<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import type { SwaggerSuite } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import InputSelect from '../components/form/InputSelect.vue'
import { ago } from '../composables/format'
import { useUi } from '../stores/ui'
import { useWorkspace } from '../stores/workspace'

// Saved Swagger test suites: their schedule, last and next run, and the
// deploy hook that runs them after each deploy.
const { t, locale } = useI18n()
const qc = useQueryClient()
const router = useRouter()
const ui = useUi()
const workspace = useWorkspace()

const suites = useQuery({ queryKey: ['swagger-suites'], queryFn: () => unwrap(api.GET('/swagger-suites')) })
const hooks = reactive<Record<number, string>>({})
const tokens = reactive<Record<number, string>>({})
const error = ref('')
const fail = (e: unknown) => (error.value = e instanceof HttpError ? e.message : t('common.error'))
const refresh = () => qc.invalidateQueries({ queryKey: ['swagger-suites'] })

const run = useMutation({
  mutationFn: (s: SwaggerSuite) => unwrap(api.POST('/swagger-suites/{id}/run', { params: { path: { id: s.id } } })),
  onSuccess: async (tk) => {
    void refresh()
    void qc.invalidateQueries({ queryKey: ['tickets'] })
    ui.notify(t('swagger.runStarted', { key: tk.key }))
    await router.push({ name: 'ticket', params: { key: tk.key } })
  },
  onError: (e) => (e instanceof HttpError && e.status === 409 ? ui.notify(t('swagger.busy')) : fail(e)),
})
const update = useMutation({
  mutationFn: (p: { s: SwaggerSuite; body: { enabled?: boolean; schedule?: SwaggerSuite['schedule']; hour?: number; token?: string } }) =>
    unwrap(api.PATCH('/swagger-suites/{id}', { params: { path: { id: p.s.id } }, body: p.body })),
  onSuccess: (s) => {
    tokens[s.id] = ''
    void refresh()
  },
  onError: fail,
})
const remove = useMutation({
  mutationFn: (s: SwaggerSuite) => unwrap(api.DELETE('/swagger-suites/{id}', { params: { path: { id: s.id } } })),
  onSuccess: () => void refresh(),
  onError: fail,
})
const hook = useMutation({
  mutationFn: (s: SwaggerSuite) => unwrap(api.POST('/swagger-suites/{id}/hook', { params: { path: { id: s.id } } })),
  onSuccess: (r, s) => {
    hooks[s.id] = r.url
    void refresh()
  },
  onError: fail,
})
function del(s: SwaggerSuite) {
  if (window.confirm(t('swagger.deleteConfirm', { name: s.name }))) remove.mutate(s)
}
const schedules: SwaggerSuite['schedule'][] = ['off', 'hourly', 'daily', 'weekly']
const scheduleOptions = computed(() => schedules.map((x) => ({ value: x, label: t(`swagger.schedule_${x}`) })))
const when = (iso?: string) => (iso ? ago(iso, locale.value) : t('swagger.never'))
</script>

<template>
  <PageHeader :title="t('swagger.suites')" doc="swagger-test" />
  <div class="col">
    <p class="sub">{{ t('swagger.suitesLede') }}</p>
    <span v-if="error" class="ferr" role="alert">{{ error }}</span>
    <p v-if="suites.data.value && !suites.data.value.length" class="hint">{{ t('swagger.suitesEmpty') }}</p>
    <section v-for="s in suites.data.value ?? []" :key="s.id" class="card ss-card">
      <div class="ch">
        <h2>{{ s.name }}</h2>
        <span v-if="!s.enabled" class="badge b-gray">{{ t('swagger.paused') }}</span>
      </div>
      <p class="sub"><code>{{ s.baseUrl }}</code> · {{ s.operations }} · {{ s.writeEnabled ? t('swagger.modeWrite') : t('swagger.modeRead') }} · {{ t(`swagger.authKind_${s.authKind}`) }}</p>
      <dl class="facts">
        <div><dt>{{ t('swagger.colSchedule') }}</dt><dd>{{ t(`swagger.schedule_${s.schedule}`) }}<template v-if="s.schedule === 'daily' || s.schedule === 'weekly'"> · {{ String(s.hour).padStart(2, '0') }}:00 UTC</template></dd></div>
        <div>
          <dt>{{ t('swagger.lastRun') }}</dt>
          <dd>
            {{ when(s.lastRunAt) }}
            <RouterLink v-if="s.lastTicketKey" :to="{ name: 'ticket', params: { key: s.lastTicketKey } }">{{ s.lastTicketKey }}</RouterLink>
          </dd>
        </div>
        <div v-if="s.enabled && s.nextRunAt"><dt>{{ t('swagger.nextRun') }}</dt><dd>{{ new Date(s.nextRunAt).toLocaleString(locale) }}</dd></div>
      </dl>
      <fieldset v-if="workspace.canEdit" class="ro-fs ss-act">
        <button type="button" class="btn btn-p" :disabled="run.isPending.value" @click="run.mutate(s)">{{ t('swagger.runNow') }}</button>
        <InputSelect
          class="ss-sched"
          :model-value="s.schedule"
          :options="scheduleOptions"
          :label="t('swagger.schedule')"
          @update:model-value="(v) => update.mutate({ s, body: { schedule: v } })"
        />
        <label v-if="s.schedule === 'daily' || s.schedule === 'weekly'" class="ss-hour">
          {{ t('swagger.hourUtc') }}
          <input class="cfg-in" type="number" min="0" max="23" :value="s.hour" @change="update.mutate({ s, body: { hour: Number(($event.target as HTMLInputElement).value) } })">
        </label>
        <button type="button" class="btn" @click="update.mutate({ s, body: { enabled: !s.enabled } })">{{ s.enabled ? t('swagger.pause') : t('swagger.resume') }}</button>
        <button type="button" class="btn" :disabled="hook.isPending.value" @click="hook.mutate(s)">{{ s.hookSet ? t('swagger.hookRotate') : t('swagger.hookCreate') }}</button>
        <span v-if="s.authKind !== 'none'" class="ss-token">
          <input v-model="tokens[s.id]" class="cfg-in mono" type="password" autocomplete="off" :placeholder="t('swagger.suiteToken')" :aria-label="t('swagger.suiteToken')">
          <button type="button" class="btn" :disabled="!tokens[s.id]" @click="update.mutate({ s, body: { token: tokens[s.id] } })">{{ t('swagger.setToken') }}</button>
        </span>
        <button type="button" class="btn btn-d" @click="del(s)">{{ t('swagger.deleteSuite') }}</button>
      </fieldset>
      <div v-if="hooks[s.id]" class="ss-hook">
        <p class="hint">{{ t('swagger.hookHint') }}</p>
        <pre>{{ t('swagger.hookExample', { url: hooks[s.id] }) }}</pre>
      </div>
    </section>
  </div>
</template>

<style scoped>
.ss-card { margin-bottom: 12px; }
.ss-act { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; border: 0; padding: 0; margin-top: 8px; }
.ss-hour { display: inline-flex; gap: 8px; align-items: center; }
.ss-hour .cfg-in { width: 90px; }
.ss-sched { width: 220px; }
.ss-token .cfg-in { width: 240px; max-width: 100%; }
.ss-token { display: inline-flex; gap: 6px; align-items: center; flex-wrap: wrap; }
.ss-hook pre { white-space: pre-wrap; word-break: break-all; }
</style>
