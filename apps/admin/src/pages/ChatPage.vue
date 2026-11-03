<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, unwrap } from '../api/client'
import { AI_NAME } from '../components/chat/AiBadge.vue'
import ChannelList from '../components/chat/ChannelList.vue'
import ChatComposer from '../components/chat/ChatComposer.vue'
import ChatMessageItem from '../components/chat/ChatMessageItem.vue'
import { dayOf, secs, type ChatChannel, type ChatMessage } from '../components/chat/chat'
import {
  chat, channelState, discard, flush, loadChannel, loadOlder, markRead, retrySend, send, sendVoice, STATS_KEY, toTicket, useChatChannels,
} from '../components/chat/useChat'
import { livePoll, useLive } from '../composables/useLive'
import { useSession } from '../stores/session'
import { useUi } from '../stores/ui'
import { useWorkspace } from '../stores/workspace'

// The team chat: channels on the left; the open channel's messages, agnts's
// cards and answers, and the message box on the right. Sending shows the
// message at once and never loses or doubles it (see components/chat/useChat.ts).
const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const ui = useUi()
const session = useSession()
const workspace = useWorkspace()
const { connected, reconnecting } = useLive()

const channels = useChatChannels()
const list = computed(() => channels.data.value ?? [])
const channelId = computed(() => Number(route.params.channelId) || 0)
const channel = computed<ChatChannel | undefined>(() => list.value.find((c) => c.id === channelId.value))

// No channel in the address: open #general (or the first one).
watch(
  [list, channelId],
  ([l, id]) => {
    if (!l.length) return
    if (!id || !l.some((c) => c.id === id)) {
      if (route.query.msg) return // the cited message's channel is looked up below
      const first = l.find((c) => c.name === 'general') ?? l[0]
      void router.replace({ name: 'chat', params: { channelId: first.id }, query: route.query })
    }
  },
  { immediate: true },
)

// Opened from a citation (?msg=<id>): go to that message's channel.
watch(
  () => Number(route.query.msg) || 0,
  async (want) => {
    if (!want) return
    try {
      const m = await unwrap(api.GET('/chat/messages/{messageId}', { params: { path: { messageId: want } } }))
      if (m.channelId !== channelId.value) void router.replace({ name: 'chat', params: { channelId: m.channelId }, query: route.query })
    } catch {
      ui.notify(t('teamchat.notLoaded'))
      void router.replace({ query: {} })
    }
  },
  { immediate: true },
)

const stats = useQuery({
  queryKey: STATS_KEY,
  queryFn: () => unwrap(api.GET('/chat/stats')),
  refetchInterval: () => livePoll(60_000),
})
const statsLine = computed(() => {
  const s = stats.data.value
  if (!s) return ''
  return `✨ ${AI_NAME} · ${t('teamchat.statsLine', { links: s.links, answers: s.answers, drafts: s.drafts })}`
})
const statsTip = computed(() => (stats.data.value?.medianMs ? t('teamchat.statsMedian', { secs: secs(stats.data.value.medianMs) }) : undefined))

// ---- the open channel ----

const state = computed(() => (channelId.value ? chat.channels[channelId.value] : undefined))
const messages = computed<ChatMessage[]>(() => state.value?.messages ?? [])
const byId = computed(() => new Map(messages.value.map((m) => [m.id, m])))
const pending = computed(() => chat.outbox.filter((o) => o.channelId === channelId.value))
const me = computed(() => session.user?.username ?? '')

type Row = { kind: 'day'; key: string; label: string } | { kind: 'msg'; key: string; m: ChatMessage }
function dayLabel(day: string): string {
  const today = dayOf(new Date().toISOString())
  const yesterday = dayOf(new Date(Date.now() - 86_400_000).toISOString())
  if (day === today) return t('teamchat.today')
  if (day === yesterday) return t('teamchat.yesterday')
  const [y, m, d] = day.split('-').map(Number)
  return new Date(y, m - 1, d).toLocaleDateString(locale.value, { weekday: 'long', day: 'numeric', month: 'long', year: y === new Date().getFullYear() ? undefined : 'numeric' })
}
const rows = computed<Row[]>(() => {
  const out: Row[] = []
  let last = ''
  for (const m of messages.value) {
    const day = dayOf(m.createdAt)
    if (day !== last) {
      out.push({ kind: 'day', key: `d-${day}`, label: dayLabel(day) })
      last = day
    }
    out.push({ kind: 'msg', key: `m-${m.id}`, m })
  }
  return out
})

// ---- scrolling: stick to the bottom, older pages at the top ----

const scroller = ref<HTMLElement | null>(null)
let stickNext = false
function nearBottom(): boolean {
  const el = scroller.value
  return !el || el.scrollHeight - el.scrollTop - el.clientHeight < 80
}
function toBottom() {
  const el = scroller.value
  if (el) el.scrollTop = el.scrollHeight
}
/** Marks the channel read when its newest message is on screen. */
function seen() {
  chat.atBottom = nearBottom()
  if (chat.atBottom && channelId.value && document.visibilityState === 'visible') void markRead(channelId.value)
}

