<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { TicketEvent } from '../../api/types'
import { pct } from '../../composables/format'
import { meterTone, museBudget } from './museBudget'

// The current Muse run's spend against its budget, live from its budget
// events: one line and a thin bar. Nothing while the run has none.
const props = defineProps<{ events: TicketEvent[] }>()
const { t, locale } = useI18n()
const b = computed(() => museBudget(props.events))
const tone = computed(() => (b.value ? meterTone(b.value) : 'ok'))
// Muse calls cost fractions of a cent: three decimals under a dollar.
const usd = (n: number) =>
  new Intl.NumberFormat(locale.value, { style: 'currency', currency: 'USD', minimumFractionDigits: 2, maximumFractionDigits: n < 1 ? 3 : 2 }).format(n)
</script>

<template>
  <div v-if="b" class="muse-meter" :aria-label="t('ticket.museMeter')">
    <div class="mm-line">
      <b :class="`mm-${tone}`">{{ b.limitUsd > 0 ? t('ticket.museSpentOf', { spent: usd(b.totalUsd), limit: usd(b.limitUsd) }) : usd(b.totalUsd) }}</b>
      <span class="muted"> · {{ t('ticket.museCalls', { n: b.calls }) }}<template v-if="b.model"> · <span class="mono">{{ b.model }}</span></template></span>
      <span v-if="b.chargedUsd !== undefined" class="badge b-gray">{{ t('ticket.museCharged', { amount: usd(b.chargedUsd) }) }}</span>
      <span v-if="b.stopped" class="badge b-bad" :title="b.stopped">{{ t('ticket.museStopped') }}</span>
      <span v-else-if="b.steered" class="badge b-warn">{{ t('ticket.museSteered') }}</span>
      <span v-if="b.escalatedTo" class="badge b-info">{{ t('ticket.museEscalated', { model: b.escalatedTo }) }}</span>
    </div>
    <div v-if="b.limitUsd > 0" class="bar mm-bar" :class="tone === 'ok' ? 'ok' : tone">
      <span :style="{ width: pct(b.totalUsd / b.limitUsd) + '%' }" />
    </div>
  </div>
</template>

<style scoped>
.muse-meter { display: flex; flex-direction: column; gap: 6px; font-size: 14px; }
.mm-line { display: flex; flex-wrap: wrap; align-items: center; gap: 4px 8px; }
.mm-line .muted { margin-left: -4px; }
.mm-ok { color: var(--ok-ink); }
.mm-warn { color: var(--warn-ink); }
.mm-bad { color: var(--bad-ink); }
.mm-bar { height: 4px; }
.mm-bar.ok > span { background: var(--ok); }
</style>
