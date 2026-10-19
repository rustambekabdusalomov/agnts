<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { useUi } from '../../stores/ui'
import SegButtons from '../form/SegButtons.vue'
import ConfirmDialog from '../ui/ConfirmDialog.vue'

// Asks agnts to review a pull request from its page, for you: a review
// ticket whose comments stay drafts in agnts until you accept and publish
// them. Approving it finishes the review; it never merges.
const props = defineProps<{ repoId: number; number: number }>()
const open = defineModel<boolean>({ default: false })
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const focus = ref('')
const deep = ref<'' | 'off' | 'always'>('')
watch(open, (v) => {
  if (v) {
    focus.value = ''
    deep.value = ''
  }
})

const start = useMutation({
  mutationFn: () =>
    unwrap(
      api.POST('/repos/{id}/pulls/{number}/review', {
        params: { path: { id: props.repoId, number: props.number } },
        body: { focus: focus.value.trim() || undefined, deep: deep.value },
      }),
    ),
  onSuccess: (tk) => {
    open.value = false
    ui.notify(t('drafts.startedToast', { key: tk.key }))
    void qc.invalidateQueries({ queryKey: ['pull'] })
    void qc.invalidateQueries({ queryKey: ['reviews', 'pulls'] })
  },
  onError: (e) => {
    // Already under review (someone else asked meanwhile): the page shows it.
    if (e instanceof HttpError && e.code === 'review_exists') {
      open.value = false
      void qc.invalidateQueries({ queryKey: ['pull'] })
    }
    ui.notify(e instanceof HttpError ? e.message : t('common.error'))
  },
})
</script>

<template>
  <ConfirmDialog
    v-model="open"
    :title="t('drafts.reviewTitle', { number })"
    :message="t('drafts.reviewSub')"
    :confirm-label="t('drafts.reviewBtn')"
    :busy="start.isPending.value"
    @confirm="start.mutate()"
  >
    <div class="rpd">
      <label class="hint" for="rpd-focus">{{ t('drafts.focusLabel') }}</label>
      <textarea id="rpd-focus" v-model="focus" maxlength="2000" rows="3" :placeholder="t('drafts.focusHint')" />
      <span class="hint">{{ t('drafts.deepLabel') }}</span>
      <SegButtons
        v-model="deep"
        :label="t('drafts.deepLabel')"
        :options="[
          { value: '', label: t('drafts.deep_default') },
          { value: 'always', label: t('drafts.deep_always') },
          { value: 'off', label: t('drafts.deep_off') },
        ]"
      />
    </div>
  </ConfirmDialog>
</template>

<style scoped>
.rpd { display: grid; gap: 6px; text-align: left; margin: 6px 0 4px; }
.rpd textarea { width: 100%; resize: vertical; font: inherit; }
</style>
