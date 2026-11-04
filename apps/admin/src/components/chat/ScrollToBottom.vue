<script setup lang="ts">
import { useI18n } from 'vue-i18n'

// The round "back to the newest" button over a chat, shown while the
// person has scrolled up; count is how many messages arrived below since.
defineProps<{ show: boolean; count?: number }>()
const emit = defineEmits<{ go: [] }>()
const { t } = useI18n()
</script>

<template>
  <Transition name="stb">
    <button
      v-if="show"
      type="button"
      class="stb"
      :class="{ has: count }"
      :title="t('common.toNewest')"
      :aria-label="count ? `${t('common.toNewest')} (${t('common.newBelow', { n: count })})` : t('common.toNewest')"
      @click="emit('go')"
    >
      <span v-if="count" class="stb-n">{{ t('common.newBelow', { n: count }) }}</span>
      <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5v14M6 13l6 6 6-6" /></svg>
    </button>
  </Transition>
</template>

<style scoped>
.stb {
  position: absolute; right: 18px; bottom: 14px; z-index: 3;
  display: inline-flex; align-items: center; gap: 6px; height: 38px; min-width: 38px; padding: 0 10px;
  justify-content: center; border: 1px solid var(--line); border-radius: 19px;
  background: var(--surface); color: var(--ink); cursor: pointer;
  box-shadow: 0 6px 16px -8px var(--shadow), 0 1px 3px rgb(0 0 0 / 0.12);
}
.stb:hover { background: var(--hover); }
.stb.has { background: var(--primary); border-color: var(--primary); color: #fff; }
.stb.has:hover { filter: brightness(1.08); }
.stb svg { width: 18px; height: 18px; fill: none; stroke: currentColor; stroke-width: 2.2; stroke-linecap: round; stroke-linejoin: round; }
.stb-n { font-size: 13px; font-weight: 700; }
.stb-enter-active, .stb-leave-active { transition: opacity 0.15s, transform 0.15s; }
.stb-enter-from, .stb-leave-to { opacity: 0; transform: translateY(6px); }
@media (prefers-reduced-motion: reduce) { .stb-enter-active, .stb-leave-active { transition: none; } }
</style>