// The message being replied to; the channel watcher below clears it, and
// runs at once, so it is declared first.
const replyTo = ref<ChatMessage | undefined>()

watch(
  channelId,
  async (id) => {
    chat.openChannel = id
    replyTo.value = undefined
    if (!id) return
    channelState(id)
    await loadChannel(id)
    await nextTick()
    toBottom()
    seen()
    void flush() // what an earlier visit left unsent
    // Opened from a citation elsewhere (the assistant): show that message.
    const want = Number(route.query.msg)
    if (want) {
      // Older than the first page: load back until it is here (or 10 pages).
      for (let i = 0; i < 10 && !byId.value.has(want) && state.value?.hasOlder; i++) await loadOlder(id)
      await nextTick()
      if (byId.value.has(want)) jump(want)
      void router.replace({ query: {} })
    }
  },
  { immediate: true },
)

// New messages (or our own, or agnts thinking): follow them when at the bottom.
const thinkingHere = computed(() => Object.values(chat.thinking).filter((x) => x.channelId === channelId.value).length)
watch(
  () => [messages.value.at(-1)?.id, pending.value.length, thinkingHere.value],
  () => {
    const stick = nearBottom() || stickNext
    stickNext = false
    void nextTick(() => {
      if (stick) toBottom()
      seen()
    })
  },
  { flush: 'pre' },
)

async function onScroll() {
  const el = scroller.value
  const st = state.value
  if (el && st && el.scrollTop < 80 && st.hasOlder && !st.loadingOlder) {
    const h = el.scrollHeight
    await loadOlder(channelId.value)
    await nextTick()
    el.scrollTop += el.scrollHeight - h
  }
  seen()
}

function onVisible() {
  if (document.visibilityState === 'visible') seen()
}
onMounted(() => document.addEventListener('visibilitychange', onVisible))
onBeforeUnmount(() => {
  document.removeEventListener('visibilitychange', onVisible)
  chat.openChannel = 0
  chat.atBottom = false
})

// ---- jumping to a message (a reply's quote, a citation) ----

const highlight = ref(0)
let hlTimer: ReturnType<typeof setTimeout> | undefined
function jump(id: number) {
  if (!byId.value.has(id)) {
    ui.notify(t('teamchat.notLoaded'))
    return
  }
  document.getElementById(`chat-msg-${id}`)?.scrollIntoView({ block: 'center', behavior: 'smooth' })
  highlight.value = id
  clearTimeout(hlTimer)
  hlTimer = setTimeout(() => (highlight.value = 0), 2200)
}

// ---- sending, replies, tickets ----

async function onVoice(clip: { recording: Blob; wav: Blob; durationMs: number }) {
  const to = replyTo.value?.id
  replyTo.value = undefined
  stickNext = true
  try {
    await sendVoice(channelId.value, clip, to)
  } catch (e) {
    ui.notify(e instanceof Error ? e.message : t('common.error'))
  }
}

function onSend(body: string) {
  if (!channelId.value) return
  stickNext = true
  send(channelId.value, body, replyTo.value?.id)
  replyTo.value = undefined
}

async function ticket(m: ChatMessage) {
  try {
    await toTicket(m.id)
    ui.notify(t('teamchat.drafting', { name: AI_NAME }))
  } catch (e) {
    ui.notify(e instanceof Error ? e.message : t('common.error'))
  }
}

// ---- connection ----

const conn = computed<'offline' | 'reconnecting' | ''>(() => (!chat.online ? 'offline' : reconnecting.value && !connected.value ? 'reconnecting' : ''))
const waiting = computed(() => chat.outbox.filter((o) => o.status === 'pending').length)
</script>

