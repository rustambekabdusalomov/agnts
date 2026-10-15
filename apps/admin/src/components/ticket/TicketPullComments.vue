<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, toRef } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { pullHost, type PullThread, type Ticket } from '../../api/types'
import { askConfirm } from '../../composables/useConfirm'
import { useUi } from '../../stores/ui'
import { useWorkspace } from '../../stores/workspace'
import PullConversation from '../pulls/PullConversation.vue'
import { usePullThreads } from '../pulls/usePull'

// The conversation of a ticket's pull request on the git host: the one a
// review ticket reviews, or the one agnts opened. On agnts's own, the
// reviewers' unresolved threads can go back to coding ("Address").
const props = defineProps<{ ticket: Ticket; repoId: number; number: number; url?: string; repoName?: string }>()
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const workspace = useWorkspace()
const open = ref(true)
const own = computed(() => props.ticket.kind !== 'review')
const host = computed(() => pullHost(props.url))
const repoId = toRef(props, 'repoId')
const number = toRef(props, 'number')
const threads = usePullThreads(repoId, number)

// Mirrors the server: someone else's unresolved thread, not answered by
// agnts last, and not sent back already.
const fromReviewer = (th: PullThread) => {
  const first = th.comments[0]
  const last = th.comments[th.comments.length - 1]
  if (!first || th.resolved || first.mine || first.system || first.agnts || /\[bot\]$/i.test(first.author)) return false
  if (th.kind === 'review' && th.reviewState === 'APPROVED' && !first.body.trim()) return false
  return !last.agnts
}
const fresh = computed(() => (own.value ? (threads.data.value ?? []).filter((th) => fromReviewer(th) && !th.sent) : []))
const canAddress = computed(
  () =>
    own.value &&
    workspace.canEdit &&
    fresh.value.length > 0 &&
    (props.ticket.state === 'waiting_for_review' || (props.ticket.state === 'done' && !props.ticket.mergedAt)),
)
const address = useMutation({
  mutationFn: () => unwrap(api.POST('/tickets/{key}/address-comments', { params: { path: { key: props.ticket.key } } })),
  onSuccess: () => {
    ui.notify(t('pulls.addressed', { n: fresh.value.length }))
    void qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] })
    void qc.invalidateQueries({ queryKey: ['pull'] })
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
async function confirmAddress() {
  const label = t('pulls.addressBtn', { n: fresh.value.length })
  if (await askConfirm({ title: label, message: t('pulls.addressConfirm', { key: props.ticket.key, n: fresh.value.length }), confirmLabel: label })) address.mutate()
}
</script>

<template>
  <section class="card">
    <div class="ch">
      <div>
        <h2>
          <button type="button" class="tpc-tg" :aria-expanded="open" @click="open = !open">{{ t('pulls.ticketTitle', { number, host }) }}</button>
        </h2>
        <p class="sub">{{ repoName ? t('pulls.ticketSubIn', { repo: repoName }) : own ? t('pulls.ticketSubOwn') : t('pulls.ticketSubReview') }}</p>
      </div>
      <div class="actions" style="margin: 0">
        <button v-if="canAddress" type="button" class="btn btn-p btn-s" :disabled="address.isPending.value" @click="confirmAddress">
          {{ t('pulls.addressBtn', { n: fresh.length }) }}
        </button>
        <RouterLink class="btn btn-s" :to="{ name: 'pull', params: { id: repoId, number } }">{{ t('pulls.openWithDiff') }}</RouterLink>
      </div>
    </div>
    <p v-if="own && fresh.length && !canAddress" class="hint">{{ t('pulls.addressLater', { n: fresh.length }) }}</p>
    <PullConversation v-if="open" :repo-id="repoId" :number="number" :provider="host.toLowerCase()" :can-edit="workspace.canEdit" />
  </section>
</template>

<style scoped>
.tpc-tg { background: none; border: 0; padding: 0; font: inherit; color: inherit; cursor: pointer; text-align: left; }
.tpc-tg::after { content: ' ▾'; color: var(--ink-3); font-size: 0.8em; }
.tpc-tg[aria-expanded='false']::after { content: ' ▸'; }
</style>
