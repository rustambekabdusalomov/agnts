<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, unwrap } from '../../api/client'
import type { components } from '../../api/schema.gen'
import { fmtBytes } from '../../composables/format'
import { highlightCode } from '../highlight'
import ReportView from '../ticket/ReportView.vue'
import SegButtons from '../form/SegButtons.vue'
import HiIcon from '../ui/HiIcon.vue'

type TreeEntry = components['schemas']['TreeEntry']

// The repository's files on a branch, read from the git host. The branch,
// the folder (path) and the open file (file) live in the address, so a
// view can be shared and the back button walks back through it.
const props = defineProps<{ repoId: number; defaultBranch: string }>()
const { t } = useI18n()
const route = useRoute()
const router = useRouter()

const q = (k: string) => (typeof route.query[k] === 'string' ? (route.query[k] as string) : '')
const branch = computed(() => q('ref') || props.defaultBranch)
const file = computed(() => q('file'))
// The folder shown: the open file's folder, or the path.
const dir = computed(() => (file.value ? file.value.split('/').slice(0, -1).join('/') : q('path')))

function go(next: { ref?: string; path?: string; file?: string }) {
  const query: Record<string, string | undefined> = { ...route.query, ref: undefined, path: undefined, file: undefined } as Record<string, string | undefined>
  const r = next.ref ?? q('ref')
  if (r && r !== props.defaultBranch) query.ref = r
  if (next.file) query.file = next.file
  else if (next.path) query.path = next.path
  void router.push({ query })
}
// Another branch may not have this folder: start again at its root.
const setBranch = (v: string) => go({ ref: v })

const branches = useQuery({
  queryKey: computed(() => ['repo', props.repoId, 'branches']),
  queryFn: () => unwrap(api.GET('/repos/{id}/branches', { params: { path: { id: props.repoId } } })),
})
const branchNames = computed(() => {
  const names = (branches.data.value ?? []).map((b) => b.name)
  if (!names.includes(props.defaultBranch)) names.unshift(props.defaultBranch)
  if (!names.includes(branch.value)) names.push(branch.value)
  return names
})

const tree = useQuery({
  queryKey: computed(() => ['repo', props.repoId, 'tree', branch.value, dir.value]),
  queryFn: () => unwrap(api.GET('/repos/{id}/tree', { params: { path: { id: props.repoId }, query: { ref: branch.value, path: dir.value || undefined } } })),
  staleTime: 60_000,
})
const blob = useQuery({
  queryKey: computed(() => ['repo', props.repoId, 'file', branch.value, file.value]),
  queryFn: () => unwrap(api.GET('/repos/{id}/file', { params: { path: { id: props.repoId }, query: { ref: branch.value, path: file.value } } })),
  enabled: computed(() => !!file.value),
  staleTime: 60_000,
})

// The folder's README, shown under the listing as GitHub and GitLab do.
const readme = computed(() => (file.value ? undefined : tree.data.value?.entries.find((e) => e.type === 'file' && /^readme(\.(md|markdown|txt|rst))?$/i.test(e.name))))
const readmeFile = useQuery({
  queryKey: computed(() => ['repo', props.repoId, 'file', branch.value, readme.value?.path]),
  queryFn: () => unwrap(api.GET('/repos/{id}/file', { params: { path: { id: props.repoId }, query: { ref: branch.value, path: readme.value!.path } } })),
  enabled: computed(() => !!readme.value),
  staleTime: 60_000,
})
const isMarkdown = (p: string) => /\.(md|markdown)$/i.test(p)

const crumbs = computed(() => {
  const parts = (file.value || dir.value).split('/').filter(Boolean)
  return parts.map((name, i) => ({ name, path: parts.slice(0, i + 1).join('/'), last: i === parts.length - 1 }))
})
const parent = computed(() => dir.value.split('/').slice(0, -1).join('/'))

function open(e: TreeEntry) {
  if (e.type === 'dir') go({ path: e.path })
  else if (e.type !== 'submodule') go({ file: e.path })
}
const icon = (e: TreeEntry) => (e.type === 'dir' ? 'folder' : 'file')

