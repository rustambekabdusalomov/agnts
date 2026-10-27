<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, nextTick, onBeforeUnmount, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import { isPullReview, isReport, isSwaggerTest, KIND_EDITABLE, needsRepo, pullHost, stateKey, TERMINAL, type Question, type ShotRef, type TicketKindChoice } from '../api/types'
import CheckBox from '../components/form/CheckBox.vue'
import TicketLessons from '../components/learn/TicketLessons.vue'
import StateBadge from '../components/StateBadge.vue'
import LiveLog from '../components/ticket/LiveLog.vue'
import MuseMeter from '../components/ticket/MuseMeter.vue'
import { museBudget } from '../components/ticket/museBudget'
import KindBadge from '../components/ticket/KindBadge.vue'
import KindPicker from '../components/ticket/KindPicker.vue'
import ImplementReport from '../components/ticket/ImplementReport.vue'
import FollowUps from '../components/ticket/FollowUps.vue'
import TicketRelations from '../components/ticket/TicketRelations.vue'
import CodeReview from '../components/ticket/CodeReview.vue'
import DesignRecord from '../components/ticket/DesignRecord.vue'
import RedFlags from '../components/ticket/RedFlags.vue'
import HarnessChecks from '../components/ticket/HarnessChecks.vue'
import ReplayButton from '../components/ticket/ReplayButton.vue'
import PreviewShots from '../components/ticket/PreviewShots.vue'
import ModelPicker from '../components/ticket/ModelPicker.vue'
import ReportView from '../components/ticket/ReportView.vue'
import SwaggerResults from '../components/swagger/SwaggerResults.vue'
import RepoPicker from '../components/ticket/RepoPicker.vue'
import RepoDiffs from '../components/ticket/RepoDiffs.vue'
import CommitMessages from '../components/ticket/CommitMessages.vue'
import TicketSection from '../components/ticket/TicketSection.vue'
import { useClosedSections } from '../composables/useClosedSections'
import TicketRepos from '../components/ticket/TicketRepos.vue'
import BranchName from '../components/ticket/BranchName.vue'
import TicketNumber from '../components/ticket/TicketNumber.vue'
import { filePath, isMultiRepo, ticketRepos } from '../components/repos/repoSet'
import ProgressTrack from '../components/ticket/ProgressTrack.vue'
import PullCard from '../components/ticket/PullCard.vue'
import ReviewDraftsPanel from '../components/pulls/ReviewDraftsPanel.vue'
import TicketPullComments from '../components/ticket/TicketPullComments.vue'
import TicketCommits from '../components/ticket/TicketCommits.vue'
import TicketDocuments from '../components/documents/TicketDocuments.vue'
import CiCard from '../components/ticket/CiCard.vue'
import { useRepoMembers } from '../components/repo/useRepoMembers'
import RunLog from '../components/ticket/RunLog.vue'
import SpendCard from '../components/ticket/SpendCard.vue'
import HiIcon from '../components/ui/HiIcon.vue'
import FileAttach from '../components/files/FileAttach.vue'
import FileList from '../components/files/FileList.vue'
import { useEventLog } from '../composables/useEventLog'
import { ago, pct } from '../composables/format'
import { livePoll } from '../composables/useLive'
import { useModels } from '../composables/useModels'
import { useUsage } from '../composables/useUsage'
import { provideTranslation, TRANSLATION_LANGS, type TranslationLang } from '../composables/useTranslation'
import InputSelect from '../components/form/InputSelect.vue'
import { useUi } from '../stores/ui'
import { askConfirm } from '../composables/useConfirm'
import WaitBanner from '../components/ticket/WaitBanner.vue'
import { useSession } from '../stores/session'
import { useWorkspace } from '../stores/workspace'
import CopyButton from '../components/ui/CopyButton.vue'

const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const qc = useQueryClient()
const ui = useUi()
const session = useSession()
const workspace = useWorkspace()
const key = computed(() => String(route.params.key))

