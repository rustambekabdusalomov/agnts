<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { askConfirm } from '../../composables/useConfirm'
import { useWorkspace } from '../../stores/workspace'
import AiBadge from './AiBadge.vue'
import { num, str, strs, type ChatAction, type ChatCard, type ChatMessage } from './chat'
import { act } from './useChat'
import { useChatLinks } from './useChatLinks'

// agnts's card: what needs a person, and the buttons that do the real thing
// (the same write path as the ticket page). Approve and merge ask first;
// merge says when CI is not green but never blocks on it. Once pressed (here
// or by anyone else), the card shows what became of it instead of buttons.
const props = defineProps<{ message: ChatMessage }>()
const { t } = useI18n()
const workspace = useWorkspace()
const { repos } = useChatLinks()

const card = computed(() => props.message.card as ChatCard)
const d = computed(() => card.value.data ?? {})
const open = computed(() => card.value.state === 'open')
const busy = ref<ChatAction | ''>('')
const error = ref('')

// request_changes asks what to change; a draft can be edited before it is created.
const feedbackOpen = ref(false)
const feedback = ref('')
const draft = reactive({ title: '', description: '', repoId: 0 })
const editing = ref(false)
watch(
  () => [card.value.type, str(d.value, 'title'), str(d.value, 'description'), num(d.value, 'repoId')] as const,
  ([type, title, description, repoId]) => {
    if (type !== 'ticket_draft' || editing.value) return
    draft.title = title
    draft.description = description
    draft.repoId = repoId ?? 0
  },
  { immediate: true },
)
const repoName = (id: number) => repos.data.value?.find((r) => r.id === id)?.name ?? str(d.value, 'repo')
const repoChoices = computed(() => (repos.data.value ?? []).filter((r) => !r.archivedAt))

const ci = computed(() => str(d.value, 'ci') as 'ok' | 'fail' | 'run' | 'none' | '')
const ciChecks = computed(() => strs(d.value, 'ciChecks'))
const ciTone = computed(() => ({ ok: 'b-ok', fail: 'b-bad', run: 'b-warn', none: 'b-gray', '': 'b-gray' })[ci.value])
const ciLabel = computed(() => {
  const names = ciChecks.value.join(', ')
  switch (ci.value) {
    case 'ok':
      return t('teamchat.ciOk')
    case 'fail':
      return names ? t('teamchat.ciFailNames', { checks: names }) : t('teamchat.ciFail')
    case 'run':
      return names ? t('teamchat.ciRunNames', { checks: names }) : t('teamchat.ciRun')
    default:
      return t('teamchat.ciNone')
  }
})

const stateTone = computed(() => ({ open: 'b-info', done: 'b-ok', failed: 'b-bad', expired: 'b-gray' })[card.value.state])

async function confirmed(a: ChatAction): Promise<boolean> {
  if (a === 'approve') {
    return askConfirm({
      title: t('teamchat.approveTitle', { key: str(d.value, 'key') }),
      message: str(d.value, 'approveDoes') || card.value.title,
      confirmLabel: t('teamchat.act_approve'),
      danger: true,
    })
  }
  if (a === 'merge') {
    const n = num(d.value, 'number')
    const checks = ciChecks.value.join(', ')
    let message = t('teamchat.mergeText', { number: n ?? '', repo: str(d.value, 'repo') })
    if (ci.value === 'fail') message = checks ? t('teamchat.mergeCiFailNames', { checks }) : t('teamchat.mergeCiFail')
    else if (ci.value === 'run') message = checks ? t('teamchat.mergeCiRunNames', { checks }) : t('teamchat.mergeCiRun')
    else if (ci.value !== 'ok') message = t('teamchat.mergeCiNone')
    return askConfirm({ title: t('teamchat.mergeTitle', { number: n ?? '' }), message, confirmLabel: t('teamchat.act_merge'), danger: true })
  }
  return true
}

