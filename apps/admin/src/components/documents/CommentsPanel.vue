<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { HttpError } from '../../api/client'
import type { DocumentComment } from '../../api/types'
import { ago } from '../../composables/format'
import type { Anchor } from './anchors'
import { personHue } from './personColor'
import type { Thread, useComments } from './useComments'

// The comments of a document: a composer for the words just selected, the
// open threads (with replies, edits, resolve) and the resolved ones folded.
// Members and guests use the same panel; the server says what each may do.
const props = defineProps<{
  c: ReturnType<typeof useComments>
  pending: { anchor: Anchor; slide?: number } | null
  activeId: number | null
  missing: number[]
  canComment: boolean
  // A member on a public document: guests read comments too.
  publicNotice?: boolean
}>()
const emit = defineEmits<{ activate: [id: number]; cancel: [] }>()
const { t, locale } = useI18n()

const open = computed(() => props.c.threads.value.filter((th) => !th.root.resolvedAt))
const resolved = computed(() => props.c.threads.value.filter((th) => th.root.resolvedAt))
const error = ref('')
const fail = (e: unknown) => (error.value = e instanceof HttpError ? e.message : t('common.error'))

// New thread on the selection.
const draft = ref('')
const composer = ref<HTMLTextAreaElement>()
watch(
  () => props.pending,
  async (p) => {
    error.value = ''
    if (!p) return
    draft.value = ''
    await nextTick()
    composer.value?.focus()
  },
)
async function post() {
  if (!props.pending || !draft.value.trim()) return
  try {
    const c = await props.c.add.mutateAsync({ body: draft.value, ...props.pending.anchor, slide: props.pending.slide })
    draft.value = ''
    emit('cancel')
    emit('activate', c.id)
  } catch (e) {
    fail(e)
  }
}

// Replies and edits, one box each, keyed by comment.
const replies = ref<Record<number, string>>({})
async function reply(th: Thread) {
  const body = replies.value[th.root.id]?.trim()
  if (!body) return
  try {
    await props.c.add.mutateAsync({ body, parentId: th.root.id })
    replies.value[th.root.id] = ''
  } catch (e) {
    fail(e)
  }
}
const editing = ref<number | null>(null)
const editText = ref('')
function startEdit(cm: DocumentComment) {
  editing.value = cm.id
  editText.value = cm.body
}
async function saveEdit() {
  if (editing.value == null || !editText.value.trim()) return
  try {
    await props.c.patch.mutateAsync({ id: editing.value, body: editText.value })
    editing.value = null
  } catch (e) {
    fail(e)
  }
}
async function resolve(th: Thread, on: boolean) {
  try {
    await props.c.patch.mutateAsync({ id: th.root.id, resolved: on })
  } catch (e) {
    fail(e)
  }
}
async function remove(cm: DocumentComment) {
  if (!window.confirm(cm.parentId == null ? t('documents.deleteThreadConfirm') : t('documents.deleteCommentConfirm'))) return
  try {
    await props.c.remove.mutateAsync(cm.id)
  } catch (e) {
    fail(e)
  }
}

function badge(cm: DocumentComment): string {
  if (cm.authorKind !== 'guest') return ''
  return cm.authorVia === 'account' ? t('documents.viaAccount') : cm.authorVia === 'google' ? t('documents.viaGoogle') : t('documents.guest')
}
const short = (s: string) => ([...s].length > 140 ? [...s].slice(0, 140).join('') + '…' : s)
</script>

