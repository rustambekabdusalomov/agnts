<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import HiIcon from '../ui/HiIcon.vue'
import SlideView from './SlideView.vue'
import { splitSlides } from './slides'

// A deck read on the page: its slides one under the other, each with its
// speaker notes when notes is set. Each slide has a button to present from
// it; the slide itself stays text people can select (and comment on), and
// says which slide it is in data-slide.
const props = defineProps<{ markdown: string; notes?: boolean; compact?: boolean }>()
const emit = defineEmits<{ present: [index: number] }>()
const { t } = useI18n()
const slides = computed(() => splitSlides(props.markdown))
</script>

<template>
  <p v-if="!slides.length" class="hint">{{ t('documents.noSlides') }}</p>
  <ol v-else class="deck" :class="{ compact }">
    <li v-for="(s, i) in slides" :key="i" class="deck-item">
      <div class="deck-slide" :data-slide="i">
        <SlideView :slide="s" :n="i + 1" :total="slides.length" />
        <button type="button" class="deck-play" :title="t('documents.presentFrom', { n: i + 1 })" :aria-label="t('documents.presentFrom', { n: i + 1 })" @click="emit('present', i)">
          <HiIcon name="play" />
        </button>
      </div>
      <div v-if="notes && s.notes" class="deck-notes">
        <span class="flbl">{{ t('documents.notes') }}</span>
        <p>{{ s.notes }}</p>
      </div>
    </li>
  </ol>
</template>

<style scoped>
.deck { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 22px; }
.deck.compact { gap: 12px; }
.deck-item { display: flex; flex-direction: column; gap: 8px; }
.deck-slide { position: relative; }
.deck-play { position: absolute; top: 10px; right: 10px; width: 34px; height: 34px; border-radius: 50%; border: 1px solid #d5d5d8; background: rgba(255, 255, 255, 0.92); color: #1d1d1f; display: inline-flex; align-items: center; justify-content: center; cursor: pointer; opacity: 0; transition: opacity 0.15s; }
.deck-slide:hover .deck-play, .deck-play:focus-visible { opacity: 1; }
@media (hover: none) { .deck-play { opacity: 0.85; } }
.deck-play :deep(svg) { width: 16px; height: 16px; fill: currentColor; stroke: none; }
.deck-notes { font-size: 13.5px; color: var(--ink-2, inherit); border-left: 3px solid var(--line-3); padding: 2px 0 2px 10px; }
.deck-notes p { margin: 2px 0 0; white-space: pre-wrap; }
</style>
