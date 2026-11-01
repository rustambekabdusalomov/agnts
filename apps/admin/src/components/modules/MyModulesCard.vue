<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { useUi } from '../../stores/ui'
import ModuleList from './ModuleList.vue'
import { listProblem, type Module } from './modules'

// The modules an Admin lets the person use, in the person's own order: the
// first is their default module, which settings fall back to and the
// pages name.
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const mine = useQuery({ queryKey: ['my-modules'], queryFn: () => unwrap(api.GET('/account/modules')) })
const order = ref<Module[]>([])
watch(() => mine.data.value, (m) => { if (m) order.value = [...m.effective] }, { immediate: true })
const changed = computed(() => order.value.join() !== (mine.data.value?.effective ?? []).join())
const problem = computed(() => (listProblem(order.value) === 'codexFirst' ? 'codexFirst' : ''))

const save = useMutation({
  mutationFn: (o: Module[] | null) => unwrap(api.PUT('/account/modules', { body: { order: o } })),
  onSuccess: (m) => {
    qc.setQueryData(['my-modules'], m)
    // The model list, the pages' wording and the usage pill follow the default module.
    void qc.invalidateQueries({ queryKey: ['models'] })
    void qc.invalidateQueries({ queryKey: ['usage'] })
    ui.notify(t('modules.mineSaved'))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
</script>

<template>
  <section v-if="(mine.data.value?.effective.length ?? 0) > 1" class="card">
    <div class="ch"><div><h2>{{ t('modules.mineTitle') }}</h2><p class="sub">{{ t('modules.mineSub') }}</p></div></div>
    <ModuleList v-model="order" fixed :options="mine.data.value?.effective ?? []" :label="t('modules.mineTitle')" :disabled="save.isPending.value" />
    <p v-if="problem" class="ferr">{{ t('modules.problem_codexFirst') }}</p>
    <div class="actions" style="margin-top: 10px">
      <button v-if="mine.data.value?.order" type="button" class="btn btn-s" :disabled="save.isPending.value" @click="save.mutate(null)">{{ t('modules.mineReset') }}</button>
      <button type="button" class="btn btn-s btn-p" :disabled="!changed || !!problem || save.isPending.value" @click="save.mutate([...order])">{{ t('form.save') }}</button>
    </div>
  </section>
</template>
