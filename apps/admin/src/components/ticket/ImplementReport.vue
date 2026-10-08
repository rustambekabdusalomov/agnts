<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import type { Ticket } from '../../api/types'
import CheckBox from '../form/CheckBox.vue'
import InputSelect from '../form/InputSelect.vue'

// The step after an approved plan or bug investigation: a code task that
// carries it out, linked back to this ticket. Once made, a link to it.
const props = defineProps<{ ticket: Ticket; childKey?: string }>()
const { t } = useI18n()
const qc = useQueryClient()
const router = useRouter()

const repos = useQuery({ queryKey: ['repos'], queryFn: () => unwrap(api.GET('/repos')), enabled: () => !props.ticket.repoId })
const items = computed(() => (repos.data.value ?? []).filter((r) => !r.archivedAt).map((r) => ({ value: r.id as number | undefined, label: r.name })))
const repoId = ref<number | undefined>()
const queue = ref(false)
const error = ref('')

const make = useMutation({
  mutationFn: () =>
    unwrap(
      api.POST('/tickets/{key}/implement', {
        params: { path: { key: props.ticket.key } },
        body: { repoId: props.ticket.repoId ? undefined : repoId.value, start: queue.value ? 'queue' : 'code' },
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
        <InputSelect v-model="repoId" :options="items" :label="t('ticket.repoTitle')" :placeholder="t('implement.pickRepo')" :disabled="repos.isPending.value" />
      </div>
      <CheckBox v-model="queue" style="margin-bottom: 10px">{{ t('implement.queue') }}</CheckBox>
      <p v-if="error" class="ferr" role="alert">{{ error }}</p>
      <div class="actions" style="margin-top: 0">
        <button class="btn btn-p" type="button" :disabled="make.isPending.value || (!ticket.repoId && !repoId)" @click="make.mutate()">
          {{ ticket.kind === 'bug' ? t('implement.fix') : t('implement.implement') }}
        </button>
      </div>
    </template>
  </div>
</template>
