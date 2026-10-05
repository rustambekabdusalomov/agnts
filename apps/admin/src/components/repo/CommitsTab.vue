<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import { useScrollPages } from '../../composables/useScrollPages'
import CiDot from './CiDot.vue'
import ScrollMore from './ScrollMore.vue'
import type { Commit } from './types'

const props = defineProps<{ repoId: number }>()
const { t, locale } = useI18n()

// 50 commits a page, the next loading as the bottom scrolls into view.
const { query: commits, all, more, sentinel } = useScrollPages<Commit>({
  key: computed(() => ['repo', props.repoId, 'commit-pages']),
  fetch: (page) => unwrap(api.GET('/repos/{id}/commits', { params: { path: { id: props.repoId }, query: { page } } })),
  perPage: 50,
  id: (c) => c.sha,
  refetchInterval: 60_000,
})

const groups = computed(() => {
  const out: { day: string; label: string; items: Commit[] }[] = []
  for (const c of all.value) {
    const d = c.date ? new Date(c.date) : null
    const day = d ? d.toDateString() : ''
    let g = out.find((x) => x.day === day)
    if (!g) {
      g = { day, label: d ? d.toLocaleDateString(locale.value, { weekday: 'long', day: 'numeric', month: 'long' }) : '—', items: [] }
      out.push(g)
    }
    g.items.push(c)
  }
  return out
})
const time = (iso?: string) => (iso ? new Date(iso).toLocaleTimeString(locale.value, { hour: '2-digit', minute: '2-digit', hour12: false }) : '')
</script>

<template>
  <section class="card">
    <div class="ch">
      <div>
        <h2>{{ t('repo.commits') }}</h2>
        <p class="sub">{{ t('repo.commitsSub') }}</p>
      </div>
    </div>
    <p v-if="commits.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <div v-else-if="commits.isError.value" class="help bad"><p>{{ (commits.error.value as Error)?.message || t('common.error') }}</p></div>
    <p v-else-if="!groups.length" class="empty">{{ t('repo.none') }}</p>
    <template v-for="g in groups" :key="g.day">
      <div class="cm-day">{{ g.label }}</div>
      <div class="cm-list">
        <div v-for="c in g.items" :key="c.sha" class="cm">
          <CiDot :status="c.ci" />
          <div class="cm-b">
            <div class="cm-m">{{ c.message }}</div>
            <div class="cm-meta">
              <span class="au">{{ c.author }}</span>
              <RouterLink v-if="c.ticketKey" :to="`/tickets/${c.ticketKey}`" class="badge b-info">{{ c.ticketKey }}</RouterLink>
              <span v-if="c.add || c.del" class="n"><span style="color: var(--ok-ink)">+{{ c.add }}</span> <span style="color: var(--bad-ink)">−{{ c.del }}</span></span>
            </div>
          </div>
          <div class="cm-r">
            <a v-if="c.url" class="sha" :href="c.url" target="_blank" rel="noopener">{{ c.sha.slice(0, 7) }}</a>
            <span v-else class="sha">{{ c.sha.slice(0, 7) }}</span>
            <span class="hint">{{ time(c.date) }}</span>
          </div>
        </div>
      </div>
    </template>
    <ScrollMore
      v-if="all.length"
      :ref="sentinel"
      :loading="commits.isFetchingNextPage.value"
      :failed="commits.isFetchNextPageError.value"
      :has-more="commits.hasNextPage.value"
      :end="t('repo.commitsEnd', { n: all.length })"
      @more="more"
    />
  </section>
</template>
