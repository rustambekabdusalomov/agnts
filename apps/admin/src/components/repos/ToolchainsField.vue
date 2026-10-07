<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { RepoDetection, Toolchain } from '../../api/types'
import HiIcon from '../ui/HiIcon.vue'
import { parseToolchain, spec } from './toolchains'

// The toolchains a repository's runs install, with Detect (a file scan of
// the default branch) and Ask Claude (README and CI files). Editing the
// list by hand marks it as an override, which detection then keeps.
const props = defineProps<{
  repoId?: number
  cloneUrl: string
  defaultBranch: string
  notes?: string[]
  /** Detect as soon as this turns true (a repository picked for import). */
  autoDetect?: boolean
}>()
const model = defineModel<Toolchain[]>({ required: true })
const override = defineModel<boolean>('override', { default: false })
const emit = defineEmits<{ detected: [det: RepoDetection] }>()
const { t } = useI18n()

const draft = ref('')
const draftError = ref('')
const busy = ref<'' | 'files' | 'claude'>('')
const status = ref('')
const statusError = ref(false)
const lastNotes = ref<string[] | null>(null)
const shownNotes = computed(() => lastNotes.value ?? props.notes ?? [])

function add() {
  if (!draft.value.trim()) return
  const tc = parseToolchain(draft.value)
  if (!tc) {
    draftError.value = t('repos.toolchainBad')
    return
  }
  draftError.value = ''
  model.value = [...model.value.filter((x) => x.tool !== tc.tool), tc]
  override.value = true
  draft.value = ''
}

function remove(i: number) {
  model.value = model.value.filter((_, j) => j !== i)
  override.value = true
}

async function detect(deep: boolean) {
  if (!props.repoId && !props.cloneUrl.trim()) {
    statusError.value = true
    status.value = t('repos.detectNeedsUrl')
    return
  }
  busy.value = deep ? 'claude' : 'files'
  statusError.value = false
  status.value = t('repos.detecting')
  try {
    const det = await unwrap(api.POST('/repos/detect', {
      body: props.repoId
        ? { id: props.repoId, cloneUrl: props.cloneUrl.trim() || undefined, defaultBranch: props.defaultBranch.trim() || undefined, deep }
        : { cloneUrl: props.cloneUrl.trim(), defaultBranch: props.defaultBranch.trim() || undefined, deep },
    }))
    model.value = det.toolchains
    override.value = false
    lastNotes.value = det.notes
    const found = det.toolchains.map(spec).join(', ')
    status.value = found ? t('repos.detectDone', { list: found }) : t('repos.detectNothing')
    if (det.source === 'claude') status.value += ' ' + t('repos.detectByClaude')
    emit('detected', det)
  } catch (e) {
    statusError.value = true
    status.value = e instanceof HttpError ? e.message : t('common.error')
  } finally {
    busy.value = ''
  }
}

watch(
  () => props.autoDetect,
  (v) => {
    if (v && !busy.value) void detect(false)
  },
  { immediate: true },
)

function backToAuto() {
  override.value = false
  void detect(false)
}

const sourceLabel = (tc: Toolchain) => {
  const bits = []
  if (tc.source) bits.push(t('repos.toolchainFrom', { source: tc.source }))
  return bits.join(' · ')
}
</script>

<template>
  <fieldset class="field tc">
    <legend class="flbl">{{ t('repos.toolchains') }}</legend>
    <span class="fhelp">{{ t('repos.toolchainsHelp') }}</span>
    <div class="chips" role="group" :aria-label="t('repos.toolchains')">
      <span v-for="(tc, i) in model" :key="tc.tool" class="chip" :title="sourceLabel(tc)">
        <span class="tc-spec">{{ spec(tc) }}</span>
        <span v-if="tc.dir" class="tc-dir">{{ tc.dir }}/</span>
        <button type="button" :aria-label="t('repos.toolchainRemove', { tool: tc.tool })" @click="remove(i)"><HiIcon name="close" /></button>
      </span>
      <span v-if="!model.length" class="hint">{{ t('repos.toolchainsNone') }}</span>
      <span class="chip-add">
        <input v-model="draft" :placeholder="t('repos.toolchainPh')" :aria-label="t('repos.toolchainPh')" spellcheck="false" @keydown.enter.prevent="add">
        <button type="button" class="btn btn-s" @click="add">{{ t('repos.toolchainAdd') }}</button>
      </span>
    </div>
    <span v-if="draftError" class="ferr" role="alert">{{ draftError }}</span>
    <span class="hint">{{ override ? t('repos.toolchainsManual') : t('repos.toolchainsAuto') }}</span>
    <span class="tc-actions">
      <button type="button" class="btn btn-s" :disabled="!!busy" @click="detect(false)">{{ t('repos.detect') }}</button>
      <button type="button" class="btn btn-s" :disabled="!!busy" :title="t('repos.detectDeepHelp')" @click="detect(true)">{{ t('repos.detectDeep') }}</button>
      <button v-if="override" type="button" class="btn btn-s" :disabled="!!busy" @click="backToAuto">{{ t('repos.toolchainsBackToAuto') }}</button>
    </span>
    <span v-if="status" :class="statusError ? 'ferr' : 'hint'" role="status" aria-live="polite">{{ status }}</span>
    <div v-if="shownNotes.length" class="tc-notes">
      <span class="flbl">{{ t('repos.notes') }}</span>
      <ul>
        <li v-for="n in shownNotes" :key="n">{{ n }}</li>
      </ul>
    </div>
  </fieldset>
</template>

<style scoped>
.tc { border: 1px solid var(--line); border-radius: 12px; padding: 12px 14px; margin: 0; display: grid; gap: 8px; }
.tc legend { padding: 0 6px; }
.tc-spec { font-family: var(--mono); font-size: 13.5px; }
.tc-dir { color: var(--ink-3); font-size: 12.5px; margin-left: 4px; }
.tc-actions { display: flex; flex-wrap: wrap; gap: 6px; }
.tc-notes ul { margin: 4px 0 0; padding-left: 18px; color: var(--ink-3); font-size: 13.5px; }
</style>
