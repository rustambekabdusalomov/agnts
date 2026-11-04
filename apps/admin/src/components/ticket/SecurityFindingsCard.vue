<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import { SEC_SEVERITY_TONE, SEC_STATUS_TONE, where } from '../security/security'

// The security findings a SEC ticket fixes, and where each stands: fixing,
// verifying after the merge, fixed, or still there. Hidden when none.
const props = defineProps<{ ticketKey: string }>()
const { t } = useI18n()

const findings = useQuery({
  queryKey: computed(() => ['security', 'ticket', props.ticketKey]),
  queryFn: () => unwrap(api.GET('/tickets/{key}/security-findings', { params: { path: { key: props.ticketKey } } })),
})
const rows = computed(() => findings.data.value ?? [])
</script>

<template>
  <section v-if="rows.length" class="card">
    <div class="ch"><div><h2>{{ t('security.cardTitle') }}</h2><p class="sub">{{ t('security.cardSub') }}</p></div></div>
    <ul class="sec-card">
      <li v-for="f in rows" :key="f.id">
        <span class="badge" :class="`b-${SEC_SEVERITY_TONE[f.severity]}`">{{ t(`security.sev_${f.severity}`) }}</span>
        <RouterLink :to="{ name: 'securityFinding', params: { id: f.id } }" class="sec-card-t">{{ f.title }}</RouterLink>
        <span class="mono">{{ where(f) }}</span>
        <span class="badge" :class="`b-${SEC_STATUS_TONE[f.status]}`">{{ t(`security.status_${f.status}`) }}</span>
      </li>
    </ul>
  </section>
</template>

<style scoped>
.sec-card { list-style: none; margin: 0; padding: 0; display: grid; gap: 8px; }
.sec-card li { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.sec-card-t { overflow-wrap: anywhere; }
.mono { font-family: var(--mono); font-size: 12.5px; color: var(--muted, #667); overflow-wrap: anywhere; }
</style>
