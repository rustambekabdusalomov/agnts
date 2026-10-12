<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import PageHeader from '../components/PageHeader.vue'
import CfgRow from '../components/form/CfgRow.vue'
import CopyField from '../components/form/CopyField.vue'
import ConnectForm from '../components/integrations/ConnectForm.vue'
import JiraSettings from '../components/integrations/JiraSettings.vue'
import PlaneSettings from '../components/integrations/PlaneSettings.vue'
import PlaneWebhook from '../components/integrations/PlaneWebhook.vue'
import ProviderTile from '../components/integrations/ProviderTile.vue'
import { isProvider, type Provider } from '../components/integrations/providers'
import { useIntegrations } from '../components/integrations/useIntegrations'
import HiIcon from '../components/ui/HiIcon.vue'
import { ago } from '../composables/format'
import { useUi } from '../stores/ui'
import { askConfirm } from '../composables/useConfirm'
import CopyButton from '../components/ui/CopyButton.vue'

const { t, locale } = useI18n()
const route = useRoute()
const qc = useQueryClient()
const ui = useUi()
const list = useIntegrations()

const provider = computed<Provider | null>(() => {
  const p = String(route.params.provider)
  return isProvider(p) && p !== 'claude' ? p : null
})
const integ = computed(() => list.data.value?.find((i) => i.provider === provider.value))
const name = computed(() => (provider.value ? t(`integrations.name_${provider.value}`) : ''))

// Shown once, right after connecting Jira.
const webhook = ref<{ url?: string; secret?: string } | null>(null)
function onConnected(url?: string, secret?: string) {
  if (provider.value === 'jira') webhook.value = { url, secret }
}

const invalidate = () => qc.invalidateQueries({ queryKey: ['integrations'] })
const onErr = (e: unknown) => ui.notify(e instanceof HttpError ? e.message : t('common.error'))
const path = () => ({ params: { path: { provider: provider.value as Provider } } })

const test = useMutation({
  mutationFn: () => unwrap(api.POST('/integrations/{provider}/test', path())),
  onSuccess: (v) => {
    void invalidate()
    ui.notify(v.lastError ? t('integrations.testFail', { name: name.value, error: v.lastError }) : t('integrations.testOk', { name: name.value }))
  },
  onError: onErr,
})
const disconnect = useMutation({
  mutationFn: () => unwrap(api.POST('/integrations/{provider}/disconnect', path())),
  onSuccess: () => {
    void invalidate()
    webhook.value = null
    ui.notify(t('integrations.disconnected', { name: name.value }))
  },
  onError: onErr,
})
const tracker = computed(() => provider.value === 'jira' || provider.value === 'plane')
const sync = useMutation({
  mutationFn: () => unwrap(provider.value === 'plane' ? api.POST('/integrations/plane/sync') : api.POST('/integrations/jira/sync')),
  onSuccess: (r) => {
    for (const k of ['tickets', 'nav', 'dashboard']) void qc.invalidateQueries({ queryKey: [k] })
    ui.notify(t(provider.value === 'plane' ? 'integrations.planeSynced' : 'integrations.synced', { found: r.found, created: r.created, updated: ('updated' in r ? r.updated : 0) ?? 0, waiting: ('waiting' in r ? r.waiting : 0) ?? 0 }))
  },
  onError: onErr,
})

// Telegram delivers updates only to a public https address; say so up front
// instead of letting the connect fail with Telegram's own error.
const insecureBase = computed(() => {
  const u = provider.value === 'telegram' ? integ.value?.webhookUrl : undefined
  return u && !u.startsWith('https://') ? u.replace(/\/webhooks\/telegram$/, '') : ''
})

async function confirmDisconnect() {
  if (await askConfirm({ title: t('integrations.disconnect'), message: t('integrations.disconnectConfirm', { name: name.value }), confirmLabel: t('integrations.disconnect'), danger: true })) disconnect.mutate()
}
const sideHelp = computed(() =>
  provider.value === 'jira'
    ? t('integrations.secretsHelp')
    : provider.value === 'plane'
      ? t('integrations.planeHelp')
      : provider.value === 'github'
      ? t('integrations.githubHelp')
      : provider.value === 'gitlab'
        ? t('integrations.gitlabHelp')
      : provider.value === 'telegram'
        ? t('integrations.telegramHelp')
      : provider.value === 'openai'
        ? t('integrations.openaiHelp')
        : t('integrations.claudeHelp'),
)
</script>

