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
  <nav v-if="workspace.canEdit" class="seg cms" :aria-label="t('codechat.modeLabel')">
    <RouterLink class="seg-b" :to="{ name: 'assistant' }" :aria-current="mode === 'chat' ? 'page' : undefined" :aria-pressed="mode === 'chat'">{{ t('codechat.modeChat') }}</RouterLink>
    <RouterLink class="seg-b" :to="{ name: 'assistantCode' }" :aria-current="mode === 'code' ? 'page' : undefined" :aria-pressed="mode === 'code'">{{ t('codechat.modeCode') }}</RouterLink>
  </nav>
</template>

<style scoped>
/* As tall as the header's buttons (40px), each label centred: links do not
   centre their text the way buttons do. */
.cms { flex-wrap: nowrap; align-self: center; }
.cms .seg-b { display: inline-flex; align-items: center; justify-content: center; min-height: 34px; min-width: 72px; text-decoration: none; white-space: nowrap; }
</style>
