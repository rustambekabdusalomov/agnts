<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { KINDS, type FollowUpSuggestion, type FollowUps, type FollowUpsMode, type Ticket, type TicketKind } from '../../api/types'
import { useUi } from '../../stores/ui'
import StateBadge from '../StateBadge.vue'
import CheckBox from '../form/CheckBox.vue'
import InputSelect from '../form/InputSelect.vue'
import { useIntegrations } from '../integrations/useIntegrations'
import { useTr } from '../../composables/useTranslation'

// Follow-up tickets agnts suggests for finishing this one. The person
// picks, then creates them held (nothing spends tokens until someone
// starts each one) or started. Either way a suggestion that must wait for
// another one waits for its ticket in the queue.
const props = defineProps<{ ticket: Ticket; followUps?: FollowUps }>()
const { t } = useI18n()
const tr = useTr()
const qc = useQueryClient()
const ui = useUi()

const integrations = useIntegrations()
const jira = computed(() => !!integrations.data.value?.find((i) => i.provider === 'jira' && i.connected))
const plane = computed(() => !!integrations.data.value?.find((i) => i.provider === 'plane' && i.connected))

const all = computed(() => props.followUps?.suggestions ?? [])
const open = computed(() => all.value.filter((s) => s.status === 'open'))
const decided = computed(() => all.value.filter((s) => s.status !== 'open'))
const children = computed(() => props.followUps?.children ?? [])

// Per suggestion: picked or not, and the person's edits.
type Edit = { picked: boolean; title: string; kind: TicketKind; target: 'local' | 'jira' | 'plane'; open: boolean }
const edits = reactive<Record<number, Edit>>({})
watch(
  open,
  (ss) => {
    for (const s of ss) edits[s.id] ??= { picked: false, title: s.title, kind: s.kind, target: 'local', open: false }
  },
  { immediate: true },
)
const picked = computed(() => open.value.filter((s) => s.ready && edits[s.id]?.picked))
// The sibling suggestions one must wait for, by title.
const afterOf = (s: FollowUpSuggestion) =>
  (s.after ?? []).map((id) => all.value.find((x) => x.id === id)).filter((x) => !!x).map((x) => x.childKey ?? tr.value(x.title))

// The parent's repositories a suggestion is about, for a ticket in several.
const repoNames = (s: FollowUpSuggestion) =>
  (s.repoIds ?? []).map((id) => props.ticket.repos?.find((r) => r.repoId === id)?.repoName).filter((x) => !!x).join(', ')

const kindOptions = computed(() => KINDS.map((k) => ({ value: k, label: t(`kind.${k}`) })))
const targetOptions = computed(() => [
  { value: 'local' as const, label: t('followUps.targetLocal') },
  { value: 'jira' as const, label: t('followUps.targetJira'), disabled: !jira.value, hint: jira.value ? undefined : t('followUps.jiraOff') },
  { value: 'plane' as const, label: t('followUps.targetPlane'), disabled: !plane.value, hint: plane.value ? undefined : t('followUps.planeOff') },
])
const modeOptions = computed(() => [
  { value: 'inherit' as const, label: t('followUps.modeInherit') },
  { value: 'on' as const, label: t('followUps.modeOn') },
  { value: 'off' as const, label: t('followUps.modeOff') },
])
const mode = computed(() => props.ticket.suggestFollowUps ?? 'inherit')

const refresh = () => {
  void qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] })
  for (const k of ['tickets', 'nav']) void qc.invalidateQueries({ queryKey: [k] })
}
const fail = (e: unknown) => ui.notify(e instanceof HttpError ? e.message : t('common.error'))

const setMode = useMutation({
  mutationFn: (m: FollowUpsMode) => unwrap(api.PUT('/tickets/{key}/follow-ups', { params: { path: { key: props.ticket.key } }, body: { mode: m } })),
  onSuccess: refresh,
  onError: fail,
})

