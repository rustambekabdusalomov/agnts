<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Repository, RepositoryInput } from '../../api/types'
import { useUi } from '../../stores/ui'
import FormDrawer from '../form/FormDrawer.vue'

// Add or edit a repository. `repo` null means a new one, prefilled from
// `preset` (a repository picked for import). Every repository takes
// side-project tasks; a Jira project key makes it take Jira tickets too.
const props = defineProps<{
  repo: Repository | null
  preset?: Pick<Repository, 'name' | 'cloneUrl' | 'defaultBranch'> | null
}>()
const open = defineModel<boolean>({ default: false })
const emit = defineEmits<{ saved: [repo: Repository] }>()
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()

const form = reactive({
  name: '',
  cloneUrl: '',
  jiraProject: '',
  taskPrefix: '',
  defaultBranch: 'main',
  buildCmd: '',
  lintCmd: '',
  testCmd: '',
  instructions: '',
  deployWorkflow: '',
})
const error = ref('')

watch(
  open,
  (v) => {
    if (!v) return
    const r = props.repo
    const p = r ? null : props.preset
    error.value = ''
    Object.assign(form, {
      name: r?.name ?? p?.name ?? '',
      cloneUrl: r?.cloneUrl ?? p?.cloneUrl ?? '',
      jiraProject: r?.jiraProject ?? '',
      taskPrefix: r?.taskPrefix ?? '',
      defaultBranch: r?.defaultBranch ?? (p?.defaultBranch || 'main'),
      buildCmd: r?.buildCmd ?? '',
      lintCmd: r?.lintCmd ?? '',
      testCmd: r?.testCmd ?? '',
      instructions: r?.instructions ?? '',
      deployWorkflow: r?.deployWorkflow ?? '',
    })
  },
  { immediate: true },
)

const save = useMutation({
  mutationFn: () => {
    const body: RepositoryInput = {
      name: form.name.trim(),
      cloneUrl: form.cloneUrl.trim(),
      defaultBranch: form.defaultBranch.trim() || undefined,
      buildCmd: form.buildCmd.trim(),
      lintCmd: form.lintCmd.trim(),
      testCmd: form.testCmd.trim(),
      instructions: form.instructions,
      jiraProject: form.jiraProject.trim(),
      taskPrefix: form.taskPrefix.trim(),
      deployWorkflow: isGitHub.value ? form.deployWorkflow.trim() : '',
    }
    return props.repo
      ? unwrap(api.PUT('/repos/{id}', { params: { path: { id: props.repo.id } }, body }))
      : unwrap(api.POST('/repos', { body }))
  },
  onSuccess: (r) => {
    void qc.invalidateQueries({ queryKey: ['repos'] })
    ui.notify(t('repos.saved'))
    open.value = false
    emit('saved', r)
  },
  onError: (e) => {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})

const claudeText = computed(() => {
  const s = props.repo?.claudeMd ?? 'unknown'
  return s === 'found' ? t('repos.claudeFound') : s === 'missing' ? t('repos.claudeMissing') : t('repos.claudeUnknown')
})
const isGitHub = computed(() => /^https:\/\/github\.com\//i.test(form.cloneUrl.trim()))
const prefix = computed(() => (form.taskPrefix || 'VIS').toUpperCase())
</script>

<template>
  <FormDrawer
    v-model="open"
    :title="repo ? repo.name : t('repos.add')"
    :subtitle="t('repos.drawerSub')"
  >
    <form id="repo-form" style="display: contents" @submit.prevent="save.mutate()">
      <div class="field">
        <label for="r-name">{{ t('repos.name') }}</label>
        <input id="r-name" v-model="form.name" type="text" required maxlength="100">
      </div>
      <div class="field">
        <label for="r-url">{{ t('repos.cloneUrl') }}</label>
        <input id="r-url" v-model="form.cloneUrl" type="text" required placeholder="https://github.com/you/repo.git or https://gitlab.com/you/repo.git" style="font-family: var(--mono); font-size: 14px">
        <span class="fhelp">{{ t('repos.cloneHelp') }}</span>
      </div>
      <div class="field">
        <label for="r-jira">{{ t('repos.jiraProject') }}</label>
        <input id="r-jira" v-model="form.jiraProject" type="text" maxlength="20" placeholder="PAY" style="font-family: var(--mono); font-size: 14px">
        <span class="fhelp">{{ t('repos.jiraHelp') }}</span>
      </div>
      <div class="field">
        <label for="r-prefix">{{ t('repos.taskPrefix') }}</label>
        <input id="r-prefix" v-model="form.taskPrefix" type="text" maxlength="8" placeholder="VIS" style="font-family: var(--mono); font-size: 14px">
        <span class="fhelp">{{ t('repos.taskPrefixHelp', { prefix }) }}</span>
      </div>
      <div class="field">
        <label for="r-branch">{{ t('repos.branch') }}</label>
        <input id="r-branch" v-model="form.defaultBranch" type="text" style="font-family: var(--mono); font-size: 14px">
        <span class="fhelp">{{ t('repos.branchHelp') }}</span>
      </div>
      <div class="field">
        <label for="r-build">{{ t('repos.build') }}</label>
        <input id="r-build" v-model="form.buildCmd" type="text" placeholder="go build ./..." style="font-family: var(--mono); font-size: 14px">
      </div>
      <div class="field">
        <label for="r-lint">{{ t('repos.lint') }}</label>
        <input id="r-lint" v-model="form.lintCmd" type="text" placeholder="go vet ./..." style="font-family: var(--mono); font-size: 14px">
      </div>
      <div class="field">
        <label for="r-test">{{ t('repos.test') }}</label>
        <input id="r-test" v-model="form.testCmd" type="text" placeholder="go test ./..." style="font-family: var(--mono); font-size: 14px">
        <span class="fhelp">{{ t('repos.testHelp') }}</span>
      </div>
      <div v-if="isGitHub" class="field">
        <label for="r-deploy">{{ t('repos.deployWorkflow') }}</label>
        <input id="r-deploy" v-model="form.deployWorkflow" type="text" maxlength="200" placeholder="deploy.yml" style="font-family: var(--mono); font-size: 14px">
        <span class="fhelp">{{ t('repos.deployWorkflowHelp') }}</span>
      </div>
      <div class="field">
        <label for="r-instr">{{ t('repos.instructions') }}</label>
        <textarea id="r-instr" v-model="form.instructions" maxlength="20000" />
        <span class="fhelp">{{ t('repos.instructionsHelp') }}</span>
      </div>
      <div v-if="repo" class="field">
        <span class="flbl">CLAUDE.md</span>
        <span :class="repo.claudeMd === 'found' ? 'repo-ok' : repo.claudeMd === 'missing' ? 'repo-miss' : 'hint'">{{ claudeText }}</span>
      </div>
      <span v-if="error" class="ferr" role="alert">{{ error }}</span>
    </form>
    <template #footer>
      <button type="button" class="btn" @click="open = false">{{ t('form.cancel') }}</button>
      <button type="submit" form="repo-form" class="btn btn-p" :disabled="save.isPending.value">
        {{ repo ? t('form.save') : t('repos.add') }}
      </button>
    </template>
  </FormDrawer>
</template>
