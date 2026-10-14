<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Ticket } from '../../api/types'
import { askConfirm } from '../../composables/useConfirm'
import RepoSetPicker from '../repos/RepoSetPicker.vue'
import { ticketRepos, ticketSelection, type RepoSelection } from '../repos/repoSet'
import { useRepoGroups } from '../repos/useGroups'
import { useUi } from '../../stores/ui'

// Which repositories a ticket runs in: a group, or one or more
// repositories (the first is the primary). The server allows a change
// while nothing runs and nothing was pushed; a stopped ticket then starts
// over from analysis, so that case asks first.
const props = defineProps<{ ticket: Ticket }>()
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()

const repos = useQuery({ queryKey: ['repos'], queryFn: () => unwrap(api.GET('/repos')) })
const groups = useRepoGroups()
const current = computed(() => ticketSelection(props.ticket))
const same = (a: RepoSelection, b: RepoSelection) => a.groupId === b.groupId && a.repoIds.join() === b.repoIds.join()
const sel = ref<RepoSelection>(current.value)
// The ticket refetches while open: only a real change replaces the choice.
watch(current, (c, old) => {
  if (!same(c, old)) sel.value = c
})
const dirty = computed(() => sel.value.repoIds.length > 0 && !same(sel.value, current.value))
const restarts = computed(() => !!props.ticket.repoId && props.ticket.state !== 'new' && props.ticket.resumeState !== 'new')
const nameOf = (id: number) => repos.data.value?.find((r) => r.id === id)?.name ?? `#${id}`
const names = (s: RepoSelection) => s.repoIds.map(nameOf).join(', ')

const save = useMutation({
  mutationFn: (s: RepoSelection) =>
    unwrap(
      api.PUT('/tickets/{key}/repos', {
        params: { path: { key: props.ticket.key } },
        body: s.groupId ? { groupId: s.groupId } : { repoIds: s.repoIds },
      }),
    ),
  onSuccess: (r) => {
    void qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] })
    void qc.invalidateQueries({ queryKey: ['tickets'] })
    ui.notify(t('ticket.repoChanged', { repo: ticketRepos(r).map((x) => x.repoName).join(', ') }))
  },
  onError: (e) => {
    sel.value = current.value
    ui.notify(e instanceof HttpError ? e.message : t('common.error'))
  },
})

async function apply() {
  const s = sel.value
  if (!dirty.value) return
  if (restarts.value) {
    const ok = await askConfirm({
      title: t('ticket.repoRestartTitle'),
      message: t('ticket.repoRestart', { repo: names(current.value), next: names(s) }),
      confirmLabel: t('ticket.repoChange'),
    })
    if (!ok) return
  }
  save.mutate(s)
}
</script>

<template>
  <div class="sec">
    <h3>{{ t('ticket.repoTitle') }}</h3>
    <p class="hint" style="margin: -4px 0 10px">{{ t('ticket.repoHint') }}</p>
    <div v-if="!ticket.repoId" class="help warn" style="margin-bottom: 10px"><p>{{ t('ticket.repoMissing') }}</p></div>
    <p v-if="repos.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <RepoSetPicker
      v-else
      v-model="sel"
      :repos="repos.data.value ?? []"
      :groups="groups.data.value ?? []"
      :label="t('ticket.repoTitle')"
      :disabled="save.isPending.value"
    />
    <div v-if="dirty" class="actions" style="margin-top: 10px">
      <button class="btn btn-p btn-s" type="button" :disabled="save.isPending.value" @click="apply">{{ t('ticket.repoChange') }}</button>
      <button class="btn btn-s" type="button" :disabled="save.isPending.value" @click="sel = current">{{ t('form.cancel') }}</button>
    </div>
  </div>
</template>