const errors = ref<string[]>([])
const accept = useMutation({
  mutationFn: (start: boolean) =>
    unwrap(
      api.POST('/tickets/{key}/follow-ups/accept', {
        params: { path: { key: props.ticket.key } },
        body: {
          start,
          items: picked.value.map((s) => {
            const e = edits[s.id]
            return {
              id: s.id,
              target: e.target,
              title: e.title.trim() && e.title.trim() !== s.title ? e.title.trim() : undefined,
              kind: e.kind !== s.kind ? e.kind : undefined,
            }
          }),
        },
      }),
    ),
  onSuccess: (res, start) => {
    const made = res.results.filter((r) => r.ticket).length
    errors.value = res.results
      .filter((r) => r.error)
      .map((r) => t('followUps.failedItem', { title: all.value.find((s) => s.id === r.id)?.title ?? `#${r.id}`, error: r.error ?? '' }))
    if (made) ui.notify(t(start ? 'followUps.startedNotice' : 'followUps.createdNotice', { count: made }))
    refresh()
  },
  onError: fail,
})

const dismiss = useMutation({
  mutationFn: (s: FollowUpSuggestion) =>
    unwrap(api.POST('/tickets/{key}/follow-ups/{id}/dismiss', { params: { path: { key: props.ticket.key, id: s.id } } })),
  onSuccess: refresh,
  onError: fail,
})
</script>

<template>
  <section v-if="followUps" class="card fu">
    <div class="ch">
      <div>
        <h2>{{ t('followUps.title') }}</h2>
        <p class="sub">{{ t('followUps.sub') }}</p>
      </div>
      <div class="fu-mode">
        <InputSelect :model-value="mode" :options="modeOptions" :label="t('followUps.mode')" :disabled="setMode.isPending.value" @update:model-value="(m) => setMode.mutate(m)" />
      </div>
    </div>

    <p v-if="!followUps.enabled && !all.length" class="hint">{{ t('followUps.offEmpty') }}</p>
    <p v-else-if="!all.length && !children.length" class="hint">{{ t('followUps.onEmpty') }}</p>

    <ul v-if="open.length" class="fu-list">
      <li v-for="s in open" :key="s.id" class="fu-item" :class="{ 'fu-wait': !s.ready }">
        <div class="fu-row">
          <CheckBox v-model="edits[s.id].picked" class="fu-check" :disabled="!s.ready" :label="t('followUps.pick', { title: s.title })" />
          <div class="fu-main">
            <div class="fu-tags">
              <span class="badge" :class="`b-${s.type === 'prerequisite' ? 'warn' : s.type === 'gap' ? 'bad' : 'info'}`">{{ t(`followUps.type_${s.type}`) }}</span>
              <span class="fu-src">{{ t(`followUps.source_${s.source}`) }}</span>
              <span class="fu-src">· {{ t(`tasks.${s.priority}`) }}</span>
              <span v-if="repoNames(s)" class="fu-src">· {{ repoNames(s) }}</span>
            </div>
            <input v-if="edits[s.id].picked" v-model="edits[s.id].title" class="cfg-in fu-title-in" :aria-label="t('followUps.editTitle')" maxlength="300">
            <p v-else class="fu-title">{{ tr(s.title) }}</p>
            <p class="fu-serves"><b>{{ t('followUps.serves') }}:</b> {{ tr(s.serves) }}</p>
            <p v-if="afterOf(s).length" class="fu-serves"><b>{{ t('followUps.after') }}:</b> {{ afterOf(s).join(', ') }}</p>
            <button v-if="s.description" type="button" class="fu-more" :aria-expanded="edits[s.id].open" @click="edits[s.id].open = !edits[s.id].open">
              {{ t('followUps.details') }}
            </button>
            <p v-if="s.description && edits[s.id].open" class="fu-desc">{{ tr(s.description) }}</p>
            <p v-if="!s.ready" class="hint fu-hint">{{ t('followUps.waitsForDone') }}</p>
            <div v-if="edits[s.id].picked" class="fu-opts">
              <InputSelect v-model="edits[s.id].kind" :options="kindOptions" :label="t('kind.title')" />
              <InputSelect v-model="edits[s.id].target" :options="targetOptions" :label="t('followUps.target')" />
            </div>
          </div>
          <button type="button" class="btn btn-s" :disabled="dismiss.isPending.value" @click="dismiss.mutate(s)">{{ t('followUps.dismiss') }}</button>
        </div>
      </li>
    </ul>

    <ul v-if="errors.length" class="ferr fu-errs" role="alert">
      <li v-for="(e, i) in errors" :key="i">{{ e }}</li>
    </ul>
    <div v-if="open.length" class="actions" style="margin-top: 12px">
      <button class="btn btn-p" type="button" :disabled="!picked.length || accept.isPending.value" @click="accept.mutate(true)">
        {{ t('followUps.createStart', { count: picked.length }) }}
      </button>
      <button class="btn" type="button" :disabled="!picked.length || accept.isPending.value" @click="accept.mutate(false)">
        {{ t('followUps.createHeld') }}
      </button>
      <span class="hint">{{ t('followUps.queuedHint') }}</span>
    </div>

    <template v-if="children.length">
      <h3 class="fu-h3">{{ t('followUps.children') }}</h3>
      <ul class="fu-kids">
        <li v-for="c in children" :key="c.key">
          <RouterLink :to="{ name: 'ticket', params: { key: c.key } }">{{ c.key }}</RouterLink>
          <span class="fu-kid-title">{{ c.title }}</span>
          <StateBadge :state="c.state" :kind="c.kind" />
        </li>
      </ul>
    </template>

    <details v-if="decided.some((s) => s.status === 'dismissed')" class="fu-dismissed">
      <summary>{{ t('followUps.dismissedCount', { count: decided.filter((s) => s.status === 'dismissed').length }) }}</summary>
      <ul>
        <li v-for="s in decided.filter((x) => x.status === 'dismissed')" :key="s.id">{{ s.title }}</li>
      </ul>
    </details>
  </section>
