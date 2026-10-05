<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import type { Repository } from '../../api/types'
import { useUi } from '../../stores/ui'
import FormDrawer from '../form/FormDrawer.vue'
import SegButtons from '../form/SegButtons.vue'
import HiIcon from '../ui/HiIcon.vue'

// "New task" drawer from the demo. Creating a task opens its ticket page.
const props = defineProps<{ repos: Repository[]; repoId?: number | null }>()
const open = defineModel<boolean>({ default: false })
defineEmits<{ addRepo: [] }>()
const { t } = useI18n()
const router = useRouter()
const qc = useQueryClient()
const ui = useUi()

type Priority = 'low' | 'medium' | 'high'
type After = 'main' | 'pr'
type Start = 'ask' | 'code' | 'queue'
const form = reactive({ repoId: 0, title: '', description: '', priority: 'medium' as Priority, after: 'pr' as After, start: 'ask' as Start })
const error = ref('')

watch(
  open,
  (v) => {
    if (!v) return
    error.value = ''
    form.repoId = props.repoId ?? props.repos[0]?.id ?? 0
  },
  { immediate: true },
)

const priorities = computed(() => (['low', 'medium', 'high'] as Priority[]).map((p) => ({ value: p, label: t(`tasks.${p}`) })))
const afters = computed(() => [
  { value: 'main' as After, label: t('tasks.afterMain') },
  { value: 'pr' as After, label: t('tasks.afterPr') },
])
const starts = computed(() => [
  { value: 'ask' as Start, label: t('tasks.startAsk'), hint: t('tasks.startAskHint') },
  { value: 'code' as Start, label: t('tasks.startCode'), hint: t('tasks.startCodeHint') },
  { value: 'queue' as Start, label: t('tasks.startQueue'), hint: t('tasks.startQueueHint') },
])

const create = useMutation({
  mutationFn: () =>
    unwrap(
      api.POST('/tasks', {
        body: {
          repoId: form.repoId,
          title: form.title.trim(),
          description: form.description.trim(),
          priority: form.priority,
          afterApprove: form.after,
          start: form.start,
        },
      }),
    ),
  onSuccess: async (tk) => {
    for (const k of ['tickets', 'nav', 'repos']) void qc.invalidateQueries({ queryKey: [k] })
    ui.notify(t('tasks.created', { key: tk.key }))
    open.value = false
    form.title = ''
    form.description = ''
    await router.push(`/tickets/${tk.key}`)
  },
  onError: (e) => {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})

function submit() {
  if (!form.repoId) {
    error.value = t('tasks.addRepoFirst')
    return
  }
  if (!form.title.trim()) {
    error.value = t('tasks.titleRequired')
    return
  }
  create.mutate()
}
</script>

<template>
  <FormDrawer v-model="open" :title="t('tasks.new')" :subtitle="t('tasks.drawerSub')">
    <form id="task-form" style="display: contents" @submit.prevent="submit">
      <div class="field">
        <span class="flbl">{{ t('tasks.repository') }}</span>
        <div class="tabs" role="group" :aria-label="t('tasks.repository')">
          <button
            v-for="r in repos"
            :key="r.id"
            type="button"
            class="tab"
            :aria-pressed="form.repoId === r.id"
            @click="form.repoId = r.id"
          >
            {{ r.name }}
          </button>
          <button type="button" class="tab" @click="$emit('addRepo')">
            <HiIcon name="import" style="width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2.4; vertical-align: -2px" />
            {{ t('repos.import') }}
          </button>
        </div>
      </div>
      <div class="field">
        <label for="t-title">{{ t('tasks.fieldTitle') }}</label>
        <input id="t-title" v-model="form.title" type="text" maxlength="300" :placeholder="t('tasks.titlePh')">
      </div>
      <div class="field">
        <label for="t-desc">{{ t('tasks.fieldDesc') }}</label>
        <textarea id="t-desc" v-model="form.description" maxlength="20000" :placeholder="t('tasks.descPh')" />
      </div>
      <div class="field">
        <span class="flbl">{{ t('tasks.priority') }}</span>
        <SegButtons v-model="form.priority" :options="priorities" :label="t('tasks.priority')" />
      </div>
      <div class="field">
        <span class="flbl">{{ t('tasks.after') }}</span>
        <SegButtons v-model="form.after" :options="afters" :label="t('tasks.after')" />
      </div>
      <div class="field">
        <span class="flbl">{{ t('tasks.start') }}</span>
        <div class="opts" role="group" :aria-label="t('tasks.start')">
          <button
            v-for="o in starts"
            :key="o.value"
            type="button"
            class="opt"
            :aria-pressed="form.start === o.value"
            @click="form.start = o.value"
          >
            <span class="rd" />
            <span><b>{{ o.label }}</b><span class="d">{{ o.hint }}</span></span>
          </button>
        </div>
      </div>
      <span v-if="error" class="ferr" role="alert">{{ error }}</span>
    </form>
    <template #footer>
      <button type="button" class="btn" @click="open = false">{{ t('form.cancel') }}</button>
      <button type="submit" form="task-form" class="btn btn-p" :disabled="create.isPending.value">
        {{ form.start === 'queue' ? t('tasks.create') : t('tasks.createStart') }}
      </button>
    </template>
  </FormDrawer>
</template>
