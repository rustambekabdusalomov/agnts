<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { CIWatch, Repository } from '../../api/types'
import { useWorkspace } from '../../stores/workspace'
import { useUi } from '../../stores/ui'
import { CI_FILTERS, lines, type CiFilter } from '../ci/ci'
import CiFailureList from '../ci/CiFailureList.vue'
import CiFilterTabs from '../ci/CiFilterTabs.vue'
import CfgRow from '../form/CfgRow.vue'
import SegButtons from '../form/SegButtons.vue'
import SwitchToggle from '../form/SwitchToggle.vue'
import HiIcon from '../ui/HiIcon.vue'

// The repository's CI watching: which branches and jobs agnts watches,
// what it does on other people's pull requests and whether it opens
// tickets by itself; then what fails here and the flaky tests.
const props = defineProps<{ repo: Repository }>()
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const workspace = useWorkspace()
const id = computed(() => props.repo.id)

type AutoFix = 'inherit' | 'on' | 'off'
type Prs = 'off' | 'comment'
interface Form { enabled: boolean; branches: string; ignore: string; prs: Prs; autoFix: AutoFix }

const watchQ = useQuery({
  queryKey: computed(() => ['ci-watch', id.value]),
  queryFn: () => unwrap(api.GET('/repos/{id}/ci-watch', { params: { path: { id: id.value } } })),
})
const toForm = (w: CIWatch): Form => ({
  enabled: w.enabled,
  branches: w.branches.join('\n'),
  ignore: w.ignore.join('\n'),
  prs: w.prs === 'comment' ? 'comment' : 'off',
  autoFix: w.autoFix == null ? 'inherit' : w.autoFix ? 'on' : 'off',
})
const form = reactive<Form>({ enabled: false, branches: '', ignore: '', prs: 'off', autoFix: 'inherit' })
const saved = ref('')
const dirty = computed(() => JSON.stringify(form) !== saved.value)
// Take the server's values unless the form has edits against the old ones.
watch(
  () => watchQ.data.value,
  (w) => {
    if (!w || (saved.value && dirty.value)) return
    Object.assign(form, toForm(w))
    saved.value = JSON.stringify(form)
  },
  { immediate: true },
)

const save = useMutation({
  mutationFn: () =>
    unwrap(
      api.PUT('/repos/{id}/ci-watch', {
        params: { path: { id: id.value } },
        body: {
          enabled: form.enabled,
          branches: lines(form.branches),
          ignore: lines(form.ignore),
          prs: form.prs,
          autoFix: form.autoFix === 'inherit' ? null : form.autoFix === 'on',
        },
      }),
    ),
  onSuccess: (w) => {
    qc.setQueryData(['ci-watch', id.value], w)
    Object.assign(form, toForm(w))
    saved.value = JSON.stringify(form)
    ui.notify(t('ci.watchSaved'))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

const prsOptions = computed(() => (['off', 'comment'] as const).map((v) => ({ value: v, label: t(`ci.prs_${v}`) })))
const autoFixOptions = computed(() => (['inherit', 'on', 'off'] as const).map((v) => ({ value: v, label: t(`ci.autoFix_${v}`) })))

const filter = ref<CiFilter>('red')
const statuses = computed(() => CI_FILTERS.find((f) => f.id === filter.value)?.statuses ?? [])
</script>

<template>
  <section class="card">
    <div class="ch"><div><h2>{{ t('ci.watchTitle') }}</h2><p class="sub">{{ t('ci.watchSub') }}</p></div></div>
    <p v-if="watchQ.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="watchQ.isError.value" class="ferr">{{ t('common.error') }}</p>
    <template v-else>
      <div v-if="watchQ.data.value?.problem" class="help warn" style="margin-bottom: 12px">
        <HiIcon name="info" /><p>{{ watchQ.data.value.problem }}</p>
      </div>
      <fieldset class="ro-fs" :disabled="!workspace.canEdit || save.isPending.value">
        <CfgRow :label="t('ci.watchEnabled')" :help="t('ci.watchEnabledHelp')">
          <SwitchToggle v-model="form.enabled" :label="t('ci.watchEnabled')" />
        </CfgRow>
        <CfgRow :label="t('ci.branches')" :help="t('ci.branchesHelp', { branch: repo.defaultBranch })">
          <textarea v-model="form.branches" class="ci-globs" rows="3" maxlength="4000" placeholder="release/*" :aria-label="t('ci.branches')" />
        </CfgRow>
        <CfgRow :label="t('ci.ignore')" :help="t('ci.ignoreHelp')">
          <textarea v-model="form.ignore" class="ci-globs" rows="3" maxlength="4000" :placeholder="'*deploy*\n*release*\n*publish*'" :aria-label="t('ci.ignore')" />
        </CfgRow>
        <CfgRow :label="t('ci.prs')" :help="t('ci.prsHelp')">
          <SegButtons v-model="form.prs" :options="prsOptions" :label="t('ci.prs')" />
        </CfgRow>
        <CfgRow :label="t('ci.autoFix')" :help="t('ci.autoFixRepoHelp')">
          <SegButtons v-model="form.autoFix" :options="autoFixOptions" :label="t('ci.autoFix')" />
        </CfgRow>
        <div class="actions" style="margin: 12px 0 0">
          <button type="button" class="btn btn-p" :disabled="!dirty || save.isPending.value" @click="save.mutate()">
            <span v-if="save.isPending.value" class="spin" aria-hidden="true" />{{ t('ci.save') }}
          </button>
        </div>
      </fieldset>
    </template>
  </section>

  <section class="card">
    <div class="ch"><div><h2>{{ t('ci.failuresTitle') }}</h2><p class="sub">{{ t('ci.failuresSub') }}</p></div></div>
    <div class="filters"><CiFilterTabs v-model="filter" /></div>
    <CiFailureList :repo-id="id" :statuses="statuses" :show-repo="false" />
  </section>

  <section class="card">
    <div class="ch"><div><h2>{{ t('ci.flakyTitle') }}</h2><p class="sub">{{ t('ci.flakySub') }}</p></div></div>
    <CiFailureList :repo-id="id" :statuses="['flaky']" :show-repo="false">
      <template #empty>{{ t('ci.flakyEmpty') }}</template>
    </CiFailureList>
  </section>
</template>

<style scoped>
.ci-globs { width: min(320px, 100%); min-height: 84px; font-family: var(--mono); font-size: 13px; }
</style>
