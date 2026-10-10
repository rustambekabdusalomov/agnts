<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { KINDS } from './trackerLabels'

// How to hand a tracker ticket to agnts: the base label and one per kind.
defineProps<{ label: string; sub: string; notes: string[] }>()
const { t } = useI18n()
</script>

<template>
  <section class="card">
    <div class="ch"><div><h2>{{ t('integrations.labelsTitle') }}</h2><p class="sub">{{ sub }}</p></div></div>
    <dl class="kv">
      <dt><code>{{ label }}</code></dt><dd>{{ t('kind.autoHint') }}</dd>
      <template v-for="k in KINDS" :key="k">
        <dt><code>{{ label }}-{{ k }}</code></dt><dd><b>{{ t(`kind.${k}`) }}.</b> {{ t(`kind.${k}Hint`) }}</dd>
      </template>
    </dl>
    <ul class="hint" style="margin: 12px 0 0; padding-left: 18px">
      <li v-for="n in notes" :key="n">{{ n }}</li>
    </ul>
  </section>
</template>
