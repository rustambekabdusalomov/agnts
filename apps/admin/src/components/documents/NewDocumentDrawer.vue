<script setup lang="ts">
import { useMutation, useQuery } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import type { DocumentSource, TicketState } from '../../api/types'
import CheckBox from '../form/CheckBox.vue'
import FormDrawer from '../form/FormDrawer.vue'
import InputSelect from '../form/InputSelect.vue'
import SegButtons from '../form/SegButtons.vue'
import { TEMPLATES, useDocumentsRefresh } from './useDocuments'

// A new document: written by hand, or by agnts from a ticket's report,
// tickets, commits, pull requests or a whole repository. Opened from a
// ticket, it links the ticket and starts from its report. People know
// tickets by their number, so that is what the form shows (the key when
// there is none); the server takes either.
const props = defineProps<{ ticketKey?: string; ticketNumber?: string }>()
const open = defineModel<boolean>({ default: false })
const { t, locale } = useI18n()
const router = useRouter()
const refresh = useDocumentsRefresh()

type Kind = DocumentSource['kind']
type Template = NonNullable<DocumentSource['template']>
const form = reactive({
  title: '',
  language: 'en' as 'en' | 'ru' | 'uz',
  by: 'agnts' as 'me' | 'agnts',
  kind: 'tickets' as Kind,
  template: 'status' as Template,
  instruction: '',
  tickets: '',
  ticketsBy: 'filter' as 'chosen' | 'filter',
  states: [] as TicketState[],
  repoIds: [] as number[],
  repoId: 0,
  branch: '',
  author: '',
  prState: 'merged' as 'open' | 'merged' | 'all',
  prNumbers: '',
  from: '',
  to: '',
})
const error = ref('')

const repos = useQuery({ queryKey: ['repos'], queryFn: () => unwrap(api.GET('/repos')), enabled: open })
const repoOptions = computed(() => (repos.data.value ?? []).filter((r) => !r.archivedAt).map((r) => ({ value: r.id, label: r.name })))

watch(open, (v) => {
  if (!v) return
  error.value = ''
  form.language = (['en', 'ru', 'uz'].includes(locale.value) ? locale.value : 'en') as typeof form.language
  if (props.ticketKey) {
    form.kind = 'report'
    form.tickets = props.ticketNumber || props.ticketKey
  }
})
watch(() => form.kind, (k) => (form.template = TEMPLATES[k][0]), { immediate: false })

const kinds = computed(() => (['report', 'tickets', 'commits', 'pulls', 'repo'] as Kind[]).map((k) => ({ value: k, label: t(`documents.kind_${k}`) })))
const templates = computed(() => TEMPLATES[form.kind].map((x) => ({ value: x, label: t(`documents.template_${x}`), hint: t(`documents.templateHint_${x}`) })))
const stateChoices: TicketState[] = ['new', 'analyzing', 'waiting_for_answers', 'coding', 'waiting_for_review', 'done', 'rejected', 'failed']
const keys = (s: string) => s.split(/[\s,]+/).map((x) => x.trim()).filter(Boolean)
const day = (s: string, end = false) => (s ? new Date(`${s}T${end ? '23:59:59' : '00:00:00'}`).toISOString() : undefined)

function toggle<T>(list: T[], v: T, on: boolean) {
  const i = list.indexOf(v)
  if (on && i < 0) list.push(v)
  if (!on && i >= 0) list.splice(i, 1)
}

