<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { isReport, type TicketDetail } from '../../api/types'
import { askConfirm } from '../../composables/useConfirm'
import { useUi } from '../../stores/ui'
import RepoDiffs from '../ticket/RepoDiffs.vue'
import ReportView from '../ticket/ReportView.vue'

// The work of a Code conversation's ticket, waiting for the person: what
// changed, how the checks went, the diff, and Approve or Reject. Both are
// the ticket's own actions, asked once more before they happen.
const props = defineProps<{ detail: TicketDetail }>()
const emit = defineEmits<{ decided: [] }>()
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()

const tk = computed(() => props.detail.ticket)
const result = computed(() => props.detail.result)
const report = computed(() => isReport(tk.value))
const files = computed(() => result.value?.files ?? [])
const added = computed(() => files.value.reduce((n, f) => n + f.add, 0))
const removed = computed(() => files.value.reduce((n, f) => n + f.del, 0))
const checks = computed(() => result.value?.checks ?? [])
const failed = computed(() => checks.value.filter((c) => c.exitCode !== 0).length)
const showDiff = ref(false)

const act = useMutation({
  mutationFn: (a: 'approve' | 'reject') => {
    const path = { params: { path: { key: tk.value.key } } }
    return a === 'approve'
      ? unwrap(api.POST('/tickets/{key}/approve', { ...path, body: report.value ? { postReport: false } : {} }))
      : unwrap(api.POST('/tickets/{key}/reject', { ...path, body: {} }))
  },
  onSuccess: () => {
    void qc.invalidateQueries({ queryKey: ['ticket', tk.value.key] })
    void qc.invalidateQueries({ queryKey: ['assistant'] })
    emit('decided')
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

async function approve() {
  const message = report.value
    ? t('codechat.approveReport')
    : tk.value.afterApprove === 'main'
      ? t('codechat.approveMain')
      : t('codechat.approvePr', { branch: tk.value.branch ?? '' })
  if (await askConfirm({ title: t('codechat.approveTitle', { key: tk.value.key }), message, confirmLabel: t('codechat.approve') })) act.mutate('approve')
}

async function reject() {
  const ok = await askConfirm({
    title: t('codechat.rejectTitle', { key: tk.value.key }), message: t('codechat.rejectText'), confirmLabel: t('codechat.reject'), danger: true,
  })
  if (ok) act.mutate('reject')
}
</script>

<template>
  <div class="cr card-in">
    <b class="cr-title">{{ report ? t('codechat.reportTitle', { key: tk.key }) : t('codechat.resultTitle', { key: tk.key }) }}</b>
    <ReportView v-if="report && result?.report" :markdown="result.report" />
    <ReportView v-else-if="result?.summary" :markdown="result.summary" />
    <div v-if="!report" class="cr-facts">
      <span>{{ t('codechat.filesChanged', { n: files.length }) }} <span class="add">+{{ added }}</span> <span class="del">−{{ removed }}</span></span>
      <span v-if="tk.skipChecks" class="badge b-gray">{{ t('codechat.checksSkipped') }}</span>
      <span v-else-if="checks.length && failed" class="badge b-bad">{{ t('codechat.checksFailed', { failed, n: checks.length }) }}</span>
      <span v-else-if="checks.length" class="badge b-ok">{{ t('codechat.checksPassed') }}</span>
    </div>
    <ul v-if="result?.notes?.length" class="cr-notes">
      <li v-for="(n, i) in result.notes" :key="i">{{ n }}</li>
    </ul>
    <div class="cr-btns">
      <button type="button" class="btn btn-p" :disabled="act.isPending.value" @click="approve">{{ t('codechat.approve') }}</button>
      <button type="button" class="btn btn-d" :disabled="act.isPending.value" @click="reject">{{ t('codechat.reject') }}</button>
      <button v-if="files.length" type="button" class="btn" :aria-expanded="showDiff" @click="showDiff = !showDiff">
        {{ showDiff ? t('codechat.hideDiff') : t('codechat.viewDiff') }}
      </button>
      <RouterLink class="btn" :to="{ name: 'ticket', params: { key: tk.key } }">{{ t('codechat.openTicket') }}</RouterLink>
    </div>
    <div v-if="showDiff" class="cr-diff"><RepoDiffs :files="files" open-first /></div>
  </div>
</template>

<style scoped>
.cr { display: flex; flex-direction: column; gap: 8px; padding: 14px 16px; border-radius: 16px; border: 1px solid var(--primary); background: var(--surface); }
.cr-title { font-size: 15px; }
.cr-facts { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; font-size: 14px; }
.add { color: var(--ok-ink); font-weight: 700; }
.del { color: var(--bad-ink); font-weight: 700; }
.cr-notes { margin: 0; padding-left: 18px; color: var(--ink-2); font-size: 14px; }
.cr-btns { display: flex; flex-wrap: wrap; gap: 8px; }
.cr-diff { margin-top: 4px; max-height: 60vh; overflow: auto; }
</style>
