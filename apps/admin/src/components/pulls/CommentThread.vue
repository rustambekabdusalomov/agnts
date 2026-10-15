<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import type { PullThread } from '../../api/types'
import { ago } from '../../composables/format'
import { askConfirm } from '../../composables/useConfirm'
import CommentBody from './CommentBody.vue'
import CommentComposer from './CommentComposer.vue'
import type { usePullWrites } from './usePull'

// One thread of a pull request: its comments, with edit and delete on
// your own, a reply box and resolve. `where` shows the file and line
// (off when the thread sits in the diff already).
const props = defineProps<{
  thread: PullThread
  writes: ReturnType<typeof usePullWrites>
  canEdit: boolean
  as: string
  where?: boolean
}>()
const { t, locale } = useI18n()
const replying = ref(false)
const editing = ref<string | null>(null)
const th = computed(() => props.thread)
const line = computed(() => th.value.line || th.value.oldLine || 0)
const verdict = computed(() => (th.value.kind === 'review' ? th.value.reviewState : undefined))
const VERDICT_TONE: Record<string, string> = { APPROVED: 'b-ok', CHANGES_REQUESTED: 'b-bad', COMMENTED: 'b-gray' }
// The last lines of the diff around the thread, for the conversation view.
const hunk = computed(() => (th.value.diffHunk ?? '').split('\n').slice(-4).join('\n'))

async function remove(id: string) {
  const ok = await askConfirm({ title: t('pulls.deleteTitle'), message: t('pulls.deleteConfirm'), confirmLabel: t('pulls.delete'), danger: true })
  if (ok) props.writes.remove.mutate(id)
}
function saveEdit(id: string, body: string) {
  props.writes.edit.mutate({ commentId: id, body }, { onSuccess: () => (editing.value = null) })
}
function sendReply(body: string) {
  props.writes.reply.mutate({ threadId: th.value.id, body }, { onSuccess: () => (replying.value = false) })
}
</script>

<template>
  <article class="th" :class="{ resolved: th.resolved }">
    <header v-if="where && th.kind === 'inline'" class="th-where">
      <span class="mono">{{ th.path }}<template v-if="line">:{{ line }}</template></span>
      <span v-if="th.outdated" class="badge b-gray">{{ t('pulls.outdated') }}</span>
      <span v-if="th.resolved" class="badge b-ok">{{ t('pulls.resolved') }}</span>
      <span v-if="th.sent" class="badge b-info">{{ th.replied ? t('pulls.answered') : t('pulls.sent') }}</span>
    </header>
    <pre v-if="where && th.kind === 'inline' && hunk" class="th-hunk mono">{{ hunk }}</pre>
    <div v-for="c in th.comments" :key="c.id" class="cm" :class="{ sys: c.system }">
      <div class="cm-h">
        <span class="cm-av" aria-hidden="true">
          <img v-if="c.avatarUrl" :src="c.avatarUrl" alt="" referrerpolicy="no-referrer">
          <template v-else>{{ c.author.slice(0, 1).toUpperCase() }}</template>
        </span>
        <b>{{ c.author }}</b>
        <span v-if="verdict && c === th.comments[0]" class="badge" :class="VERDICT_TONE[verdict] ?? 'b-gray'">{{ t(`pulls.verdict_${verdict}`) }}</span>
        <span v-if="c.agnts" class="badge b-info">agnts</span>
        <a v-if="c.url" class="hint" :href="c.url" target="_blank" rel="noopener">{{ ago(c.createdAt, locale) }}</a>
        <span v-else class="hint">{{ ago(c.createdAt, locale) }}</span>
        <span v-if="new Date(c.updatedAt).getTime() - new Date(c.createdAt).getTime() > 1000" class="hint">· {{ t('pulls.edited') }}</span>
        <span class="cm-sp" />
        <template v-if="canEdit && c.mine && !c.system && editing !== c.id">
          <button type="button" class="lnk" @click="editing = c.id">{{ t('pulls.edit') }}</button>
          <button v-if="!c.id.startsWith('rv:')" type="button" class="lnk bad" :disabled="writes.remove.isPending.value" @click="remove(c.id)">{{ t('pulls.delete') }}</button>
        </template>
      </div>
      <CommentComposer
        v-if="editing === c.id"
        :initial="c.body"
        :busy="writes.edit.isPending.value"
        :submit-label="t('pulls.save')"
        autofocus
        @submit="(b) => saveEdit(c.id, b)"
        @cancel="editing = null"
      />
      <CommentBody v-else-if="c.body.trim()" :markdown="c.body" />
    </div>
    <footer v-if="canEdit" class="th-f">
      <CommentComposer
        v-if="replying"
        :busy="writes.reply.isPending.value"
        :submit-label="t('pulls.reply')"
        :as="as"
        autofocus
        @submit="sendReply"
        @cancel="replying = false"
      />
      <template v-else>
        <button type="button" class="btn btn-s" @click="replying = true">{{ t('pulls.reply') }}</button>
        <button
          v-if="th.resolvable"
          type="button"
          class="btn btn-s"
          :disabled="writes.resolve.isPending.value"
          @click="writes.resolve.mutate({ threadId: th.id, resolved: !th.resolved })"
        >
          {{ th.resolved ? t('pulls.unresolve') : t('pulls.resolve') }}
        </button>
      </template>
    </footer>
  </article>
</template>

<style scoped>
.th { border: 1px solid var(--line); border-radius: 12px; background: var(--surface); padding: 12px 14px; display: grid; gap: 10px; min-width: 0; }
.th.resolved { opacity: 0.8; }
.th-where { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; font-size: 13px; overflow-wrap: anywhere; }
.th-hunk { margin: 0; padding: 8px 10px; border-radius: 8px; background: var(--field); font-size: 12.5px; overflow-x: auto; white-space: pre; }
.cm { display: grid; gap: 6px; min-width: 0; }
.cm + .cm { border-top: 1px solid var(--line-2); padding-top: 10px; }
.cm.sys { color: var(--ink-3); font-size: 13px; }
.cm-h { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; font-size: 13.5px; }
.cm-av { width: 22px; height: 22px; border-radius: 50%; overflow: hidden; display: grid; place-items: center; background: var(--hover); font-size: 11px; font-weight: 700; flex: none; }
.cm-av img { width: 100%; height: 100%; object-fit: cover; }
.cm-sp { flex: 1; }
.lnk { background: none; border: 0; padding: 2px 4px; font: inherit; font-size: 13px; color: var(--ink-2); cursor: pointer; }
.lnk:hover { color: var(--ink); text-decoration: underline; }
.lnk.bad { color: var(--bad-ink, #b42318); }
.th-f { display: flex; gap: 8px; flex-wrap: wrap; }
.th-f > .cmp { flex: 1 1 100%; }
</style>
