import { onBeforeUnmount, ref } from 'vue'

// Records a spoken question from the microphone as 16 kHz mono 16-bit WAV:
// the one format Muse's `muse voice transcribe` reads on the server without
// ffmpeg. The browser records what it can (WebM/Opus, MP4/AAC, Ogg) and the
// clip is decoded and resampled here when the person stops.

/** Longest clip, as the server takes it. */
export const MAX_VOICE_SECONDS = 120
export const VOICE_RATE = 16000

export type VoiceState = 'idle' | 'recording' | 'encoding'

/** Whether this browser can record at all. */
export function canRecord(): boolean {
  return typeof window !== 'undefined' && !!navigator.mediaDevices?.getUserMedia && typeof MediaRecorder !== 'undefined'
}

/** 16-bit PCM WAV of mono samples in [-1, 1]. */
export function encodeWav(samples: Float32Array, rate: number): Uint8Array<ArrayBuffer> {
  const out = new Uint8Array(44 + samples.length * 2)
  const v = new DataView(out.buffer)
  const ascii = (at: number, s: string) => [...s].forEach((c, i) => v.setUint8(at + i, c.charCodeAt(0)))
  ascii(0, 'RIFF')
  v.setUint32(4, 36 + samples.length * 2, true)
  ascii(8, 'WAVEfmt ')
  v.setUint32(16, 16, true) // fmt chunk size
  v.setUint16(20, 1, true) // PCM
  v.setUint16(22, 1, true) // mono
  v.setUint32(24, rate, true)
  v.setUint32(28, rate * 2, true) // bytes per second
  v.setUint16(32, 2, true) // bytes per frame
  v.setUint16(34, 16, true)
  ascii(36, 'data')
  v.setUint32(40, samples.length * 2, true)
  for (let i = 0; i < samples.length; i++) {
    const s = Math.max(-1, Math.min(1, samples[i]))
    v.setInt16(44 + i * 2, s < 0 ? s * 0x8000 : s * 0x7fff, true)
  }
  return out
}

/** Decodes a recording and resamples it to 16 kHz mono WAV. */
async function toWav(recording: Blob): Promise<Blob> {
  const ctx = new AudioContext()
  let decoded: AudioBuffer
  try {
    decoded = await ctx.decodeAudioData(await recording.arrayBuffer())
  } finally {
    void ctx.close()
  }
  const frames = Math.max(1, Math.ceil(decoded.duration * VOICE_RATE))
  // An offline context with one channel downmixes and resamples.
  const offline = new OfflineAudioContext(1, frames, VOICE_RATE)
  const src = offline.createBufferSource()
  src.buffer = decoded
  src.connect(offline.destination)
  src.start()
  const mono = await offline.startRendering()
  return new Blob([encodeWav(mono.getChannelData(0), VOICE_RATE)], { type: 'audio/wav' })
}

/**
 * The microphone, for one clip at a time: start() asks for it, stop()
 * resolves with the WAV (stopping on its own at MAX_VOICE_SECONDS),
 * cancel() drops the clip.
 */
export function useVoiceRecorder(onLimit: () => void) {
  const state = ref<VoiceState>('idle')
  const seconds = ref(0)
  let rec: MediaRecorder | undefined
  let stream: MediaStream | undefined
  let chunks: Blob[] = []
  let timer: ReturnType<typeof setInterval> | undefined
  let started = 0

  function release() {
    clearInterval(timer)
    timer = undefined
    stream?.getTracks().forEach((t) => t.stop())
    stream = undefined
  }

  async function start() {
    if (state.value !== 'idle') return
    stream = await navigator.mediaDevices.getUserMedia({ audio: { channelCount: 1, echoCancellation: true, noiseSuppression: true } })
    chunks = []
    try {
      rec = new MediaRecorder(stream)
      rec.ondataavailable = (e) => e.data.size && chunks.push(e.data)
      rec.start()
    } catch (e) {
      release()
      throw e
    }
    started = Date.now()
    seconds.value = 0
    state.value = 'recording'
    timer = setInterval(() => {
      seconds.value = Math.floor((Date.now() - started) / 1000)
      if (seconds.value >= MAX_VOICE_SECONDS) onLimit()
    }, 250)
  }

  function stopped(): Promise<Blob> {
    return new Promise((resolve) => {
      if (!rec || rec.state === 'inactive') return resolve(new Blob(chunks))
      rec.onstop = () => resolve(new Blob(chunks, { type: rec?.mimeType }))
      rec.stop()
    })
  }

  async function stop(): Promise<Blob> {
    return (await stopClip()).wav
  }

  /** Stops and resolves with the clip as the browser recorded it (to keep and play), the same as WAV, and its length. */
  async function stopClip(): Promise<{ recording: Blob; wav: Blob; durationMs: number }> {
    if (state.value !== 'recording') throw new Error('not recording')
    state.value = 'encoding'
    const durationMs = Date.now() - started
    try {
      const recording = await stopped()
      release()
      return { recording, wav: await toWav(recording), durationMs }
    } finally {
      release()
      rec = undefined
      state.value = 'idle'
    }
  }

  function cancel() {
    if (rec && rec.state !== 'inactive') {
      rec.onstop = null
      rec.stop()
    }
    rec = undefined
    chunks = []
    release()
    state.value = 'idle'
  }

  onBeforeUnmount(cancel)
  return { state, seconds, start, stop, stopClip, cancel }
}
