<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import InputSelect from '../form/InputSelect.vue'
import HiIcon from './HiIcon.vue'

// Pages under a list: which rows are shown, the pages to jump to and how
// many rows a page holds. page counts from 1; the parent slices the rows.
// It hides while one page holds every row, unless always: then the range
// ("1–10 of 10") still shows, without the page buttons.
const props = withDefaults(defineProps<{ total: number; sizes?: number[]; always?: boolean }>(), { sizes: () => [25, 50, 100], always: false })
const page = defineModel<number>({ required: true })
const size = defineModel<number>('size', { required: true })
const { t } = useI18n()

const pages = computed(() => Math.max(1, Math.ceil(props.total / size.value)))
const from = computed(() => (props.total ? (page.value - 1) * size.value + 1 : 0))
const to = computed(() => Math.min(props.total, page.value * size.value))
// The first and last pages, and two either side of this one; gaps between as "…".
const shown = computed(() => {
  const n = pages.value
  const keep = new Set([1, n])
  for (let p = page.value - 2; p <= page.value + 2; p++) if (p >= 1 && p <= n) keep.add(p)
  const out: (number | '…')[] = []
  let last = 0
  for (const p of [...keep].sort((a, b) => a - b)) {
    if (p - last > 1) out.push('…')
    out.push(p)
    last = p
  }
  return out
})
const few = computed(() => props.total <= props.sizes[0])
const sizeOptions = computed(() => props.sizes.map((n) => ({ value: n, label: String(n) })))
function setSize(n: number) {
  // Keep the first row in view on its new page.
  const first = (page.value - 1) * size.value
  size.value = n
  page.value = Math.floor(first / n) + 1
}
</script>

<template>
  <nav v-if="!few || (always && total)" class="pn" :aria-label="t('common.pager')">
    <span class="pn-range">{{ t('common.pageRange', { from, to, n: total }) }}</span>
    <div v-if="!few" class="pn-pages">
      <button type="button" class="btn btn-s pn-btn" :disabled="page <= 1" :aria-label="t('common.pagePrev')" @click="page = page - 1"><HiIcon name="prev" /></button>
      <template v-for="(p, i) in shown" :key="`${p}-${i}`">
        <span v-if="p === '…'" class="pn-gap" aria-hidden="true">…</span>
        <button v-else type="button" class="btn btn-s pn-btn" :class="{ on: p === page }" :aria-current="p === page ? 'page' : undefined" @click="page = p">{{ p }}</button>
      </template>
      <button type="button" class="btn btn-s pn-btn" :disabled="page >= pages" :aria-label="t('common.pageNext')" @click="page = page + 1"><HiIcon name="next" /></button>
    </div>
    <div v-if="!few" class="pn-size">
      <span aria-hidden="true">{{ t('common.perPage') }}</span>
      <InputSelect :model-value="size" :options="sizeOptions" :label="t('common.perPage')" class="pn-sel" @update:model-value="setSize" />
    </div>
  </nav>
</template>

<style scoped>
.pn { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; padding: 14px 2px 2px; border-top: 1px solid var(--line-2); margin-top: 4px; }
.pn-range { font-size: 13.5px; color: var(--ink-3); font-variant-numeric: tabular-nums; }
.pn-pages { display: flex; align-items: center; gap: 4px; margin: 0 auto; }
.pn-btn { min-width: 34px; padding: 0 8px; font-variant-numeric: tabular-nums; }
.pn-btn svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.pn-btn.on { background: var(--primary-soft); border-color: var(--primary); color: var(--ink); font-weight: 700; }
.pn-gap { min-width: 20px; text-align: center; color: var(--ink-3); }
.pn-size { display: flex; align-items: center; gap: 8px; font-size: 13.5px; color: var(--ink-3); }
.pn-sel { width: 84px; }
@media (max-width: 640px) {
  .pn-pages { margin: 0; order: 3; width: 100%; justify-content: center; }
}
</style>
