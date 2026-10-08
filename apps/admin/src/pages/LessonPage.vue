<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import PageHeader from '../components/PageHeader.vue'
import LessonQuiz from '../components/learn/LessonQuiz.vue'
import LessonText from '../components/learn/LessonText.vue'
import { useLesson, useSetLearned } from '../components/learn/useLessons'
import HiIcon from '../components/ui/HiIcon.vue'
import { ago } from '../composables/format'
import { useWorkspace } from '../stores/workspace'

// One lesson: what it is, why the change needed it, where to look, a quiz
// and further reading.
const { t, locale } = useI18n()
const route = useRoute()
const id = computed(() => Number(route.params.id))
const lesson = useLesson(id)
const l = computed(() => lesson.data.value)
const setLearned = useSetLearned()
const workspace = useWorkspace()
// A reference's folder and file name, shown in different weights.
const dirOf = (p: string) => p.slice(0, p.lastIndexOf('/') + 1)
const fileOf = (p: string) => p.slice(p.lastIndexOf('/') + 1)
</script>

<template>
  <RouterLink class="back-btn" :to="{ name: 'learn' }"><HiIcon name="back" />{{ t('learn.back') }}</RouterLink>
  <p v-if="lesson.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="lesson.isError.value || !l" class="empty">{{ t('learn.notFound') }}</p>
  <template v-else>
    <PageHeader :title="l.title">
      <template #below>
        <div class="lesson-meta" style="margin-top: 10px">
          <span class="src">{{ t(`learn.category_${l.category}`) }}</span>
          <span class="src local">{{ t(`learn.level_${l.level}`) }}</span>
          <RouterLink class="tkey" :to="{ name: 'repo', params: { id: l.repoId } }">{{ l.repoName }}</RouterLink>
          <RouterLink class="tkey" :to="{ name: 'ticket', params: { key: l.ticketKey } }">{{ t('learn.fromTicket', { key: l.ticketKey }) }}</RouterLink>
          <span class="tkey">{{ t('learn.readTime', { n: l.readMinutes }) }}</span>
          <span class="tkey">{{ ago(l.createdAt, locale) }}</span>
        </div>
      </template>
      <div v-if="workspace.canEdit" class="actions" style="margin: 0">
        <button
          type="button"
          class="btn"
          :class="{ 'btn-p': !l.learnedAt }"
          :disabled="setLearned.isPending.value"
          @click="setLearned.mutate({ id: l.id, learned: !l.learnedAt })"
        >
          <HiIcon v-if="!l.learnedAt" name="check" />{{ l.learnedAt ? t('learn.markUnlearned') : t('learn.markLearned') }}
        </button>
      </div>
    </PageHeader>

    <div class="cfg-grid">
      <div class="col">
        <section v-if="l.summary" class="card summary"><p style="margin: 0">{{ l.summary }}</p></section>
        <section v-if="l.explanation" class="card">
          <div class="ch"><h2>{{ t('learn.whatTitle') }}</h2></div>
          <LessonText :text="l.explanation" />
        </section>
        <section v-if="l.whyHere" class="card">
          <div class="ch"><h2>{{ t('learn.whyTitle') }}</h2></div>
          <LessonText :text="l.whyHere" />
        </section>
        <section v-if="l.quiz.length" class="card">
          <div class="ch"><div><h2>{{ t('learn.quizTitle') }}</h2><p class="sub">{{ t('learn.quizSub') }}</p></div></div>
          <LessonQuiz :quiz="l.quiz" />
        </section>
      </div>
      <aside class="cfg-side lesson-side">
        <section v-if="l.refs.length" class="card">
          <div class="ch"><div><h2>{{ t('learn.whereTitle') }}</h2><p class="sub">{{ t('learn.whereSub', { repo: l.repoName, key: l.ticketKey }) }}</p></div></div>
          <ul class="lesson-refs">
            <li v-for="(r, i) in l.refs" :key="i">
              <code class="lesson-path" :title="r.line ? `${r.path}:${r.line}` : r.path">
                <span class="dir">{{ dirOf(r.path) }}</span><span class="file">{{ fileOf(r.path) }}</span><span v-if="r.line" class="line">:{{ r.line }}</span>
              </code>
              <p v-if="r.note">{{ r.note }}</p>
            </li>
          </ul>
        </section>
        <section v-if="l.reading.length" class="card">
          <div class="ch"><h2>{{ t('learn.readingTitle') }}</h2></div>
          <ul class="lesson-refs">
            <li v-for="(k, i) in l.reading" :key="i">
              <a :href="k.url" target="_blank" rel="noopener noreferrer">{{ k.title }}</a>
              <p class="lesson-url">{{ k.url }}</p>
            </li>
          </ul>
          <p class="hint" style="margin: 10px 0 0">{{ t('learn.readingNote') }}</p>
        </section>
      </aside>
    </div>
  </template>
</template>
