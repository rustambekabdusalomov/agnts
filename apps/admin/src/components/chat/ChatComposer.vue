<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import type { AttachedFile } from '../../api/types'
import { canRecord, MAX_VOICE_SECONDS, useVoiceRecorder } from '../../composables/useVoiceRecorder'
import FileAttach from '../files/FileAttach.vue'
import HiIcon from '../ui/HiIcon.vue'
import { MAX_CHAT, type ChatMessage } from './chat'

// The message box: Enter sends, Shift+Enter starts a new line. A reply shows
// what it answers above the box, with a way to drop it. Files come with the
// paperclip, by dropping them on the box, or by pasting a screenshot; they
// upload at once and go with the next message (text is then optional).
const props = defineProps<{ channelName: string; replyTo?: ChatMessage }>()
const emit = defineEmits<{
  send: [body: string, files: AttachedFile[]]
  voice: [clip: { recording: Blob; wav: Blob; durationMs: number }]
  cancelReply: []
}>()
const { t } = useI18n()

const text = ref('')
const box = ref<HTMLTextAreaElement | null>(null)
const length = computed(() => text.value.trim().length)
const over = computed(() => text.value.length > MAX_CHAT)

const fileIds = ref<number[]>([])
const uploading = ref(false)
const attach = ref<InstanceType<typeof FileAttach> | null>(null)
const dragging = ref(false)
const canSend = computed(() => (length.value > 0 || fileIds.value.length > 0) && !over.value && !uploading.value)

function submit() {
  const body = text.value.trim()
  if (!canSend.value) return
  const files: AttachedFile[] = (attach.value?.attached() ?? []).map((a) => ({
    id: a.id, name: a.name, contentType: a.contentType, size: a.size, image: !!a.image, url: a.url,
  }))
  emit('send', body, files)
  text.value = ''
  fileIds.value = [] // clears the list (the uploads now belong to the message)
}

function dropped(e: DragEvent) {
  dragging.value = false
  if (e.dataTransfer?.files.length) attach.value?.add(Array.from(e.dataTransfer.files))
}
function pasted(e: ClipboardEvent) {
  attach.value?.pasted(e)
}

function onKey(e: KeyboardEvent) {
  if (e.key === 'Enter' && !e.shiftKey && !e.isComposing) {
    e.preventDefault()
    submit()
  } else if (e.key === 'Escape' && props.replyTo) emit('cancelReply')
}

watch(
  () => props.replyTo,
  (r) => {
    if (r) void nextTick(() => box.value?.focus())
  },
)

// A voice message: the mic records, Send sends the clip (it also stops at
// the limit), Cancel drops it. Muse hears it on the server.
const voiceOn = canRecord()
const voice = useVoiceRecorder(() => void sendVoice())
const micError = ref('')

async function startVoice() {
  micError.value = ''
  try {
    await voice.start()
  } catch (e) {
    const denied = e instanceof DOMException && (e.name === 'NotAllowedError' || e.name === 'SecurityError')
    micError.value = denied ? t('teamchat.voiceDenied') : t('teamchat.voiceNoMic')
  }
}

async function sendVoice() {
  if (voice.state.value !== 'recording') return
  try {
    emit('voice', await voice.stopClip())
  } catch {
    micError.value = t('teamchat.voiceNoMic')
  }
}

