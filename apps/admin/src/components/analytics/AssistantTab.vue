<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import type { AssistantAction } from '../../api/types'
import { actionStatus, secs } from '../assistant/assistant'
import ReportView from '../ticket/ReportView.vue'
import { pctOf, type Days } from './analytics'

// Assistant: how the workspace's questions went (for its owner), what
// became of the actions answers proposed, per prompt version, and the
// answers people rated with their questions, comments and actions.
const props = defineProps<{ days: Days }>()
const { t, locale } = useI18n()

const stats = useQuery({
  queryKey: computed(() => ['assistant', 'stats', props.days]),
  queryFn: () => unwrap(api.GET('/assistant/stats', { params: { query: { days: props.days } } })),
})
const filter = ref<'' | 'up' | 'down'>('')
const rated = useQuery({
  queryKey: computed(() => ['assistant', 'rated', filter.value]),
  queryFn: () => unwrap(api.GET('/assistant/rated', { params: { query: { rating: filter.value || undefined } } })),
})
const s = computed(() => stats.data.value)
const statusLabel = (a: AssistantAction) => ({
  proposed: t('massistant.statsActionsOffered'), running: t('massistant.actionRunning'), done: t('massistant.actionDone'),
  failed: t('massistant.actionFailed'), cancelled: t('massistant.actionCancelled'), expired: t('massistant.actionExpired'),
})[actionStatus(a)]
const when = (iso: string) => new Date(iso).toLocaleString(locale.value, { dateStyle: 'medium', timeStyle: 'short' })
</script>

