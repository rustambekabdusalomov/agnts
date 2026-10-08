<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import type { components } from '../../api/schema.gen'
import { useSession } from '../../stores/session'
import { useUi } from '../../stores/ui'
import { useWorkspace } from '../../stores/workspace'
import CopyField from '../form/CopyField.vue'
import ConfirmDialog from '../ui/ConfirmDialog.vue'

type Member = components['schemas']['Member']

const { t } = useI18n()
const router = useRouter()
const qc = useQueryClient()
const ui = useUi()
const session = useSession()
const workspace = useWorkspace()
const me = computed(() => session.user?.id)
const errText = (e: unknown) => (e instanceof HttpError ? e.message : t('common.error'))

const members = useQuery({ queryKey: ['members'], queryFn: () => unwrap(api.GET('/workspace/members')) })
const invites = useQuery({ queryKey: ['invites'], queryFn: () => unwrap(api.GET('/workspace/invites')), enabled: () => workspace.isOwner })

const limitText = computed(() => {
  const n = members.data.value?.length ?? 0
  const limit = workspace.detail?.memberLimit ?? 0
  return limit > 0 ? t('ws.memberLimit', { n, limit }) : t('ws.memberLimitNone', { n })
})

const email = ref('')
const inviteRole = ref<'user' | 'viewer'>('user')
const created = ref<{ url: string; emailed?: boolean; email: string } | null>(null)
const invite = useMutation({
  mutationFn: () =>
    unwrap(api.POST('/workspace/invites', { body: { role: inviteRole.value, ...(email.value.trim() ? { email: email.value.trim() } : {}) } })),
  onSuccess: (r) => {
    created.value = { url: r.url, emailed: r.emailed, email: r.invite.email }
    email.value = ''
    void qc.invalidateQueries({ queryKey: ['invites'] })
  },
  onError: (e) => ui.notify(errText(e)),
})
const revoke = useMutation({
  mutationFn: (id: number) => unwrap(api.DELETE('/workspace/invites/{id}', { params: { path: { id } } })),
  onSuccess: () => {
    ui.notify(t('ws.revoked'))
    void qc.invalidateQueries({ queryKey: ['invites'] })
  },
})

// A member who is not the owner works as a member or only looks as a viewer.
const setRole = useMutation({
  mutationFn: (v: { m: Member; role: 'user' | 'viewer' }) =>
    unwrap(api.PUT('/workspace/members/{userId}/role', { params: { path: { userId: v.m.userId } }, body: { role: v.role } })),
  onSuccess: (_r, v) => {
    ui.notify(t('ws.roleChanged', { name: who(v.m), role: t(`ws.role_${v.role}`) }))
    void qc.invalidateQueries({ queryKey: ['members'] })
    void qc.invalidateQueries({ queryKey: ['workspace-claude'] })
  },
  onError: (e) => {
    ui.notify(errText(e))
    void qc.invalidateQueries({ queryKey: ['members'] })
  },
})
const roleBadge: Record<string, string> = { owner: 'b-info', user: 'b-gray', viewer: 'b-warn' }

// One confirm at a time: remove, make owner, or leave.
const pending = ref<{ kind: 'remove' | 'owner' | 'leave'; m?: Member } | null>(null)
const busy = ref(false)
const who = (m?: Member) => m?.displayName || m?.username || ''
async function act() {
  const p = pending.value
  if (!p) return
  busy.value = true
  try {
    if (p.kind === 'remove' && p.m) {
      await unwrap(api.DELETE('/workspace/members/{userId}', { params: { path: { userId: p.m.userId } } }))
      ui.notify(t('ws.removed', { name: who(p.m) }))
    } else if (p.kind === 'owner' && p.m) {
      await unwrap(api.POST('/workspace/transfer', { body: { userId: p.m.userId } }))
      ui.notify(t('ws.transferred', { name: who(p.m) }))
      await workspace.refresh()
    } else if (p.kind === 'leave') {
      await unwrap(api.POST('/workspace/leave'))
      pending.value = null
      workspace.reset()
      await session.load()
      await router.replace('/')
      return
    }
    void qc.invalidateQueries({ queryKey: ['members'] })
    pending.value = null
  } catch (e) {
    ui.notify(errText(e))
  } finally {
    busy.value = false
  }
}
const confirmTitle = computed(() => {
  const p = pending.value
  if (!p) return ''
  if (p.kind === 'remove') return t('ws.removeTitle', { name: who(p.m) })
  if (p.kind === 'owner') return t('ws.transferTitle', { name: who(p.m) })
  return t('ws.leaveTitle', { name: workspace.name })
})
const confirmBody = computed(() => {
  const p = pending.value
  if (!p) return ''
  return t(p.kind === 'remove' ? 'ws.removeBody' : p.kind === 'owner' ? 'ws.transferBody' : 'ws.leaveBody')
})
const confirmOpen = computed({ get: () => !!pending.value, set: (v) => { if (!v) pending.value = null } })
const fmt = (s: string) => new Date(s).toLocaleDateString()
</script>

