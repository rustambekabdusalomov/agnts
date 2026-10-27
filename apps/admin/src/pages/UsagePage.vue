<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../api/client'
import PageHeader from '../components/PageHeader.vue'
import HiIcon from '../components/ui/HiIcon.vue'
import TicketSpendCard from '../components/usage/TicketSpendCard.vue'
import { ago, level, pct } from '../composables/format'
import { useModels } from '../composables/useModels'
import { useUsage } from '../composables/useUsage'
import { useUi } from '../stores/ui'

const { t, locale } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const usage = useUsage()
// Muse runs are paid per call: Claude's plan windows and pausing do not apply.
const catalog = useModels()
const settings = useQuery({ queryKey: ['settings'], queryFn: () => unwrap(api.GET('/settings')) })

const u = computed(() => usage.data.value)
const windows = computed(() => [
  { key: 'session', w: u.value?.fiveHour },
  { key: 'week', w: u.value?.sevenDay },
])

function resetText(iso?: string): string {
  if (!iso) return t('usage.noReset')
  const d = new Date(iso).getTime() - Date.now()
  if (d <= 0) return t('usage.resettingNow')
  const h = Math.floor(d / 3_600_000)
  const m = Math.floor((d % 3_600_000) / 60_000)
  if (h >= 24) {
    const at = new Date(iso).toLocaleString(locale.value, { weekday: 'short', hour: '2-digit', minute: '2-digit' })
    return t('usage.resetsAt', { time: at })
  }
  return t('usage.resetsIn', { time: `${h ? h + 'h ' : ''}${m}m` })
}
const pausedUntil = computed(() =>
  u.value?.pausedUntil ? new Date(u.value.pausedUntil).toLocaleString(locale.value, { weekday: 'short', hour: '2-digit', minute: '2-digit' }) : '',
)

const refresh = useMutation({
  mutationFn: () => unwrap(api.POST('/usage/refresh')),
  onSuccess: (v) => {
    qc.setQueryData(['usage'], v)
    ui.notify(t('usage.refreshStarted'))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
</script>

<template>
  <PageHeader :title="t('usage.title')" doc="usage" />
  <!-- Muse has no help column: the cards take the full width. -->
  <div class="cfg-grid" :class="{ solo: catalog.isMuse.value }">
    <div class="col">
      <section v-if="!catalog.isMuse.value" class="card" :aria-label="t('usage.card')">
        <div class="ch">
          <div>
            <h2>{{ t('usage.card') }}</h2>
            <p class="sub">{{ u?.updatedAt ? t('usage.updated', { time: ago(u.updatedAt, locale) }) : t('usage.noReading') }}</p>
          </div>
          <button type="button" class="btn btn-s" :disabled="u?.refreshing || refresh.isPending.value" @click="refresh.mutate()">
            {{ u?.refreshing ? t('usage.refreshing') : t('usage.refresh') }}
          </button>
        </div>
        <p v-if="usage.isPending.value" class="hint">{{ t('common.loading') }}</p>
        <template v-else>
          <div v-for="x in windows" :key="x.key" class="lim">
            <div class="lim-h">
              <span>{{ t(`usage.${x.key}`) }}</span>
              <b :class="level(x.w?.utilization)">{{ x.w?.utilization == null ? t('usage.unknown') : pct(x.w.utilization) + '%' }}</b>
            </div>
            <div class="bar" :class="level(x.w?.utilization)"><span :style="{ width: pct(x.w?.utilization) + '%' }" /></div>
            <span class="hint">{{ resetText(x.w?.resetsAt) }}</span>
          </div>
          <div class="mini-kv">
            <span>{{ t('usage.status') }}</span><b>{{ t(`usage.status_${u?.status ?? 'unknown'}`) }}</b>
          </div>
          <div v-if="u?.paused" class="help bad" style="margin-top: 8px">
            <HiIcon name="info" />
            <p>{{ pausedUntil ? t('usage.paused', { time: pausedUntil }) : t('usage.pausedNoTime') }}</p>
          </div>
          <div v-else-if="(u?.fiveHour?.utilization ?? 0) >= 0.8" class="help warn" style="margin-top: 8px">
            <HiIcon name="info" /><p>{{ t('usage.warn80') }}</p>
          </div>
          <p class="hint" style="margin: 10px 0 0">{{ t('usage.source') }}</p>
        </template>
      </section>

      <TicketSpendCard />

      <section v-if="!catalog.isMuse.value" class="card">
        <div class="ch"><div><h2>{{ t('usage.limitTitle') }}</h2><p class="sub">{{ t('usage.limitSub') }}</p></div></div>
        <dl class="kv">
          <dt>{{ t('usage.above', { pct: u?.pauseAbove ?? settings.data.value?.pauseAbove ?? 90 }) }}</dt>
          <dd>{{ t('usage.aboveDo') }}</dd>
          <dt>{{ t('usage.midRun') }}</dt>
          <dd>{{ t('usage.midRunDo') }}</dd>
          <dt>{{ t('usage.afterReset') }}</dt>
          <dd>{{ settings.data.value?.autoResume === false ? t('usage.resumeManual') : t('usage.resumeAuto') }}</dd>
          <dt>{{ t('usage.idle') }}</dt>
          <dd>{{ t('usage.idleDo') }}</dd>
        </dl>
      </section>
    </div>
    <aside v-if="!catalog.isMuse.value" class="cfg-side">
      <div class="help"><HiIcon name="info" /><p>{{ t('usage.help') }}</p></div>
    </aside>
  </div>
</template>