<template>
  <p v-if="stats.isPending.value" class="hint">{{ t('analytics.loading') }}</p>
  <div v-else-if="stats.isError.value" class="help bad"><p>{{ t('analytics.error') }}</p></div>
  <section v-else-if="s && !s.questions" class="card">
    <div class="ch"><div><h2>{{ t('massistant.statsTitle') }}</h2></div></div>
    <p class="hint">{{ t('massistant.statsNone') }}</p>
  </section>
  <template v-else-if="s">
    <div class="g6">
      <div class="card stat">
        <div class="lbl">{{ t('massistant.statsQuestions') }}</div>
        <div class="val">{{ s.questions }}</div>
        <div class="note">{{ t('massistant.statsPeople', { n: s.people }) }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('massistant.statsAnswered') }}</div>
        <div class="val">{{ pctOf(s.answered, s.questions) }}%</div>
        <div class="note">{{ s.answered }} / {{ s.questions }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('massistant.statsMedian') }}</div>
        <div class="val">{{ secs(s.medianMs) }}</div>
        <div class="note">p90 {{ secs(s.p90Ms) }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('massistant.statsHelpful') }}</div>
        <div class="val">{{ s.up + s.down ? `${pctOf(s.up, s.up + s.down)}%` : '—' }}</div>
        <div class="note">{{ s.up }} 👍 · {{ s.down }} 👎</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('massistant.statsTokens') }}</div>
        <div class="val">{{ s.tokens.toLocaleString(locale) }}</div>
        <div class="note">${{ s.costUsd.toFixed(2) }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('massistant.statsActions') }}</div>
        <div class="val">{{ s.actions.proposed ? `${pctOf(s.actions.done, s.actions.proposed)}%` : '—' }}</div>
        <div class="note">{{ s.actions.done }} / {{ s.actions.proposed }}</div>
      </div>
    </div>

    <section class="card">
      <div class="ch">
        <div>
          <h2>{{ t('massistant.statsMedian') }}</h2>
          <p class="sub">{{ t('massistant.statsParts', { start: secs(s.medianStartMs), snapshot: secs(s.medianSnapshotMs), claude: secs(s.medianClaudeMs) }) }}</p>
          <p class="sub">{{ t('massistant.statsWarm', { n: s.warm, total: s.answered }) }}</p>
          <p v-if="s.actions.proposed || s.actions.notOffered" class="sub">{{ t('massistant.statsActionsLine', { ...s.actions }) }}</p>
        </div>
      </div>
      <div v-if="s.versions.length" class="tw">
        <table class="tbl">
          <thead>
            <tr>
              <th>{{ t('massistant.statsVersions') }}</th>
              <th class="num">{{ t('massistant.statsAnswered') }}</th>
              <th class="num">{{ t('massistant.failed') }}</th>
              <th class="num">👍</th>
              <th class="num">👎</th>
              <th class="num">{{ t('massistant.statsMedian') }}</th>
              <th class="num">{{ t('massistant.statsTokens') }}</th>
              <th class="num">{{ t('massistant.statsActionsOffered') }}</th>
              <th class="num">{{ t('massistant.actionDone') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="v in s.versions" :key="v.promptVersion">
              <td class="mono">{{ v.promptVersion || '—' }}</td>
              <td class="num">{{ v.answered }}</td>
              <td class="num">{{ v.failed }}</td>
              <td class="num">{{ v.up }}</td>
              <td class="num">{{ v.down }}</td>
              <td class="num">{{ secs(v.medianMs) }}</td>
              <td class="num">{{ v.tokens.toLocaleString(locale) }}</td>
              <td class="num">{{ v.proposed }}</td>
              <td class="num">{{ v.done }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </template>

  <section class="card">
    <div class="ch">
      <div><h2>{{ t('massistant.statsRated') }}</h2><p class="sub">{{ t('massistant.rateNote') }}</p></div>
      <div class="seg" role="group" :aria-label="t('massistant.statsRated')">
        <button v-for="f in ['', 'up', 'down'] as const" :key="f" type="button" class="seg-b" :aria-pressed="filter === f" @click="filter = f">
          {{ f === '' ? t('tickets.all') : f === 'up' ? `👍 ${t('massistant.helpful')}` : `👎 ${t('massistant.notHelpful')}` }}
        </button>
      </div>
    </div>
    <p v-if="rated.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="!rated.data.value?.length" class="hint">{{ t('massistant.ratedEmpty') }}</p>
    <div v-else class="as-rated">
      <article v-for="r in rated.data.value" :key="r.messageId" class="as-r">
        <div class="as-r-h">
          <span>{{ r.rating === 1 ? '👍' : '👎' }}</span>
          <b>{{ r.user }}</b>
          <span class="hint">{{ when(r.ratedAt) }}</span>
          <span v-if="r.shared" class="src">{{ t('massistant.ratedShared') }}</span>
          <span class="sp" />
          <span class="hint mono">{{ r.promptVersion }}</span>
        </div>
        <p class="as-r-q">{{ r.question }}</p>
        <ReportView :markdown="r.answer" />
        <div v-for="a in r.actions ?? []" :key="a.id" class="as-r-a" :class="actionStatus(a)">
          <span>{{ a.summary }}</span>
          <span class="as-r-s"><b>{{ statusLabel(a) }}</b><template v-if="a.result"> · {{ a.result }}</template></span>
        </div>
        <p v-if="r.comment" class="as-r-c">“{{ r.comment }}”</p>
      </article>
    </div>
  </section>
</template>

<style scoped>
.mono { font-family: var(--mono); font-size: 13px; }
.as-rated { display: flex; flex-direction: column; gap: 12px; }
.as-r { border: 1px solid var(--line); border-radius: 12px; padding: 12px 16px; }
.as-r-h { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.as-r-h .sp { flex: 1; }
.as-r-q { margin: 8px 0; font-weight: 700; }
.as-r-a { display: flex; flex-direction: column; gap: 2px; margin-top: 8px; padding: 8px 10px; border: 1px solid var(--line); border-radius: 10px; font-size: 13.5px; }
.as-r-s { color: var(--ink-2); }
.as-r-a.done b { color: var(--ok-ink); }
.as-r-a.failed b { color: var(--bad-ink); }
.as-r-c { margin: 8px 0 0; font-style: italic; color: var(--ink-2); }
</style>
