<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { ago, level, pct } from '../../composables/format'
import { livePoll } from '../../composables/useLive'
import { useUi } from '../../stores/ui'
import HiIcon from '../ui/HiIcon.vue'

/** One module's plan usage: the windows its account reports (Claude's rate
 * limit events, Muse's allowance), read for the viewer's account. */
const props = defineProps<{ provider: 'claude' | 'muse' }>()

const { t, locale } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const name = computed(() => t(`modules.name_${props.provider}`))
const agent = computed(() => (props.provider === 'muse' ? 'Muse' : 'Claude'))
const usage = useQuery({
  queryKey: computed(() => ['usage', props.provider]),
  queryFn: () => unwrap(api.GET('/usage', { params: { query: { provider: props.provider } } })),
  refetchInterval: () => livePoll(60_000),
})
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

// Only Claude has a refresh run; Muse reports its allowance after every run.
const refresh = useMutation({
  mutationFn: () => unwrap(api.POST('/usage/refresh')),
  onSuccess: (v) => {
    qc.setQueryData(['usage', 'claude'], v)
    ui.notify(t('usage.refreshStarted'))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
</script>

<template>
  <section class="card" :aria-label="t('usage.cardFor', { name })">
    <div class="ch">
      <div>
        <h2>{{ t('usage.cardFor', { name }) }}</h2>
        <p class="sub">
          <template v-if="u?.account">{{ u.account }} · </template>
          {{ u?.updatedAt ? t('usage.updated', { time: ago(u.updatedAt, locale) }) : t('usage.noReading') }}
        </p>
      </div>
      <button
        v-if="provider === 'claude' && u?.connected !== false" type="button" class="btn btn-s"
        :disabled="u?.refreshing || refresh.isPending.value" @click="refresh.mutate()"
      >
        {{ u?.refreshing ? t('usage.refreshing') : t('usage.refresh') }}
      </button>
    </div>
    <p v-if="usage.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <div v-else-if="u?.connected === false" class="help">
      <HiIcon name="info" /><p>{{ t('usage.notConnected', { name }) }}</p>
    </div>
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
      <p class="hint" style="margin: 10px 0 0">{{ provider === 'muse' ? t('usage.museSource') : t('usage.source', { agent }) }}</p>
    </template>
  </section>
</template>
