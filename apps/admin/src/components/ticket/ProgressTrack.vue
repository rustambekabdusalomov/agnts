<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { isReport, type StageSpend, type Ticket, type TicketState } from '../../api/types'
import { fmtTokens, ioTokens } from '../../composables/format'
import HiIcon from '../ui/HiIcon.vue'

// The six stops from the demo; diamonds are where agnts waits for you.
const props = defineProps<{ ticket: Ticket; spend?: StageSpend[] }>()
const { t, locale } = useI18n()

// Which spend stages each stop's tokens come from; stops without Claude
// work (answers, tests, push) show none.
const SPEND_OF: Record<string, StageSpend['stage'][]> = {
  stopAnalyze: ['analyze'],
  stopCoding: ['coding', 'retry'],
  stopWriting: ['coding', 'retry'],
  stopReview: ['review'],
}
const stopTokens = (key: string) =>
  (props.spend ?? []).filter((s) => SPEND_OF[key]?.includes(s.stage)).reduce((n, s) => n + ioTokens(s.spend), 0)

const CHANGE_STOPS = [
  { key: 'stopAnalyze', gate: false },
  { key: 'stopAnswers', gate: true },
  { key: 'stopCoding', gate: false },
  { key: 'stopTests', gate: false },
  { key: 'stopReview', gate: true },
  { key: 'stopPushed', gate: false },
]
const CHANGE_STOP_OF: Partial<Record<TicketState, number>> = {
  new: -1,
  analyzing: 0,
  waiting_for_answers: 1,
  coding: 2,
  testing: 3,
  waiting_for_review: 4,
  pushing: 5,
  done: 6,
  rejected: -2,
}
// A report has no tests and nothing to push.
const REPORT_STOPS = [
  { key: 'stopAnalyze', gate: false },
  { key: 'stopAnswers', gate: true },
  { key: 'stopWriting', gate: false },
  { key: 'stopReview', gate: true },
  { key: 'stopDone', gate: false },
]
const REPORT_STOP_OF: Partial<Record<TicketState, number>> = {
  new: -1,
  analyzing: 0,
  waiting_for_answers: 1,
  coding: 2,
  waiting_for_review: 3,
  pushing: 4,
  done: 5,
  rejected: -2,
}

const report = computed(() => isReport(props.ticket))
const STOPS = computed(() => (report.value ? REPORT_STOPS : CHANGE_STOPS))

const classes = computed(() => {
  const st = props.ticket.state
  const stopOf = report.value ? REPORT_STOP_OF : CHANGE_STOP_OF
  const last = STOPS.value.length
  let idx = stopOf[st]
  let err = false
  if (idx === undefined) {
    idx = stopOf[props.ticket.resumeState ?? 'new'] ?? 0
    if (idx < 0) idx = 0
    err = true
  }
  return STOPS.value.map((_, i) => {
    if (idx === -2) return i === 0 ? 'done' : ''
    if (i < idx || idx === last) return 'done'
    if (i === idx) return err ? 'error' : 'active'
    return ''
  })
})
</script>

<template>
  <div class="track" :aria-label="t('ticket.progress')">
    <ol>
      <li v-for="(s, i) in STOPS" :key="s.key" class="stop" :class="[s.gate ? 'gate' : '', classes[i]]">
        <span class="mark"><HiIcon v-if="classes[i] === 'done'" name="check" /></span>
        <span class="lbl">{{ t(`ticket.${s.key}`) }}</span>
        <span v-if="stopTokens(s.key)" class="tok">{{ t('spend.tokens', { n: fmtTokens(stopTokens(s.key), locale) }) }}</span>
      </li>
    </ol>
  </div>
</template>

<style scoped>
.stop .tok { margin-top: -6px; font-size: 12px; color: var(--ink-3); font-variant-numeric: tabular-nums; white-space: nowrap; }
</style>
