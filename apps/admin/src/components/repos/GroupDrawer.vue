<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { RepoGroup, RepoGroupInput, Repository } from '../../api/types'
import { useUi } from '../../stores/ui'
import FormDrawer from '../form/FormDrawer.vue'
import InputSelect from '../form/InputSelect.vue'
import HiIcon from '../ui/HiIcon.vue'

// Add or edit a repository group: repositories that change together, in
// order (the first is the primary of the group's tickets), each with a
// role. Saving may come back with warnings about what the repositories
// share uneasily in one run; the drawer then stays open to show them.
const props = defineProps<{ group: RepoGroup | null; repos: Repository[] }>()
const open = defineModel<boolean>({ default: false })
const emit = defineEmits<{ saved: [group: RepoGroup] }>()
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()

type Member = { repoId: number; role: string }
const form = reactive({ name: '', description: '', taskPrefix: '', instructions: '', members: [] as Member[] })
const error = ref('')
// The group as last saved here, while its warnings are shown.
const saved = ref<RepoGroup | null>(null)
const current = computed(() => saved.value ?? props.group)
const warnings = computed(() => current.value?.warnings ?? [])

watch(
  open,
  (v) => {
    if (!v) return
    const g = props.group
    error.value = ''
    saved.value = null
    Object.assign(form, {
      name: g?.name ?? '',
      description: g?.description ?? '',
      taskPrefix: g?.taskPrefix ?? '',
      instructions: g?.instructions ?? '',
      members: (g?.members ?? []).map((m) => ({ repoId: m.repoId, role: m.role })),
    })
  },
  { immediate: true },
)

const repoById = computed(() => new Map(props.repos.map((r) => [r.id, r])))
const nameOf = (id: number) => repoById.value.get(id)?.name ?? props.group?.members.find((m) => m.repoId === id)?.repoName ?? `#${id}`
const archived = (id: number) => !!repoById.value.get(id)?.archivedAt || !!props.group?.members.find((m) => m.repoId === id)?.archived
// Archived repositories stay if already members, but cannot be added.
const addOptions = computed(() =>
  props.repos
    .filter((r) => !r.archivedAt && !form.members.some((m) => m.repoId === r.id))
    .map((r) => ({ value: r.id as number | undefined, label: r.name })),
)
function add(id: number | undefined) {
  if (id && !form.members.some((m) => m.repoId === id)) form.members.push({ repoId: id, role: '' })
}
function move(i: number, d: -1 | 1) {
  const j = i + d
  if (j < 0 || j >= form.members.length) return
  const ms = [...form.members]
  ;[ms[i], ms[j]] = [ms[j], ms[i]]
  form.members = ms
}
function remove(i: number) {
  form.members = form.members.filter((_, j) => j !== i)
}

