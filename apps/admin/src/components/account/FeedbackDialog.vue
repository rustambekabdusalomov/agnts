<script setup lang="ts">
import { useMutation } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { useUi } from '../../stores/ui'
import ConfirmDialog from '../ui/ConfirmDialog.vue'

// "Send feedback": a title and a description for the platform's Admins.
// The workspace it is sent from goes along as context.
const props = defineProps<{ workspace?: string }>()
const open = defineModel<boolean>({ default: false })
const { t } = useI18n()
const ui = useUi()

const title = ref('')
const description = ref('')
const error = ref('')
const ready = computed(() => !!title.value.trim() && !!description.value.trim())
watch(open, (v) => {
  if (v) error.value = ''
})

const send = useMutation({
  mutationFn: () =>
    unwrap(api.POST('/feedback', {
      body: { title: title.value.trim(), description: description.value.trim(), ...(props.workspace ? { workspace: props.workspace } : {}) },
    })),
  onSuccess: () => {
    open.value = false
    title.value = description.value = ''
    ui.notify(t('feedback.sent'))
  },
  onError: (e) => {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})
</script>

<template>
  <ConfirmDialog
    v-model="open"
    class="cdlg-wide"
    :title="t('feedback.title')"
    :message="t('feedback.lede')"
    :confirm-label="t('feedback.send')"
    :busy="send.isPending.value"
    :disabled="!ready"
    @confirm="send.mutate()"
  >
    <template #icon><svg viewBox="0 0 24 24"><path d="M4 5.5A1.5 1.5 0 0 1 5.5 4h13A1.5 1.5 0 0 1 20 5.5v9a1.5 1.5 0 0 1-1.5 1.5H9l-5 4z" /><path d="M8 9h8M8 12h5" /></svg></template>
    <div class="stack fb-form">
      <label class="field">
        <span class="flbl">{{ t('feedback.titleLabel') }}</span>
        <input v-model="title" class="cfg-in" maxlength="120" :placeholder="t('feedback.titlePlaceholder')">
      </label>
      <label class="field">
        <span class="flbl">{{ t('feedback.descLabel') }}</span>
        <textarea v-model="description" class="cfg-in fb-desc" maxlength="5000" rows="6" :placeholder="t('feedback.descPlaceholder')" />
        <span class="fhelp">{{ description.length }} / 5000</span>
      </label>
      <p v-if="error" class="login-err" role="alert">{{ error }}</p>
    </div>
  </ConfirmDialog>
</template>
