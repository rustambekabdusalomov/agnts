<script lang="ts">
/**
 * The name every AI badge shows. Static for now, whichever provider the
 * Team chat model runs on; the real provider and model are in ai and show
 * in the tooltip. Switching the badge to the real name is a change here.
 */
export const AI_NAME = 'Muse'
</script>

<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { ChatAI } from './chat'
import { secs } from './chat'

// "✨ Muse · 1.2s" on anything a model made.
const props = defineProps<{ ai: ChatAI; extra?: string }>()
const { t } = useI18n()
const tip = computed(() =>
  t('teamchat.aiTip', { model: props.ai.model || props.ai.provider, cost: props.ai.costUsd ? `$${props.ai.costUsd.toFixed(3)}` : '—' }),
)
</script>

<template>
  <span class="ai-badge" :title="tip">✨ {{ AI_NAME }} · {{ secs(ai.ms) }}s<template v-if="extra"> · {{ extra }}</template></span>
</template>

<style scoped>
.ai-badge { display: inline-flex; align-items: center; gap: 2px; padding: 1px 8px; border-radius: 999px; background: var(--primary-soft); color: var(--primary-ink); font-size: 12px; font-weight: 700; white-space: nowrap; cursor: default; }
</style>
