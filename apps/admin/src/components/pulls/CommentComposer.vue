<script setup lang="ts">
import { ref, useId } from 'vue'
import { useI18n } from 'vue-i18n'
import CommentBody from './CommentBody.vue'

// Writes or edits a comment: Markdown with a preview. `as` says who it
// will appear from on the git host. altLabel adds a second way to send it
// (keep it as a draft of the review instead of posting it now).
const props = defineProps<{ initial?: string; busy?: boolean; submitLabel: string; as?: string; autofocus?: boolean; label?: string; altLabel?: string }>()
const emit = defineEmits<{ submit: [body: string]; alt: [body: string]; cancel: [] }>()
const { t } = useI18n()
const body = ref(props.initial ?? '')
const preview = ref(false)
const id = useId()

function submit() {
  const b = body.value.trim()
  if (b && !props.busy) emit('submit', b)
}
function alt() {
  const b = body.value.trim()
  if (b && !props.busy) emit('alt', b)
}
function onKey(e: KeyboardEvent) {
  if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') submit()
  if (e.key === 'Escape') emit('cancel')
}
defineExpose({ clear: () => (body.value = '') })
</script>

<template>
  <div class="cmp">
    <div class="cmp-tabs" role="tablist">
      <button type="button" class="cmp-tab" role="tab" :aria-selected="!preview" @click="preview = false">{{ t('pulls.write') }}</button>
      <button type="button" class="cmp-tab" role="tab" :aria-selected="preview" :disabled="!body.trim()" @click="preview = true">{{ t('pulls.preview') }}</button>
    </div>
    <CommentBody v-if="preview" class="cmp-prev" :markdown="body" />
    <template v-else>
      <label :for="id" class="sr-only">{{ label ?? t('pulls.commentLabel') }}</label>
      <textarea :id="id" v-model="body" class="cmp-in" maxlength="60000" :placeholder="t('pulls.placeholder')" :autofocus="autofocus" @keydown="onKey" />
    </template>
    <div class="cmp-f">
      <span v-if="as" class="hint">{{ as }}</span>
      <span class="cmp-sp" />
      <button type="button" class="btn btn-s" :disabled="busy" @click="emit('cancel')">{{ t('form.cancel') }}</button>
      <button v-if="altLabel" type="button" class="btn btn-s" :disabled="busy || !body.trim()" @click="alt">{{ altLabel }}</button>
      <button type="button" class="btn btn-s btn-p" :disabled="busy || !body.trim()" @click="submit">
        <span v-if="busy" class="spin" aria-hidden="true" />{{ submitLabel }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.cmp { border: 1px solid var(--line-2); border-radius: 10px; background: var(--field); padding: 8px; display: grid; gap: 8px; }
.cmp-tabs { display: flex; gap: 4px; }
.cmp-tab { background: none; border: 0; padding: 4px 10px; border-radius: 6px; font: inherit; font-size: 13px; color: var(--ink-3); cursor: pointer; }
.cmp-tab[aria-selected='true'] { background: var(--hover); color: var(--ink); }
.cmp-tab:disabled { opacity: 0.5; cursor: default; }
.cmp-in { width: 100%; min-height: 90px; resize: vertical; font: inherit; font-size: 14.5px; }
.cmp-prev { min-height: 60px; padding: 4px 6px; }
.cmp-f { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.cmp-sp { flex: 1; }
.sr-only { position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0 0 0 0); white-space: nowrap; }
</style>
