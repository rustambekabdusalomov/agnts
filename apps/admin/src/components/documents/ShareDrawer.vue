<script setup lang="ts">
import { useMutation, useQuery } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { components } from '../../api/schema.gen'
import type { Document } from '../../api/types'
import CopyField from '../form/CopyField.vue'
import FormDrawer from '../form/FormDrawer.vue'
import InputSelect from '../form/InputSelect.vue'
import SegButtons from '../form/SegButtons.vue'
import { useDocumentsRefresh } from './useDocuments'

type Findings = components['schemas']['SecretFindings']['findings']
type Level = 'view' | 'edit'

// Who can open a document: its type (a public link for anyone), the
// workspace default, and members one by one. Only the owner changes it;
// workspace viewers can only be given view.
const props = defineProps<{ doc: Document }>()
const open = defineModel<boolean>({ default: false })
const { t } = useI18n()
const refresh = useDocumentsRefresh()

const sharing = useQuery({
  queryKey: computed(() => ['document-sharing', String(props.doc.id)]),
  queryFn: () => unwrap(api.GET('/documents/{id}/sharing', { params: { path: { id: props.doc.id } } })),
  enabled: open,
})
const members = useQuery({ queryKey: ['members'], queryFn: () => unwrap(api.GET('/workspace/members')), enabled: open })

const draft = reactive({ type: 'private' as 'private' | 'public', workspaceAccess: 'none' as 'none' | Level, grants: [] as { userId: number; level: Level }[] })
const findings = ref<Findings>([])
const error = ref('')
const adding = ref<number | undefined>(undefined)

watch(
  () => sharing.data.value,
  (s) => {
    if (!s) return
    draft.type = s.type
    draft.workspaceAccess = s.workspaceAccess
    draft.grants = s.grants.map((g) => ({ userId: g.userId, level: g.level }))
  },
  { immediate: true },
)
watch(open, (v) => {
  if (v) {
    findings.value = []
    error.value = ''
  }
})

const roleOf = (id: number) => members.data.value?.find((m) => m.userId === id)?.role
const nameOf = (id: number) => {
  const m = members.data.value?.find((x) => x.userId === id)
  return m ? m.displayName || m.username : `#${id}`
}
const addable = computed(() =>
  (members.data.value ?? [])
    .filter((m) => m.userId !== props.doc.ownerId && !draft.grants.some((g) => g.userId === m.userId) && m.role !== 'owner')
    .map((m) => ({ value: m.userId, label: m.displayName || m.username, hint: t(`documents.role_${m.role}`) })),
)
function add(id: number | undefined) {
  if (!id) return
  draft.grants.push({ userId: id, level: 'view' })
  adding.value = undefined
}
const levelOptions = (id: number) =>
  roleOf(id) === 'viewer' ? [{ value: 'view' as Level, label: t('documents.access_view') }] : [{ value: 'view' as Level, label: t('documents.access_view') }, { value: 'edit' as Level, label: t('documents.access_edit') }]

