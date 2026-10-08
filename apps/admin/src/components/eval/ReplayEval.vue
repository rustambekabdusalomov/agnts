<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import { fmtUsd } from '../../composables/format'
import StateBadge from '../StateBadge.vue'

// Replays re-run done tickets with the current agnts, from the commit each
// started from; this compares them with the work people approved.
const { t, locale } = useI18n()
const q = useQuery({ queryKey: ['eval', 'replays'], queryFn: () => unwrap(api.GET('/eval/replays')), refetchInterval: 60_000 })
const pct = (v: number) => `${Math.round(v * 100)}%`
</script>

<template>
  <section class="card span3">
    <div class="ch"><div><h2>{{ t('replay.evalTitle') }}</h2><p class="sub">{{ t('replay.evalSub') }}</p></div></div>
    <p v-if="q.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="q.isError.value" class="hint">{{ t('common.error') }}</p>
    <p v-else-if="!q.data.value?.replays.length" class="hint">{{ t('replay.none') }}</p>
    <template v-else>
      <div v-if="q.data.value.versions.length" class="tw">
        <table class="tbl">
          <thead>
            <tr>
              <th>{{ t('analytics.colVersion') }}</th>
              <th>{{ t('replay.colReplays') }}</th>
              <th>{{ t('replay.colChecks') }}</th>
              <th>{{ t('replay.colLooksGood') }}</th>
              <th :title="t('replay.colOverlapHint')">{{ t('replay.colOverlap') }}</th>
              <th :title="t('replay.colRecallHint')">{{ t('replay.colRecall') }}</th>
              <th>{{ t('replay.colTurns') }}</th>
              <th>{{ t('replay.colCost') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="v in q.data.value.versions" :key="v.promptVersion">
              <td class="ttitle mono">{{ v.promptVersion || t('analytics.versionUnknown') }}</td>
              <td>{{ v.replays }}</td>
              <td>{{ pct(v.checksPassed / v.replays) }}</td>
              <td>{{ v.reviewed ? `${v.looksGood}/${v.reviewed}` : '—' }}</td>
              <td>{{ pct(v.avgOverlap) }}</td>
              <td>{{ pct(v.avgRecall) }}</td>
              <td>{{ Math.round(v.avgTurns) }} <span class="hint">({{ Math.round(v.originalTurns) }})</span></td>
              <td>{{ fmtUsd(v.avgCostUsd, locale) }} <span class="hint">({{ fmtUsd(v.originalCostUsd, locale) }})</span></td>
            </tr>
          </tbody>
        </table>
      </div>
      <h3 style="margin-top: 16px">{{ t('replay.recent') }}</h3>
      <div class="tw">
        <table class="tbl">
          <thead>
            <tr>
              <th>{{ t('replay.colReplay') }}</th>
              <th>{{ t('replay.colOf') }}</th>
              <th>{{ t('replay.colState') }}</th>
              <th>{{ t('replay.colChecks') }}</th>
              <th>{{ t('replay.colOverlap') }}</th>
              <th>{{ t('replay.colReview') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="x in q.data.value.replays.slice(0, 20)" :key="x.key">
              <td class="ttitle"><RouterLink :to="{ name: 'ticket', params: { key: x.key } }">{{ x.key }}</RouterLink></td>
              <td><RouterLink :to="{ name: 'ticket', params: { key: x.original } }">{{ x.original }}</RouterLink></td>
              <td><StateBadge :state="x.state" /></td>
              <td>
                <span v-if="!x.hasChange" class="hint">—</span>
                <span v-else :class="x.checksPassed ? 'repo-ok' : 'repo-miss'">{{ x.checksPassed ? t('replay.pass') : t('replay.fail') }}</span>
              </td>
              <td>{{ x.hasChange ? pct(x.overlap) : '—' }}</td>
              <td>{{ x.verdict ? t(`replay.verdict_${x.verdict}`) : '—' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>
  </section>
</template>
