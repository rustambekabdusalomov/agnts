<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../api/client'
import PageHeader from '../components/PageHeader.vue'
import ProviderTile from '../components/integrations/ProviderTile.vue'
import { PROVIDERS, type Provider } from '../components/integrations/providers'
import { useIntegrations } from '../components/integrations/useIntegrations'
import { ago } from '../composables/format'
import { useUi } from '../stores/ui'
import CopyButton from '../components/ui/CopyButton.vue'

const { t, locale } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const list = useIntegrations()
const find = (p: Provider) => list.data.value?.find((i) => i.provider === p)

const test = useMutation({
  mutationFn: (p: Provider) => unwrap(api.POST('/integrations/{provider}/test', { params: { path: { provider: p } } })),
  onSuccess: (v) => {
    void qc.invalidateQueries({ queryKey: ['integrations'] })
    const name = t(`integrations.name_${v.provider}`)
    ui.notify(v.lastError ? t('integrations.testFail', { name, error: v.lastError }) : t('integrations.testOk', { name }))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
</script>

<template>
  <PageHeader :title="t('integrations.title')" doc="integrations" />
  <p v-if="list.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <div v-else class="integ-grid">
    <section v-for="p in PROVIDERS.filter((x) => x !== 'claude')" :key="p" class="card integ-card">
      <div class="ic-h">
        <ProviderTile :provider="p" />
        <div>
          <h2>{{ t(`integrations.name_${p}`) }}</h2>
          <span class="badge" :class="find(p)?.connected ? 'b-ok' : 'b-gray'">
            {{ find(p)?.connected ? t('integrations.connected') : t('integrations.notConnected') }}
          </span>
        </div>
      </div>
      <p class="sub" style="margin: 10px 0 8px">{{ t(`integrations.desc_${p}`) }}</p>
      <template v-if="find(p)?.connected">
        <div v-if="find(p)?.account" class="mini-kv"><span>{{ t('integrations.account') }}</span><b>{{ find(p)?.account }}</b></div>
        <div v-if="find(p)?.tokenHint" class="mini-kv"><span>{{ t('integrations.token') }}</span><b>•••• {{ find(p)?.tokenHint }}</b></div>
        <div class="mini-kv"><span>{{ t('integrations.lastChecked') }}</span><b>{{ find(p)?.checkedAt ? ago(find(p)?.checkedAt, locale) : t('integrations.never') }}</b></div>
        <div v-if="find(p)?.lastError" class="err-row" style="margin: 8px 0 0"><p class="ferr err-text">{{ find(p)?.lastError }}</p><CopyButton :text="find(p)?.lastError ?? ''" /></div>
      </template>
      <div class="actions">
        <RouterLink class="btn" :class="{ 'btn-p': !find(p)?.connected }" :to="{ name: 'integration', params: { provider: p } }">
          {{ find(p)?.connected ? t('integrations.manage') : t('integrations.connect') }}
        </RouterLink>
        <button v-if="find(p)?.connected" type="button" class="btn" :disabled="test.isPending.value" @click="test.mutate(p)">
          {{ t('integrations.test') }}
        </button>
      </div>
    </section>
    <section class="card integ-card">
      <div class="ic-h">
        <ProviderTile provider="claude" />
        <div><h2>{{ t('integrations.name_claude') }}</h2></div>
      </div>
      <p class="sub" style="margin: 10px 0 8px">{{ t('settings.claudeMoved') }}</p>
      <div class="actions">
        <RouterLink class="btn" :to="{ name: 'workspace', query: { tab: 'claude' } }">{{ t('settings.claudeOpen') }}</RouterLink>
      </div>
    </section>
  </div>
  <section class="card">
    <div class="ch"><div><h2>{{ t('integrations.coming') }}</h2><p class="sub">{{ t('integrations.comingSub') }}</p></div></div>
    <div class="soon">
      <span>Bitbucket</span>
      <span>Linear</span>
      <span>Slack</span>
    </div>
  </section>
</template>
