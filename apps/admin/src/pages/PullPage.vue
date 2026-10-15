<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, unwrap } from '../api/client'
import type { ReviewDraft } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import CommentBody from '../components/pulls/CommentBody.vue'
import PullConversation from '../components/pulls/PullConversation.vue'
import ReviewDraftsPanel from '../components/pulls/ReviewDraftsPanel.vue'
import ReviewPullDialog from '../components/pulls/ReviewPullDialog.vue'
import { hostName, pullKey } from '../components/pulls/usePull'
import { numberDiff } from '../components/diffLines'
import HiIcon from '../components/ui/HiIcon.vue'
import { ago } from '../composables/format'
import { livePoll } from '../composables/useLive'
import { useWorkspace } from '../stores/workspace'

// One pull request (GitLab merge request) as it stands on the git host:
// its description, conversation and diff, with comments made here going
// out as the git host token's user. "Review with agnts" asks for a review
// of it; the review's comments stay drafts here until accepted and
// published.
const { t, locale } = useI18n()
const route = useRoute()
const workspace = useWorkspace()
const repoId = computed(() => Number(route.params.id))
const number = computed(() => Number(route.params.number))
const asking = ref(false)

const pull = useQuery({
  queryKey: computed(() => pullKey(repoId.value, number.value, 'detail')),
  queryFn: () => unwrap(api.GET('/repos/{id}/pulls/{number}', { params: { path: { id: repoId.value, number: number.value } } })),
  // Faster while agnts is reviewing, so its drafts show up when ready.
  refetchInterval: (q): number => livePoll(['new', 'analyzing', 'coding'].includes(q.state.data?.ticketState ?? '') ? 10_000 : 60_000),
})
const d = computed(() => pull.data.value)
const TONE: Record<string, string> = { open: 'b-info', merged: 'b-ok', closed: 'b-gray' }
const errMsg = (e: unknown) => (e instanceof Error && e.message ? e.message : t('common.error'))
const host = computed(() => hostName(d.value?.provider))

// A review can be asked for on an open pull request that is not agnts's
// own, when it has none in progress.
const TERMINAL = ['done', 'rejected']
const reviewEnded = computed(() => !d.value?.ticketKey || TERMINAL.includes(d.value.ticketState ?? ''))
const canAsk = computed(() => workspace.canEdit && d.value?.pull.state === 'open' && !d.value.own && reviewEnded.value)
const reviewing = computed(() => !d.value?.own && ['new', 'analyzing', 'coding'].includes(d.value?.ticketState ?? ''))
const drafts = computed<ReviewDraft[] | undefined>(() => (d.value?.own ? undefined : d.value?.drafts ?? undefined))
const locked = computed(() => d.value?.pull.state !== 'open' || d.value?.ticketState === 'rejected')

// The drafts the diff cannot show under a line: the summary, general
// comments, and those on a line outside the diff or on another commit.
const listed = computed(() => {
  const files = new Map((d.value?.files ?? []).map((f) => [f.path, new Set(numberDiff(f.diff ?? '').filter((l) => l.kind !== 'del').map((l) => l.new))]))
  const head = d.value?.pull.headSha
  return (drafts.value ?? []).filter(
    (x) => x.kind === 'summary' || !x.path || !x.line || (x.headSha && head && x.headSha !== head) || !files.get(x.path)?.has(x.line) || x.state === 'published',
  )
})
</script>

<template>
  <RouterLink class="back-btn" :to="{ name: 'repo', params: { id: repoId }, query: { tab: 'pulls' } }"><HiIcon name="back" />{{ t('pulls.back') }}</RouterLink>
  <p v-if="pull.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <div v-else-if="pull.isError.value" class="help bad"><HiIcon name="info" /><p>{{ errMsg(pull.error.value) }}</p></div>
  <template v-else-if="d">
    <PageHeader :title="`#${d.pull.number} ${d.pull.title}`">
      <template #below>
        <p class="pp-meta">
          <span class="badge" :class="TONE[d.pull.state]">{{ t(`pulls.state_${d.pull.state}`) }}</span>
          <span v-if="d.pull.draft" class="badge b-gray">{{ t('pulls.draft') }}</span>
          <span>{{ d.pull.author }}</span>
          <span class="mono">{{ d.pull.headRef }} → {{ d.pull.baseRef }}</span>
          <span>{{ d.repoName }}</span>
          <span>{{ t('pulls.updated', { time: ago(d.pull.updatedAt, locale) }) }}</span>
        </p>
      </template>
      <div class="actions" style="margin: 0">
        <button v-if="canAsk" class="btn btn-p" type="button" @click="asking = true">
          {{ d.ticketKey ? t('drafts.reviewAgainBtn') : t('drafts.reviewWithBtn') }}
        </button>
        <RouterLink v-if="d.ticketKey" class="btn" :to="{ name: 'ticket', params: { key: d.ticketKey } }">
          {{ d.own ? t('pulls.ownTicket', { key: d.ticketKey }) : t('pulls.reviewTicket', { key: d.ticketKey }) }}
        </RouterLink>
        <a class="btn" :href="d.pull.url" target="_blank" rel="noopener">{{ t('reviews.openOn', { host }) }}</a>
      </div>
    </PageHeader>
    <ReviewPullDialog v-model="asking" :repo-id="repoId" :number="number" />

    <section v-if="d.body?.trim()" class="card">
      <CommentBody :markdown="d.body" />
    </section>
    <div v-if="d.filesError" class="help warn"><HiIcon name="info" /><p>{{ t('pulls.filesError', { error: d.filesError }) }}</p></div>

    <div v-if="reviewing" class="help info pp-busy">
      <span class="spin" aria-hidden="true" />
      <p>{{ t('drafts.reviewingNow', { key: d.ticketKey ?? '' }) }}</p>
    </div>
    <section v-if="d.ticketKey && drafts?.length" class="card">
      <ReviewDraftsPanel
        :ticket-key="d.ticketKey"
        :drafts="drafts"
        :listed="listed"
        :host="host"
        :head-sha="d.pull.headSha"
        :can-edit="workspace.canEdit"
        :locked="locked"
        :own="!!d.login && d.login.toLowerCase() === d.pull.author.toLowerCase()"
      />
    </section>

    <section class="card">
      <PullConversation
        :key="d.ticketKey ?? 'none'"
        :repo-id="repoId"
        :number="number"
        :provider="d.provider"
        :login="d.login"
        :head-sha="d.pull.headSha"
        :files="d.files"
        :can-edit="workspace.canEdit"
        :ticket-key="d.ticketKey"
        :drafts="drafts"
        :drafts-locked="locked"
      />
    </section>
  </template>
</template>

<style scoped>
.pp-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 6px 12px; margin: 6px 0 0; font-size: 13.5px; color: var(--ink-3); }
.pp-meta .mono { overflow-wrap: anywhere; }
.pp-busy { align-items: center; }
</style>
