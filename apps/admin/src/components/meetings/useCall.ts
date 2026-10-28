import {
  ConnectionQuality,
  createAudioAnalyser,
  createLocalAudioTrack,
  createLocalVideoTrack,
  DisconnectReason,
  type LocalAudioTrack,
  type LocalVideoTrack,
  type Participant,
  type RemoteTrack,
  Room,
  RoomEvent,
  ScreenSharePresets,
  Track,
  VideoPresets,
} from 'livekit-client'
import { computed, markRaw, onScopeDispose, reactive, ref, shallowRef } from 'vue'
import { api, HttpError, unwrap } from '../../api/client'
import type { MeetingCall, MeetingCallSettings, MeetingGrant, MeetingJoin, MeetingMessage, PublicMeeting } from '../../api/types'

// One person's call: the lobby (camera preview, devices), the join or the
// knock, the LiveKit room once let in, and every in-call request (chat,
// the waiting room, host controls) with the seat the join handed out.
// LiveKit's objects change in place, so they are kept raw and `tick`
// counts their events: the derived lists recompute on it.

/** Topics agnts sends into the room (see the server's meetings package). */
const TOPIC_CHAT = 'agnts.chat'
const TOPIC_KNOCK = 'agnts.knock'
const TOPIC_STATE = 'agnts.state'
const TOPIC_ASK_UNMUTE = 'agnts.ask-unmute'
/** Reactions go from client to client. */
const TOPIC_REACTION = 'agnts.reaction'
const ATTR_HAND = 'agnts.hand'
const ATTR_ROLE = 'agnts.role'
const ATTR_PERSON = 'agnts.person'

export type Phase = 'lobby' | 'joining' | 'waiting' | 'connecting' | 'in-call' | 'left' | 'refused' | 'removed' | 'ended' | 'error'

export type Tile = {
  identity: string
  name: string
  person: string
  role: string
  local: boolean
  camera?: Track
  screen?: Track
  micOn: boolean
  camOn: boolean
  speaking: boolean
  hand: number // when raised, 0 when not
  quality: ConnectionQuality
}

export type Reaction = { id: number; emoji: string; name: string }

export type RoomMeta = { title?: string; locked?: boolean; guests?: string; guestsQuiet?: boolean; recording?: boolean; notes?: boolean }

/** The device id this browser keeps, part of its LiveKit identity. */
export function deviceId(): string {
  try {
    let id = localStorage.getItem('agnts.meet.device')
    if (!id || !/^[a-z0-9]{4,16}$/.test(id)) {
      id = Array.from(crypto.getRandomValues(new Uint8Array(8)), (b) => 'abcdefghijklmnopqrstuvwxyz0123456789'[b % 36]).join('')
      localStorage.setItem('agnts.meet.device', id)
    }
    return id
  } catch {
    return Math.random().toString(36).slice(2, 10)
  }
}

const guestKey = (code: string) => `agnts.meet.guest.${code.replace(/-/g, '')}`

function storedGuest(code: string): string {
  try {
    return localStorage.getItem(guestKey(code)) ?? ''
  } catch {
    return ''
  }
}

function storeGuest(code: string, token: string) {
  try {
    localStorage.setItem(guestKey(code), token)
  } catch {
    /* private mode: the guest is new next time */
  }
}

/** Devices the lobby offers, remembered per browser. */
export type DevicePrefs = { mic: string; cam: string; speaker: string; micOn: boolean; camOn: boolean }

function loadPrefs(): DevicePrefs {
  try {
    const p = JSON.parse(localStorage.getItem('agnts.meet.devices') ?? '{}')
    return { mic: p.mic ?? '', cam: p.cam ?? '', speaker: p.speaker ?? '', micOn: p.micOn ?? true, camOn: p.camOn ?? true }
  } catch {
    return { mic: '', cam: '', speaker: '', micOn: true, camOn: true }
  }
}

function savePrefs(p: DevicePrefs) {
  try {
    localStorage.setItem('agnts.meet.devices', JSON.stringify(p))
  } catch {
    /* not remembered */
  }
}

