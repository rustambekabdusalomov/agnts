<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { SecSeverity } from '../../api/types'
import { useUi } from '../../stores/ui'
import { useWorkspace } from '../../stores/workspace'
import CfgRow from '../form/CfgRow.vue'
import SegButtons from '../form/SegButtons.vue'
import { SEVERITIES } from '../security/security'

// A repository's security settings: scan on a schedule, paths no tool
// reports on, and the lowest severity that notifies. Owners change them.
const props = defineProps<{ repoId: number }>()
const { t, locale } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const workspace = useWorkspace()

type Schedule = 'off' | 'daily' | 'weekly'
const settings = useQuery({
  queryKey: computed(() => ['security', 'settings', props.repoId]),
  queryFn: () => unwrap(api.GET('/repos/{id}/security/settings', { params: { path: { id: props.repoId } } })),
})
const form = reactive({ schedule: 'off' as Schedule, exclude: '', minNotify: 'high' as SecSeverity })
watch(
  () => settings.data.value,
  (s) => {
    if (!s) return
    form.schedule = s.schedule
    form.exclude = s.exclude.join('\n')
    form.minNotify = s.minNotify
  },
  { immediate: true },
)
const dirty = computed(() => {
  const s = settings.data.value
  return !!s && (s.schedule !== form.schedule || s.minNotify !== form.minNotify || s.exclude.join('\n') !== form.exclude.trim())
})
const save = useMutation({
  mutationFn: () =>
    unwrap(
      api.PUT('/repos/{id}/security/settings', {
        params: { path: { id: props.repoId } },
        body: { schedule: form.schedule, minNotify: form.minNotify, exclude: form.exclude.split('\n').map((x) => x.trim()).filter(Boolean) },
      }),
    ),
  onSuccess: (s) => {
    qc.setQueryData(['security', 'settings', props.repoId], s)
    ui.notify(t('security.settingsSaved'))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
const schedules = computed(() => (['off', 'daily', 'weekly'] as Schedule[]).map((s) => ({ value: s, label: t(`security.schedule_${s}`) })))
const severities = computed(() => SEVERITIES.filter((s) => s !== 'info').map((s) => ({ value: s, label: t(`security.sev_${s}`) })))
const next = computed(() => settings.data.value?.nextAt && new Date(settings.data.value.nextAt).toLocaleString(locale.value))
</script>

<template>
  <section class="card">
    <div class="ch"><div><h2>{{ t('security.repoSettings') }}</h2><p class="sub">{{ t('security.repoSettingsSub') }}</p></div></div>
    <p v-if="settings.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="settings.isError.value" class="ferr">{{ t('common.error') }}</p>
    <fieldset v-else class="sec-fs" :disabled="!workspace.isOwner">
      <CfgRow :label="t('security.schedule')" :help="next ? t('security.nextScan', { when: next }) : t('security.scheduleHelp')">
        <SegButtons v-model="form.schedule" :options="schedules" :label="t('security.schedule')" />
      </CfgRow>
      <CfgRow :label="t('security.minNotify')" :help="t('security.minNotifyHelp')">
        <SegButtons v-model="form.minNotify" :options="severities" :label="t('security.minNotify')" />
      </CfgRow>
      <CfgRow :label="t('security.exclude')" :help="t('security.excludeHelp')">
        <textarea
          v-model="form.exclude" rows="3" spellcheck="false" placeholder="testdata/**&#10;docs/examples" :aria-label="t('security.exclude')"
          style="font-family: var(--mono); font-size: 12.5px"
        />
      </CfgRow>
      <div v-if="workspace.isOwner" class="actions" style="margin: 8px 0 0">
        <button type="button" class="btn btn-p" :disabled="!dirty || save.isPending.value" @click="save.mutate()">{{ t('security.save') }}</button>
      </div>
      <p v-else class="hint">{{ t('security.ownerOnly') }}</p>
    </fieldset>
  </section>
</template>

<style scoped>
.sec-fs { border: 0; margin: 0; padding: 0; min-width: 0; }
</style>
