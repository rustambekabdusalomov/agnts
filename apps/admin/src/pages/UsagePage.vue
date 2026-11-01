<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../api/client'
import PageHeader from '../components/PageHeader.vue'
import HiIcon from '../components/ui/HiIcon.vue'
import ModuleUsageCard from '../components/usage/ModuleUsageCard.vue'
import TicketSpendCard from '../components/usage/TicketSpendCard.vue'
import { useModels } from '../composables/useModels'

const { t } = useI18n()
// One card per module the person may use, in their order: Claude and Muse
// report plan windows for their account; Codex runs on an API key.
const catalog = useModels()
const planModules = computed(() => catalog.providers.value.filter((p): p is 'claude' | 'muse' => p === 'claude' || p === 'muse'))
const hasClaude = computed(() => catalog.has('claude'))
const settings = useQuery({ queryKey: ['settings'], queryFn: () => unwrap(api.GET('/settings')) })
</script>

<template>
  <PageHeader :title="t('usage.title')" doc="usage" />
  <!-- The help column explains Claude's windows; without Claude the cards take the full width. -->
  <div class="cfg-grid" :class="{ solo: !hasClaude }">
    <div class="col">
      <ModuleUsageCard v-for="p in planModules" :key="p" :provider="p" />

      <section v-if="catalog.has('codex')" class="card" :aria-label="t('modules.name_codex')">
        <div class="ch"><div><h2>{{ t('modules.name_codex') }}</h2><p class="sub">{{ t('usage.codexSub') }}</p></div></div>
        <div class="help"><HiIcon name="info" /><p>{{ t('usage.codexBody') }}</p></div>
      </section>

      <TicketSpendCard />

      <section v-if="hasClaude" class="card">
        <div class="ch"><div><h2>{{ t('usage.limitTitle') }}</h2><p class="sub">{{ t('usage.limitSub') }}</p></div></div>
        <dl class="kv">
          <dt>{{ t('usage.above', { pct: settings.data.value?.pauseAbove ?? 90 }) }}</dt>
          <dd>{{ t('usage.aboveDo') }}</dd>
          <dt>{{ t('usage.midRun') }}</dt>
          <dd>{{ t('usage.midRunDo') }}</dd>
          <dt>{{ t('usage.afterReset') }}</dt>
          <dd>{{ settings.data.value?.autoResume === false ? t('usage.resumeManual') : t('usage.resumeAuto') }}</dd>
          <dt>{{ t('usage.idle') }}</dt>
          <dd>{{ t('usage.idleDo') }}</dd>
        </dl>
      </section>
    </div>
    <aside v-if="hasClaude" class="cfg-side">
      <div class="help"><HiIcon name="info" /><p>{{ t('usage.help', { agent: 'Claude' }) }}</p></div>
    </aside>
  </div>
</template>