export function useCall(code: string) {
  const phase = ref<Phase>('lobby')
  const error = ref('')
  const refusal = ref('') // the server's reason code
  const info = shallowRef<PublicMeeting | null>(null)
  const grant = shallowRef<MeetingGrant | null>(null)
  const state = shallowRef<MeetingCall | null>(null)
  const messages = ref<MeetingMessage[]>([])
  const unread = ref(0)
  const chatOpen = ref(false)
  const reactions = ref<Reaction[]>([])
  const askedUnmute = ref('')
  const audioBlocked = ref(false)
  const reconnecting = ref(false)
  const meta = ref<RoomMeta>({})
  const knock = reactive({ id: 0, token: '' })
  const prefs = reactive(loadPrefs())
  const devices = reactive({ mics: [] as MediaDeviceInfo[], cams: [] as MediaDeviceInfo[], speakers: [] as MediaDeviceInfo[] })
  const preview = shallowRef<LocalVideoTrack | null>(null)
  const previewMic = shallowRef<LocalAudioTrack | null>(null)
  const micLevel = ref(0)
  const tick = ref(0)
  const screenOn = ref(false)
  let room: Room | null = null
  let audioBox: HTMLElement | null = null
  let stopLevel: (() => void) | null = null
  let stateTimer: ReturnType<typeof setInterval> | undefined
  let reactionSeq = 0
  let aborted = false
  const device = deviceId()

  const seat = () => grant.value?.seat ?? ''
  const headers = () => ({ 'X-Meeting-Seat': seat() })

  // --- The lobby ---

  async function loadInfo() {
    try {
      info.value = await unwrap(api.GET('/public/meetings/{code}', { params: { path: { code } } }))
    } catch (e) {
      phase.value = 'error'
      error.value = e instanceof HttpError && e.status === 404 ? 'not_found' : e instanceof HttpError ? e.message : 'error'
    }
  }

  async function listDevices() {
    try {
      const all = await Room.getLocalDevices(undefined, false)
      devices.mics = all.filter((d) => d.kind === 'audioinput' && d.deviceId)
      devices.cams = all.filter((d) => d.kind === 'videoinput' && d.deviceId)
      devices.speakers = all.filter((d) => d.kind === 'audiooutput' && d.deviceId)
    } catch {
      /* no devices to list */
    }
  }

  /** Starts (or restarts) the lobby's camera and microphone preview. */
  async function startPreview() {
    stopPreview()
    error.value = ''
    try {
      if (prefs.camOn) {
        preview.value = markRaw(await createLocalVideoTrack({ deviceId: prefs.cam || undefined, resolution: VideoPresets.h720.resolution }))
      }
      if (prefs.micOn) {
        previewMic.value = markRaw(await createLocalAudioTrack({ deviceId: prefs.mic || undefined, echoCancellation: true, noiseSuppression: true }))
        const { calculateVolume, cleanup } = createAudioAnalyser(previewMic.value)
        const timer = setInterval(() => (micLevel.value = calculateVolume()), 100)
        stopLevel = () => {
          clearInterval(timer)
          void cleanup()
        }
      }
    } catch (e) {
      error.value = e instanceof Error && e.name === 'NotAllowedError' ? 'devices_blocked' : 'devices_failed'
    }
    await listDevices()
  }

  function stopPreview() {
    stopLevel?.()
    stopLevel = null
    micLevel.value = 0
    preview.value?.stop()
    previewMic.value?.stop()
    preview.value = null
    previewMic.value = null
  }

  async function setPref<K extends keyof DevicePrefs>(key: K, value: DevicePrefs[K]) {
    prefs[key] = value
    savePrefs({ ...prefs })
    if (phase.value === 'lobby') await startPreview()
    else if (room) {
      if (key === 'mic' && typeof value === 'string') await room.switchActiveDevice('audioinput', value)
      if (key === 'cam' && typeof value === 'string') await room.switchActiveDevice('videoinput', value)
      if (key === 'speaker' && typeof value === 'string') await room.switchActiveDevice('audiooutput', value)
    }
  }

  // --- Joining ---

  /** Asks to join: a name for guests, Google, or an invitation link's token. */
  async function join(body: { name?: string; googleCredential?: string; invite?: string }) {
    phase.value = 'joining'
    error.value = ''
    refusal.value = ''
    try {
      const guest = storedGuest(code)
      const res = await unwrap(
        api.POST('/public/meetings/{code}/join', {
          params: { path: { code }, header: guest ? { 'X-Guest-Token': guest } : {} },
          body: { ...body, device },
        }),
      )
      await answered(res)
    } catch (e) {
      failed(e)
    }
  }

  async function answered(res: MeetingJoin) {
    if (res.guestToken) storeGuest(code, res.guestToken)
    if (res.status === 'joined' && res.grant) {
      grant.value = res.grant
      await connect(res.grant)
      return
    }
    knock.id = res.knockId ?? 0
    knock.token = res.knockToken ?? ''
    phase.value = 'waiting'
    void waitKnock()
  }

  async function waitKnock() {
    while (phase.value === 'waiting' && !aborted) {
      try {
        const res = await unwrap(
          api.GET('/public/meetings/{code}/knocks/{knockId}', {
            params: { path: { code, knockId: knock.id }, header: { 'X-Knock-Token': knock.token } },
          }),
        )
        if (res.status === 'joined') {
          await answered(res)
          return
        }
      } catch (e) {
        if (e instanceof HttpError && (e.status === 403 || e.status === 404)) {
          failed(e)
          return
        }
        await new Promise((r) => setTimeout(r, 3000)) // the server or the network is down: try again
      }
    }
  }

  function cancelKnock() {
    phase.value = 'lobby'
    knock.id = 0
  }

  function failed(e: unknown) {
    if (e instanceof HttpError && e.status === 403) {
      phase.value = 'refused'
      refusal.value = e.code
      error.value = e.message
      return
    }
    phase.value = 'error'
    error.value = e instanceof HttpError ? e.message : 'error'
  }

  // --- The room ---

  function bump() {
    tick.value++
  }

  async function connect(g: MeetingGrant) {
    phase.value = 'connecting'
    const r = markRaw(
      new Room({
        adaptiveStream: true,
        dynacast: true,
        videoCaptureDefaults: { resolution: VideoPresets.h720.resolution, deviceId: prefs.cam || undefined },
        audioCaptureDefaults: { echoCancellation: true, noiseSuppression: true, autoGainControl: true, deviceId: prefs.mic || undefined },
        audioOutput: prefs.speaker ? { deviceId: prefs.speaker } : undefined,
        publishDefaults: { simulcast: true, screenShareEncoding: ScreenSharePresets.h1080fps15.encoding, dtx: true, red: true },
      }),
    )
    room = r
    r.on(RoomEvent.ParticipantConnected, () => {
      bump()
      void refreshState()
    })
      .on(RoomEvent.ParticipantDisconnected, () => {
        bump()
        void refreshState()
      })
      .on(RoomEvent.TrackSubscribed, (track: RemoteTrack) => {
        if (track.kind === Track.Kind.Audio) attachAudio(track)
        bump()
      })
      .on(RoomEvent.TrackUnsubscribed, (track: RemoteTrack) => {
        if (track.kind === Track.Kind.Audio) track.detach().forEach((el) => el.remove())
        bump()
      })
      .on(RoomEvent.TrackMuted, bump)
      .on(RoomEvent.TrackUnmuted, bump)
      .on(RoomEvent.LocalTrackPublished, bump)
      .on(RoomEvent.LocalTrackUnpublished, () => {
        screenOn.value = !!r.localParticipant.getTrackPublication(Track.Source.ScreenShare)?.track
        bump()
      })
      .on(RoomEvent.ActiveSpeakersChanged, bump)
      .on(RoomEvent.ConnectionQualityChanged, bump)
      .on(RoomEvent.ParticipantNameChanged, bump)
      .on(RoomEvent.ParticipantAttributesChanged, (_changed: Record<string, string>, p: Participant) => {
        bump()
        if (p.isLocal && _changed[ATTR_ROLE] !== undefined) void refreshState()
      })
      .on(RoomEvent.ParticipantPermissionsChanged, () => {
        bump()
        void refreshState()
      })
      .on(RoomEvent.RoomMetadataChanged, (md: string) => readMeta(md))
      .on(RoomEvent.DataReceived, (payload: Uint8Array, p?: Participant, _kind?: unknown, topic?: string) => onData(payload, p, topic))
      .on(RoomEvent.AudioPlaybackStatusChanged, () => (audioBlocked.value = !r.canPlaybackAudio))
      .on(RoomEvent.Reconnecting, () => (reconnecting.value = true))
      .on(RoomEvent.Reconnected, () => {
        reconnecting.value = false
        void refreshState()
      })
      .on(RoomEvent.Disconnected, (reason?: DisconnectReason) => onDisconnected(reason))
    try {
      await r.connect(g.url, g.token)
    } catch (e) {
      phase.value = 'error'
      error.value = e instanceof Error ? e.message : 'connect_failed'
      return
    }
    stopPreview()
    readMeta(r.metadata ?? '')
    phase.value = 'in-call'
    audioBlocked.value = !r.canPlaybackAudio
    if (g.rights.publish) {
      if (prefs.micOn) await safe(() => r.localParticipant.setMicrophoneEnabled(true))
      if (prefs.camOn) await safe(() => r.localParticipant.setCameraEnabled(true))
    }
    bump()
    await Promise.all([refreshState(), loadMessages()])
    stateTimer = setInterval(() => void refreshState(), 15_000)
  }

  async function safe(fn: () => Promise<unknown>) {
    try {
      await fn()
    } catch (e) {
      error.value = e instanceof Error && e.name === 'NotAllowedError' ? 'devices_blocked' : 'devices_failed'
    }
  }

  function attachAudio(track: RemoteTrack) {
    if (!audioBox) {
      audioBox = document.createElement('div')
      audioBox.hidden = true
      document.body.appendChild(audioBox)
    }
    const el = track.attach()
    audioBox.appendChild(el)
  }

  function readMeta(md: string) {
    try {
      meta.value = md ? (JSON.parse(md) as RoomMeta) : {}
    } catch {
      meta.value = {}
    }
  }

  function onData(payload: Uint8Array, p: Participant | undefined, topic?: string) {
    let body: Record<string, unknown>
    try {
      body = JSON.parse(new TextDecoder().decode(payload))
    } catch {
      return
    }
    switch (topic) {
      case TOPIC_CHAT: {
        const m = body as unknown as MeetingMessage
        if (!messages.value.some((x) => x.id === m.id)) {
          messages.value.push(m)
          if (!chatOpen.value) unread.value++
        }
        break
      }
      case TOPIC_KNOCK:
      case TOPIC_STATE:
        void refreshState()
        break
      case TOPIC_ASK_UNMUTE:
        askedUnmute.value = String(body.from ?? '')
        break
      case TOPIC_REACTION:
        if (typeof body.emoji === 'string') showReaction(body.emoji, p?.name || p?.identity || '')
        break
    }
  }

  function showReaction(emoji: string, name: string) {
    const id = ++reactionSeq
    reactions.value.push({ id, emoji, name })
    setTimeout(() => (reactions.value = reactions.value.filter((r) => r.id !== id)), 4000)
  }

  function onDisconnected(reason?: DisconnectReason) {
    clearInterval(stateTimer)
    audioBox?.remove()
    audioBox = null
    room = null
    bump()
    if (phase.value === 'left') return
    switch (reason) {
      case DisconnectReason.PARTICIPANT_REMOVED:
        phase.value = 'removed'
        break
      case DisconnectReason.ROOM_DELETED:
        phase.value = 'ended'
        break
      case DisconnectReason.DUPLICATE_IDENTITY:
        phase.value = 'left'
        error.value = 'duplicate'
        break
      default:
        phase.value = 'left'
    }
  }

  async function refreshState() {
    if (!seat()) return
    try {
      state.value = await unwrap(api.GET('/public/meetings/{code}/call', { params: { path: { code }, header: headers() } }))
    } catch (e) {
      if (e instanceof HttpError && e.status === 401 && phase.value === 'in-call') {
        // The seat ended (removed, or the session is over).
        await room?.disconnect()
      }
    }
  }

  async function loadMessages() {
    const after = messages.value.at(-1)?.id ?? 0
    try {
      const got = await unwrap(api.GET('/public/meetings/{code}/call/messages', { params: { path: { code }, query: { after }, header: headers() } }))
      for (const m of got) if (!messages.value.some((x) => x.id === m.id)) messages.value.push(m)
    } catch {
      /* the chat stays as it is */
    }
  }

  // --- What the person does ---

  const local = computed(() => {
    void tick.value
    return room?.localParticipant
  })
  const micOn = computed(() => {
    void tick.value
    return !!room?.localParticipant.isMicrophoneEnabled
  })
  const camOn = computed(() => {
    void tick.value
    return !!room?.localParticipant.isCameraEnabled
  })
  const handUp = computed(() => {
    void tick.value
    return !!room?.localParticipant.attributes?.[ATTR_HAND]
  })

  async function toggleMic() {
    if (!room) return
    const on = !room.localParticipant.isMicrophoneEnabled
    await safe(() => room!.localParticipant.setMicrophoneEnabled(on))
    prefs.micOn = on
    savePrefs({ ...prefs })
    if (on) askedUnmute.value = ''
    bump()
  }

  async function toggleCam() {
    if (!room) return
    const on = !room.localParticipant.isCameraEnabled
    await safe(() => room!.localParticipant.setCameraEnabled(on))
    prefs.camOn = on
    savePrefs({ ...prefs })
    bump()
  }

  async function toggleScreen() {
    if (!room) return
    const on = !room.localParticipant.isScreenShareEnabled
    try {
      await room.localParticipant.setScreenShareEnabled(on, { audio: true, selfBrowserSurface: 'exclude', surfaceSwitching: 'include' })
      screenOn.value = on
    } catch (e) {
      // Cancelled in the browser's picker: nothing to say.
      if (!(e instanceof Error && e.name === 'NotAllowedError')) error.value = 'screen_failed'
    }
    bump()
  }

  async function toggleHand() {
    if (!room) return
    await room.localParticipant.setAttributes({ [ATTR_HAND]: handUp.value ? '' : String(Date.now()) })
    bump()
  }

  async function react(emoji: string) {
    if (!room) return
    await room.localParticipant.publishData(new TextEncoder().encode(JSON.stringify({ emoji })), { reliable: true, topic: TOPIC_REACTION })
    showReaction(emoji, room.localParticipant.name || '')
  }

  async function startAudio() {
    await room?.startAudio()
    audioBlocked.value = !room?.canPlaybackAudio
  }

  async function send(body: string) {
    const m = await unwrap(api.POST('/public/meetings/{code}/call/messages', { params: { path: { code }, header: headers() }, body: { body } }))
    if (!messages.value.some((x) => x.id === m.id)) messages.value.push(m)
  }

  function openChat(open: boolean) {
    chatOpen.value = open
    if (open) unread.value = 0
  }

  async function decide(knockId: number, decision: 'admit' | 'deny') {
    await unwrap(api.POST('/public/meetings/{code}/call/knocks/{knockId}/{decision}', { params: { path: { code, knockId, decision }, header: headers() } }))
    await refreshState()
  }

  async function admitAll() {
    await unwrap(api.POST('/public/meetings/{code}/call/admit-all', { params: { path: { code }, header: headers() } }))
    await refreshState()
  }

  type Action = 'mute' | 'ask-unmute' | 'remove' | 'lower-hand' | 'cohost' | 'uncohost'
  async function act(person: string, action: Action, source?: 'microphone' | 'camera' | 'screen_share') {
    await unwrap(
      api.POST('/public/meetings/{code}/call/people/{person}/{action}', {
        params: { path: { code, person, action }, header: headers() },
        body: source ? { source } : {},
      }),
    )
    await refreshState()
  }

  async function muteAll() {
    await unwrap(api.POST('/public/meetings/{code}/call/mute-all', { params: { path: { code }, header: headers() } }))
  }

  async function settings(body: MeetingCallSettings) {
    await unwrap(api.PUT('/public/meetings/{code}/call/settings', { params: { path: { code }, header: headers() }, body }))
    await refreshState()
  }

  async function leave() {
    phase.value = 'left'
    clearInterval(stateTimer)
    await room?.disconnect()
  }

  async function endForAll() {
    await unwrap(api.POST('/public/meetings/{code}/call/end', { params: { path: { code }, header: headers() } }))
    phase.value = 'ended'
    await room?.disconnect()
  }

  /** Back to the lobby to join again (after leaving or a dropped connection). */
  async function rejoin() {
    phase.value = 'lobby'
    error.value = ''
    await startPreview()
  }

  // --- The tiles ---

  const tiles = computed<Tile[]>(() => {
    void tick.value
    const r = room
    if (!r) return []
    const all: Participant[] = [r.localParticipant, ...r.remoteParticipants.values()]
    return all.map((p) => ({
      identity: p.identity,
      name: p.name || p.identity,
      person: p.attributes?.[ATTR_PERSON] ?? '',
      role: p.attributes?.[ATTR_ROLE] ?? '',
      local: p.isLocal,
      camera: p.getTrackPublication(Track.Source.Camera)?.isMuted ? undefined : p.getTrackPublication(Track.Source.Camera)?.track,
      screen: p.getTrackPublication(Track.Source.ScreenShare)?.track,
      micOn: !!p.getTrackPublication(Track.Source.Microphone) && !p.getTrackPublication(Track.Source.Microphone)?.isMuted,
      camOn: !!p.getTrackPublication(Track.Source.Camera)?.track && !p.getTrackPublication(Track.Source.Camera)?.isMuted,
      speaking: p.isSpeaking,
      hand: Number(p.attributes?.[ATTR_HAND] || 0),
      quality: p.connectionQuality,
    }))
  })

  /** Raised hands, first raised first. */
  const hands = computed(() => tiles.value.filter((t) => t.hand > 0).sort((a, b) => a.hand - b.hand))

  /** The person speaking, or the one who spoke last. */
  let lastSpeaker = ''
  const speaker = computed(() => {
    void tick.value
    const s = room?.activeSpeakers.find((p) => !p.isLocal)
    if (s) lastSpeaker = s.identity
    return tiles.value.find((t) => t.identity === lastSpeaker) ?? tiles.value.find((t) => !t.local) ?? tiles.value[0]
  })

  const shares = computed(() => tiles.value.filter((t) => t.screen))

  async function start() {
    await loadInfo()
    if (phase.value === 'lobby') await startPreview()
  }

  onScopeDispose(() => {
    aborted = true
    clearInterval(stateTimer)
    stopPreview()
    void room?.disconnect()
  })

  return {
    code, phase, error, refusal, info, grant, state, messages, unread, chatOpen, reactions, askedUnmute, audioBlocked, reconnecting, meta,
    prefs, devices, preview, micLevel, micOn, camOn, screenOn, handUp, local, tiles, hands, speaker, shares,
    start, startPreview, stopPreview, setPref, join, cancelKnock, toggleMic, toggleCam, toggleScreen, toggleHand, react, startAudio, send, openChat,
    decide, admitAll, act, muteAll, settings, leave, endForAll, rejoin, refreshState,
  }
}

export type Call = ReturnType<typeof useCall>
