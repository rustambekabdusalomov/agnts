<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { components } from '../../api/schema.gen'
import PageHeader from '../../components/PageHeader.vue'
import ConfirmDialog from '../../components/ui/ConfirmDialog.vue'
import { useSession } from '../../stores/session'
import { useUi } from '../../stores/ui'

type PW = components['schemas']['PlatformWorkspace']

// The Admin's view of the server: capacity, runs, the server queue,
// every workspace (metadata only) and every user.
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const session = useSession()
const errText = (e: unknown) => (e instanceof HttpError ? e.message : t('common.error'))
const admin = computed(() => !!session.user?.isAdmin)

const overview = useQuery({ queryKey: ['platform', 'overview'], queryFn: () => unwrap(api.GET('/platform/overview')), refetchInterval: 10_000, enabled: admin })
const workspaces = useQuery({ queryKey: ['platform', 'workspaces'], queryFn: () => unwrap(api.GET('/platform/workspaces')), enabled: admin })
const users = useQuery({ queryKey: ['platform', 'users'], queryFn: () => unwrap(api.GET('/platform/users')), enabled: admin })
const cap = computed(() => overview.data.value?.capacity)
const gb = (mb: number) => `${(mb / 1024).toFixed(mb % 1024 ? 1 : 0)} GB`
const ago = (s: string) => {
  const m = Math.round((Date.now() - new Date(s).getTime()) / 60000)
  return m < 60 ? `${m} min` : `${Math.floor(m / 60)} h ${m % 60} min`
}

const editing = ref<PW | null>(null)
const plan = ref('')
const slots = ref(1)
const limit = ref(0)
function edit(w: PW) {
  editing.value = w
  plan.value = w.plan
  slots.value = w.slots
  limit.value = w.memberLimit
}
const save = useMutation({
  mutationFn: (w: PW) => unwrap(api.PUT('/platform/workspaces/{id}', { params: { path: { id: w.id } }, body: { plan: plan.value, slots: slots.value, memberLimit: limit.value } })),
  onSuccess: () => {
    editing.value = null
    ui.notify(t('platform.saved'))
    void qc.invalidateQueries({ queryKey: ['platform'] })
  },
  onError: (e) => ui.notify(errText(e)),
})
const suspend = useMutation({
  mutationFn: (w: PW) => unwrap(api.PUT('/platform/workspaces/{id}', { params: { path: { id: w.id } }, body: { suspended: !w.suspended } })),
  onSuccess: () => void qc.invalidateQueries({ queryKey: ['platform'] }),
  onError: (e) => ui.notify(errText(e)),
})

const granting = ref<PW | null>(null)
const amount = ref(1000)
const note = ref('')
const grant = useMutation({
  mutationFn: (w: PW) => unwrap(api.POST('/platform/workspaces/{id}/credits', { params: { path: { id: w.id } }, body: { amount: amount.value, ...(note.value ? { note: note.value } : {}) } })),
  onSuccess: (_r, w) => {
    ui.notify(t('platform.grantDone', { n: amount.value, name: w.name }))
    granting.value = null
    note.value = ''
    void qc.invalidateQueries({ queryKey: ['platform'] })
  },
  onError: (e) => ui.notify(errText(e)),
})
const grantOpen = computed({ get: () => !!granting.value, set: (v) => { if (!v) granting.value = null } })
const editOpen = computed({ get: () => !!editing.value, set: (v) => { if (!v) editing.value = null } })

const setAdmin = useMutation({
  mutationFn: (u: { id: number; isAdmin?: boolean }) => unwrap(api.PUT('/platform/users/{id}', { params: { path: { id: u.id } }, body: { isAdmin: !u.isAdmin } })),
  onSuccess: () => void qc.invalidateQueries({ queryKey: ['platform', 'users'] }),
  onError: (e) => ui.notify(errText(e)),
})
const state = (w: PW) => (w.deletedAt ? 'deleted' : w.suspended ? 'suspended' : 'active')
</script>

