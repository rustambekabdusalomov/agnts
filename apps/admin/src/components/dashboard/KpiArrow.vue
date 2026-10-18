<script setup lang="ts">
// The arrow at a dashboard card's top-right corner: the card opens a page.
</script>

<template>
  <svg class="kpi-go" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" aria-hidden="true" focusable="false">
    <path d="M200,64V168a8,8,0,0,1-16,0V83.31L69.66,197.66a8,8,0,0,1-11.32-11.32L172.69,72H88a8,8,0,0,1,0-16H192A8,8,0,0,1,200,64Z" />
  </svg>
</template>

<style scoped>
.kpi-go { position: absolute; top: 16px; right: 16px; width: 18px; height: 18px; fill: currentColor; color: var(--ink-3); transition: color 0.15s, transform 0.15s; }
:global(.kpi-btn:hover) .kpi-go { color: var(--ink); transform: translate(1px, -1px); }
</style>
