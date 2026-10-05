<script setup lang="ts">
import { answerConfirm, confirmState } from '../../composables/useConfirm'
import ConfirmDialog from './ConfirmDialog.vue'

// Closing the dialog any other way (Cancel, Escape, backdrop) answers "no".
function onOpen(v: boolean) {
  if (!v) answerConfirm(false)
}
</script>

<template>
  <ConfirmDialog
    v-if="confirmState.opts"
    :model-value="confirmState.open"
    :title="confirmState.opts.title"
    :message="confirmState.opts.message"
    :confirm-label="confirmState.opts.confirmLabel"
    :danger="confirmState.opts.danger"
    @update:model-value="onOpen"
    @confirm="answerConfirm(true)"
  />
</template>
