<script setup lang="ts">
// The unfinished change a stopped ticket's last coding run left. The next
// run picks it up; ticking discard makes it start from the last commit.
import { useI18n } from 'vue-i18n'
import CheckBox from '../form/CheckBox.vue'
import HiIcon from '../ui/HiIcon.vue'

defineProps<{ files: string[] }>()
const discard = defineModel<boolean>('discard', { required: true })
const { t } = useI18n()
</script>

<template>
  <div class="sec saved-work">
    <div class="help"><HiIcon name="info" /><p>{{ t('ticket.savedWork', { count: files.length }) }}</p></div>
    <details class="saved-work-files">
      <summary>{{ t('ticket.savedWorkFiles') }}</summary>
      <ul>
        <li v-for="f in files" :key="f" class="mono">{{ f }}</li>
      </ul>
    </details>
    <CheckBox v-model="discard">{{ t('ticket.discardWork') }}</CheckBox>
    <p class="hint">{{ t('ticket.discardWorkHint') }}</p>
  </div>
</template>

<style scoped>
.saved-work-files { margin: 8px 0 12px; font-size: 14px; }
.saved-work-files summary { cursor: pointer; font-weight: 700; color: var(--primary-ink); }
.saved-work-files ul { margin: 6px 0 0; padding-left: 20px; }
.saved-work-files li { overflow-wrap: anywhere; }
.saved-work .hint { margin: 4px 0 0 26px; }
</style>
