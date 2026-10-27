<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import PageHeader from '../../components/PageHeader.vue'
import ConfirmDialog from '../../components/ui/ConfirmDialog.vue'
import { initialsOf, nameOf, useAgo, usePlatform, within, type PlatformUser } from '../../composables/usePlatform'
import { useUi } from '../../stores/ui'

// The platform's Users (Admin accounts are on the Admins page): how they
// sign in, which workspaces they are in and when they last signed in.
const { t } = useI18n()
const route = useRoute()
const ago = useAgo()
const { users } = usePlatform()
const qc = useQueryClient()
const ui = useUi()

const FILTERS = ['all', 'active', 'new', 'google'] as const
type Filter = (typeof FILTERS)[number]
const filter = ref<Filter>((FILTERS as readonly string[]).includes(String(route.query.f)) ? (route.query.f as Filter) : 'all')
const q = ref('')
const matches = (u: PlatformUser, f: Filter) =>
  f === 'all' ||
  (f === 'active' && within(u.lastSignInAt, 7)) ||
  (f === 'new' && within(u.user.createdAt, 7)) ||
  (f === 'google' && !u.hasPassword)
const people = computed(() => (users.data.value ?? []).filter((u) => !u.user.isAdmin))
const count = (f: Filter) => people.value.filter((u) => matches(u, f)).length
const list = computed(() => {
  const s = q.value.trim().toLowerCase()
  return people.value
    .filter((u) => matches(u, filter.value))
    .filter((u) => !s || [u.user.username, u.user.displayName ?? '', u.user.email ?? '', ...u.workspaces.map((w) => w.name)].some((x) => x.toLowerCase().includes(s)))
    .sort((a, b) => (b.user.createdAt ?? '').localeCompare(a.user.createdAt ?? ''))
})

// Free credits: what a person may spend on agnts's Muse key before their
// workspace's credits (1 credit = $0.01).
const usd = (credits: number) => new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(credits / 100)
const PRESETS = [0, 500, 2000, 5000]
const crediting = ref<PlatformUser | null>(null)
const creditLimit = ref(0)
function editCredits(u: PlatformUser) {
  crediting.value = u
  creditLimit.value = u.freeCredits?.limit ?? 0
}
const creditOk = computed(() => Number.isInteger(creditLimit.value) && creditLimit.value >= 0 && creditLimit.value <= 10_000_000)
const setCredits = useMutation({
  mutationFn: (u: PlatformUser) => unwrap(api.PUT('/platform/users/{id}/free-credits', { params: { path: { id: u.user.id } }, body: { limit: creditLimit.value } })),
  onSuccess: (fc, u) => {
    ui.notify(t('platform.freeCreditsSet', { name: nameOf(u.user), n: fc.limit, amount: usd(fc.limit) }))
    crediting.value = null
    void qc.invalidateQueries({ queryKey: ['platform', 'users'] })
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
const creditOpen = computed({ get: () => !!crediting.value, set: (v: boolean) => { if (!v) crediting.value = null } })
</script>

<template>
  <PageHeader :title="t('platform.users')">
    <template #below><p class="sub" style="margin: 2px 0 0">{{ t('platform.usersLede') }}</p></template>
  </PageHeader>

  <section class="card">
    <div class="filters">
      <div class="seg" role="group" :aria-label="t('platform.users')">
        <button v-for="f in FILTERS" :key="f" class="seg-b" :aria-pressed="filter === f" @click="filter = f">{{ t(`platform.u_${f}`) }} <span class="muted">{{ count(f) }}</span></button>
      </div>
      <label class="mini-search">
        <svg viewBox="0 0 24 24" width="16" height="16" aria-hidden="true" style="fill: none; stroke: currentColor; stroke-width: 2"><circle cx="11" cy="11" r="7" /><path d="M20 20l-3.5-3.5" /></svg>
        <input v-model="q" type="search" :placeholder="t('platform.searchUsers')" :aria-label="t('platform.searchUsers')">
      </label>
    </div>
    <p v-if="users.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="!list.length" class="empty">{{ t('platform.noUsers') }}</p>
    <div v-else class="tw">
      <table class="tbl">
        <thead>
          <tr>
            <th>{{ t('platform.user') }}</th><th>{{ t('platform.signIn') }}</th><th>{{ t('platform.workspaces') }}</th>
            <th>{{ t('platform.freeCredits') }}</th><th>{{ t('platform.joined') }}</th><th>{{ t('platform.lastSeen') }}</th><th />
          </tr>
        </thead>
        <tbody>
          <tr v-for="u in list" :key="u.user.id" style="cursor: default">
            <td>
              <div class="adm-person">
                <span class="av">{{ initialsOf(u.user) }}</span>
                <span class="adm-who">
                  <b>{{ nameOf(u.user) }}</b>
                  <small>{{ u.user.email || u.user.username }}<template v-if="u.user.email && !u.user.emailVerified"> · {{ t('platform.unverified') }}</template></small>
                </span>
              </div>
            </td>
            <td>
              <span class="badge" :class="u.hasPassword ? 'b-gray' : 'b-ok'">{{ u.hasPassword ? t('platform.password') : 'Google' }}</span>
              <span v-if="u.user.hasTotp" class="badge b-gray" style="margin-left: 6px">2FA</span>
            </td>
            <td>
              <span v-if="!u.workspaces.length" class="muted">—</span>
              <span v-for="w in u.workspaces" :key="w.id" class="adm-ws" :title="t(`ws.role_${w.role}`)">{{ w.name }}<small v-if="w.role === 'owner'"> · {{ t('ws.role_owner') }}</small></span>
            </td>
            <td>
              <template v-if="u.freeCredits?.limit">
                <span class="mono">{{ u.freeCredits.remaining }} / {{ u.freeCredits.limit }}</span>
                <small class="muted"> · {{ usd(u.freeCredits.remaining) }}</small>
              </template>
              <span v-else class="muted">—</span>
            </td>
            <td class="hint">{{ ago(u.user.createdAt) }}</td>
            <td class="hint">{{ ago(u.lastSignInAt) }}</td>
            <td style="text-align: right"><button class="btn btn-s" @click="editCredits(u)">{{ t('platform.setFreeCredits') }}</button></td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>

  <ConfirmDialog
    v-model="creditOpen"
    :title="t('platform.setFreeCredits')"
    :message="crediting ? nameOf(crediting.user) : ''"
    :confirm-label="t('platform.setFreeCredits')"
    :busy="setCredits.isPending.value"
    @confirm="crediting && creditOk && setCredits.mutate(crediting)"
  >
    <div class="stack" style="gap: 10px; width: 100%; margin-top: 12px">
      <p v-if="crediting?.freeCredits?.limit" class="hint">
        {{ t('platform.freeCreditsUsed', { used: crediting.freeCredits.used, limit: crediting.freeCredits.limit }) }}
      </p>
      <label class="field">
        <span class="flbl">{{ t('platform.freeCreditsLimit') }}</span>
        <input v-model.number="creditLimit" class="cfg-in" type="number" min="0" max="10000000" step="100">
      </label>
      <p class="hint">{{ creditOk ? t('platform.freeCreditsWorth', { amount: usd(creditLimit) }) : t('platform.freeCreditsInvalid') }}</p>
      <div class="seg" role="group" :aria-label="t('platform.freeCreditsLimit')">
        <button v-for="n in PRESETS" :key="n" type="button" class="seg-b" :aria-pressed="creditLimit === n" @click="creditLimit = n">
          {{ n }} <span class="muted">{{ usd(n) }}</span>
        </button>
      </div>
    </div>
  </ConfirmDialog>
</template>
