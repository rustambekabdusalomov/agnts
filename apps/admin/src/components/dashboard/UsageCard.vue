<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Usage } from '../../api/types'
import { ago, level, pct } from '../../composables/format'

// Plan usage windows with reset times; shared by dashboard and ticket page.
const props = defineProps<{ usage?: Usage; titleKey?: string }>()
const { t, locale } = useI18n()

function resetText(iso?: string) {
  if (!iso) return t('nav.usageUnknown')
  const d = new Date(iso).getTime() - Date.now()
  if (d <= 0) return t('nav.resettingNow')
  const h = Math.floor(d / 3_600_000)
  const m = Math.floor((d % 3_600_000) / 60_000)
  return t('nav.resetsIn', { time: `${h ? h + 'h ' : ''}${m}m` })
}

const rows = computed(() => [
  { key: 'session', w: props.usage?.fiveHour },
  { key: 'week', w: props.usage?.sevenDay },
])
</script>

<template>
  <section class="card">
    <div class="ch">
      <div>
        <h2>{{ t(titleKey ?? 'dashboard.usageTitle') }}</h2>
        <p class="sub">
          {{ usage?.updatedAt ? t('dashboard.updated', { time: ago(usage.updatedAt, locale) }) : t('dashboard.notUpdated') }}
        </p>
      </div>
      <slot name="action" />
    </div>
    <div v-for="r in rows" :key="r.key" class="lim">
      <div class="lim-h">
        <span>{{ t(`dashboard.${r.key}`) }}</span><b :class="level(r.w?.utilization)">{{ r.w?.utilization == null ? '—' : pct(r.w.utilization) + '%' }}</b>
      </div>
      <div class="bar" :class="level(r.w?.utilization)"><span :style="{ width: pct(r.w?.utilization) + '%' }" /></div>
      <span class="hint">{{ resetText(r.w?.resetsAt) }}</span>
    </div>
    <div v-if="usage?.paused" class="help warn" style="margin-top: 8px"><p>{{ t('dashboard.paused') }}</p></div>
    <slot />
  </section>
</template>
