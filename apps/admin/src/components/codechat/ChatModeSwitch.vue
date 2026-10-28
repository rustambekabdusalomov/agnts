<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { useWorkspace } from '../../stores/workspace'

// Chat or Code: the chat's two modes, each its own page. Code changes
// repositories, so viewers see only Chat.
defineProps<{ mode: 'chat' | 'code' }>()
const { t } = useI18n()
const workspace = useWorkspace()
</script>

<template>
  <nav v-if="workspace.canEdit" class="tabs cms" :aria-label="t('codechat.modeLabel')">
    <RouterLink class="tab" :to="{ name: 'assistant' }" :aria-current="mode === 'chat' ? 'page' : undefined" :aria-pressed="mode === 'chat'">{{ t('codechat.modeChat') }}</RouterLink>
    <RouterLink class="tab" :to="{ name: 'assistantCode' }" :aria-current="mode === 'code' ? 'page' : undefined" :aria-pressed="mode === 'code'">{{ t('codechat.modeCode') }}</RouterLink>
  </nav>
</template>

<style scoped>
.cms { display: inline-flex; }
.cms .tab { text-decoration: none; }
</style>
