<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { isReport, type Ticket, type TicketState } from '../../api/types'
import HiIcon from '../ui/HiIcon.vue'

// The six stops from the demo; diamonds are where hiro waits for you.
const props = defineProps<{ ticket: Ticket }>()
const { t } = useI18n()

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
      </li>
    </ol>
  </div>
</template>