function source(): DocumentSource {
  const s: DocumentSource = { kind: form.kind, template: form.template, instruction: form.instruction.trim() || undefined }
  switch (form.kind) {
    case 'report':
      s.tickets = keys(form.tickets).slice(0, 1)
      break
    case 'tickets':
      if (form.ticketsBy === 'chosen') s.tickets = keys(form.tickets)
      else s.filter = { states: form.states.length ? form.states : undefined }
      s.from = day(form.from)
      s.to = day(form.to, true)
      break
    case 'commits':
      s.repoIds = form.repoIds
      s.branch = form.branch.trim() || undefined
      s.author = form.author.trim() || undefined
      s.from = day(form.from)
      s.to = day(form.to, true)
      break
    case 'pulls':
      s.repoIds = form.repoIds
      s.prState = form.prState
      s.prNumbers = keys(form.prNumbers).map(Number).filter((n) => n > 0)
      if (!s.prNumbers.length) s.prNumbers = undefined
      s.from = day(form.from)
      s.to = day(form.to, true)
      break
    case 'repo':
      s.repoIds = form.repoId ? [form.repoId] : []
      s.branch = form.branch.trim() || undefined
      break
  }
  return s
}

const create = useMutation({
  mutationFn: () =>
    unwrap(
      api.POST('/documents', {
        body: {
          title: form.title.trim(),
          language: form.language,
          body: form.by === 'me' ? '' : undefined,
          source: form.by === 'agnts' ? source() : undefined,
          linkTickets: props.ticketKey && !(form.by === 'agnts' && form.kind === 'report') ? [props.ticketKey] : undefined,
        },
      }),
    ),
  onSuccess: async (d) => {
    refresh(d.id)
    open.value = false
    await router.push({ name: 'document', params: { id: d.id }, query: form.by === 'me' ? { edit: '1' } : {} })
  },
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})
const canSubmit = computed(() => form.title.trim().length > 0 && !create.isPending.value)
</script>

