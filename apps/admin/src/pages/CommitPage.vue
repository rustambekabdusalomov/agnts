<script setup lang="ts">
import { useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, unwrap } from '../api/client'
import DiffView from '../components/DiffView.vue'
import PageHeader from '../components/PageHeader.vue'
import { hostName } from '../components/pulls/usePull'
import CiDot from '../components/repo/CiDot.vue'
import PipelineRow from '../components/repo/PipelineRow.vue'
import type { CommitDetail } from '../components/repo/types'
import CopyButton from '../components/ui/CopyButton.vue'
import HiIcon from '../components/ui/HiIcon.vue'
import { ago } from '../composables/format'
import { useLive } from '../composables/useLive'

// One commit as the git host has it: who wrote it, its full message, the
// CI runs on it, the pull requests that carry it and the files it changed.
const { t, locale } = useI18n()
const route = useRoute()
const qc = useQueryClient()
const repoId = computed(() => Number(route.params.id))
const sha = computed(() => String(route.params.sha))
const key = computed(() => ['repo', repoId.value, 'commit', sha.value])
const open = ref<number | null>(null)

const RUNNING = ['run', 'pending']
const commit = useQuery({
  queryKey: key,
  queryFn: () => unwrap(api.GET('/repos/{id}/commits/{sha}', { params: { path: { id: repoId.value, sha: sha.value } } })),
  // Poll while a run is going; webhooks (below) cover the rest.
  refetchInterval: (q) => ((q.state.data as CommitDetail | undefined)?.pipelines.some((p) => RUNNING.includes(p.status)) ? 15_000 : false),
})
const repo = useQuery({
  queryKey: computed(() => ['repos', repoId.value]),
  queryFn: () => unwrap(api.GET('/repos/{id}', { params: { path: { id: repoId.value } } })),
})

let timer: ReturnType<typeof setTimeout> | undefined
useLive((e) => {
  if (e.type !== 'pipeline' && e.type !== 'pr_merged') return
  clearTimeout(timer)
  timer = setTimeout(() => void qc.invalidateQueries({ queryKey: key.value }), 1500)
})

const c = computed(() => commit.data.value)
const title = computed(() => c.value?.message.split('\n')[0] ?? '')
const body = computed(() => c.value?.message.split('\n').slice(1).join('\n').trim() ?? '')
const ci = computed(() => {
  const ps = c.value?.pipelines ?? []
  if (!ps.length) return 'none'
  for (const s of ['fail', 'run', 'pending', 'manual'] as const) if (ps.some((p) => p.status === s)) return s
  return ps.every((p) => p.status === 'skip' || p.status === 'canceled') ? ps[0].status : 'ok'
})
const sameCommitter = computed(() => !c.value?.committer || (c.value.committer === c.value.author && c.value.committerEmail === c.value.authorEmail))
// Large commits open collapsed; a handful of files open at once.
const openFiles = computed(() => (c.value?.files.length ?? 0) <= 5)
const PULL_TONE: Record<string, string> = { open: 'b-info', merged: 'b-ok', closed: 'b-gray' }
const errMsg = (e: unknown) => (e instanceof Error && e.message ? e.message : t('common.error'))
const when = (iso?: string) => (iso ? new Date(iso).toLocaleString(locale.value, { dateStyle: 'medium', timeStyle: 'short' }) : '—')
</script>

