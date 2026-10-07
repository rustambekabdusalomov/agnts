<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { useUi } from '../../stores/ui'
import CfgRow from '../form/CfgRow.vue'
import CopyField from '../form/CopyField.vue'
import HiIcon from '../ui/HiIcon.vue'
import type { Provider } from './providers'

// Connect a provider: the token (and Jira's site and email, or Plane's
// address and workspace) is checked by the server before it is saved.
const props = defineProps<{ provider: Provider }>()
const emit = defineEmits<{ connected: [webhookUrl: string | undefined, webhookSecret: string | undefined] }>()
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()

const form = reactive({ site: '', email: '', token: '', chatId: '', url: 'https://gitlab.com', planeUrl: 'https://api.plane.so', workspace: '' })
const error = ref('')

// "How to get the token" guide: a page to open, or a command to run.
// Telegram also links to the bot's getUpdates once a token is pasted: before
// agnts sets the webhook, that is where the chat id shows up.
const guide = computed<{ link?: string; command?: string; chatIdLink?: string } | null>(() => {
  if (props.provider === 'github') return { link: 'https://github.com/settings/personal-access-tokens/new' }
  if (props.provider === 'gitlab') {
    const base = /^https:\/\/[^\s/]+/.test(form.url.trim()) ? form.url.trim().replace(/\/+$/, '') : 'https://gitlab.com'
    return { link: `${base}/-/user_settings/personal_access_tokens` }
  }
  if (props.provider === 'claude') return { command: 'claude setup-token' }
  if (props.provider === 'jira') return { link: 'https://id.atlassian.com/manage-profile/security/api-tokens' }
  if (props.provider === 'plane') return { link: 'https://developers.plane.so/api-reference/introduction' }
  if (props.provider === 'telegram') {
    const tok = form.token.trim()
    return { link: 'https://t.me/BotFather', chatIdLink: /^\d+:[\w-]{20,}$/.test(tok) ? `https://api.telegram.org/bot${tok}/getUpdates` : undefined }
  }
  return null
})

const tokenLabel = computed(() =>
  props.provider === 'jira' ? t('integrations.apiToken') : props.provider === 'plane' ? t('integrations.apiKey') : t('integrations.accessToken'),
)
const tokenHelp = computed(() =>
  props.provider === 'jira' ? t('integrations.apiTokenHelp') : props.provider === 'plane' ? t('integrations.apiKeyHelp') : t('integrations.tokenHelp'),
)

