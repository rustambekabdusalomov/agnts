<template>
  <section class="p-conn1" id="connectors">
    <div class="p-row">
      <p class="p-mono p-rev p-conn2"><span class="p-conn3">02</span>  <span>{{ t('nav.connectors') }}</span></p>
      <div>
        <h2 class="p-h2 p-rev p-conn4"><span>{{ t('connectors.title') }}</span></h2>
        <p class="p-rev p-conn5"><span>{{ t('connectors.lead') }}</span></p>
        <div class="p-two">
          <div v-for="(c, i) in connectors" :key="c.key" class="p-rev p-conn6" :class="{ 'p-conn7': i % 2 }"><div class="p-rule"></div>
            <span class="p-mono p-conn8">{{ t(`connectors.${c.key}.role`) }}</span>
            <h3 class="p-conn9"><span>{{ c.name }}</span></h3>
            <p class="p-conn10"><span>{{ t(`connectors.${c.key}.text`) }}</span></p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const { t } = useI18n()

// Product names are not translated.
const connectors = [
  { key: 'jira', name: 'Jira' },
  { key: 'github', name: 'GitHub' },
  { key: 'gitlab', name: 'GitLab' },
  { key: 'claude', name: 'Claude' },
]
</script>
