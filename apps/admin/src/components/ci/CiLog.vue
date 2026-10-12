<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { splitSample } from './ci'

// A failure's redacted log excerpt: check annotations, the first error
// block (highlighted) and the end of the log. Log text is untrusted, so it
// is only ever interpolated as text.
const props = defineProps<{ sample: string }>()
const { t } = useI18n()
const parts = computed(() => splitSample(props.sample))
</script>

<template>
  <div class="ci-log">
    <template v-if="parts.annotations">
      <div class="ci-log-h">{{ t('ci.logAnnotations') }}</div>
      <pre class="ci-pre">{{ parts.annotations }}</pre>
    </template>
    <template v-if="parts.firstError">
      <div class="ci-log-h bad">{{ t('ci.logFirstError') }}</div>
      <pre class="ci-pre ci-err">{{ parts.firstError }}</pre>
    </template>
    <template v-if="parts.tail">
      <div class="ci-log-h">{{ parts.firstError ? t('ci.logEnd') : t('ci.logTail') }}</div>
      <pre class="ci-pre">{{ parts.tail }}</pre>
    </template>
  </div>
</template>

<style scoped>
.ci-log { display: grid; gap: 6px; }
.ci-log-h { font-size: 12.5px; font-weight: 700; color: var(--ink-3); margin-top: 6px; }
.ci-log-h.bad { color: var(--bad-ink); }
.ci-pre { margin: 0; font-family: var(--mono); font-size: 13px; line-height: 1.6; background: var(--code); color: var(--code-ink); border-radius: 10px; padding: 12px 14px; max-height: 420px; overflow: auto; white-space: pre-wrap; word-break: break-word; }
.ci-err { box-shadow: inset 4px 0 0 var(--bad); }
</style>
