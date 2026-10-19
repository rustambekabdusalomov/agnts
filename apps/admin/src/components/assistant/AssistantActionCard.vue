<script setup lang="ts">
import { useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import type { AssistantAction } from '../../api/types'
import { askConfirm } from '../../composables/useConfirm'
import { actionStatus } from './assistant'

// An action an answer proposes: agnts's summary of what it does, and
// Confirm and Decline while it waits; then what became of it. Approve and
// reject ask once more before they run.
const props = defineProps<{ action: AssistantAction }>()
const { t } = useI18n()
const qc = useQueryClient()

const status = computed(() => actionStatus(props.action))
const busy = ref(false)
const error = ref('')

async function decide(confirm: boolean) {
  const a = props.action
  if (confirm && a.destructive && !(await askConfirm({
    title: t('massistant.actionConfirmTitle'),
    message: t('massistant.actionConfirmText', { summary: a.summary }),
    confirmLabel: t('massistant.actionConfirm'),
    danger: true,
  }))) return
  busy.value = true
  error.value = ''
  try {
    const path = { params: { path: { actionId: a.id } } }
    await unwrap(confirm ? api.POST('/assistant/actions/{actionId}/confirm', path) : api.POST('/assistant/actions/{actionId}/cancel', path))
  } catch (e) {
    error.value = e instanceof Error ? e.message : t('common.error')
  } finally {
    busy.value = false
    await qc.invalidateQueries({ queryKey: ['assistant', 'conversation', a.conversationId] })
  }
}
</script>

<template>
  <div class="aa" :class="[status, { danger: action.destructive && status === 'proposed' }]">
    <p class="aa-sum">{{ action.summary }}</p>
    <template v-if="status === 'proposed'">
      <p class="hint">{{ t('massistant.actionHint') }}</p>
      <div class="aa-b">
        <button type="button" class="btn btn-s" :disabled="busy" @click="decide(false)">{{ t('massistant.actionDecline') }}</button>
        <button type="button" class="btn btn-s" :class="action.destructive ? 'btn-danger' : 'btn-p'" :disabled="busy" @click="decide(true)">
          {{ t('massistant.actionConfirm') }}
        </button>
      </div>
    </template>
    <p v-else-if="status === 'running'" class="aa-out"><span class="aa-spin" />{{ t('massistant.actionRunning') }}</p>
    <p v-else-if="status === 'done'" class="aa-out ok">
      <b>{{ t('massistant.actionDone') }}</b><span v-if="action.result"> · {{ action.result }}</span>
      <RouterLink v-if="action.ticketKey" class="aa-link" :to="{ name: 'ticket', params: { key: action.ticketKey } }">{{ action.ticketKey }}</RouterLink>
    </p>
    <p v-else-if="status === 'failed'" class="aa-out bad">
      <b>{{ t('massistant.actionFailed') }}</b><span v-if="action.result"> · {{ action.result }}</span>
    </p>
    <p v-else class="hint aa-out">{{ status === 'cancelled' ? t('massistant.actionCancelled') : t('massistant.actionExpired') }}</p>
    <p v-if="error" class="ferr">{{ error }}</p>
  </div>
</template>

<style scoped>
.aa { margin-top: 10px; padding: 10px 12px; border: 1px solid var(--line); border-radius: 12px; background: var(--bg); }
.aa.danger { border-color: var(--bad); }
.aa.cancelled .aa-sum, .aa.expired .aa-sum, .aa.failed .aa-sum { opacity: 0.6; }
.aa-sum { margin: 0 0 6px; white-space: pre-wrap; overflow-wrap: anywhere; }
.aa .hint { margin: 0; }
.aa-b { display: flex; gap: 8px; justify-content: flex-end; margin-top: 8px; }
.aa-out { display: flex; flex-wrap: wrap; align-items: center; gap: 4px; margin: 0; }
.aa-out.ok b { color: var(--ok-ink); }
.aa-out.bad b { color: var(--bad-ink); }
.aa-link { margin-left: 6px; padding: 2px 9px; border-radius: 999px; background: var(--primary-soft); color: var(--primary-ink); font-family: var(--mono); font-size: 13px; font-weight: 700; text-decoration: none; }
.aa-spin { width: 12px; height: 12px; margin-right: 6px; border-radius: 50%; border: 2px solid var(--line-3); border-top-color: var(--primary); animation: aa-spin 0.8s linear infinite; }
@keyframes aa-spin { to { transform: rotate(360deg); } }
</style>
