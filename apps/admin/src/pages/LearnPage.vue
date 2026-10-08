<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import PageHeader from '../components/PageHeader.vue'
import InputSelect from '../components/form/InputSelect.vue'
import SegButtons from '../components/form/SegButtons.vue'
import { useLessons, type LessonStatus } from '../components/learn/useLessons'
import { useRepos } from '../components/repos/useRepos'
import { ago } from '../composables/format'
import { useLive } from '../composables/useLive'
import { useUi } from '../stores/ui'

// Lessons from pushed changes. View and repository live in the URL
// (?view=all&repo=3) so a filtered list can be linked; ?ticket= comes from
// notifications about one ticket.
const { t, locale } = useI18n()
const ui = useUi()
const route = useRoute()
const router = useRouter()
const repos = useRepos()
useLive()

const view = computed<LessonStatus>({
  get: () => (['all', 'learned'].includes(String(route.query.view)) ? (route.query.view as LessonStatus) : 'new'),
  set: (v) => void router.replace({ query: { ...route.query, view: v === 'new' ? undefined : v } }),
})
const repo = computed<number | undefined>({
  get: () => (route.query.repo ? Number(route.query.repo) : undefined),
  set: (v) => void router.replace({ query: { ...route.query, repo: v ? String(v) : undefined } }),
})
const repoOptions = computed(() => [
  { value: undefined, label: t('learn.allRepos') },
  ...(repos.data.value ?? []).map((r) => ({ value: r.id as number | undefined, label: r.name })),
])
const ticket = computed(() => (route.query.ticket ? String(route.query.ticket) : undefined))

const filter = computed(() => ({ status: ticket.value ? 'all' : view.value, repo: repo.value, ticket: ticket.value }))
const lessons = useLessons(filter)
const views = computed(() => [
  { value: 'new' as LessonStatus, label: t('learn.viewNew', { n: lessons.data.value?.unlearned ?? 0 }) },
  { value: 'all' as LessonStatus, label: t('learn.viewAll', { n: lessons.data.value?.total ?? 0 }) },
  { value: 'learned' as LessonStatus, label: t('learn.viewLearned') },
])
const rows = computed(() => {
  const q = ui.search.trim().toLowerCase()
  return (lessons.data.value?.items ?? []).filter(
    (l) => !q || [l.title, l.summary, l.slug, l.ticketKey].some((s) => s.toLowerCase().includes(q)),
  )
})
const empty = computed(() => {
  if (ui.search.trim()) return t('learn.noMatch')
  if (!lessons.data.value?.total) return t('learn.none')
  return view.value === 'new' ? t('learn.noneNew') : t('learn.noMatch')
})
</script>

<template>
  <PageHeader :title="t('learn.title')" doc="learn" />

  <section class="card">
    <div class="ch" style="flex-wrap: wrap; gap: 10px">
      <SegButtons v-if="!ticket" v-model="view" :options="views" :label="t('learn.viewLabel')" />
      <span v-else style="display: flex; gap: 8px; align-items: center">
        <span class="src">{{ t('learn.fromTicket', { key: ticket }) }}</span>
        <RouterLink class="btn btn-s" :to="{ name: 'learn' }">{{ t('learn.back') }}</RouterLink>
      </span>
      <InputSelect v-if="(repos.data.value?.length ?? 0) > 1" v-model="repo" :options="repoOptions" :label="t('learn.repoLabel')" style="width: 240px" />
    </div>

    <p v-if="lessons.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="lessons.isError.value" class="ferr">{{ t('common.error') }}</p>
    <p v-else-if="!rows.length" class="empty">{{ empty }}</p>
    <ul v-else class="lesson-list">
      <li v-for="l in rows" :key="l.id">
        <RouterLink class="lesson-row" :to="{ name: 'lesson', params: { id: l.id } }">
          <div class="lesson-row-top">
            <span class="ttitle">{{ l.title }}</span>
            <span v-if="!l.learnedAt" class="badge b-info">{{ t('learn.newBadge') }}</span>
            <span v-else class="badge b-ok">{{ t('learn.learned') }}</span>
          </div>
          <p class="lesson-sum">{{ l.summary }}</p>
          <div class="lesson-meta">
            <span class="src">{{ t(`learn.category_${l.category}`) }}</span>
            <span class="src local">{{ t(`learn.level_${l.level}`) }}</span>
            <span class="tkey">{{ l.repoName }} · {{ l.ticketKey }}</span>
            <span class="tkey">{{ t('learn.readTime', { n: l.readMinutes }) }}</span>
            <span v-if="l.quizCount" class="tkey">{{ t('learn.quizCount', { n: l.quizCount }) }}</span>
            <span class="tkey" style="margin-left: auto">{{ ago(l.createdAt, locale) }}</span>
          </div>
        </RouterLink>
      </li>
    </ul>
  </section>
</template>
