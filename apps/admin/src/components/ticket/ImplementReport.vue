<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import type { Ticket } from '../../api/types'
import CheckBox from '../form/CheckBox.vue'
import RepoSetPicker from '../repos/RepoSetPicker.vue'
import { emptySelection, selectionBody } from '../repos/repoSet'
import { useRepoGroups } from '../repos/useGroups'

// The step after an approved plan or bug investigation: a code task that
// carries it out, linked back to this ticket. Once made, a link to it.
// It works in the report's repositories; a report without any picks one or
// more, or a group.
const props = defineProps<{ ticket: Ticket; childKey?: string }>()
const { t } = useI18n()
const qc = useQueryClient()
const router = useRouter()

const repos = useQuery({ queryKey: ['repos'], queryFn: () => unwrap(api.GET('/repos')), enabled: () => !props.ticket.repoId })
const groups = useRepoGroups(() => !props.ticket.repoId)
const active = computed(() => (repos.data.value ?? []).filter((r) => !r.archivedAt))
const sel = ref(emptySelection())
const queue = ref(false)
const error = ref('')

const make = useMutation({
  mutationFn: () =>
    unwrap(
      api.POST('/tickets/{key}/implement', {
        params: { path: { key: props.ticket.key } },
        body: { ...(props.ticket.repoId ? {} : selectionBody(sel.value)), start: queue.value ? 'queue' : 'code' },
      }),
    ),
  onSuccess: async (child) => {
    for (const k of ['tickets', 'nav']) void qc.invalidateQueries({ queryKey: [k] })
    void qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] })
    await router.push({ name: 'ticket', params: { key: child.key } })
  },
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})
</script>

<template>
  <div class="sec">
    <h3>{{ t('implement.title') }}</h3>
    <p v-if="childKey" class="hint" style="margin: 0">
      {{ t('implement.doneBy') }} <RouterLink :to="{ name: 'ticket', params: { key: childKey } }">{{ childKey }}</RouterLink>
    </p>
    <template v-else>
      <p class="hint" style="margin: -4px 0 10px">{{ ticket.kind === 'bug' ? t('implement.subBug') : t('implement.subPlan') }}</p>
      <div v-if="!ticket.repoId" style="margin-bottom: 10px">
        <span class="flbl">{{ t('implement.pickRepo') }}</span>
        <p v-if="repos.isPending.value" class="hint">{{ t('common.loading') }}</p>
        <RepoSetPicker v-else v-model="sel" :repos="active" :groups="groups.data.value ?? []" :label="t('implement.pickRepo')" />
      </div>
      <CheckBox v-model="queue" style="margin-bottom: 10px">{{ t('implement.queue') }}</CheckBox>
      <p v-if="error" class="ferr" role="alert">{{ error }}</p>
      <div class="actions" style="margin-top: 0">
        <button class="btn btn-p" type="button" :disabled="make.isPending.value || (!ticket.repoId && !sel.repoIds.length)" @click="make.mutate()">
          {{ ticket.kind === 'bug' ? t('implement.fix') : t('implement.implement') }}
        </button>
      </div>
    </template>
  </div>
</template>
