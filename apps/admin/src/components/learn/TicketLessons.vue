<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Ticket } from '../../api/types'
import { useUi } from '../../stores/ui'
import { useLessons } from './useLessons'

// What a pushed ticket taught: its lessons, or where its learn run stands.
const props = defineProps<{ ticket: Ticket }>()
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const lessons = useLessons(computed(() => ({ ticket: props.ticket.key, status: 'all' as const })))
const items = computed(() => lessons.data.value?.items ?? [])
const state = computed(() => props.ticket.learnState ?? 'none')

const learn = useMutation({
  mutationFn: () => unwrap(api.POST('/tickets/{key}/learn', { params: { path: { key: props.ticket.key } } })),
  onSuccess: () => {
    void qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] })
    ui.notify(t('learn.queued'))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
</script>

<template>
  <section class="card">
    <div class="ch"><div><h2>{{ t('learn.ticketTitle') }}</h2><p class="sub">{{ t('learn.ticketSub') }}</p></div></div>
    <ul v-if="items.length" class="lesson-list">
      <li v-for="l in items" :key="l.id">
        <RouterLink class="lesson-row" :to="`/learn/${l.id}`">
          <div class="lesson-row-top">
            <span class="ttitle">{{ l.title }}</span>
            <span class="src">{{ t(`learn.category_${l.category}`) }}</span>
            <span class="tkey">{{ t('learn.readTime', { n: l.readMinutes }) }}</span>
          </div>
          <p class="lesson-sum">{{ l.summary }}</p>
        </RouterLink>
      </li>
    </ul>
    <p v-else-if="state === 'pending'" class="hint">{{ t('learn.ticketPending') }}</p>
    <p v-else-if="state === 'done'" class="hint">{{ t('learn.ticketNone') }}</p>
    <p v-else-if="state === 'failed'" class="ferr">{{ t('learn.ticketFailed') }}</p>
    <p v-else class="hint">{{ t('learn.ticketIdle') }}</p>
    <div v-if="state !== 'pending'" class="actions">
      <button type="button" class="btn btn-s" :disabled="learn.isPending.value" @click="learn.mutate()">
        {{ state === 'none' ? t('learn.learnNow') : t('learn.learnAgain') }}
      </button>
    </div>
  </section>
</template>
