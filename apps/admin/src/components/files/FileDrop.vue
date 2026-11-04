<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import HiIcon from '../ui/HiIcon.vue'

// One file to send later (the parent uploads it): dropped or chosen,
// checked against accept and maxBytes, then shown as a row the parent's
// progress (0..1, null when idle) fills while it uploads. A file that
// fails the checks is not taken; its error shows instead.
const file = defineModel<File | null>({ default: null })
const props = withDefaults(
  defineProps<{
    id?: string
    accept?: string
    maxBytes?: number
    progress?: number | null
    disabled?: boolean
    /** What the empty area says before "choose a file". */
    prompt?: string
    /** The line under it: the kinds of file and the limit. */
    hint?: string
    tooBig?: string
    badType?: (name: string) => string
  }>(),
  { id: undefined, accept: '', maxBytes: 0, progress: null, disabled: false, prompt: undefined, hint: undefined, tooBig: undefined, badType: undefined },
)
const { t } = useI18n()

const input = ref<HTMLInputElement | null>(null)
const dragging = ref(false)
const error = ref('')
const busy = computed(() => props.progress !== null)
const locked = computed(() => props.disabled || busy.value)

/** Whether a file matches accept: "video/*", "audio/mpeg" or ".mkv" entries. */
function accepted(f: File): boolean {
  const rules = props.accept.split(',').map((r) => r.trim().toLowerCase()).filter(Boolean)
  if (!rules.length) return true
  const name = f.name.toLowerCase()
  const type = f.type.toLowerCase()
  return rules.some((r) => (r.startsWith('.') ? name.endsWith(r) : r.endsWith('/*') ? type.startsWith(r.slice(0, -1)) : type === r))
}

function take(f: File | undefined) {
  if (!f || locked.value) return
  if (!accepted(f)) {
    error.value = props.badType?.(f.name) ?? t('files.failed', { name: f.name })
    return
  }
  if (props.maxBytes && f.size > props.maxBytes) {
    error.value = props.tooBig ?? t('files.failed', { name: f.name })
    return
  }
  error.value = ''
  file.value = f
}
function picked(e: Event) {
  const el = e.target as HTMLInputElement
  take(el.files?.[0])
  el.value = ''
}
function dropped(e: DragEvent) {
  dragging.value = false
  take(e.dataTransfer?.files[0])
}
function over() {
  if (!locked.value) dragging.value = true
}
function remove() {
  file.value = null
  error.value = ''
}
function choose() {
  if (!locked.value) input.value?.click()
}

const kind = computed(() => (file.value?.type.startsWith('audio/') || /\.(opus|mp3|m4a|wav|ogg|flac)$/i.test(file.value?.name ?? '') ? 'mic' : 'video'))
const size = (n: number) => (n >= 1 << 30 ? `${(n / (1 << 30)).toFixed(1)} GB` : n >= 1 << 20 ? `${(n / (1 << 20)).toFixed(1)} MB` : `${Math.max(1, Math.round(n / 1024))} KB`)
const pct = computed(() => Math.round((props.progress ?? 0) * 100))
</script>