// The open file: its lines, highlighted once highlight.js has loaded.
const lines = computed(() => {
  const c = blob.data.value?.content ?? ''
  const ls = c.split('\n')
  if (ls.length > 1 && ls[ls.length - 1] === '') ls.pop()
  return ls
})
const html = ref<string[] | null>(null)
watch(
  () => [blob.data.value?.content, file.value] as const,
  async ([content, path], _, onCleanup) => {
    html.value = null
    let stale = false
    onCleanup(() => (stale = true))
    if (content === undefined || !path || content.length > 512 * 1024) return
    const out = await highlightCode(content, path).catch(() => null)
    if (!stale) html.value = out
  },
  { immediate: true },
)
const width = computed(() => `${String(lines.value.length).length}ch`)

type View = 'preview' | 'code'
const view = ref<View>('preview')
watch(file, () => (view.value = 'preview'))
const views = computed(() => [
  { value: 'preview' as View, label: t('repo.codePreview') },
  { value: 'code' as View, label: t('repo.codeSource') },
])
const errorOf = (e: unknown) => (e as Error)?.message || t('common.error')
</script>

<template>
  <section class="card">
    <div class="ch">
      <div>
        <h2>{{ t('repo.code') }}</h2>
        <p class="sub">{{ t('repo.codeSub') }}</p>
      </div>
      <div class="actions" style="margin: 0">
        <select class="cfg-in" :value="branch" :aria-label="t('repo.codeBranch')" :title="t('repo.codeBranch')" @change="setBranch(($event.target as HTMLSelectElement).value)">
          <option v-for="b in branchNames" :key="b" :value="b">{{ b }}{{ b === defaultBranch ? ` (${t('repo.default')})` : '' }}</option>
        </select>
      </div>
    </div>

    <nav class="cd-crumbs" :aria-label="t('repo.codePath')">
      <a href="#" :class="{ cur: !crumbs.length }" @click.prevent="go({})">{{ t('repo.codeRoot') }}</a>
      <template v-for="c in crumbs" :key="c.path">
        <span class="cd-sep">/</span>
        <span v-if="c.last" class="cur">{{ c.name }}</span>
        <a v-else href="#" @click.prevent="go({ path: c.path })">{{ c.name }}</a>
      </template>
    </nav>

    <!-- A file -->
    <template v-if="file">
      <p v-if="blob.isPending.value" class="hint">{{ t('common.loading') }}</p>
      <div v-else-if="blob.isError.value" class="help bad"><p>{{ errorOf(blob.error.value) }}</p></div>
      <div v-else-if="blob.data.value" class="cd-file">
        <div class="cd-fh">
          <span class="cd-meta">
            <span v-if="blob.data.value.content !== undefined">{{ t('repo.codeLines', { n: lines.length }) }} · </span>{{ fmtBytes(blob.data.value.size) }}
          </span>
          <span class="actions" style="margin: 0">
            <SegButtons v-if="isMarkdown(file) && blob.data.value.content !== undefined" v-model="view" :options="views" :label="t('repo.codeView')" />
            <a v-if="blob.data.value.url" class="btn btn-s" :href="blob.data.value.url" target="_blank" rel="noopener">{{ t('repo.openRun') }}</a>
          </span>
        </div>
        <p v-if="blob.data.value.binary" class="empty">{{ t('repo.codeBinary') }}</p>
        <p v-else-if="blob.data.value.tooLarge" class="empty">{{ t('repo.codeTooLarge') }}</p>
        <p v-else-if="!blob.data.value.content" class="empty">{{ t('repo.codeEmptyFile') }}</p>
        <ReportView v-else-if="isMarkdown(file) && view === 'preview'" class="cd-readme" :markdown="blob.data.value.content" />
        <div v-else class="diff cd-code" :style="{ '--ln': width }">
          <div v-for="(l, i) in lines" :key="i" class="dl">
            <span class="lns" aria-hidden="true"><span class="ln">{{ i + 1 }}</span></span>
            <!-- eslint-disable-next-line vue/no-v-html -- highlight.js escapes the text -->
            <span v-if="html" class="tx" v-html="html[i] ?? ''" />
            <span v-else class="tx">{{ l }}</span>
          </div>
        </div>
      </div>
    </template>

    <!-- A folder -->
    <template v-else>
      <p v-if="tree.isPending.value" class="hint">{{ t('common.loading') }}</p>
      <div v-else-if="tree.isError.value" class="help bad"><p>{{ errorOf(tree.error.value) }}</p></div>
      <template v-else-if="tree.data.value">
        <p v-if="!tree.data.value.entries.length && !dir" class="empty">{{ t('repo.codeEmpty') }}</p>
        <div v-else class="cd-list">
          <a v-if="dir" href="#" class="cd-row" @click.prevent="go({ path: parent })">
            <HiIcon name="folder" /><span class="cd-name">..</span>
          </a>
          <a
            v-for="e in tree.data.value.entries"
            :key="e.path"
            href="#"
            class="cd-row"
            :class="{ off: e.type === 'submodule' }"
            :aria-disabled="e.type === 'submodule'"
            @click.prevent="open(e)"
          >
            <HiIcon :name="icon(e)" :class="{ dir: e.type === 'dir' }" />
            <span class="cd-name">{{ e.name }}</span>
            <span v-if="e.type === 'submodule'" class="badge b-gray">{{ t('repo.codeSubmodule') }}</span>
            <span v-else-if="e.type === 'symlink'" class="badge b-gray">{{ t('repo.codeSymlink') }}</span>
            <span v-if="e.size !== undefined" class="cd-size">{{ fmtBytes(e.size) }}</span>
          </a>
        </div>
        <p v-if="tree.data.value.capped" class="hint">{{ t('repo.codeCapped', { n: tree.data.value.entries.length }) }}</p>

        <div v-if="readme && readmeFile.data.value?.content" class="cd-file cd-readme-box">
          <div class="cd-fh"><span class="cd-meta"><HiIcon name="file" />{{ readme.name }}</span></div>
          <ReportView v-if="isMarkdown(readme.name)" class="cd-readme" :markdown="readmeFile.data.value.content" />
          <pre v-else class="cd-readme cd-pre">{{ readmeFile.data.value.content }}</pre>
        </div>
      </template>
    </template>
  </section>
