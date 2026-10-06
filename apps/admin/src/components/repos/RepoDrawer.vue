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
  // Previews: how agnts starts the app to take screenshots.
  pvCommand: '',
  pvPort: '' as string | number,
  pvReady: '/',
  pvRoutes: '',
  pvUiPaths: '',
  pvLogin: '',
})
const error = ref('')
// The environment is write-only: it is shown by names, and replaced or
// cleared only when asked.
const envEdit = ref<'keep' | 'replace' | 'clear'>('keep')
const envText = ref('')

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
      pvCommand: r?.preview?.command ?? '',
      pvPort: r?.preview?.port || '',
      pvReady: r?.preview?.readyPath || '/',
      pvRoutes: (r?.preview?.routes ?? []).join('\n'),
      pvUiPaths: (r?.preview?.uiPaths ?? []).join('\n'),
      pvLogin: r?.preview?.login ?? '',
    })
    envEdit.value = r?.preview?.envSet ? 'keep' : 'replace'
    envText.value = ''
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
      preview: {
        command: form.pvCommand.trim(),
        port: Number(form.pvPort) || 0,
        readyPath: form.pvReady.trim() || '/',
        routes: lines(form.pvRoutes),
        uiPaths: lines(form.pvUiPaths),
        login: form.pvLogin.trim(),
        env: envEdit.value === 'clear' ? '' : envEdit.value === 'replace' && (envText.value.trim() || props.repo?.preview?.envSet) ? envText.value : undefined,
      },
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
const lines = (v: string) => v.split('\n').map((x) => x.trim()).filter(Boolean)
const envNames = computed(() => props.repo?.preview?.envNames ?? [])
// Globs for the usual front-end layouts; a change touching one gets a preview.
const UI_PRESETS: Record<string, string[]> = {
  'Vue / Vite': ['src/**/*.{vue,ts,js,css,scss}'],
  React: ['src/**/*.{tsx,jsx,ts,css,scss}'],
  'Next.js': ['app/**/*.{tsx,jsx,ts,css}', 'pages/**/*.{tsx,jsx}', 'components/**/*.{tsx,jsx,css}'],
  Angular: ['src/**/*.{ts,html,scss,css}'],
}
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
      <fieldset class="field rp-preview">
        <legend class="flbl">{{ t('preview.repoTitle') }}</legend>
        <span class="fhelp">{{ t('preview.repoHelp') }}</span>
        <div class="field">
          <label for="r-pv-cmd">{{ t('preview.repoCommand') }}</label>
          <input id="r-pv-cmd" v-model="form.pvCommand" type="text" maxlength="1000" placeholder="npm ci && npm run dev -- --host 127.0.0.1 --port 5173" style="font-family: var(--mono); font-size: 14px">
          <span class="fhelp">{{ t('preview.repoCommandHelp') }}</span>
        </div>
        <template v-if="form.pvCommand.trim()">
          <div class="rp-row">
            <div class="field">
              <label for="r-pv-port">{{ t('preview.repoPort') }}</label>
              <input id="r-pv-port" v-model="form.pvPort" type="number" min="1" max="65535" required placeholder="5173" style="font-family: var(--mono); font-size: 14px">
            </div>
            <div class="field">
              <label for="r-pv-ready">{{ t('preview.repoReady') }}</label>
              <input id="r-pv-ready" v-model="form.pvReady" type="text" maxlength="300" placeholder="/" style="font-family: var(--mono); font-size: 14px">
            </div>
          </div>
          <div class="field">
            <label for="r-pv-ui">{{ t('preview.repoUiPaths') }}</label>
            <textarea id="r-pv-ui" v-model="form.pvUiPaths" rows="3" placeholder="src/**/*.vue" style="font-family: var(--mono); font-size: 13.5px" />
            <span class="fhelp">{{ t('preview.repoUiPathsHelp') }}</span>
            <span class="rp-presets">
              <button v-for="(globs, name) in UI_PRESETS" :key="name" type="button" class="btn btn-s" @click="form.pvUiPaths = globs.join('\n')">{{ name }}</button>
            </span>
          </div>
          <div class="field">
            <label for="r-pv-routes">{{ t('preview.repoRoutes') }}</label>
            <textarea id="r-pv-routes" v-model="form.pvRoutes" rows="2" placeholder="/" style="font-family: var(--mono); font-size: 13.5px" />
            <span class="fhelp">{{ t('preview.repoRoutesHelp') }}</span>
          </div>
          <div class="field">
            <label for="r-pv-login">{{ t('preview.repoLogin') }}</label>
            <textarea id="r-pv-login" v-model="form.pvLogin" rows="2" maxlength="2000" :placeholder="t('preview.repoLoginPh')" />
            <span class="fhelp">{{ t('preview.repoLoginHelp') }}</span>
          </div>
          <div class="field">
            <label for="r-pv-env">{{ t('preview.repoEnv') }}</label>
            <template v-if="repo?.preview?.envSet && envEdit === 'keep'">
              <span class="hint">{{ t('preview.repoEnvSet', { names: envNames.join(', ') }) }}</span>
              <span class="rp-presets">
                <button type="button" class="btn btn-s" @click="envEdit = 'replace'">{{ t('preview.repoEnvReplace') }}</button>
                <button type="button" class="btn btn-s btn-d" @click="envEdit = 'clear'">{{ t('preview.repoEnvClear') }}</button>
              </span>
            </template>
            <template v-else-if="envEdit === 'clear'">
              <span class="hint">{{ t('preview.repoEnvCleared') }}</span>
              <span class="rp-presets"><button type="button" class="btn btn-s" @click="envEdit = 'keep'">{{ t('form.cancel') }}</button></span>
            </template>
            <template v-else>
              <textarea id="r-pv-env" v-model="envText" rows="3" maxlength="16384" autocomplete="off" spellcheck="false" placeholder="VITE_API_URL=https://staging.example.com" style="font-family: var(--mono); font-size: 13.5px" />
              <span class="fhelp">{{ t('preview.repoEnvHelp') }}</span>
            </template>
          </div>
        </template>
      </fieldset>
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

<style scoped>
.rp-preview { border: 1px solid var(--line); border-radius: 12px; padding: 12px 14px; margin: 0; display: grid; gap: 12px; }
.rp-preview legend { padding: 0 6px; }
.rp-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.rp-presets { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 6px; }
</style>
