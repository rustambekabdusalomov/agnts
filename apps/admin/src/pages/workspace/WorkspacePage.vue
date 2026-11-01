<script setup lang="ts">
import { computed, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import PageHeader from '../../components/PageHeader.vue'
import BillingTab from '../../components/workspace/BillingTab.vue'
import ClaudeTab from '../../components/workspace/ClaudeTab.vue'
import GeneralTab from '../../components/workspace/GeneralTab.vue'
import MembersTab from '../../components/workspace/MembersTab.vue'
import { useWorkspace } from '../../stores/workspace'

// Workspace settings: General, Members, Claude and (for the owner) Billing.
const { t } = useI18n()
const route = useRoute()
const router = useRouter()
const workspace = useWorkspace()

type Tab = 'general' | 'members' | 'ai' | 'billing'
const tabs = computed<Tab[]>(() => (workspace.isOwner ? ['general', 'members', 'ai', 'billing'] : ['general', 'members', 'ai']))
// AI accounts was the Claude tab (?tab=claude): old links still open it.
const tab = computed<Tab>(() => {
  const raw = String(route.query.tab ?? 'general')
  const q = (raw === 'claude' ? 'ai' : raw) as Tab
  return tabs.value.includes(q) ? q : 'general'
})
watch(() => route.query.tab, (q) => { if (q === 'claude') void router.replace({ query: { ...route.query, tab: 'ai' } }) }, { immediate: true })
const label: Record<Tab, string> = { general: 'ws.tabGeneral', members: 'ws.tabMembers', ai: 'ws.tabAi', billing: 'ws.tabBilling' }
function open(t: Tab) {
  void router.replace({ query: { ...route.query, tab: t } })
}
</script>

<template>
  <PageHeader :title="workspace.name">
    <template #below>
      <p class="sub" style="margin: 2px 0 0">
        {{ t(`ws.role_${workspace.detail?.role ?? 'user'}`) }} · /w/{{ workspace.slug }}
      </p>
    </template>
  </PageHeader>
  <p v-if="workspace.detail?.suspended" class="login-err" style="margin-bottom: 16px">{{ t('ws.suspended') }}</p>
  <div class="page-tabs" role="tablist">
    <button v-for="x in tabs" :key="x" type="button" role="tab" class="page-tab" :aria-selected="tab === x" @click="open(x)">{{ t(label[x]) }}</button>
  </div>
  <GeneralTab v-if="tab === 'general'" />
  <MembersTab v-else-if="tab === 'members'" />
  <ClaudeTab v-else-if="tab === 'ai'" />
  <BillingTab v-else-if="tab === 'billing'" />
</template>
