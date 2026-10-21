<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import type { components } from '../../api/schema.gen'
import { fmtUsd } from '../../composables/format'

// Replays summed by the prompt version and coding model they ran with.
defineProps<{ versions: components['schemas']['ReplayVersion'][] }>()
const { t, locale } = useI18n()
const pct = (v: number) => `${Math.round(v * 100)}%`
const opt = (v?: number) => (v == null ? '—' : pct(v))
</script>

<template>
  <div class="tw">
    <table class="tbl">
      <thead>
        <tr>
          <th>{{ t('analytics.colVersion') }}</th>
          <th>{{ t('replay.colModel') }}</th>
          <th>{{ t('replay.colReplays') }}</th>
          <th>{{ t('replay.colChecks') }}</th>
          <th>{{ t('replay.colLooksGood') }}</th>
          <th :title="t('replay.colOverlapHint')">{{ t('replay.colOverlap') }}</th>
          <th :title="t('replay.colRecallHint')">{{ t('replay.colRecall') }}</th>
          <th :title="t('replay.colLinesHint')">{{ t('replay.colLines') }}</th>
          <th>{{ t('replay.colTurns') }}</th>
          <th>{{ t('replay.colCost') }}</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="v in versions" :key="`${v.promptVersion}/${v.model}`">
          <td class="ttitle mono">{{ v.promptVersion || t('analytics.versionUnknown') }}</td>
          <td class="mono">{{ v.model || '—' }}</td>
          <td>{{ v.replays }}</td>
          <td>{{ pct(v.checksPassed / v.replays) }}</td>
          <td>{{ v.reviewed ? `${v.looksGood}/${v.reviewed}` : '—' }}</td>
          <td>{{ pct(v.avgOverlap) }}</td>
          <td>{{ pct(v.avgRecall) }}</td>
          <td>{{ opt(v.avgLineRecall) }} <span class="hint">({{ opt(v.originalLineRecall) }})</span></td>
          <td>{{ Math.round(v.avgTurns) }} <span class="hint">({{ Math.round(v.originalTurns) }})</span></td>
          <td>{{ fmtUsd(v.avgCostUsd, locale) }} <span class="hint">({{ fmtUsd(v.originalCostUsd, locale) }})</span></td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
