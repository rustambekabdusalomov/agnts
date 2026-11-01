<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { components } from '../../api/schema.gen'
import { useUi } from '../../stores/ui'
import { useWorkspace } from '../../stores/workspace'
import ClaudeConnect from '../account/ClaudeConnect.vue'
import CodexCard from './CodexCard.vue'
import MuseConnect from '../account/MuseConnect.vue'
import { accountModules, type AccountModule } from '../modules/modules'
import { useModels } from '../../composables/useModels'
import CfgRow from '../form/CfgRow.vue'
import SegButtons from '../form/SegButtons.vue'
import SwitchToggle from '../form/SwitchToggle.vue'

type WC = components['schemas']['WorkspaceClaude']
type Mode = 'shared' | 'member'
type Kind = 'subscription' | 'api_key' | 'muse_api_key'

// The owner chooses which accounts the workspace's runs use: one shared
// account, or each ticket member's own; and whether runs go on with credits
// when that account is at its limit. Each module the viewer may use that has
// an account (Muse, Claude) gets its own connection; Codex runs on the
// OpenAI integration.
const { t } = useI18n()
const catalog = useModels()
const conns = computed(() => accountModules(catalog.providers.value))
const both = computed(() => conns.value.length > 1)
// Wording for the modules at hand: ws.claude → ws.claudeMuse, or ws.claudeBoth for Muse and Claude.
const w = (key: string) => (both.value ? `${key}Both` : catalog.isMuse.value ? `${key}Muse` : key)
const qc = useQueryClient()
const ui = useUi()
const workspace = useWorkspace()
const owner = computed(() => workspace.isOwner)
const errText = (e: unknown) => (e instanceof HttpError ? e.message : t('common.error'))

// One answer per module: its connection and who has connected their own.
const wcOf = (p: AccountModule) =>
  useQuery({
    queryKey: ['workspace-claude', p],
    queryFn: () => unwrap(api.GET('/workspace/claude', { params: { query: { provider: p } } })),
    enabled: computed(() => catalog.has(p)),
  })
const byModule: Record<AccountModule, ReturnType<typeof wcOf>> = { muse: wcOf('muse'), claude: wcOf('claude') }
// Mode, fallback and the default member are the workspace's, the same in
// every module's answer: the default module's is shown.
const wc = computed(() => conns.value.map((p) => byModule[p].data.value).find((v) => !!v))
const pending = computed(() => catalog.query.isPending.value || (!!conns.value.length && !wc.value && conns.value.some((p) => byModule[p].isPending.value)))
const set = (p: AccountModule, v: WC) => {
  qc.setQueryData(['workspace-claude', p], v)
  void workspace.refresh()
}

const update = useMutation({
  mutationFn: (body: { mode?: Mode; fallback?: boolean; defaultMemberId?: number }) => unwrap(api.PUT('/workspace/claude', { body })),
  onSuccess: (v) => {
    // The answer is the default module's; the others share its settings.
    for (const p of conns.value) {
      if (p === catalog.primary.value) set(p, v)
      else void qc.invalidateQueries({ queryKey: ['workspace-claude', p] })
    }
    ui.notify(t(w('ws.claudeSaved')))
  },
  onError: (e) => ui.notify(errText(e)),
})
// The server tells the module from the kind of token.
const moduleOf = (kind: Kind): AccountModule => (kind === 'muse_api_key' ? 'muse' : 'claude')
const connError = ref<Record<AccountModule, string>>({ muse: '', claude: '' })
const connect = useMutation({
  mutationFn: (v: { kind: Kind; token: string }) => unwrap(api.PUT('/workspace/claude/connection', { body: v })),
  onSuccess: (v, { kind }) => {
    connError.value[moduleOf(kind)] = ''
    set(moduleOf(kind), v)
  },
  onError: (e, { kind }) => {
    connError.value[moduleOf(kind)] = errText(e)
  },
})
const disconnect = useMutation({
  mutationFn: (p: AccountModule) => unwrap(api.DELETE('/workspace/claude/connection', { params: { query: { provider: p } } })),
  onSuccess: (_r, p) => void qc.invalidateQueries({ queryKey: ['workspace-claude', p] }),
})
const busy = computed(() => connect.isPending.value || disconnect.isPending.value)
// One card per module: "Workspace account", or its module's name when there are two.
const connTitle = (p: AccountModule) => (both.value ? t(p === 'muse' ? 'ws.connectionMuse' : 'ws.connectionClaude') : t('ws.connection'))
// A member's own account for a module: connected, and paused at its limit.
const memberOf = (p: AccountModule, userId: number) => byModule[p].data.value?.members.find((m) => m.userId === userId)