</template>

<style scoped>
.fu .ch { align-items: flex-start; gap: 12px; flex-wrap: wrap; }
.fu-mode { min-width: 180px; }
.fu-list { list-style: none; margin: 4px 0 0; padding: 0; display: grid; gap: 10px; }
.fu-item { border: 1px solid var(--line); border-radius: 12px; padding: 12px 14px; }
.fu-wait { opacity: 0.75; }
.fu-row { display: flex; gap: 12px; align-items: flex-start; }
.fu-check { margin-top: 4px; flex: none; }
.fu-main { flex: 1; min-width: 0; }
.fu-tags { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.fu-src { font-size: 12.5px; color: var(--ink-3); font-weight: 600; }
.fu-title { margin: 8px 0 0; font-weight: 700; }
.fu-title-in { margin-top: 8px; width: 100%; }
.fu-serves { margin: 6px 0 0; font-size: 14px; }
.fu-more { margin-top: 6px; background: none; border: 0; padding: 0; color: var(--primary-ink); font-size: 13px; font-weight: 600; cursor: pointer; }
.fu-desc { margin: 6px 0 0; font-size: 14px; white-space: pre-wrap; }
.fu-hint { margin: 6px 0 0; font-size: 13px; }
.fu-opts { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 10px; margin-top: 10px; }
.fu-errs { margin: 10px 0 0; padding-left: 18px; }
.fu-h3 { margin: 18px 0 8px; }
.fu-kids { list-style: none; margin: 0; padding: 0; display: grid; gap: 6px; }
.fu-kids li { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.fu-kid-title { flex: 1; min-width: 0; overflow-wrap: anywhere; }
.fu-dismissed { margin-top: 14px; font-size: 13.5px; color: var(--ink-3); }
.fu-dismissed ul { margin: 6px 0 0; }
</style>
