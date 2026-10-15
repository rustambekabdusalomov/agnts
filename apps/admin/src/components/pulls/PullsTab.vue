<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import type { PullItem } from '../../api/types'
import { ago } from '../../composables/format'
import { useScrollPages } from '../../composables/useScrollPages'
import ScrollMore from '../repo/ScrollMore.vue'

// A repository's pull requests (GitLab merge requests) on the git host,
// with agnts's ticket for each: its own change, or its review.
const props = defineProps<{ repoId: number }>()
const { t, locale } = useI18n()
const STATES = ['open', 'merged', 'closed', 'all'] as const
const state = ref<(typeof STATES)[number]>('open')

const { query, all, more, sentinel } = useScrollPages<PullItem>({
  key: computed(() => ['pull', String(props.repoId), 'list', state.value]),
  fetch: (page) => unwrap(api.GET('/repos/{id}/pulls', { params: { path: { id: props.repoId }, query: { state: state.value, page } } })),
  perPage: 30,
  id: (p) => p.number,
  refetchInterval: 60_000,
})
const TONE: Record<string, string> = { open: 'b-info', merged: 'b-ok', closed: 'b-gray' }
</script>

<template>
  <section class="card">
    <div class="ch">
      <div>
        <h2>{{ t('pulls.title') }}</h2>
        <p class="sub">{{ t('pulls.sub') }}</p>
      </div>
      <div class="tabs" role="tablist" style="margin: 0">
        <button v-for="s in STATES" :key="s" type="button" class="tab" role="tab" :aria-selected="state === s" :aria-pressed="state === s" @click="state = s">
          {{ t(`pulls.state_${s}`) }}
        </button>
      </div>
    </div>
    <p v-if="query.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <div v-else-if="query.isError.value" class="help bad"><p>{{ (query.error.value as Error)?.message || t('common.error') }}</p></div>
    <p v-else-if="!all.length" class="empty">{{ t('pulls.none') }}</p>
    <ul v-else class="pl">
      <li v-for="p in all" :key="p.number">
        <RouterLink class="pl-row" :to="{ name: 'pull', params: { id: repoId, number: p.number } }">
          <span class="pl-n mono">#{{ p.number }}</span>
          <span class="pl-b">
            <span class="pl-t">{{ p.title }}</span>
            <span class="pl-meta">
              <span>{{ p.author }}</span>
              <span class="mono">{{ p.headRef }} → {{ p.baseRef }}</span>
              <span>{{ t('pulls.updated', { time: ago(p.updatedAt, locale) }) }}</span>
            </span>
          </span>
          <span class="pl-tags">
            <span v-if="p.draft" class="badge b-gray">{{ t('pulls.draft') }}</span>
            <span v-if="p.why" class="badge b-warn">{{ t(`reviews.why_${p.why}`) }}</span>
            <span v-if="p.ticketKey" class="badge b-info">{{ p.own ? t('pulls.ownTicket', { key: p.ticketKey }) : t('pulls.reviewTicket', { key: p.ticketKey }) }}</span>
            <span class="badge" :class="TONE[p.state]">{{ t(`pulls.state_${p.state}`) }}</span>
          </span>
        </RouterLink>
      </li>
    </ul>
    <ScrollMore
      v-if="all.length"
      :ref="sentinel"
      :loading="query.isFetchingNextPage.value"
      :failed="query.isFetchNextPageError.value"
      :has-more="!!query.hasNextPage.value"
      :end="t('pulls.end')"
      @more="more"
    />
  </section>
</template>

<style scoped>
.pl { list-style: none; margin: 0; padding: 0; display: grid; }
.pl li + li { border-top: 1px solid var(--line-2); }
.pl-row { display: flex; align-items: flex-start; gap: 12px; padding: 12px 4px; color: inherit; text-decoration: none; min-width: 0; }
.pl-row:hover { background: var(--row-hover); }
.pl-n { color: var(--ink-3); flex: none; min-width: 3.5ch; }
.pl-b { flex: 1; min-width: 0; display: grid; gap: 4px; }
.pl-t { font-weight: 600; overflow-wrap: anywhere; }
.pl-meta { display: flex; flex-wrap: wrap; gap: 4px 12px; font-size: 12.5px; color: var(--ink-3); }
.pl-meta .mono { overflow-wrap: anywhere; }
.pl-tags { display: flex; gap: 6px; flex-wrap: wrap; justify-content: flex-end; flex: none; max-width: 45%; }
@media (max-width: 640px) {
  .pl-row { flex-wrap: wrap; }
  .pl-tags { max-width: none; justify-content: flex-start; flex-basis: 100%; }
}
</style>
