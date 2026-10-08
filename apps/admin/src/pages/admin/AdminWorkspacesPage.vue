<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import PageHeader from '../../components/PageHeader.vue'
import ConfirmDialog from '../../components/ui/ConfirmDialog.vue'
import { initialsOf, nameOf, useAgo, usePlatform, type PlatformWorkspace } from '../../composables/usePlatform'
import { useUi } from '../../stores/ui'

// Every workspace on the platform (metadata only: their tickets are their
// members'), its members, and the Admin's levers: plan, slots, member
// limit, credits and suspension.
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const ago = useAgo()
const { workspaces, users } = usePlatform()
const errText = (e: unknown) => (e instanceof HttpError ? e.message : t('common.error'))

type State = 'active' | 'suspended' | 'deleted'
const FILTERS = ['all', 'active', 'suspended', 'deleted'] as const
const filter = ref<(typeof FILTERS)[number]>('all')
const q = ref('')
const state = (w: PlatformWorkspace): State => (w.deletedAt ? 'deleted' : w.suspended ? 'suspended' : 'active')
const list = computed(() => {
  const s = q.value.trim().toLowerCase()
  return (workspaces.data.value ?? [])
    .filter((w) => filter.value === 'all' || state(w) === filter.value)
    .filter((w) => !s || [w.name, w.slug, w.owner ?? ''].some((x) => x.toLowerCase().includes(s)))
    .sort((a, b) => (b.createdAt ?? '').localeCompare(a.createdAt ?? ''))
})
const count = (f: (typeof FILTERS)[number]) => (workspaces.data.value ?? []).filter((w) => f === 'all' || state(w) === f).length

// Members come from the user list, which carries each person's workspaces.
const membersOf = (id: number) =>
  (users.data.value ?? [])
    .flatMap((u) => u.workspaces.filter((w) => w.id === id).map((w) => ({ user: u.user, role: w.role })))
    .sort((a, b) => Number(b.role === 'owner') - Number(a.role === 'owner'))
const open = ref<number | null>(null)

const editing = ref<PlatformWorkspace | null>(null)
const plan = ref('')
const slots = ref(1)
const limit = ref(0)
function edit(w: PlatformWorkspace) {
  editing.value = w
  plan.value = w.plan
  slots.value = w.slots
  limit.value = w.memberLimit
}
const refresh = () => void qc.invalidateQueries({ queryKey: ['platform'] })
const save = useMutation({
  mutationFn: (w: PlatformWorkspace) => unwrap(api.PUT('/platform/workspaces/{id}', { params: { path: { id: w.id } }, body: { plan: plan.value, slots: slots.value, memberLimit: limit.value } })),
  onSuccess: () => {
    editing.value = null
    ui.notify(t('platform.saved'))
    refresh()
  },
  onError: (e) => ui.notify(errText(e)),
})
const suspending = ref<PlatformWorkspace | null>(null)
const suspend = useMutation({
  mutationFn: (w: PlatformWorkspace) => unwrap(api.PUT('/platform/workspaces/{id}', { params: { path: { id: w.id } }, body: { suspended: !w.suspended } })),
  onSuccess: () => {
    suspending.value = null
    refresh()
  },
  onError: (e) => ui.notify(errText(e)),
})
const granting = ref<PlatformWorkspace | null>(null)
const amount = ref(1000)
const note = ref('')
const grant = useMutation({
  mutationFn: (w: PlatformWorkspace) => unwrap(api.POST('/platform/workspaces/{id}/credits', { params: { path: { id: w.id } }, body: { amount: amount.value, ...(note.value ? { note: note.value } : {}) } })),
  onSuccess: (_r, w) => {
    ui.notify(t('platform.grantDone', { n: amount.value, name: w.name }))
    granting.value = null
    note.value = ''
    refresh()
  },
  onError: (e) => ui.notify(errText(e)),
})
const dialog = (r: typeof editing) => computed({ get: () => !!r.value, set: (v: boolean) => { if (!v) r.value = null } })
const editOpen = dialog(editing)
const grantOpen = dialog(granting)
const suspendOpen = dialog(suspending)
</script>

