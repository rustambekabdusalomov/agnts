<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import type { RedFlag } from '../../api/types'

// What agnts's scan of the change flagged: skipped tests, removed
// assertions, silenced linters and the like. A path opens its diff.
defineProps<{ flags: RedFlag[] }>()
const emit = defineEmits<{ show: [path: string] }>()
const { t } = useI18n()
</script>

<template>
  <div class="sec">
    <h3>{{ t('redFlags.title', { n: flags.length }) }}</h3>
    <p class="hint" style="margin: 0 0 8px">{{ t('redFlags.sub') }}</p>
    <ul class="rf">
      <li v-for="(f, i) in flags" :key="i">
        <span class="badge b-warn">{{ t(`redFlags.kind_${f.kind}`) }}</span>
        <button type="button" class="linklike mono" @click="emit('show', f.path)">{{ f.path }}<template v-if="f.line">:{{ f.line }}</template></button>
        <code class="rf-text">{{ f.text }}</code>
      </li>
    </ul>
  </div>
</template>

<style scoped>
.rf { list-style: none; padding: 0; margin: 0; display: grid; gap: 8px; }
.rf li { display: flex; flex-wrap: wrap; gap: 6px 10px; align-items: baseline; }
.rf-text { flex-basis: 100%; font-size: 12.5px; color: var(--ink-2); overflow-wrap: anywhere; }
.linklike { background: none; border: 0; padding: 0; color: var(--primary); cursor: pointer; font-size: 13px; }
</style>