const connect = useMutation({
  mutationFn: () => {
    const settings: Record<string, string> =
      props.provider === 'jira'
        ? { site: form.site.trim().replace(/\/+$/, ''), email: form.email.trim() }
        : props.provider === 'telegram'
          ? { chat_id: form.chatId.trim() }
          : props.provider === 'gitlab'
            ? { url: form.url.trim().replace(/\/+$/, '') }
            : props.provider === 'plane'
              ? { base_url: form.planeUrl.trim().replace(/\/+$/, ''), workspace: form.workspace.trim().toLowerCase() }
              : {}
    return unwrap(
      api.POST('/integrations/{provider}/connect', {
        params: { path: { provider: props.provider } },
        body: { token: form.token.trim(), settings },
      }),
    )
  },
  onSuccess: (r) => {
    void qc.invalidateQueries({ queryKey: ['integrations'] })
    form.token = ''
    error.value = ''
    ui.notify(t('integrations.connectedToast', { name: t(`integrations.name_${props.provider}`) }))
    emit('connected', r.integration.webhookUrl, r.webhookSecret)
  },
  onError: (e) => {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})

const perms = [
  { name: 'Contents', help: 'permContents', need: 'required' },
  { name: 'Pull requests', help: 'permPulls', need: 'required' },
  { name: 'Workflows', help: 'permWorkflows', need: 'recommended' },
  { name: 'Metadata', help: 'permMetadata', need: 'required' },
  { name: 'Actions', help: 'permActions', need: 'recommended' },
  { name: 'Deployments', help: 'permDeployments', need: 'recommended' },
] as const
const glScopes = [
  { name: 'api', help: 'glApi' },
  { name: 'read_repository', help: 'glRead' },
  { name: 'write_repository', help: 'glWrite' },
] as const
</script>

<template>
  <section class="card">
    <div class="ch">
      <div>
        <h2>{{ t('integrations.connectTitle', { name: t(`integrations.name_${provider}`) }) }}</h2>
        <p class="sub">{{ t(`integrations.connectSub_${provider}`) }}</p>
      </div>
    </div>
    <div v-if="guide" class="help token-how">
      <HiIcon name="info" />
      <div>
        <b>{{ t('integrations.tokenHow') }}</b>
        <ol>
          <li v-for="n in 4" :key="n">{{ t(`integrations.tokenStep${n}_${provider}`) }}</li>
        </ol>
        <CopyField v-if="guide.command" :label="t('integrations.tokenCommand')" :value="guide.command" />
        <div class="actions" style="margin: 0">
          <a v-if="guide.link" class="btn" :href="guide.link" target="_blank" rel="noopener noreferrer">
            {{ t(`integrations.tokenOpen_${provider}`) }} ↗
          </a>
          <a v-if="guide.chatIdLink" class="btn" :href="guide.chatIdLink" target="_blank" rel="noopener noreferrer">
            {{ t('integrations.chatIdFind') }} ↗
          </a>
        </div>
      </div>
    </div>
    <form @submit.prevent="connect.mutate()">
      <template v-if="provider === 'jira'">
        <CfgRow :label="t('integrations.site')" :help="t('integrations.siteHelp')">
          <input v-model="form.site" class="cfg-in mono" type="url" required placeholder="https://your-team.atlassian.net" :aria-label="t('integrations.site')">
        </CfgRow>
        <CfgRow :label="t('integrations.email')">
          <input v-model="form.email" class="cfg-in" type="email" required autocomplete="email" :aria-label="t('integrations.email')">
        </CfgRow>
      </template>
      <template v-if="provider === 'plane'">
        <CfgRow :label="t('integrations.planeBaseUrl')" :help="t('integrations.planeBaseUrlHelp')">
          <input v-model="form.planeUrl" class="cfg-in mono" type="url" required pattern="https?://.*" :aria-label="t('integrations.planeBaseUrl')">
        </CfgRow>
        <CfgRow :label="t('integrations.planeWorkspace')" :help="t('integrations.planeWorkspaceHelp')">
          <input v-model="form.workspace" class="cfg-in mono" required pattern="[A-Za-z0-9_\-]+" placeholder="acme" autocapitalize="off" :aria-label="t('integrations.planeWorkspace')">
        </CfgRow>
      </template>
      <CfgRow v-if="provider === 'gitlab'" :label="t('integrations.gitlabUrl')" :help="t('integrations.gitlabUrlHelp')">
        <input v-model="form.url" class="cfg-in mono" type="url" required pattern="https://.*" :aria-label="t('integrations.gitlabUrl')">
      </CfgRow>
      <CfgRow
        :label="tokenLabel"
        :help="tokenHelp"
      >
        <input
          v-model="form.token"
          class="cfg-in mono"
          type="password"
          required
          minlength="8"
          autocomplete="off"
          :placeholder="provider === 'plane' ? 'plane_api_…' : provider === 'github' ? 'github_pat_…' : provider === 'gitlab' ? 'glpat-…' : provider === 'claude' ? 'sk-ant-…' : provider === 'telegram' ? '123456:ABC…' : ''"
          :aria-label="tokenLabel"
        >
      </CfgRow>
      <CfgRow v-if="provider === 'telegram'" :label="t('integrations.chatId')" :help="t('integrations.chatIdHelp')">
        <input v-model="form.chatId" class="cfg-in mono" inputmode="numeric" required pattern="-?[0-9]+" :aria-label="t('integrations.chatId')">
      </CfgRow>
      <div v-if="provider === 'github'" class="sec">
        <h3>{{ t('integrations.scopes') }}</h3>
        <div v-for="p in perms" :key="p.name" class="perm">
          <span class="pk">{{ p.name }}</span>
          <span class="hint">{{ t(`integrations.${p.help}`) }}</span>
          <span class="pr"><span class="hint">{{ t(`integrations.${p.need}`) }}</span></span>
        </div>
      </div>
      <div v-if="provider === 'gitlab'" class="sec">
        <h3>{{ t('integrations.scopes') }}</h3>
        <div v-for="p in glScopes" :key="p.name" class="perm">
          <span class="pk">{{ p.name }}</span>
          <span class="hint">{{ t(`integrations.${p.help}`) }}</span>
          <span class="pr"><span class="hint">{{ t('integrations.required') }}</span></span>
        </div>
      </div>
      <p v-if="error" class="ferr" role="alert" style="margin-top: 12px">{{ error }}</p>
      <div class="actions">
        <button type="submit" class="btn btn-p" :disabled="connect.isPending.value">
          {{ connect.isPending.value ? t('integrations.connecting') : t('integrations.connectTitle', { name: t(`integrations.name_${provider}`) }) }}
        </button>
      </div>
    </form>
  </section>
</template>