</template>

<style scoped>
.cd-crumbs { display: flex; flex-wrap: wrap; align-items: center; gap: 4px; margin: 0 0 12px; font-family: var(--mono); font-size: 13.5px; }
.cd-crumbs a { color: var(--primary); text-decoration: none; }
.cd-crumbs a:hover, .cd-crumbs a:focus-visible { text-decoration: underline; }
.cd-crumbs .cur { color: var(--ink); font-weight: 600; }
.cd-sep { color: var(--ink-3); }
.cd-list { border: 1px solid var(--line); border-radius: 10px; overflow: hidden; }
.cd-row { display: flex; align-items: center; gap: 10px; padding: 8px 14px; color: var(--ink); text-decoration: none; border-top: 1px solid var(--line-2); font-size: 14px; }
.cd-row:first-child { border-top: 0; }
.cd-row:hover, .cd-row:focus-visible { background: var(--row-hover); }
.cd-row.off { cursor: default; color: var(--ink-3); }
.cd-row.off:hover { background: none; }
.cd-row svg { flex: none; width: 17px; height: 17px; fill: none; stroke: var(--ink-3); stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
.cd-row svg.dir { stroke: var(--primary); }
.cd-name { flex: 1; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-family: var(--mono); font-size: 13.5px; }
.cd-size { flex: none; color: var(--ink-3); font-size: 12.5px; }
.cd-file { border: 1px solid var(--line); border-radius: 10px; overflow: hidden; }
.cd-readme-box { margin-top: 16px; }
.cd-fh { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 8px; padding: 8px 12px; border-bottom: 1px solid var(--line); background: var(--gray-soft); }
.cd-meta { display: inline-flex; align-items: center; gap: 6px; color: var(--ink-2); font-size: 13px; }
.cd-meta svg { width: 15px; height: 15px; fill: none; stroke: currentColor; stroke-width: 1.8; }
.cd-file > .empty { margin: 0; padding: 16px; }
.cd-code { font-family: var(--mono); font-size: 12.5px; line-height: 1.55; padding: 6px 0; }
.cd-code .dl { min-width: max-content; }
.cd-code .tx { white-space: pre; }
/* The width holds the digits alone; the padding keeps them off the edge and the rule. */
.cd-code .ln { box-sizing: content-box; width: var(--ln); padding: 0 12px 0 16px; border-right: 1px solid rgb(127 127 127 / 0.25); }
.cd-code .tx { padding-left: 16px; }
.cd-readme { padding: 16px 20px; }
.cd-pre { margin: 0; font-family: var(--mono); font-size: 13px; white-space: pre-wrap; overflow-wrap: anywhere; }
</style>