const clock = (s: number) => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`

defineExpose({ focus: () => box.value?.focus() })
</script>

<template>
  <form
    class="cp"
    :class="{ drag: dragging }"
    @submit.prevent="submit"
    @dragover.prevent="dragging = voice.state.value === 'idle'"
    @dragleave.self="dragging = false"
    @drop.prevent="dropped"
  >
    <p v-if="dragging" class="cp-drop" aria-hidden="true">{{ t('files.drop') }}</p>
    <div v-if="replyTo" class="cp-reply">
      <span>↪ {{ t('teamchat.replyingTo', { name: replyTo.author }) }}: <i>{{ (replyTo.body || replyTo.card?.title || '').slice(0, 100) }}</i></span>
      <button type="button" class="cp-x" :aria-label="t('teamchat.cancelReply')" @click="emit('cancelReply')">×</button>
    </div>
    <div v-if="voice.state.value !== 'idle'" class="cp-rec" role="status">
      <span class="cp-dot" aria-hidden="true" />
      <span v-if="voice.state.value === 'encoding'">{{ t('teamchat.voiceEncoding') }}</span>
      <span v-else>{{ t('teamchat.voiceRecording') }} <b class="cp-clock">{{ clock(voice.seconds.value) }}</b> <small class="hint">{{ t('teamchat.voiceLimit', { n: MAX_VOICE_SECONDS / 60 }) }}</small></span>
      <span class="cp-sp" />
      <button type="button" class="btn" :disabled="voice.state.value === 'encoding'" @click="voice.cancel()">{{ t('form.cancel') }}</button>
      <button type="button" class="btn btn-p" :disabled="voice.state.value === 'encoding'" @click="sendVoice">{{ t('teamchat.voiceSend') }}</button>
    </div>
    <FileAttach v-show="voice.state.value === 'idle'" ref="attach" v-model="fileIds" v-model:busy="uploading" bare />
    <textarea
      v-if="voice.state.value === 'idle'"
      ref="box"
      v-model="text"
      rows="2"
      :placeholder="t('teamchat.placeholder', { channel: channelName })"
      :aria-label="t('teamchat.placeholder', { channel: channelName })"
      @keydown="onKey"
      @paste="pasted"
    />
    <div v-if="voice.state.value === 'idle'" class="cp-f">
      <span class="hint" :class="{ ferr: over || micError }">{{ micError || (text.length > MAX_CHAT - 500 ? t('teamchat.count', { n: text.length, max: MAX_CHAT }) : t('teamchat.sendHint')) }}</span>
      <span class="cp-btns">
        <button type="button" class="btn cp-attach" :title="t('files.attach')" :aria-label="t('files.attach')" @click="attach?.open()">
          <HiIcon name="attach" />
        </button>
        <button v-if="voiceOn" type="button" class="btn cp-mic" :title="t('teamchat.voiceStart')" :aria-label="t('teamchat.voiceStart')" @click="startVoice">
          <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3a3 3 0 0 0-3 3v6a3 3 0 0 0 6 0V6a3 3 0 0 0-3-3Z" /><path d="M5 11a7 7 0 0 0 14 0M12 18v3" /></svg>
        </button>
        <button type="submit" class="btn btn-p" :disabled="!canSend" :title="uploading ? t('files.wait') : undefined">{{ t('teamchat.send') }}</button>
      </span>
    </div>
  </form>
</template>

<style scoped>
.cp { border-top: 1px solid var(--line); padding: 12px 16px; display: flex; flex-direction: column; gap: 8px; }
.cp textarea { min-height: 48px; resize: none; }
.cp-f { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
.cp-reply { display: flex; align-items: center; gap: 8px; justify-content: space-between; padding: 4px 10px; border-left: 3px solid var(--primary); border-radius: 6px; background: var(--primary-soft); color: var(--primary-ink); font-size: 13px; }
.cp-reply span { min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.cp-x { border: 0; background: none; color: inherit; font-size: 18px; line-height: 1; cursor: pointer; }
.cp-btns { display: inline-flex; gap: 8px; }
.cp-mic, .cp-attach { padding: 0 10px; }
.cp.drag { outline: 2px dashed var(--primary); outline-offset: -4px; }
.cp-drop { margin: 0; font-size: 13px; color: var(--primary-ink); font-weight: 600; }
.cp-attach :deep(svg), .cp-mic svg { width: 18px; height: 18px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; }
.cp-rec { display: flex; align-items: center; gap: 10px; min-height: 48px; padding: 0 4px; font-size: 14.5px; }
.cp-dot { width: 12px; height: 12px; border-radius: 50%; background: var(--bad); animation: cp-pulse 1.2s ease-in-out infinite; }
@keyframes cp-pulse { 50% { opacity: 0.3; } }
@media (prefers-reduced-motion: reduce) { .cp-dot { animation: none; } }
.cp-clock { font-variant-numeric: tabular-nums; }
.cp-sp { flex: 1; }
</style>
