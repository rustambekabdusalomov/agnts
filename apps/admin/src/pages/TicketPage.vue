<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, nextTick, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import { isReport, KIND_EDITABLE, MODEL_NAME, needsRepo, stateKey, TERMINAL, type TicketKind } from '../api/types'
import UsageCard from '../components/dashboard/UsageCard.vue'
import DiffView from '../components/DiffView.vue'
import TicketLessons from '../components/learn/TicketLessons.vue'
import StateBadge from '../components/StateBadge.vue'
import LiveLog from '../components/ticket/LiveLog.vue'
import KindBadge from '../components/ticket/KindBadge.vue'
import KindPicker from '../components/ticket/KindPicker.vue'
import ImplementReport from '../components/ticket/ImplementReport.vue'
import FollowUps from '../components/ticket/FollowUps.vue'
import TicketRelations from '../components/ticket/TicketRelations.vue'
import CodeReview from '../components/ticket/CodeReview.vue'
import ModelPicker from '../components/ticket/ModelPicker.vue'
import ReportView from '../components/ticket/ReportView.vue'
import RepoPicker from '../components/ticket/RepoPicker.vue'
import ProgressTrack from '../components/ticket/ProgressTrack.vue'
import { useRepoMembers } from '../components/repo/useRepoMembers'
import RunLog from '../components/ticket/RunLog.vue'
import SpendCard from '../components/ticket/SpendCard.vue'
import HiIcon from '../components/ui/HiIcon.vue'
import { useEventLog } from '../composables/useEventLog'
import { ago, pct } from '../composables/format'
import { useUsage } from '../composables/useUsage'
import { provideTranslation, TRANSLATION_LANGS, type TranslationLang } from '../composables/useTranslation'
import InputSelect from '../components/form/InputSelect.vue'
import { useUi } from '../stores/ui'
import { askConfirm } from '../composables/useConfirm'

const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const qc = useQueryClient()
const ui = useUi()
const key = computed(() => String(route.params.key))

const detail = useQuery({
  queryKey: computed(() => ['ticket', key.value]),
  queryFn: () => unwrap(api.GET('/tickets/{key}', { params: { path: { key: key.value } } })),
  refetchInterval: (q) => (q.state.data && TERMINAL.includes(q.state.data.ticket.state) ? false : 15_000),
})
const d = computed(() => detail.data.value)
const tk = computed(() => d.value?.ticket)
const isTask = computed(() => tk.value?.source === 'local')
// A report kind (plan, analysis, bug): no branch, checks, diff or pull request.
const report = computed(() => !!tk.value && isReport(tk.value))
const kindEditable = computed(() => !!tk.value && KIND_EDITABLE.includes(tk.value.state) && !tk.value.prUrl && tk.value.resumeState !== 'pushing')
const { events } = useEventLog(key)

// The page can be read in another language; texts show translated where a
// translation exists. The UI language is offered first.
const translation = provideTranslation(key, computed(() => tk.value?.updatedAt))
const tr = translation.tr
const langOptions = computed(() => {
  const ui = TRANSLATION_LANGS.filter((l) => l.value === locale.value)
  return [{ value: '' as TranslationLang | '', label: t('ticket.translateOriginal') }, ...ui, ...TRANSLATION_LANGS.filter((l) => l.value !== locale.value)]
})
const translateError = computed(() => {
  const e = translation.query.error.value
  return e ? t('ticket.translateFailed', { error: e instanceof HttpError ? e.message : t('common.error') }) : ''
})
const usage = useUsage()

// Answers: option or free text, plus an optional note per question.
const answers = reactive<Record<number, { answer: string; note: string }>>({})
watch(
  () => d.value?.questions,
  (qs) => {
    for (const q of qs ?? []) answers[q.id] ??= { answer: q.answer ?? '', note: q.note }
  },
  { immediate: true },
)
const left = computed(() => (d.value?.questions ?? []).filter((q) => !answers[q.id]?.answer.trim()).length)
const answered = computed(() => (d.value?.questions ?? []).filter((q) => q.answer))

const feedback = ref('')
const notice = ref('')

// Assignees for the pull request agnts opens on approval (not for tasks that
// push straight to the default branch). Members load only while reviewing.
const opensPr = computed(() => !report.value && !(isTask.value && tk.value?.afterApprove === 'main'))
// Reports reach the Jira issue only when the reviewer ticks this.
const postReport = ref(false)
const reviewing = computed(() => tk.value?.state === 'waiting_for_review' && opensPr.value)
// Mirrors the server's rule: no pull request and no pending push.
const canChangeRepo = computed(() => !!tk.value && !tk.value.prUrl && tk.value.resumeState !== 'pushing')
const members = useRepoMembers(computed(() => (reviewing.value ? tk.value?.repoId : undefined)))
const assignees = ref<string[]>([])
watch(
  () => [key.value, tk.value?.state],
  () => {
    assignees.value = [...(tk.value?.assignees ?? [])]
    postReport.value = false
  },
  { immediate: true },
)