<template>
  <!-- No page title: the chat takes the whole page; the channel's header names it. -->
  <section class="card tc" :aria-label="t('nav.chat')">
    <ChannelList :channels="list" :current="channelId" @created="(c) => router.push({ name: 'chat', params: { channelId: c.id } })" />

    <div class="tc-main">
      <header class="tc-h">
        <div class="tc-ht">
          <h2>#{{ channel?.name ?? '…' }}</h2>
          <span v-if="channel?.agents" class="badge b-info">{{ t('teamchat.agentsHere') }}</span>
          <span v-if="conn" class="badge" :class="conn === 'offline' ? 'b-bad' : 'b-warn'" role="status">
            {{ conn === 'offline' ? t('teamchat.offline') : t('teamchat.reconnecting') }}<template v-if="waiting"> · {{ t('teamchat.waiting', { n: waiting }) }}</template>
          </span>
          <span class="sp" />
          <span v-if="statsLine" class="tc-stats" :title="statsTip">{{ statsLine }}</span>
        </div>
        <p v-if="channel?.topic" class="hint tc-topic">{{ channel.topic }}</p>
      </header>

      <div ref="scroller" class="tc-msgs" aria-live="polite" @scroll.passive="onScroll">
        <p v-if="channels.isError.value" class="ferr">{{ t('common.error') }}</p>
        <p v-if="state?.loadingOlder" class="hint tc-c">{{ t('common.loading') }}</p>
        <p v-else-if="state?.loaded && !state.hasOlder && messages.length" class="hint tc-c">{{ t('teamchat.start', { channel: channel?.name ?? '' }) }}</p>
        <p v-if="state?.loading && !messages.length" class="hint tc-c">{{ t('common.loading') }}</p>
        <p v-else-if="state?.error && !messages.length" class="ferr tc-c">{{ state.error }}</p>
        <div v-else-if="state?.loaded && !messages.length && !pending.length" class="tc-empty">
          <h3>{{ t('teamchat.emptyTitle', { channel: channel?.name ?? '' }) }}</h3>
          <p class="hint">{{ t('teamchat.emptyText') }}</p>
        </div>

        <template v-for="r in rows" :key="r.key">
          <div v-if="r.kind === 'day'" class="tc-day"><span>{{ r.label }}</span></div>
          <ChatMessageItem
            v-else
            :message="r.m"
            :parent="r.m.replyTo ? byId.get(r.m.replyTo) : undefined"
            :thinking="!!chat.thinking[r.m.id]"
            :highlight="highlight === r.m.id"
            :can-ticket="workspace.canEdit"
            @reply="replyTo = $event"
            @jump="jump"
            @ticket="ticket"
          />
        </template>

        <div v-for="o in pending" :key="o.clientMsgId" class="tc-pend" :class="o.status">
          <span class="tc-av" aria-hidden="true">{{ me.slice(0, 2).toUpperCase() }}</span>
          <div class="tc-pm">
            <div class="tc-ph">
              <b>{{ me }}</b>
              <span v-if="o.status === 'pending'" class="hint">{{ conn ? t('teamchat.waitingNet') : t('teamchat.sending') }}</span>
              <span v-else class="ferr">{{ t('teamchat.failed') }}<template v-if="o.error">: {{ o.error }}</template></span>
            </div>
            <p v-if="o.replyTo" class="hint tc-pq">↪ {{ byId.get(o.replyTo)?.author ?? '' }}</p>
            <p class="tc-pb">{{ o.body }}</p>
            <div v-if="o.status === 'failed'" class="tc-pa">
              <button type="button" class="btn btn-s" @click="retrySend(o.clientMsgId)">{{ t('teamchat.retry') }}</button>
              <button type="button" class="btn btn-s btn-d" @click="discard(o.clientMsgId)">{{ t('teamchat.delete') }}</button>
            </div>
          </div>
        </div>
      </div>

      <ChatComposer :channel-name="channel?.name ?? ''" :reply-to="replyTo" @send="onSend" @voice="onVoice" @cancel-reply="replyTo = undefined" />
    </div>
  </section>
</template>

<style scoped>
.tc { display: grid; grid-template-columns: 240px minmax(0, 1fr); grid-template-rows: minmax(0, 1fr); padding: 0; overflow: hidden; }
.tc-main { display: flex; flex-direction: column; min-width: 0; min-height: 0; }
.tc-h { padding: 12px 18px; border-bottom: 1px solid var(--line); }
.tc-ht { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.tc-ht h2 { margin: 0; font-size: 17px; }
.tc-ht .sp { flex: 1; }
.tc-stats { font-size: 13px; font-weight: 700; color: var(--primary-ink); }
.tc-topic { margin: 2px 0 0; }
.tc-msgs { flex: 1; min-height: 0; overflow-y: auto; padding: 14px 10px; display: flex; flex-direction: column; gap: 4px; }
.tc-c { text-align: center; margin: 4px 0; }
.tc-empty { margin: auto; text-align: center; max-width: 440px; }
.tc-empty h3 { margin: 0 0 4px; }
.tc-day { display: flex; align-items: center; gap: 10px; margin: 10px 0 4px; font-size: 12.5px; font-weight: 700; color: var(--ink-3); }
.tc-day::before, .tc-day::after { content: ''; flex: 1; height: 1px; background: var(--line); }
.tc-pend { display: flex; gap: 10px; padding: 6px 10px; border-radius: 10px; opacity: 0.65; }
.tc-pend.failed { opacity: 1; background: var(--bad-soft); }
.tc-av { flex: none; width: 32px; height: 32px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; font-weight: 700; font-size: 12.5px; color: #fff; background: var(--primary); }
.tc-pm { min-width: 0; flex: 1; }
.tc-ph { display: flex; gap: 8px; align-items: baseline; flex-wrap: wrap; }
.tc-pq { margin: 0; }
.tc-pb { margin: 0; white-space: pre-wrap; overflow-wrap: anywhere; }
.tc-pa { display: flex; gap: 8px; margin-top: 6px; }

@media (max-width: 900px) {
  .tc { grid-template-columns: 1fr; grid-template-rows: auto minmax(0, 1fr); }
}
</style>
