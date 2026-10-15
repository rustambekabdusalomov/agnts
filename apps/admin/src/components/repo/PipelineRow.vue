<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { ago, fmtDur } from '../../composables/format'
import CiDot from './CiDot.vue'
import type { Pipeline, Stage } from './types'

// One CI run: its header, the stage strip and, when open, a stage table.
// A manual stage offers "Deploy" when the parent passes canDeploy.
defineProps<{ pipeline: Pipeline; open: boolean; canDeploy?: boolean; deploying?: boolean }>()
const emit = defineEmits<{ toggle: []; deploy: [stage: Stage] }>()
const { t, locale } = useI18n()
</script>

<template>
  <div class="pp" :class="{ open }">
    <button type="button" class="pp-h" :aria-expanded="open" @click="emit('toggle')">
      <CiDot :status="pipeline.status" />
      <span class="pp-id">#{{ pipeline.id }}</span>
      <span class="pp-m">
        <span>{{ pipeline.message || pipeline.name || '—' }}</span>
        <span class="pp-sub">
          <span class="br">{{ pipeline.branch }}</span><span class="sha">{{ pipeline.sha.slice(0, 7) }}</span><span>{{ pipeline.trigger }}</span>
        </span>
      </span>
      <span class="pp-r">
        <span>{{ t(`repo.ci_${pipeline.status}`) }}</span>
        <span v-if="pipeline.durationMs" class="hint">{{ fmtDur(pipeline.durationMs) }}</span>
        <span v-if="pipeline.created" class="hint">{{ ago(pipeline.created, locale) }}</span>
      </span>
    </button>
    <div v-if="pipeline.stages.length" class="stg">
      <template v-for="(s, i) in pipeline.stages" :key="s.id">
        <span v-if="i" class="stg-ln" />
        <span class="stg-i" :class="`stg-${s.status}`" :title="`${s.name}: ${t(`repo.ci_${s.status}`)}`">
          <span class="stg-n">{{ s.name }}</span>
          <button v-if="canDeploy && s.manual" type="button" class="btn btn-s stg-go" :disabled="deploying" @click="emit('deploy', s)">
            {{ t('repo.deploy') }}
          </button>
        </span>
      </template>
    </div>
    <div v-if="open" class="pp-d">
      <table class="tbl">
        <thead>
          <tr><th>{{ t('repo.stage') }}</th><th>{{ t('repo.status') }}</th><th>{{ t('repo.duration') }}</th></tr>
        </thead>
        <tbody>
          <tr v-for="s in pipeline.stages" :key="s.id">
            <td>{{ s.name }}</td>
            <td><CiDot :status="s.status" label /></td>
            <td class="muted">{{ s.durationMs ? fmtDur(s.durationMs) : '—' }}</td>
          </tr>
        </tbody>
      </table>
      <a v-if="pipeline.url" :href="pipeline.url" target="_blank" rel="noopener" class="btn btn-s" style="margin-top: 8px">{{ t('repo.openRun') }}</a>
    </div>
  </div>
</template>
