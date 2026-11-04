<script setup lang="ts">
import { computed, nextTick, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { apiPath } from '../../api/client'
import type { components } from '../../api/schema.gen'
import HiIcon from '../ui/HiIcon.vue'

// The files a chat message brought (team chat and AI chat): pictures as
// thumbnails that open full size, other files as rows that download.
type AttachedFile = components['schemas']['AttachedFile']
const props = defineProps<{ files: AttachedFile[] }>()
const { t } = useI18n()

// A picture the browser cannot draw (a broken one) falls back to a row.
const broken = ref(new Set<number>())
const pictures = computed(() => props.files.filter((f) => f.image && !broken.value.has(f.id)))
const others = computed(() => props.files.filter((f) => !f.image || broken.value.has(f.id)))

const zoomed = ref<AttachedFile | null>(null)
const dlg = ref<HTMLDialogElement | null>(null)
async function zoom(f: AttachedFile) {
  zoomed.value = f
  await nextTick()
  if (dlg.value && !dlg.value.open) dlg.value.showModal()
}

const size = (n: number) => (n >= 1 << 20 ? `${(n / (1 << 20)).toFixed(1)} MB` : `${Math.max(1, Math.round(n / 1024))} KB`)
</script>

<template>
  <div v-if="files.length" class="cf">
    <ul v-if="pictures.length" class="cf-pics">
      <li v-for="f in pictures" :key="f.id">
        <button type="button" class="cf-thumb" :title="f.name" :aria-label="t('files.open', { name: f.name })" @click="zoom(f)">
          <img :src="apiPath(f.url)" :alt="f.name" loading="lazy" @error="broken = new Set([...broken, f.id])">
        </button>
      </li>
    </ul>
    <ul v-if="others.length" class="cf-list">
      <li v-for="f in others" :key="f.id">
        <a class="cf-row" :href="apiPath(f.url)" :download="f.name" :aria-label="t('files.download', { name: f.name })">
          <HiIcon name="file" />
          <span class="cf-name">{{ f.name }}</span>
          <span class="cf-size">{{ size(f.size) }}</span>
        </a>
      </li>
    </ul>
    <dialog ref="dlg" class="cf-zoom" :aria-label="zoomed?.name" @close="zoomed = null" @click="dlg?.close()">
      <img v-if="zoomed" :src="apiPath(zoomed.url)" :alt="zoomed.name">
    </dialog>
  </div>
</template>

<style scoped>
.cf { display: grid; gap: 6px; margin: 4px 0; }
.cf-pics, .cf-list { list-style: none; margin: 0; padding: 0; }
.cf-pics { display: flex; flex-wrap: wrap; gap: 8px; }
.cf-thumb { display: block; padding: 0; border: 1px solid var(--line); border-radius: 10px; overflow: hidden; background: var(--hover); cursor: zoom-in; }
.cf-thumb img { display: block; width: auto; height: auto; max-width: min(280px, 100%); max-height: 200px; object-fit: cover; }
.cf-list { display: grid; gap: 4px; max-width: 420px; }
.cf-row { display: flex; align-items: center; gap: 8px; padding: 6px 10px; border: 1px solid var(--line); border-radius: 10px; color: var(--ink); text-decoration: none; font-size: 13.5px; }
.cf-row:hover { background: var(--hover); }
.cf-row :deep(svg) { width: 16px; height: 16px; flex: none; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.cf-name { flex: 1; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-weight: 600; }
.cf-size { flex: none; font-size: 12.5px; color: var(--ink-3); }
.cf-zoom { padding: 0; border: 0; border-radius: 10px; max-width: min(96vw, 1600px); max-height: 94vh; background: transparent; cursor: zoom-out; }
.cf-zoom::backdrop { background: rgb(0 0 0 / 0.7); }
.cf-zoom img { display: block; max-width: 100%; max-height: 94vh; height: auto; }
</style>
