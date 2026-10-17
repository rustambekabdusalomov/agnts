<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { nextTick, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { useWorkspace } from '../../stores/workspace'

// A ticket's branch, renamable until agnts pushes it (the server's
// canRenameBranch): the pull request then opens from the new name.
const props = defineProps<{ ticketKey: string; branch: string; repoId?: number; canRename?: boolean }>()
const { t } = useI18n()
const qc = useQueryClient()
const workspace = useWorkspace()

const editing = ref(false)
const name = ref('')
const error = ref('')
const input = ref<HTMLInputElement | null>(null)

async function edit() {
  name.value = props.branch
  error.value = ''
  editing.value = true
  await nextTick()
  input.value?.select()
}

const save = useMutation({
  mutationFn: () =>
    unwrap(api.PUT('/tickets/{key}/branch', { params: { path: { key: props.ticketKey } }, body: { branch: name.value.trim(), repoId: props.repoId } })),
  onSuccess: () => {
    editing.value = false
    void qc.invalidateQueries({ queryKey: ['ticket', props.ticketKey] })
  },
  onError: (e) => {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})

function submit() {
  if (!name.value.trim() || name.value.trim() === props.branch) editing.value = false
  else save.mutate()
}
</script>

<template>
  <form v-if="editing" class="bn-edit" @submit.prevent="submit">
    <input
      ref="input" v-model="name" type="text" maxlength="200" spellcheck="false" autocomplete="off" :aria-label="t('ticket.branchRename')"
      :disabled="save.isPending.value" @keydown.esc="editing = false"
    >
    <button class="btn btn-s btn-p" type="submit" :disabled="save.isPending.value || !name.trim()">{{ t('form.save') }}</button>
    <button class="btn btn-s" type="button" :disabled="save.isPending.value" @click="editing = false">{{ t('form.cancel') }}</button>
    <p v-if="error" class="ferr bn-err">{{ error }}</p>
    <p v-else class="hint bn-err">{{ t('ticket.branchRenameHint') }}</p>
  </form>
  <span v-else class="bn">
    <span class="mono">{{ branch }}</span>
    <button v-if="canRename && workspace.canEdit" type="button" class="link-btn" @click="edit">{{ t('ticket.branchRename') }}</button>
  </span>
</template>

<style scoped>
.bn { display: inline-flex; flex-wrap: wrap; align-items: baseline; gap: 4px 8px; }
.bn .mono { font-family: var(--mono); overflow-wrap: anywhere; }
.bn-edit { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; }
.bn-edit input { flex: 1 1 220px; min-width: 0; font-family: var(--mono); font-size: 14px; }
.bn-err { flex-basis: 100%; margin: 0; font-size: 13px; }
</style>
