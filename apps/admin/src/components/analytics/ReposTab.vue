<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { minutesText, pctOf, type Analytics } from './analytics'

// Repos: where agnts works best and where it struggles.
defineProps<{ a: Analytics }>()
const { t } = useI18n()
const fmtMin = (m: number) => minutesText(t, m)

function mdClass(s: string) {
  return s === 'found' ? 'repo-ok' : s === 'missing' ? 'repo-miss' : 'hint'
}
function mdLabel(s: string) {
  return s === 'found' ? t('analytics.mdFound') : s === 'missing' ? t('analytics.mdMissing') : t('analytics.mdUnknown')
}
</script>

<template>
  <section class="card">
    <div class="ch"><div><h2>{{ t('analytics.repos') }}</h2><p class="sub">{{ t('analytics.reposSub') }}</p></div></div>
    <p v-if="!a.repos.length" class="hint">{{ t('analytics.noRepos') }}</p>
    <div v-else class="tw">
      <table class="tbl">
        <thead>
          <tr>
            <th>{{ t('analytics.colRepo') }}</th>
            <th>{{ t('analytics.colSource') }}</th>
            <th>{{ t('analytics.colTickets') }}</th>
            <th>{{ t('analytics.colSuccess') }}</th>
            <th :title="t('analytics.colMergeRateHint')">{{ t('analytics.colMergeRate') }}</th>
            <th>{{ t('analytics.colTurns') }}</th>
            <th>{{ t('analytics.colAgnts') }}</th>
            <th :title="t('analytics.colQuestionsHint')">{{ t('analytics.colQuestions') }}</th>
            <th :title="t('analytics.colCiHint')">{{ t('analytics.colCi') }}</th>
            <th>{{ t('analytics.colClaudeMd') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in a.repos" :key="r.repoId">
            <td class="ttitle"><RouterLink :to="{ name: 'repo', params: { id: r.repoId } }">{{ r.name }}</RouterLink></td>
            <td>
              <span v-if="r.kind === 'side'" class="src local">{{ t('analytics.srcTask') }}</span>
              <span v-else class="src">{{ r.kind === 'plane' ? t('analytics.srcPlane') : t('analytics.srcJira') }}</span>
            </td>
            <td>{{ r.tickets }}</td>
            <td>
              <span v-if="r.finished" :class="pctOf(r.done, r.finished) >= 80 ? 'repo-ok' : 'repo-miss'">{{ pctOf(r.done, r.finished) }}%</span>
              <span v-else class="hint">—</span>
            </td>
            <td>
              <span v-if="r.merged + r.closed" :class="pctOf(r.merged, r.merged + r.closed) >= 70 ? 'repo-ok' : 'repo-miss'">
                {{ pctOf(r.merged, r.merged + r.closed) }}%
              </span>
              <span v-else class="hint">—</span>
            </td>
            <td>{{ Math.round(r.avgTurns) }}</td>
            <td>{{ fmtMin(r.agntsMin) }}</td>
            <td>{{ r.analyzed ? (r.asked / r.analyzed).toFixed(1) : '—' }}</td>
            <td>
              <RouterLink v-if="r.ciFailures" :to="{ name: 'ci' }">{{ r.ciFailures }}</RouterLink>
              <span v-else class="hint">0</span>
            </td>
            <td><span :class="mdClass(r.claudeMd)">{{ mdLabel(r.claudeMd) }}</span></td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>