<template>
  <FormDrawer
    v-model="open"
    :title="t('documents.newTitle')"
    :subtitle="ticketKey ? t('documents.newForTicket', { number: ticketNumber || ticketKey }) : t('documents.newSub')"
  >
    <div class="field">
      <label for="nd-title">{{ t('documents.title') }}</label>
      <input id="nd-title" v-model="form.title" type="text" maxlength="200" :placeholder="t('documents.titlePlaceholder')">
    </div>
    <div class="field">
      <span class="flbl">{{ t('documents.whoWrites') }}</span>
      <SegButtons v-model="form.by" :options="[{ value: 'agnts', label: t('documents.byAgnts') }, { value: 'me', label: t('documents.byMe') }]" :label="t('documents.whoWrites')" />
    </div>
    <div class="field">
      <span class="flbl">{{ t('documents.language') }}</span>
      <SegButtons v-model="form.language" :options="[{ value: 'en', label: 'English' }, { value: 'ru', label: 'Русский' }, { value: 'uz', label: 'Oʻzbekcha' }]" :label="t('documents.language')" />
    </div>

    <template v-if="form.by === 'agnts'">
      <div class="field">
        <span class="flbl">{{ t('documents.source') }}</span>
        <SegButtons v-model="form.kind" :options="kinds" :label="t('documents.source')" />
        <span class="fhelp">{{ t(`documents.kindHelp_${form.kind}`) }}</span>
      </div>

      <div v-if="form.kind === 'report'" class="field">
        <label for="nd-ticket">{{ t('documents.ticket') }}</label>
        <input id="nd-ticket" v-model="form.tickets" type="text" placeholder="AMANAT-12">
      </div>

      <template v-if="form.kind === 'tickets'">
        <div class="field">
          <SegButtons v-model="form.ticketsBy" :options="[{ value: 'filter', label: t('documents.byFilter') }, { value: 'chosen', label: t('documents.chosen') }]" :label="t('documents.source')" />
        </div>
        <div v-if="form.ticketsBy === 'chosen'" class="field">
          <label for="nd-tickets">{{ t('documents.tickets') }}</label>
          <textarea id="nd-tickets" v-model="form.tickets" rows="3" :placeholder="t('documents.ticketsPlaceholder')" />
        </div>
        <div v-else class="field">
          <span class="flbl">{{ t('documents.states') }}</span>
          <div class="nd-checks">
            <CheckBox v-for="st in stateChoices" :key="st" :model-value="form.states.includes(st)" @update:model-value="(on) => toggle(form.states, st, on)">
              {{ t(`state.${st}`) }}
            </CheckBox>
          </div>
          <span class="fhelp">{{ t('documents.statesHelp') }}</span>
        </div>
      </template>

      <div v-if="form.kind === 'commits' || form.kind === 'pulls'" class="field">
        <span class="flbl">{{ t('documents.repos') }}</span>
        <div class="nd-checks">
          <CheckBox v-for="r in repoOptions" :key="r.value" :model-value="form.repoIds.includes(r.value)" @update:model-value="(on) => toggle(form.repoIds, r.value, on)">
            {{ r.label }}
          </CheckBox>
        </div>
      </div>
      <InputSelect v-if="form.kind === 'repo'" v-model="form.repoId" :options="repoOptions" :label="t('documents.repo')" :placeholder="t('documents.chooseRepo')" />
      <div v-if="form.kind === 'commits' || form.kind === 'repo'" class="field">
        <label for="nd-branch">{{ t('documents.branch') }}</label>
        <input id="nd-branch" v-model="form.branch" type="text" :placeholder="t('documents.branchPlaceholder')">
      </div>
      <div v-if="form.kind === 'commits'" class="field">
        <label for="nd-author">{{ t('documents.author') }}</label>
        <input id="nd-author" v-model="form.author" type="text" :placeholder="t('documents.authorPlaceholder')">
      </div>
      <template v-if="form.kind === 'pulls'">
        <div class="field">
          <span class="flbl">{{ t('documents.prState') }}</span>
          <SegButtons v-model="form.prState" :options="[{ value: 'merged', label: t('documents.pr_merged') }, { value: 'open', label: t('documents.pr_open') }, { value: 'all', label: t('documents.pr_all') }]" :label="t('documents.prState')" />
        </div>
        <div class="field">
          <label for="nd-prs">{{ t('documents.prNumbers') }}</label>
          <input id="nd-prs" v-model="form.prNumbers" type="text" placeholder="41, 42">
          <span class="fhelp">{{ t('documents.prNumbersHelp') }}</span>
        </div>
      </template>
      <div v-if="form.kind === 'tickets' || form.kind === 'commits' || form.kind === 'pulls'" class="nd-period">
        <div class="field">
          <label for="nd-from">{{ t('documents.from') }}</label>
          <input id="nd-from" v-model="form.from" class="cfg-in" type="date">
        </div>
        <div class="field">
          <label for="nd-to">{{ t('documents.to') }}</label>
          <input id="nd-to" v-model="form.to" class="cfg-in" type="date">
        </div>
      </div>

      <InputSelect v-model="form.template" :options="templates" :label="t('documents.template')" />
      <div class="field">
        <label for="nd-ins">{{ t('documents.instruction') }}</label>
        <textarea id="nd-ins" v-model="form.instruction" rows="3" maxlength="2000" :placeholder="t('documents.instructionPlaceholder')" />
      </div>
    </template>
    <span v-if="error" class="ferr" role="alert">{{ error }}</span>

    <template #footer>
      <button type="button" class="btn" @click="open = false">{{ t('form.cancel') }}</button>
      <button type="button" class="btn btn-p" :disabled="!canSubmit" @click="create.mutate()">
        {{ form.by === 'agnts' ? t('documents.generate') : t('documents.create') }}
      </button>
    </template>
  </FormDrawer>
</template>

<style scoped>
.nd-checks { display: flex; flex-wrap: wrap; gap: 8px 16px; }
.nd-period { display: flex; gap: 12px; flex-wrap: wrap; }
.nd-period .cfg-in { width: 180px; }
textarea { border: 1px solid var(--line-3); border-radius: 9px; padding: 10px 12px; font: inherit; background: var(--surface); resize: vertical; }
</style>
