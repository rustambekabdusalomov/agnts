<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import ChartLegend from '../../components/charts/ChartLegend.vue'
import StackedBars from '../../components/charts/StackedBars.vue'
import PageHeader from '../../components/PageHeader.vue'
import MuseRouteCard from '../../components/platform/MuseRouteCard.vue'
import { initialsOf, nameOf, perDay, useAgo, usePlatform, within } from '../../composables/usePlatform'

// The platform at a glance: people and workspaces, how fast they grow, and
// what the server is running.
const { t, locale } = useI18n()
const { overview, workspaces, users } = usePlatform()
const ago = useAgo()

const DAYS = 30
// Users only: Admin accounts run the platform and are counted apart.
const all = computed(() => users.data.value ?? [])
const us = computed(() => all.value.filter((u) => !u.user.isAdmin))
const ws = computed(() => (workspaces.data.value ?? []).filter((w) => !w.deletedAt))
const kpi = computed(() => ({
  users: us.value.length,
  newUsers: us.value.filter((u) => within(u.user.createdAt, 7)).length,
  active: us.value.filter((u) => within(u.lastSignInAt, 7)).length,
  google: us.value.filter((u) => !u.hasPassword).length,
  workspaces: ws.value.length,
  newWorkspaces: ws.value.filter((w) => within(w.createdAt, 7)).length,
  team: ws.value.filter((w) => w.members > 1).length,
  admins: all.value.filter((u) => u.user.isAdmin).length,
}))

const labels = computed(() =>
  Array.from({ length: DAYS }, (_, i) => {
    const d = new Date()
    d.setDate(d.getDate() - (DAYS - 1 - i))
    return d.toLocaleDateString(locale.value, { day: 'numeric', month: 'short' })
  }),
)
const growth = computed(() => [
  { label: t('platform.legendUsers'), values: perDay(us.value.map((u) => u.user.createdAt), DAYS), color: 'var(--primary)' },
  { label: t('platform.legendWorkspaces'), values: perDay(ws.value.map((w) => w.createdAt), DAYS), color: 'var(--warn)' },
])
const recent = computed(() => [...us.value].sort((a, b) => (b.user.createdAt ?? '').localeCompare(a.user.createdAt ?? '')).slice(0, 6))

const cap = computed(() => overview.data.value?.capacity)
const gb = (mb: number) => `${(mb / 1024).toFixed(mb % 1024 ? 1 : 0)} GB`
</script>

