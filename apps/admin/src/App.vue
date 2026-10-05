<script setup lang="ts">
import { useRoute } from 'vue-router'
import AppShell from './components/AppShell.vue'
import ConfirmHost from './components/ui/ConfirmHost.vue'
import { usePrefs } from './stores/prefs'

usePrefs() // applies theme and language before the first page renders
const route = useRoute()
</script>

<template>
  <!-- One shell for every signed-in page, so the sidebar survives navigation. -->
  <RouterView v-if="route.meta.bare" />
  <AppShell v-else>
    <RouterView />
  </AppShell>
  <ConfirmHost />
</template>
