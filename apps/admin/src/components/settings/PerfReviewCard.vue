<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import type { components } from '../../api/schema.gen'
import CfgRow from '../form/CfgRow.vue'
import CommandChips from '../form/CommandChips.vue'
import SwitchToggle from '../form/SwitchToggle.vue'

// Performance reviews in Settings: the switch, the zone months are
// counted in and Jira's not-done resolutions (saved with the page), then
// git identities and the backfill of earlier deliveries (saved at once).
type PerfReviewSettings = components['schemas']['PerfReviewSettings']
const model = defineModel<PerfReviewSettings>({ required: true })
// saved: the switch as stored; identities and the backfill need it on.
const props = defineProps<{ saved: boolean }>()
const { t } = useI18n()
const qc = useQueryClient()

const notDone = computed({
  get: () => model.value.notDone ?? [],
  set: (v: string[]) => (model.value = { ...model.value, notDone: v }),
})
const timeZone = computed({
  get: () => model.value.timeZone ?? 'UTC',
  set: (v: string) => (model.value = { ...model.value, timeZone: v }),
})

const members = useQuery({ queryKey: ['members'], queryFn: () => unwrap(api.GET('/workspace/members')) })
const ids = useQuery({
  queryKey: ['developers', 'identities'],
  queryFn: () => unwrap(api.GET('/analytics/developers/identities')),
  enabled: computed(() => props.saved),
})
const nameOf = (id: number) => {
  const m = (members.data.value ?? []).find((x) => x.userId === id)
  return m ? m.displayName || m.username : `#${id}`
}
const error = ref('')
const form = reactive({ userId: 0, login: '', email: '' })
const map = useMutation({
  mutationFn: (b: { userId: number; login?: string; email?: string; remove?: boolean }) =>
    unwrap(api.PUT('/analytics/developers/identities', { body: b })),
  onSuccess: (d) => {
    qc.setQueryData(['developers', 'identities'], d)
    qc.invalidateQueries({ queryKey: ['developers'] })
    form.login = form.email = ''
    error.value = ''
  },
  onError: (e: Error) => (error.value = e.message),
})
function add() {
  if (!form.userId || (!form.login.trim() && !form.email.trim())) return
  map.mutate({ userId: form.userId, login: form.login.trim(), email: form.email.trim() })
}
// An unmapped author's key is unmapped:<login or email>.
function mapUnmapped(identity: string, userId: number) {
  if (!userId) return
  map.mutate(identity.includes('@') ? { userId, email: identity } : { userId, login: identity })
}

const estimate = ref<components['schemas']['ScoreBackfill'] | null>(null)
const backfill = useMutation({
  mutationFn: (confirm: boolean) => unwrap(api.POST('/analytics/developers/backfill', { body: { confirm } })),
  onSuccess: (d) => {
    estimate.value = d
    error.value = ''
    if (d.queued) qc.invalidateQueries({ queryKey: ['developers'] })
  },
  onError: (e: Error) => (error.value = e.message),
})
</script>

