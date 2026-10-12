<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import HBars from '../charts/HBars.vue'
import DeltaTag from '../dashboard/DeltaTag.vue'
import { pctOf, type AnalyticsLearning } from './analytics'

// Learning: what agnts learned (lessons, rules, reflections), whether its
// follow-up suggestions are useful, and what reviewers keep telling it.
const props = defineProps<{ l: AnalyticsLearning }>()
const { t } = useI18n()

const cur = computed(() => props.l.current)
const prev = computed(() => props.l.previous)
const acceptRate = (p: { accepted: number; dismissed: number }) => pctOf(p.accepted, p.accepted + p.dismissed)

const lessonRows = computed(() => props.l.lessons.map((c) => ({ l: t(`learn.category_${c.category}`), v: c.created })))
const sourceRows = computed(() => props.l.followUpSources.map((c) => ({ l: t(`followUps.source_${c.name}`), v: c.suggested })))
</script>

<template>
  <div class="g6">
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiLessons') }}</div>
      <div class="val">{{ cur.lessons }} <DeltaTag :cur="cur.lessons" :prev="prev.lessons" :good-when-up="true" /></div>
      <div class="note">{{ t('analytics.kpiLessonsNote', { n: cur.lessonsLearned }) }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiRulesLearned') }}</div>
      <div class="val">{{ cur.rulesAdopted }} <DeltaTag :cur="cur.rulesAdopted" :prev="prev.rulesAdopted" :good-when-up="true" /></div>
      <div class="note">{{ t('analytics.kpiRulesLearnedNote', { n: cur.rulesSuggested }) }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiRulesManual') }}</div>
      <div class="val">{{ cur.rulesManual }}</div>
      <div class="note">{{ t('analytics.kpiRulesManualNote') }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiReflections') }}</div>
      <div class="val">{{ cur.reflections }}</div>
      <div class="note">{{ t('analytics.kpiReflectionsNote', { n: cur.reflectionRules }) }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiFollowUps') }}</div>
      <div class="val">
        <template v-if="cur.accepted + cur.dismissed">{{ acceptRate(cur) }}% <DeltaTag :cur="acceptRate(cur)" :prev="acceptRate(prev)" :good-when-up="true" /></template>
        <template v-else>—</template>
      </div>
      <div class="note">{{ t('analytics.kpiFollowUpsNote', { n: cur.followUps }) }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiReviewerNotes') }}</div>
      <div class="val">{{ cur.reviewerNotes }} <DeltaTag :cur="cur.reviewerNotes" :prev="prev.reviewerNotes" :good-when-up="false" /></div>
      <div class="note">{{ t('analytics.kpiReviewerNotesNote') }}</div>
    </div>
  </div>
  <p class="hint" style="margin: -8px 0 0">{{ t('analytics.learningNote') }}</p>

  <div class="dash-grid">
    <section class="card span2">
      <div class="ch">
        <div><h2>{{ t('analytics.followUps') }}</h2><p class="sub">{{ t('analytics.followUpsSub') }}</p></div>
      </div>
      <p v-if="!l.followUpTypes.length" class="hint">{{ t('analytics.noFollowUps') }}</p>
      <div v-else class="tw">
        <table class="tbl">
          <thead>
            <tr>
              <th>{{ t('analytics.colType') }}</th>
              <th>{{ t('analytics.colSuggested') }}</th>
              <th>{{ t('analytics.colAccepted') }}</th>
              <th>{{ t('analytics.colDismissed') }}</th>
              <th>{{ t('analytics.colOpen') }}</th>
              <th>{{ t('analytics.colAcceptRate') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="c in l.followUpTypes" :key="c.name">
              <td class="ttitle" style="white-space: nowrap">{{ t(`followUps.type_${c.name}`) }}</td>
              <td>{{ c.suggested }}</td>
              <td>{{ c.accepted }}</td>
              <td>{{ c.dismissed }}</td>
              <td>{{ c.suggested - c.accepted - c.dismissed }}</td>
              <td>
                <span v-if="c.accepted + c.dismissed" :class="acceptRate(c) >= 50 ? 'repo-ok' : 'repo-miss'">{{ acceptRate(c) }}%</span>
                <span v-else class="hint">—</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <section class="card">
      <div class="ch"><div><h2>{{ t('analytics.followUpSources') }}</h2><p class="sub">{{ t('analytics.followUpSourcesSub') }}</p></div></div>
      <p v-if="!sourceRows.length" class="hint">{{ t('analytics.noFollowUps') }}</p>
      <HBars v-else :rows="sourceRows" />
    </section>

    <section class="card">
      <div class="ch">
        <div><h2>{{ t('analytics.lessons') }}</h2><p class="sub">{{ t('analytics.lessonsSub', { n: cur.lessonsLearned }) }}</p></div>
        <RouterLink class="btn btn-s" :to="{ name: 'learn' }">{{ t('analytics.openLearn') }}</RouterLink>
      </div>
      <p v-if="!lessonRows.length" class="hint">{{ t('analytics.noLessons') }}</p>
      <HBars v-else :rows="lessonRows" />
    </section>

    <section class="card span2">
      <div class="ch">
        <div><h2>{{ t('analytics.reviewers') }}</h2><p class="sub">{{ t('analytics.reviewersSub') }}</p></div>
        <RouterLink class="btn btn-s" :to="{ name: 'rules' }">{{ t('analytics.openRules') }}</RouterLink>
      </div>
      <p v-if="!l.reviewers.length" class="hint">{{ t('analytics.noReviewers') }}</p>
      <div v-else class="tw">
        <table class="tbl">
          <thead>
            <tr>
              <th>{{ t('analytics.colReviewer') }}</th>
              <th :title="t('analytics.colRereviewHint')">{{ t('analytics.colRereview') }}</th>
              <th :title="t('analytics.colDismissedNotesHint')">{{ t('analytics.colDismissedNotes') }}</th>
              <th :title="t('analytics.colManualHint')">{{ t('analytics.colManual') }}</th>
              <th>{{ t('analytics.colRepos') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="r in l.reviewers" :key="r.login">
              <td class="ttitle mono" style="white-space: nowrap">{{ r.login }}</td>
              <td>{{ r.rereview }}</td>
              <td>{{ r.dismissed }}</td>
              <td>{{ r.manual }}</td>
              <td>{{ r.repos.join(', ') || '—' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>
