<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import type { Rule } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import InputSelect from '../components/form/InputSelect.vue'
import { useRepos } from '../components/repos/useRepos'
import RuleCard from '../components/rules/RuleCard.vue'
import RuleDrawer from '../components/rules/RuleDrawer.vue'
import { useRules } from '../components/rules/useRules'
import HiIcon from '../components/ui/HiIcon.vue'
import { useLive } from '../composables/useLive'
import { useUi } from '../stores/ui'

// Global and per-repository rules. The scope filter lives in the URL
// (?scope=global or ?scope=<repo id>) so a repository's rules can be linked.
const { t } = useI18n()
const ui = useUi()
const route = useRoute()
const router = useRouter()
const repos = useRepos()
const rules = useRules()
useLive()

type Scope = 'all' | 'global' | number
const scope = computed<Scope>({
  get: () => {
    const s = String(route.query.scope ?? '')
    return s === 'global' ? 'global' : /^\d+$/.test(s) ? Number(s) : 'all'
  },
  set: (v) => void router.replace({ query: { ...route.query, scope: v === 'all' ? undefined : String(v) } }),
})
const all = computed(() => rules.data.value ?? [])
const scopeOptions = computed(() => [
  { value: 'all' as Scope, label: t('rules.scopeAll', { n: all.value.length }) },
  { value: 'global' as Scope, label: t('rules.scopeGlobal', { n: all.value.filter((r) => !r.repoId).length }) },
  ...(repos.data.value ?? []).map((r) => ({ value: r.id as Scope, label: `${r.name} (${all.value.filter((x) => x.repoId === r.id).length})` })),
])

// Rules that need you first, then failed reviews, then the rest in order.
const rank = (r: Rule) => (r.status === 'questions' ? 0 : r.status === 'failed' ? 1 : 2)
const rows = computed(() => {
  const q = ui.search.trim().toLowerCase()
  return all.value
    .filter((r) => scope.value === 'all' || (scope.value === 'global' ? !r.repoId : r.repoId === scope.value))
    .filter((r) => !q || [r.title, r.body, r.repoName ?? ''].some((s) => s.toLowerCase().includes(q)))
    .map((r, i) => ({ r, i }))
    .sort((a, b) => rank(a.r) - rank(b.r) || a.i - b.i)
    .map(({ r }) => r)
})
const waiting = computed(() => all.value.filter((r) => r.status === 'questions').length)

const drawerOpen = ref(false)
const editing = ref<Rule | null>(null)
function openRule(r: Rule | null) {
  editing.value = r
  drawerOpen.value = true
}
const presetRepo = computed(() => (typeof scope.value === 'number' ? scope.value : undefined))
</script>

<template>
  <PageHeader :title="t('rules.title')" :lede="t('rules.lede')" doc="rules">
    <div class="actions" style="margin: 0">
      <button class="btn btn-p" type="button" @click="openRule(null)"><HiIcon name="plus" />{{ t('rules.add') }}</button>
    </div>
  </PageHeader>

  <div v-if="waiting" class="help warn"><HiIcon name="info" /><p>{{ t('rules.waitingHelp', { n: waiting }) }}</p></div>

  <div v-if="all.length" class="rules-bar">
    <InputSelect v-model="scope" :options="scopeOptions" :label="t('rules.scopeLabel')" style="width: 280px; max-width: 100%" />
  </div>

  <p v-if="rules.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="rules.isError.value" class="ferr">{{ t('common.error') }}</p>
  <section v-else-if="!all.length" class="card">
    <p class="empty">{{ t('rules.none') }}</p>
  </section>
  <section v-else-if="!rows.length" class="card">
    <p class="empty">{{ t('rules.noMatch') }}</p>
  </section>
  <RuleCard v-for="r in rows" v-else :key="r.id" :rule="r" @edit="openRule" />

  <RuleDrawer v-model="drawerOpen" :rule="editing" :repo-id="presetRepo" />
</template>

<style scoped>
.rules-bar { display: flex; gap: 10px; margin: 0 0 14px; flex-wrap: wrap; }
</style>
