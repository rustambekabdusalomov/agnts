<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import type { components } from '../../api/schema.gen'
import CfgRow from '../form/CfgRow.vue'
import CopyField from '../form/CopyField.vue'
import SegButtons from '../form/SegButtons.vue'
import HiIcon from '../ui/HiIcon.vue'
import CopyButton from '../ui/CopyButton.vue'

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
// "How to get the token": a plan token from Claude Code, or a key from the Console.
const steps = computed(() =>
  kind.value === 'subscription'
    ? [1, 2, 3, 4].map((n) => t(`integrations.tokenStep${n}_claude`))
    : [1, 2, 3, 4].map((n) => t(`ws.keyStep${n}`)),
)
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
    <div v-if="state?.lastError" class="err-row"><p class="ferr err-text">{{ state.lastError }}</p><CopyButton :text="state.lastError" /></div>
    <form v-if="editing && !readonly" class="stack" style="margin-top: 12px; gap: 10px" @submit.prevent="submit">
      <p v-if="!subscriptions" class="hint">{{ t('ws.subscriptionsOff') }}</p>
      <SegButtons v-model="kind" :options="kinds" :label="t('ws.kind')" />
      <div class="help token-how">
        <HiIcon name="info" />
        <div>
          <b>{{ t('integrations.tokenHow') }}</b>
          <ol>
            <li v-for="(step, i) in steps" :key="i">{{ step }}</li>
          </ol>
          <CopyField v-if="kind === 'subscription'" :label="t('integrations.tokenCommand')" value="claude setup-token" />
          <div v-else class="actions" style="margin: 0">
            <a class="btn" href="https://console.anthropic.com/settings/keys" target="_blank" rel="noopener noreferrer">{{ t('ws.keyOpen') }} ↗</a>
          </div>
        </div>
      </div>
      <input v-model="token" class="cfg-in mono" type="password" autocomplete="off" :placeholder="kind === 'subscription' ? 'sk-ant-oat…' : 'sk-ant-api…'" :aria-label="t('ws.token')">
      <p v-if="error" class="ferr">{{ error }}</p>
      <span class="row-actions" style="justify-content: flex-start">
        <button type="submit" class="btn btn-p btn-s" :disabled="busy || token.trim().length < 10">{{ t('ws.connect') }}</button>
        <button type="button" class="btn btn-s" @click="editing = false">{{ t('form.cancel') }}</button>
      </span>
    </form>
  </div>
</template>
