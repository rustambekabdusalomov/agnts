<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import AiBadge, { AI_NAME } from './AiBadge.vue'
import ChatBody from './ChatBody.vue'
import ChatCardView from './ChatCardView.vue'
import RefChips from './RefChips.vue'
import type { ChatMessage } from './chat'
import { citationsOf } from './citations'

// One message: who, when, the text (or agnts's card), its links, the reply
// it answers, and on hover Reply and Turn into ticket.
const props = defineProps<{
  message: ChatMessage
  parent?: ChatMessage
  thinking?: boolean
  highlight?: boolean
  canTicket?: boolean
}>()
const emit = defineEmits<{ reply: [m: ChatMessage]; jump: [id: number]; ticket: [m: ChatMessage] }>()
const { t, locale } = useI18n()

const agent = computed(() => props.message.kind === 'agent_card' || props.message.kind === 'agent_text' || !props.message.authorId)
const time = computed(() => new Date(props.message.createdAt).toLocaleTimeString(locale.value, { hour: '2-digit', minute: '2-digit' }))
const sources = computed(() => (props.message.kind === 'agent_text' ? citationsOf(props.message.body).length : 0))
const snippet = (s: string) => (s.length > 120 ? `${s.slice(0, 120)}…` : s)
const initials = computed(() => (props.message.author || '?').slice(0, 2).toUpperCase())
</script>

<template>
  <div v-if="message.kind === 'system'" :id="`chat-msg-${message.id}`" class="cm-sys" :class="{ hl: highlight }">{{ message.body }} · {{ time }}</div>
  <div v-else :id="`chat-msg-${message.id}`" class="cm" :class="{ agent, hl: highlight }">
    <span class="cm-av" :class="{ agent }" aria-hidden="true">{{ agent ? '✨' : initials }}</span>
    <div class="cm-main">
      <button v-if="message.replyTo" type="button" class="cm-quote" @click="emit('jump', message.replyTo)">
        ↪ <template v-if="parent">{{ t('teamchat.replyingTo', { name: parent.author }) }}: <span>{{ snippet(parent.body || parent.card?.title || '') }}</span></template>
        <template v-else>{{ t('teamchat.replyingToMessage') }}</template>
      </button>
      <div class="cm-h">
        <b class="cm-who">{{ message.author }}</b>
        <time class="cm-time" :datetime="message.createdAt">{{ time }}</time>
        <AiBadge v-if="message.ai && message.kind !== 'agent_card'" :ai="message.ai" :extra="sources ? t('teamchat.sources', { n: sources }) : ''" />
      </div>
      <ChatCardView v-if="message.kind === 'agent_card' && message.card" :message="message" />
      <ChatBody v-else :body="message.body" :refs="message.refs" :cite="message.kind === 'agent_text'" @jump="emit('jump', $event)" />
      <RefChips :message="message" />
      <div v-if="thinking" class="cm-think" role="status"><span class="cm-spin" />{{ t('teamchat.thinking') }} <span class="cm-muse">✨ {{ AI_NAME }}</span></div>
    </div>
    <div class="cm-menu">
      <button type="button" class="cm-mb" :title="t('teamchat.reply')" :aria-label="t('teamchat.reply')" @click="emit('reply', message)">↩</button>
      <button v-if="canTicket && message.kind === 'text'" type="button" class="cm-mb" :title="t('teamchat.toTicket')" :aria-label="t('teamchat.toTicket')" @click="emit('ticket', message)">🎫</button>
    </div>
  </div>
</template>

<style scoped>
.cm { position: relative; display: flex; gap: 10px; padding: 6px 10px; border-radius: 10px; transition: background-color 0.3s; }
.cm:hover { background: var(--row-hover); }
.cm.hl, .cm-sys.hl { background: var(--primary-soft); }
.cm-av { flex: none; width: 32px; height: 32px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; font-weight: 700; font-size: 12.5px; color: #fff; background: var(--primary); }
.cm-av.agent { background: var(--mark); color: var(--mark-ink); }
.cm-main { min-width: 0; flex: 1; }
.cm-h { display: flex; align-items: baseline; gap: 8px; flex-wrap: wrap; }
.cm-who { font-size: 14.5px; }
.cm.agent .cm-who { color: var(--primary-ink); }
.cm-time { font-size: 12px; color: var(--ink-3); }
.cm-quote { display: block; max-width: 100%; margin: 0 0 2px; padding: 0 0 0 8px; border: 0; border-left: 2px solid var(--line-3); background: none; color: var(--ink-3); font-size: 12.5px; text-align: left; cursor: pointer; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.cm-quote:hover { color: var(--ink); }
.cm-think { display: flex; align-items: center; gap: 8px; margin-top: 6px; font-size: 13px; color: var(--ink-2); font-weight: 700; }
.cm-muse { color: var(--primary-ink); }
.cm-spin { width: 12px; height: 12px; border-radius: 50%; border: 2px solid var(--line-3); border-top-color: var(--primary); animation: cm-spin 0.8s linear infinite; }
@keyframes cm-spin { to { transform: rotate(360deg); } }
.cm-menu { position: absolute; top: -10px; right: 10px; display: none; gap: 2px; padding: 2px; border: 1px solid var(--line); border-radius: 8px; background: var(--surface); box-shadow: 0 4px 12px -6px var(--shadow); }
.cm:hover .cm-menu, .cm:focus-within .cm-menu { display: flex; }
.cm-mb { width: 30px; height: 28px; border: 0; border-radius: 6px; background: none; cursor: pointer; font-size: 14px; color: var(--ink-2); }
.cm-mb:hover { background: var(--hover); color: var(--ink); }
.cm-sys { align-self: center; margin: 4px auto; padding: 2px 10px; border-radius: 999px; font-size: 12.5px; color: var(--ink-3); text-align: center; }
</style>