<template>
  <div class="stack">
    <section class="card">
      <div class="ch">
        <div><h2>{{ t('ws.members') }}</h2><p class="sub">{{ t('ws.membersSub') }}</p></div>
        <span class="badge b-gray">{{ limitText }}</span>
      </div>
      <p v-if="members.isPending.value" class="hint">{{ t('common.loading') }}</p>
      <div v-else class="tw">
        <table class="tbl">
          <tbody>
            <tr v-for="m in members.data.value ?? []" :key="m.userId" style="cursor: default">
              <td>
                <div class="ttitle">{{ who(m) }} <span v-if="m.userId === me" class="hint">({{ t('ws.you') }})</span></div>
                <div class="tkey">{{ m.username }}<template v-if="m.email"> · {{ m.email }}</template></div>
              </td>
              <td>
                <select
                  v-if="workspace.isOwner && m.role !== 'owner'"
                  class="cfg-in" style="min-width: 130px"
                  :value="m.role" :disabled="setRole.isPending.value" :aria-label="t('ws.roleLabel', { name: who(m) })"
                  @change="setRole.mutate({ m, role: ($event.target as HTMLSelectElement).value as 'user' | 'viewer' })"
                >
                  <option value="user">{{ t('ws.role_user') }}</option>
                  <option value="viewer">{{ t('ws.role_viewer') }}</option>
                </select>
                <span v-else class="badge" :class="roleBadge[m.role]">{{ t(`ws.role_${m.role}`) }}</span>
              </td>
              <td>
                <span class="badge" :class="m.claudeConnected ? 'b-ok' : 'b-gray'">{{ m.claudeConnected ? t('ws.claudeBadge') : t('ws.noClaudeBadge') }}</span>
              </td>
              <td class="hint">{{ fmt(m.joinedAt) }}</td>
              <td>
                <span v-if="workspace.isOwner && m.role !== 'owner'" class="row-actions">
                  <button class="btn btn-s" @click="pending = { kind: 'owner', m }">{{ t('ws.makeOwner') }}</button>
                  <button class="btn btn-s btn-d" @click="pending = { kind: 'remove', m }">{{ t('ws.remove') }}</button>
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="!workspace.isOwner" class="row-actions" style="margin-top: 12px">
        <button class="btn btn-s btn-d" @click="pending = { kind: 'leave' }">{{ t('ws.leave') }}</button>
      </div>
      <p v-else class="hint" style="margin-top: 12px">{{ t('ws.ownerCannotLeave') }}</p>
    </section>

    <section v-if="workspace.isOwner" class="card">
      <div class="ch"><div><h2>{{ t('ws.invite') }}</h2><p class="sub">{{ t('ws.inviteSub') }}</p></div></div>
      <form class="row-actions" style="justify-content: flex-start" @submit.prevent="invite.mutate()">
        <input v-model="email" class="cfg-in" type="email" :placeholder="t('ws.inviteEmail')" :aria-label="t('ws.inviteEmail')" style="min-width: 260px">
        <select v-model="inviteRole" class="cfg-in" :aria-label="t('ws.inviteAs')" :title="t('ws.inviteAsHelp')" style="min-width: 130px">
          <option value="user">{{ t('ws.role_user') }}</option>
          <option value="viewer">{{ t('ws.role_viewer') }}</option>
        </select>
        <button class="btn btn-p btn-s" type="submit" :disabled="invite.isPending.value">{{ t('ws.inviteSend') }}</button>
      </form>
      <div v-if="created" style="margin-top: 14px">
        <div class="cfg-lbl">{{ t('ws.inviteLink') }}</div>
        <CopyField :value="created.url" :label="t('ws.inviteLink')" />
        <p v-if="created.emailed" class="hint">{{ t('ws.inviteEmailed', { email: created.email }) }}</p>
      </div>
      <template v-if="invites.data.value?.length">
        <h3 style="margin: 18px 0 8px; font-size: 14px">{{ t('ws.invites') }}</h3>
        <div class="tw">
          <table class="tbl">
            <tbody>
              <tr v-for="i in invites.data.value" :key="i.id" style="cursor: default">
                <td>{{ i.email || t('ws.inviteAnyone') }}</td>
                <td><span class="badge" :class="roleBadge[i.role]">{{ t(`ws.role_${i.role}`) }}</span></td>
                <td class="hint">{{ t('ws.inviteExpires', { date: fmt(i.expiresAt) }) }}</td>
                <td><span class="row-actions"><button class="btn btn-s" @click="revoke.mutate(i.id)">{{ t('ws.revoke') }}</button></span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>
    </section>

    <ConfirmDialog
      v-model="confirmOpen" :title="confirmTitle" :message="confirmBody"
      :confirm-label="pending?.kind === 'owner' ? t('ws.makeOwner') : pending?.kind === 'leave' ? t('ws.leave') : t('ws.remove')"
      :danger="pending?.kind !== 'owner'" :busy="busy" @confirm="act"
    />
  </div>
</template>