const detail = useQuery({
  queryKey: computed(() => ['ticket', key.value]),
  queryFn: () => unwrap(api.GET('/tickets/{key}', { params: { path: { key: key.value } } })),
  refetchInterval: (q) => (q.state.data && TERMINAL.includes(q.state.data.ticket.state) ? false : livePoll(15_000)),
})
const d = computed(() => detail.data.value)
const tk = computed(() => d.value?.ticket)
// Making the ticket yours: per-member Claude mode then runs it on your account.
const takeOver = useMutation({
  mutationFn: () => unwrap(api.PUT('/tickets/{key}/member', { params: { path: { key: key.value } }, body: { userId: 0 } })),
  onSuccess: () => {
    ui.notify(t('queue.takenOver'))
    void qc.invalidateQueries({ queryKey: ['ticket', key.value] })
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
const isTask = computed(() => tk.value?.source === 'local')
// Plane tickets use their own wording where the page names the tracker.
const isPlane = computed(() => tk.value?.source === 'plane')
// A report kind (plan, analysis, bug): no branch, checks, diff or pull request.
const report = computed(() => !!tk.value && isReport(tk.value))
const swaggerTest = computed(() => !!tk.value && isSwaggerTest(tk.value))
// A review of someone else's pull request: approve merges it, reject
// dismisses agnts's review and leaves the pull request to you. A review
// asked for from the pull request page (afterApprove none) never merges:
// approving it finishes the review.
const pull = computed(() => !!tk.value && isPullReview(tk.value))
const finishOnly = computed(() => pull.value && tk.value?.afterApprove === 'none')
const host = computed(() => pullHost(tk.value?.pull?.url ?? tk.value?.prUrl))
// Why a review is dismissed; it teaches agnts how you review.
const dismissReason = ref('')
const kindEditable = computed(() => !!tk.value && KIND_EDITABLE.includes(tk.value.state) && !tk.value.prUrl && tk.value.resumeState !== 'pushing' && !isSwaggerTest(tk.value))
const { events } = useEventLog(key)
const models = useModels()

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

// Answers: option or free text, plus an optional note and files per
// question. A multiple-choice question takes several options, and the text
// is one more choice; the answer lists them one per line. They start from
// the unsent draft when there is one (see saveDrafts), else the answer.
type Draft = { answer: string; note: string; picked: string[]; files: number[]; uploading: boolean }
const answers = reactive<Record<number, Draft>>({})
// Each question's draft as last sent (see saveDrafts).
const savedDraft: Record<number, string> = {}
watch(
  () => d.value?.questions,
  (qs) => {
    for (const q of qs ?? []) {
      if (answers[q.id]) continue
      const from = (q.answer == null && q.draft) || { answer: q.answer ?? '', note: q.note, attachments: [] }
      const lines = q.multiple ? from.answer.split('\n').filter(Boolean) : []
      answers[q.id] = {
        answer: q.multiple ? lines.filter((l) => !q.options.includes(l)).join(' ') : from.answer,
        note: from.note,
        picked: lines.filter((l) => q.options.includes(l)),
        files: from.attachments.map((a) => a.id),
        uploading: false,
      }
      savedDraft[q.id] = draftKey(q)
    }
  },
  { immediate: true },
)
function answerOf(q: Question): string {
  const a = answers[q.id]
  if (!a) return ''
  if (!q.multiple) return a.answer.trim()
  return [...q.options.filter((o) => a.picked.includes(o)), a.answer.trim()].filter(Boolean).join('\n')
}
function togglePick(q: Question, o: string) {
  const a = answers[q.id]
  a.picked = a.picked.includes(o) ? a.picked.filter((x) => x !== o) : [...a.picked, o]
}
const left = computed(() => (d.value?.questions ?? []).filter((q) => !answerOf(q)).length)

// Unsent answers are saved as they are typed, so closing the tab or the
// app loses nothing; they come back on any device, for anyone answering.
// Only the questions changed since the last save are sent.
const draftState = ref<'' | 'saving' | 'saved' | 'failed'>('')
let draftTimer: ReturnType<typeof setTimeout> | undefined
function draftOf(q: Question) {
  const a = answers[q.id]
  return { questionId: q.id, answer: answerOf(q), note: a.note.trim() || undefined, attachments: a.files.length ? a.files : undefined }
}
function draftKey(q: Question) {
  return JSON.stringify(draftOf(q))
}
function saveDrafts(ticketKey: string, qs: Question[], keepalive = false) {
  clearTimeout(draftTimer)
  draftTimer = undefined
  const changed = qs.filter((q) => answers[q.id] && draftKey(q) !== savedDraft[q.id])
  if (!changed.length) return
  const sent = changed.map((q) => [q.id, draftKey(q)] as const)
  for (const [id, k] of sent) savedDraft[id] = k
  draftState.value = 'saving'
  const body = { answers: changed.map(draftOf) }
  // Browsers refuse a keepalive request over 64 KB; a bigger one is sent
  // plainly and may not make it out of a closing page.
  keepalive &&= JSON.stringify(body).length < 60_000
  unwrap(api.PUT('/tickets/{key}/answers/draft', { params: { path: { key: ticketKey } }, body, keepalive }))
    .then(() => {
      if (draftState.value === 'saving') draftState.value = 'saved'
    })
    .catch((e) => {
      for (const [id, k] of sent) if (savedDraft[id] === k) delete savedDraft[id]
      // 409: the questions are answered or gone; nothing to keep.
      if (e instanceof HttpError && e.status === 409) {
        draftState.value = ''
        return
      }
      draftState.value = 'failed'
      // Only a lost connection or a server error can go better next time,
      // and only while the page is open.
      const retry = !(e instanceof HttpError) || e.status >= 500
      if (retry && !gone && !draftTimer) {
        // Kept as waiting, so leaving the page tries once more.
        draftFor ??= { key: ticketKey, qs }
        draftTimer = setTimeout(flushDrafts, 5000)
      }
    })
}
// Set on unmount: the last save there must not schedule another.
let gone = false
// What a pending save is for: the ticket open when the typing happened.
let draftFor: { key: string; qs: Question[] } | undefined
function flushDrafts(keepalive = false) {
  if (draftFor) saveDrafts(draftFor.key, draftFor.qs, keepalive)
  draftFor = undefined
}
watch(
  () => (tk.value?.state === 'waiting_for_answers' && workspace.canEdit ? (d.value?.questions ?? []).map((q) => (answers[q.id] ? draftKey(q) : '')).join('\u0000') : ''),
  (now, was) => {
    if (!now || now === was || act.isPending.value) return
    draftFor = { key: key.value, qs: d.value?.questions ?? [] }
    clearTimeout(draftTimer)
    draftTimer = setTimeout(flushDrafts, 800)
  },
)
// Leaving the ticket or the page saves what is waiting.
watch(key, () => flushDrafts(), { flush: 'sync' })
const onPageHide = () => flushDrafts(true)
window.addEventListener('pagehide', onPageHide)
onBeforeUnmount(() => {
  window.removeEventListener('pagehide', onPageHide)
  gone = true
  flushDrafts(true)
  clearTimeout(draftTimer)
})
const answersUploading = computed(() => Object.values(answers).some((a) => a.uploading))
const answered = computed(() => (d.value?.questions ?? []).filter((q) => q.answer))
// The questions as plain text, to paste into a chat for whoever can answer.
// "Q1.", not "1.": chat editors read "1." as a list and restart it at 1
// after each question's options.
const questionsText = computed(() => {
  if (!tk.value || !d.value) return ''
  const qs = d.value.questions.map((q, i) => {
    const opts = q.options.map((o) => `   - ${tr.value(o)}`)
    return [`Q${i + 1}. ${tr.value(q.text)}${q.multiple ? ` (${t('ticket.pickAny')})` : ''}`, ...opts].join('\n')
  })
  return [`${tk.value.key}: ${tr.value(tk.value.title)}`, '', ...qs].join('\n')
})
// The chosen options of a multiple-choice answer, each translated.
const answerText = (q: Question) => (q.answer ?? '').split('\n').map((l) => tr.value(l)).join(', ')
const files = computed(() => d.value?.attachments ?? [])
const filesOf = (purpose: string, questionId?: number) =>
  files.value.filter((a) => a.purpose === purpose && (questionId === undefined || a.questionId === questionId))

const feedback = ref('')
// Preview screenshots the feedback points at; the coding run gets them.
const feedbackShots = ref<ShotRef[]>([])
// Files that go with the feedback (mockups, logs); the coding run reads them.
const feedbackFiles = ref<number[]>([])
const feedbackUploading = ref(false)
const feedbackAttach = ref<InstanceType<typeof FileAttach> | null>(null)
// How to get past a failure; the retried coding run gets it with the error.
const retryNote = ref('')
const retryFiles = ref<number[]>([])
const retryUploading = ref(false)
// What to do differently when a rejected ticket is continued.
const continueNote = ref('')
const continueFiles = ref<number[]>([])
const continueUploading = ref(false)
const MAX_FEEDBACK_SHOTS = 6
const notice = ref('')

// Assignees for the pull request agnts opens on approval (not for tasks that
// push straight to the default branch). Members load only while reviewing.
const opensPr = computed(() => !report.value && !pull.value && !(isTask.value && tk.value?.afterApprove === 'main'))
// Reports reach the tracker issue only when the reviewer ticks this.
const postReport = ref(false)
// Coding runs go to review without the checks; retry and requested
// changes send it, starting from the ticket's own setting.
const skipChecks = ref(false)
// The repository whose diffs the Changes tab shows, in a ticket of several.
const diffRepo = ref('')
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
    skipChecks.value = !!tk.value?.skipChecks
    diffRepo.value = ''
  },
  { immediate: true },
)

// The analysis disagreed with a kind someone chose: offer the switch while
// the kind can still change.
const kindWarning = computed(() => {
  const ev = [...events.value].reverse().find((e) => e.type === 'kind_changed')
  if (!ev || ev.level !== 'warn' || !tk.value || ev.data.to === tk.value.kind || ev.data.from !== tk.value.kind) return null
  return { message: ev.message, to: ev.data.to as TicketKindChoice }
})
const switchKind = useMutation({
  mutationFn: (kind: TicketKindChoice) => unwrap(api.PUT('/tickets/{key}/kind', { params: { path: { key: key.value } }, body: { kind } })),
  onSettled: () => qc.invalidateQueries({ queryKey: ['ticket', key.value] }),
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
function toggleAssignee(u: string) {
  assignees.value = assignees.value.includes(u) ? assignees.value.filter((x) => x !== u) : [...assignees.value, u]
}

type Action = 'answers' | 'approve' | 'request-changes' | 'reject' | 'retry' | 'continue' | 'start-over' | 'start' | 'stop' | 'merged'
const act = useMutation({
  mutationFn: (a: Action) => {
    const path = { params: { path: { key: key.value } } }
    switch (a) {
      case 'answers':
        // Sending the answers clears their drafts.
        clearTimeout(draftTimer)
        draftFor = undefined
        return unwrap(
          api.PUT('/tickets/{key}/answers', {
            ...path,
            body: {
              answers: (d.value?.questions ?? []).map((q) => ({
                questionId: q.id,
                answer: answerOf(q),
                note: answers[q.id].note.trim() || undefined,
                attachments: answers[q.id].files.length ? answers[q.id].files : undefined,
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
        return unwrap(
          api.POST('/tickets/{key}/request-changes', {
            ...path,
            body: {
              feedback: feedback.value.trim(),
              shots: feedbackShots.value.length ? feedbackShots.value : undefined,
              attachments: feedbackFiles.value.length ? feedbackFiles.value : undefined,
              skipChecks: skipChecks.value,
            },
          }),
        )
      case 'reject':
        return unwrap(api.POST('/tickets/{key}/reject', { ...path, body: pull.value && dismissReason.value.trim() ? { reason: dismissReason.value.trim() } : {} }))
      case 'retry':
        return unwrap(
          api.POST('/tickets/{key}/retry', {
            ...path,
            body: {
              note: retryNote.value.trim() || undefined,
              attachments: retryFiles.value.length ? retryFiles.value : undefined,
              skipChecks: skipChecks.value,
            },
          }),
        )
      case 'continue':
        return unwrap(
          api.POST('/tickets/{key}/continue', {
            ...path,
            body: continueTakesNote.value
              ? { note: continueNote.value.trim() || undefined, attachments: continueFiles.value.length ? continueFiles.value : undefined }
              : {},
          }),
        )
      case 'start-over':
        return unwrap(api.POST('/tickets/{key}/start-over', path))
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
    if (a === 'request-changes') {
      feedback.value = ''
      feedbackShots.value = []
      feedbackFiles.value = []
    }
    if (a === 'reject') dismissReason.value = ''
    if (a === 'retry') {
      retryNote.value = ''
      retryFiles.value = []
    }
    if (a === 'continue') {
      continueNote.value = ''
      continueFiles.value = []
    }
  },
  onError: (e) => {
    notice.value = e instanceof HttpError && e.status === 409 ? t('ticket.conflict')
      : e instanceof HttpError && e.status === 400 && /credential/i.test(e.message) ? t('harnessTicket.secretsNeeded')
        : e instanceof HttpError ? e.message : t('common.error')
  },
  onSettled: () => qc.invalidateQueries({ queryKey: ['ticket', key.value] }),
})

const del = useMutation({
  mutationFn: () => unwrap(api.DELETE('/tasks/{key}', { params: { path: { key: key.value } } })),
  onSuccess: () => router.push({ name: 'tasks' }),
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

// A newer version of the issue arrived after agnts started: restart with
// it, or keep working on the current one.
const trackerName = computed(() => (tk.value?.source === 'plane' ? 'Plane' : 'Jira'))
const version = useMutation({
  mutationFn: (what: 'restart' | 'keep') =>
    unwrap(
      what === 'restart'
        ? api.POST('/tickets/{key}/restart-update', { params: { path: { key: key.value } } })
        : api.POST('/tickets/{key}/keep-version', { params: { path: { key: key.value } } }),
    ),
  onSuccess: (_, what) => {
    ui.notify(what === 'restart' ? t('ticket.updateRestarted', { key: key.value }) : t('ticket.updateKept'))
    void qc.invalidateQueries({ queryKey: ['ticket', key.value] })
    void qc.invalidateQueries({ queryKey: ['tickets'] })
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
async function confirmRestart() {
  const label = t('ticket.updateRestart')
  const message = t('ticket.updateRestartConfirm', { key: key.value, source: trackerName.value })
  if (await askConfirm({ title: label, message, confirmLabel: label, danger: true })) version.mutate('restart')
}

// agnts's review comments are drafts kept here: only the accepted ones are
// published on the pull request, as often as people accept more.
const drafts = useQuery({
  queryKey: computed(() => ['drafts', key.value]),
  queryFn: () => unwrap(api.GET('/tickets/{key}/drafts', { params: { path: { key: key.value } } })),
  enabled: computed(() => pull.value && !!d.value?.review),
})
const draftsLocked = computed(() => tk.value?.state === 'rejected' || (!!tk.value?.pull?.state && tk.value.pull.state !== 'open'))

// The pull requests whose conversation the page shows: the one a review
// reviews, or the open ones agnts opened.
const prThreads = computed(() => {
  const k = tk.value
  if (!k) return []
  if (pull.value) return k.repoId && k.pull?.number ? [{ repoId: k.repoId, number: k.pull.number, url: k.pull.url }] : []
  const rs = (k.repos ?? []).filter((r) => r.prNumber && !r.closedAt)
  if (!rs.length && k.repoId && k.prNumber) return [{ repoId: k.repoId, number: k.prNumber, url: k.prUrl }]
  return rs.map((r) => ({ repoId: r.repoId, number: r.prNumber ?? 0, url: r.prUrl, repoName: rs.length > 1 ? r.repoName : undefined }))
})

const ACTION_LABEL = { approve: 'ticket.approve', reject: 'ticket.reject', stop: 'ticket.stopRun' } as const
async function confirmThen(msg: string, a: keyof typeof ACTION_LABEL) {
  const label = a === 'approve' && finishOnly.value ? t('drafts.finishBtn') : a === 'approve' && pull.value ? t('reviews.mergeBtn') : a === 'reject' && pull.value ? t('reviews.dismissBtn', { host: host.value }) : a === 'approve' && report.value ? t('ticket.approveReport') : t(ACTION_LABEL[a])
  if (await askConfirm({ title: label, message: msg, confirmLabel: label, danger: a !== 'approve' })) act.mutate(a)
}
function approve() {
  const t0 = tk.value
  if (!t0) return
  if (finishOnly.value) {
    confirmThen(t('drafts.finishConfirm', { number: t0.pull?.number ?? t0.prNumber ?? '' }), 'approve')
    return
  }
  if (pull.value) {
    const method = t(`reviews.merge_${settingsMerge.value}`)
    confirmThen(t('reviews.mergeConfirm', { number: t0.pull?.number ?? t0.prNumber ?? '', host: host.value, method }), 'approve')
    return
  }
  if (report.value) {
    confirmThen(
      postReport.value ? t(isPlane.value ? 'ticket.approveReportPostConfirmPlane' : 'ticket.approveReportPostConfirm', { key: t0.key }) : t('ticket.approveReportConfirm'),
      'approve',
    )
    return
  }
  let msg = opensPr.value ? t('ticket.approveConfirm', { branch: t0.branch }) : t('ticket.approveMainConfirm')
  if (opensPr.value && assignees.value.length) msg += '\n\n' + t('ticket.approveAssignees', { names: assignees.value.join(', ') })
  confirmThen(msg, 'approve')
}
// A rejected ticket goes back where it stopped (the server's continueTo); a
// note sends one rejected at review to coding first.
const CONTINUE_HINT = {
  new: 'ticket.continueToNew', waiting_for_answers: 'ticket.continueToAnswers', coding: 'ticket.continueToCoding',
  waiting_for_review: 'ticket.continueToReview', failed: 'ticket.continueToFailed', rate_limited: 'ticket.continueToRateLimited',
} as const
const continueTo = computed(() => tk.value?.continueTo)
const continueHint = computed(() => {
  const to = continueTo.value
  return to && to in CONTINUE_HINT ? t(CONTINUE_HINT[to as keyof typeof CONTINUE_HINT]) : ''
})
// Only a stage that runs Claude next can take a note.
const continueTakesNote = computed(() => ['new', 'coding', 'waiting_for_review'].includes(continueTo.value ?? ''))
async function startOver() {
  const label = t('ticket.startOver')
  if (await askConfirm({ title: label, message: t('ticket.startOverConfirm', { key: key.value }), confirmLabel: label, danger: true })) act.mutate('start-over')
}
function reject() {
  if (pull.value) confirmThen(t('reviews.dismissConfirm', { number: tk.value?.pull?.number ?? '', host: host.value }), 'reject')
  else confirmThen(t(tk.value?.state === 'pushing' ? 'ticket.rejectPushingConfirm' : 'ticket.rejectConfirm', { key: key.value }), 'reject')
}
// The merge method agnts uses, for the merge confirmation.
const settingsQuery = useQuery({ queryKey: ['settings'], queryFn: () => unwrap(api.GET('/settings')), enabled: pull })
const settingsMerge = computed(() => settingsQuery.data.value?.pullReviews?.mergeMethod ?? 'merge')
async function deleteTask() {
  if (await askConfirm({ title: t('ticket.delete'), message: t('ticket.deleteConfirm', { key: key.value }), confirmLabel: t('ticket.delete'), danger: true })) del.mutate()
}

// Lines from agnts's code review go to the end of the feedback box.
function addFeedback(line: string) {
  feedback.value = feedback.value.trim() ? `${feedback.value.trimEnd()}\n${line}` : line
}
// A screenshot goes to the feedback as a line to finish, and travels with it.
function addShot(line: string, ref: ShotRef) {
  if (feedbackShots.value.length >= MAX_FEEDBACK_SHOTS) {
    ui.notify(t('preview.tooMany', { n: MAX_FEEDBACK_SHOTS }))
    return
  }
  addFeedback(line)
  feedbackShots.value = [...feedbackShots.value, ref]
  nextTick(() => document.getElementById('feedback')?.focus())
}
function dropShot(i: number) {
  feedbackShots.value = feedbackShots.value.filter((_, j) => j !== i)
}
const shotName = (r: ShotRef) => d.value?.preview?.shots.find((s) => s.id === r.shotId)?.name ?? r.shotId
const sections = useClosedSections()
// Opens a changed file's diff and scrolls to it.
async function showFile(path: string) {
  tab.value = 'changes'
  if (!sections.isOpen('diff')) sections.toggle('diff') // closed earlier: the file is in it
  await nextTick()
  // In several repositories a path may come without its folder.
  const f = result.value?.files.find((x) => filePath(x) === path) ?? result.value?.files.find((x) => x.path === path)
  if (f) {
    diffRepo.value = f.repo ?? ''
    await nextTick()
  }
  const el = document.getElementById(`diff-${f ? filePath(f) : path}`) as HTMLDetailsElement | null
  if (!el) return
  el.open = true
  el.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

const result = computed(() => d.value?.result)
// Lines flagged as possible credentials: approving needs a person to say
// they are not real ones, once per revision.
const secretFlags = computed(() => (result.value?.redFlags ?? []).filter((f) => f.kind === 'secret' || f.kind === 'env_file').length)
const secretsAcked = ref('')
const ackKey = computed(() => `${key.value}@${tk.value?.revision ?? 0}`)
const needsAck = computed(() => secretFlags.value > 0 && !pull.value && !report.value && secretsAcked.value !== ackKey.value)
const ackSecrets = useMutation({
  mutationFn: () => unwrap(api.POST('/tickets/{key}/secrets-ack', { params: { path: { key: key.value } } })),
  onSuccess: () => {
    secretsAcked.value = ackKey.value
    notice.value = ''
    ui.notify(t('harnessTicket.secretsDone'))
    void qc.invalidateQueries({ queryKey: ['ticket', key.value] })
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
// The tickets this one waits for (active dependencies not merged yet).
const waitsFor = computed(() =>
  (d.value?.relations?.items ?? []).filter((r) => r.status === 'active' && r.direction === 'waits_for' && !r.other.landed).map((r) => r.other.key),
)
// A ticket in several repositories: names for the texts, its pull requests,
// and its changed files by repository.
const multi = computed(() => !!tk.value && isMultiRepo(tk.value))
const repoNames = computed(() => (tk.value ? ticketRepos(tk.value).map((r) => r.repoName).join(', ') : ''))
const prs = computed(() => (tk.value?.repos ?? []).filter((r) => r.prUrl))
const totals = computed(() => {
  const files = result.value?.files ?? []
  return { n: files.length, add: files.reduce((a, f) => a + f.add, 0), del: files.reduce((a, f) => a + f.del, 0) }
})
const checksOk = computed(() => (result.value?.checks ?? []).every((c) => c.exitCode === 0))

// Everything that is not the current decision sits behind tabs under the
// state card, so the page is one screen of "what now" plus one open panel
// instead of every section stacked. The first available tab opens by default.
// The ticket's details, token spend and history come last, as tabs rather
// than a side column, so the main panel keeps the full width.
type Tab = 'api' | 'decide' | 'report' | 'review' | 'preview' | 'changes' | 'followUps' | 'order' | 'answers' | 'lessons' | 'documents' | 'log' | 'task' | 'spend' | 'history'
const tabs = computed(() => {
  const k = tk.value
  if (!k) return []
  const out: { id: Tab; label: string; n?: number }[] = []
  if (swaggerTest.value && !['coding', 'new'].includes(k.state)) out.push({ id: 'api', label: t('swagger.tab') })
  if (reviewingReport.value) out.push({ id: 'decide', label: t('ticket.reviewReportTitle') })
  if (report.value && (k.state === 'waiting_for_review' || (k.state === 'done' && result.value?.report))) out.push({ id: 'report', label: t('ticket.report') })
  if (k.state === 'waiting_for_review' || (pull.value && d.value?.review)) out.push({ id: 'review', label: t('ticket.tabReview'), n: d.value?.review?.revision === k.revision ? d.value.review.findings.length || undefined : undefined })
  if (k.state === 'waiting_for_review' && !report.value && (k.canPreview || d.value?.preview)) {
    const pv = d.value?.preview
    out.push({ id: 'preview', label: t('preview.tab'), n: pv?.revision === k.revision ? pv.issues.length || undefined : undefined })
  }
  if (!report.value && result.value?.files.length) out.push({ id: 'changes', label: t('ticket.changes'), n: totals.value.n })
  if (d.value?.followUps && !pull.value) out.push({ id: 'followUps', label: t('ticket.tabFollowUps') })
  const rels = d.value?.relations
  if (!pull.value && (k.repoId || rels?.items.length)) {
    const waiting = rels?.items.filter((r) => r.status === 'proposed').length
    out.push({ id: 'order', label: t('relations.tab'), n: waiting || undefined })
  }
  if (answered.value.length && !['new', 'analyzing', 'waiting_for_answers'].includes(k.state)) out.push({ id: 'answers', label: t('ticket.tabAnswers'), n: answered.value.length })
  if (k.state === 'done' && !pull.value) out.push({ id: 'lessons', label: t('ticket.tabLessons') })
  out.push({ id: 'documents', label: t('documents.ticketTitle') })
  if (events.value.length) out.push({ id: 'log', label: t('ticket.runLog') })
  out.push({ id: 'task', label: isTask.value ? t('ticket.sideTask') : t('ticket.sideTicket') })
  out.push({ id: 'spend', label: t('spend.title') })
  out.push({ id: 'history', label: t('ticket.historyTitle'), n: d.value?.history?.length || undefined })
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
  feedbackShots.value = []
})
const branch = computed(() => tk.value?.branch || `agnts/${key.value}`)
// The primary repository's branch can be renamed until it is pushed.
const canRenameBranch = computed(() => !!tk.value?.repos?.[0]?.canRenameBranch)
const reviewSub = computed(() => {
  if (isTask.value && tk.value?.afterApprove === 'main') return t('ticket.reviewSubMain')
  if (isTask.value) return t('ticket.reviewSubPr', { branch: branch.value })
  return t(isPlane.value ? 'ticket.reviewSubPlane' : 'ticket.reviewSubJira', { branch: branch.value })
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
  <div class="tk-top">
    <RouterLink class="back-btn" :to="backTo"><HiIcon name="back" />{{ isTask ? t('nav.tasks') : t('ticket.back') }}</RouterLink>
    <div v-if="d && tk" class="tk-lang">
      <InputSelect v-model="translation.lang.value" :options="langOptions" :label="t('ticket.translate')" :placeholder="t('ticket.translate')" />
    </div>
  </div>

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
        <FileList :files="filesOf('ticket')" />
        <FileList :files="filesOf('retry')" :label="t('files.fromRetry')" />
        <FileList :files="filesOf('feedback')" :label="t('files.fromFeedback')" />
      </div>
      <div v-if="isTask && tk.state === 'new' && workspace.canEdit" class="actions tk-head-act" style="margin: 0">
        <button class="btn btn-d" type="button" :disabled="del.isPending.value" @click="deleteTask">{{ t('ticket.delete') }}</button>
      </div>
    </div>
    <p v-if="translation.lang.value && translation.query.isFetching.value" class="hint tk-tr-note" role="status">
      <span class="spin" aria-hidden="true" />{{ t('ticket.translating') }}
    </p>
    <p v-else-if="translateError" class="ferr" role="alert">{{ translateError }}</p>

    <p v-if="notice" class="ferr" role="alert">{{ notice }}</p>
    <WaitBanner :ticket="tk" />
    <div v-if="tk.replayOf" class="help" style="margin-bottom: 14px">
      <HiIcon name="info" />
      <p>
        {{ t('replay.banner') }}
        <RouterLink :to="{ name: 'ticket', params: { key: tk.replayOf } }">{{ tk.replayOf }}</RouterLink>
      </p>
    </div>
    <section v-if="tk.trackerUpdate" class="card tk-update">
      <div class="help warn">
        <HiIcon name="info" />
        <div>
          <p><b>{{ t('ticket.updateTitle', { source: trackerName }) }}</b></p>
          <p>{{ t('ticket.updateSub') }}</p>
        </div>
      </div>
      <div class="sec">
        <h3>{{ t('ticket.updateNow', { when: new Date(tk.trackerUpdate.at).toLocaleString() }) }}</h3>
        <p class="tk-update-title">{{ tk.trackerUpdate.title }}</p>
        <p class="tk-update-desc">{{ tk.trackerUpdate.description || '—' }}</p>
      </div>
      <p v-if="tk.prUrl" class="hint">{{ t('ticket.updatePushed') }}</p>
      <div v-if="workspace.canEdit" class="actions" style="margin: 0">
        <button class="btn btn-p" type="button" :disabled="!!tk.prUrl || version.isPending.value" @click="confirmRestart">{{ t('ticket.updateRestart') }}</button>
        <button class="btn" type="button" :disabled="version.isPending.value" @click="version.mutate('keep')">{{ t('ticket.updateKeep') }}</button>
      </div>
    </section>
    <div v-if="kindWarning" class="help warn" style="margin-bottom: 14px">
      <HiIcon name="info" />
      <p>
        {{ kindWarning.message }}
        <button
          v-if="kindEditable && workspace.canEdit"
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

    <div class="col">
      <CiCard v-if="tk.source === 'ci'" :ticket-key="tk.key" />
      <section class="card"><ProgressTrack :ticket="tk" :spend="d.spendByStage" /></section>

      <section v-if="!reviewingReport" class="card tk-stage">
        <!-- outside the fieldset: a viewer can copy the questions too -->
        <CopyButton v-if="!pull && tk.state === 'waiting_for_answers'" class="q-copy" :text="questionsText" :label="t('ticket.copyQuestions')" />
        <fieldset class="ro-fs" :disabled="!workspace.canEdit">
          <PullCard v-if="pull" :ticket="tk" />
          <p v-if="pull && tk.pull?.postedAt" class="hint sec">{{ t('reviews.posted', { host, when: new Date(tk.pull.postedAt).toLocaleString() }) }}</p>
          <!-- a pull request review: queued, fetching, reviewing, ready, merging, merged, dismissed -->
          <template v-if="pull && ['new', 'analyzing', 'coding'].includes(tk.state)">
            <h2>{{ titleWithRev(tk.state === 'new' ? t('ticket.queuedTitle') : tk.state === 'analyzing' ? t('reviews.fetchingTitle') : t('reviews.reviewingTitle')) }}</h2>
            <p class="sub">{{ tk.state === 'new' ? t('reviews.queuedSub') : t('reviews.reviewingSub') }}</p>
            <div v-if="tk.state !== 'new'" class="sec"><MuseMeter :events="events" style="margin-bottom: 10px" /><LiveLog :events="events" /></div>
            <div class="actions">
              <button v-if="tk.state !== 'new'" class="btn btn-d" type="button" :disabled="act.isPending.value" @click="confirmThen(t('ticket.stopConfirm', { key }), 'stop')">{{ t('ticket.stopRun') }}</button>
              <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('reviews.dismissBtn', { host }) }}</button>
            </div>
          </template>
          <template v-else-if="pull && tk.state === 'waiting_for_review'">
            <h2>{{ titleWithRev(t('reviews.readyTitle')) }}</h2>
            <p class="sub">{{ finishOnly ? t('drafts.readySub', { host }) : t('reviews.readySub', { host }) }}</p>
            <div v-if="d.review?.summary" class="sec"><div class="summary"><p>{{ tr(d.review.summary) }}</p></div></div>
            <div v-if="result" class="sec">
              <dl class="facts">
                <div><dt>{{ t('ticket.factChanged') }}</dt><dd>{{ t('ticket.changedValue', { n: totals.n, add: totals.add, del: totals.del }) }}</dd></div>
                <div><dt>{{ t('ticket.factTurns') }}</dt><dd>{{ tk.turns }}</dd></div>
              </dl>
            </div>
            <div class="sec">
              <h3><label for="feedback">{{ t('reviews.noteLabel') }}</label></h3>
              <textarea id="feedback" v-model="feedback" maxlength="4000" :placeholder="t('reviews.noteHint')" @paste="feedbackAttach?.pasted($event)" />
              <FileAttach ref="feedbackAttach" v-model="feedbackFiles" v-model:busy="feedbackUploading" />
            </div>
            <div class="sec">
              <h3><label for="dismiss-reason">{{ t('reviews.dismissReason') }}</label></h3>
              <input id="dismiss-reason" v-model="dismissReason" class="cfg-in" maxlength="4000" :placeholder="t('reviews.dismissReasonHint')">
            </div>
            <div class="actions">
              <button class="btn btn-p" type="button" :disabled="act.isPending.value" @click="approve">{{ finishOnly ? t('drafts.finishBtn') : t('reviews.mergeBtn') }}</button>
              <button class="btn" type="button" :disabled="!feedback.trim() || feedbackUploading || act.isPending.value" @click="act.mutate('request-changes')">{{ t('reviews.rereviewBtn') }}</button>
              <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('reviews.dismissBtn', { host }) }}</button>
            </div>
          </template>
          <template v-else-if="pull && tk.state === 'pushing'">
            <h2>{{ t('reviews.mergingTitle') }}</h2>
            <div class="sec"><LiveLog :events="events" /></div>
            <div class="actions"><button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('reviews.dismissBtn', { host }) }}</button></div>
          </template>
          <template v-else-if="pull && tk.state === 'done'">
            <h2>{{ finishOnly ? t('drafts.finishedTitle') : t('reviews.mergedTitle') }}</h2>
            <div class="sec">
              <div class="help ok">
                <HiIcon name="check" />
                <p>{{ finishOnly ? t('drafts.finishedSub', { number: tk.pull?.number ?? tk.prNumber ?? '' }) : t('reviews.mergedSub', { number: tk.pull?.number ?? tk.prNumber ?? '' }) }}</p>
              </div>
            </div>
          </template>
          <template v-else-if="pull && tk.state === 'rejected'">
            <h2>{{ tk.mergedAt ? t('reviews.mergedTitle') : t('reviews.dismissedTitle') }}</h2>
            <p class="sub">{{ tk.stopReason || t('reviews.dismissedSub', { host }) }}</p>
          </template>
          <!-- new -->
          <template v-else-if="tk.state === 'new'">
            <h2>{{ t('ticket.queuedTitle') }}</h2>
            <p class="sub">{{ tk.held ? t('ticket.heldSub') : report ? t('ticket.queuedSubReport') : t('ticket.queuedSub') }}</p>
            <KindPicker :ticket="tk" />
            <RepoPicker :ticket="tk" />
            <ModelPicker :ticket="tk" :stages="['analyze', 'coding']" />
            <div class="actions">
              <button v-if="tk.held" class="btn btn-p" type="button" :disabled="act.isPending.value" @click="act.mutate('start')">{{ t('ticket.start') }}</button>
              <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('ticket.reject') }}</button>
              <span v-if="tk.held" class="hint">{{ t('ticket.startHint') }}</span>
            </div>
          </template>

          <!-- analyzing -->
          <template v-else-if="tk.state === 'analyzing'">
            <h2>{{ tk.repoId ? t('ticket.analyzingTitle') : t('ticket.analyzingTitleNoRepo') }}</h2>
            <p class="sub">{{ tk.repoId ? t('ticket.analyzingSub', { repo: repoNames }) : t('ticket.analyzingSubNoRepo') }}</p>
            <div class="sec"><MuseMeter :events="events" style="margin-bottom: 10px" /><LiveLog :events="events" /></div>
            <div class="actions">
              <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="confirmThen(t('ticket.stopConfirm', { key }), 'stop')">{{ t('ticket.stopRun') }}</button>
              <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('ticket.reject') }}</button>
            </div>
          </template>

          <!-- waiting_for_answers -->
          <template v-else-if="tk.state === 'waiting_for_answers'">
            <h2 class="q-title">{{ t('ticket.questionsTitle', { n: d.questions.length }) }}</h2>
            <p class="sub">{{ t('ticket.questionsSub') }}</p>
            <TicketSection v-if="d.analysis?.plan.length" id="plan" :title="t('ticket.plan')" :hint="String(d.analysis.plan.length)">
              <ol class="plan"><li v-for="(p, i) in d.analysis.plan" :key="i">{{ tr(p) }}</li></ol>
            </TicketSection>
            <DesignRecord :analysis="d.analysis" />
            <form class="sec" @submit.prevent="act.mutate('answers')">
              <h3>{{ t('ticket.questions') }}</h3>
              <div v-for="(q, i) in d.questions" :key="q.id" class="q">
                <p>{{ tr(q.text) }}</p>
                <template v-if="q.multiple">
                  <span class="hint">{{ t('ticket.pickAny') }}</span>
                  <div class="tabs" role="group">
                    <button v-for="o in q.options" :key="o" type="button" class="tab" :aria-pressed="answers[q.id].picked.includes(o)" @click="togglePick(q, o)">{{ tr(o) }}</button>
                  </div>
                  <input v-model="answers[q.id].answer" maxlength="5000" class="cfg-in" :placeholder="t('ticket.otherAnswer')" :aria-label="t('ticket.answerFor', { n: i + 1 })">
                </template>
                <template v-else>
                  <div v-if="q.options.length" class="tabs" role="group">
                    <button v-for="o in q.options" :key="o" type="button" class="tab" :aria-pressed="answers[q.id].answer === o" @click="answers[q.id].answer = o">{{ tr(o) }}</button>
                  </div>
                  <input v-model="answers[q.id].answer" maxlength="5000" class="cfg-in" :placeholder="t('ticket.yourAnswer')" :aria-label="t('ticket.answerFor', { n: i + 1 })">
                </template>
                <textarea v-model="answers[q.id].note" maxlength="5000" :placeholder="t('ticket.addDetails')" :aria-label="t('ticket.detailsFor', { n: i + 1 })" />
                <FileAttach v-model="answers[q.id].files" v-model:busy="answers[q.id].uploading" :restored="q.answer == null ? q.draft?.attachments : undefined" />
              </div>
              <KindPicker :ticket="tk" />
              <ModelPicker :ticket="tk" :stages="['coding', 'retry']" />
              <div class="actions">
                <button class="btn btn-p" type="submit" :disabled="left > 0 || answersUploading || act.isPending.value">{{ report ? t('ticket.startWriting') : t('ticket.startCoding') }}</button>
                <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('ticket.reject') }}</button>
                <span class="hint">{{ left ? t('ticket.questionsLeft', { n: left }) : answersUploading ? t('files.wait') : t('ticket.allAnswered') }}</span>
                <span v-if="draftState" class="hint" role="status">{{ t(draftState === 'saving' ? 'ticket.draftSaving' : draftState === 'saved' ? 'ticket.draftSaved' : 'ticket.draftFailed') }}</span>
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
                <RouterLink :to="{ name: 'ticket', params: { key: b.key } }">{{ b.key }}</RouterLink>
                <span class="tk-wait-title">{{ b.title }}</span>
                <StateBadge :state="b.state" />
              </li>
            </ul>
            <div class="actions">
              <button class="btn" type="button" @click="tab = 'order'">{{ t('relations.title') }}</button>
              <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('ticket.reject') }}</button>
            </div>
          </template>

          <!-- coding / testing -->
          <template v-else-if="swaggerTest && tk.state === 'coding'">
            <h2>{{ tk.held ? t('swagger.queuedTitle') : t('swagger.runningTitle') }}</h2>
            <p class="sub">{{ tk.held ? t('swagger.queuedSub') : t('swagger.runningSub') }}</p>
            <div v-if="tk.held" class="actions">
              <button class="btn btn-p" type="button" :disabled="act.isPending.value" @click="act.mutate('start')">{{ t('ticket.start') }}</button>
              <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('ticket.reject') }}</button>
            </div>
            <template v-else>
              <TicketSection id="log" :title="t('ticket.log')"><MuseMeter :events="events" style="margin-bottom: 10px" /><LiveLog :events="events" /></TicketSection>
              <div class="actions">
                <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="confirmThen(t('ticket.stopConfirm', { key }), 'stop')">{{ t('ticket.stopRun') }}</button>
                <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('ticket.reject') }}</button>
              </div>
            </template>
          </template>
          <template v-else-if="tk.state === 'coding' || tk.state === 'testing'">
            <h2>{{ titleWithRev(report ? t('ticket.writingTitle') : tk.state === 'coding' ? t('ticket.codingTitle') : t('ticket.testingTitle')) }}</h2>
            <p class="sub">{{ report ? t('ticket.writingSub') : t('ticket.codingSub', { branch }) }}</p>
            <div class="sec">
              <dl class="facts">
                <div><dt>{{ t('ticket.factModel') }}</dt><dd>{{ d.effectiveModels ? models.label(tk.revision > 0 ? d.effectiveModels.retry : d.effectiveModels.coding) : '—' }}</dd></div>
                <div><dt>{{ t('ticket.factTurns') }}</dt><dd>{{ tk.turns }}</dd></div>
                <div><dt>{{ t('ticket.factTurnLimit') }}</dt><dd>{{ d.maxTurns ?? '—' }}</dd></div>
                <div v-if="!models.isMuse.value"><dt>{{ t('ticket.factSession') }}</dt><dd>{{ sessionPct }}%</dd></div>
              </dl>
            </div>
            <TicketSection id="log" :title="t('ticket.log')"><MuseMeter :events="events" style="margin-bottom: 10px" /><LiveLog :events="events" /></TicketSection>
            <div class="actions">
              <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="confirmThen(t('ticket.stopConfirm', { key }), 'stop')">{{ t('ticket.stopRun') }}</button>
              <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('ticket.reject') }}</button>
            </div>
          </template>

          <!-- waiting_for_review -->
          <template v-else-if="tk.state === 'waiting_for_review'">
            <h2>{{ titleWithRev(t('ticket.reviewTitle')) }}</h2>
            <p class="sub">{{ reviewSub }}</p>
            <div v-if="result" class="sec">
              <dl class="facts">
                <div>
                  <dt>{{ t('ticket.factTests') }}</dt>
                  <dd v-if="tk.skipChecks && !result.checks.length">{{ t('ticket.checksSkipped') }}</dd>
                  <dd v-else :class="checksOk ? 'ok' : 'bad'">{{ result.checks.length ? t('ticket.checksPassed', { n: result.checks.filter((c) => c.exitCode === 0).length }) : t('ticket.noChecks') }}</dd>
                </div>
                <div><dt>{{ t('ticket.factChanged') }}</dt><dd>{{ t('ticket.changedValue', { n: totals.n, add: totals.add, del: totals.del }) }}</dd></div>
                <div><dt>{{ t('ticket.factTurns') }}</dt><dd>{{ tk.turns }}</dd></div>
                <div v-if="!multi"><dt>{{ t('ticket.kvBranch') }}</dt><dd><BranchName :ticket-key="tk.key" :branch="branch" :can-rename="canRenameBranch" /></dd></div>
              </dl>
            </div>
            <TicketSection v-if="result?.summary" id="summary" :title="t('ticket.whatAgntsDid')">
              <div class="summary"><p>{{ tr(result.summary) }}</p></div>
            </TicketSection>
            <TicketSection v-if="result?.notes.length" id="notes" :title="t('ticket.notes')" :hint="String(result.notes.length)">
              <ul><li v-for="(n, i) in result.notes" :key="i">{{ tr(n) }}</li></ul>
            </TicketSection>
            <DesignRecord :analysis="d.analysis" :deviations="result?.deviations" />
            <CommitMessages :ticket="tk" />
            <ModelPicker :ticket="tk" :stages="tk.canPreview ? ['retry', 'review', 'preview'] : ['retry', 'review']" />
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
              <textarea id="feedback" v-model="feedback" :placeholder="t('ticket.feedbackHint')" @paste="feedbackAttach?.pasted($event)" />
              <FileAttach ref="feedbackAttach" v-model="feedbackFiles" v-model:busy="feedbackUploading" />
              <div class="tk-skip">
                <CheckBox v-model="skipChecks">{{ t('ticket.skipChecks') }}</CheckBox>
                <p class="hint">{{ t('ticket.skipChecksHint') }}</p>
              </div>
              <div v-if="feedbackShots.length" class="tk-shots" :aria-label="t('preview.attached')">
                <span class="hint">{{ t('preview.attached') }}:</span>
                <span v-for="(r, i) in feedbackShots" :key="`${r.runId}-${r.shotId}`" class="badge b-info tk-shot">
                  {{ shotName(r) }}
                  <button type="button" :aria-label="t('preview.detach', { name: shotName(r) })" @click="dropShot(i)">×</button>
                </span>
              </div>
            </div>
            <div v-if="secretFlags" class="help" :class="needsAck ? 'bad' : 'ok'" role="status">
              <HiIcon name="info" />
              <div>
                <p><b>{{ t('harnessTicket.secretsTitle') }}</b></p>
                <p>{{ needsAck ? t('harnessTicket.secretsBody', { n: secretFlags }) : t('harnessTicket.secretsDone') }}</p>
                <button v-if="needsAck" class="btn btn-s" type="button" :disabled="ackSecrets.isPending.value" @click="ackSecrets.mutate()">{{ t('harnessTicket.secretsConfirm') }}</button>
              </div>
            </div>
            <div class="actions">
              <button class="btn btn-p" type="button" :disabled="act.isPending.value" @click="approve">{{ t('ticket.approve') }}</button>
              <button class="btn" type="button" :disabled="!feedback.trim() || feedbackUploading || act.isPending.value" @click="act.mutate('request-changes')">{{ t('ticket.requestChanges') }}</button>
              <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('ticket.reject') }}</button>
            </div>
          </template>

          <!-- pushing -->
          <template v-else-if="tk.state === 'pushing'">
            <h2>{{ report ? t('ticket.deliveringTitle') : t('ticket.pushingTitle') }}</h2>
            <p class="sub">{{ report ? t('ticket.deliveringSub') : t('ticket.pushingSub') }}</p>
            <div class="sec"><LiveLog :events="events" /></div>
            <div class="actions"><button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('ticket.reject') }}</button></div>
          </template>

          <!-- done -->
          <template v-else-if="tk.state === 'done' && report">
            <h2>{{ t('ticket.doneReportTitle') }}</h2>
            <div class="sec">
              <div class="help ok">
                <HiIcon name="check" />
                <p>{{ tk.postReport ? t(isPlane ? 'ticket.doneReportPostedPlane' : 'ticket.doneReportPosted', { key: tk.key }) : t('ticket.doneReport') }}</p>
              </div>
            </div>
            <ImplementReport v-if="tk.kind === 'plan' || tk.kind === 'bug'" :ticket="tk" :child-key="d.childKey" />
          </template>

          <template v-else-if="tk.state === 'done'">
            <h2>{{ t('ticket.doneTitle') }}</h2>
            <div class="sec">
              <div class="help ok">
                <HiIcon name="check" />
                <p v-if="isTask && tk.afterApprove === 'main' && !tk.prUrl">{{ t('ticket.doneMain', { repo: repoNames }) }}</p>
                <p v-else>{{ t('ticket.donePr', { number: tk.prNumber ?? '', branch }) }}</p>
              </div>
              <p v-if="tk.mergedAt" class="hint" style="margin: 8px 0 0">{{ t('ticket.mergedAt', { time: ago(tk.mergedAt, locale) }) }}</p>
            </div>
            <div v-if="tk.prUrl || prs.length" class="actions">
              <template v-if="prs.length > 1">
                <a v-for="r in prs" :key="r.repoId" class="btn" :href="r.prUrl" target="_blank" rel="noopener">{{ t('groups.openPrIn', { repo: r.repoName, number: r.prNumber ?? '' }) }}</a>
              </template>
              <a v-else class="btn" :href="tk.prUrl || prs[0]?.prUrl" target="_blank" rel="noopener">{{ t('ticket.openPr', { number: tk.prNumber ?? prs[0]?.prNumber ?? '' }) }}</a>
              <template v-if="!tk.mergedAt">
                <button class="btn" type="button" :disabled="act.isPending.value" @click="act.mutate('merged')">{{ t('relations.markMerged') }}</button>
                <span class="hint">{{ t('relations.markMergedHint') }}</span>
              </template>
            </div>
            <ReplayButton v-if="!tk.replayOf && tk.repoId" :ticket="tk" />
          </template>

          <!-- rejected -->
          <template v-else-if="tk.state === 'rejected'">
            <h2>{{ t('ticket.rejectedTitle') }}</h2>
            <p class="sub">{{ continueTo ? t('ticket.rejectedSubContinue') : t('ticket.rejectedSub') }}</p>
            <template v-if="continueTo">
              <div v-if="continueTakesNote" class="sec">
                <h3><label for="continue-note">{{ t('ticket.continueNote') }}</label></h3>
                <textarea id="continue-note" v-model="continueNote" maxlength="4000" :placeholder="t('ticket.continueNoteHint')" />
                <FileAttach v-model="continueFiles" v-model:busy="continueUploading" />
              </div>
              <div class="actions">
                <button class="btn btn-p" type="button" :disabled="act.isPending.value || continueUploading" @click="act.mutate('continue')">{{ t('ticket.continue') }}</button>
                <button v-if="tk.canStartOver" class="btn" type="button" :disabled="act.isPending.value" @click="startOver">{{ t('ticket.startOver') }}</button>
                <span class="hint">{{ continueHint }}</span>
              </div>
            </template>
          </template>

          <!-- failed -->
          <template v-else-if="tk.state === 'failed'">
            <h2>{{ t('ticket.failedTitle') }}</h2>
            <div class="sec">
              <div class="help bad"><HiIcon name="info" /><p class="err-text" style="white-space: pre-wrap">{{ tk.stopReason || t('ticket.failedUnknown') }}</p><CopyButton v-if="tk.stopReason" :text="tk.stopReason" /></div>
            </div>
            <KindPicker v-if="kindEditable && !pull" :ticket="tk" />
            <RepoPicker v-if="canChangeRepo && !pull" :ticket="tk" />
            <ModelPicker v-if="!pull" :ticket="tk" :stages="['retry']" />
            <div v-if="tk.resumeState !== 'pushing'" class="sec">
              <h3><label for="retry-note">{{ t('ticket.retryNote') }}</label></h3>
              <textarea id="retry-note" v-model="retryNote" maxlength="4000" :placeholder="t('ticket.retryNoteHint')" />
              <FileAttach v-model="retryFiles" v-model:busy="retryUploading" />
              <div class="tk-skip">
                <CheckBox v-model="skipChecks">{{ t('ticket.skipChecks') }}</CheckBox>
                <p class="hint">{{ t('ticket.skipChecksHint') }}</p>
              </div>
            </div>
            <div class="actions">
              <button class="btn btn-p" type="button" :disabled="act.isPending.value || retryUploading || (needsRepo(tk) && !tk.repoId)" @click="act.mutate('retry')">{{ t('ticket.retry') }}</button>
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
              <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('ticket.reject') }}</button>
              <span class="hint">{{ t('ticket.rateHint', { pct: sessionPct }) }}</span>
            </div>
          </template>
        </fieldset>
      </section>

      <section v-if="pull && drafts.data.value?.length" class="card">
        <ReviewDraftsPanel
          :ticket-key="key"
          :drafts="drafts.data.value"
          :listed="drafts.data.value"
          :host="host"
          :head-sha="tk.pull?.headSha"
          :can-edit="workspace.canEdit"
          :locked="draftsLocked"
          :own="!!tk.pull?.login && tk.pull.login.toLowerCase() === tk.pull.author.toLowerCase()"
        />
        <p v-if="tk.repoId && tk.pull?.number" class="hint">
          <RouterLink :to="{ name: 'pull', params: { id: tk.repoId, number: tk.pull.number } }">{{ t('drafts.onDiff') }}</RouterLink>
        </p>
      </section>

      <template v-if="tabs.length">
        <div class="tabs tk-tabs" role="group" :aria-label="t('ticket.tabsLabel')">
          <button v-for="x in tabs" :key="x.id" type="button" class="tab" :aria-pressed="activeTab === x.id" @click="tab = x.id">
            {{ x.label }}<span v-if="x.n" class="tk-n">{{ x.n }}</span>
          </button>
        </div>

        <!-- waiting_for_review: a report -->
        <section v-if="activeTab === 'decide'" class="card tk-panel">
          <fieldset class="ro-fs" :disabled="!workspace.canEdit">
            <h2>{{ titleWithRev(t('ticket.reviewReportTitle')) }}</h2>
            <p class="sub">{{ isTask ? t('ticket.reviewReportSub') : isPlane ? t('ticket.reviewReportSubPlane') : t('ticket.reviewReportSubJira') }}</p>
            <div v-if="result?.summary" class="sec">
              <div class="summary"><p>{{ tr(result.summary) }}</p></div>
            </div>
            <TicketSection v-if="result?.notes.length" id="notes" :title="t('ticket.notes')" :hint="String(result.notes.length)">
              <ul><li v-for="(n, i) in result.notes" :key="i">{{ tr(n) }}</li></ul>
            </TicketSection>
            <ModelPicker :ticket="tk" :stages="['retry', 'review']" />
            <div v-if="!isTask" class="sec">
              <CheckBox v-model="postReport">{{ t(isPlane ? 'ticket.postReportPlane' : 'ticket.postReport', { key: tk.key }) }}</CheckBox>
            </div>
            <div class="sec">
              <h3><label for="feedback">{{ t('ticket.feedback') }}</label></h3>
              <textarea id="feedback" v-model="feedback" :placeholder="t('ticket.feedbackReportHint')" @paste="feedbackAttach?.pasted($event)" />
              <FileAttach ref="feedbackAttach" v-model="feedbackFiles" v-model:busy="feedbackUploading" />
            </div>
            <div class="actions">
              <button class="btn btn-p" type="button" :disabled="act.isPending.value" @click="approve">{{ t('ticket.approveReport') }}</button>
              <button class="btn" type="button" :disabled="!feedback.trim() || feedbackUploading || act.isPending.value" @click="act.mutate('request-changes')">{{ t('ticket.requestChanges') }}</button>
              <button class="btn btn-d" type="button" :disabled="act.isPending.value" @click="reject">{{ t('ticket.reject') }}</button>
            </div>
          </fieldset>
        </section>

        <section v-else-if="activeTab === 'api'" class="card tk-panel">
          <SwaggerResults :ticket="tk" />
        </section>

        <section v-else-if="activeTab === 'report'" class="card tk-panel">
          <div class="ch"><h2>{{ t('ticket.report') }}</h2></div>
          <ReportView v-if="result?.report" :markdown="tr(result.report)" />
          <p v-else class="hint">{{ t('ticket.reportMissing') }}</p>
        </section>

        <section v-else-if="activeTab === 'review'" class="card tk-panel">
          <fieldset class="ro-fs" :disabled="!workspace.canEdit">
            <CodeReview :ticket="tk" :review="d.review" :feedback="feedback" :report="report" :pull="pull" @add="addFeedback" @show="showFile" />
            <RedFlags v-if="result?.redFlags?.length" :flags="result.redFlags" @show="showFile" />
            <HarnessChecks :result="result" />
          </fieldset>
        </section>

        <section v-else-if="activeTab === 'preview'" class="card tk-panel">
          <fieldset class="ro-fs" :disabled="!workspace.canEdit">
            <PreviewShots :ticket="tk" :preview="d.preview" :attached="feedbackShots" @add="addShot" />
          </fieldset>
        </section>

        <section v-else-if="activeTab === 'changes' && result" class="card tk-panel">
          <div class="ch">
            <div>
              <h2>{{ t('ticket.changes') }}</h2>
              <p class="sub">{{ t('ticket.changedValue', { n: totals.n, add: totals.add, del: totals.del }) }} · {{ ago(result.createdAt, locale) }}</p>
            </div>
          </div>
          <div v-if="result.summary && tk.state !== 'waiting_for_review'" class="summary"><p>{{ tr(result.summary) }}</p></div>
          <TicketSection
            v-if="result.checks.length" id="checks" :title="t('ticket.checks')"
            :hint="`${result.checks.filter((c) => c.exitCode === 0).length}/${result.checks.length}`"
          >
            <dl class="kv">
              <template v-for="c in result.checks" :key="c.name">
                <dt class="mono">{{ c.command }}</dt>
                <dd :class="c.exitCode === 0 ? 'repo-ok' : 'repo-miss'">{{ c.exitCode === 0 ? t('ticket.passed') : t('ticket.failedCheck') }} · {{ (c.durationMs / 1000).toFixed(1) }}s</dd>
              </template>
            </dl>
          </TicketSection>
          <TicketSection id="diff" :title="t('ticket.diff')" :hint="String(result.files.length)">
            <RepoDiffs v-model:repo="diffRepo" :files="result.files" :open-first="tk.state === 'waiting_for_review'" />
          </TicketSection>
        </section>

        <fieldset v-else-if="activeTab === 'followUps'" class="ro-fs" :disabled="!workspace.canEdit">
          <FollowUps :ticket="tk" :follow-ups="d.followUps" />
        </fieldset>

        <fieldset v-else-if="activeTab === 'order'" class="ro-fs" :disabled="!workspace.canEdit">
          <TicketRelations :ticket="tk" :relations="d.relations" :footprint="d.analysis?.footprint" />
        </fieldset>

        <section v-else-if="activeTab === 'answers'" class="card">
          <div class="ch"><div><h2>{{ t('ticket.answersTitle') }}</h2><p class="sub">{{ t('ticket.answersSub') }}</p></div></div>
          <div v-for="q in answered" :key="q.id" class="ans">
            <span class="qq">{{ tr(q.text) }}</span>
            <span>
              <b>{{ q.multiple ? answerText(q) : tr(q.answer ?? '') }}</b><template v-if="q.note">. {{ q.note }}</template>
              <FileList :files="filesOf('answer', q.id)" />
            </span>
          </div>
        </section>

        <fieldset v-else-if="activeTab === 'lessons'" class="ro-fs" :disabled="!workspace.canEdit">
          <TicketLessons :ticket="tk" />
        </fieldset>

        <TicketDocuments v-else-if="activeTab === 'documents'" class="tk-panel" :ticket="tk" :has-report="report && !!result?.report" />

        <RunLog v-else-if="activeTab === 'log'" :events="events" :ticket-key="key" />

        <template v-else-if="activeTab === 'task'">
          <section class="card tk-panel">
            <div class="ch"><h2>{{ isTask ? t('ticket.sideTask') : t('ticket.sideTicket') }}</h2><span><StateBadge :state="tk.state" :kind="tk.kind" /> <span v-if="tk.mergedAt" class="badge b-ok">{{ t('ticket.merged') }}</span> <span v-if="tk.partlyMerged" class="badge b-warn">{{ t('groups.partlyMerged') }}</span></span></div>
            <!-- Facts in small titled groups, each label beside its value: one
                 list across the full width put them too far apart to read. -->
            <div class="tk-facts">
              <section class="tk-fgrp">
                <h3>{{ t('ticket.factsTicket') }}</h3>
                <dl class="tk-dl">
                  <dt>{{ t('ticket.kvKey') }}</dt><dd class="mono">{{ tk.key }}</dd>
                  <template v-if="!pull"><dt>{{ t('tasks.ticketNumber') }}</dt><dd><TicketNumber :ticket="tk" /></dd></template>
                  <dt>{{ t('kind.title') }}</dt><dd><KindBadge :ticket="tk" /></dd>
                  <dt>{{ t('ticket.kvSource') }}</dt><dd>{{ isTask ? t('ticket.srcTask') : isPlane ? t('ticket.srcPlane') : pull ? t('ticket.srcGit') : tk.source === 'ci' ? t('ticket.srcCi') : t('ticket.srcJira') }}</dd>
                  <dt>{{ t('ticket.kvPriority') }}</dt><dd>{{ tk.priority }}</dd>
                </dl>
              </section>
              <section class="tk-fgrp">
                <h3>{{ t('ticket.factsCode') }}</h3>
                <dl class="tk-dl">
                  <template v-if="multi"><dt>{{ t('groups.kvRepos') }}</dt><dd>{{ repoNames }}</dd></template>
                  <template v-else><dt>{{ t('ticket.kvRepo') }}</dt><dd>{{ tk.repoName ?? '—' }}</dd></template>
                  <template v-if="tk.group"><dt>{{ t('groups.kvGroup') }}</dt><dd>{{ tk.group.name }}</dd></template>
                  <template v-if="!report && !pull && !multi"><dt>{{ t('ticket.kvBranch') }}</dt><dd><BranchName :ticket-key="tk.key" :branch="branch" :can-rename="canRenameBranch" /></dd></template>
                  <template v-if="isTask && !report"><dt>{{ t('ticket.kvAfter') }}</dt><dd>{{ tk.afterApprove === 'main' ? t('ticket.afterMain') : t('ticket.afterPr') }}</dd></template>
                  <template v-if="tk.ciFixes && !multi"><dt>{{ t('ticket.kvCi') }}</dt><dd><span class="badge b-warn">{{ t('ticket.ciFixes', { n: tk.ciFixes }) }}</span></dd></template>
                </dl>
              </section>
              <section class="tk-fgrp">
                <h3>{{ t('ticket.factsPeople') }}</h3>
                <dl class="tk-dl">
                  <dt>{{ t('queue.member') }}</dt>
                  <dd>
                    {{ tk.member ?? '—' }}
                    <button
                      v-if="workspace.canEdit && tk.memberId !== session.user?.id && !['done', 'rejected'].includes(tk.state)" type="button" class="link-btn" style="margin-left: 6px"
                      :disabled="takeOver.isPending.value" @click="takeOver.mutate()"
                    >
                      {{ t('queue.takeOver') }}
                    </button>
                    <div v-if="tk.createdBy" class="hint tk-dd-note">{{ t('queue.createdBy', { name: tk.createdBy }) }}</div>
                  </dd>
                  <template v-if="tk.assignees?.length"><dt>{{ t('ticket.kvAssignees') }}</dt><dd>{{ tk.assignees.join(', ') }}</dd></template>
                </dl>
              </section>
              <section v-if="tk.parentKey || tk.followUpOf || waitsFor.length" class="tk-fgrp">
                <h3>{{ t('ticket.factsLinks') }}</h3>
                <dl class="tk-dl">
                  <template v-if="tk.parentKey"><dt>{{ t('implement.implements') }}</dt><dd><RouterLink :to="{ name: 'ticket', params: { key: tk.parentKey } }">{{ tk.parentKey }}</RouterLink></dd></template>
                  <template v-if="tk.followUpOf"><dt>{{ t('followUps.followUpOf') }}</dt><dd><RouterLink :to="{ name: 'ticket', params: { key: tk.followUpOf } }">{{ tk.followUpOf }}</RouterLink></dd></template>
                  <template v-if="waitsFor.length">
                    <dt>{{ t('relations.waitsFor') }}</dt>
                    <dd><template v-for="(k2, i) in waitsFor" :key="k2"><template v-if="i">, </template><RouterLink :to="{ name: 'ticket', params: { key: k2 } }">{{ k2 }}</RouterLink></template></dd>
                  </template>
                </dl>
              </section>
              <section class="tk-fgrp">
                <h3>{{ t('ticket.factsRuns') }}</h3>
                <dl class="tk-dl">
                  <dt>{{ t('ticket.kvRevision') }}</dt><dd>{{ tk.revision }}</dd>
                  <dt>{{ t('ticket.kvTurns') }}</dt><dd>{{ tk.turns }}</dd>
                  <template v-if="d.effectiveModels && !pull">
                    <dt>{{ t('ticket.kvCodingModel') }}</dt><dd>{{ models.label(d.effectiveModels.coding) }}</dd>
                    <dt>{{ t('ticket.kvRetryModel') }}</dt><dd>{{ models.label(d.effectiveModels.retry) }}</dd>
                  </template>
                </dl>
              </section>
            </div>
          </section>
          <TicketRepos v-if="multi" :ticket="tk" :can-retry="tk.state === 'failed' && workspace.canEdit" :busy="act.isPending.value" @retry="act.mutate('retry')" />
        </template>

        <div v-else-if="activeTab === 'spend'" class="tk-panel">
          <section v-if="museBudget(events)" class="card" style="margin-bottom: 16px"><MuseMeter :events="events" /></section>
          <SpendCard :spend="tk.spend" :stages="d.spendByStage ?? []" :report="report" />
        </div>

        <section v-else-if="activeTab === 'history'" class="card tk-panel">
          <div class="ch"><h2>{{ t('ticket.historyTitle') }}</h2></div>
          <ol v-if="d.history?.length" class="tl">
            <li v-for="(h, i) in [...d.history].reverse()" :key="i">
              <time>{{ histTime(h.at) }}</time>
              <span class="dot" :class="histDot(h.origin, h.state)" />
              <span>{{ t(stateKey(h.state, tk.kind)) }}<template v-if="h.message">: {{ h.message }}</template><span v-if="h.user" class="hint"> · {{ t('queue.by', { name: h.user }) }}</span></span>
            </li>
          </ol>
          <p v-else class="hint">{{ t('ticket.historyEmpty') }}</p>
        </section>
      </template>

      <TicketPullComments v-for="p in prThreads" :key="`${p.repoId}-${p.number}`" :ticket="tk" v-bind="p" />
      <TicketCommits v-if="!report" :ticket="tk" />
    </div>
  </template>
