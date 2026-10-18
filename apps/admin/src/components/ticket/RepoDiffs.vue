<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { FileChange } from '../../api/types'
import DiffView from '../DiffView.vue'
import { filePath, filesByRepo } from '../repos/repoSet'

// A change's diffs. In a ticket of several repositories each gets a tab,
// with its file count and lines added and removed, and only the picked
// one's files show; the first until another is picked. repo is the
// picked repository's name ('' for the first), so the page can switch to
// the one a file it opens is in.
const props = defineProps<{ files: FileChange[]; openFirst?: boolean }>()
const repo = defineModel<string>('repo', { default: '' })
const { t } = useI18n()

const groups = computed(() =>
  filesByRepo(props.files).map((g) => ({ ...g, add: g.files.reduce((a, f) => a + f.add, 0), del: g.files.reduce((a, f) => a + f.del, 0) })),
)
const shown = computed(() => groups.value.find((g) => g.repo === repo.value) ?? groups.value[0])
</script>

<template>
  <div v-if="groups.length > 1" class="tabs rd-tabs" role="group" :aria-label="t('ticket.diffReposLabel')">
    <button v-for="g in groups" :key="g.repo" type="button" class="tab" :aria-pressed="shown?.repo === g.repo" @click="repo = g.repo">
      {{ g.repo || t('ticket.diffOtherRepo') }}<span class="rd-n">{{ g.files.length }}</span>
      <span class="rd-delta"><span class="add">+{{ g.add }}</span> <span class="del">−{{ g.del }}</span></span>
    </button>
  </div>
  <template v-if="shown">
    <DiffView v-for="(f, i) in shown.files" :id="`diff-${filePath(f)}`" :key="filePath(f)" :file="f" :open="openFirst && shown === groups[0] && i === 0" />
  </template>
</template>

<style scoped>
.rd-tabs { margin: 0 0 12px; }
.rd-n { margin-left: 6px; font-size: 12.5px; opacity: 0.7; font-variant-numeric: tabular-nums; }
.rd-delta { margin-left: 8px; font: 12px var(--mono); }
.rd-delta .add { color: var(--ok); }
.rd-delta .del { color: var(--bad); }
.tab[aria-pressed="true"] .rd-delta span { color: inherit; opacity: 0.8; }
</style>
