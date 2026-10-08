<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { ago } from '../../composables/format'
import { livePoll } from '../../composables/useLive'
import { useUi } from '../../stores/ui'
import { useWorkspace } from '../../stores/workspace'

// Done tickets and where their learn run stands: running, queued (in run
// order), failed or never learned, with buttons to queue them.
const { t, locale } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const workspace = useWorkspace()
const queue = useQuery({
  queryKey: ['lessons', 'queue'],
  queryFn: () => unwrap(api.GET('/lessons/queue')),
  // Poll while something is queued: a run starting writes no event of its own.
  refetchInterval: (q) => (q.state.data?.some((x) => x.status === 'running' || x.status === 'pending') ? 5_000 : livePoll(60_000)),
})
const items = computed(() => queue.data.value ?? [])
const idle = computed(() => items.value.filter((x) => x.status === 'none'))
const position = (key: string) => items.value.filter((x) => x.status === 'pending').findIndex((x) => x.key === key) + 1
const TONE = { running: 'b-info', pending: 'b-warn', failed: 'b-bad', none: 'b-gray' } as const

const learn = useMutation({
  mutationFn: async (keys: string[]) => {
    for (const key of keys) await unwrap(api.POST('/tickets/{key}/learn', { params: { path: { key } } }))
    return keys.length
  },
  onSuccess: (n) => ui.notify(n === 1 ? t('learn.queued') : t('learn.queuedAll', { n })),
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
  onSettled: () => qc.invalidateQueries({ queryKey: ['lessons', 'queue'] }),
})
</script>

<template>
  <section class="card">
    <div class="ch">
      <div><h2>{{ t('learn.queueTitle') }}</h2><p class="sub">{{ t('learn.queueSub') }}</p></div>
      <button v-if="idle.length > 1 && workspace.canEdit" type="button" class="btn btn-s" :disabled="learn.isPending.value" @click="learn.mutate(idle.map((x) => x.key))">
        {{ t('learn.queueAll', { n: idle.length }) }}
      </button>
    </div>
    <p v-if="queue.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="queue.isError.value" class="ferr">{{ t('common.error') }}</p>
    <p v-else-if="!items.length" class="empty">{{ t('learn.queueEmpty') }}</p>
    <div v-else class="tw">
      <table class="tbl">
        <tbody>
          <tr v-for="x in items" :key="x.key">
            <td>
              <RouterLink class="ttitle" :to="{ name: 'ticket', params: { key: x.key } }">{{ x.title }}</RouterLink>
              <div class="tkey">{{ x.key }} · {{ x.repoName }}</div>
            </td>
            <td>
              <span class="badge" :class="TONE[x.status]">{{ t(`learn.status_${x.status}`) }}</span>
              <span v-if="x.status === 'pending'" class="tkey" style="margin-left: 8px">{{ t('learn.queuePosition', { n: position(x.key) }) }}</span>
            </td>
            <td class="tkey">{{ ago(x.updatedAt, locale) }}</td>
            <td style="text-align: right">
              <button
                v-if="workspace.canEdit && (x.status === 'none' || x.status === 'failed')"
                type="button"
                class="btn btn-s"
                :disabled="learn.isPending.value"
                @click="learn.mutate([x.key])"
              >
                {{ x.status === 'failed' ? t('learn.retryBtn') : t('learn.queueBtn') }}
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>
