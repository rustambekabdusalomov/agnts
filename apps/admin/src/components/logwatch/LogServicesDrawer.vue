<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { LogService, LogSource } from '../../api/types'
import CheckBox from '../form/CheckBox.vue'
import FormDrawer from '../form/FormDrawer.vue'
import InputSelect from '../form/InputSelect.vue'
import { useRepos } from '../repos/useRepos'
import HiIcon from '../ui/HiIcon.vue'

// The services of a source: tick the ones to watch and pick the
// repositories each runs on (several for a gateway). A service with no
// repository is only reported, never ticketed.
const props = defineProps<{ source: LogSource }>()
const open = defineModel<boolean>({ default: false })
const { t } = useI18n()
const qc = useQueryClient()
const repos = useRepos()
const rows = ref<LogService[]>([])
const error = ref('')
const custom = ref('')

const discover = useQuery({
  queryKey: computed(() => ['logwatch', 'discover', props.source.id]),
  queryFn: () => unwrap(api.GET('/log-sources/{sourceId}/discover', { params: { path: { sourceId: props.source.id } } })),
  enabled: computed(() => open.value && props.source.kind !== 'push'),
  retry: false,
})
watch([open, () => discover.data.value], () => {
  if (!open.value) return
  const saved = props.source.services.map((s) => ({ ...s, repoIds: [...s.repoIds] }))
  const found = (discover.data.value ?? []).filter((d) => !saved.some((s) => s.name === d.name))
  rows.value = [...saved, ...found.map((d) => ({ ...d, repoIds: [...d.repoIds] }))]
  error.value = ''
}, { immediate: true })

const repoName = (id: number) => repos.data.value?.find((r) => r.id === id)?.name ?? `#${id}`
const addOptions = (s: LogService) =>
  (repos.data.value ?? []).filter((r) => !r.archivedAt && !s.repoIds.includes(r.id)).map((r) => ({ value: r.id, label: r.name }))
function addRepo(s: LogService, id: number | undefined) {
  if (id && !s.repoIds.includes(id)) s.repoIds.push(id)
  s.enabled = true
}
function addCustom() {
  const name = custom.value.trim()
  if (!name || rows.value.some((r) => r.name === name)) return
  rows.value.push({ name, selector: props.source.kind === 'loki' ? `{service_name="${name}"}` : name, repoIds: [], enabled: true })
  custom.value = ''
}

const save = useMutation({
  mutationFn: () =>
    unwrap(api.PUT('/log-sources/{sourceId}/services', {
      params: { path: { sourceId: props.source.id } },
      body: rows.value.filter((r) => r.enabled || r.id).map((r) => ({ name: r.name, selector: r.selector, repoIds: r.repoIds, enabled: r.enabled, groupId: r.groupId })),
    })),
  onSuccess: () => {
    void qc.invalidateQueries({ queryKey: ['logwatch'] })
    open.value = false
  },
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})
</script>

<template>
  <FormDrawer v-model="open" :title="t('logwatch.servicesOf', { name: source.name })" :subtitle="t('logwatch.servicesSub')">
    <p v-if="discover.isFetching.value" class="hint">{{ t('logwatch.discovering') }}</p>
    <p v-else-if="discover.isError.value" class="ferr">{{ discover.error.value instanceof HttpError ? discover.error.value.message : t('common.error') }}</p>
    <ul v-if="rows.length" class="sv-list">
      <li v-for="s in rows" :key="s.name" class="sv-row" :class="{ off: !s.enabled }">
        <div class="sv-top">
          <CheckBox v-model="s.enabled">{{ s.name }}</CheckBox>
          <input v-model="s.selector" class="cfg-in sv-sel" type="text" maxlength="500" :aria-label="t('logwatch.selectorOf', { name: s.name })">
        </div>
        <div class="sv-repos">
          <span v-for="id in s.repoIds" :key="id" class="chip">
            {{ repoName(id) }}
            <button type="button" class="x" :aria-label="t('form.remove', { name: repoName(id) })" @click="s.repoIds = s.repoIds.filter((x) => x !== id)"><HiIcon name="close" /></button>
          </span>
          <span v-if="!s.repoIds.length" class="hint">{{ t('logwatch.noReposYet') }}</span>
          <div class="sv-add">
            <InputSelect :model-value="undefined" :options="addOptions(s)" :label="t('logwatch.addRepo')" :placeholder="t('logwatch.addRepo')" @update:model-value="(v) => addRepo(s, v as number | undefined)" />
          </div>
        </div>
      </li>
    </ul>
    <p v-else-if="!discover.isFetching.value" class="hint">{{ t('logwatch.noServices') }}</p>
    <div class="field">
      <label for="sv-custom">{{ t('logwatch.addService') }}</label>
      <div style="display: flex; gap: 6px">
        <input id="sv-custom" v-model="custom" type="text" maxlength="120" :placeholder="t('logwatch.addServicePh')" @keydown.enter.prevent="addCustom">
        <button type="button" class="btn" @click="addCustom">{{ t('logwatch.add') }}</button>
      </div>
    </div>
    <span v-if="error" class="ferr" role="alert">{{ error }}</span>
    <template #footer>
      <button type="button" class="btn" @click="open = false">{{ t('form.cancel') }}</button>
      <button type="button" class="btn btn-p" :disabled="save.isPending.value" @click="save.mutate()">{{ t('form.save') }}</button>
    </template>
  </FormDrawer>
</template>

<style scoped>
.sv-list { list-style: none; margin: 0; padding: 0; display: grid; gap: 10px; }
.sv-row { border: 1px solid var(--line); border-radius: 10px; padding: 10px 12px; display: grid; gap: 8px; }
.sv-row.off { opacity: 0.6; }
.sv-top { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1.2fr); gap: 8px; align-items: center; }
.sv-sel { font-family: var(--mono); font-size: 12.5px; width: 100%; }
.sv-repos { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
.sv-add { min-width: 200px; flex: 1; }
.chip { display: inline-flex; align-items: center; gap: 4px; border: 1px solid var(--line-3); border-radius: 999px; padding: 2px 8px; font-size: 13px; }
.chip .x { border: 0; background: none; padding: 0; cursor: pointer; display: inline-flex; }
.chip .x :deep(svg) { width: 11px; height: 11px; stroke: currentColor; fill: none; stroke-width: 2.4; }
@media (max-width: 560px) { .sv-top { grid-template-columns: 1fr; } }
</style>
