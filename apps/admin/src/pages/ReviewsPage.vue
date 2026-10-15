<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import type { PRCommentSettings, PullReviewSettings, ReviewSync, Settings, Ticket } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import StateBadge from '../components/StateBadge.vue'
import CfgRow from '../components/form/CfgRow.vue'
import SegButtons from '../components/form/SegButtons.vue'
import SwitchToggle from '../components/form/SwitchToggle.vue'
import HiIcon from '../components/ui/HiIcon.vue'
import { ago } from '../composables/format'
import { livePoll, useLive } from '../composables/useLive'
import { useUi } from '../stores/ui'
import { useWorkspace } from '../stores/workspace'

// The pull requests waiting for you, agnts's reviews of them, and what it
// learned about how you review.
const { t, locale } = useI18n()
const router = useRouter()
const qc = useQueryClient()
const ui = useUi()
const workspace = useWorkspace()
useLive()
const fail = (e: unknown) => ui.notify(e instanceof HttpError ? e.message : t('common.error'))

const tickets = useQuery({
  queryKey: ['tickets', 'reviews'],
  queryFn: () => unwrap(api.GET('/tickets')),
  refetchInterval: () => livePoll(30_000),
})
const reviews = computed(() => {
  const q = ui.search.trim().toLowerCase()
  return (tickets.data.value ?? [])
    .filter((x) => x.kind === 'review')
    .filter((x) => !q || [x.key, x.title, x.repoName ?? '', x.pull?.author ?? ''].some((s) => s.toLowerCase().includes(q)))
})
const FINISHED = ['done', 'rejected']
const groups = computed(() => [
  { id: 'waiting', rows: reviews.value.filter((x) => x.state === 'waiting_for_review') },
  { id: 'inProgress', rows: reviews.value.filter((x) => x.state !== 'waiting_for_review' && !FINISHED.includes(x.state)) },
  { id: 'finished', rows: reviews.value.filter((x) => FINISHED.includes(x.state)).slice(0, 20) },
])
const open = (x: Ticket) => router.push({ name: 'ticket', params: { key: x.key } })

// Sync now.
const lastSync = ref<ReviewSync | null>(null)
const sync = useMutation({
  mutationFn: () => unwrap(api.POST('/reviews/sync')),
  onSuccess: (r) => {
    lastSync.value = r
    void qc.invalidateQueries({ queryKey: ['tickets'] })
    void qc.invalidateQueries({ queryKey: ['nav'] })
  },
  onError: fail,
})

// Settings.pullReviews, saved with the rest of the settings on each change.
const settings = useQuery({ queryKey: ['settings'], queryFn: () => unwrap(api.GET('/settings')) })
const DEFAULTS: PullReviewSettings = { enabled: false, reviewRequested: true, skipDrafts: true, rereview: true, mergeMethod: 'merge' }
const pr = computed(() => settings.data.value?.pullReviews ?? DEFAULTS)
const saveSettings = useMutation({
  mutationFn: (s: Settings) => unwrap(api.PUT('/settings', { body: s })),
  onSuccess: (s) => qc.setQueryData(['settings'], s),
  onError: fail,
})
function setPr<K extends keyof PullReviewSettings>(k: K, v: PullReviewSettings[K]) {
  const s = settings.data.value
  if (s) saveSettings.mutate({ ...JSON.parse(JSON.stringify(s)), pullReviews: { ...pr.value, [k]: v } })
}
// Settings.prComments: how agnts takes part in pull request conversations.
const PRC_DEFAULTS: PRCommentSettings = { attribution: true, learnFromComments: true, resolveFixed: true, autoAddress: false }
const PRC_KEYS = ['attribution', 'learnFromComments', 'resolveFixed', 'autoAddress'] as const
const prc = computed(() => settings.data.value?.prComments ?? PRC_DEFAULTS)
function setPrc(k: keyof PRCommentSettings, v: boolean) {
  const s = settings.data.value
  if (s) saveSettings.mutate({ ...JSON.parse(JSON.stringify(s)), prComments: { ...prc.value, [k]: v } })
}
const methods = computed(() => (['merge', 'squash', 'rebase'] as const).map((m) => ({ value: m, label: t(`reviews.merge_${m}`) })))

