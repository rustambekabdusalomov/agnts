<script setup lang="ts">
import { useRoute } from 'vue-router'
import AppShell from './components/AppShell.vue'
import ConfirmHost from './components/ui/ConfirmHost.vue'
import { usePrefs } from './stores/prefs'

usePrefs() // applies theme and language before the first page renders
const route = useRoute()
</script>

<template>
  <!-- One shell for every signed-in page, so the sidebar survives navigation.
       Nothing renders before the first navigation resolves: the start route
       has no :ws, and the shell's named links would throw without it. -->
  <template v-if="!route.matched.length" />
  <RouterView v-else-if="route.meta.bare" />
  <AppShell v-else>
    <RouterView />
  </AppShell>
  <ConfirmHost />
</template>