<template>
  <RouterLink class="back-btn" :to="{ name: 'repo', params: { id: repoId }, query: { tab: 'commits' } }">
    <HiIcon name="back" />{{ repo.data.value ? t('commit.backTo', { repo: repo.data.value.name }) : t('commit.back') }}
  </RouterLink>
  <p v-if="commit.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <div v-else-if="commit.isError.value" class="help bad"><HiIcon name="info" /><p>{{ errMsg(commit.error.value) }}</p></div>
  <template v-else-if="c">
    <PageHeader :title="title || c.sha.slice(0, 7)">
      <template #below>
        <p class="cd-meta">
          <CiDot :status="ci" label />
          <span class="mono">{{ c.sha.slice(0, 12) }}</span>
          <CopyButton :text="c.sha" />
          <span>{{ t('commit.authoredAgo', { name: c.author, time: c.date ? ago(c.date, locale) : '—' }) }}</span>
          <span class="n"><span class="a">+{{ c.add }}</span> <span class="d">−{{ c.del }}</span></span>
          <span>{{ t('commit.filesN', { n: c.files.length }) }}</span>
        </p>
      </template>
      <div class="actions" style="margin: 0">
        <RouterLink v-if="c.ticketKey" class="btn" :to="{ name: 'ticket', params: { key: c.ticketKey } }">{{ c.ticketKey }}</RouterLink>
        <a v-if="c.url" class="btn" :href="c.url" target="_blank" rel="noopener">{{ t('reviews.openOn', { host: hostName(c.provider) }) }}</a>
      </div>
    </PageHeader>

    <div class="cd-grid">
      <section class="card">
        <div class="ch"><div><h2>{{ t('commit.author') }}</h2></div></div>
        <div class="cd-person">
          <img v-if="c.authorAvatar" class="cd-av" :src="c.authorAvatar" alt="" loading="lazy">
          <span v-else class="cd-av cd-av-x" aria-hidden="true">{{ c.author.slice(0, 1).toUpperCase() }}</span>
          <div class="cd-who">
            <b>{{ c.author }}</b>
            <span v-if="c.authorLogin" class="hint">@{{ c.authorLogin }}</span>
            <span v-if="c.authorEmail" class="hint mono">{{ c.authorEmail }}</span>
          </div>
        </div>
        <div class="mini-kv"><span>{{ t('commit.authored') }}</span><b>{{ when(c.date) }}</b></div>
        <template v-if="!sameCommitter">
          <div class="mini-kv"><span>{{ t('commit.committer') }}</span><b>{{ c.committer }}</b></div>
        </template>
        <div v-if="c.committedDate && c.committedDate !== c.date" class="mini-kv"><span>{{ t('commit.committed') }}</span><b>{{ when(c.committedDate) }}</b></div>
        <div class="mini-kv">
          <span>{{ t('commit.parents', { n: c.parents.length }) }}</span>
          <span class="cd-parents">
            <RouterLink v-for="p in c.parents" :key="p" class="mono" :to="{ name: 'commit', params: { id: repoId, sha: p } }">{{ p.slice(0, 7) }}</RouterLink>
            <span v-if="!c.parents.length">—</span>
          </span>
        </div>
      </section>

      <section class="card">
        <div class="ch"><div><h2>{{ t('commit.pulls') }}</h2><p class="sub">{{ t('commit.pullsSub') }}</p></div></div>
        <p v-if="!c.pulls.length" class="empty">{{ t('commit.noPulls') }}</p>
        <ul v-else class="cd-pulls">
          <li v-for="p in c.pulls" :key="p.number">
            <span class="badge" :class="PULL_TONE[p.state]">{{ t(`pulls.state_${p.state}`) }}</span>
            <RouterLink :to="{ name: 'pull', params: { id: repoId, number: p.number } }">#{{ p.number }} {{ p.title }}</RouterLink>
          </li>
        </ul>
      </section>
    </div>

    <section v-if="body" class="card">
      <div class="ch"><div><h2>{{ t('commit.message') }}</h2></div></div>
      <pre class="cd-body">{{ body }}</pre>
    </section>

    <section class="card">
      <div class="ch"><div><h2>{{ t('repo.pipelines') }}</h2><p class="sub">{{ t('commit.pipelinesSub') }}</p></div></div>
      <p v-if="!c.pipelines.length" class="empty">{{ t('commit.noPipelines') }}</p>
      <PipelineRow
        v-for="p in c.pipelines"
        :key="p.id"
        :pipeline="p"
        :open="open === p.id"
        @toggle="open = open === p.id ? null : p.id"
      />
    </section>

    <section class="card">
      <div class="ch"><div><h2>{{ t('commit.changes') }}</h2><p class="sub">{{ t('commit.changesSub', { n: c.files.length, add: c.add, del: c.del }) }}</p></div></div>
      <div v-if="c.filesCapped" class="help warn"><HiIcon name="info" /><p>{{ t('commit.filesCapped', { n: c.files.length }) }}</p></div>
      <p v-if="!c.files.length" class="empty">{{ t('commit.noFiles') }}</p>
      <DiffView v-for="f in c.files" :key="f.path" :file="f" :open="openFiles" />
    </section>
  </template>
</template>

<style scoped>
.cd-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 6px 12px; margin: 6px 0 0; font-size: 13.5px; color: var(--ink-3); }
.cd-meta .mono, .mono { font-family: var(--mono); }
.cd-meta .a { color: var(--ok-ink); }
.cd-meta .d { color: var(--bad-ink); }
.cd-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 16px; }
.cd-person { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
.cd-av { width: 44px; height: 44px; border-radius: 50%; flex: none; object-fit: cover; }
.cd-av-x { display: grid; place-items: center; background: var(--gray-soft); color: var(--gray-ink); font-weight: 700; }
.cd-who { display: flex; flex-direction: column; gap: 2px; min-width: 0; overflow-wrap: anywhere; }
.cd-parents { display: flex; flex-wrap: wrap; gap: 8px; }
.cd-pulls { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 8px; }
.cd-pulls li { display: flex; align-items: center; gap: 8px; min-width: 0; }
.cd-pulls a { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.cd-body { margin: 0; white-space: pre-wrap; overflow-wrap: anywhere; font-family: var(--mono); font-size: 13.5px; }
</style>
