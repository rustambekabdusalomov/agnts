<template>
  <section class="p-conn1" id="connectors">
    <div class="p-row">
      <p class="p-mono p-rev p-conn2"><span class="p-conn3">03</span>  <span>{{ t('nav.connectors') }}</span></p>
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
        <div class="p-rev p-conn11">
          <div>
            <h3 class="p-conn12"><span>{{ t('connectors.request.title') }}</span></h3>
            <p class="p-conn10"><span>{{ t('connectors.request.text') }}</span></p>
          </div>
          <button type="button" class="p-btn p-conn13" @click="request.show()"><span>{{ t('connectors.request.button') }}</span>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6"></path></svg>
          </button>
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
  { key: 'plane', name: 'Plane' },
  { key: 'github', name: 'GitHub' },
  { key: 'gitlab', name: 'GitLab' },
  { key: 'claude', name: 'Claude' },
]

const request = useConnectorRequest()
</script>
