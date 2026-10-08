<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import PageHeader from '../../components/PageHeader.vue'
import { useAgo, useFeedback } from '../../composables/usePlatform'
import { useUi } from '../../stores/ui'

// What people sent from their accounts: newest first, new ones until an
// Admin marks them done.
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const ago = useAgo()
const feedback = useFeedback()

const FILTERS = ['new', 'done', 'all'] as const
type Filter = (typeof FILTERS)[number]
const filter = ref<Filter>('new')
const q = ref('')
const all = computed(() => feedback.data.value ?? [])
const count = (f: Filter) => all.value.filter((x) => f === 'all' || x.status === f).length
const list = computed(() => {
  const s = q.value.trim().toLowerCase()
  return all.value
    .filter((x) => filter.value === 'all' || x.status === filter.value)
    .filter((x) => !s || [x.title, x.description, x.sender, x.email ?? '', x.workspace ?? ''].some((v) => v.toLowerCase().includes(s)))
})

const setStatus = useMutation({
  mutationFn: (v: { id: number; status: 'new' | 'done' }) =>
    unwrap(api.PUT('/platform/feedback/{id}', { params: { path: { id: v.id } }, body: { status: v.status } })),
  onSuccess: (f) => {
    ui.notify(f.status === 'done' ? t('feedback.markedDone') : t('feedback.reopened'))
    void qc.invalidateQueries({ queryKey: ['platform', 'feedback'] })
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
</script>

<template>
  <PageHeader :title="t('feedback.adminTitle')">
    <template #below><p class="sub" style="margin: 2px 0 0">{{ t('feedback.adminLede') }}</p></template>
  </PageHeader>

  <section class="card">
    <div class="filters">
      <div class="seg" role="group" :aria-label="t('feedback.adminTitle')">
        <button v-for="f in FILTERS" :key="f" class="seg-b" :aria-pressed="filter === f" @click="filter = f">{{ t(`feedback.f_${f}`) }} <span class="muted">{{ count(f) }}</span></button>
      </div>
      <label class="mini-search">
        <svg viewBox="0 0 24 24" width="16" height="16" aria-hidden="true" style="fill: none; stroke: currentColor; stroke-width: 2"><circle cx="11" cy="11" r="7" /><path d="M20 20l-3.5-3.5" /></svg>
        <input v-model="q" type="search" :placeholder="t('feedback.search')" :aria-label="t('feedback.search')">
      </label>
    </div>
    <p v-if="feedback.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="feedback.isError.value" class="ferr">{{ t('common.error') }}</p>
    <p v-else-if="!list.length" class="empty">{{ filter === 'new' ? t('feedback.noneNew') : t('feedback.none') }}</p>
    <ul v-else class="fb-list">
      <li v-for="f in list" :key="f.id" class="fb-item" :class="{ done: f.status === 'done' }">
        <div class="fb-head">
          <h3>{{ f.title }}</h3>
          <span class="badge" :class="f.status === 'new' ? 'b-warn' : 'b-ok'">{{ t(`feedback.s_${f.status}`) }}</span>
        </div>
        <p class="fb-text">{{ f.description }}</p>
        <div class="fb-meta">
          <span><b>{{ f.sender }}</b><template v-if="f.email"> · {{ f.email }}</template><template v-if="!f.userId"> · {{ t('feedback.accountGone') }}</template></span>
          <span v-if="f.workspace">{{ t('feedback.from', { workspace: f.workspace }) }}</span>
          <span :title="new Date(f.createdAt).toLocaleString()">{{ ago(f.createdAt) }}</span>
          <button
            class="btn btn-s fb-act"
            :disabled="setStatus.isPending.value"
            @click="setStatus.mutate({ id: f.id, status: f.status === 'new' ? 'done' : 'new' })"
          >
            {{ f.status === 'new' ? t('feedback.markDone') : t('feedback.reopen') }}
          </button>
        </div>
      </li>
    </ul>
  </section>
</template>
