<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { stillFailing } from '../ci/ci'
import CiStatusBadge from '../ci/CiStatusBadge.vue'

// The CI failure a CI ticket fixes: the job, the branch, how often it
// failed and whether the branch is green again. Hidden when the ticket
// has none (404).
const props = defineProps<{ ticketKey: string }>()
const { t } = useI18n()

const failure = useQuery({
  queryKey: computed(() => ['ci', 'ticket', props.ticketKey]),
  queryFn: () => unwrap(api.GET('/tickets/{key}/ci', { params: { path: { key: props.ticketKey } } })),
  retry: (n, e) => !(e instanceof HttpError && e.status === 404) && n < 2,
})
const f = computed(() => failure.data.value)
// The newest failing run.
const lastRun = computed(() => [...(f.value?.occurrences ?? [])].sort((a, b) => b.at.localeCompare(a.at))[0])
const verdict = computed(() => {
  if (!f.value) return null
  if (f.value.status === 'resolved') return { tone: 'ok', text: t('ci.greenAgain') }
  if (f.value.status === 'fixed') return { tone: 'info', text: t('ci.waitingGreen') }
  if (stillFailing(f.value)) return { tone: 'bad', text: t('ci.stillFailing') }
  return null
})
</script>

<template>
  <section v-if="f" class="card ci-card">
    <div class="ch">
      <div><h2>{{ t('ci.cardTitle') }}</h2><p class="sub ci-card-title">{{ f.title }}</p></div>
      <CiStatusBadge :status="f.status" />
    </div>
    <dl class="kv">
      <dt>{{ t('ci.colJob') }}</dt><dd>{{ f.workflow ? `${f.workflow} / ${f.job}` : f.job }}</dd>
      <dt>{{ t('ci.branch') }}</dt><dd><span class="br">{{ f.branch }}</span></dd>
      <dt>{{ t('ci.failingRuns') }}</dt><dd>{{ t('ci.times', { n: f.count }) }}</dd>
      <template v-if="lastRun">
        <dt>{{ t('ci.lastRun') }}</dt>
        <dd><a :href="lastRun.url" target="_blank" rel="noopener">{{ t('ci.openRun') }}</a> <span class="sha">{{ lastRun.sha.slice(0, 7) }}</span></dd>
      </template>
    </dl>
    <div class="ci-card-f">
      <span v-if="verdict" class="badge" :class="`b-${verdict.tone}`">{{ verdict.text }}</span>
      <RouterLink class="btn btn-s" :to="{ name: 'ciFailure', params: { id: f.id } }">{{ t('ci.openFailure') }}</RouterLink>
    </div>
  </section>
</template>

<style scoped>
.ci-card-title { font-family: var(--mono); font-size: 13px; overflow-wrap: anywhere; }
.ci-card-f { display: flex; align-items: center; justify-content: space-between; gap: 10px; flex-wrap: wrap; margin-top: 12px; }
</style>
