<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'

// Codex has no account to connect here: it runs on the workspace's OpenAI
// key (Integrations → OpenAI), and OpenAI bills it, not workspace credits.
const { t } = useI18n()
const integrations = useQuery({ queryKey: ['integrations'], queryFn: () => unwrap(api.GET('/integrations')) })
const openai = computed(() => integrations.data.value?.find((i) => i.provider === 'openai'))
</script>

<template>
  <section class="card">
    <div class="ch">
      <div><h2>{{ t('modules.name_codex') }}</h2><p class="sub">{{ t('ws.codexSub') }}</p></div>
      <RouterLink class="btn btn-s" :to="{ name: 'integration', params: { provider: 'openai' } }">
        {{ openai?.connected ? t('ws.codexManage') : t('ws.codexConnect') }}
      </RouterLink>
    </div>
    <p v-if="integrations.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <div v-else class="mini-kv">
      <span>{{ t('ws.codexKey') }}</span>
      <b>
        <template v-if="openai?.connected">{{ t('ws.codexConnected') }}<template v-if="openai.tokenHint"> · …{{ openai.tokenHint }}</template></template>
        <template v-else>{{ t('ws.codexNotConnected') }}</template>
      </b>
    </div>
    <p v-if="openai?.lastError" class="ferr">{{ openai.lastError }}</p>
    <p class="hint" style="margin: 10px 0 0">{{ t('ws.codexCredits') }}</p>
  </section>
</template>