const modes = computed(() => [
  { value: 'shared' as Mode, label: t('ws.modeShared') },
  { value: 'member' as Mode, label: t('ws.modeMember') },
])
const mode = computed({
  get: () => (wc.value?.mode ?? 'shared') as Mode,
  set: (m: Mode) => update.mutate({ mode: m }),
})
const fallback = computed({
  get: () => wc.value?.fallback ?? false,
  set: (v: boolean) => update.mutate({ fallback: v }),
})
const defaultMember = computed({
  get: () => String(wc.value?.defaultMemberId ?? 0),
  set: (v: string) => update.mutate({ defaultMemberId: Number(v) }),
})
const when = (s: string) => new Date(s).toLocaleString([], { dateStyle: 'medium', timeStyle: 'short' })
</script>

<template>
  <p v-if="pending" class="hint">{{ t('common.loading') }}</p>
  <div v-else-if="!conns.length" class="stack">
    <p class="hint">{{ t('ws.noAccountModules') }}</p>
    <CodexCard v-if="catalog.has('codex')" />
  </div>
  <div v-else-if="wc" class="stack">
    <section class="card">
      <div class="ch"><div><h2>{{ t(w('ws.claude')) }}</h2><p class="sub">{{ owner ? t(w('ws.claudeSub')) : t('ws.readOnly') }}</p></div></div>
      <CfgRow :label="t('ws.mode')" :help="mode === 'shared' ? t('ws.modeSharedHelp') : t('ws.modeMemberHelp')">
        <SegButtons v-if="owner" v-model="mode" :options="modes" :label="t('ws.mode')" />
        <span v-else class="badge b-info">{{ mode === 'shared' ? t('ws.modeShared') : t('ws.modeMember') }}</span>
      </CfgRow>
      <CfgRow :label="t('ws.fallback')" :help="t(w('ws.fallbackHelp'))">
        <span class="row-actions">
          <span class="hint">{{ t('ws.credits', { n: wc.creditsBalance }) }}</span>
          <SwitchToggle v-model="fallback" :label="t('ws.fallback')" :disabled="!owner" />
        </span>
      </CfgRow>
      <CfgRow v-if="mode === 'member'" :label="t('ws.defaultMember')" :help="t('ws.defaultMemberHelp')">
        <select v-model="defaultMember" class="cfg-in" :disabled="!owner" :aria-label="t('ws.defaultMember')">
          <option value="0">{{ t('ws.defaultOwner') }}</option>
          <option v-for="m in wc.members" :key="m.userId" :value="String(m.userId)">{{ m.username }}</option>
        </select>
      </CfgRow>
    </section>

    <section v-for="p in conns" :key="p" class="card">
      <div class="ch"><div><h2>{{ connTitle(p) }}</h2><p class="sub">{{ t('ws.connectionSub') }}</p></div></div>
      <p v-if="byModule[p].isPending.value" class="hint">{{ t('common.loading') }}</p>
      <MuseConnect
        v-else-if="p === 'muse'"
        scope="workspace"
        :state="byModule.muse.data.value?.connection"
        :readonly="!owner"
        :busy="busy"
        :error="connError.muse"
        @connect="(token) => connect.mutate({ kind: 'muse_api_key', token })"
        @disconnect="disconnect.mutate('muse')"
        @signed-in="qc.invalidateQueries({ queryKey: ['workspace-claude', 'muse'] })"
      />
      <ClaudeConnect
        v-else
        :state="byModule.claude.data.value?.connection"
        :subscriptions="byModule.claude.data.value?.subscriptionsAllowed ?? true"
        :readonly="!owner"
        :busy="busy"
        :error="connError.claude"
        @connect="(kind, token) => connect.mutate({ kind, token })"
        @disconnect="disconnect.mutate('claude')"
      />
    </section>

    <CodexCard v-if="catalog.has('codex')" />

    <section class="card">
      <div class="ch">
        <div><h2>{{ t('ws.memberAccounts') }}</h2><p class="sub">{{ t(w('ws.memberAccountsSub')) }}</p></div>
        <RouterLink class="btn btn-s" :to="{ name: 'profile' }">{{ t('ws.yourAccount') }}</RouterLink>
      </div>
      <div class="tw">
        <table class="tbl">
          <tbody>
            <tr v-for="m in wc.members" :key="m.userId" style="cursor: default">
              <td>{{ m.username }}</td>
              <td v-for="p in conns" :key="p">
                <span class="badge" :class="memberOf(p, m.userId)?.connected ? (memberOf(p, m.userId)?.pausedUntil ? 'b-warn' : 'b-ok') : 'b-gray'">
                  <template v-if="both">{{ t(p === 'muse' ? 'ws.claudeMuse' : 'ws.claude') }} · </template>{{ memberOf(p, m.userId)?.connected ? t('ws.connected') : t('ws.notConnected') }}
                </span>
              </td>
              <td class="hint">
                <div v-for="p in conns.filter((x) => memberOf(x, m.userId)?.pausedUntil)" :key="p">
                  <template v-if="both">{{ t(p === 'muse' ? 'ws.claudeMuse' : 'ws.claude') }}: </template>{{ t('ws.pausedUntil', { time: when(memberOf(p, m.userId)!.pausedUntil!) }) }}
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>