<template>
  <section class="card cp">
    <div class="ch">
      <h2>{{ t('documents.comments') }}<span v-if="open.length" class="cp-n">{{ open.length }}</span></h2>
    </div>

    <div v-if="pending" class="cp-new">
      <blockquote class="cp-q">{{ short(pending.anchor.quote) }}</blockquote>
      <textarea
        ref="composer"
        v-model="draft"
        rows="3"
        maxlength="5000"
        :placeholder="t('documents.commentPlaceholder')"
        :aria-label="t('documents.commentPlaceholder')"
        @keydown.meta.enter="post"
        @keydown.ctrl.enter="post"
        @keydown.esc="emit('cancel')"
      />
      <p v-if="publicNotice" class="fhelp">{{ t('documents.guestsCanRead') }}</p>
      <div class="cp-act">
        <button type="button" class="btn btn-s" @click="emit('cancel')">{{ t('form.cancel') }}</button>
        <button type="button" class="btn btn-s btn-p" :disabled="!draft.trim() || c.add.isPending.value" @click="post">{{ t('documents.post') }}</button>
      </div>
    </div>

    <span v-if="error" class="ferr" role="alert">{{ error }}</span>
    <p v-if="!open.length && !pending" class="hint">{{ canComment ? t('documents.noCommentsHint') : t('documents.noComments') }}</p>

    <ol class="cp-list">
      <li
        v-for="th in open"
        :key="th.root.id"
        class="cp-th"
        :class="{ active: th.root.id === activeId }"
        :style="{ '--ch': personHue(th.root.authorName) }"
        @click="emit('activate', th.root.id)"
      >
        <blockquote class="cp-q" :class="{ gone: missing.includes(th.root.id) }">
          <span v-if="th.root.slide != null" class="tkey">{{ t('documents.slideN', { n: th.root.slide + 1 }) }}</span>
          {{ short(th.root.quote) }}
        </blockquote>
        <p v-if="missing.includes(th.root.id)" class="cp-gone">{{ t('documents.textChanged') }}</p>
        <div v-for="cm in [th.root, ...th.replies]" :key="cm.id" class="cp-c" :style="{ '--ph': personHue(cm.authorName) }">
          <div class="cp-h">
            <span class="cp-dot" aria-hidden="true" />
            <b class="cp-who">{{ cm.authorName }}</b>
            <span v-if="badge(cm)" class="badge b-gray" :title="cm.authorEmail">{{ badge(cm) }}</span>
            <span class="hint">{{ ago(cm.createdAt, locale) }}<template v-if="cm.updatedAt !== cm.createdAt && cm.id !== th.root.id"> · {{ t('documents.edited') }}</template></span>
          </div>
          <template v-if="editing === cm.id">
            <textarea v-model="editText" rows="3" maxlength="5000" :aria-label="t('documents.edit')" @click.stop />
            <div class="cp-act">
              <button type="button" class="btn btn-s" @click.stop="editing = null">{{ t('form.cancel') }}</button>
              <button type="button" class="btn btn-s btn-p" :disabled="!editText.trim()" @click.stop="saveEdit">{{ t('documents.save') }}</button>
            </div>
          </template>
          <p v-else class="cp-b">{{ cm.body }}</p>
          <div v-if="editing !== cm.id && (cm.mine || cm.canDelete)" class="cp-links">
            <button v-if="cm.mine" type="button" class="cp-link" @click.stop="startEdit(cm)">{{ t('documents.edit') }}</button>
            <button v-if="cm.canDelete" type="button" class="cp-link" @click.stop="remove(cm)">{{ t('documents.delete') }}</button>
          </div>
        </div>
        <div v-if="canComment" class="cp-reply" @click.stop>
          <input
            v-model="replies[th.root.id]"
            type="text"
            maxlength="5000"
            :placeholder="t('documents.replyPlaceholder')"
            :aria-label="t('documents.replyPlaceholder')"
            @keydown.enter="reply(th)"
          >
          <button v-if="th.root.canResolve" type="button" class="btn btn-s" :title="t('documents.resolveHelp')" @click="resolve(th, true)">{{ t('documents.resolve') }}</button>
        </div>
      </li>
    </ol>

    <details v-if="resolved.length" class="cp-res">
      <summary>{{ t('documents.resolvedN', { n: resolved.length }) }}</summary>
      <ol class="cp-list">
        <li v-for="th in resolved" :key="th.root.id" class="cp-th done" :style="{ '--ch': personHue(th.root.authorName) }">
          <blockquote class="cp-q">{{ short(th.root.quote) }}</blockquote>
          <p class="cp-b"><b>{{ th.root.authorName }}:</b> {{ th.root.body }}</p>
          <p class="hint">{{ t('documents.resolvedBy', { name: th.root.resolvedBy ?? '' }) }}<template v-if="th.replies.length"> · {{ t('documents.repliesN', { n: th.replies.length }) }}</template></p>
          <button v-if="th.root.canResolve" type="button" class="btn btn-s" @click="resolve(th, false)">{{ t('documents.reopen') }}</button>
        </li>
      </ol>
    </details>
  </section>
