<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Integration } from '../../api/types'
import { useUi } from '../../stores/ui'
import CfgRow from '../form/CfgRow.vue'
import CopyField from '../form/CopyField.vue'
import HiIcon from '../ui/HiIcon.vue'

// Plane generates the webhook secret, unlike Jira: the URL goes into Plane,
// and the secret Plane shows comes back here.
const props = defineProps<{ integration: Integration }>()
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()

const secret = ref('')
const editing = ref(!props.integration.webhookSecretSet)
const error = ref('')

const save = useMutation({
  mutationFn: () => unwrap(api.PUT('/integrations/plane/webhook-secret', { body: { secret: secret.value.trim() } })),
  onSuccess: () => {
    void qc.invalidateQueries({ queryKey: ['integrations'] })
    secret.value = ''
    error.value = ''
    editing.value = false
    ui.notify(t('integrations.planeSecretSaved'))
  },
  onError: (e) => {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})
</script>

<template>
  <section class="card">
    <div class="ch">
      <div><h2>{{ t('integrations.planeWebhookTitle') }}</h2><p class="sub">{{ t('integrations.planeWebhookSteps') }}</p></div>
      <span v-if="integration.webhookSecretSet" class="badge b-ok">{{ t('integrations.connected') }}</span>
    </div>
    <CopyField v-if="integration.webhookUrl" :label="t('integrations.webhookUrl')" :value="integration.webhookUrl" />
    <div class="mini-kv"><span>{{ t('integrations.events') }}</span><b>{{ t('integrations.planeEventsValue') }}</b></div>
    <form v-if="editing" @submit.prevent="save.mutate()">
      <CfgRow :label="t('integrations.planeSecret')" :help="t('integrations.planeSecretHelp')">
        <input v-model="secret" class="cfg-in mono" type="password" required minlength="8" autocomplete="off" :aria-label="t('integrations.planeSecret')">
      </CfgRow>
      <p v-if="error" class="ferr" role="alert">{{ error }}</p>
      <div class="actions">
        <button type="submit" class="btn btn-p" :disabled="save.isPending.value">{{ t('integrations.planeSecretSave') }}</button>
      </div>
    </form>
    <div v-else class="actions" style="justify-content: space-between; align-items: center">
      <p class="hint" style="margin: 0">{{ t('integrations.planeSecretSet') }}</p>
      <button type="button" class="btn" @click="editing = true">{{ t('integrations.planeSecretReplace') }}</button>
    </div>
    <div v-if="!integration.webhookSecretSet" class="help warn" style="margin-top: 8px"><HiIcon name="info" /><p>{{ t('integrations.planeSecretMissing') }}</p></div>
  </section>
</template>
