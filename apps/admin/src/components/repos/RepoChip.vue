<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Ticket } from '../../api/types'
import { repoChip } from './repoSet'

// A ticket's repository in lists: "api", or "api +2" for one in three,
// with all names on hover.
const props = defineProps<{ ticket: Pick<Ticket, 'repos' | 'repoId' | 'repoName'>; empty?: string }>()
const { t } = useI18n()
const chip = computed(() => repoChip(props.ticket))
</script>

<template>
  <span v-if="chip" :title="chip.more ? chip.all : undefined">{{ chip.name }}<span v-if="chip.more" class="badge b-gray rc-more">{{ t('groups.more', { count: chip.more }) }}</span></span>
  <span v-else-if="empty">{{ empty }}</span>
</template>

<style scoped>
.rc-more { margin-left: 6px; height: 20px; padding: 0 7px; }
.rc-more::before { display: none; }
</style>
