<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import PageHeader from '../components/PageHeader.vue'
import LearnQueue from '../components/learn/LearnQueue.vue'
import { useLive } from '../composables/useLive'

// The learning queue: done tickets and where their learn run stands.
const { t } = useI18n()
useLive()
</script>

<template>
  <PageHeader :title="t('learn.queueTitle')" :lede="t('learn.queueLede')" doc="learn" />
  <LearnQueue />
</template>
