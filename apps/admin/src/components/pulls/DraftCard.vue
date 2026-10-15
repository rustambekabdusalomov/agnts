<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { SEVERITY_TONE, type ReviewDraft } from '../../api/types'
import { askConfirm } from '../../composables/useConfirm'
import CommentBody from './CommentBody.vue'
import CommentComposer from './CommentComposer.vue'
import type { useDraftWrites } from './useDrafts'

// One comment of agnts's review that is kept in agnts: a draft until a
// person accepts it, and only accepted ones are published on the git
// host. Dismiss can say why (agnts learns what you call noise); a
// person's own comment can be deleted. locked: read only (the review was
// dismissed, or the pull request closed).
const props = defineProps<{
  draft: ReviewDraft
  writes: ReturnType<typeof useDraftWrites>
  canEdit: boolean
  locked?: boolean
  where?: boolean
}>()
const { t } = useI18n()
const d = computed(() => props.draft)
const editing = ref(false)
const dismissing = ref(false)
const reason = ref('')
const live = computed(() => props.canEdit && !props.locked && !['publishing', 'published'].includes(d.value.state))
const STATE_TONE: Record<ReviewDraft['state'], string> = {
  draft: 'b-gray', accepted: 'b-ok', publishing: 'b-info', dismissed: 'b-gray', published: 'b-info', outdated: 'b-warn',
}
const sevTone = computed(() => (d.value.kind === 'finding' && d.value.severity ? `b-${SEVERITY_TONE[d.value.severity as keyof typeof SEVERITY_TONE] ?? 'gray'}` : ''))
const who = computed(() => (d.value.kind === 'comment' ? d.value.author || t('drafts.someone') : 'agnts'))

function set(state: 'draft' | 'accepted' | 'dismissed', dismissReason?: string) {
  props.writes.update.mutate({ id: d.value.id, state, dismissReason }, {
    onSuccess: () => {
      dismissing.value = false
      reason.value = ''
    },
  })
}
function save(body: string) {
  props.writes.update.mutate({ id: d.value.id, body }, { onSuccess: () => (editing.value = false) })
}
async function remove() {
  if (await askConfirm({ title: t('drafts.deleteTitle'), message: t('drafts.deleteConfirm'), confirmLabel: t('pulls.delete'), danger: true })) {
    props.writes.remove.mutate(d.value.id)
  }
}
</script>

<template>
  <article class="dr" :class="[`dr-${d.state}`]" :data-state="d.state">
    <header class="dr-h">
      <span class="dr-chip">{{ t('drafts.chip') }}</span>
      <b>{{ who }}</b>
      <span v-if="sevTone" class="badge" :class="sevTone">{{ d.severity }}</span>
      <span v-if="d.kind === 'summary'" class="badge b-gray">{{ t('drafts.summary') }}</span>
      <span v-if="d.category && d.kind === 'finding'" class="hint">{{ d.category }}</span>
      <span class="badge" :class="STATE_TONE[d.state]">{{ t(`drafts.state_${d.state}`) }}</span>
      <span v-if="d.edited" class="hint">· {{ t('drafts.edited') }}</span>
      <span v-if="where && d.path" class="mono hint dr-where">{{ d.path }}<template v-if="d.line">:{{ d.line }}</template></span>
    </header>
    <p v-if="d.error" class="help bad dr-err">{{ t('drafts.failed', { error: d.error }) }}</p>
    <p v-if="d.state === 'dismissed' && d.dismissReason" class="hint dr-reason">{{ t('drafts.dismissedBecause', { reason: d.dismissReason }) }}</p>
    <p v-if="d.state === 'outdated'" class="hint dr-reason">{{ t('drafts.outdatedHint') }}</p>
    <CommentComposer
      v-if="editing"
      :initial="d.body"
      :busy="writes.update.isPending.value"
      :submit-label="t('pulls.save')"
      autofocus
      @submit="save"
      @cancel="editing = false"
    />
    <CommentBody v-else :markdown="d.body" :class="{ 'dr-dim': d.state === 'dismissed' || d.state === 'outdated' }" />
    <div v-if="dismissing" class="dr-dis">
      <label class="hint" :for="`dr-r-${d.id}`">{{ t('drafts.reasonLabel') }}</label>
      <input :id="`dr-r-${d.id}`" v-model="reason" class="cfg-in" maxlength="1000" :placeholder="t('drafts.reasonHint')" @keydown.enter="set('dismissed', reason.trim() || undefined)">
      <div class="dr-act">
        <button type="button" class="btn btn-s" @click="dismissing = false">{{ t('form.cancel') }}</button>
        <button type="button" class="btn btn-s btn-d" :disabled="writes.update.isPending.value" @click="set('dismissed', reason.trim() || undefined)">{{ t('drafts.dismiss') }}</button>
      </div>
    </div>
    <footer v-else-if="live && !editing" class="dr-act">
      <template v-if="d.state === 'draft'">
        <button type="button" class="btn btn-s btn-p" :disabled="writes.update.isPending.value" @click="set('accepted')">{{ t('drafts.accept') }}</button>
        <button type="button" class="btn btn-s" @click="editing = true">{{ t('pulls.edit') }}</button>
        <button v-if="d.kind !== 'comment'" type="button" class="btn btn-s" @click="dismissing = true">{{ t('drafts.dismiss') }}</button>
      </template>
      <template v-else-if="d.state === 'accepted'">
        <button type="button" class="btn btn-s" :disabled="writes.update.isPending.value" @click="set('draft')">{{ t('drafts.undo') }}</button>
        <button type="button" class="btn btn-s" @click="editing = true">{{ t('pulls.edit') }}</button>
      </template>
      <template v-else-if="d.state === 'dismissed' || d.state === 'outdated'">
        <button type="button" class="btn btn-s" :disabled="writes.update.isPending.value" @click="set('draft')">{{ t('drafts.reopen') }}</button>
      </template>
      <button v-if="d.kind === 'comment'" type="button" class="lnk bad" :disabled="writes.remove.isPending.value" @click="remove">{{ t('pulls.delete') }}</button>
    </footer>
  </article>
</template>

<style scoped>
/* A draft is not on the git host: a dashed edge sets it apart from the
   threads around it. */
.dr { border: 1.5px dashed var(--line); border-radius: 12px; background: var(--surface); padding: 12px 14px; display: grid; gap: 8px; min-width: 0; }
.dr-accepted { border-color: var(--ok, #16a34a); border-style: solid; }
.dr-dismissed, .dr-outdated { opacity: 0.75; }
.dr-h { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; font-size: 13.5px; }
.dr-chip { font-size: 11.5px; font-weight: 700; letter-spacing: 0.02em; text-transform: uppercase; color: var(--ink-3); border: 1px dashed var(--line); border-radius: 5px; padding: 0 6px; }
.dr-where { overflow-wrap: anywhere; }
.dr-err, .dr-reason { margin: 0; }
.dr-dim { color: var(--ink-3); }
.dr-dis { display: grid; gap: 6px; }
.dr-act { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }
.lnk { background: none; border: 0; padding: 2px 4px; font: inherit; font-size: 13px; color: var(--ink-2); cursor: pointer; }
.lnk.bad { color: var(--bad-ink, #b42318); }
</style>