// How you review: profiles and the notes not learned yet.
const reviewers = useQuery({ queryKey: ['reviewers'], queryFn: () => unwrap(api.GET('/reviews/reviewers')) })
const profiles = reactive<Record<string, string>>({})
const notes = reactive<Record<string, string>>({})
watch(
  () => reviewers.data.value?.reviewers,
  (rs) => {
    for (const r of rs ?? []) if (profiles[r.login] === undefined) profiles[r.login] = r.profile
  },
  { immediate: true },
)
// Logins agnts reviews for: those it knows, and those of the pull requests it has.
const logins = computed(() => {
  const set = new Set((reviewers.data.value?.reviewers ?? []).map((r) => r.login))
  for (const x of reviews.value) if (x.pull?.login) set.add(x.pull.login)
  return [...set].sort()
})
const reviewerOf = (login: string) => reviewers.data.value?.reviewers.find((r) => r.login === login)
const refresh = () => qc.invalidateQueries({ queryKey: ['reviewers'] })
const saveProfile = useMutation({
  mutationFn: (login: string) =>
    unwrap(api.PUT('/reviews/reviewers/{login}', { params: { path: { login } }, body: { profile: profiles[login] ?? '' } })),
  onSuccess: () => {
    ui.notify(t('reviews.profileSaved'))
    void refresh()
  },
  onError: fail,
})
const addNote = useMutation({
  mutationFn: (login: string) => unwrap(api.POST('/reviews/notes', { body: { login, note: (notes[login] ?? '').trim() } })),
  onSuccess: (_, login) => {
    notes[login] = ''
    ui.notify(t('reviews.noteAdded'))
    void refresh()
  },
  onError: fail,
})
const delNote = useMutation({
  mutationFn: (id: number) => unwrap(api.DELETE('/reviews/notes/{id}', { params: { path: { id } } })),
  onSuccess: () => void refresh(),
  onError: fail,
})
const newLogin = ref('')
</script>

