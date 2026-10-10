<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { pullHost, type Ticket } from '../../api/types'

// The pull request a review ticket reviews: where it goes, who wrote it,
// and its head as of the last sync.
const props = defineProps<{ ticket: Ticket }>()
const { t } = useI18n()
const pr = computed(() => props.ticket.pull)
const short = (sha?: string) => (sha ?? '').slice(0, 7)
// The head moved on the git host since the commit agnts reviewed.
const moved = computed(() => !!pr.value?.headSha && !!props.ticket.headSha && pr.value.headSha !== props.ticket.headSha)
</script>

<template>
  <div v-if="pr" class="sec pr-card">
    <div class="pr-h">
      <a :href="pr.url" target="_blank" rel="noopener" class="pr-n">{{ t('reviews.pr', { number: pr.number }) }}</a>
      <span class="hint">{{ t('reviews.by', { author: pr.author }) }} · {{ t(`reviews.why_${pr.why}`) }}</span>
    </div>
    <p class="pr-refs mono">{{ pr.headRef }} → {{ pr.baseRef }}</p>
    <p v-if="pr.headSha" class="hint pr-sha">{{ t('reviews.reviewed', { sha: short(pr.headSha) }) }}</p>
    <p v-if="moved" class="hint pr-sha warn">{{ t('reviews.newCommits', { sha: short(ticket.headSha) }) }}</p>
    <a class="btn btn-s" :href="pr.url" target="_blank" rel="noopener">{{ t('reviews.openOn', { host: pullHost(pr.url) }) }}</a>
  </div>
</template>

<style scoped>
.pr-h { display: flex; align-items: baseline; gap: 10px; flex-wrap: wrap; }
.pr-n { font-weight: 700; }
.pr-refs { margin: 6px 0 0; font-size: 13px; overflow-wrap: anywhere; }
.pr-sha { margin: 6px 0 10px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.pr-sha.warn { color: var(--warn-ink); }
</style>
