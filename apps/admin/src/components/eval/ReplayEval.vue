<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { fmtUsd } from '../../composables/format'
import { askConfirm } from '../../composables/useConfirm'
import { useModels } from '../../composables/useModels'
import { useUi } from '../../stores/ui'
import StateBadge from '../StateBadge.vue'
import ReplayVersions from './ReplayVersions.vue'

// Replays re-run done tickets with the current agnts, from the commit each
// started from; this compares them with what their pull requests merged as
// (or, when that was not recorded, with agnts's original change). The
// benchmark is the fixed set of merged tickets every change is judged on.
const { t, locale } = useI18n()
const ui = useUi()
const qc = useQueryClient()
const q = useQuery({ queryKey: ['eval', 'replays'], queryFn: () => unwrap(api.GET('/eval/replays')), refetchInterval: 60_000 })
const bench = useQuery({ queryKey: ['eval', 'benchmark'], queryFn: () => unwrap(api.GET('/eval/benchmark')) })
const pct = (v: number) => `${Math.round(v * 100)}%`
const opt = (v?: number) => (v == null ? '—' : pct(v))

const model = ref('')
const catalog = useModels()
const models = computed(() => ['', ...catalog.models.value.map((m) => m.id)])
const run = useMutation({
  mutationFn: () => unwrap(api.POST('/eval/benchmark', { body: model.value ? { models: { coding: model.value } } : {} })),
  onSuccess: (runs) => {
    const bad = runs.filter((r) => r.error)
    ui.notify(bad.length
      ? t('replay.benchmarkFailed', { n: bad.length, why: bad.map((r) => `${r.original}: ${r.error}`).join('; ') })
      : t('replay.benchmarkStarted', { n: runs.length }))
    void qc.invalidateQueries({ queryKey: ['eval'] })
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

async function start() {
  const n = bench.data.value?.length ?? 0
  if (await askConfirm({ title: t('replay.benchmarkRun'), message: t('replay.benchmarkConfirm', { n }), confirmLabel: t('replay.benchmarkRun') })) {
    run.mutate()
  }
}
</script>

<template>
  <section class="card span3">
    <div class="ch">
      <div><h2>{{ t('replay.benchmarkTitle') }}</h2><p class="sub">{{ t('replay.benchmarkSub') }}</p></div>
    </div>
    <p v-if="bench.data.value && !bench.data.value.length" class="hint">{{ t('replay.benchmarkEmpty') }}</p>
    <div v-else-if="bench.data.value" class="actions" style="flex-wrap: wrap; align-items: center">
      <span class="hint">{{ t('replay.benchmarkCount', { n: bench.data.value.length }) }}:</span>
      <RouterLink v-for="b in bench.data.value" :key="b.key" :to="{ name: 'ticket', params: { key: b.key } }" class="mono">{{ b.key }}</RouterLink>
    </div>
    <div v-if="bench.data.value?.length" class="actions" style="margin-top: 12px; align-items: center">
      <label class="hint" for="bench-model">{{ t('replay.benchmarkModel') }}</label>
      <select id="bench-model" v-model="model" class="cfg-in">
        <option v-for="m in models" :key="m" :value="m">{{ m ? catalog.label(m) : t('replay.benchmarkModelDefault') }}</option>
      </select>
      <button class="btn primary" type="button" :disabled="run.isPending.value" @click="start">{{ t('replay.benchmarkRun') }}</button>
    </div>
    <ReplayVersions v-if="q.data.value?.benchmark?.length" :versions="q.data.value.benchmark" style="margin-top: 16px" />
  </section>

  <section class="card span3">
    <div class="ch"><div><h2>{{ t('replay.evalTitle') }}</h2><p class="sub">{{ t('replay.evalSub') }}</p></div></div>
    <p v-if="q.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="q.isError.value" class="hint">{{ t('common.error') }}</p>
    <p v-else-if="!q.data.value?.replays.length" class="hint">{{ t('replay.none') }}</p>
    <template v-else>
      <ReplayVersions v-if="q.data.value.versions.length" :versions="q.data.value.versions" />
      <h3 style="margin-top: 16px">{{ t('replay.recent') }}</h3>
      <div class="tw">
        <table class="tbl">
          <thead>
            <tr>
              <th>{{ t('replay.colReplay') }}</th>
              <th>{{ t('replay.colOf') }}</th>
              <th>{{ t('replay.colState') }}</th>
              <th>{{ t('replay.colModel') }}</th>
              <th>{{ t('replay.colChecks') }}</th>
              <th>{{ t('replay.colOverlap') }}</th>
              <th :title="t('replay.colLinesHint')">{{ t('replay.colLines') }}</th>
              <th>{{ t('replay.colReview') }}</th>
              <th>{{ t('replay.colCost') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="x in q.data.value.replays.slice(0, 20)" :key="x.key">
              <td class="ttitle"><RouterLink :to="{ name: 'ticket', params: { key: x.key } }">{{ x.key }}</RouterLink></td>
              <td><RouterLink :to="{ name: 'ticket', params: { key: x.original } }">{{ x.original }}</RouterLink></td>
              <td><StateBadge :state="x.state" /></td>
              <td class="mono">{{ x.model || '—' }}</td>
              <td>
                <span v-if="!x.hasChange" class="hint">—</span>
                <span v-else :class="x.checksPassed ? 'repo-ok' : 'repo-miss'">{{ x.checksPassed ? t('replay.pass') : t('replay.fail') }}</span>
              </td>
              <td>
                {{ x.hasChange ? pct(x.overlap) : '—' }}
                <span v-if="x.against" class="hint">{{ t(`replay.against_${x.against}`) }}</span>
              </td>
              <td>{{ opt(x.lineRecall) }} <span class="hint">({{ opt(x.originalLineRecall) }})</span></td>
              <td>{{ x.verdict ? t(`replay.verdict_${x.verdict}`) : '—' }}</td>
              <td>{{ fmtUsd(x.costUsd, locale) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>
  </section>
</template>
