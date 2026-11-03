<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, nextTick, onBeforeUnmount, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, transcribeQuestion, unwrap } from '../api/client'
import type { AssistantConversation, AssistantLink, AssistantMessage } from '../api/types'
import { applyLive, assistantLang, fileLabel, isOpen, live, MAX_QUESTION, secs } from '../components/assistant/assistant'
import AssistantActionCard from '../components/assistant/AssistantActionCard.vue'
import ChatBody from '../components/chat/ChatBody.vue'
import ChatModeSwitch from '../components/codechat/ChatModeSwitch.vue'
import PageHeader from '../components/PageHeader.vue'
import ReportView from '../components/ticket/ReportView.vue'
import HiIcon from '../components/ui/HiIcon.vue'
import { livePoll, useLive } from '../composables/useLive'
import { canRecord, MAX_VOICE_SECONDS, useVoiceRecorder } from '../composables/useVoiceRecorder'
import { useWorkspace } from '../stores/workspace'

// The assistant's chat: questions about the workspace, typed, answered in
// 10-30 seconds from a snapshot of it, with links to what the answers name.
// Asked to act, an answer carries the actions as cards; nothing happens
// until the person confirms one. The open conversation is in the URL (/assistant/<id>);
// the person's conversations are listed on their own page.
const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const qc = useQueryClient()
useLive(applyLive)

const id = computed(() => Number(route.params.id) || 0)

const conv = useQuery({
  queryKey: computed(() => ['assistant', 'conversation', id.value]),
  queryFn: () => unwrap(api.GET('/assistant/conversations/{conversationId}', { params: { path: { conversationId: id.value } } })),
  enabled: computed(() => id.value > 0),
  // While an answer is being made, poll too: the stream may be down.
  refetchInterval: (q) => ((q.state.data as AssistantConversation | undefined)?.messages.some(isOpen) ? 3000 : livePoll(60_000)),
})
const messages = computed(() => (id.value ? (conv.data.value?.messages ?? []) : []))
const open = computed(() => messages.value.some(isOpen))

// Redraws the "thinking" seconds while an answer is open.
const now = ref(Date.now())
let tick: ReturnType<typeof setInterval> | undefined
watch(open, (o) => {
  clearInterval(tick)
  tick = o ? setInterval(() => (now.value = Date.now()), 1000) : undefined
}, { immediate: true })
onBeforeUnmount(() => clearInterval(tick))
const thinking = (m: AssistantMessage) => Math.max(0, Math.round((now.value - new Date(m.createdAt).getTime()) / 1000))

// Newest at the bottom, kept in view as answers arrive.
const scroller = ref<HTMLElement | null>(null)
watch(() => [messages.value.length, messages.value.at(-1)?.status, live.get(messages.value.at(-1)?.id ?? 0)?.text], async () => {
  await nextTick()
  if (scroller.value) scroller.value.scrollTop = scroller.value.scrollHeight
}, { flush: 'post' })

