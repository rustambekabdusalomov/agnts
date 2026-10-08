<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import { useSession } from '../../stores/session'
import { useUi } from '../../stores/ui'
import { useWorkspace } from '../../stores/workspace'
import CfgRow from '../form/CfgRow.vue'
import ConfirmDialog from '../ui/ConfirmDialog.vue'

const { t } = useI18n()
const router = useRouter()
const ui = useUi()
const session = useSession()
const workspace = useWorkspace()
const w = computed(() => workspace.detail)

const name = ref('')
const slug = ref('')
watch(w, (x) => {
  name.value = x?.name ?? ''
  slug.value = x?.slug ?? ''
}, { immediate: true })
const busy = ref(false)
const dirty = computed(() => !!w.value && (name.value.trim() !== w.value.name || slug.value.trim() !== w.value.slug))

async function save() {
  if (!w.value) return
  busy.value = true
  try {
    const out = await unwrap(api.PUT('/workspace', { body: {
      ...(name.value.trim() !== w.value.name ? { name: name.value.trim() } : {}),
      ...(slug.value.trim() !== w.value.slug ? { slug: slug.value.trim() } : {}),
    } }))
    await session.load()
    ui.notify(t('ws.saved'))
    if (out.slug !== workspace.slug) await router.replace(`/w/${out.slug}/workspace`)
    else await workspace.refresh()
  } catch (e) {
    ui.notify(e instanceof HttpError ? e.message : t('common.error'))
  } finally {
    busy.value = false
  }
}

const confirmDelete = ref(false)
const typed = ref('')
const deleting = ref(false)
async function remove() {
  deleting.value = true
  try {
    await unwrap(api.DELETE('/workspace', { body: { confirm: typed.value.trim() } }))
    ui.notify(t('ws.deleted'))
    confirmDelete.value = false
    workspace.reset()
    await session.load()
    await router.replace('/')
  } catch (e) {
    ui.notify(e instanceof HttpError ? e.message : t('common.error'))
  } finally {
    deleting.value = false
  }
}
const fmt = (s?: string) => (s ? new Date(s).toLocaleDateString() : '')
</script>

<template>
  <div v-if="w" class="stack">
    <section class="card">
      <div class="ch"><div><h2>{{ t('ws.general') }}</h2><p class="sub">{{ workspace.isOwner ? t('ws.generalSub') : t('ws.readOnly') }}</p></div></div>
      <CfgRow :label="t('ws.name')">
        <input v-model="name" class="cfg-in" maxlength="80" :disabled="!workspace.isOwner" :aria-label="t('ws.name')">
      </CfgRow>
      <CfgRow :label="t('ws.slug')" :help="t('ws.slugHelp', { slug: slug || w.slug })">
        <input v-model="slug" class="cfg-in mono" maxlength="40" :disabled="!workspace.isOwner" :aria-label="t('ws.slug')">
      </CfgRow>
      <CfgRow :label="t('ws.plan')" :help="w.trialEndsAt ? t('ws.trialEnds', { date: fmt(w.trialEndsAt) }) : ''">
        <span class="badge b-info">{{ w.plan }}</span>
      </CfgRow>
      <CfgRow :label="t('ws.slots')" :help="t('ws.slotsHelp')">
        <span class="mono">{{ w.slots }}</span>
      </CfgRow>
      <div v-if="workspace.isOwner" class="row-actions" style="margin-top: 12px">
        <button class="btn btn-p btn-s" :disabled="!dirty || busy" @click="save">{{ t('ws.save') }}</button>
      </div>
    </section>

    <section v-if="workspace.isOwner" class="card">
      <div class="ch"><div><h2>{{ t('ws.danger') }}</h2><p class="sub">{{ t('ws.dangerSub') }}</p></div></div>
      <div class="row-actions" style="justify-content: flex-start">
        <button class="btn btn-s btn-d" @click="confirmDelete = true">{{ t('ws.delete') }}</button>
      </div>
    </section>
    <ConfirmDialog
      v-model="confirmDelete" :title="t('ws.deleteTitle', { name: w.name })" :message="t('ws.deleteBody', { slug: w.slug })"
      :confirm-label="t('ws.delete')" danger :busy="deleting" @confirm="remove"
    >
      <input v-model="typed" class="cfg-in mono" :placeholder="w.slug" :aria-label="t('ws.slug')" style="width: 100%; margin-top: 12px">
    </ConfirmDialog>
  </div>
</template>
