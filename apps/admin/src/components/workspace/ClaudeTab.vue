<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { components } from '../../api/schema.gen'
import { useUi } from '../../stores/ui'
import { useWorkspace } from '../../stores/workspace'
import ClaudeConnect from '../account/ClaudeConnect.vue'
import MuseConnect from '../account/MuseConnect.vue'
import { useModels } from '../../composables/useModels'
import CfgRow from '../form/CfgRow.vue'
import SegButtons from '../form/SegButtons.vue'
import SwitchToggle from '../form/SwitchToggle.vue'

type WC = components['schemas']['WorkspaceClaude']
type Mode = 'shared' | 'member'

// The owner chooses which Claude (or, where Muse Code is the tool, Muse)
// account the workspace's runs use: one shared account, or each ticket
// member's own; and whether runs go on with credits when that account is
// at its limit.
const { t } = useI18n()
const catalog = useModels()
// Muse wording where Muse Code is the default tool: ws.claude → ws.claudeMuse.
const w = (key: string) => (catalog.isMuse.value ? `${key}Muse` : key)
const qc = useQueryClient()
const ui = useUi()
const workspace = useWorkspace()
const owner = computed(() => workspace.isOwner)
const errText = (e: unknown) => (e instanceof HttpError ? e.message : t('common.error'))

const wc = useQuery({ queryKey: ['workspace-claude'], queryFn: () => unwrap(api.GET('/workspace/claude')) })
const set = (v: WC) => {
  qc.setQueryData(['workspace-claude'], v)
  void workspace.refresh()
}

const update = useMutation({
  mutationFn: (body: { mode?: Mode; fallback?: boolean; defaultMemberId?: number }) => unwrap(api.PUT('/workspace/claude', { body })),
  onSuccess: (v) => {
    set(v)
    ui.notify(t(w('ws.claudeSaved')))
  },
  onError: (e) => ui.notify(errText(e)),
})
const connError = ref('')
const connect = useMutation({
  mutationFn: (v: { kind: 'subscription' | 'api_key' | 'muse_api_key'; token: string }) => unwrap(api.PUT('/workspace/claude/connection', { body: v })),
  onSuccess: (v) => {
    connError.value = ''
    set(v)
  },
  onError: (e) => {
    connError.value = errText(e)
  },
})
const disconnect = useMutation({
  mutationFn: () => unwrap(api.DELETE('/workspace/claude/connection')),
  onSuccess: () => void qc.invalidateQueries({ queryKey: ['workspace-claude'] }),
})

const modes = computed(() => [
  { value: 'shared' as Mode, label: t('ws.modeShared') },
  { value: 'member' as Mode, label: t('ws.modeMember') },
])
const mode = computed({
  get: () => (wc.data.value?.mode ?? 'shared') as Mode,
  set: (m: Mode) => update.mutate({ mode: m }),
})
const fallback = computed({
  get: () => wc.data.value?.fallback ?? false,
  set: (v: boolean) => update.mutate({ fallback: v }),
})
const defaultMember = computed({
  get: () => String(wc.data.value?.defaultMemberId ?? 0),
  set: (v: string) => update.mutate({ defaultMemberId: Number(v) }),
})
const when = (s: string) => new Date(s).toLocaleString([], { dateStyle: 'medium', timeStyle: 'short' })
</script>

<template>
  <p v-if="wc.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <div v-else-if="wc.data.value" class="stack">
    <section class="card">
      <div class="ch"><div><h2>{{ t(w('ws.claude')) }}</h2><p class="sub">{{ owner ? t(w('ws.claudeSub')) : t('ws.readOnly') }}</p></div></div>
      <CfgRow :label="t('ws.mode')" :help="mode === 'shared' ? t('ws.modeSharedHelp') : t('ws.modeMemberHelp')">
        <SegButtons v-if="owner" v-model="mode" :options="modes" :label="t('ws.mode')" />
        <span v-else class="badge b-info">{{ mode === 'shared' ? t('ws.modeShared') : t('ws.modeMember') }}</span>
      </CfgRow>
      <CfgRow :label="t('ws.fallback')" :help="t(w('ws.fallbackHelp'))">
        <span class="row-actions">
          <span class="hint">{{ t('ws.credits', { n: wc.data.value.creditsBalance }) }}</span>
          <SwitchToggle v-model="fallback" :label="t('ws.fallback')" :disabled="!owner" />
        </span>
      </CfgRow>
      <CfgRow v-if="mode === 'member'" :label="t('ws.defaultMember')" :help="t('ws.defaultMemberHelp')">
        <select v-model="defaultMember" class="cfg-in" :disabled="!owner" :aria-label="t('ws.defaultMember')">
          <option value="0">{{ t('ws.defaultOwner') }}</option>
          <option v-for="m in wc.data.value.members" :key="m.userId" :value="String(m.userId)">{{ m.username }}</option>
        </select>
      </CfgRow>
    </section>

    <section class="card">
      <div class="ch"><div><h2>{{ t('ws.connection') }}</h2><p class="sub">{{ t('ws.connectionSub') }}</p></div></div>
      <MuseConnect
        v-if="catalog.isMuse.value"
        scope="workspace"
        :state="wc.data.value.connection"
        :readonly="!owner"
        :busy="connect.isPending.value || disconnect.isPending.value"
        :error="connError"
        @connect="(token) => connect.mutate({ kind: 'muse_api_key', token })"
        @disconnect="disconnect.mutate()"
        @signed-in="qc.invalidateQueries({ queryKey: ['workspace-claude'] })"
      />
      <ClaudeConnect
        v-else
        :state="wc.data.value.connection"
        :subscriptions="wc.data.value.subscriptionsAllowed"
        :readonly="!owner"
        :busy="connect.isPending.value || disconnect.isPending.value"
        :error="connError"
        @connect="(kind, token) => connect.mutate({ kind, token })"
        @disconnect="disconnect.mutate()"
      />
    </section>

    <section class="card">
      <div class="ch">
        <div><h2>{{ t('ws.memberAccounts') }}</h2><p class="sub">{{ t(w('ws.memberAccountsSub')) }}</p></div>
        <RouterLink class="btn btn-s" :to="{ name: 'profile' }">{{ t('ws.yourAccount') }}</RouterLink>
      </div>
      <div class="tw">
        <table class="tbl">
          <tbody>
            <tr v-for="m in wc.data.value.members" :key="m.userId" style="cursor: default">
              <td>{{ m.username }}</td>
              <td>
                <span class="badge" :class="m.connected ? (m.pausedUntil ? 'b-warn' : 'b-ok') : 'b-gray'">
                  {{ m.connected ? t('ws.connected') : t('ws.notConnected') }}
                </span>
              </td>
              <td class="hint">{{ m.pausedUntil ? t('ws.pausedUntil', { time: when(m.pausedUntil) }) : '' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>
