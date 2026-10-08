<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, unwrap } from '../../api/client'
import type { StageSpend } from '../../api/types'
import { fmtTokens, fmtUsd, ioTokens } from '../../composables/format'
import { livePoll } from '../../composables/useLive'
import StateBadge from '../StateBadge.vue'

// The tickets that used most of the plan in a period, by Claude Code's cost
// estimate. Share is of the period's estimated cost.
type Days = 7 | 30 | 90
const PERIODS: Days[] = [7, 30, 90]
const { t, locale } = useI18n()
const router = useRouter()
const days = ref<Days>(30)

const q = useQuery({
  queryKey: computed(() => ['ticket-spend', days.value]),
  queryFn: () => unwrap(api.GET('/usage/tickets', { params: { query: { days: days.value, limit: 10 } } })),
  refetchInterval: () => livePoll(60_000),
})
const v = computed(() => q.data.value)

const STAGE_KEY: Record<StageSpend['stage'], string> = {
  analyze: 'spend.stageAnalyze',
  coding: 'spend.stageCoding',
  retry: 'spend.stageRetry',
  review: 'spend.stageReview',
  preview: 'spend.stagePreview',
  learn: 'spend.stageLearn',
  helper: 'spend.stageHelper',
}
const share = (cost: number) => (v.value && v.value.total.costUsd > 0 ? Math.round((100 * cost) / v.value.total.costUsd) : 0)
const tok = (n: number) => fmtTokens(n, locale.value)
const open = (key: string) => router.push({ name: 'ticket', params: { key: key } })
</script>

<template>
  <section class="card">
    <div class="ch">
      <div>
        <h2>{{ t('spend.topTitle') }}</h2>
        <p class="sub">
          {{ v && v.tickets.length ? t('spend.topSub', { tokens: tok(ioTokens(v.total)), cost: fmtUsd(v.total.costUsd, locale) }) : t('spend.topSubEmpty') }}
        </p>
      </div>
      <div class="seg" role="group" :aria-label="t('analytics.period')">
        <button v-for="p in PERIODS" :key="p" type="button" class="seg-b" :aria-pressed="days === p" @click="days = p">
          {{ t('analytics.days', { n: p }) }}
        </button>
      </div>
    </div>
    <p v-if="q.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="q.isError.value" class="ferr">{{ t('common.error') }}</p>
    <p v-else-if="!v?.tickets.length" class="empty">{{ t('spend.topEmpty') }}</p>
    <div v-else class="tw">
      <table class="tbl">
        <thead>
          <tr>
            <th>{{ t('tickets.colTicket') }}</th>
            <th>{{ t('spend.colStage') }}</th>
            <th class="num">{{ t('spend.colTokens') }}</th>
            <th class="num">{{ t('spend.colCost') }}</th>
            <th>{{ t('spend.colShare') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="x in v.tickets" :key="x.key" tabindex="0" @click="open(x.key)" @keydown.enter="open(x.key)">
            <td>
              <div class="tkey">{{ x.key }} <StateBadge :state="x.state" :kind="x.kind" /></div>
              <div class="ttitle">{{ x.title }}</div>
            </td>
            <td class="muted">{{ t(STAGE_KEY[x.topStage]) }}<br><span class="hint">{{ t('spend.calls', { n: x.calls }) }}</span></td>
            <td class="num" :title="t('spend.cache', { read: tok(x.spend.cacheRead), write: tok(x.spend.cacheWrite) })">{{ tok(ioTokens(x.spend)) }}</td>
            <td class="num">{{ fmtUsd(x.spend.costUsd, locale) }}</td>
            <td class="share">
              <div class="bar"><span :style="{ width: share(x.spend.costUsd) + '%' }" /></div>
              <span class="hint">{{ share(x.spend.costUsd) }}%</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <p v-if="v?.tickets.length" class="hint" style="margin: 10px 0 0">{{ t('spend.topNote') }}</p>
  </section>
</template>

<style scoped>
.share { min-width: 110px; }
.share .bar { margin-bottom: 4px; }
</style>