async function press(a: ChatAction) {
  if (a === 'request_changes' && !feedbackOpen.value) {
    feedbackOpen.value = true
    return
  }
  if (!(await confirmed(a))) return
  busy.value = a
  error.value = ''
  try {
    if (a === 'request_changes') await act(props.message.id, { action: a, feedback: feedback.value.trim() })
    else if (a === 'create' || a === 'create_assign') {
      await act(props.message.id, { action: a, draft: { title: draft.title.trim(), description: draft.description, ...(draft.repoId ? { repoId: draft.repoId } : {}) } })
    } else await act(props.message.id, { action: a })
    feedbackOpen.value = false
    editing.value = false
  } catch (e) {
    // 409: someone pressed it first (the message says who); 400: refused (why).
    error.value = e instanceof Error ? e.message : t('common.error')
  } finally {
    busy.value = ''
  }
}

const primary = (a: ChatAction) => ['fix', 'approve', 'merge', 'create', 'create_assign'].includes(a)
const danger = (a: ChatAction) => a === 'merge' || a === 'approve'
const paths = computed(() => strs(d.value, 'paths'))
const repos2 = computed(() => strs(d.value, 'repos'))
const acceptance = computed(() => strs(d.value, 'acceptance'))
const findingId = computed(() => num(d.value, 'findingId'))
const ticketKey = computed(() => str(d.value, 'ticketKey') || props.message.ticketKey || '')
const usd = (n: number | undefined) => (n === undefined ? '' : `$${n.toFixed(2)}`)
</script>

