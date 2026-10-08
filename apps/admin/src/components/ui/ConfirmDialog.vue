<script setup lang="ts">
import { ref, useId, watch } from 'vue'
import { useI18n } from 'vue-i18n'

// Centered confirm modal on the native <dialog>: it traps focus, closes on
// Escape and renders above everything. Clicking the backdrop cancels.
// disabled keeps the confirm button off (a form inside that is not filled in yet).
const props = defineProps<{ title: string; message?: string; confirmLabel: string; danger?: boolean; busy?: boolean; disabled?: boolean }>()
const emit = defineEmits<{ confirm: [] }>()
const open = defineModel<boolean>({ default: false })
const { t } = useI18n()
const dlg = ref<HTMLDialogElement | null>(null)
const id = useId() // several dialogs can be mounted at once

watch(
  [open, dlg],
  ([v, el]) => {
    if (!el) return
    if (v && !el.open) el.showModal()
    else if (!v && el.open) el.close()
  },
  { immediate: true },
)

function onBackdrop(e: MouseEvent) {
  if (e.target === dlg.value && !props.busy) open.value = false
}
</script>

<template>
  <dialog
    ref="dlg"
    class="cdlg"
    :aria-labelledby="`${id}-title`"
    :aria-describedby="message ? `${id}-msg` : undefined"
    @close="open = false"
    @cancel.prevent="!busy && (open = false)"
    @click="onBackdrop"
  >
    <div class="cdlg-in">
      <span class="cdlg-ic" :class="{ bad: danger }" aria-hidden="true">
        <slot name="icon">
          <svg v-if="danger" viewBox="0 0 24 24"><path d="M12 4l9 16H3z" /><path d="M12 10v4M12 17v.01" /></svg>
          <svg v-else viewBox="0 0 24 24"><circle cx="12" cy="12" r="9" /><path d="M9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.6.3-1 .9-1 1.6M12 17v.01" /></svg>
        </slot>
      </span>
      <h2 :id="`${id}-title`">{{ title }}</h2>
      <p v-if="message" :id="`${id}-msg`">{{ message }}</p>
      <slot />
      <div class="cdlg-f">
        <button class="btn" type="button" :disabled="busy" autofocus @click="open = false">{{ t('form.cancel') }}</button>
        <button class="btn" :class="danger ? 'btn-danger' : 'btn-p'" type="button" :disabled="busy || disabled" @click="emit('confirm')">
          <span v-if="busy" class="spin" aria-hidden="true" />{{ confirmLabel }}
        </button>
      </div>
    </div>
  </dialog>
</template>