<template>
  <RouterLink class="back-btn" :to="{ name: 'integrations' }"><HiIcon name="back" />{{ t('integrations.back') }}</RouterLink>
  <p v-if="!provider" class="empty">{{ t('common.error') }}</p>
  <p v-else-if="list.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <template v-else>
    <PageHeader :title="name" doc="integrations">
      <template #below>
        <p>
          {{
            integ?.connected
              ? t('integrations.connectedAs', {
                account: integ.account ?? name,
                time: integ.checkedAt ? ago(integ.checkedAt, locale) : t('integrations.never'),
              })
              : t('integrations.notYet')
          }}
        </p>
      </template>
      <div v-if="integ?.connected" class="actions" style="margin: 0">
        <button v-if="tracker" type="button" class="btn" :disabled="sync.isPending.value" @click="sync.mutate()">
          {{ t('integrations.syncNow') }}
        </button>
        <button type="button" class="btn" :disabled="test.isPending.value" @click="test.mutate()">{{ t('integrations.test') }}</button>
        <button type="button" class="btn btn-d" :disabled="disconnect.isPending.value" @click="confirmDisconnect">
          {{ t('integrations.disconnect') }}
        </button>
      </div>
    </PageHeader>

    <div class="cfg-grid">
      <div class="col">
        <section v-if="webhook" class="card">
          <div class="ch"><div><h2>{{ t('integrations.webhookTitle') }}</h2><p class="sub">{{ t('integrations.webhookSteps') }}</p></div></div>
          <CopyField v-if="webhook.url" :label="t('integrations.webhookUrl')" :value="webhook.url" />
          <CopyField v-if="webhook.secret" :label="t('integrations.webhookSecret')" :value="webhook.secret" />
          <div class="mini-kv"><span>{{ t('integrations.events') }}</span><b>{{ t('integrations.eventsValue') }}</b></div>
          <div v-if="webhook.secret" class="help warn" style="margin-top: 8px"><HiIcon name="info" /><p>{{ t('integrations.webhookOnce') }}</p></div>
        </section>

        <div v-if="insecureBase" class="help warn">
          <HiIcon name="info" /><p>{{ t('integrations.telegramHttps', { url: insecureBase }) }}</p>
        </div>
        <ConnectForm v-if="!integ?.connected" :provider="provider" @connected="onConnected" />
        <template v-else>
          <section class="card">
            <div class="ch">
              <div><h2>{{ t('integrations.connection') }}</h2></div>
              <span class="badge b-ok">{{ t('integrations.connected') }}</span>
            </div>
            <CfgRow v-if="integ.settings.site" :label="t('integrations.site')"><span class="conn">{{ integ.settings.site }}</span></CfgRow>
            <CfgRow v-if="integ.settings.url" :label="t('integrations.gitlabUrl')"><span class="conn">{{ integ.settings.url }}</span></CfgRow>
            <template v-if="provider === 'plane'">
              <CfgRow :label="t('integrations.planeBaseUrl')"><span class="conn">{{ integ.settings.base_url || 'https://api.plane.so' }}</span></CfgRow>
              <CfgRow v-if="integ.settings.workspace" :label="t('integrations.planeWorkspace')"><span class="conn">{{ integ.settings.workspace }}</span></CfgRow>
            </template>
            <CfgRow v-if="integ.account" :label="t('integrations.account')"><span class="conn">{{ integ.account }}</span></CfgRow>
            <CfgRow v-if="integ.tokenHint" :label="t('integrations.token')" :help="t('integrations.tokenHelp')">
              <span class="conn">•••• {{ integ.tokenHint }}</span>
            </CfgRow>
            <CfgRow :label="t('integrations.lastChecked')">
              <span class="conn">{{ integ.checkedAt ? ago(integ.checkedAt, locale) : t('integrations.never') }}</span>
            </CfgRow>
            <div v-if="integ.lastError" class="err-row"><p class="ferr err-text">{{ t('integrations.lastError') }}: {{ integ.lastError }}</p><CopyButton :text="integ.lastError" /></div>
          </section>
          <JiraSettings v-if="provider === 'jira'" :integration="integ" />
          <template v-if="provider === 'plane'">
            <PlaneWebhook :integration="integ" />
            <PlaneSettings :integration="integ" />
          </template>
          <section v-if="(provider === 'github' || provider === 'gitlab') && integ.webhookSecret" class="card">
            <div class="ch"><div><h2>{{ t('integrations.webhook') }}</h2><p class="sub">{{ t(`integrations.gitWebhookSteps_${provider}`) }}</p></div></div>
            <CopyField v-if="integ.webhookUrl" :label="t('integrations.webhookUrl')" :value="integ.webhookUrl" />
            <CopyField :label="t('integrations.webhookSecret')" :value="integ.webhookSecret" />
            <div class="mini-kv"><span>{{ t('integrations.events') }}</span><b>{{ t(`integrations.gitEvents_${provider}`) }}</b></div>
            <p class="hint" style="margin: 8px 0 0">{{ t('integrations.gitWebhookWhy') }}</p>
          </section>
        </template>
      </div>
      <aside class="cfg-side">
        <section class="card">
          <div class="ic-h"><ProviderTile :provider="provider" :size="48" /><div><h2>{{ name }}</h2></div></div>
          <p class="sub" style="margin: 10px 0 0">{{ t(`integrations.desc_${provider}`) }}</p>
        </section>
        <section v-if="provider === 'jira' && integ?.connected" class="card">
          <div class="ch"><div><h2>{{ t('integrations.webhook') }}</h2></div></div>
          <CopyField v-if="integ.webhookUrl" :label="t('integrations.webhookUrl')" :value="integ.webhookUrl" />
          <p class="hint" style="margin: 8px 0 0">{{ t('integrations.syncHelp') }}</p>
        </section>
        <section v-if="provider === 'plane' && integ?.connected" class="card">
          <div class="ch"><div><h2>{{ t('integrations.sync') }}</h2></div></div>
          <p class="hint" style="margin: 0">{{ t('integrations.planeSyncHelp') }}</p>
        </section>
        <div class="help"><HiIcon name="info" /><p>{{ sideHelp }}</p></div>
      </aside>
    </div>
  </template>
</template>
