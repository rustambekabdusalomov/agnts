<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, onBeforeUnmount, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { CodeApproval } from '../../api/types'
import { useUi } from '../../stores/ui'

// A tool call the agent waits on: a rule says to ask the person first
// (installing a dependency, say). Nobody answering in time denies it.
const props = defineProps<{ approval: CodeApproval }>()
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()

const now = ref(Date.now())
const tick = setInterval(() => (now.value = Date.now()), 1000)
onBeforeUnmount(() => clearInterval(tick))
const left = computed(() => Math.max(0, Math.round((new Date(props.approval.expiresAt).getTime() - now.value) / 1000)))
const status = computed(() => (props.approval.status === 'pending' && left.value === 0 ? 'expired' : props.approval.status))

const decide = useMutation({
  mutationFn: (allow: boolean) =>
    unwrap(api.POST('/assistant/approvals/{approvalId}', { params: { path: { approvalId: props.approval.id } }, body: { allow } })),
  onSettled: () => qc.invalidateQueries({ queryKey: ['assistant'] }),
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
</script>

<template>
  <div class="ca" :class="status">
    <b>{{ t('codechat.approvalTitle') }}</b>
    <code class="ca-what">{{ approval.command || approval.path || approval.tool }}</code>
    <p class="hint">{{ t('codechat.approvalReason', { reason: approval.reason }) }}</p>
    <div v-if="status === 'pending'" class="ca-btns">
      <button type="button" class="btn btn-p btn-s" :disabled="decide.isPending.value" @click="decide.mutate(true)">{{ t('codechat.approvalAllow') }}</button>
      <button type="button" class="btn btn-s" :disabled="decide.isPending.value" @click="decide.mutate(false)">{{ t('codechat.approvalDeny') }}</button>
      <span class="hint">{{ t('codechat.approvalLeft', { seconds: left }) }}</span>
    </div>
    <span v-else class="badge" :class="status === 'allowed' ? 'b-ok' : 'b-gray'">
      {{ t(status === 'allowed' ? 'codechat.approvalAllowed' : status === 'denied' ? 'codechat.approvalDenied' : 'codechat.approvalExpired') }}
    </span>
  </div>
</template>

<style scoped>
.ca { display: flex; flex-direction: column; gap: 6px; padding: 12px 14px; border-radius: 14px; border: 1px solid var(--warn); background: var(--warn-soft); }
.ca.allowed, .ca.denied, .ca.expired { border-color: var(--line); background: var(--surface); }
.ca-what { font-family: var(--mono); font-size: 13px; white-space: pre-wrap; overflow-wrap: anywhere; }
.ca p { margin: 0; }
.ca-btns { display: flex; align-items: center; gap: 8px; }
.ca .badge { align-self: flex-start; }
</style>