<template>
  <div class="cc" :class="[card.type, card.state]">
    <div class="cc-h">
      <b class="cc-t">{{ card.title }}</b>
      <span v-if="!open" class="badge" :class="stateTone">{{ t(`teamchat.state_${card.state}`) }}</span>
      <span class="sp" />
      <AiBadge v-if="message.ai" :ai="message.ai" />
    </div>
    <p v-if="card.summary" class="cc-sum">{{ card.summary }}</p>

    <!-- log_finding -->
    <template v-if="card.type === 'log_finding'">
      <p class="cc-meta">
        <span class="badge" :class="str(d, 'severity') === 'critical' || str(d, 'severity') === 'high' ? 'b-bad' : 'b-warn'">{{ str(d, 'severity') || '—' }}</span>
        <b>{{ str(d, 'service') }}</b>
        <span v-if="str(d, 'category')">· {{ str(d, 'category') }}</span>
        <span v-if="num(d, 'count')">· ×{{ num(d, 'count') }}</span>
        <span v-if="str(d, 'kind') === 'regression'" class="badge b-bad">{{ t('teamchat.regression') }}</span>
        <span v-else-if="str(d, 'kind') === 'new'" class="badge b-info">{{ t('teamchat.newFinding') }}</span>
      </p>
      <p v-if="str(d, 'route') || repos2.length" class="cc-meta hint">
        <span v-if="str(d, 'route')" class="mono">{{ str(d, 'route') }}</span>
        <span v-if="repos2.length">· {{ t('teamchat.repos') }}: {{ repos2.join(', ') }}</span>
        <span v-if="str(d, 'revision')">· <span class="mono">{{ str(d, 'revision').slice(0, 10) }}</span></span>
      </p>
      <pre v-if="str(d, 'mask')" class="cc-mask">{{ str(d, 'mask') }}</pre>
      <p v-if="str(d, 'remediation')" class="cc-text">{{ str(d, 'remediation') }}</p>
    </template>

    <!-- review_ready -->
    <template v-else-if="card.type === 'review_ready'">
      <p class="cc-meta">
        <RouterLink v-if="str(d, 'key')" class="cc-key" :to="{ name: 'ticket', params: { key: str(d, 'key') } }">{{ str(d, 'key') }}</RouterLink>
        <span v-if="str(d, 'repo')">{{ str(d, 'repo') }}</span>
        <span>· {{ t('teamchat.files', { n: num(d, 'files') ?? 0 }) }}</span>
        <span class="add">+{{ num(d, 'add') ?? 0 }}</span>
        <span class="del">−{{ num(d, 'del') ?? 0 }}</span>
        <span v-if="num(d, 'costUsd') !== undefined">· {{ usd(num(d, 'costUsd')) }}</span>
        <span v-if="num(d, 'reviewFindings')">· {{ t('teamchat.reviewFindings', { n: num(d, 'reviewFindings') ?? 0 }) }}</span>
      </p>
      <ul v-if="paths.length" class="cc-paths">
        <li v-for="p in paths.slice(0, 6)" :key="p" class="mono">{{ p }}</li>
        <li v-if="paths.length > 6" class="hint">{{ t('teamchat.more', { n: paths.length - 6 }) }}</li>
      </ul>
      <p v-if="open && str(d, 'approveDoes')" class="hint cc-text">{{ str(d, 'approveDoes') }}</p>
    </template>

    <!-- pr_opened -->
    <template v-else-if="card.type === 'pr_opened'">
      <p class="cc-meta">
        <a v-if="str(d, 'url')" class="cc-key" :href="str(d, 'url')" target="_blank" rel="noopener">#{{ num(d, 'number') }}</a>
        <span v-else class="cc-key">#{{ num(d, 'number') }}</span>
        <span>{{ str(d, 'repo') }}</span>
        <RouterLink v-if="str(d, 'key')" class="cc-key" :to="{ name: 'ticket', params: { key: str(d, 'key') } }">{{ str(d, 'key') }}</RouterLink>
      </p>
      <p class="cc-meta"><span class="badge" :class="ciTone">{{ ciLabel }}</span></p>
    </template>

    <!-- ticket_draft -->
    <template v-else-if="card.type === 'ticket_draft'">
      <div v-if="editing && open" class="cc-edit">
        <label>{{ t('teamchat.draftTitle') }}<input v-model="draft.title" maxlength="200"></label>
        <label>{{ t('teamchat.draftDescription') }}<textarea v-model="draft.description" rows="5" /></label>
        <label>{{ t('teamchat.draftRepo') }}
          <select v-model.number="draft.repoId">
            <option v-for="r in repoChoices" :key="r.id" :value="r.id">{{ r.name }}</option>
          </select>
        </label>
      </div>
      <template v-else>
        <p class="cc-dt">{{ draft.title }}</p>
        <p v-if="draft.description" class="cc-text">{{ draft.description }}</p>
        <p class="cc-meta hint">
          <span>{{ t('teamchat.draftRepo') }}: <b>{{ repoName(draft.repoId) || '—' }}</b></span>
          <span v-if="str(d, 'kind')">· {{ str(d, 'kind') }}</span>
        </p>
      </template>
      <ul v-if="acceptance.length" class="cc-acc">
        <li v-for="(a, i) in acceptance" :key="i">{{ a }}</li>
      </ul>
    </template>

    <!-- Links that are not actions -->
    <p class="cc-links">
      <RouterLink v-if="card.type === 'log_finding' && findingId" class="btn btn-s" :to="{ name: 'logFinding', params: { id: findingId } }">{{ t('teamchat.openFinding') }}</RouterLink>
      <RouterLink v-if="card.type === 'review_ready' && str(d, 'key')" class="btn btn-s" :to="{ name: 'ticket', params: { key: str(d, 'key') } }">{{ t('teamchat.viewDiff') }}</RouterLink>
      <a v-if="card.type === 'pr_opened' && str(d, 'url')" class="btn btn-s" :href="str(d, 'url')" target="_blank" rel="noopener">{{ t('teamchat.viewPr') }}</a>
      <RouterLink v-if="ticketKey && card.type !== 'review_ready'" class="btn btn-s" :to="{ name: 'ticket', params: { key: ticketKey } }">{{ ticketKey }}</RouterLink>
    </p>

    <template v-if="open && workspace.canEdit && card.actions.length">
      <div v-if="feedbackOpen" class="cc-fb">
        <textarea v-model="feedback" rows="3" maxlength="4000" :placeholder="t('teamchat.feedbackPlaceholder')" :aria-label="t('teamchat.feedbackPlaceholder')" />
      </div>
      <div class="cc-b">
        <button v-if="card.type === 'ticket_draft'" type="button" class="btn btn-s" :disabled="!!busy" @click="editing = !editing">
          {{ editing ? t('teamchat.draftDone') : t('teamchat.draftEdit') }}
        </button>
        <button v-if="feedbackOpen" type="button" class="btn btn-s" :disabled="!!busy" @click="feedbackOpen = false">{{ t('form.cancel') }}</button>
        <button
          v-for="a in card.actions"
          :key="a"
          type="button"
          class="btn btn-s"
          :class="{ 'btn-p': primary(a) && !danger(a), 'btn-danger': danger(a) }"
          :disabled="!!busy || (a === 'request_changes' && feedbackOpen && !feedback.trim()) || ((a === 'create' || a === 'create_assign') && !draft.title.trim())"
          @click="press(a)"
        >
          <span v-if="busy === a" class="spin" aria-hidden="true" />{{ a === 'request_changes' && feedbackOpen ? t('teamchat.sendFeedback') : t(`teamchat.act_${a}`) }}
        </button>
      </div>
    </template>
    <p v-else-if="!open" class="cc-res" :class="card.state">
      <b>{{ card.done || t(`teamchat.state_${card.state}`) }}</b>
      <span v-if="card.by"> · {{ t('teamchat.by', { name: card.by }) }}</span>
      <span v-if="card.result"> · {{ card.result }}</span>
    </p>
    <p v-if="error" class="ferr cc-err">{{ error }}</p>
  </div>