<template>
  <PageHeader :title="t('platform.navDashboard')">
    <template #below><p class="sub" style="margin: 2px 0 0">{{ t('platform.dashLede') }}</p></template>
  </PageHeader>

  <p v-if="users.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="users.isError.value" class="ferr">{{ t('common.error') }}</p>
  <template v-else>
    <div class="g4">
      <RouterLink class="card stat kpi-btn" :to="{ name: 'adminUsers' }">
        <div class="lbl">{{ t('platform.users') }}</div>
        <div class="val">{{ kpi.users }}</div>
        <div class="note">{{ t('platform.newThisWeek', { n: kpi.newUsers }) }} · {{ t('platform.viaGoogle', { n: kpi.google }) }}</div>
      </RouterLink>
      <RouterLink class="card stat kpi-btn" :to="{ name: 'adminUsers', query: { f: 'active' } }">
        <div class="lbl">{{ t('platform.activeUsers') }}</div>
        <div class="val">{{ kpi.active }}</div>
        <div class="note">{{ t('platform.activeNote') }}</div>
      </RouterLink>
      <RouterLink class="card stat kpi-btn" :to="{ name: 'adminWorkspaces' }">
        <div class="lbl">{{ t('platform.workspaces') }}</div>
        <div class="val">{{ kpi.workspaces }}</div>
        <div class="note">{{ t('platform.newThisWeek', { n: kpi.newWorkspaces }) }} · {{ t('platform.teams', { n: kpi.team }) }}</div>
      </RouterLink>
      <RouterLink class="card stat kpi-btn" :to="{ name: 'adminAdmins' }">
        <div class="lbl">{{ t('platform.admins') }}</div>
        <div class="val">{{ kpi.admins }}</div>
        <div class="note">{{ t('platform.runsNow', { n: cap?.runs ?? 0 }) }}</div>
      </RouterLink>
    </div>

    <div class="dash-grid" style="margin-top: 16px">
      <section class="card span2">
        <div class="ch"><div><h2>{{ t('platform.growthTitle') }}</h2><p class="sub">{{ t('platform.growthSub', { n: DAYS }) }}</p></div></div>
        <StackedBars :series="growth" :labels="labels" :max-labels="10" :h="190" :aria="t('platform.growthTitle')" />
        <ChartLegend :items="[['var(--primary)', t('platform.legendUsers')], ['var(--warn)', t('platform.legendWorkspaces')]]" />
      </section>

      <section class="card">
        <div class="ch"><div><h2>{{ t('platform.recentTitle') }}</h2></div><RouterLink class="link-btn" :to="{ name: 'adminUsers' }">{{ t('platform.seeAll') }}</RouterLink></div>
        <p v-if="!recent.length" class="empty">{{ t('platform.noUsers') }}</p>
        <ul v-else class="adm-list">
          <li v-for="u in recent" :key="u.user.id">
            <span class="av">{{ initialsOf(u.user) }}</span>
            <span class="adm-who"><b>{{ nameOf(u.user) }}</b><small>{{ u.user.email || u.user.username }}</small></span>
            <span class="adm-when">{{ ago(u.user.createdAt) }}</span>
          </li>
        </ul>
      </section>

      <MuseRouteCard class="span2" />

      <section class="card">
        <div class="ch"><div><h2>{{ t('platform.capacity') }}</h2></div><span v-if="cap?.full" class="badge b-warn">{{ t('platform.full') }}</span></div>
        <template v-if="cap">
          <div class="mini-kv"><span>{{ t('platform.reserved') }}</span><b>{{ gb(cap.reservedMb) }}<template v-if="cap.budgetMb"> / {{ gb(cap.budgetMb) }}</template><template v-else> ({{ t('platform.budgetNone') }})</template></b></div>
          <div class="mini-kv"><span>{{ t('platform.runs') }}</span><b>{{ cap.runs }}</b></div>
          <div v-if="cap.diskFreeMb !== undefined" class="mini-kv"><span>{{ t('platform.disk') }}</span><b>{{ gb(cap.diskFreeMb) }}</b></div>
        </template>
        <p v-else class="empty">{{ t('common.loading') }}</p>
      </section>

      <section class="card">
        <div class="ch"><div><h2>{{ t('platform.running') }}</h2></div></div>
        <p v-if="!overview.data.value?.runs.length" class="empty">{{ t('platform.noRuns') }}</p>
        <ul v-else class="adm-list">
          <li v-for="r in overview.data.value.runs" :key="`${r.workspaceId}/${r.ticketKey}`">
            <span class="adm-who"><b class="mono">{{ r.ticketKey }}</b><small>{{ r.workspace }} · {{ r.stage }}</small></span>
            <span class="adm-when">{{ ago(r.startedAt) }}</span>
          </li>
        </ul>
      </section>

      <section class="card">
        <div class="ch"><div><h2>{{ t('platform.queue') }}</h2></div></div>
        <p v-if="!overview.data.value?.serverQueue.length" class="empty">{{ t('platform.noQueue') }}</p>
        <ul v-else class="adm-list">
          <li v-for="(q, i) in overview.data.value.serverQueue" :key="`${q.workspaceId}/${q.ticketKey}`">
            <span class="mono">#{{ i + 1 }}</span>
            <span class="adm-who"><b class="mono">{{ q.ticketKey }}</b><small>{{ q.workspace }}</small></span>
          </li>
        </ul>
      </section>
    </div>
  </template>
</template>
