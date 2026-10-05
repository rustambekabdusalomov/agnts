<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import type { TicketEvent } from '../../api/types'
import { fmtTime } from '../../composables/format'

// The demo's terminal-style log of what Claude is doing right now.
const props = defineProps<{ events: TicketEvent[] }>()
const { t, locale } = useI18n()
const box = ref<HTMLElement | null>(null)
const SHOWN = ['claude_text', 'claude_tool', 'check', 'state_changed', 'pushed', 'pr_opened', 'error']
const lines = computed(() => props.events.filter((e) => SHOWN.includes(e.type)).slice(-60))

watch(
  () => lines.value.length,
  async () => {
    await nextTick()
    if (box.value) box.value.scrollTop = box.value.scrollHeight
  },
  { immediate: true },
)
</script>

<template>
  <div ref="box" class="log" aria-live="polite">
    <div v-for="(l, i) in lines" :key="l.id" :class="{ cur: i === lines.length - 1 }">
      <span class="t">{{ fmtTime(l.createdAt, locale) }}</span>{{ l.message }}
    </div>
    <div v-if="!lines.length" class="cur"><span class="t" />{{ t('ticket.logEmpty') }}</div>
  </div>
</template>
