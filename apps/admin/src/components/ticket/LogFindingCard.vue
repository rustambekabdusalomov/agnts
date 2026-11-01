<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { ago } from '../../composables/format'
import LogStatusBadge from '../logwatch/LogStatusBadge.vue'

// The log finding a log ticket fixes: the service, how often it was seen,
// and whether it is still in the logs. Hidden when there is none (404).
const props = defineProps<{ ticketKey: string }>()
const { t, locale } = useI18n()

const finding = useQuery({
  queryKey: computed(() => ['logwatch', 'ticket', props.ticketKey]),
  queryFn: () => unwrap(api.GET('/tickets/{key}/log-finding', { params: { path: { key: props.ticketKey } } })),
  retry: (n, e) => !(e instanceof HttpError && e.status === 404) && n < 2,
})
const f = computed(() => finding.data.value)
const verdict = computed(() => {
  if (!f.value) return null
  if (f.value.status === 'resolved') return { tone: 'ok', text: t('logwatch.goneNow') }
  if (f.value.status === 'fixed') return { tone: 'info', text: t('logwatch.waitingQuiet') }
  if (f.value.status === 'regression') return { tone: 'bad', text: t('logwatch.backAgain') }
  return null
})
</script>

<template>
  <section v-if="f" class="card">
    <div class="ch">
      <div><h2>{{ t('logwatch.cardTitle') }}</h2><p class="sub lw-card-title">{{ f.title }}</p></div>
      <LogStatusBadge :status="f.status" />
    </div>
    <dl class="kv">
      <dt>{{ t('logwatch.colService') }}</dt><dd>{{ f.service }}</dd>
      <dt>{{ t('logwatch.count') }}</dt><dd>{{ t('logwatch.times', { n: f.count }) }}</dd>
      <dt>{{ t('logwatch.lastSeen') }}</dt><dd>{{ ago(f.lastSeenAt, locale) }}</dd>
    </dl>
    <div class="lw-card-f">
      <span v-if="verdict" class="badge" :class="`b-${verdict.tone}`">{{ verdict.text }}</span>
      <RouterLink class="btn btn-s" :to="{ name: 'logFinding', params: { id: f.id } }">{{ t('logwatch.openFinding') }}</RouterLink>
    </div>
  </section>
</template>

<style scoped>
.lw-card-title { font-family: var(--mono); font-size: 13px; overflow-wrap: anywhere; }
.lw-card-f { display: flex; align-items: center; justify-content: space-between; gap: 10px; flex-wrap: wrap; margin-top: 12px; }
</style>
