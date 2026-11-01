<script setup lang="ts">
import { computed } from 'vue'

// A finding's redacted excerpt: the header lines (source, service, route,
// masked value), then the log lines. Log text is untrusted, so it is only
// ever interpolated as text.
const props = defineProps<{ sample: string }>()
const parts = computed(() => {
  const at = props.sample.indexOf('\n\n')
  if (at < 0) return { head: '', body: props.sample }
  return { head: props.sample.slice(0, at), body: props.sample.slice(at + 2) }
})
</script>

<template>
  <div class="lw-log">
    <pre v-if="parts.head" class="lw-pre lw-head">{{ parts.head }}</pre>
    <pre class="lw-pre lw-body">{{ parts.body }}</pre>
  </div>
</template>

<style scoped>
.lw-log { display: grid; gap: 6px; }
.lw-pre { margin: 0; font-family: var(--mono); font-size: 13px; line-height: 1.6; background: var(--code); color: var(--code-ink); border-radius: 10px; padding: 12px 14px; max-height: 480px; overflow: auto; white-space: pre-wrap; word-break: break-word; }
.lw-head { opacity: 0.8; }
.lw-body { box-shadow: inset 4px 0 0 var(--bad); }
</style>
