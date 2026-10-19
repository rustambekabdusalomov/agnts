<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, unwrap } from '../api/client'
import type { ReviewDraft } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import StateBadge from '../components/StateBadge.vue'
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
// out as the git host token's user. "Review with agnts" starts a new review
// of it as it stands now, whenever no review runs (after new commits, say);
// the reviews so far are listed, newest first, and the newest one's
// comments stay drafts here until accepted and published.
const { t, locale } = useI18n()
const route = useRoute()
const workspace = useWorkspace()
const repoId = computed(() => Number(route.params.id))
const number = computed(() => Number(route.params.number))
const asking = ref(false)

const RUNNING = ['new', 'analyzing', 'coding', 'testing', 'pushing']
const pull = useQuery({
  queryKey: computed(() => pullKey(repoId.value, number.value, 'detail')),
  queryFn: () => unwrap(api.GET('/repos/{id}/pulls/{number}', { params: { path: { id: repoId.value, number: number.value } } })),
  // Faster while agnts is reviewing, so its drafts show up when ready.
  refetchInterval: (q): number => livePoll(RUNNING.includes(q.state.data?.reviews?.[0]?.state ?? '') ? 10_000 : 60_000),
})
const d = computed(() => pull.data.value)
const TONE: Record<string, string> = { open: 'b-info', merged: 'b-ok', closed: 'b-gray' }
const errMsg = (e: unknown) => (e instanceof Error && e.message ? e.message : t('common.error'))
const host = computed(() => hostName(d.value?.provider))

// Its reviews, newest first. A new one can be asked for on an open pull
// request (agnts's own included) whenever none runs.
const reviews = computed(() => d.value?.reviews ?? [])
const latest = computed(() => reviews.value[0])
const reviewing = computed(() => RUNNING.includes(latest.value?.state ?? ''))
const canAsk = computed(() => workspace.canEdit && d.value?.pull.state === 'open' && !reviewing.value)
const drafts = computed<ReviewDraft[] | undefined>(() => (latest.value ? d.value?.drafts ?? undefined : undefined))
const locked = computed(() => d.value?.pull.state !== 'open' || latest.value?.state === 'rejected')
const short = (sha?: string) => (sha ?? '').slice(0, 7)

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
          {{ latest ? t('drafts.reviewAgainBtn') : t('drafts.reviewWithBtn') }}
        </button>
        <RouterLink v-if="d.own && d.ticketKey" class="btn" :to="{ name: 'ticket', params: { key: d.ticketKey } }">
          {{ t('pulls.ownTicket', { key: d.ticketKey }) }}
        </RouterLink>
        <a class="btn" :href="d.pull.url" target="_blank" rel="noopener">{{ t('reviews.openOn', { host }) }}</a>
      </div>
    </PageHeader>
    <ReviewPullDialog v-model="asking" :repo-id="repoId" :number="number" />

    <section v-if="d.body?.trim()" class="card">
      <CommentBody :markdown="d.body" />
    </section>
    <div v-if="d.filesError" class="help warn"><HiIcon name="info" /><p>{{ t('pulls.filesError', { error: d.filesError }) }}</p></div>

    <section class="card">
      <div class="ch"><h2>{{ t('reviews.history') }} <span v-if="reviews.length" class="tk-n">{{ reviews.length }}</span></h2></div>
      <p v-if="!reviews.length" class="hint" style="margin: 0">{{ t('reviews.historyEmpty') }}</p>
      <div v-else class="tw">
        <table class="tbl">
          <tbody>
            <tr v-for="(r, i) in reviews" :key="r.key">
              <td><RouterLink :to="{ name: 'ticket', params: { key: r.key } }" class="mono">{{ r.key }}</RouterLink></td>
              <td>
                <StateBadge :state="r.state" kind="review" />
                <span v-if="i === 0 && r.headSha && r.headSha !== d.pull.headSha" class="badge b-warn">{{ t('reviews.newCommits') }}</span>
              </td>
              <td class="muted mono">{{ r.headSha ? t('reviews.reviewedAt', { sha: short(r.headSha) }) : '' }}</td>
              <td class="muted">{{ ago(r.createdAt, locale) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <div v-if="reviewing" class="help info pp-busy">
      <span class="spin" aria-hidden="true" />
      <p>{{ t('drafts.reviewingNow', { key: latest?.key ?? '' }) }}</p>
    </div>
    <section v-if="latest && drafts?.length" class="card">
      <ReviewDraftsPanel
        :ticket-key="latest.key"
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
        :key="latest?.key ?? 'none'"
        :repo-id="repoId"
        :number="number"
        :provider="d.provider"
        :login="d.login"
        :head-sha="d.pull.headSha"
        :files="d.files"
        :can-edit="workspace.canEdit"
        :ticket-key="latest?.key"
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