</template>

<style scoped>
.cc { margin-top: 2px; padding: 12px 14px; border: 1px solid var(--line); border-left: 4px solid var(--primary); border-radius: 12px; background: var(--surface); max-width: 640px; }
.cc.log_finding { border-left-color: var(--bad); }
.cc.review_ready { border-left-color: var(--warn); }
.cc.pr_opened { border-left-color: var(--ok); }
.cc.done, .cc.expired { border-left-color: var(--line-3); }
.cc.failed { border-left-color: var(--bad); }
.cc-h { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.cc-h .sp { flex: 1; }
.cc-t { font-size: 15px; }
.cc-sum, .cc-text { margin: 6px 0 0; white-space: pre-wrap; overflow-wrap: anywhere; }
.cc-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; margin: 6px 0 0; font-size: 13.5px; }
.cc-meta.hint { color: var(--ink-3); }
.cc-key { font-family: var(--mono); font-weight: 700; color: var(--primary-ink); }
.add { color: var(--ok-ink); font-weight: 700; }
.del { color: var(--bad-ink); font-weight: 700; }
.mono { font-family: var(--mono); }
.cc-mask { margin: 8px 0 0; padding: 8px 10px; border-radius: 8px; background: var(--code); color: var(--code-ink); font-family: var(--mono); font-size: 12.5px; white-space: pre-wrap; overflow-wrap: anywhere; max-height: 140px; overflow: auto; }
.cc-paths, .cc-acc { margin: 6px 0 0; padding-left: 18px; font-size: 13.5px; }
.cc-dt { margin: 6px 0 0; font-weight: 700; }
.cc-edit { display: flex; flex-direction: column; gap: 8px; margin-top: 8px; }
.cc-edit label { display: flex; flex-direction: column; gap: 4px; font-size: 13px; font-weight: 700; color: var(--ink-2); }
.cc-edit input, .cc-edit textarea, .cc-edit select, .cc-fb textarea { width: 100%; padding: 8px 10px; border: 1px solid var(--line-4); border-radius: 8px; background: var(--field); font-weight: 400; color: var(--ink); }
.cc-fb { margin-top: 8px; }
.cc-links { display: flex; flex-wrap: wrap; gap: 8px; margin: 10px 0 0; }
.cc-links:empty { display: none; }
.cc-b { display: flex; flex-wrap: wrap; gap: 8px; justify-content: flex-end; margin-top: 10px; }
.cc-res { margin: 10px 0 0; font-size: 14px; }
.cc-res.done b { color: var(--ok-ink); }
.cc-res.failed b { color: var(--bad-ink); }
.cc-res.expired b { color: var(--ink-3); }
.cc-err { margin: 8px 0 0; }
</style>