const save = useMutation({
  mutationFn: () => {
    const body: RepoGroupInput = {
      name: form.name.trim(),
      description: form.description.trim(),
      taskPrefix: form.taskPrefix.trim().toUpperCase(),
      instructions: form.instructions,
      members: form.members.map((m) => ({ repoId: m.repoId, role: m.role.trim() || undefined })),
    }
    const id = current.value?.id
    return id
      ? unwrap(api.PUT('/repo-groups/{id}', { params: { path: { id } }, body }))
      : unwrap(api.POST('/repo-groups', { body }))
  },
  onSuccess: (g) => {
    for (const k of ['repo-groups', 'repos']) void qc.invalidateQueries({ queryKey: [k] })
    ui.notify(t('groups.saved', { name: g.name }))
    emit('saved', g)
    error.value = ''
    if (g.warnings.length) saved.value = g
    else open.value = false
  },
  onError: (e) => {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})

function submit() {
  if (!form.members.length) {
    error.value = t('groups.membersNeeded')
    return
  }
  save.mutate()
}
// Empty: the first repository's prefix, as the server does.
const prefix = computed(() => (form.taskPrefix || repoById.value.get(form.members[0]?.repoId ?? 0)?.taskPrefix || 'VIS').toUpperCase())
</script>

<template>
  <FormDrawer v-model="open" :title="current ? current.name : t('groups.add')" :subtitle="t('groups.drawerSub')">
    <form id="group-form" style="display: contents" @submit.prevent="submit">
      <div v-if="warnings.length" class="help warn" role="status">
        <HiIcon name="info" />
        <div>
          <p><b>{{ t('groups.warningsTitle') }}</b></p>
          <ul class="gr-warn"><li v-for="(w, i) in warnings" :key="i">{{ w }}</li></ul>
        </div>
      </div>
      <div class="field">
        <label for="g-name">{{ t('groups.name') }}</label>
        <input id="g-name" v-model="form.name" type="text" required maxlength="100" :placeholder="t('groups.namePh')">
      </div>
      <div class="field">
        <label for="g-desc">{{ t('groups.description') }}</label>
        <input id="g-desc" v-model="form.description" type="text" maxlength="500">
      </div>
      <div class="field">
        <span class="flbl">{{ t('groups.members') }}</span>
        <span class="fhelp">{{ t('groups.membersHelp') }}</span>
        <ol v-if="form.members.length" class="gr-members">
          <li v-for="(m, i) in form.members" :key="m.repoId" class="gr-member">
            <span class="gr-name">
              <b>{{ nameOf(m.repoId) }}</b>
              <span v-if="i === 0" class="badge b-info">{{ t('groups.primary') }}</span>
              <span v-if="archived(m.repoId)" class="badge b-gray">{{ t('groups.archived') }}</span>
            </span>
            <input v-model="m.role" class="cfg-in gr-role" type="text" maxlength="40" :placeholder="t('groups.rolePh')" :aria-label="t('groups.roleOf', { name: nameOf(m.repoId) })">
            <span class="gr-acts">
              <button type="button" class="btn btn-s" :disabled="i === 0" :aria-label="t('groups.moveUp', { name: nameOf(m.repoId) })" @click="move(i, -1)">↑</button>
              <button type="button" class="btn btn-s" :disabled="i === form.members.length - 1" :aria-label="t('groups.moveDown', { name: nameOf(m.repoId) })" @click="move(i, 1)">↓</button>
              <button type="button" class="btn btn-s" :aria-label="t('form.remove', { name: nameOf(m.repoId) })" @click="remove(i)"><HiIcon name="close" /></button>
            </span>
          </li>
        </ol>
        <p v-else class="hint">{{ t('groups.noMembers') }}</p>
        <InputSelect
          :model-value="undefined"
          :options="addOptions"
          :label="t('groups.addMember')"
          :placeholder="addOptions.length ? t('groups.addMember') : t('groups.noMoreRepos')"
          :disabled="!addOptions.length"
          @update:model-value="add"
        />
      </div>
      <div class="field">
        <label for="g-prefix">{{ t('repos.taskPrefix') }}</label>
        <input id="g-prefix" v-model="form.taskPrefix" type="text" maxlength="8" placeholder="SHOP" style="font-family: var(--mono); font-size: 14px">
        <span class="fhelp">{{ t('groups.prefixHelp', { prefix }) }}</span>
      </div>
      <div class="field">
        <label for="g-instr">{{ t('groups.instructions') }}</label>
        <textarea id="g-instr" v-model="form.instructions" maxlength="20000" :placeholder="t('groups.instructionsPh')" />
        <span class="fhelp">{{ t('groups.instructionsHelp') }}</span>
      </div>
      <span v-if="error" class="ferr" role="alert">{{ error }}</span>
    </form>
    <template #footer>
      <button type="button" class="btn" @click="open = false">{{ saved ? t('form.close') : t('form.cancel') }}</button>
      <button type="submit" form="group-form" class="btn btn-p" :disabled="save.isPending.value">
        {{ current ? t('form.save') : t('groups.add') }}
      </button>
    </template>
  </FormDrawer>
</template>

<style scoped>
.gr-members { list-style: none; margin: 4px 0 8px; padding: 0; display: grid; gap: 8px; }
.gr-member { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 140px) auto; gap: 8px; align-items: center; border: 1px solid var(--line); border-radius: 10px; padding: 8px 10px; }
.gr-name { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; min-width: 0; overflow-wrap: anywhere; }
.gr-role { width: 100%; }
.gr-acts { display: inline-flex; gap: 4px; }
.gr-acts :deep(svg) { width: 12px; height: 12px; stroke: currentColor; fill: none; stroke-width: 2.4; }
.gr-warn { margin: 4px 0 0; padding-left: 18px; }
@media (max-width: 560px) {
  .gr-member { grid-template-columns: 1fr; }
}
</style>
