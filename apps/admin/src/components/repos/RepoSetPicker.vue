<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { RepoGroup, Repository } from '../../api/types'
import CheckBox from '../form/CheckBox.vue'
import HiIcon from '../ui/HiIcon.vue'
import { emptySelection, makePrimary, pickGroup, toggleRepo, type RepoSelection } from './repoSet'

// Where a ticket works: groups at the top, repositories below with
// checkboxes. A picked group shows its members as removable chips; editing
// them turns the choice into a plain list of repositories. The first one
// is the primary repository.
const props = defineProps<{
  repos: Repository[]
  groups: RepoGroup[]
  label: string
  /** Offers "no repository" with this label. */
  noneLabel?: string
  noneDisabled?: boolean
  noneTitle?: string
  disabled?: boolean
}>()
const model = defineModel<RepoSelection>({ required: true })
const { t } = useI18n()

const ids = computed(() => model.value.repoIds)
const group = computed(() => props.groups.find((g) => g.id === model.value.groupId) ?? null)
// Archived repositories show only while already chosen (a ticket's current one).
const shown = computed(() => props.repos.filter((r) => !r.archivedAt || ids.value.includes(r.id)))
const nameOf = (id: number) => props.repos.find((r) => r.id === id)?.name ?? group.value?.members.find((m) => m.repoId === id)?.repoName ?? `#${id}`
const roleOf = (id: number) => group.value?.members.find((m) => m.repoId === id)?.role ?? ''
const showChips = computed(() => !!group.value || ids.value.length > 1)

const set = (s: RepoSelection) => (model.value = s)
</script>

<template>
  <div class="rsp">
    <div v-if="noneLabel || groups.length || $slots.extra" class="tabs" role="group" :aria-label="t('groups.pickerGroups')">
      <button
        v-if="noneLabel"
        type="button"
        class="tab"
        :aria-pressed="!ids.length"
        :disabled="disabled || noneDisabled"
        :title="noneTitle"
        @click="set(emptySelection())"
      >
        {{ noneLabel }}
      </button>
      <button
        v-for="g in groups"
        :key="g.id"
        type="button"
        class="tab rsp-group"
        :aria-pressed="model.groupId === g.id"
        :disabled="disabled"
        :title="g.description || undefined"
        @click="set(pickGroup(g))"
      >
        {{ g.name }} <span class="rsp-n">{{ g.members.filter((m) => !m.archived).length }}</span>
      </button>
      <slot name="extra" />
    </div>
    <div class="rsp-repos" role="group" :aria-label="label">
      <CheckBox
        v-for="r in shown"
        :key="r.id"
        :model-value="ids.includes(r.id)"
        :disabled="disabled"
        @update:model-value="(on: boolean) => set(toggleRepo(model, r.id, on))"
      >
        {{ r.name }}
      </CheckBox>
    </div>
    <div v-if="showChips" class="rsp-chips" role="group" :aria-label="t('groups.chosen')">
      <span v-if="group" class="hint">{{ t('groups.fromGroup', { name: group.name }) }}</span>
      <span v-for="(id, i) in ids" :key="id" class="chip">
        <button v-if="i > 0" type="button" class="rsp-prim" :disabled="disabled" :title="t('groups.makePrimary')" @click="set(makePrimary(model, id))">{{ nameOf(id) }}</button>
        <span v-else>{{ nameOf(id) }}</span>
        <span v-if="roleOf(id)" class="rsp-role">{{ roleOf(id) }}</span>
        <span v-if="i === 0" class="rsp-role">{{ t('groups.primary') }}</span>
        <button type="button" :disabled="disabled" :aria-label="t('form.remove', { name: nameOf(id) })" @click="set(toggleRepo(model, id, false))"><HiIcon name="close" /></button>
      </span>
    </div>
  </div>
</template>

<style scoped>
.rsp { display: grid; gap: 10px; }
.rsp-n { margin-left: 4px; font-size: 12.5px; opacity: 0.7; font-variant-numeric: tabular-nums; }
.rsp-repos { display: flex; flex-wrap: wrap; gap: 8px 16px; }
.rsp-chips { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
.rsp-role { font-family: var(--sans, inherit); font-size: 12px; color: var(--ink-3); }
.chip .rsp-prim { width: auto; height: auto; padding: 0; border-radius: 0; font: inherit; color: inherit; background: none; }
.chip .rsp-prim:hover { background: none; color: var(--primary-ink); text-decoration: underline; }
</style>