const save = useMutation({
  mutationFn: async () => {
    const { data, error: body, response } = await api.PUT('/documents/{id}/sharing', { params: { path: { id: props.doc.id } }, body: { ...draft } })
    if (response.status === 422) findings.value = (body as { findings?: Findings } | undefined)?.findings ?? []
    if (!response.ok) throw new HttpError(response.status, body as { code?: string; message?: string } | undefined)
    return data
  },
  onSuccess: () => {
    findings.value = []
    error.value = ''
    refresh(props.doc.id)
  },
  onError: (e) => {
    if (e instanceof HttpError && e.status === 422) {
      draft.type = 'private' // nothing was saved; fix the text first
      return
    }
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})
const reset = useMutation({
  mutationFn: () => unwrap(api.POST('/documents/{id}/reset-link', { params: { path: { id: props.doc.id } } })),
  onSuccess: () => refresh(props.doc.id),
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})

const transferTo = ref<number | undefined>(undefined)
const transferOptions = computed(() =>
  (members.data.value ?? []).filter((m) => m.userId !== props.doc.ownerId).map((m) => ({ value: m.userId, label: m.displayName || m.username })),
)
const transfer = useMutation({
  mutationFn: (to: number) => unwrap(api.PUT('/documents/{id}/owner', { params: { path: { id: props.doc.id } }, body: { userId: to } })),
  onSuccess: () => {
    transferTo.value = undefined
    refresh(props.doc.id)
    open.value = false
  },
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})
function confirmTransfer() {
  if (transferTo.value && window.confirm(t('documents.transferConfirm', { name: nameOf(transferTo.value) }))) transfer.mutate(transferTo.value)
}
</script>

<template>
  <FormDrawer v-model="open" :title="t('documents.shareTitle')" :subtitle="doc.title">
    <p v-if="sharing.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <template v-else-if="sharing.data.value">
      <div class="field">
        <span class="flbl">{{ t('documents.type') }}</span>
        <SegButtons
          v-model="draft.type"
          :options="[{ value: 'private', label: t('documents.private') }, { value: 'public', label: t('documents.public') }]"
          :label="t('documents.type')"
        />
        <span class="fhelp">{{ draft.type === 'public' ? t('documents.publicHelp') : t('documents.privateHelp') }}</span>
        <span v-if="!sharing.data.value.publicAllowed" class="fhelp bad-ink">{{ t('documents.publicOff') }}</span>
      </div>
      <div v-if="findings.length" class="help bad" role="alert">
        <div>
          <p><b>{{ t('documents.secretsTitle') }}</b></p>
          <p>{{ t('documents.secretsHelp') }}</p>
          <ul class="sd-find">
            <li v-for="f in findings" :key="f.line"><span class="tkey">{{ t('documents.line', { n: f.line }) }}</span> <code>{{ f.excerpt }}</code></li>
          </ul>
        </div>
      </div>
      <div v-if="sharing.data.value.publicUrl" class="sd-link">
        <CopyField :value="sharing.data.value.publicUrl" :label="t('documents.publicLink')" />
        <button type="button" class="btn btn-s" :disabled="reset.isPending.value" @click="reset.mutate()">{{ t('documents.resetLink') }}</button>
        <span class="fhelp">{{ t('documents.resetHelp') }}</span>
      </div>

      <div class="field">
        <span class="flbl">{{ t('documents.workspaceAccess') }}</span>
        <SegButtons
          v-model="draft.workspaceAccess"
          :options="[{ value: 'none', label: t('documents.access_none') }, { value: 'view', label: t('documents.access_view') }, { value: 'edit', label: t('documents.access_edit') }]"
          :label="t('documents.workspaceAccess')"
        />
        <span class="fhelp">{{ t('documents.workspaceAccessHelp') }}</span>
      </div>

      <div class="field">
        <span class="flbl">{{ t('documents.people') }}</span>
        <ul class="sd-people">
          <li>
            <span>{{ nameOf(doc.ownerId) }}</span><span class="badge b-info">{{ t('documents.access_owner') }}</span>
          </li>
          <li v-for="(g, i) in draft.grants" :key="g.userId">
            <span>{{ nameOf(g.userId) }} <span v-if="roleOf(g.userId) === 'viewer'" class="tkey">{{ t('documents.role_viewer') }}</span></span>
            <span class="sd-row">
              <SegButtons v-model="g.level" :options="levelOptions(g.userId)" :label="nameOf(g.userId)" />
              <button type="button" class="btn btn-s btn-d" @click="draft.grants.splice(i, 1)">{{ t('documents.remove') }}</button>
            </span>
          </li>
        </ul>
        <InputSelect
          v-if="addable.length"
          :model-value="adding"
          :options="addable"
          :label="t('documents.addPerson')"
          :placeholder="t('documents.addPerson')"
          @update:model-value="add"
        />
        <span class="fhelp">{{ t('documents.ownerNote') }}</span>
      </div>
      <span v-if="error" class="ferr" role="alert">{{ error }}</span>

      <details class="sd-transfer">
        <summary>{{ t('documents.transfer') }}</summary>
        <div class="sd-row" style="margin-top: 10px">
          <InputSelect v-model="transferTo" :options="transferOptions" :label="t('documents.transferTo')" :placeholder="t('documents.transferTo')" />
          <button type="button" class="btn" :disabled="!transferTo || transfer.isPending.value" @click="confirmTransfer">{{ t('documents.transfer') }}</button>
        </div>
      </details>
    </template>
    <template #footer>
      <button type="button" class="btn" @click="open = false">{{ t('form.close') }}</button>
      <button type="button" class="btn btn-p" :disabled="save.isPending.value" @click="save.mutate()">{{ t('documents.saveSharing') }}</button>
    </template>
  </FormDrawer>
</template>

<style scoped>
.sd-people { list-style: none; margin: 0 0 8px; padding: 0; display: flex; flex-direction: column; gap: 8px; }
.sd-people li { display: flex; justify-content: space-between; align-items: center; gap: 10px; flex-wrap: wrap; }
.sd-row { display: inline-flex; gap: 8px; align-items: center; flex-wrap: wrap; }
.sd-link { display: flex; flex-direction: column; gap: 8px; }
.sd-find { margin: 6px 0 0; padding-left: 18px; }
.sd-find code { word-break: break-all; }
.bad-ink { color: var(--bad-ink); }
</style>