const text = ref('')
const error = ref('')
const length = computed(() => text.value.trim().length)
const ask = useMutation({
  mutationFn: (question: string) => {
    const body = { question, lang: assistantLang(locale.value) }
    return id.value
      ? unwrap(api.POST('/assistant/conversations/{conversationId}/messages', { params: { path: { conversationId: id.value } }, body }))
      : unwrap(api.POST('/assistant/conversations', { body }))
  },
  onMutate: () => (error.value = ''),
  onSuccess: async (c, question) => {
    if (question === text.value.trim()) text.value = ''
    qc.setQueryData(['assistant', 'conversation', c.id], c)
    void qc.invalidateQueries({ queryKey: ['assistant', 'list'] })
    if (c.id !== id.value) await router.replace({ name: 'assistant', params: { id: c.id } })
  },
  onError: (e) => (error.value = e instanceof Error ? e.message : t('common.error')),
})
function send(question = text.value.trim()) {
  if (!question || question.length > MAX_QUESTION || ask.isPending.value) return
  ask.mutate(question)
}
function onKey(e: KeyboardEvent) {
  if (e.key === 'Enter' && !e.shiftKey && !e.isComposing) {
    e.preventDefault()
    send()
  }
}
// Voice: the person speaks the question; Muse hears it on the server and
// its words are asked as a typed question is.
const voiceOn = canRecord()
const voice = useVoiceRecorder(() => void finishVoice())
const hearing = ref(false)
const clock = (s: number) => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`
async function startVoice() {
  error.value = ''
  try {
    await voice.start()
  } catch (e) {
    const denied = e instanceof DOMException && (e.name === 'NotAllowedError' || e.name === 'SecurityError')
    error.value = denied ? t('massistant.voiceDenied') : t('massistant.voiceNoMic')
  }
}
async function finishVoice() {
  if (voice.state.value !== 'recording') return
  hearing.value = true
  try {
    const question = (await transcribeQuestion(await voice.stop())).trim().slice(0, MAX_QUESTION)
    if (question) send(question)
  } catch (e) {
    error.value = e instanceof Error ? e.message : t('common.error')
  } finally {
    hearing.value = false
  }
}

/** The question an answer belongs to, to ask it again. */
function questionOf(m: AssistantMessage): string | undefined {
  const i = messages.value.indexOf(m)
  const q = messages.value[i - 1]
  return q?.role === 'user' ? q.text : undefined
}


// Rating: the thumb that is on takes it back; the other opens a short form.
const rating = reactive({ id: 0, value: 0 as -1 | 1, comment: '', share: false, busy: false })
function thumb(m: AssistantMessage, value: -1 | 1) {
  if (m.rating === value) return void rate(m.id, 0, '', false)
  Object.assign(rating, { id: m.id, value, comment: '', share: false })
}
async function rate(messageId: number, value: -1 | 0 | 1, comment: string, share: boolean) {
  rating.busy = true
  try {
    await unwrap(api.PUT('/assistant/messages/{messageId}/rating', {
      params: { path: { messageId } },
      body: { rating: value, comment: comment.trim() || undefined, share },
    }))
    rating.id = 0
    await qc.invalidateQueries({ queryKey: ['assistant', 'conversation', id.value] })
  } catch (e) {
    error.value = e instanceof Error ? e.message : t('common.error')
  } finally {
    rating.busy = false
  }
}

function linkTo(l: AssistantLink) {
  if (l.kind === 'ticket') return { name: 'ticket', params: { key: l.key } }
  if (l.kind === 'ci') return { name: 'ciFailure', params: { id: l.id } }
  return { name: 'lesson', params: { id: l.id } }
}
function linkLabel(l: AssistantLink) {
  if (l.kind === 'ticket') return l.key ?? ''
  return l.kind === 'ci' ? t('massistant.linkCi', { id: l.id }) : t('massistant.linkLesson', { id: l.id })
}

const workspace = useWorkspace()
const suggestions = computed(() => [
  t('massistant.suggestWaiting'), t('massistant.suggestCi'), t('massistant.suggestSpend'), t('massistant.suggestDone'),
  ...(workspace.canEdit ? [t('massistant.suggestAct')] : []),
])
</script>

<template>
  <PageHeader :title="id && conv.data.value ? conv.data.value.title : t('nav.assistantChat')">
    <div class="actions" style="margin: 0">
      <ChatModeSwitch mode="chat" />
      <RouterLink class="btn" :to="{ name: 'assistantConversations' }"><HiIcon name="logs" />{{ t('nav.assistantConversations') }}</RouterLink>
      <RouterLink v-if="id" class="btn btn-p" :to="{ name: 'assistant' }"><HiIcon name="plus" />{{ t('massistant.newConversation') }}</RouterLink>
    </div>
    <template #below><p class="sub" style="margin: 4px 0 0">{{ t('massistant.private') }}</p></template>
  </PageHeader>

  <section class="card as-chat">
    <div ref="scroller" class="as-msgs" aria-live="polite">
      <div v-if="!id" class="as-empty">
        <HiIcon name="assistant" class="as-big" />
        <h2>{{ t('massistant.emptyTitle') }}</h2>
        <p class="hint">{{ t('massistant.emptyText') }}</p>
        <div class="as-suggest">
          <button v-for="s in suggestions" :key="s" type="button" class="btn btn-s" :disabled="ask.isPending.value" @click="send(s)">{{ s }}</button>
        </div>
      </div>
      <p v-else-if="conv.isPending.value" class="hint">{{ t('common.loading') }}</p>
      <p v-else-if="conv.isError.value" class="ferr">{{ t('common.error') }}</p>
      <template v-for="m in messages" v-else :key="m.id">
        <div v-if="m.role === 'user'" class="as-q">{{ m.text }}</div>
        <div v-else class="as-a" :class="{ failed: m.status === 'failed' }">
          <template v-if="isOpen(m)">
            <div class="as-think"><span class="as-spin" />{{ t('massistant.thinking', { seconds: thinking(m) }) }}</div>
            <p v-if="live.get(m.id)?.file && !live.get(m.id)?.text" class="hint">{{ t('massistant.reading', { what: fileLabel(t, live.get(m.id)!.file!) }) }}</p>
            <ReportView v-if="live.get(m.id)?.text" class="as-partial" :markdown="live.get(m.id)!.text!" />
          </template>
          <template v-else-if="m.status === 'failed'">
            <b>{{ t('massistant.failed') }}</b>
            <p v-if="m.error" class="as-err">{{ m.error }}</p>
            <button v-if="questionOf(m)" type="button" class="btn btn-s" :disabled="ask.isPending.value" @click="send(questionOf(m))">{{ t('massistant.askAgain') }}</button>
          </template>
          <template v-else>
            <ChatBody :body="m.text" cite assistant />
            <AssistantActionCard v-for="a in m.actions ?? []" :key="a.id" :action="a" />
            <div v-if="m.handoff" class="as-handoff">
              <b>{{ t('codechat.handoffTitle') }}</b>
              <p>{{ m.handoff.request }}</p>
              <p v-if="m.handoff.repos.length" class="hint">{{ t('codechat.repos') }}: {{ m.handoff.repos.join(', ') }}</p>
              <RouterLink
                class="btn btn-p btn-s"
                :to="{ name: 'assistantCode', query: { text: m.handoff.request, repos: m.handoff.repoIds.join(',') || undefined } }"
              >
                <HiIcon name="code" />{{ t('codechat.handoffOpen') }}
              </RouterLink>
            </div>
            <p v-for="(e, i) in m.actionErrors ?? []" :key="i" class="hint as-noact">{{ t('massistant.actionNotOffered', { reason: e }) }}</p>
            <div v-if="m.links.length" class="as-links">
              <RouterLink v-for="(l, i) in m.links" :key="i" class="as-link" :class="{ mono: l.kind === 'ticket' }" :to="linkTo(l)">{{ linkLabel(l) }}</RouterLink>
            </div>
            <div class="as-foot">
              <span v-if="m.durationMs" class="hint">{{ secs(m.durationMs) }}</span>
              <span class="sp" />
              <button type="button" class="as-thumb" :aria-pressed="m.rating === 1" :title="t('massistant.helpful')" :aria-label="t('massistant.helpful')" @click="thumb(m, 1)">👍</button>
              <button type="button" class="as-thumb" :aria-pressed="m.rating === -1" :title="t('massistant.notHelpful')" :aria-label="t('massistant.notHelpful')" @click="thumb(m, -1)">👎</button>
            </div>
            <form v-if="rating.id === m.id" class="as-rate" @submit.prevent="rate(m.id, rating.value, rating.comment, rating.share)">
              <b>{{ t('massistant.rateTitle') }} {{ rating.value === 1 ? '👍' : '👎' }}</b>
              <textarea v-model="rating.comment" :maxlength="MAX_QUESTION" rows="2" :placeholder="t('massistant.rateComment')" />
              <label class="as-check"><input v-model="rating.share" type="checkbox"> {{ t('massistant.rateShare') }}</label>
              <p class="hint">{{ t('massistant.rateNote') }}</p>
              <div class="as-rate-b">
                <button type="button" class="btn btn-s" @click="rating.id = 0">{{ t('form.cancel') }}</button>
                <button type="submit" class="btn btn-s btn-p" :disabled="rating.busy">{{ t('massistant.rateSend') }}</button>
              </div>
            </form>
          </template>
        </div>
      </template>
    </div>

    <div v-if="voice.state.value === 'recording' || hearing" class="as-compose as-voice" role="status">
      <template v-if="hearing">
        <span class="as-spin" />
        <span>{{ t('massistant.voiceHearing') }}</span>
      </template>
      <template v-else>
        <span class="as-rec" />
        <span>{{ t('massistant.voiceRecording') }} <b class="as-clock">{{ clock(voice.seconds.value) }}</b></span>
        <span class="hint">{{ t('massistant.voiceLimit', { n: MAX_VOICE_SECONDS / 60 }) }}</span>
        <span class="sp" />
        <button type="button" class="btn" @click="voice.cancel()">{{ t('form.cancel') }}</button>
        <button type="button" class="btn btn-p" @click="finishVoice">{{ t('massistant.voiceSend') }}</button>
      </template>
      <p v-if="error" class="ferr">{{ error }}</p>
    </div>
    <form v-else class="as-compose" @submit.prevent="send()">
      <textarea
        v-model="text"
        rows="2"
        :placeholder="t('massistant.placeholder')"
        :aria-label="t('massistant.placeholder')"
        @keydown="onKey"
      />
      <div class="as-send">
        <span class="hint">{{ length > MAX_QUESTION - 100 ? t('massistant.count', { n: length }) : t('massistant.sendHint') }}</span>
        <span class="as-btns">
          <button
            v-if="voiceOn"
            type="button"
            class="btn as-mic"
            :disabled="ask.isPending.value"
            :title="t('massistant.voiceStart')"
            :aria-label="t('massistant.voiceStart')"
            @click="startVoice"
          ><HiIcon name="mic" /></button>
          <button type="submit" class="btn btn-p" :disabled="!length || length > MAX_QUESTION || ask.isPending.value">{{ t('massistant.send') }}</button>
        </span>
      </div>
      <p v-if="error" class="ferr">{{ error }}</p>
    </form>
  </section>
</template>

<style scoped>

.as-chat { display: flex; flex-direction: column; padding: 0; }
.as-msgs { flex: 1; min-height: 0; overflow: auto; padding: 20px; display: flex; flex-direction: column; gap: 12px; }
.as-empty { margin: auto; max-width: 520px; text-align: center; display: flex; flex-direction: column; align-items: center; gap: 8px; }
.as-empty h2 { margin: 0; font-size: 18px; }
.as-big { width: 40px; height: 40px; color: var(--primary); }
.as-suggest { display: flex; flex-wrap: wrap; justify-content: center; gap: 8px; margin-top: 8px; }
.as-q { align-self: flex-end; max-width: 75%; padding: 10px 14px; border-radius: 16px; background: var(--primary-soft); color: var(--primary-ink); white-space: pre-wrap; overflow-wrap: anywhere; }
.as-a { align-self: flex-start; max-width: 85%; padding: 12px 16px 8px; border-radius: 16px; border: 1px solid var(--line); background: var(--surface); }
.as-a.failed b { color: var(--bad-ink); }
.as-err { margin: 4px 0 8px; color: var(--ink-2); }
.as-think { display: flex; align-items: center; gap: 10px; font-weight: 700; color: var(--ink-2); padding-bottom: 4px; }
.as-spin { width: 14px; height: 14px; border-radius: 50%; border: 2px solid var(--line-3); border-top-color: var(--primary); animation: as-spin 0.8s linear infinite; }
@keyframes as-spin { to { transform: rotate(360deg); } }
.as-partial { opacity: 0.6; }
.as-noact { margin: 8px 0 0; }
.as-handoff { display: flex; flex-direction: column; align-items: flex-start; gap: 6px; margin-top: 10px; padding: 12px 14px; border-radius: 14px; border: 1px solid var(--primary); }
.as-handoff p { margin: 0; white-space: pre-wrap; }
.as-links { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 10px; }
.as-link { padding: 3px 10px; border-radius: 999px; background: var(--primary-soft); color: var(--primary-ink); font-size: 13.5px; font-weight: 700; text-decoration: none; }
.as-link.mono { font-family: var(--mono); }
.as-foot { display: flex; align-items: center; gap: 4px; margin-top: 6px; }
.as-foot .sp { flex: 1; }
.as-thumb { border: 0; background: none; cursor: pointer; padding: 4px 6px; border-radius: 8px; filter: grayscale(1); opacity: 0.55; }
.as-thumb:hover { opacity: 1; }
.as-thumb[aria-pressed="true"] { filter: none; opacity: 1; background: var(--primary-soft); }
.as-rate { display: flex; flex-direction: column; gap: 8px; margin: 8px 0 6px; padding-top: 10px; border-top: 1px solid var(--line); }
.as-check { display: flex; gap: 8px; align-items: flex-start; font-size: 14px; }
.as-rate-b { display: flex; gap: 8px; justify-content: flex-end; }

.as-compose { border-top: 1px solid var(--line); padding: 12px 16px; display: flex; flex-direction: column; gap: 8px; }
.as-compose textarea { min-height: 48px; resize: none; }
.as-send { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
.as-btns { display: flex; gap: 8px; }
.as-mic { padding-inline: 10px; }
.as-mic svg { width: 18px; height: 18px; }
.as-voice { flex-direction: row; flex-wrap: wrap; align-items: center; gap: 10px; min-height: 106px; }
.as-voice .sp { flex: 1; }
.as-voice .ferr { flex-basis: 100%; }
.as-rec { width: 12px; height: 12px; border-radius: 50%; background: var(--bad-ink); animation: as-pulse 1.2s ease-in-out infinite; }
@keyframes as-pulse { 50% { opacity: 0.3; } }
.as-clock { font-variant-numeric: tabular-nums; }

</style>
