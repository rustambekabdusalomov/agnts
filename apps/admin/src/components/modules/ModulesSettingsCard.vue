<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { HttpError } from '../../api/client'
import { useModulesSettings } from '../../composables/usePlatform'
import CheckBox from '../form/CheckBox.vue'
import ModuleList from './ModuleList.vue'
import { listProblem, type Module } from './modules'

// Which coding modules people may be given (within what the server can run)
// and the list everyone gets unless an Admin set theirs, the default first.
const { t } = useI18n()
const { settings, save } = useModulesSettings()

const available = computed(() => settings.data.value?.available ?? [])
const enabled = ref<Module[]>([])
const list = ref<Module[]>([])
watch(() => settings.data.value, (s) => {
  if (!s) return
  enabled.value = [...s.enabled]
  list.value = [...s.default]
}, { immediate: true })
// A module that is switched off leaves the default list too.
function enable(m: Module, on: boolean) {
  enabled.value = on ? available.value.filter((x) => x === m || enabled.value.includes(x)) : enabled.value.filter((x) => x !== m)
  if (!on) list.value = list.value.filter((x) => x !== m)
}
const problem = computed(() => (!enabled.value.length ? 'noneEnabled' : listProblem(list.value)))
const errText = computed(() => (save.error.value ? (save.error.value instanceof HttpError ? save.error.value.message : t('common.error')) : ''))
function submit() {
  if (problem.value || !settings.data.value) return
  save.mutate({ available: settings.data.value.available, enabled: [...enabled.value], default: [...list.value] })
}
</script>

<template>
  <section class="card">
    <div class="ch"><div><h2>{{ t('modules.title') }}</h2><p class="sub">{{ t('modules.sub') }}</p></div></div>
    <p v-if="settings.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="settings.isError.value" class="ferr">{{ t('common.error') }}</p>
    <form v-else @submit.prevent="submit">
      <div class="cfg-row">
        <div><b>{{ t('modules.available') }}</b><div class="hint">{{ t('modules.availableHelp') }}</div></div>
        <span class="row-actions">
          <span v-for="m in available" :key="m" class="badge b-gray">{{ t(`modules.name_${m}`) }}</span>
        </span>
      </div>
      <div class="cfg-row">
        <div><b>{{ t('modules.enabled') }}</b><div class="hint">{{ t('modules.enabledHelp') }}</div></div>
        <span class="row-actions">
          <CheckBox v-for="m in available" :key="m" :model-value="enabled.includes(m)" @update:model-value="(on) => enable(m, on)">{{ t(`modules.name_${m}`) }}</CheckBox>
        </span>
      </div>
      <div class="cfg-row">
        <div><b>{{ t('modules.defaultList') }}</b><div class="hint">{{ t('modules.defaultListHelp') }}</div></div>
        <ModuleList v-model="list" :options="enabled" :label="t('modules.defaultList')" style="min-width: 240px" />
      </div>
      <p v-if="problem" class="ferr">{{ t(`modules.problem_${problem}`) }}</p>
      <p v-if="errText" class="ferr">{{ errText }}</p>
      <div class="actions">
        <button class="btn btn-p" type="submit" :disabled="save.isPending.value || !!problem">{{ t('modules.save') }}</button>
      </div>
    </form>
  </section>
</template>