<template>
  <PageHeader :title="t('platform.workspaces')">
    <template #below><p class="sub" style="margin: 2px 0 0">{{ t('platform.wsLede') }}</p></template>
  </PageHeader>

  <section class="card">
    <div class="filters">
      <div class="seg" role="group" :aria-label="t('platform.state')">
        <button v-for="f in FILTERS" :key="f" class="seg-b" :aria-pressed="filter === f" @click="filter = f">{{ t(`platform.f_${f}`) }} <span class="muted">{{ count(f) }}</span></button>
      </div>
      <label class="mini-search">
        <svg viewBox="0 0 24 24" width="16" height="16" aria-hidden="true" style="fill: none; stroke: currentColor; stroke-width: 2"><circle cx="11" cy="11" r="7" /><path d="M20 20l-3.5-3.5" /></svg>
        <input v-model="q" type="search" :placeholder="t('platform.searchWs')" :aria-label="t('platform.searchWs')">
      </label>
    </div>
    <p v-if="workspaces.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="!list.length" class="empty">{{ t('platform.noWorkspaces') }}</p>
    <div v-else class="tw">
      <table class="tbl">
        <thead>
          <tr>
            <th>{{ t('platform.workspace') }}</th><th>{{ t('platform.owner') }}</th><th>{{ t('platform.members') }}</th><th>{{ t('platform.plan') }}</th>
            <th>{{ t('platform.slots') }}</th><th>{{ t('platform.credits') }}</th><th>{{ t('platform.runs') }}</th><th>{{ t('platform.created') }}</th><th>{{ t('platform.state') }}</th><th />
          </tr>
        </thead>
        <tbody>
          <template v-for="w in list" :key="w.id">
            <tr :aria-expanded="open === w.id" @click="open = open === w.id ? null : w.id">
              <td><div class="ttitle">{{ w.name }}</div><div class="tkey">/w/{{ w.slug }}</div></td>
              <td>{{ w.owner }}</td>
              <td class="mono">{{ w.members }}<template v-if="w.memberLimit"> / {{ w.memberLimit }}</template></td>
              <td>{{ w.plan }}</td>
              <td class="mono">{{ w.slots }}</td>
              <td class="mono">{{ w.creditsBalance }}</td>
              <td class="mono">{{ w.running }}</td>
              <td class="hint">{{ ago(w.createdAt) }}</td>
              <td><span class="badge" :class="{ active: 'b-ok', suspended: 'b-warn', deleted: 'b-bad' }[state(w)]">{{ t(`platform.${state(w)}`) }}</span></td>
              <td @click.stop>
                <span v-if="!w.deletedAt" class="row-actions">
                  <button class="btn btn-s" @click="edit(w)">{{ t('platform.edit') }}</button>
                  <button class="btn btn-s" @click="granting = w">{{ t('platform.grant') }}</button>
                  <button class="btn btn-s" :class="{ 'btn-d': !w.suspended }" @click="w.suspended ? suspend.mutate(w) : (suspending = w)">{{ w.suspended ? t('platform.resume') : t('platform.suspend') }}</button>
                </span>
              </td>
            </tr>
            <tr v-if="open === w.id" class="adm-sub">
              <td colspan="10">
                <ul class="adm-members">
                  <li v-for="m in membersOf(w.id)" :key="m.user.id">
                    <span class="av">{{ initialsOf(m.user) }}</span>
                    <span class="adm-who"><b>{{ nameOf(m.user) }}</b><small>{{ m.user.email || m.user.username }}</small></span>
                    <span class="badge" :class="m.role === 'owner' ? 'b-info' : 'b-gray'">{{ t(`ws.role_${m.role}`) }}</span>
                  </li>
                  <li v-if="!membersOf(w.id).length" class="muted">{{ t('platform.noMembers') }}</li>
                </ul>
              </td>
            </tr>
          </template>
        </tbody>
      </table>
    </div>
  </section>

  <ConfirmDialog v-model="editOpen" :title="editing?.name ?? ''" :confirm-label="t('ws.save')" :busy="save.isPending.value" @confirm="editing && save.mutate(editing)">
    <div class="stack" style="gap: 10px; width: 100%; margin-top: 12px">
      <label class="field"><span class="flbl">{{ t('platform.plan') }}</span><input v-model="plan" class="cfg-in"></label>
      <label class="field"><span class="flbl">{{ t('platform.slots') }}</span><input v-model.number="slots" class="cfg-in" type="number" min="1" max="50"></label>
      <label class="field"><span class="flbl">{{ t('platform.memberLimit') }} (0 = {{ t('platform.noLimit') }})</span><input v-model.number="limit" class="cfg-in" type="number" min="0"></label>
    </div>
  </ConfirmDialog>
  <ConfirmDialog v-model="grantOpen" :title="t('platform.grant')" :message="granting?.name" :confirm-label="t('platform.grant')" :busy="grant.isPending.value" @confirm="granting && grant.mutate(granting)">
    <div class="stack" style="gap: 10px; width: 100%; margin-top: 12px">
      <label class="field"><span class="flbl">{{ t('platform.grantAmount') }}</span><input v-model.number="amount" class="cfg-in" type="number"></label>
      <label class="field"><span class="flbl">{{ t('platform.grantNote') }}</span><input v-model="note" class="cfg-in" maxlength="300"></label>
    </div>
  </ConfirmDialog>
  <ConfirmDialog
    v-model="suspendOpen"
    :title="t('platform.suspendTitle', { name: suspending?.name ?? '' })"
    :message="t('platform.suspendBody')"
    :confirm-label="t('platform.suspend')"
    danger
    :busy="suspend.isPending.value"
    @confirm="suspending && suspend.mutate(suspending)"
  />
</template>
