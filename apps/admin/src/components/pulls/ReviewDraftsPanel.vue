<script setup lang="ts">
import { computed, ref, toRef } from 'vue'
import { useI18n } from 'vue-i18n'
import type { ReviewDraft } from '../../api/types'
import { useUi } from '../../stores/ui'
import CheckBox from '../form/CheckBox.vue'
import ConfirmDialog from '../ui/ConfirmDialog.vue'
import DraftCard from './DraftCard.vue'
import { draftCounts, useDraftWrites } from './useDrafts'

// The comments of agnts's review that are kept in agnts, with what was
// decided about each, and Publish: only accepted ones go to the git host,
// together as one review. `listed` are the drafts shown here (on the pull
// request page, the ones not placed on a diff line); `drafts` all of them.
const props = defineProps<{
  ticketKey: string
  drafts: ReviewDraft[]
  listed: ReviewDraft[]
  host: string
  headSha?: string
  canEdit: boolean
  locked?: boolean
  // The git host token's user opened the pull request: nobody can request
  // changes on their own.
  own?: boolean
}>()
const { t } = useI18n()
const ui = useUi()
const writes = useDraftWrites(toRef(props, 'ticketKey'))
const n = computed(() => draftCounts(props.drafts))
const showClosed = ref(false)
const confirming = ref(false)
const changes = ref(false)
const accepted = computed(() => props.drafts.filter((d) => d.state === 'accepted'))
// Accepted comments about another commit than the pull request's head go
// on the version agnts reviewed.
const moved = computed(() => {
  const old = accepted.value.find((d) => props.headSha && d.headSha && d.headSha !== props.headSha)
  return old ? { from: old.headSha.slice(0, 7), to: (props.headSha ?? '').slice(0, 7) } : null
})
const closed = (d: ReviewDraft) => ['dismissed', 'outdated', 'published'].includes(d.state)
const shown = computed(() => props.listed.filter((d) => showClosed.value || !closed(d)))
const hidden = computed(() => props.listed.filter(closed).length)
const editable = computed(() => props.canEdit && !props.locked)

function publish() {
  writes.publish.mutate(changes.value, {
    onSuccess: (r) => {
      confirming.value = false
      ui.notify(t('drafts.publishedToast', { n: accepted.value.length || r.inline, host: props.host }))
    },
  })
}
</script>

<template>
  <section class="rdp">
    <div class="rdp-bar">
      <div class="rdp-n">
        <b>{{ t('drafts.title') }}</b>
        <span class="badge b-ok">{{ t('drafts.nAccepted', { n: n.accepted }) }}</span>
        <span class="badge b-gray">{{ t('drafts.nDraft', { n: n.draft }) }}</span>
        <span v-if="n.dismissed" class="badge b-gray">{{ t('drafts.nDismissed', { n: n.dismissed }) }}</span>
        <span v-if="n.published" class="badge b-info">{{ t('drafts.nPublished', { n: n.published }) }}</span>
        <span v-if="n.outdated" class="badge b-warn">{{ t('drafts.nOutdated', { n: n.outdated }) }}</span>
      </div>
      <span class="rdp-sp" />
      <template v-if="editable">
        <button v-if="n.draft" type="button" class="btn btn-s" :disabled="writes.busy.value" @click="writes.acceptAll.mutate('major')">{{ t('drafts.acceptMajor') }}</button>
        <button v-if="n.draft" type="button" class="btn btn-s" :disabled="writes.busy.value" @click="writes.acceptAll.mutate(undefined)">{{ t('drafts.acceptAll') }}</button>
        <button type="button" class="btn btn-s btn-p" :disabled="!n.accepted || writes.busy.value" @click="confirming = true">
          {{ t('drafts.publishBtn', { n: n.accepted, host }) }}
        </button>
      </template>
    </div>
    <p class="hint rdp-sub">{{ locked ? t('drafts.lockedSub') : t('drafts.sub', { host }) }}</p>
    <DraftCard v-for="d in shown" :key="d.id" :draft="d" :writes="writes" :can-edit="canEdit" :locked="locked" where />
    <label v-if="hidden" class="hint rdp-tg"><input v-model="showClosed" type="checkbox"> {{ t('drafts.showClosed', { n: hidden }) }}</label>

    <ConfirmDialog
      v-model="confirming"
      :title="t('drafts.publishTitle', { host })"
      :message="t('drafts.publishSub', { n: accepted.length, host })"
      :confirm-label="t('drafts.publishBtn', { n: accepted.length, host })"
      :busy="writes.publish.isPending.value"
      @confirm="publish"
    >
      <div class="rdp-dlg">
        <div v-if="moved" class="help warn"><p>{{ t('drafts.headMoved', { from: moved.from, to: moved.to, host }) }}</p></div>
        <ul class="rdp-l">
          <li v-for="d in accepted" :key="d.id">
            <span class="badge b-gray">{{ d.kind === 'finding' ? d.severity : t(`drafts.kind_${d.kind}`) }}</span>
            <span class="rdp-t">{{ d.title || d.body.slice(0, 80) }}</span>
            <span v-if="d.path" class="hint mono">{{ d.path }}<template v-if="d.line">:{{ d.line }}</template></span>
          </li>
        </ul>
        <CheckBox v-if="host === 'GitHub' && !own" v-model="changes">{{ t('pulls.requestChanges') }}</CheckBox>
      </div>
    </ConfirmDialog>
  </section>
</template>

<style scoped>
.rdp { display: grid; gap: 10px; min-width: 0; }
.rdp-bar { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.rdp-n { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
.rdp-sp { flex: 1; }
.rdp-sub { margin: 0; }
.rdp-tg { display: inline-flex; align-items: center; gap: 6px; cursor: pointer; }
.rdp-dlg { display: grid; gap: 10px; text-align: left; margin: 6px 0 4px; max-height: 50vh; overflow-y: auto; }
.rdp-l { list-style: none; margin: 0; padding: 0; display: grid; gap: 6px; }
.rdp-l li { display: flex; flex-wrap: wrap; align-items: center; gap: 4px 8px; }
.rdp-t { overflow-wrap: anywhere; }
</style>
