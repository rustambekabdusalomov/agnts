<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Repository } from '../../api/types'
import { ago, fmtDur } from '../../composables/format'
import { useScrollPages } from '../../composables/useScrollPages'
import { useUi } from '../../stores/ui'
import HiIcon from '../ui/HiIcon.vue'
import CiDot from './CiDot.vue'
import ScrollMore from './ScrollMore.vue'
import type { Pipeline } from './types'
import { askConfirm } from '../../composables/useConfirm'

const props = defineProps<{ repo: Repository }>()
const { t, locale } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const id = computed(() => props.repo.id)
const open = ref<number | null>(null)

const envs = useQuery({
  queryKey: computed(() => ['repo', id.value, 'environments']),
  queryFn: () => unwrap(api.GET('/repos/{id}/environments', { params: { path: { id: id.value } } })),
  refetchInterval: 30_000,
})
// 20 runs a page, the next loading as the bottom scrolls into view.
const { query: pipelines, all, more, sentinel } = useScrollPages<Pipeline>({
  key: computed(() => ['repo', id.value, 'pipeline-pages']),
  fetch: (page) => unwrap(api.GET('/repos/{id}/pipelines', { params: { path: { id: id.value }, query: { page } } })),
  perPage: 20,
  id: (p) => p.id,
  refetchInterval: 30_000,
})

const deploy = useMutation({
  mutationFn: (body: { jobId?: number; ref?: string }) =>
    unwrap(api.POST('/repos/{id}/deploy', { params: { path: { id: id.value } }, body })),
  onSuccess: () => {
    ui.notify(t('repo.deployStarted'))
    setTimeout(() => void qc.invalidateQueries({ queryKey: ['repo', id.value] }), 4000)
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
async function deployJob(p: Pipeline, jobId: number, stage: string) {
  const message = t('repo.deployConfirm', { stage, sha: p.sha.slice(0, 7) })
  if (await askConfirm({ title: t('repo.deploy'), message, confirmLabel: t('repo.deploy'), danger: true })) deploy.mutate({ jobId })
}
async function deployWorkflow() {
  const message = t('repo.deployWorkflowConfirm', { workflow: props.repo.deployWorkflow ?? '', branch: props.repo.defaultBranch })
  if (await askConfirm({ title: t('repo.deploy'), message, confirmLabel: t('repo.deploy'), danger: true })) {
    deploy.mutate({ ref: props.repo.defaultBranch })
  }
}
const canWorkflow = computed(() => props.repo.provider === 'github' && !!props.repo.deployWorkflow)
const errMsg = (e: unknown) => (e instanceof Error && e.message ? e.message : t('common.error'))
</script>

<template>
  <div class="env-grid">
    <p v-if="envs.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <div v-else-if="envs.isError.value" class="help bad"><HiIcon name="info" /><p>{{ errMsg(envs.error.value) }}</p></div>
    <template v-else>
      <section v-for="e in envs.data.value ?? []" :key="e.name" class="card env">
        <div class="ch">
          <div>
            <h2>{{ e.name }}</h2>
            <p class="sub">{{ e.deployedAt ? t('repo.deployedAgo', { time: ago(e.deployedAt, locale) }) : t('repo.notDeployed') }}</p>
          </div>
          <span class="badge" :class="e.deployedAt ? 'b-ok' : 'b-gray'">{{ e.deployedAt ? t('repo.deployed') : t('repo.empty') }}</span>
        </div>
        <div class="mini-kv"><span>{{ t('repo.commit') }}</span><b style="font-family: var(--mono)">{{ e.sha ? e.sha.slice(0, 7) : '—' }}</b></div>
        <a v-if="e.url" :href="e.url" target="_blank" rel="noopener" class="hint">{{ t('repo.open') }}</a>
      </section>
      <p v-if="!(envs.data.value ?? []).length" class="hint">{{ t('repo.noEnvironments') }}</p>
    </template>
    <div class="help">
      <HiIcon name="info" />
      <p>{{ t('repo.deployHelp') }}</p>
      <button v-if="canWorkflow" type="button" class="btn btn-s" :disabled="deploy.isPending.value" @click="deployWorkflow">
        {{ t('repo.deployBranch', { branch: repo.defaultBranch }) }}
      </button>
    </div>
  </div>

  <section class="card">
    <div class="ch"><div><h2>{{ t('repo.pipelines') }}</h2><p class="sub">{{ t('repo.pipelinesSub') }}</p></div></div>
    <p v-if="pipelines.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <div v-else-if="pipelines.isError.value" class="help bad"><HiIcon name="info" /><p>{{ errMsg(pipelines.error.value) }}</p></div>
    <p v-else-if="!all.length" class="empty">{{ t('repo.none') }}</p>
    <div v-for="p in all" :key="p.id" class="pp" :class="{ open: open === p.id }">
      <button type="button" class="pp-h" :aria-expanded="open === p.id" @click="open = open === p.id ? null : p.id">
        <CiDot :status="p.status" />
        <span class="pp-id">#{{ p.id }}</span>
        <span class="pp-m">
          <span>{{ p.message || p.name || '—' }}</span>
          <span class="pp-sub">
            <span class="br">{{ p.branch }}</span><span class="sha">{{ p.sha.slice(0, 7) }}</span><span>{{ p.trigger }}</span>
          </span>
        </span>
        <span class="pp-r">
          <span>{{ t(`repo.ci_${p.status}`) }}</span>
          <span v-if="p.durationMs" class="hint">{{ fmtDur(p.durationMs) }}</span>
          <span v-if="p.created" class="hint">{{ ago(p.created, locale) }}</span>
        </span>
      </button>
      <div v-if="p.stages.length" class="stg">
        <template v-for="(s, i) in p.stages" :key="s.id">
          <span v-if="i" class="stg-ln" />
          <span class="stg-i" :class="`stg-${s.status}`" :title="`${s.name}: ${t(`repo.ci_${s.status}`)}`">
            <span class="stg-n">{{ s.name }}</span>
            <button v-if="s.manual" type="button" class="btn btn-s stg-go" :disabled="deploy.isPending.value" @click="deployJob(p, s.id, s.name)">
              {{ t('repo.deploy') }}
            </button>
          </span>
        </template>
      </div>
      <div v-if="open === p.id" class="pp-d">
        <table class="tbl">
          <thead>
            <tr><th>{{ t('repo.stage') }}</th><th>{{ t('repo.status') }}</th><th>{{ t('repo.duration') }}</th></tr>
          </thead>
          <tbody>
            <tr v-for="s in p.stages" :key="s.id">
              <td>{{ s.name }}</td>
              <td><CiDot :status="s.status" label /></td>
              <td class="muted">{{ s.durationMs ? fmtDur(s.durationMs) : '—' }}</td>
            </tr>
          </tbody>
        </table>
        <a v-if="p.url" :href="p.url" target="_blank" rel="noopener" class="btn btn-s" style="margin-top: 8px">{{ t('repo.openRun') }}</a>
      </div>
    </div>
    <ScrollMore
      v-if="all.length"
      :ref="sentinel"
      :loading="pipelines.isFetchingNextPage.value"
      :failed="pipelines.isFetchNextPageError.value"
      :has-more="pipelines.hasNextPage.value"
      :end="t('repo.pipelinesEnd', { n: all.length })"
      @more="more"
    />
  </section>
</template>