// The analysis disagreed with a kind someone chose: offer the switch while
// the kind can still change.
const kindWarning = computed(() => {
  const ev = [...events.value].reverse().find((e) => e.type === 'kind_changed')
  if (!ev || ev.level !== 'warn' || !tk.value || ev.data.to === tk.value.kind || ev.data.from !== tk.value.kind) return null
  return { message: ev.message, to: ev.data.to as TicketKind }
})
const switchKind = useMutation({
  mutationFn: (kind: TicketKind) => unwrap(api.PUT('/tickets/{key}/kind', { params: { path: { key: key.value } }, body: { kind } })),
  onSettled: () => qc.invalidateQueries({ queryKey: ['ticket', key.value] }),
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
function toggleAssignee(u: string) {
  assignees.value = assignees.value.includes(u) ? assignees.value.filter((x) => x !== u) : [...assignees.value, u]
}

type Action = 'answers' | 'approve' | 'request-changes' | 'reject' | 'retry' | 'start' | 'stop' | 'merged'
const act = useMutation({
  mutationFn: (a: Action) => {
    const path = { params: { path: { key: key.value } } }
    switch (a) {
      case 'answers':
        return unwrap(
          api.PUT('/tickets/{key}/answers', {
            ...path,
            body: {
              answers: Object.entries(answers).map(([id, v]) => ({
                questionId: Number(id),
                answer: v.answer.trim(),
                note: v.note.trim() || undefined,
              })),
            },
          }),
        )
      case 'approve':
        return unwrap(
          api.POST('/tickets/{key}/approve', {
            ...path,
            body: report.value ? { postReport: postReport.value } : opensPr.value ? { assignees: assignees.value } : {},
          }),
        )
      case 'request-changes':
        return unwrap(api.POST('/tickets/{key}/request-changes', { ...path, body: { feedback: feedback.value.trim() } }))
      case 'reject':
        return unwrap(api.POST('/tickets/{key}/reject', { ...path, body: {} }))
      case 'retry':
        return unwrap(api.POST('/tickets/{key}/retry', path))
      case 'start':
        return unwrap(api.POST('/tickets/{key}/analyze', path))
      case 'stop':
        return unwrap(api.POST('/tickets/{key}/stop', path))
      case 'merged':
        return unwrap(api.POST('/tickets/{key}/merged', path))
    }
  },
  onSuccess: (_, a) => {
    notice.value = ''
    if (a === 'request-changes') feedback.value = ''
  },
  onError: (e) => {
    notice.value = e instanceof HttpError && e.status === 409 ? t('ticket.conflict') : e instanceof HttpError ? e.message : t('common.error')
  },
  onSettled: () => qc.invalidateQueries({ queryKey: ['ticket', key.value] }),
})

const del = useMutation({
  mutationFn: () => unwrap(api.DELETE('/tasks/{key}', { params: { path: { key: key.value } } })),
  onSuccess: () => router.push('/tasks'),
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

const ACTION_LABEL = { approve: 'ticket.approve', reject: 'ticket.reject', stop: 'ticket.stopRun' } as const
async function confirmThen(msg: string, a: keyof typeof ACTION_LABEL) {
  const label = a === 'approve' && report.value ? t('ticket.approveReport') : t(ACTION_LABEL[a])
  if (await askConfirm({ title: label, message: msg, confirmLabel: label, danger: a !== 'approve' })) act.mutate(a)
}
function approve() {
  const t0 = tk.value
  if (!t0) return
  if (report.value) {
    confirmThen(postReport.value ? t('ticket.approveReportPostConfirm', { key: t0.key }) : t('ticket.approveReportConfirm'), 'approve')
    return
  }
  let msg = opensPr.value ? t('ticket.approveConfirm', { branch: t0.branch }) : t('ticket.approveMainConfirm')
  if (opensPr.value && assignees.value.length) msg += '\n\n' + t('ticket.approveAssignees', { names: assignees.value.join(', ') })
  confirmThen(msg, 'approve')
}
function reject() {
  confirmThen(t('ticket.rejectConfirm', { key: key.value }), 'reject')
}
async function deleteTask() {
  if (await askConfirm({ title: t('ticket.delete'), message: t('ticket.deleteConfirm', { key: key.value }), confirmLabel: t('ticket.delete'), danger: true })) del.mutate()
}

// Lines from agnts's code review go to the end of the feedback box.
function addFeedback(line: string) {
  feedback.value = feedback.value.trim() ? `${feedback.value.trimEnd()}\n${line}` : line
}
// Opens a changed file's diff and scrolls to it.
async function showFile(path: string) {
  tab.value = 'changes'
  await nextTick()
  const el = document.getElementById(`diff-${path}`) as HTMLDetailsElement | null
  if (!el) return
  el.open = true
  el.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

const result = computed(() => d.value?.result)
// The tickets this one waits for (active dependencies not merged yet).
const waitsFor = computed(() =>
  (d.value?.relations?.items ?? []).filter((r) => r.status === 'active' && r.direction === 'waits_for' && !r.other.landed).map((r) => r.other.key),
)
const totals = computed(() => {
  const files = result.value?.files ?? []
  return { n: files.length, add: files.reduce((a, f) => a + f.add, 0), del: files.reduce((a, f) => a + f.del, 0) }
})
const checksOk = computed(() => (result.value?.checks ?? []).every((c) => c.exitCode === 0))

// Everything that is not the current decision sits behind tabs under the
// state card, so the page is one screen of "what now" plus one open panel
// instead of every section stacked. The first available tab opens by default.
type Tab = 'decide' | 'report' | 'review' | 'changes' | 'followUps' | 'order' | 'answers' | 'lessons' | 'log'
const tabs = computed(() => {
  const k = tk.value
  if (!k) return []
  const out: { id: Tab; label: string; n?: number }[] = []
  if (reviewingReport.value) out.push({ id: 'decide', label: t('ticket.reviewReportTitle') })
  if (report.value && (k.state === 'waiting_for_review' || (k.state === 'done' && result.value?.report))) out.push({ id: 'report', label: t('ticket.report') })
  if (k.state === 'waiting_for_review') out.push({ id: 'review', label: t('ticket.tabReview'), n: d.value?.review?.revision === k.revision ? d.value.review.findings.length || undefined : undefined })
  if (!report.value && result.value?.files.length) out.push({ id: 'changes', label: t('ticket.changes'), n: totals.value.n })
  if (d.value?.followUps) out.push({ id: 'followUps', label: t('ticket.tabFollowUps') })
  const rels = d.value?.relations
  if (k.repoId || rels?.items.length) {
    const waiting = rels?.items.filter((r) => r.status === 'proposed').length
    out.push({ id: 'order', label: t('relations.tab'), n: waiting || undefined })
  }
  if (answered.value.length && !['new', 'analyzing', 'waiting_for_answers'].includes(k.state)) out.push({ id: 'answers', label: t('ticket.tabAnswers'), n: answered.value.length })
  if (k.state === 'done') out.push({ id: 'lessons', label: t('ticket.tabLessons') })
  if (events.value.length) out.push({ id: 'log', label: t('ticket.runLog') })
  return out
})
// A report under review has its decision in a tab next to the report itself,
// not in the state card above.
const reviewingReport = computed(() => tk.value?.state === 'waiting_for_review' && report.value)
const tab = ref<Tab | null>(null)
const activeTab = computed(() => tabs.value.find((x) => x.id === tab.value)?.id ?? tabs.value[0]?.id)

// Long descriptions fold to a few lines.
const descOpen = ref(false)
const descLong = computed(() => {
  const s = tk.value?.description ?? ''
  return s.length > 280 || s.split('\n').length > 4
})
watch(key, () => {
  tab.value = null
  descOpen.value = false
})
const branch = computed(() => tk.value?.branch || `agnts/${key.value}`)
const reviewSub = computed(() => {
  if (isTask.value && tk.value?.afterApprove === 'main') return t('ticket.reviewSubMain')
  return isTask.value ? t('ticket.reviewSubPr', { branch: branch.value }) : t('ticket.reviewSubJira', { branch: branch.value })
})
const titleWithRev = (title: string) =>
  tk.value && tk.value.revision > 0 ? t('ticket.revisionSuffix', { title, n: tk.value.revision }) : title
const sessionPct = computed(() => pct(usage.data.value?.fiveHour.utilization))
const histTime = (iso: string) => new Date(iso).toLocaleTimeString(locale.value, { hour: '2-digit', minute: '2-digit', hour12: false })
const histDot = (origin: string, state: string) =>
  state === 'done' ? 'ok' : ['web', 'mobile', 'mcp', 'telegram'].includes(origin) ? 'you' : ''
const backTo = computed(() => (isTask.value ? '/tasks' : { name: 'tickets', query: { f: 'needs' } }))
</script>

<template>
  <RouterLink class="back-btn" :to="backTo"><HiIcon name="back" />{{ isTask ? t('nav.tasks') : t('ticket.back') }}</RouterLink>

  <p v-if="detail.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="detail.error.value instanceof HttpError && detail.error.value.status === 404" class="ferr">
    {{ t('ticket.notFound', { key }) }}
  </p>
  <p v-else-if="detail.isError.value" class="ferr">{{ t('common.error') }}</p>

  <template v-else-if="d && tk">
    <div class="ph">
      <div>
        <h1>{{ tr(tk.title) }}</h1>
        <p v-if="tk.description" class="tk-desc" :class="{ folded: descLong && !descOpen }">{{ tr(tk.description) }}</p>
        <button v-if="descLong" type="button" class="tk-more" :aria-expanded="descOpen" @click="descOpen = !descOpen">
          {{ descOpen ? t('ticket.showLess') : t('ticket.showMore') }}
        </button>
      </div>
      <div class="actions tk-head-act" style="margin: 0">
        <div class="tk-lang">
          <InputSelect v-model="translation.lang.value" :options="langOptions" :label="t('ticket.translate')" :placeholder="t('ticket.translate')" />
        </div>
        <button v-if="isTask && tk.state === 'new'" class="btn btn-d" type="button" :disabled="del.isPending.value" @click="deleteTask">{{ t('ticket.delete') }}</button>
      </div>
    </div>
    <p v-if="translation.lang.value && translation.query.isFetching.value" class="hint tk-tr-note" role="status">
      <span class="spin" aria-hidden="true" />{{ t('ticket.translating') }}
    </p>
    <p v-else-if="translateError" class="ferr" role="alert">{{ translateError }}</p>

    <p v-if="notice" class="ferr" role="alert">{{ notice }}</p>
    <div v-if="kindWarning" class="help warn" style="margin-bottom: 14px">
      <HiIcon name="info" />
      <p>
        {{ kindWarning.message }}
        <button
          v-if="kindEditable"
          type="button"
          class="btn"
          style="margin-left: 8px; min-height: 32px"
          :disabled="switchKind.isPending.value"
          @click="switchKind.mutate(kindWarning.to)"
        >
          {{ t('kind.switchTo', { kind: t(`kind.${kindWarning.to}`) }) }}
        </button>
      </p>
    </div>

    <div class="cfg-grid">
      <div class="col">
        <section class="card"><ProgressTrack :ticket="tk" :spend="d.spendByStage" /></section>

        <section v-if="!reviewingReport" class="card">
          <!-- new -->
          <template v-if="tk.state === 'new'">
            <h2>{{ t('ticket.queuedTitle') }}</h2>
            <p class="sub">{{ tk.held ? t('ticket.heldSub') : report ? t('ticket.queuedSubReport') : t('ticket.queuedSub') }}</p>
            <KindPicker :ticket="tk" />
            <RepoPicker :ticket="tk" />
            <ModelPicker :ticket="tk" :stages="['analyze', 'coding']" />
            <div v-if="tk.held" class="actions">
              <button class="btn btn-p" type="button" :disabled="act.isPending.value" @click="act.mutate('start')">{{ t('ticket.start') }}</button>
              <span class="hint">{{ t('ticket.startHint') }}</span>
            </div>
          </template>

          <!-- analyzing -->
          <template v-else-if="tk.state === 'analyzing'">
            <h2>{{ tk.repoId ? t('ticket.analyzingTitle') : t('ticket.analyzingTitleNoRepo') }}</h2>
            <p class="sub">{{ tk.repoId ? t('ticket.analyzingSub', { repo: tk.repoName ?? '' }) : t('ticket.analyzingSubNoRepo') }}</p>
            <div class="sec"><LiveLog :events="events" /></div>
            <div class="actions"><button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="confirmThen(t('ticket.stopConfirm', { key }), 'stop')">{{ t('ticket.stopRun') }}</button></div>
          </template>

          <!-- waiting_for_answers -->
          <template v-else-if="tk.state === 'waiting_for_answers'">
            <h2>{{ t('ticket.questionsTitle', { n: d.questions.length }) }}</h2>
            <p class="sub">{{ t('ticket.questionsSub') }}</p>
            <div v-if="d.analysis?.plan.length" class="sec">
              <h3>{{ t('ticket.plan') }}</h3>
              <ol class="plan"><li v-for="(p, i) in d.analysis.plan" :key="i">{{ tr(p) }}</li></ol>
            </div>
            <form class="sec" @submit.prevent="act.mutate('answers')">
              <h3>{{ t('ticket.questions') }}</h3>
              <div v-for="(q, i) in d.questions" :key="q.id" class="q">
                <p>{{ tr(q.text) }}</p>
                <div v-if="q.options.length" class="tabs" role="group">
                  <button v-for="o in q.options" :key="o" type="button" class="tab" :aria-pressed="answers[q.id].answer === o" @click="answers[q.id].answer = o">{{ tr(o) }}</button>
                </div>
                <input v-model="answers[q.id].answer" class="cfg-in" :placeholder="t('ticket.yourAnswer')" :aria-label="t('ticket.answerFor', { n: i + 1 })">
                <textarea v-model="answers[q.id].note" :placeholder="t('ticket.addDetails')" :aria-label="t('ticket.detailsFor', { n: i + 1 })" />
              </div>
              <KindPicker :ticket="tk" />
              <ModelPicker :ticket="tk" :stages="['coding', 'retry']" />
              <div class="actions">
                <button class="btn btn-p" type="submit" :disabled="left > 0 || act.isPending.value">{{ report ? t('ticket.startWriting') : t('ticket.startCoding') }}</button>
                <span class="hint">{{ left ? t('ticket.questionsLeft', { n: left }) : t('ticket.allAnswered') }}</span>
              </div>
            </form>
          </template>

          <!-- coding, held back by other tickets -->
          <template v-else-if="tk.state === 'coding' && tk.blockedBy?.length">
            <h2>{{ t('relations.waitingTitle') }}</h2>
            <p class="sub">{{ t('relations.waitingSub') }}</p>
            <ul class="tk-wait">
              <li v-for="b in tk.blockedBy" :key="b.key">
                <span class="badge" :class="b.type === 'conflicts' ? 'b-warn' : 'b-info'">{{ b.type === 'conflicts' ? t('relations.conflicts') : t('relations.waitsFor') }}</span>
                <RouterLink :to="`/tickets/${b.key}`">{{ b.key }}</RouterLink>
                <span class="tk-wait-title">{{ b.title }}</span>
                <StateBadge :state="b.state" />
              </li>
            </ul>
            <div class="actions"><button class="btn" type="button" @click="tab = 'order'">{{ t('relations.title') }}</button></div>
          </template>

          <!-- coding / testing -->
          <template v-else-if="tk.state === 'coding' || tk.state === 'testing'">
            <h2>{{ titleWithRev(report ? t('ticket.writingTitle') : tk.state === 'coding' ? t('ticket.codingTitle') : t('ticket.testingTitle')) }}</h2>
            <p class="sub">{{ report ? t('ticket.writingSub') : t('ticket.codingSub', { branch }) }}</p>
            <div class="sec">
              <dl class="facts">
                <div><dt>{{ t('ticket.factModel') }}</dt><dd>{{ d.effectiveModels ? MODEL_NAME[tk.revision > 0 ? d.effectiveModels.retry : d.effectiveModels.coding] : '—' }}</dd></div>
                <div><dt>{{ t('ticket.factTurns') }}</dt><dd>{{ tk.turns }}</dd></div>
                <div><dt>{{ t('ticket.factTurnLimit') }}</dt><dd>{{ d.maxTurns ?? '—' }}</dd></div>
                <div><dt>{{ t('ticket.factSession') }}</dt><dd>{{ sessionPct }}%</dd></div>
              </dl>
            </div>
            <div class="sec"><h3>{{ t('ticket.log') }}</h3><LiveLog :events="events" /></div>
            <div class="actions"><button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="confirmThen(t('ticket.stopConfirm', { key }), 'stop')">{{ t('ticket.stopRun') }}</button></div>
          </template>

          <!-- waiting_for_review -->
          <template v-else-if="tk.state === 'waiting_for_review'">
            <h2>{{ titleWithRev(t('ticket.reviewTitle')) }}</h2>
            <p class="sub">{{ reviewSub }}</p>
            <div v-if="result" class="sec">
              <dl class="facts">
                <div>
                  <dt>{{ t('ticket.factTests') }}</dt>
                  <dd :class="checksOk ? 'ok' : 'bad'">{{ result.checks.length ? t('ticket.checksPassed', { n: result.checks.filter((c) => c.exitCode === 0).length }) : t('ticket.noChecks') }}</dd>
                </div>
                <div><dt>{{ t('ticket.factChanged') }}</dt><dd>{{ t('ticket.changedValue', { n: totals.n, add: totals.add, del: totals.del }) }}</dd></div>
                <div><dt>{{ t('ticket.factTurns') }}</dt><dd>{{ tk.turns }}</dd></div>
                <div><dt>{{ t('ticket.kvBranch') }}</dt><dd>{{ branch }}</dd></div>
              </dl>
            </div>
            <div v-if="result?.summary" class="sec">
              <h3>{{ t('ticket.whatAgntsDid') }}</h3>
              <div class="summary"><p>{{ tr(result.summary) }}</p></div>
              <template v-if="result.notes.length">
                <h3>{{ t('ticket.notes') }}</h3>
                <ul><li v-for="(n, i) in result.notes" :key="i">{{ tr(n) }}</li></ul>
              </template>
            </div>
            <ModelPicker :ticket="tk" :stages="['retry', 'review']" />
            <div v-if="opensPr" class="sec">
              <h3>{{ t('ticket.assignTitle') }}</h3>
              <p class="hint" style="margin: 0 0 10px">{{ t('ticket.assignSub') }}</p>
              <p v-if="members.isPending.value" class="hint">{{ t('common.loading') }}</p>
              <p v-else-if="members.isError.value" class="hint">{{ t('ticket.assignError', { error: (members.error.value as Error)?.message || t('common.error') }) }}</p>
              <p v-else-if="!members.data.value?.length" class="hint">{{ t('ticket.assignNone') }}</p>
              <div v-else class="assignees" role="group" :aria-label="t('ticket.assignTitle')">
                <button
                  v-for="m in members.data.value"
                  :key="m.username"
                  type="button"
                  class="assignee"
                  :aria-pressed="assignees.includes(m.username)"
                  :title="m.role"
                  @click="toggleAssignee(m.username)"
                >
                  <img v-if="m.avatarUrl" class="mem-av" :src="m.avatarUrl" alt="" loading="lazy">
                  <span v-else class="mem-av mem-av-x" aria-hidden="true">{{ m.username.slice(0, 1).toUpperCase() }}</span>
                  {{ m.name || m.username }}
                </button>
              </div>
            </div>
            <div class="sec">
              <h3><label for="feedback">{{ t('ticket.feedback') }}</label></h3>
              <textarea id="feedback" v-model="feedback" :placeholder="t('ticket.feedbackHint')" />
            </div>
            <div class="actions">
              <button class="btn btn-p" type="button" :disabled="act.isPending.value" @click="approve">{{ t('ticket.approve') }}</button>
              <button class="btn" type="button" :disabled="!feedback.trim() || act.isPending.value" @click="act.mutate('request-changes')">{{ t('ticket.requestChanges') }}</button>
              <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('ticket.reject') }}</button>
            </div>
          </template>

          <!-- pushing -->
          <template v-else-if="tk.state === 'pushing'">
            <h2>{{ report ? t('ticket.deliveringTitle') : t('ticket.pushingTitle') }}</h2>
            <p class="sub">{{ report ? t('ticket.deliveringSub') : t('ticket.pushingSub') }}</p>
            <div class="sec"><LiveLog :events="events" /></div>
          </template>

          <!-- done -->
          <template v-else-if="tk.state === 'done' && report">
            <h2>{{ t('ticket.doneReportTitle') }}</h2>
            <div class="sec">
              <div class="help ok">
                <HiIcon name="check" />
                <p>{{ tk.postReport ? t('ticket.doneReportPosted', { key: tk.key }) : t('ticket.doneReport') }}</p>
              </div>
            </div>
            <ImplementReport v-if="tk.kind === 'plan' || tk.kind === 'bug'" :ticket="tk" :child-key="d.childKey" />
          </template>

          <template v-else-if="tk.state === 'done'">
            <h2>{{ t('ticket.doneTitle') }}</h2>
            <div class="sec">
              <div class="help ok">
                <HiIcon name="check" />
                <p v-if="isTask && tk.afterApprove === 'main' && !tk.prUrl">{{ t('ticket.doneMain', { repo: tk.repoName ?? '' }) }}</p>
                <p v-else>{{ t('ticket.donePr', { number: tk.prNumber ?? '', branch }) }}</p>
              </div>
              <p v-if="tk.mergedAt" class="hint" style="margin: 8px 0 0">{{ t('ticket.mergedAt', { time: ago(tk.mergedAt, locale) }) }}</p>
            </div>
            <div v-if="tk.prUrl" class="actions">
              <a class="btn" :href="tk.prUrl" target="_blank" rel="noopener">{{ t('ticket.openPr', { number: tk.prNumber ?? '' }) }}</a>
              <template v-if="!tk.mergedAt">
                <button class="btn" type="button" :disabled="act.isPending.value" @click="act.mutate('merged')">{{ t('relations.markMerged') }}</button>
                <span class="hint">{{ t('relations.markMergedHint') }}</span>
              </template>
            </div>
          </template>

          <!-- rejected -->
          <template v-else-if="tk.state === 'rejected'">
            <h2>{{ t('ticket.rejectedTitle') }}</h2>
            <p class="sub">{{ t('ticket.rejectedSub') }}</p>
          </template>

          <!-- failed -->
          <template v-else-if="tk.state === 'failed'">
            <h2>{{ t('ticket.failedTitle') }}</h2>
            <div class="sec">
              <div class="help bad"><HiIcon name="info" /><p style="white-space: pre-wrap">{{ tk.stopReason || t('ticket.failedUnknown') }}</p></div>
            </div>
            <KindPicker v-if="kindEditable" :ticket="tk" />
            <RepoPicker v-if="canChangeRepo" :ticket="tk" />
            <ModelPicker :ticket="tk" :stages="['retry']" />
            <div class="actions">
              <button class="btn btn-p" type="button" :disabled="act.isPending.value || (needsRepo(tk) && !tk.repoId)" @click="act.mutate('retry')">{{ t('ticket.retry') }}</button>
              <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('ticket.takeItMyself') }}</button>
            </div>
          </template>

          <!-- rate_limited -->
          <template v-else-if="tk.state === 'rate_limited'">
            <h2>{{ t('ticket.rateTitle') }}</h2>
            <div class="sec">
              <div class="help warn"><HiIcon name="info" /><p>{{ tk.stopReason || t('ticket.rateTitle') }}</p></div>
            </div>
            <RepoPicker v-if="canChangeRepo" :ticket="tk" />
            <div class="actions">
              <button class="btn btn-p" type="button" :disabled="act.isPending.value" @click="act.mutate('retry')">{{ t('ticket.resume') }}</button>
              <span class="hint">{{ t('ticket.rateHint', { pct: sessionPct }) }}</span>
            </div>
          </template>
        </section>

        <template v-if="tabs.length">
          <div class="tabs tk-tabs" role="group" :aria-label="t('ticket.tabsLabel')">
            <button v-for="x in tabs" :key="x.id" type="button" class="tab" :aria-pressed="activeTab === x.id" @click="tab = x.id">
              {{ x.label }}<span v-if="x.n" class="tk-n">{{ x.n }}</span>
            </button>
          </div>

          <!-- waiting_for_review: a report -->
          <section v-if="activeTab === 'decide'" class="card tk-panel">
            <h2>{{ titleWithRev(t('ticket.reviewReportTitle')) }}</h2>
            <p class="sub">{{ isTask ? t('ticket.reviewReportSub') : t('ticket.reviewReportSubJira') }}</p>
            <div v-if="result?.summary" class="sec">
              <div class="summary"><p>{{ tr(result.summary) }}</p></div>
              <template v-if="result.notes.length">
                <h3>{{ t('ticket.notes') }}</h3>
                <ul><li v-for="(n, i) in result.notes" :key="i">{{ tr(n) }}</li></ul>
              </template>
            </div>
            <ModelPicker :ticket="tk" :stages="['retry', 'review']" />
            <div v-if="!isTask" class="sec">
              <label class="check-row"><input v-model="postReport" type="checkbox">{{ t('ticket.postReport', { key: tk.key }) }}</label>
            </div>
            <div class="sec">
              <h3><label for="feedback">{{ t('ticket.feedback') }}</label></h3>
              <textarea id="feedback" v-model="feedback" :placeholder="t('ticket.feedbackReportHint')" />
            </div>
            <div class="actions">
              <button class="btn btn-p" type="button" :disabled="act.isPending.value" @click="approve">{{ t('ticket.approveReport') }}</button>
              <button class="btn" type="button" :disabled="!feedback.trim() || act.isPending.value" @click="act.mutate('request-changes')">{{ t('ticket.requestChanges') }}</button>
              <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('ticket.reject') }}</button>
            </div>
          </section>

          <section v-else-if="activeTab === 'report'" class="card tk-panel">
            <div class="ch"><h2>{{ t('ticket.report') }}</h2></div>
            <ReportView v-if="result?.report" :markdown="tr(result.report)" />
            <p v-else class="hint">{{ t('ticket.reportMissing') }}</p>
          </section>

          <section v-else-if="activeTab === 'review'" class="card tk-panel">
            <CodeReview :ticket="tk" :review="d.review" :feedback="feedback" :report="report" @add="addFeedback" @show="showFile" />
          </section>

          <section v-else-if="activeTab === 'changes' && result" class="card tk-panel">
            <div class="ch">
              <div>
                <h2>{{ t('ticket.changes') }}</h2>
                <p class="sub">{{ t('ticket.changedValue', { n: totals.n, add: totals.add, del: totals.del }) }} · {{ ago(result.createdAt, locale) }}</p>
              </div>
            </div>
            <div v-if="result.summary && tk.state !== 'waiting_for_review'" class="summary"><p>{{ tr(result.summary) }}</p></div>
            <div v-if="result.checks.length" class="sec">
              <h3>{{ t('ticket.checks') }}</h3>
              <dl class="kv">
                <template v-for="c in result.checks" :key="c.name">
                  <dt>{{ c.command }}</dt>
                  <dd :class="c.exitCode === 0 ? 'repo-ok' : 'repo-miss'">{{ c.exitCode === 0 ? t('ticket.passed') : t('ticket.failedCheck') }} · {{ (c.durationMs / 1000).toFixed(1) }}s</dd>
                </template>
              </dl>
            </div>
            <div class="sec">
              <h3>{{ t('ticket.diff') }}</h3>
              <DiffView v-for="(f, i) in result.files" :id="`diff-${f.path}`" :key="f.path" :file="f" :open="i === 0 && tk.state === 'waiting_for_review'" />
            </div>
          </section>

          <FollowUps v-else-if="activeTab === 'followUps'" :ticket="tk" :follow-ups="d.followUps" />

          <TicketRelations v-else-if="activeTab === 'order'" :ticket="tk" :relations="d.relations" :footprint="d.analysis?.footprint" />

          <section v-else-if="activeTab === 'answers'" class="card">
            <div class="ch"><div><h2>{{ t('ticket.answersTitle') }}</h2><p class="sub">{{ t('ticket.answersSub') }}</p></div></div>
            <div v-for="q in answered" :key="q.id" class="ans">
              <span class="qq">{{ tr(q.text) }}</span>
              <span><b>{{ tr(q.answer ?? '') }}</b><template v-if="q.note">. {{ q.note }}</template></span>
            </div>
          </section>

          <TicketLessons v-else-if="activeTab === 'lessons'" :ticket="tk" />

          <RunLog v-else-if="activeTab === 'log'" :events="events" :ticket-key="key" />
        </template>
      </div>

      <aside class="cfg-side tk-side">
        <section class="card">
          <div class="ch"><h2>{{ isTask ? t('ticket.sideTask') : t('ticket.sideTicket') }}</h2><span><StateBadge :state="tk.state" :kind="tk.kind" /> <span v-if="tk.mergedAt" class="badge b-ok">{{ t('ticket.merged') }}</span></span></div>
          <dl class="kv">
            <dt>{{ t('ticket.kvKey') }}</dt><dd>{{ tk.key }}</dd>
            <template v-if="tk.parentKey"><dt>{{ t('implement.implements') }}</dt><dd><RouterLink :to="`/tickets/${tk.parentKey}`">{{ tk.parentKey }}</RouterLink></dd></template>
            <template v-if="tk.followUpOf"><dt>{{ t('followUps.followUpOf') }}</dt><dd><RouterLink :to="`/tickets/${tk.followUpOf}`">{{ tk.followUpOf }}</RouterLink></dd></template>
            <template v-if="waitsFor.length">
              <dt>{{ t('relations.waitsFor') }}</dt>
              <dd><template v-for="(k2, i) in waitsFor" :key="k2"><template v-if="i">, </template><RouterLink :to="`/tickets/${k2}`">{{ k2 }}</RouterLink></template></dd>
            </template>
            <dt>{{ t('kind.title') }}</dt><dd><KindBadge :ticket="tk" /></dd>
            <dt>{{ t('ticket.kvSource') }}</dt><dd>{{ isTask ? t('ticket.srcTask') : t('ticket.srcJira') }}</dd>
            <dt>{{ t('ticket.kvRepo') }}</dt><dd>{{ tk.repoName ?? '—' }}</dd>
            <template v-if="isTask && !report"><dt>{{ t('ticket.kvAfter') }}</dt><dd>{{ tk.afterApprove === 'main' ? t('ticket.afterMain') : t('ticket.afterPr') }}</dd></template>
            <dt>{{ t('ticket.kvPriority') }}</dt><dd>{{ tk.priority }}</dd>
            <template v-if="!report"><dt>{{ t('ticket.kvBranch') }}</dt><dd>{{ branch }}</dd></template>
            <template v-if="tk.assignees?.length"><dt>{{ t('ticket.kvAssignees') }}</dt><dd>{{ tk.assignees.join(', ') }}</dd></template>
            <dt>{{ t('ticket.kvRevision') }}</dt><dd>{{ tk.revision }}</dd>
            <dt>{{ t('ticket.kvTurns') }}</dt><dd>{{ tk.turns }}</dd>
            <template v-if="d.effectiveModels">
              <dt>{{ t('ticket.kvCodingModel') }}</dt><dd>{{ MODEL_NAME[d.effectiveModels.coding] }}</dd>
              <dt>{{ t('ticket.kvRetryModel') }}</dt><dd>{{ MODEL_NAME[d.effectiveModels.retry] }}</dd>
            </template>
          </dl>
        </section>
        <SpendCard :spend="tk.spend" :stages="d.spendByStage ?? []" :report="report" />
        <section class="card">
          <div class="ch"><h2>{{ t('ticket.historyTitle') }}</h2></div>
          <ol v-if="d.history?.length" class="tl">
            <li v-for="(h, i) in [...d.history].reverse()" :key="i">
              <time>{{ histTime(h.at) }}</time>
              <span class="dot" :class="histDot(h.origin, h.state)" />
              <span>{{ t(stateKey(h.state, tk.kind)) }}<template v-if="h.message">: {{ h.message }}</template></span>
            </li>
          </ol>
          <p v-else class="hint">{{ t('ticket.historyEmpty') }}</p>
        </section>
        <UsageCard :usage="usage.data.value" title-key="ticket.usageTitle" />
      </aside>
    </div>
  </template>
</template>

<style scoped>
.tk-desc { white-space: pre-wrap; }
.tk-desc.folded { display: -webkit-box; -webkit-line-clamp: 3; line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }
.tk-more { margin-top: 4px; padding: 0; border: 0; background: none; font: inherit; font-size: 14px; font-weight: 700; color: var(--primary-ink); cursor: pointer; }
.tk-head-act { align-self: flex-start; }
.tk-lang { width: 200px; }
.tk-tr-note { display: flex; align-items: center; gap: 8px; margin: 10px 0 0; }
.tk-tabs { margin: 4px 0 -4px; }
.tk-n { margin-left: 6px; font-size: 12.5px; opacity: .7; font-variant-numeric: tabular-nums; }
.tk-panel > .sec:first-child { margin-top: 0; }
.tk-wait { list-style: none; margin: 12px 0 0; padding: 0; display: grid; gap: 8px; }
.tk-wait li { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.tk-wait-title { min-width: 0; overflow-wrap: anywhere; }
</style>