<template>
  <PageHeader :title="t('platform.title')">
    <template #below><p class="sub" style="margin: 2px 0 0">{{ t('platform.lede') }}</p></template>
  </PageHeader>
  <p v-if="!admin" class="ferr">{{ t('platform.forbidden') }}</p>
  <div v-else class="stack" style="max-width: 1200px">
    <section class="card">
      <div class="ch"><div><h2>{{ t('platform.capacity') }}</h2></div><span v-if="cap?.full" class="badge b-warn">{{ t('platform.full') }}</span></div>
      <div v-if="cap" class="stat-cards">
        <div class="stat-card">
          <div class="v">{{ gb(cap.reservedMb) }}<small v-if="cap.budgetMb" class="hint"> / {{ gb(cap.budgetMb) }}</small></div>
          <div class="l">{{ t('platform.reserved') }}<template v-if="!cap.budgetMb"> ({{ t('platform.budgetNone') }})</template></div>
        </div>
        <div class="stat-card"><div class="v">{{ cap.runs }}</div><div class="l">{{ t('platform.runs') }}</div></div>
        <div v-if="cap.diskFreeMb !== undefined" class="stat-card"><div class="v">{{ gb(cap.diskFreeMb) }}</div><div class="l">{{ t('platform.disk') }}</div></div>
        <div class="stat-card"><div class="v">{{ overview.data.value?.workspaces }}</div><div class="l">{{ t('platform.workspaces') }}</div></div>
        <div class="stat-card"><div class="v">{{ overview.data.value?.users }}</div><div class="l">{{ t('platform.users') }}</div></div>
      </div>
    </section>

    <div class="cfg-grid">
      <section class="card">
        <div class="ch"><div><h2>{{ t('platform.running') }}</h2></div></div>
        <p v-if="!overview.data.value?.runs.length" class="empty">{{ t('platform.noRuns') }}</p>
        <div v-else class="tw">
          <table class="tbl">
            <thead><tr><th>{{ t('platform.workspace') }}</th><th>{{ t('platform.ticket') }}</th><th>{{ t('platform.stage') }}</th><th>{{ t('platform.started') }}</th></tr></thead>
            <tbody>
              <tr v-for="r in overview.data.value.runs" :key="`${r.workspaceId}/${r.ticketKey}`" style="cursor: default">
                <td>{{ r.workspace }}</td><td class="mono">{{ r.ticketKey }}</td><td>{{ r.stage }}</td><td class="hint">{{ ago(r.startedAt) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
      <section class="card">
        <div class="ch"><div><h2>{{ t('platform.queue') }}</h2></div></div>
        <p v-if="!overview.data.value?.serverQueue.length" class="empty">{{ t('platform.noQueue') }}</p>
        <div v-else class="tw">
          <table class="tbl">
            <tbody>
              <tr v-for="(q, i) in overview.data.value.serverQueue" :key="`${q.workspaceId}/${q.ticketKey}`" style="cursor: default">
                <td class="mono">#{{ i + 1 }}</td><td>{{ q.workspace }}</td><td class="mono">{{ q.ticketKey }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </div>

    <section class="card">
      <div class="ch"><div><h2>{{ t('platform.workspaces') }}</h2></div></div>
      <div class="tw">
        <table class="tbl">
          <thead>
            <tr>
              <th>{{ t('platform.workspace') }}</th><th>{{ t('platform.owner') }}</th><th>{{ t('platform.plan') }}</th><th>{{ t('platform.slots') }}</th>
              <th>{{ t('platform.members') }}</th><th>{{ t('platform.credits') }}</th><th>{{ t('platform.runs') }}</th><th>{{ t('platform.state') }}</th><th />
            </tr>
          </thead>
          <tbody>
            <tr v-for="w in workspaces.data.value ?? []" :key="w.id" style="cursor: default">
              <td><div class="ttitle">{{ w.name }}</div><div class="tkey">/w/{{ w.slug }}</div></td>
              <td>{{ w.owner }}</td>
              <td>{{ w.plan }}</td>
              <td class="mono">{{ w.slots }}</td>
              <td class="mono">{{ w.members }}<template v-if="w.memberLimit"> / {{ w.memberLimit }}</template></td>
              <td class="mono">{{ w.creditsBalance }}</td>
              <td class="mono">{{ w.running }}</td>
              <td><span class="badge" :class="{ active: 'b-ok', suspended: 'b-warn', deleted: 'b-bad' }[state(w)]">{{ t(`platform.${state(w)}`) }}</span></td>
              <td>
                <span v-if="!w.deletedAt" class="row-actions">
                  <button class="btn btn-s" @click="edit(w)">{{ t('platform.edit') }}</button>
                  <button class="btn btn-s" @click="granting = w">{{ t('platform.grant') }}</button>
                  <button class="btn btn-s" :class="{ 'btn-d': !w.suspended }" @click="suspend.mutate(w)">{{ w.suspended ? t('platform.resume') : t('platform.suspend') }}</button>
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <section class="card">
      <div class="ch"><div><h2>{{ t('platform.users') }}</h2></div></div>
      <div class="tw">
        <table class="tbl">
          <thead><tr><th>{{ t('platform.user') }}</th><th>{{ t('platform.email') }}</th><th>{{ t('platform.joined') }}</th><th /></tr></thead>
          <tbody>
            <tr v-for="u in users.data.value ?? []" :key="u.id" style="cursor: default">
              <td>{{ u.username }} <span v-if="u.isAdmin" class="badge b-info">{{ t('platform.admin') }}</span></td>
              <td>{{ u.email }}</td>
              <td class="hint">{{ u.createdAt ? new Date(u.createdAt).toLocaleDateString() : '' }}</td>
              <td>
                <span v-if="u.id !== session.user?.id" class="row-actions">
                  <button class="btn btn-s" @click="setAdmin.mutate(u)">{{ u.isAdmin ? t('platform.removeAdmin') : t('platform.makeAdmin') }}</button>
                </span>
              </td>
            </tr>
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
  </div>
</template>
