<script setup lang="ts">
import { computed, onBeforeUnmount, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, MAX_ATTACHMENT_BYTES, MAX_ATTACHMENTS, uploadAttachment } from '../../api/client'
import HiIcon from '../ui/HiIcon.vue'

// Attach files to a task, an answer or a retry note. Files upload as soon
// as they are picked, dropped or pasted; the parent sends the ids with its
// request. Clearing the ids (after a successful send) clears the list.
const ids = defineModel<number[]>({ default: () => [] })
const busy = defineModel<boolean>('busy', { default: false })
defineProps<{ label?: string }>()
const { t } = useI18n()

type Item = { key: number; name: string; size: number; id?: number; preview?: string; error?: string }
const items = ref<Item[]>([])
let seq = 0
const input = ref<HTMLInputElement | null>(null)
const dragging = ref(false)

const uploading = computed(() => items.value.some((i) => !i.id && !i.error))
watch(uploading, (v) => (busy.value = v), { immediate: true })
watch(ids, (v) => {
  if (v.length === 0 && items.value.some((i) => i.id)) clear()
})

function sync() {
  ids.value = items.value.flatMap((i) => (i.id ? [i.id] : []))
}

function add(files: Iterable<File>) {
  for (const f of files) {
    if (items.value.filter((i) => !i.error).length >= MAX_ATTACHMENTS) {
      items.value.push({ key: ++seq, name: f.name, size: f.size, error: t('files.tooMany', { n: MAX_ATTACHMENTS }) })
      break
    }
    const item: Item = { key: ++seq, name: f.name || 'file', size: f.size }
    if (f.size > MAX_ATTACHMENT_BYTES) item.error = t('files.tooLarge', { name: item.name })
    else if (f.type.startsWith('image/')) item.preview = URL.createObjectURL(f)
    items.value.push(item)
    if (item.error) continue
    const it = items.value[items.value.length - 1]
    uploadAttachment(f)
      .then((a) => {
        if (!items.value.includes(it)) {
          // Removed while it was uploading.
          void api.DELETE('/attachments/{id}', { params: { path: { id: a.id } } })
          return
        }
        it.id = a.id
        sync()
      })
      .catch((e) => {
        it.error = e instanceof HttpError && e.status === 413 ? t('files.tooLarge', { name: it.name }) : t('files.failed', { name: it.name })
      })
  }
}

function remove(it: Item) {
  items.value = items.value.filter((i) => i !== it)
  if (it.preview) URL.revokeObjectURL(it.preview)
  if (it.id) void api.DELETE('/attachments/{id}', { params: { path: { id: it.id } } })
  sync()
}

function clear() {
  for (const i of items.value) if (i.preview) URL.revokeObjectURL(i.preview)
  items.value = []
}
onBeforeUnmount(clear)

function picked(e: Event) {
  const el = e.target as HTMLInputElement
  if (el.files) add(Array.from(el.files))
  el.value = ''
}
function dropped(e: DragEvent) {
  dragging.value = false
  if (e.dataTransfer?.files.length) add(Array.from(e.dataTransfer.files))
}
// A screenshot pasted into the field around this control attaches it.
function pasted(e: ClipboardEvent) {
  const files = Array.from(e.clipboardData?.files ?? [])
  if (files.length) {
    e.preventDefault()
    add(files)
  }
}
defineExpose({ pasted })

const kb = (n: number) => (n >= 1 << 20 ? `${(n / (1 << 20)).toFixed(1)} MB` : `${Math.max(1, Math.round(n / 1024))} KB`)
</script>

<template>
  <div
    class="fa"
    :class="{ drag: dragging }"
    @dragover.prevent="dragging = true"
    @dragleave="dragging = false"
    @drop.prevent="dropped"
    @paste="pasted"
  >
    <div class="fa-row">
      <button type="button" class="tab fa-btn" @click="input?.click()">
        <HiIcon name="attach" />{{ label ?? t('files.attach') }}
      </button>
      <span class="hint">{{ t('files.hint') }}</span>
      <input ref="input" type="file" multiple hidden @change="picked">
    </div>
    <ul v-if="items.length" class="fa-list">
      <li v-for="it in items" :key="it.key" class="fa-item" :class="{ bad: it.error }">
        <img v-if="it.preview" :src="it.preview" alt="">
        <HiIcon v-else name="file" />
        <span class="fa-name">
          <b>{{ it.name }}</b>
          <span v-if="it.error" class="fa-err" role="alert">{{ it.error }}</span>
          <span v-else-if="!it.id" class="fa-meta" role="status"><span class="spin" aria-hidden="true" />{{ t('files.uploading', { name: it.name }) }}</span>
          <span v-else class="fa-meta">{{ kb(it.size) }}</span>
        </span>
        <button type="button" class="fa-x" :aria-label="t('files.remove', { name: it.name })" @click="remove(it)"><HiIcon name="close" /></button>
      </li>
    </ul>
  </div>
</template>

<style scoped>
.fa { display: grid; gap: 8px; border-radius: 12px; }
.fa.drag { outline: 2px dashed var(--primary); outline-offset: 4px; }
.fa-row { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.fa-btn { display: inline-flex; align-items: center; gap: 6px; }
.fa-btn :deep(svg), .fa-item > :deep(svg) { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex: none; }
.fa-list { list-style: none; margin: 0; padding: 0; display: grid; gap: 6px; }
.fa-item { display: flex; align-items: center; gap: 10px; border: 1px solid var(--line); border-radius: 10px; padding: 6px 6px 6px 10px; min-width: 0; }
.fa-item.bad { border-color: var(--bad-ink); }
.fa-item img { width: 36px; height: 36px; object-fit: cover; border-radius: 6px; flex: none; }
.fa-name { display: grid; min-width: 0; flex: 1; font-size: 13.5px; }
.fa-name b { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.fa-meta { display: inline-flex; align-items: center; gap: 6px; font-size: 12.5px; color: var(--ink-3); }
.fa-meta .spin { width: 12px; height: 12px; }
.fa-err { font-size: 12.5px; color: var(--bad-ink); }
.fa-x { width: 28px; height: 28px; border-radius: 14px; border: 0; background: transparent; display: inline-flex; align-items: center; justify-content: center; cursor: pointer; color: var(--ink-3); flex: none; }
.fa-x:hover { background: var(--hover); color: var(--bad-ink); }
.fa-x :deep(svg) { width: 12px; height: 12px; stroke: currentColor; fill: none; stroke-width: 2.4; stroke-linecap: round; }
</style>
