<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import type { components } from '../../api/schema.gen'
import CfgRow from '../form/CfgRow.vue'
import SegButtons from '../form/SegButtons.vue'

type State = components['schemas']['ClaudeConnectionState']
type Kind = 'subscription' | 'api_key'

// A Claude account's state and the form to connect or replace it (the
// workspace's in its settings, a person's in their profile).
const props = defineProps<{ state?: State; subscriptions: boolean; busy?: boolean; readonly?: boolean; error?: string }>()
const emit = defineEmits<{ connect: [kind: Kind, token: string]; disconnect: [] }>()
const { t } = useI18n()
const when = (s: string) => new Date(s).toLocaleString([], { dateStyle: 'medium', timeStyle: 'short' })

const kind = ref<Kind>(props.subscriptions ? 'subscription' : 'api_key')
const token = ref('')
const editing = ref(false)
const kinds = computed(() => [
  ...(props.subscriptions ? [{ value: 'subscription' as Kind, label: t('ws.kindSubscription') }] : []),
  { value: 'api_key' as Kind, label: t('ws.kindApiKey') },
])
const pct = (v?: number) => (v === undefined ? '' : `${Math.round(v * 100)}%`)

function submit() {
  if (token.value.trim().length < 10) return
  emit('connect', kind.value, token.value.trim())
  token.value = ''
  editing.value = false
}
</script>

<template>
  <div>
    <CfgRow :label="state?.connected ? t('ws.connected') : t('ws.notConnected')">
      <span class="row-actions">
        <span v-if="state?.connected" class="badge" :class="state.pausedUntil ? 'b-warn' : 'b-ok'">
          {{ state.kind === 'api_key' ? t('ws.kindApiKey') : t('ws.kindSubscription') }}<template v-if="state.tokenHint"> · …{{ state.tokenHint }}</template>
        </span>
        <span v-else class="badge b-gray">{{ t('ws.notConnected') }}</span>
        <template v-if="!readonly">
          <button v-if="!editing" type="button" class="btn btn-s" @click="editing = true">{{ state?.connected ? t('ws.replace') : t('ws.connect') }}</button>
          <button v-if="state?.connected && !editing" type="button" class="btn btn-s btn-d" :disabled="busy" @click="emit('disconnect')">{{ t('ws.disconnect') }}</button>
        </template>
      </span>
    </CfgRow>
    <p v-if="state?.pausedUntil" class="hint">{{ t('ws.pausedUntil', { time: when(state.pausedUntil) }) }}</p>
    <p v-if="state?.usage && state.usage.fiveHour.utilization !== undefined" class="hint">
      {{ t('nav.session') }}: {{ pct(state.usage.fiveHour.utilization) }}<template v-if="state.usage.sevenDay.utilization !== undefined"> · {{ t('nav.week') }}: {{ pct(state.usage.sevenDay.utilization) }}</template>
    </p>
    <p v-if="state?.lastError" class="ferr">{{ state.lastError }}</p>
    <form v-if="editing && !readonly" class="stack" style="margin-top: 12px; gap: 10px" @submit.prevent="submit">
      <p v-if="!subscriptions" class="hint">{{ t('ws.subscriptionsOff') }}</p>
      <SegButtons v-model="kind" :options="kinds" :label="t('ws.kind')" />
      <p class="hint">{{ kind === 'subscription' ? t('ws.kindSubscriptionHelp') : t('ws.kindApiKeyHelp') }}</p>
      <input v-model="token" class="cfg-in mono" type="password" autocomplete="off" :placeholder="kind === 'subscription' ? 'sk-ant-oat…' : 'sk-ant-api…'" :aria-label="t('ws.token')">
      <p v-if="error" class="ferr">{{ error }}</p>
      <span class="row-actions" style="justify-content: flex-start">
        <button type="submit" class="btn btn-p btn-s" :disabled="busy || token.trim().length < 10">{{ t('ws.connect') }}</button>
        <button type="button" class="btn btn-s" @click="editing = false">{{ t('form.cancel') }}</button>
      </span>
    </form>
  </div>
</template>
