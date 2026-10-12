<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { TicketEvent } from '../../api/types'
import { eventKind, KIND_CLASS, KIND_LABEL } from './eventKind'

const props = defineProps<{ event: TicketEvent }>()
const { t } = useI18n()
const kind = computed(() => eventKind(props.event))
const cls = computed(() => (kind.value === 'limit' && props.event.level === 'warn' ? 'b-warn' : KIND_CLASS[kind.value]))
</script>

<template>
  <span class="badge" :class="cls">{{ t(KIND_LABEL[kind]) }}</span>
</template>
