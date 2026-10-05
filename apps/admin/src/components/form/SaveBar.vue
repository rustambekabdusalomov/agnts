<script setup lang="ts">
import { useI18n } from 'vue-i18n'

// Sticky bar shown while a form has unsaved changes.
defineProps<{ busy?: boolean; error?: string }>()
defineEmits<{ save: []; discard: [] }>()
const { t } = useI18n()
</script>

<template>
  <div class="savebar" role="region" :aria-label="t('form.unsaved')">
    <span>{{ error || t('form.unsaved') }}</span>
    <span style="display: flex; gap: 8px">
      <button type="button" class="btn btn-s" :disabled="busy" @click="$emit('discard')">{{ t('form.discard') }}</button>
      <button type="button" class="btn btn-p btn-s" :disabled="busy" @click="$emit('save')">
        {{ busy ? t('form.saving') : t('form.save') }}
      </button>
    </span>
  </div>
</template>
