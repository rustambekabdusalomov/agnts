<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

// A small Copy button for an error's text, so it can be pasted into an issue
// or a chat whole: run errors are long and span lines. A label names what it
// copies when the button stands apart from the text.
const props = defineProps<{ text: string; label?: string }>()
const { t } = useI18n()
const copied = ref(false)

/** The Clipboard API, else a hidden textarea (it needs a secure page). */
async function write(text: string): Promise<boolean> {
  try {
    await navigator.clipboard.writeText(text)
    return true
  } catch {
    const ta = document.createElement('textarea')
    ta.value = text
    ta.setAttribute('readonly', '')
    ta.style.cssText = 'position:fixed;top:0;left:0;opacity:0'
    document.body.appendChild(ta)
    ta.select()
    const ok = document.execCommand('copy')
    ta.remove()
    return ok
  }
}

async function copy() {
  if (!(await write(props.text))) return
  copied.value = true
  setTimeout(() => (copied.value = false), 1500)
}
</script>

<template>
  <button type="button" class="btn btn-s copy-btn" :aria-label="label ?? t('form.copy')" @click.stop.prevent="copy">
    <svg viewBox="0 0 24 24" aria-hidden="true">
      <path v-if="copied" d="M5 12.5l4.5 4.5L19 7.5" />
      <template v-else><rect x="9" y="9" width="11" height="11" rx="2" /><path d="M5 15V5a2 2 0 0 1 2-2h8" /></template>
    </svg>
    <span role="status">{{ copied ? t('form.copied') : (label ?? t('form.copy')) }}</span>
  </button>
</template>
