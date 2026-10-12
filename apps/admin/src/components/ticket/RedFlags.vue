<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { RedFlag } from '../../api/types'

// What agnts's scan of the change flagged: skipped tests, removed
// assertions, silenced linters, possible secrets and the like. A path
// opens its diff.
const props = defineProps<{ flags: RedFlag[] }>()
const emit = defineEmits<{ show: [path: string] }>()
const { t } = useI18n()

// The order the server lists kinds in (domain.FlagKinds): the most serious first.
const ORDER: RedFlag['kind'][] = ['secret', 'env_file', 'skipped_test', 'removed_assertion', 'deleted_test', 'silenced_lint',
  'check_config', 'swallowed_error', 'rule_violation', 'debug_leftover', 'todo', 'new_dependency']
// Kinds added with the harness keep their labels in their own namespace.
const NEW: RedFlag['kind'][] = ['secret', 'env_file', 'debug_leftover', 'check_config', 'rule_violation']
const sorted = computed(() => [...props.flags].sort((a, b) => ORDER.indexOf(a.kind) - ORDER.indexOf(b.kind)))
const label = (k: RedFlag['kind']) => (NEW.includes(k) ? t(`harnessTicket.flag_${k}`) : t(`redFlags.kind_${k}`))
const tone = (k: RedFlag['kind']) => (k === 'secret' || k === 'env_file' ? 'b-bad' : 'b-warn')
</script>

<template>
  <div class="sec">
    <h3>{{ t('redFlags.title', { n: flags.length }) }}</h3>
    <p class="hint" style="margin: 0 0 8px">{{ t('redFlags.sub') }}</p>
    <ul class="rf">
      <li v-for="(f, i) in sorted" :key="i">
        <span class="badge" :class="tone(f.kind)">{{ label(f.kind) }}</span>
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