<template>
  <PageHeader :title="t('reviews.title')">
    <template #below><p class="sub" style="margin: 4px 0 0">{{ t('reviews.lede') }}</p></template>
    <div class="actions" style="margin: 0">
      <button v-if="workspace.canEdit" class="btn btn-p" type="button" :disabled="sync.isPending.value" @click="sync.mutate()">
        <span v-if="sync.isPending.value" class="spin" aria-hidden="true" />{{ sync.isPending.value ? t('reviews.syncing') : t('reviews.sync') }}
      </button>
    </div>
  </PageHeader>

  <div class="cfg-grid">
    <div class="col">
      <div v-if="lastSync" class="help" :class="{ warn: lastSync.errors.length }" role="status">
        <HiIcon name="info" />
        <div>
          <p style="margin: 0">{{ t('reviews.synced', { ...lastSync }) }}</p>
          <template v-if="lastSync.errors.length">
            <p style="margin: 6px 0 0">{{ t('reviews.syncErrors') }}</p>
            <ul class="rv-errs"><li v-for="(e, i) in lastSync.errors" :key="i">{{ e }}</li></ul>
          </template>
        </div>
      </div>

      <p v-if="tickets.isPending.value" class="hint">{{ t('common.loading') }}</p>
      <section v-else-if="!reviews.length" class="card"><div class="empty"><p style="margin: 0">{{ t('reviews.emptyAll') }}</p></div></section>
      <template v-else>
        <section v-for="g in groups" :key="g.id" class="card">
          <div class="ch"><h2>{{ t(`reviews.${g.id}`) }} <span v-if="g.rows.length" class="tk-n">{{ g.rows.length }}</span></h2></div>
          <p v-if="!g.rows.length" class="hint" style="margin: 0">{{ t('reviews.empty') }}</p>
          <div v-else class="tw">
            <table class="tbl">
              <tbody>
                <tr v-for="x in g.rows" :key="x.key" tabindex="0" @click="open(x)" @keydown.enter="open(x)">
                  <td>
                    <div class="tkey">
                      {{ x.repoName ?? '—' }}
                      <a v-if="x.pull" :href="x.pull.url" target="_blank" rel="noopener" @click.stop>#{{ x.pull.number }}</a>
                    </div>
                    <div class="ttitle">{{ x.title }}</div>
                    <div v-if="x.pull" class="hint rv-meta">
                      {{ t('reviews.by', { author: x.pull.author }) }} · {{ t(`reviews.why_${x.pull.why}`) }}
                    </div>
                  </td>
                  <td><StateBadge :state="x.state" :kind="x.kind" /> <span v-if="x.mergedAt" class="badge b-ok">{{ t('ticket.merged') }}</span></td>
                  <td class="muted">{{ ago(x.updatedAt, locale) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </template>

      <section class="card">
        <div class="ch"><div><h2>{{ t('reviews.howTitle') }}</h2><p class="sub">{{ t('reviews.howSub') }}</p></div></div>
        <p v-if="reviewers.isPending.value" class="hint">{{ t('common.loading') }}</p>
        <p v-else-if="!logins.length" class="hint">{{ t('reviews.noReviewers') }}</p>
        <fieldset class="ro-fs" :disabled="!workspace.canEdit">
          <div v-for="login in logins" :key="login" class="sec rv-who">
            <h3>@{{ login }} <span v-if="reviewerOf(login)?.notesFolded" class="hint">· {{ t('reviews.folded', { n: reviewerOf(login)?.notesFolded ?? 0 }) }}</span></h3>
            <label class="hint" :for="`profile-${login}`">{{ t('reviews.profile') }} · {{ t('reviews.profileHint') }}</label>
            <textarea :id="`profile-${login}`" v-model="profiles[login]" class="rv-profile" maxlength="8000" />
            <div class="actions" style="margin-top: 8px">
              <button class="btn btn-s" type="button" :disabled="saveProfile.isPending.value || (profiles[login] ?? '') === (reviewerOf(login)?.profile ?? '')" @click="saveProfile.mutate(login)">
                {{ t('reviews.saveProfile') }}
              </button>
            </div>
            <template v-if="reviewerOf(login)?.pending.length">
              <h3 style="margin-top: 14px">{{ t('reviews.pending') }}</h3>
              <ul class="rv-notes">
                <li v-for="n in reviewerOf(login)?.pending" :key="n.id">
                  <div class="hint">{{ t(`reviews.noteKind_${n.kind}`) }}<template v-if="n.ticketKey"> · <RouterLink :to="{ name: 'ticket', params: { key: n.ticketKey } }">{{ n.ticketKey }}</RouterLink></template> · {{ ago(n.createdAt, locale) }}</div>
                  <p>{{ n.note }}</p>
                  <button type="button" class="link-btn" :aria-label="t('reviews.deleteNote')" :disabled="delNote.isPending.value" @click="delNote.mutate(n.id)">{{ t('reviews.deleteNote') }}</button>
                </li>
              </ul>
            </template>
            <label class="hint" :for="`note-${login}`" style="display: block; margin-top: 12px">{{ t('reviews.addNote') }}</label>
            <textarea :id="`note-${login}`" v-model="notes[login]" maxlength="4000" :placeholder="t('reviews.notePlaceholder')" />
            <div class="actions" style="margin-top: 8px">
              <button class="btn btn-s" type="button" :disabled="!(notes[login] ?? '').trim() || addNote.isPending.value" @click="addNote.mutate(login)">{{ t('reviews.addNote') }}</button>
            </div>
          </div>
          <div v-if="!logins.length" class="sec">
            <input v-model="newLogin" class="cfg-in rv-login" :placeholder="t('reviews.login')" :aria-label="t('reviews.login')">
            <textarea v-model="notes[newLogin.trim()]" maxlength="4000" :disabled="!newLogin.trim()" :placeholder="t('reviews.notePlaceholder')" />
            <div class="actions" style="margin-top: 8px">
              <button class="btn btn-s" type="button" :disabled="!newLogin.trim() || !(notes[newLogin.trim()] ?? '').trim() || addNote.isPending.value" @click="addNote.mutate(newLogin.trim())">{{ t('reviews.addNote') }}</button>
            </div>
          </div>
        </fieldset>
      </section>
    </div>

    <aside class="cfg-side">
      <section class="card">
        <div class="ch"><h2>{{ t('reviews.settingsTitle') }}</h2></div>
        <fieldset class="ro-fs" :disabled="!workspace.canEdit || !settings.data.value || saveSettings.isPending.value">
          <CfgRow :label="t('reviews.enabled')" :help="t('reviews.enabledHelp')">
            <SwitchToggle :model-value="pr.enabled" :label="t('reviews.enabled')" @update:model-value="(v) => setPr('enabled', v)" />
          </CfgRow>
          <CfgRow :label="t('reviews.reviewRequested')" :help="t('reviews.reviewRequestedHelp')">
            <SwitchToggle :model-value="pr.reviewRequested" :label="t('reviews.reviewRequested')" @update:model-value="(v) => setPr('reviewRequested', v)" />
          </CfgRow>
          <CfgRow :label="t('reviews.skipDrafts')" :help="t('reviews.skipDraftsHelp')">
            <SwitchToggle :model-value="pr.skipDrafts" :label="t('reviews.skipDrafts')" @update:model-value="(v) => setPr('skipDrafts', v)" />
          </CfgRow>
          <CfgRow :label="t('reviews.rereview')" :help="t('reviews.rereviewHelp')">
            <SwitchToggle :model-value="pr.rereview" :label="t('reviews.rereview')" @update:model-value="(v) => setPr('rereview', v)" />
          </CfgRow>
          <CfgRow :label="t('reviews.mergeMethod')" :help="t('reviews.mergeMethodHelp')">
            <SegButtons :model-value="pr.mergeMethod" :options="methods" :label="t('reviews.mergeMethod')" @update:model-value="(v) => setPr('mergeMethod', v)" />
          </CfgRow>
        </fieldset>
      </section>
      <section class="card">
        <div class="ch"><h2>{{ t('pulls.settingsTitle') }}</h2></div>
        <fieldset class="ro-fs" :disabled="!workspace.canEdit || !settings.data.value || saveSettings.isPending.value">
          <CfgRow v-for="k in PRC_KEYS" :key="k" :label="t(`pulls.set_${k}`)" :help="t(`pulls.set_${k}Help`)">
            <SwitchToggle :model-value="prc[k]" :label="t(`pulls.set_${k}`)" @update:model-value="(v) => setPrc(k, v)" />
          </CfgRow>
        </fieldset>
      </section>
    </aside>
  </div>
</template>

<style scoped>
.tk-n { margin-left: 6px; font-size: 13px; opacity: .7; font-variant-numeric: tabular-nums; }
.rv-meta { margin-top: 2px; font-size: 13px; }
.rv-errs { margin: 4px 0 0; padding-left: 18px; font-size: 13.5px; overflow-wrap: anywhere; }
.rv-who + .rv-who { border-top: 1px solid var(--line); padding-top: 14px; }
.rv-login { display: block; width: 100%; max-width: none; margin-bottom: 10px; }
.rv-profile { min-height: 140px; font-family: var(--mono); font-size: 13px; }
.rv-notes { list-style: none; margin: 8px 0 0; padding: 0; display: grid; gap: 8px; }
.rv-notes li { border: 1px solid var(--line); border-radius: 10px; padding: 10px 12px; }
.rv-notes p { margin: 4px 0; white-space: pre-wrap; }
</style>
