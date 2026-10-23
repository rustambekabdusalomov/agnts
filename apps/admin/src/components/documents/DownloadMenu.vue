<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { HttpError } from '../../api/client'
import HiIcon from '../ui/HiIcon.vue'
import { downloadFile } from './useDocuments'

// Download buttons for Markdown and PDF. A PDF made for the first time
// takes a few seconds: the button says so while it waits.
// headers go with each request (a guest's token on a public link).
const props = defineProps<{ mdPath: string; pdfPath: string; name: string; small?: boolean; headers?: Record<string, string> }>()
const { t } = useI18n()
const busy = ref<'' | 'md' | 'pdf'>('')
const preparing = ref(false)
const error = ref('')

async function get(format: 'md' | 'pdf') {
  busy.value = format
  preparing.value = false
  error.value = ''
  try {
    await downloadFile(format === 'md' ? props.mdPath : props.pdfPath, `${props.name}.${format}`, () => (preparing.value = true), props.headers)
  } catch (e) {
    error.value = e instanceof HttpError && e.status === 503 ? t('documents.pdfFailed') : e instanceof HttpError && e.status === 202 ? t('documents.pdfSlow') : t('common.error')
  } finally {
    busy.value = ''
    preparing.value = false
  }
}
</script>

<template>
  <span class="dl">
    <button type="button" class="btn" :class="{ 'btn-s': small }" :disabled="!!busy" @click="get('md')">
      <HiIcon name="import" />{{ t('documents.downloadMd') }}
    </button>
    <button type="button" class="btn" :class="{ 'btn-s': small }" :disabled="!!busy" @click="get('pdf')">
      <HiIcon name="import" />{{ busy === 'pdf' && preparing ? t('documents.preparingPdf') : t('documents.downloadPdf') }}
    </button>
    <span v-if="error" class="ferr" role="alert">{{ error }}</span>
  </span>
</template>

<style scoped>
.dl { display: inline-flex; gap: 8px; align-items: center; flex-wrap: wrap; }
</style>
