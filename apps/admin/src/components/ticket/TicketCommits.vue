<script setup lang="ts">
import { useInfiniteQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import type { components } from '../../api/schema.gen'
import type { Ticket } from '../../api/types'
import { ago } from '../../composables/format'

type LinkedCommits = components['schemas']['LinkedCommits']

// Commits on the git host whose branch or message has the ticket's number
// (or key): anyone's, from pushes and the repositories' recent history.
// Shown once there is one; a commits_linked event refreshes it.
const props = defineProps<{ ticket: Ticket }>()
const { t, locale } = useI18n()
const open = ref(true)
const perPage = 20

const commits = useInfiniteQuery({
  queryKey: computed(() => ['ticket-commits', props.ticket.key]),
  queryFn: ({ pageParam }) =>
    unwrap(api.GET('/tickets/{key}/linked-commits', { params: { path: { key: props.ticket.key }, query: { limit: perPage, offset: pageParam } } })),
  initialPageParam: 0,
  getNextPageParam: (last: LinkedCommits, pages: LinkedCommits[]) => {
    const seen = pages.reduce((n, p) => n + p.commits.length, 0)
    return seen < last.total && last.commits.length ? seen : undefined
  },
})
const all = computed(() => {
  const seen = new Set<string>()
  return (commits.data.value?.pages.flatMap((p) => p.commits) ?? []).filter((c) => {
    const k = `${c.repoId}:${c.sha}`
    return !seen.has(k) && !!seen.add(k)
  })
})
const total = computed(() => commits.data.value?.pages[0]?.total ?? 0)
const number = computed(() => props.ticket.ticketNumber || props.ticket.key)
</script>

<template>
  <section v-if="total > 0" class="card">
    <div class="ch">
      <div>
        <h2>
          <button type="button" class="tc-tg" :aria-expanded="open" @click="open = !open">{{ t('linkedCommits.title') }}</button>
          <span class="badge" style="margin-left: 8px">{{ t('linkedCommits.total', { n: total }) }}</span>
        </h2>
        <p class="sub">{{ t('linkedCommits.sub', { number }) }}</p>
      </div>
    </div>
    <template v-if="open">
      <div class="cm-list">
        <div v-for="c in all" :key="`${c.repoId}:${c.sha}`" class="cm">
          <div class="cm-b">
            <a v-if="c.url" class="cm-m" :href="c.url" target="_blank" rel="noopener">{{ c.subject || c.shortSha }}</a>
            <span v-else class="cm-m">{{ c.subject || c.shortSha }}</span>
            <div class="cm-meta">
              <span class="au">{{ t('linkedCommits.meta', { author: c.authorLogin ? `@${c.authorLogin}` : c.author, repo: c.repo, branch: c.branch }) }}</span>
              <span v-if="c.matchedOn.includes('branch')" class="badge b-info" :title="t('linkedCommits.onBranchHint')">{{ t('linkedCommits.onBranch') }}</span>
              <span v-if="c.matchedOn.includes('message')" class="badge" :title="t('linkedCommits.onMessageHint')">{{ t('linkedCommits.onMessage') }}</span>
            </div>
          </div>
          <div class="cm-r">
            <RouterLink class="sha" :to="{ name: 'commit', params: { id: c.repoId, sha: c.sha } }">{{ c.shortSha.slice(0, 7) }}</RouterLink>
            <span class="hint">{{ ago(c.committedAt, locale) }}</span>
          </div>
        </div>
      </div>
      <div v-if="commits.hasNextPage.value" class="actions">
        <button type="button" class="btn btn-s" :disabled="commits.isFetchingNextPage.value" @click="commits.fetchNextPage()">
          {{ t('linkedCommits.more', { n: total - all.length }) }}
        </button>
      </div>
      <p v-if="commits.isFetchNextPageError.value" class="help bad">{{ t('linkedCommits.loadError') }}</p>
    </template>
  </section>
</template>

<style scoped>
.cm-m { display: block; color: inherit; text-decoration: none; }
a.cm-m:hover, a.cm-m:focus-visible { text-decoration: underline; }
.tc-tg { background: none; border: 0; padding: 0; font: inherit; color: inherit; cursor: pointer; text-align: left; }
.tc-tg::after { content: ' ▾'; color: var(--ink-3); font-size: 0.8em; }
.tc-tg[aria-expanded='false']::after { content: ' ▸'; }
</style>