<template>
  <div class="fd" :class="{ drag: dragging, has: file, busy, off: disabled }" @dragover.prevent="over" @dragleave="dragging = false" @drop.prevent="dropped">
    <input ref="input" class="fd-input" type="file" :accept="accept || undefined" :disabled="locked" tabindex="-1" aria-hidden="true" @change="picked">
    <div v-if="file" class="fd-file">
      <span class="fd-fill" :style="{ width: busy ? pct + '%' : '0' }" aria-hidden="true" />
      <span class="fd-ico"><HiIcon :name="kind" /></span>
      <span class="fd-txt">
        <span class="fd-name" :title="file.name">{{ file.name }}</span>
        <span class="fd-meta">{{ size(file.size) }}<template v-if="busy"> · {{ pct }}%</template></span>
      </span>
      <progress v-if="busy" class="fd-sr" :value="progress ?? 0" max="1" :aria-label="t('files.uploading', { name: file.name })" />
      <button v-if="!busy" :id="id" type="button" class="btn btn-s fd-change" :disabled="disabled" @click="choose">{{ t('files.change') }}</button>
      <button v-if="!busy" type="button" class="fd-x" :disabled="disabled" :aria-label="t('files.remove', { name: file.name })" @click="remove"><HiIcon name="close" /></button>
    </div>
    <button v-else :id="id" type="button" class="fd-zone" :disabled="locked" :aria-describedby="hint ? `${id}-hint` : undefined" @click="choose">
      <span class="fd-zone-ico"><HiIcon name="upload" /></span>
      <span class="fd-zone-txt">{{ prompt ?? t('files.dropOne') }} <span class="fd-link">{{ t('files.choose') }}</span></span>
      <span v-if="hint" :id="`${id}-hint`" class="fd-hint">{{ hint }}</span>
    </button>
    <p v-if="error" class="fd-err" role="alert">{{ error }}</p>
  </div>
</template>

<style scoped>
.fd { display: flex; flex-direction: column; gap: 6px; }
.fd-input { position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none; }
.fd-zone { display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; width: 100%; min-height: 112px; padding: 16px; border: 1.5px dashed var(--line-4); border-radius: 12px; background: var(--field); color: var(--ink-2); font: inherit; font-size: 14px; text-align: center; cursor: pointer; transition: border-color .15s, background .15s; }
.fd-zone:hover:not(:disabled), .fd.drag .fd-zone { border-color: var(--primary); background: var(--primary-soft); }
.fd-zone:focus-visible { outline: none; border-color: var(--primary); box-shadow: 0 0 0 3px var(--ring); }
.fd-zone:disabled { cursor: default; opacity: .6; }
.fd-zone-ico { display: grid; place-items: center; width: 36px; height: 36px; margin-bottom: 2px; border-radius: 50%; background: var(--surface); color: var(--primary); }
.fd-zone-ico svg { width: 18px; height: 18px; }
.fd-link { color: var(--primary); font-weight: 600; text-decoration: underline; text-underline-offset: 2px; }
.fd-hint { color: var(--ink-3); font-size: 12.5px; }
.fd-file { position: relative; display: flex; align-items: center; gap: 12px; min-height: 64px; padding: 10px 10px 10px 12px; border: 1px solid var(--line-3); border-radius: 12px; background: var(--surface); overflow: hidden; }
.fd.drag .fd-file { border-color: var(--primary); }
.fd-fill { position: absolute; inset: 0 auto 0 0; background: var(--primary-soft); transition: width .2s; }
.fd-ico, .fd-txt, .fd-change, .fd-x { position: relative; }
.fd-ico { display: grid; place-items: center; flex: none; width: 40px; height: 40px; border-radius: 10px; background: var(--primary-soft); color: var(--primary-ink); }
.fd.busy .fd-ico { background: var(--surface); }
.fd-ico svg { width: 20px; height: 20px; }
.fd-txt { display: flex; flex-direction: column; flex: 1; min-width: 0; }
.fd-name { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-weight: 600; font-size: 14px; }
.fd-meta { color: var(--ink-3); font-size: 12.5px; font-variant-numeric: tabular-nums; }
.fd-x { display: grid; place-items: center; flex: none; width: 32px; height: 32px; border: 0; border-radius: 8px; background: none; color: var(--ink-3); cursor: pointer; }
.fd-x:hover:not(:disabled) { background: var(--hover); color: var(--ink); }
.fd-x svg { width: 16px; height: 16px; }
.fd-sr { position: absolute; width: 1px; height: 1px; opacity: 0; }
.fd-err { margin: 0; color: var(--bad-ink); font-size: 13px; }
@media (max-width: 480px) { .fd-change { display: none; } }
</style>
