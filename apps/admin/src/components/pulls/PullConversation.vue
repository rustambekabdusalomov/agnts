<script setup lang="ts">
import { computed, ref, toRef } from 'vue'
import { useI18n } from 'vue-i18n'
import type { FileChange, PullThread, ReviewDraft } from '../../api/types'
import HiIcon from '../ui/HiIcon.vue'
import CommentComposer from './CommentComposer.vue'
import CommentThread from './CommentThread.vue'
import PullDiffFile from './PullDiffFile.vue'
import { draftsOnFile, useDraftWrites } from './useDrafts'
import { hostName, usePullThreads, usePullWrites } from './usePull'

// A pull request's conversation from the git host: every thread in the
// order it started, and (with files) the diff with threads under their
// lines. Comments go out as the git host token's user (login). With a
// review ticket (ticketKey), agnts's draft comments sit on the diff too.
const props = defineProps<{
  repoId: number
  number: number
  provider?: string
  login?: string
  headSha?: string
  files?: FileChange[]
  canEdit: boolean
  ticketKey?: string
  drafts?: ReviewDraft[]
  draftsLocked?: boolean
}>()
const { t } = useI18n()
const repoId = toRef(props, 'repoId')
const number = toRef(props, 'number')
const threads = usePullThreads(repoId, number)
const writes = usePullWrites(repoId, number)
const draftWrites = useDraftWrites(toRef(props, 'ticketKey'))
const reviewing = computed(() => !!props.ticketKey && !!props.drafts)
// Open on the diff while agnts's drafts wait for a decision.
const view = ref<'conversation' | 'files'>(props.files && props.drafts?.some((d) => d.state === 'draft') ? 'files' : 'conversation')
const showResolved = ref(false)
const composer = ref<InstanceType<typeof CommentComposer> | null>(null)

const host = computed(() => hostName(props.provider))
const as = computed(() => (props.login ? t('pulls.postsAs', { login: props.login, host: host.value }) : t('pulls.postsAsToken', { host: host.value })))
const all = computed<PullThread[]>(() => threads.data.value ?? [])
// System notes ("added 2 commits") say little; resolved threads fold away.
const shown = computed(() =>
  all.value.filter((th) => !th.comments.every((c) => c.system) && (showResolved.value || !th.resolved)),
)
const resolvedN = computed(() => all.value.filter((th) => th.resolved).length)
const openN = computed(() => all.value.filter((th) => th.resolvable && !th.resolved).length)
const byFile = computed(() => {
  const m = new Map<string, PullThread[]>()
  for (const th of all.value) if (th.kind === 'inline' && th.path) m.set(th.path, [...(m.get(th.path) ?? []), th])
  return m
})
const errMsg = (e: unknown) => (e instanceof Error && e.message ? e.message : t('common.error'))

function comment(body: string) {
  writes.add.mutate({ body }, { onSuccess: () => composer.value?.clear() })
}
</script>

<template>
  <div class="pconv">
    <div class="pconv-bar">
      <div v-if="files" class="tabs" role="tablist" style="margin: 0">
        <button type="button" class="tab" role="tab" :aria-selected="view === 'conversation'" :aria-pressed="view === 'conversation'" @click="view = 'conversation'">
          {{ t('pulls.conversation') }} <span class="hint">{{ all.length }}</span>
        </button>
        <button type="button" class="tab" role="tab" :aria-selected="view === 'files'" :aria-pressed="view === 'files'" @click="view = 'files'">
          {{ t('pulls.files') }} <span class="hint">{{ files.length }}</span>
        </button>
      </div>
      <span v-if="openN" class="badge b-warn">{{ t('pulls.unresolvedN', { n: openN }) }}</span>
      <span class="pconv-sp" />
      <label v-if="resolvedN && view === 'conversation'" class="hint pconv-tg">
        <input v-model="showResolved" type="checkbox"> {{ t('pulls.showResolved', { n: resolvedN }) }}
      </label>
    </div>

    <p v-if="threads.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <div v-else-if="threads.isError.value" class="help bad"><HiIcon name="info" /><p>{{ errMsg(threads.error.value) }}</p></div>
    <template v-else-if="view === 'conversation'">
      <p v-if="!shown.length" class="hint">{{ t('pulls.noComments') }}</p>
      <CommentThread v-for="th in shown" :key="th.id" :thread="th" :writes="writes" :can-edit="canEdit" :as="as" where />
      <div v-if="canEdit" class="pconv-new">
        <h3>{{ t('pulls.addComment') }}</h3>
        <CommentComposer ref="composer" :busy="writes.add.isPending.value" :submit-label="t('pulls.comment')" :as="as" @submit="comment" @cancel="composer?.clear()" />
      </div>
    </template>
    <template v-else>
      <p v-if="!files?.length" class="hint">{{ t('pulls.noFiles') }}</p>
      <PullDiffFile
        v-for="f in files ?? []"
        :key="f.path"
        :file="f"
        :threads="byFile.get(f.path) ?? []"
        :writes="writes"
        :can-edit="canEdit"
        :as="as"
        :head-sha="headSha"
        :drafts="reviewing ? draftsOnFile(drafts ?? [], f.path) : undefined"
        :draft-writes="reviewing ? draftWrites : undefined"
        :drafts-locked="draftsLocked"
      />
    </template>
  </div>
</template>

<style scoped>
.pconv { display: grid; gap: 12px; min-width: 0; }
.pconv-bar { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.pconv-sp { flex: 1; }
.pconv-tg { display: inline-flex; align-items: center; gap: 6px; cursor: pointer; }
.pconv-new h3 { margin: 6px 0 8px; font-size: 15px; }
</style>
