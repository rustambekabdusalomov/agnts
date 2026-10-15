<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { FileChange, Finding } from '../../api/types'
import { useUi } from '../../stores/ui'
import { numberDiff } from '../diffLines'
import CheckBox from '../form/CheckBox.vue'
import ConfirmDialog from '../ui/ConfirmDialog.vue'

// Posting agnts's review on the pull request: the summary, and the chosen
// findings as comments on their lines, in one review. A finding whose line
// is not in the diff can only be in the summary.
const props = defineProps<{ ticketKey: string; number: number; host: string; findings: Finding[]; files: FileChange[] }>()
const open = defineModel<boolean>({ default: false })
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()

// The lines of the new version a comment can go on, per file.
const lines = computed(() => {
  const m = new Map<string, Set<number>>()
  for (const f of props.files) {
    const s = new Set<number>()
    for (const l of numberDiff(f.diff ?? '')) if ((l.kind === 'add' || l.kind === '') && l.new !== undefined) s.add(l.new)
    m.set(f.path, s)
  }
  return m
})
const onLine = (f: Finding) => !!f.file && !!f.line && !!lines.value.get(f.file)?.has(f.line)
const summary = ref(true)
const changes = ref(false)
const chosen = ref<boolean[]>([])
watch(open, (v) => {
  if (v) {
    summary.value = true
    changes.value = false
    chosen.value = props.findings.map(onLine)
  }
})
const inline = computed(() => chosen.value.filter((c, i) => c && onLine(props.findings[i])).length)

const post = useMutation({
  mutationFn: () =>
    unwrap(
      api.POST('/tickets/{key}/post-review', {
        params: { path: { key: props.ticketKey } },
        body: {
          summary: summary.value,
          findings: props.findings.map((_, i) => i).filter((i) => chosen.value[i] && onLine(props.findings[i])),
          requestChanges: changes.value,
        },
      }),
    ),
  onSuccess: () => {
    open.value = false
    ui.notify(t('reviews.postedToast', { host: props.host }))
    void qc.invalidateQueries({ queryKey: ['ticket', props.ticketKey] })
    void qc.invalidateQueries({ queryKey: ['pull'] })
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
</script>

<template>
  <ConfirmDialog
    v-model="open"
    :title="t('pulls.postTitle', { number, host })"
    :message="t('pulls.postSub', { host })"
    :confirm-label="t('pulls.postBtn', { n: inline })"
    :busy="post.isPending.value"
    :disabled="!summary && !inline"
    @confirm="post.mutate()"
  >
    <div class="prd">
      <CheckBox v-model="summary">{{ t('pulls.postSummary') }}</CheckBox>
      <p v-if="findings.length" class="hint prd-h">{{ t('pulls.postFindings') }}</p>
      <ul class="prd-l">
        <li v-for="(f, i) in findings" :key="i">
          <CheckBox v-model="chosen[i]" :disabled="!onLine(f)">
            <span class="badge" :class="f.severity === 'blocker' || f.severity === 'major' ? 'b-bad' : 'b-gray'">{{ f.severity }}</span>
            <span class="prd-t">{{ f.title }}</span>
            <span class="hint mono">{{ f.file ? `${f.file}${f.line ? ':' + f.line : ''}` : '' }}</span>
            <span v-if="!onLine(f)" class="hint">{{ t('pulls.summaryOnly') }}</span>
          </CheckBox>
        </li>
      </ul>
      <CheckBox v-if="host === 'GitHub'" v-model="changes">{{ t('pulls.requestChanges') }}</CheckBox>
      <p v-else class="hint">{{ t('pulls.noRequestChanges') }}</p>
    </div>
  </ConfirmDialog>
</template>

<style scoped>
.prd { display: grid; gap: 10px; text-align: left; margin: 6px 0 4px; max-height: 50vh; overflow-y: auto; }
.prd-h { margin: 4px 0 0; }
.prd-l { list-style: none; margin: 0; padding: 0; display: grid; gap: 8px; }
.prd-t { overflow-wrap: anywhere; }
.prd :deep(.cbx-lbl) { display: flex; flex-wrap: wrap; align-items: center; gap: 4px 8px; }
</style>
