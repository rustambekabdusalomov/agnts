<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useUsage } from '../composables/useUsage'
import { level, pct } from '../composables/format'
import { usePrefs } from '../stores/prefs'

const { t } = useI18n()
const prefs = usePrefs()
const usage = useUsage()
const five = computed(() => usage.data.value?.fiveHour)
const week = computed(() => usage.data.value?.sevenDay)
const resetText = useResetText()

function useResetText() {
  return (iso?: string) => {
    if (!iso) return t('nav.usageUnknown')
    const d = new Date(iso).getTime() - Date.now()
    if (d <= 0) return t('nav.resettingNow')
    const h = Math.floor(d / 3_600_000)
    const m = Math.floor((d % 3_600_000) / 60_000)
    return t('nav.resetsIn', { time: `${h ? h + 'h ' : ''}${m}m` })
  }
}
</script>

<template>
  <RouterLink
    :to="{ name: 'usage' }"
    class="side-usage"
    :aria-label="`${t('nav.session')} ${pct(five?.utilization)}%`"
    :data-tip="prefs.thin ? `${t('nav.session')} ${pct(five?.utilization)}% · ${resetText(five?.resetsAt)} · ${t('nav.week')} ${pct(week?.utilization)}%` : undefined"
  >
    <span class="su-h">
      <span>{{ t('nav.session') }}</span><b :class="level(five?.utilization)">{{ five?.utilization == null ? '—' : pct(five.utilization) + '%' }}</b>
    </span>
    <span class="bar" :class="level(five?.utilization)"><span :style="{ width: pct(five?.utilization) + '%' }" /></span>
    <b class="su-mini" :class="level(five?.utilization)">{{ five?.utilization == null ? '—' : pct(five.utilization) + '%' }}</b>
    <span class="su-f">
      <span>{{ resetText(five?.resetsAt) }}</span><span>{{ t('nav.week') }} {{ pct(week?.utilization) }}%</span>
    </span>
  </RouterLink>
</template>
