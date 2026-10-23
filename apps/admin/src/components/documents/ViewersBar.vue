<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { DocumentViewer } from '../../api/types'
import { personHue } from './personColor'

// Who has the document open now: a few initials, and the rest as "+n".
// Guests have a dashed ring; you have a solid one.
const props = defineProps<{ viewers: DocumentViewer[] }>()
const { t } = useI18n()
const SHOW = 5
const shown = computed(() => props.viewers.slice(0, SHOW))
const names = computed(() =>
  props.viewers.map((v) => `${v.name}${v.you ? ` (${t('documents.you')})` : v.kind === 'guest' ? ` (${via(v)})` : ''}`).join(', '),
)
const via = (v: DocumentViewer) => (v.via === 'account' ? t('documents.viaAccount') : v.via === 'google' ? t('documents.viaGoogle') : t('documents.guest'))
const initials = (n: string) =>
  n
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((w) => [...w][0]?.toUpperCase() ?? '')
    .join('') || '?'
</script>

<template>
  <span v-if="viewers.length" class="vb" :title="names" :aria-label="t('documents.viewingNow', { n: viewers.length }) + ': ' + names">
    <span class="vb-faces" aria-hidden="true">
      <span
        v-for="v in shown"
        :key="v.kind + v.id"
        class="vb-face"
        :class="{ guest: v.kind === 'guest' && v.via !== 'account', you: v.you }"
        :style="{ background: `hsl(${personHue(v.name)} 60% 42%)` }"
      >{{ initials(v.name) }}</span>
      <span v-if="viewers.length > SHOW" class="vb-face vb-more">+{{ viewers.length - SHOW }}</span>
    </span>
    <span class="vb-n">{{ t('documents.viewingNow', { n: viewers.length }) }}</span>
  </span>
</template>

<style scoped>
.vb { display: inline-flex; align-items: center; gap: 8px; }
.vb-faces { display: inline-flex; }
.vb-face { width: 26px; height: 26px; border-radius: 50%; color: #fff; font-size: 11px; font-weight: 700; display: inline-flex; align-items: center; justify-content: center; border: 2px solid var(--surface); margin-left: -4px; letter-spacing: -0.02em; }
.vb-face:first-child { margin-left: 0; }
.vb-face.guest { outline: 1.5px dashed var(--ink-3); outline-offset: -1px; }
.vb-face.you { box-shadow: 0 0 0 2px var(--primary, #1a5fb4); }
.vb-more { background: var(--line-3); color: var(--ink); }
.vb-n { font-size: 13px; color: var(--ink-3); }
</style>