</template>

<style scoped>
.cp { display: flex; flex-direction: column; gap: 10px; }
.cp-n { margin-left: 8px; font-size: 12px; font-weight: 700; background: var(--line-2); border-radius: 10px; padding: 1px 8px; vertical-align: middle; }
.cp-new { display: flex; flex-direction: column; gap: 8px; padding: 10px; border: 1px solid var(--primary, #1a5fb4); border-radius: 10px; }
.cp-q { margin: 0; padding: 2px 0 2px 8px; border-left: 3px solid hsl(var(--ch, 43) 75% 42%); color: var(--ink-3); font-size: 13px; overflow-wrap: anywhere; }
.cp-q .tkey { margin-right: 6px; }
.cp-q.gone { text-decoration: line-through; border-left-color: var(--line-3); }
.cp-gone { margin: 0; font-size: 12.5px; color: var(--ink-3); }
.cp-list { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 10px; }
.cp-th { border: 1px solid var(--line-2); border-left: 4px solid hsl(var(--ch, 43) 75% 45%); border-radius: 10px; padding: 10px; display: flex; flex-direction: column; gap: 8px; cursor: pointer; }
.cp-th.active { border-color: hsl(var(--ch, 43) 75% 45%); box-shadow: 0 0 0 1px hsl(var(--ch, 43) 75% 45% / 0.5); }
/* Each comment in a thread in its own author's colour. */
.cp-dot { width: 9px; height: 9px; border-radius: 50%; flex: none; background: hsl(var(--ph, 43) 70% 45%); }
.cp-who { color: hsl(var(--ph, 43) 65% 36%); }
@media (prefers-color-scheme: dark) { :root:not([data-theme='light']) .cp-who { color: hsl(var(--ph, 43) 75% 70%); } }
:root[data-theme='dark'] .cp-who { color: hsl(var(--ph, 43) 75% 70%); }
.cp-th.done { cursor: default; }
.cp-c { display: flex; flex-direction: column; gap: 3px; }
.cp-h { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; font-size: 13.5px; }
.cp-h .hint { font-size: 12px; }
.cp-b { margin: 0; white-space: pre-wrap; overflow-wrap: anywhere; font-size: 14px; }
.cp-links { display: flex; gap: 10px; }
.cp-link { background: none; border: 0; padding: 0; color: var(--ink-3); font: inherit; font-size: 12.5px; cursor: pointer; }
.cp-link:hover { color: var(--ink); text-decoration: underline; }
.cp-reply { display: flex; gap: 6px; }
.cp-reply input { flex: 1; min-width: 0; border: 1px solid var(--line-3); border-radius: 8px; padding: 6px 9px; font: inherit; font-size: 13.5px; background: var(--surface); }
.cp-act { display: flex; gap: 8px; justify-content: flex-end; }
.cp-res summary { cursor: pointer; font-size: 13.5px; color: var(--ink-3); }
.cp-res .cp-list { margin-top: 8px; }
textarea { border: 1px solid var(--line-3); border-radius: 8px; padding: 8px 10px; font: inherit; font-size: 14px; background: var(--surface); resize: vertical; }
</style>