</template>

<style scoped>
.tk-stage { position: relative; }
.tk-stage .q-copy { position: absolute; top: 16px; right: 16px; }
/* room for the copy button beside the title */
.q-title { padding-right: 170px; }
@media (max-width: 560px) {
  .tk-stage .q-copy { position: static; margin-bottom: 10px; }
  .q-title { padding-right: 0; }
}
.tk-update { margin-bottom: 14px; }
.tk-update-title { margin: 6px 0 4px; font-weight: 600; }
.tk-update-desc { margin: 0; white-space: pre-wrap; max-height: 240px; overflow: auto; font-size: 14px; }
.tk-desc { white-space: pre-wrap; overflow-wrap: anywhere; }
.tk-skip { margin-top: 12px; }
.tk-skip .hint { margin: 4px 0 0 26px; }
/* A title may hold a long host name or path (Swagger tests): let it wrap. */
.ph > div { min-width: 0; }
.ph h1 { overflow-wrap: anywhere; }
.tk-desc.folded { display: -webkit-box; -webkit-line-clamp: 3; line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }
.tk-more { margin-top: 4px; padding: 0; border: 0; background: none; font: inherit; font-size: 14px; font-weight: 700; color: var(--primary-ink); cursor: pointer; }
.tk-head-act { align-self: flex-start; }
.tk-top { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 8px; }
.tk-lang { width: 200px; }
.tk-tr-note { display: flex; align-items: center; gap: 8px; margin: 10px 0 0; }
.tk-tabs { margin: 4px 0 -4px; }
.tk-facts { display: grid; grid-template-columns: repeat(auto-fill, minmax(min(100%, 300px), 1fr)); gap: 14px; margin-top: 14px; align-items: start; }
.tk-fgrp { min-width: 0; padding: 14px 16px 6px; border: 1px solid var(--line); border-radius: 12px; }
.tk-fgrp h3 { margin: 0 0 6px; font-size: 13px; font-weight: 700; color: var(--ink-3); }
.tk-dl { display: grid; grid-template-columns: minmax(96px, max-content) minmax(0, 1fr); margin: 0; font-size: 14px; }
.tk-dl dt, .tk-dl dd { min-width: 0; padding: 8px 0; border-top: 1px solid var(--line-2); overflow-wrap: anywhere; }
.tk-dl dt { padding-right: 14px; color: var(--ink-3); }
.tk-dl dd { margin: 0; font-weight: 600; }
.tk-dl dt:first-of-type, .tk-dl dt:first-of-type + dd { border-top: 0; }
.tk-dd-note { margin-top: 2px; font-weight: 400; }
.tk-dl .mono { font-family: var(--mono); font-size: 13.5px; }
.tk-dl .badge { white-space: normal; height: auto; min-height: 24px; padding-block: 3px; line-height: 1.3; }
.tk-dl a { color: var(--primary-ink); font-family: var(--mono); font-size: 13.5px; font-weight: 700; text-decoration: none; }
.tk-dl a:hover { text-decoration: underline; }
.tk-n { margin-left: 6px; font-size: 12.5px; opacity: .7; font-variant-numeric: tabular-nums; }
.tk-panel > .sec:first-child { margin-top: 0; }
.tk-wait { list-style: none; margin: 12px 0 0; padding: 0; display: grid; gap: 8px; }
.tk-wait li { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.tk-wait-title { min-width: 0; overflow-wrap: anywhere; }
.tk-shots { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; margin-top: 8px; }
.tk-shot { display: inline-flex; align-items: center; gap: 6px; }
.tk-shot button { border: 0; background: none; padding: 0 2px; font: inherit; font-weight: 700; color: inherit; cursor: pointer; }
</style>
