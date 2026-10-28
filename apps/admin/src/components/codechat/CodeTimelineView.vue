<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { STATE_TONE, stateKey, type TicketEvent, type TicketState } from '../../api/types'
import ReportView from '../ticket/ReportView.vue'
import { routedLabel, toolLine, type Block } from './codechat'

// A Code conversation's timeline: the person's messages on the right with
// what each did, the agent's runs on the left (its text, and its tool
// calls folded into steps), and one-line notes of what the ticket did.
defineProps<{ blocks: Block[] }>()
const { t } = useI18n()

const toState = (e: TicketEvent) => String(e.data?.to ?? '') as TicketState
const url = (e: TicketEvent) => (typeof e.data?.url === 'string' && e.data.url.startsWith('https://') ? e.data.url : '')
const tone = (e: TicketEvent) => (e.level === 'error' ? 'bad' : e.level === 'warn' ? 'warn' : 'info')
</script>

<template>
  <template v-for="b in blocks" :key="b.id">
    <div v-if="b.kind === 'msg'" class="ct-q" :class="{ failed: b.message.routed === 'failed' }">
      <div class="ct-q-text">{{ b.message.text }}</div>
      <span v-if="b.message.routed" class="ct-routed" :class="b.message.routed">{{ routedLabel(t, b.message) }}</span>
    </div>

    <div v-else-if="b.kind === 'run'" class="ct-run">
      <template v-for="(p, i) in b.parts" :key="i">
        <ReportView v-if="p.kind === 'text'" class="ct-text" :markdown="p.event.message" />
        <details v-else class="ct-tools">
          <summary>{{ t('codechat.steps', { n: p.events.length }) }} · <span class="mono">{{ toolLine(p.events.at(-1)!) }}</span></summary>
          <ol>
            <li v-for="e in p.events" :key="e.id" class="mono">{{ toolLine(e) }}</li>
          </ol>
        </details>
      </template>
    </div>

    <div v-else class="ct-line" :class="tone(b.event)">
      <template v-if="b.event.type === 'state_changed' && toState(b.event)">
        <span class="mono">{{ b.event.ticketKey }}</span>
        <span class="badge" :class="`b-${STATE_TONE[toState(b.event)] ?? 'gray'}`">{{ t(stateKey(toState(b.event))) }}</span>
        <span v-if="b.event.level !== 'info' && b.event.message" class="ct-msg">{{ b.event.message }}</span>
      </template>
      <template v-else>
        <span class="ct-dot" />
        <span class="ct-msg">{{ b.event.message }}</span>
        <a v-if="url(b.event)" :href="url(b.event)" target="_blank" rel="noopener">{{ t('codechat.prOpened') }} ↗</a>
      </template>
    </div>
  </template>
</template>

<style scoped>
.ct-q { align-self: flex-end; max-width: 75%; display: flex; flex-direction: column; align-items: flex-end; gap: 4px; }
.ct-q-text { padding: 10px 14px; border-radius: 16px; background: var(--primary-soft); color: var(--primary-ink); white-space: pre-wrap; overflow-wrap: anywhere; }
.ct-routed { font-size: 12.5px; color: var(--ink-3); }
.ct-routed.queued { color: var(--warn-ink); }
.ct-routed.failed { color: var(--bad-ink); }
.ct-run { align-self: flex-start; max-width: 85%; display: flex; flex-direction: column; gap: 6px; padding: 10px 14px; border-radius: 16px; border: 1px solid var(--line); background: var(--surface); }
.ct-text :deep(p) { margin: 4px 0; }
.ct-tools { font-size: 13px; color: var(--ink-3); }
.ct-tools summary { cursor: pointer; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.ct-tools ol { margin: 6px 0 0; padding-left: 20px; max-height: 240px; overflow: auto; }
.ct-tools li { overflow-wrap: anywhere; }
.ct-line { align-self: center; display: flex; flex-wrap: wrap; align-items: center; justify-content: center; gap: 8px; font-size: 13px; color: var(--ink-3); max-width: 90%; }
.ct-line.bad .ct-msg { color: var(--bad-ink); }
.ct-line.warn .ct-msg { color: var(--warn-ink); }
.ct-dot { width: 6px; height: 6px; border-radius: 50%; background: var(--line-3); flex: none; }
.ct-line.bad .ct-dot { background: var(--bad); }
.ct-msg { overflow-wrap: anywhere; text-align: center; }
</style>
