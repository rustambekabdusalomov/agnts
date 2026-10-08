<script setup lang="ts">
import { apiPath } from '../../api/client'
import { nextTick, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Attachment } from '../../api/types'
import HiIcon from '../ui/HiIcon.vue'

// Attached files: pictures as thumbnails that open large, other files as
// download links.
defineProps<{ files: Attachment[]; label?: string }>()
const { t } = useI18n()

const src = (a: Attachment) => apiPath(a.url)
const kb = (n: number) => (n >= 1 << 20 ? `${(n / (1 << 20)).toFixed(1)} MB` : `${Math.max(1, Math.round(n / 1024))} KB`)

const zoomed = ref<Attachment | null>(null)
const dlg = ref<HTMLDialogElement | null>(null)
async function zoom(a: Attachment) {
  zoomed.value = a
  await nextTick()
  if (dlg.value && !dlg.value.open) dlg.value.showModal()
}
</script>

<template>
  <div v-if="files.length" class="fl">
    <span v-if="label" class="fl-lbl">{{ label }}</span>
    <ul class="fl-list">
      <li v-for="a in files" :key="a.id">
        <button v-if="a.image" type="button" class="fl-img" :aria-label="t('files.open', { name: a.name })" :title="a.name" @click="zoom(a)">
          <img :src="src(a)" :alt="a.name" loading="lazy">
        </button>
        <a v-else class="fl-file" :href="src(a)" :download="a.name" :title="t('files.open', { name: a.name })">
          <HiIcon name="file" /><span>{{ a.name }}</span><span class="fl-size">{{ kb(a.size) }}</span>
        </a>
      </li>
    </ul>
    <dialog ref="dlg" class="fl-zoom" :aria-label="zoomed?.name" @close="zoomed = null" @click="dlg?.close()">
      <img v-if="zoomed" :src="src(zoomed)" :alt="zoomed.name">
    </dialog>
  </div>
</template>

<style scoped>
.fl { display: grid; gap: 6px; margin-top: 8px; }
.fl-lbl { font-size: 12.5px; font-weight: 700; color: var(--ink-3); }
.fl-list { list-style: none; margin: 0; padding: 0; display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
.fl-img { padding: 0; border: 1px solid var(--line); border-radius: 8px; overflow: hidden; cursor: zoom-in; background: var(--hover); display: block; }
.fl-img img { display: block; width: 72px; height: 72px; object-fit: cover; }
.fl-file { display: inline-flex; align-items: center; gap: 6px; max-width: 280px; min-height: 32px; padding: 0 10px; border: 1px solid var(--line); border-radius: 16px; font-size: 13px; color: var(--ink-2); text-decoration: none; }
.fl-file:hover { border-color: var(--ink); }
.fl-file span:first-of-type { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.fl-file :deep(svg) { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; flex: none; }
.fl-size { color: var(--ink-3); flex: none; }
.fl-zoom { padding: 0; border: 0; border-radius: 10px; max-width: min(96vw, 1600px); max-height: 94vh; background: transparent; cursor: zoom-out; }
.fl-zoom::backdrop { background: rgb(0 0 0 / 0.7); }
.fl-zoom img { display: block; max-width: 100%; height: auto; }
</style>
