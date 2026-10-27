<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'

// The person's own free credits from an Admin: runs on agnts's Muse key
// spend them before the workspace's credits (1 credit = $0.01). The
// profile shows the card even with none; billing only when there are some.
const props = defineProps<{ always?: boolean }>()
const { t } = useI18n()
const free = useQuery({ queryKey: ['free-credits'], queryFn: () => unwrap(api.GET('/account/free-credits')) })
const f = computed(() => free.data.value)
const usd = (n: number) =>
  new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', minimumFractionDigits: Number.isInteger(n) ? 0 : 2, maximumFractionDigits: 2 }).format(n)
const shown = computed(() => !!f.value && (props.always || f.value.limit > 0))
</script>

<template>
  <section v-if="shown && f" class="card">
    <div class="ch">
      <div><h2>{{ t('billing.freeCredits') }}</h2><p class="sub">{{ t('billing.freeCreditsSub') }}</p></div>
      <span class="badge" :class="f.remaining > 0 ? 'b-ok' : 'b-gray'">{{ usd(f.remaining / 100) }}</span>
    </div>
    <p v-if="!f.limit" class="hint">{{ t('billing.freeCreditsNone') }}</p>
    <div v-else class="lim">
      <div class="lim-h">
        <span>{{ t('billing.freeCreditsLeft', { n: f.remaining, limit: f.limit }) }}</span>
        <b>{{ t('billing.freeCreditsWorth', { amount: usd(f.remaining / 100), total: usd(f.limit / 100) }) }}</b>
      </div>
      <div class="bar"><span :style="{ width: Math.round((f.remaining / f.limit) * 100) + '%' }" /></div>
    </div>
  </section>
</template>