<template>
  <section class="card">
    <div class="ch"><div><h2>{{ t('perf.settingsTitle') }}</h2><p class="sub">{{ t('perf.settingsSub') }}</p></div></div>
    <CfgRow :label="t('perf.enabled')" :help="t('perf.enabledHelp')">
      <SwitchToggle v-model="model.enabled" :label="t('perf.enabled')" />
    </CfgRow>
    <CfgRow :label="t('perf.timeZone')" :help="t('perf.timeZoneHelp')">
      <input v-model="timeZone" class="cfg-in" maxlength="64" :aria-label="t('perf.timeZone')" placeholder="Asia/Tashkent">
    </CfgRow>
    <CfgRow :label="t('perf.notDone')" :help="t('perf.notDoneHelp')">
      <CommandChips v-model="notDone" :label="t('perf.notDone')" placeholder="Won't Do" />
    </CfgRow>
  </section>

  <section class="card">
    <div class="ch"><div><h2>{{ t('perf.identities') }}</h2><p class="sub">{{ t('perf.identitiesSub') }}</p></div></div>
    <p v-if="!saved" class="hint">{{ t('perf.saveFirst') }}</p>
    <template v-else>
      <div class="pr-add">
        <select v-model.number="form.userId" class="cfg-in" :aria-label="t('perf.member')">
          <option :value="0">{{ t('perf.member') }}</option>
          <option v-for="m in members.data.value ?? []" :key="m.userId" :value="m.userId">{{ m.displayName || m.username }}</option>
        </select>
        <input v-model="form.login" class="cfg-in" :placeholder="t('perf.login')" :aria-label="t('perf.login')" maxlength="200">
        <input v-model="form.email" class="cfg-in" :placeholder="t('perf.email')" :aria-label="t('perf.email')" maxlength="320">
        <button type="button" class="btn btn-s btn-p" :disabled="map.isPending.value" @click="add">{{ t('perf.add') }}</button>
      </div>
      <div v-if="ids.data.value?.identities.length" class="tw">
        <table class="tbl">
          <thead><tr><th>{{ t('perf.member') }}</th><th>{{ t('perf.login') }}</th><th>{{ t('perf.email') }}</th><th /></tr></thead>
          <tbody>
            <tr v-for="g in ids.data.value.identities" :key="`${g.userId}|${g.login}|${g.email}`">
              <td>{{ nameOf(g.userId) }}</td>
              <td class="mono">{{ g.login }}</td>
              <td class="mono">{{ g.email }}</td>
              <td class="num">
                <button type="button" class="btn btn-s" :disabled="map.isPending.value" @click="map.mutate({ userId: g.userId, login: g.login, email: g.email, remove: true })">
                  {{ t('perf.remove') }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <h3 class="pr-h">{{ t('perf.unmappedTitle') }}</h3>
      <p v-if="!ids.data.value?.unmapped.length" class="hint">{{ t('perf.noUnmapped') }}</p>
      <div v-for="u in ids.data.value?.unmapped ?? []" :key="u.key" class="pr-un">
        <span class="mono">{{ u.identity }}</span>
        <span class="hint">{{ t('perf.unmappedDeliveries', { n: u.deliveries }) }}</span>
        <select class="cfg-in" :aria-label="t('perf.mapTo')" @change="mapUnmapped(u.identity, Number(($event.target as HTMLSelectElement).value))">
          <option value="0">{{ t('perf.mapTo') }}</option>
          <option v-for="m in members.data.value ?? []" :key="m.userId" :value="m.userId">{{ m.displayName || m.username }}</option>
        </select>
      </div>
    </template>
  </section>

  <section class="card">
    <div class="ch"><div><h2>{{ t('perf.backfill') }}</h2><p class="sub">{{ t('perf.backfillSub', { days: 90 }) }}</p></div></div>
    <p v-if="!saved" class="hint">{{ t('perf.saveFirst') }}</p>
    <template v-else>
      <div class="pr-add">
        <button type="button" class="btn btn-s" :disabled="backfill.isPending.value" @click="backfill.mutate(false)">{{ t('perf.backfillEstimate') }}</button>
        <button
          v-if="estimate && estimate.deliveries && !estimate.refused && !estimate.queued"
          type="button"
          class="btn btn-s btn-p"
          :disabled="backfill.isPending.value"
          @click="backfill.mutate(true)"
        >
          {{ t('perf.backfillConfirm') }}
        </button>
      </div>
      <template v-if="estimate">
        <p class="hint">{{ t('perf.backfillResult', { n: estimate.deliveries, usd: estimate.costUsd.toFixed(2) }) }}</p>
        <p v-if="estimate.onCredits" class="hint">{{ t('perf.backfillCredits', { credits: estimate.credits, balance: estimate.balance }) }}</p>
        <p v-if="estimate.refused" class="ferr">{{ estimate.refused }}</p>
        <p v-if="estimate.queued" class="hint">{{ t('perf.backfillQueued', { n: estimate.queued }) }}</p>
      </template>
    </template>
    <p v-if="error" class="ferr">{{ error }}</p>
  </section>
</template>

<style scoped>
.pr-add { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; margin-bottom: 10px; }
.pr-un { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; padding: 4px 0; }
.pr-h { font-size: 14px; margin: 14px 0 6px; }
.mono { font-family: var(--mono); font-size: 13px; }
</style>
