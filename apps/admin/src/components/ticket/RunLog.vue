<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { TicketEvent } from '../../api/types'
import { fmtDur, fmtTime } from '../../composables/format'
import EventTypeBadge from '../logs/EventTypeBadge.vue'

// The ticket's events grouped into consecutive steps, newest group open.
const props = defineProps<{ events: TicketEvent[]; ticketKey: string }>()
const { t, locale } = useI18n()

const groups = computed(() => {
  const out: { step: string; items: TicketEvent[] }[] = []
  for (const e of props.events) {
    const g = out[out.length - 1]
    if (g && g.step === e.step) g.items.push(e)
    else out.push({ step: e.step, items: [e] })
  }
  return out.map((g) => ({
    ...g,
    span: new Date(g.items[g.items.length - 1].createdAt).getTime() - new Date(g.items[0].createdAt).getTime(),
    errors: g.items.filter((e) => e.level === 'error').length,
  }))
})
</script>

<template>
  <section v-if="events.length" class="card">
    <div class="ch">
      <div><h2>{{ t('ticket.runLog') }}</h2><p class="sub">{{ t('ticket.runLogSub', { n: events.length }) }}</p></div>
      <RouterLink class="btn btn-s" :to="{ name: 'logs', query: { key: ticketKey } }">{{ t('ticket.openInLogs') }}</RouterLink>
    </div>
    <details v-for="(g, i) in groups" :key="i" class="rl" :open="i === groups.length - 1">
      <summary>
        <span>{{ g.step || t('ticket.stepOther') }}</span>
        <span class="hint">
          {{ t('ticket.groupEvents', { n: g.items.length }) }}<template v-if="g.span > 0">, {{ fmtDur(g.span) }}</template>
          <template v-if="g.errors">, <b style="color: var(--bad-ink)">{{ t('ticket.groupErrors', { n: g.errors }) }}</b></template>
        </span>
      </summary>
      <ol>
        <li v-for="e in g.items" :key="e.id">
          <span class="ts">{{ fmtTime(e.createdAt, locale) }}</span>
          <span><EventTypeBadge :event="e" /></span>
          <span :style="e.level === 'error' ? 'color: var(--bad-ink); font-weight: 700' : ''">
            {{ e.message }}<span v-if="e.durationMs" class="hint"> {{ fmtDur(e.durationMs) }}</span>
          </span>
        </li>
      </ol>
    </details>
  </section>
</template>
