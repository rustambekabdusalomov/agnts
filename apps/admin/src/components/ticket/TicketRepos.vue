<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Ticket } from '../../api/types'
import { REPO_STATE_TONE } from '../repos/repoSet'

// A ticket's repositories, primary first: each with its role, branch, pull
// request, state and CI fixes. A failed push names its error; a retry
// pushes only the repositories still missing.
const props = defineProps<{ ticket: Ticket; canRetry?: boolean; busy?: boolean }>()
const emit = defineEmits<{ retry: [] }>()
const { t } = useI18n()

const repos = computed(() => props.ticket.repos ?? [])
const failed = computed(() => repos.value.filter((r) => r.pushError))
</script>

<template>
  <section v-if="repos.length" class="card tr-card">
    <div class="ch">
      <div>
        <h2>{{ t('groups.ticketRepos', { count: repos.length }) }}</h2>
        <p v-if="ticket.group" class="sub">{{ t('groups.fromGroup', { name: ticket.group.name }) }}</p>
      </div>
      <span v-if="ticket.partlyMerged" class="badge b-warn">{{ t('groups.partlyMerged') }}</span>
    </div>
    <ul class="tr-list">
      <li v-for="(r, i) in repos" :key="r.repoId" class="tr-item">
        <div class="tr-top">
          <RouterLink class="tr-name" :to="{ name: 'repo', params: { id: r.repoId } }">{{ r.repoName }}</RouterLink>
          <span v-if="r.role" class="hint">{{ r.role }}</span>
          <span v-if="i === 0" class="badge b-info">{{ t('groups.primary') }}</span>
          <span v-if="r.archived" class="badge b-gray">{{ t('groups.archived') }}</span>
          <span class="badge tr-state" :class="`b-${REPO_STATE_TONE[r.state]}`">{{ t(`groups.state_${r.state}`) }}</span>
        </div>
        <div class="tr-meta">
          <span v-if="r.branch" class="mono">{{ r.branch }}</span>
          <a v-if="r.prUrl" :href="r.prUrl" target="_blank" rel="noopener">{{ t('groups.pr', { number: r.prNumber ?? '' }) }}</a>
          <span v-if="r.files">{{ t('groups.files', { count: r.files }) }}</span>
          <span v-if="r.ciFixes" class="badge b-warn">{{ t('ticket.ciFixes', { n: r.ciFixes }) }}</span>
        </div>
        <p v-if="r.pushError" class="ferr tr-err">{{ t('groups.pushError', { error: r.pushError }) }}</p>
      </li>
    </ul>
    <div v-if="failed.length && canRetry" class="actions" style="margin-top: 10px">
      <button class="btn btn-s btn-p" type="button" :disabled="busy" @click="emit('retry')">{{ t('ticket.retry') }}</button>
      <span class="hint">{{ t('groups.retryHint', { count: failed.length }) }}</span>
    </div>
  </section>
</template>

<style scoped>
.tr-list { list-style: none; margin: 0; padding: 0; display: grid; gap: 10px; }
.tr-item { border-top: 1px solid var(--line); padding-top: 10px; }
.tr-item:first-child { border-top: 0; padding-top: 0; }
.tr-top { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
.tr-name { font-weight: 700; overflow-wrap: anywhere; }
.tr-state { margin-left: auto; }
.tr-meta { display: flex; flex-wrap: wrap; gap: 4px 12px; margin-top: 4px; font-size: 13.5px; color: var(--ink-3); }
.tr-meta .mono { font-family: var(--mono); overflow-wrap: anywhere; }
.tr-err { margin: 6px 0 0; font-size: 13.5px; white-space: pre-wrap; }
</style>
