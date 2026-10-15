<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, unwrap } from '../api/client'
import PageHeader from '../components/PageHeader.vue'
import CommentBody from '../components/pulls/CommentBody.vue'
import PullConversation from '../components/pulls/PullConversation.vue'
import { hostName, pullKey } from '../components/pulls/usePull'
import HiIcon from '../components/ui/HiIcon.vue'
import { ago } from '../composables/format'
import { livePoll } from '../composables/useLive'
import { useWorkspace } from '../stores/workspace'

// One pull request (GitLab merge request) as it stands on the git host:
// its description, conversation and diff, with comments made here going
// out as the git host token's user.
const { t, locale } = useI18n()
const route = useRoute()
const workspace = useWorkspace()
const repoId = computed(() => Number(route.params.id))
const number = computed(() => Number(route.params.number))

const pull = useQuery({
  queryKey: computed(() => pullKey(repoId.value, number.value, 'detail')),
  queryFn: () => unwrap(api.GET('/repos/{id}/pulls/{number}', { params: { path: { id: repoId.value, number: number.value } } })),
  refetchInterval: () => livePoll(60_000),
})
const d = computed(() => pull.data.value)
const TONE: Record<string, string> = { open: 'b-info', merged: 'b-ok', closed: 'b-gray' }
const errMsg = (e: unknown) => (e instanceof Error && e.message ? e.message : t('common.error'))
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
        <RouterLink v-if="d.ticketKey" class="btn" :to="{ name: 'ticket', params: { key: d.ticketKey } }">
          {{ d.own ? t('pulls.ownTicket', { key: d.ticketKey }) : t('pulls.reviewTicket', { key: d.ticketKey }) }}
        </RouterLink>
        <a class="btn" :href="d.pull.url" target="_blank" rel="noopener">{{ t('reviews.openOn', { host: hostName(d.provider) }) }}</a>
      </div>
    </PageHeader>

    <section v-if="d.body?.trim()" class="card">
      <CommentBody :markdown="d.body" />
    </section>
    <div v-if="d.filesError" class="help warn"><HiIcon name="info" /><p>{{ t('pulls.filesError', { error: d.filesError }) }}</p></div>

    <section class="card">
      <PullConversation
        :repo-id="repoId"
        :number="number"
        :provider="d.provider"
        :login="d.login"
        :head-sha="d.pull.headSha"
        :files="d.files"
        :can-edit="workspace.canEdit"
      />
    </section>
  </template>
</template>

<style scoped>
.pp-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 6px 12px; margin: 6px 0 0; font-size: 13.5px; color: var(--ink-3); }
.pp-meta .mono { overflow-wrap: anywhere; }
</style>
