<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

// The branch name, commit message and pull request title formats, with
// their placeholders and an example of each: a repository's own, or a
// group's, which replace its members' in the group's tickets (empty keeps
// each repository's own).
const props = defineProps<{ taskPrefix: string; branchPrefix?: string; group?: boolean; idPrefix: string }>()
const branch = defineModel<string>('branch', { required: true })
const commit = defineModel<string>('commit', { required: true })
const pr = defineModel<string>('pr', { required: true })
const { t } = useI18n()

const branchDefault = '{prefix}{key}'
const branchPlaceholders: [string, string][] = [
  ['{prefix}', 'repos.phPrefix'],
  ['{type}', 'repos.phType'],
  ['{key}', 'repos.phKey'],
  ['{number}', 'repos.phNumber'],
  ['{slug}', 'repos.phSlug'],
  ['{user}', 'repos.phUser'],
]
// A group's empty format shows no example: each repository names its own.
const branchExample = computed(() => {
  const tmpl = branch.value.trim() || (props.group ? '' : branchDefault)
  return tmpl
    .replaceAll('{prefix}', props.branchPrefix || 'agnts/')
    .replaceAll('{type}', 'feature')
    .replaceAll('{key}', `${props.taskPrefix}-42`)
    .replaceAll('{number}', 'AMANAT-2288')
    .replaceAll('{slug}', 'add-login-page')
    .replaceAll('{user}', 'jane')
})
// Commit messages: the agent fills {type}, {scope} and {subject} from its change.
const commitPlaceholders: [string, string][] = [
  ['{number}', 'repos.phNumber'],
  ['{key}', 'repos.phKey'],
  ['{type}', 'repos.phCommitType'],
  ['{scope}', 'repos.phScope'],
  ['{subject}', 'repos.phSubject'],
  ['{title}', 'repos.phTitle'],
]
const commitPlaceholder = '[{number}] {type}({scope}): {subject}'
// A commit-style template filled with the example change.
const fillCommitStyle = (tmpl: string) =>
  tmpl
    .replaceAll('{number}', 'AMANAT-2288')
    .replaceAll('{key}', `${props.taskPrefix}-42`)
    .replaceAll('{type}', 'chore')
    .replaceAll('{scope}', 'deps')
    .replaceAll('{subject}', 'bump protos to v1.63.0')
    .replaceAll('{title}', 'Update protos')
const commitExample = computed(() => fillCommitStyle(commit.value.trim()))
// Pull request titles take the commit message's placeholders.
const prPlaceholder = '[{number}] {type}: {subject}'
const prExample = computed(() => fillCommitStyle(pr.value.trim()))
</script>

<template>
  <div class="field">
    <label :for="`${idPrefix}-branch-tmpl`">{{ t('repos.branchTemplate') }}</label>
    <input
      :id="`${idPrefix}-branch-tmpl`" v-model="branch" type="text" maxlength="100" :placeholder="group ? '' : branchDefault"
      style="font-family: var(--mono); font-size: 14px"
    >
    <span class="fhelp">{{ group ? t('groups.branchTemplateHelp', { key: '{key}', number: '{number}' }) : t('repos.branchTemplateHelp', { key: '{key}', number: '{number}', fallback: branchDefault }) }}</span>
    <dl class="fhelp ph-list" :aria-label="t('repos.placeholders')">
      <template v-for="[ph, desc] in branchPlaceholders" :key="ph">
        <dt>{{ ph }}</dt>
        <dd>{{ t(desc) }}</dd>
      </template>
    </dl>
    <span v-if="branchExample" class="fhelp" style="font-family: var(--mono)">{{ t('repos.branchTemplateExample', { example: branchExample }) }}</span>
  </div>
  <div class="field">
    <label :for="`${idPrefix}-commit-tmpl`">{{ t('repos.commitTemplate') }}</label>
    <input
      :id="`${idPrefix}-commit-tmpl`" v-model="commit" type="text" maxlength="200" :placeholder="commitPlaceholder"
      style="font-family: var(--mono); font-size: 14px"
    >
    <span class="fhelp">{{ group ? t('groups.commitTemplateHelp') : t('repos.commitTemplateHelp') }}</span>
    <dl class="fhelp ph-list" :aria-label="t('repos.placeholders')">
      <template v-for="[ph, desc] in commitPlaceholders" :key="ph">
        <dt>{{ ph }}</dt>
        <dd>{{ t(desc) }}</dd>
      </template>
    </dl>
    <span v-if="commitExample" class="fhelp" style="font-family: var(--mono)">{{ t('repos.commitTemplateExample', { example: commitExample }) }}</span>
  </div>
  <div class="field">
    <label :for="`${idPrefix}-pr-tmpl`">{{ t('repos.prTemplate') }}</label>
    <input
      :id="`${idPrefix}-pr-tmpl`" v-model="pr" type="text" maxlength="200" :placeholder="prPlaceholder"
      style="font-family: var(--mono); font-size: 14px"
    >
    <span class="fhelp">{{ group ? t('groups.prTemplateHelp') : t('repos.prTemplateHelp') }}</span>
    <span v-if="prExample" class="fhelp" style="font-family: var(--mono)">{{ t('repos.commitTemplateExample', { example: prExample }) }}</span>
  </div>
</template>

<style scoped>
.ph-list { display: grid; grid-template-columns: max-content 1fr; gap: 4px 12px; margin: 2px 0; }
.ph-list dt { font-family: var(--mono); color: var(--ink-2); }
.ph-list dd { margin: 0; }
</style>
