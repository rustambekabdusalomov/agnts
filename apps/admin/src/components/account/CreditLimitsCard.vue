<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'

// The person's monthly limit on agnts's Muse key, which an Admin may set,
// and what they spent of it this month. Shown only when there is a limit
// (1 credit = $0.01).
const { t } = useI18n()
const usage = useQuery({ queryKey: ['credit-usage'], queryFn: () => unwrap(api.GET('/account/credit-usage')) })
const u = computed(() => usage.data.value)
const usd = (credits: number) => new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(credits / 100)
const pct = computed(() => (u.value?.monthLimit ? Math.min(100, Math.round((u.value.monthUsed / u.value.monthLimit) * 100)) : 0))
const level = computed(() => (pct.value >= 100 ? 'bad' : pct.value >= 80 ? 'warn' : ''))
</script>

<template>
  <section v-if="u?.monthLimit" class="card">
    <div class="ch">
      <div><h2>{{ t('billing.limitsTitle') }}</h2><p class="sub">{{ t('billing.limitsSub') }}</p></div>
    </div>
    <div class="lim">
      <div class="lim-h">
        <span>{{ t('billing.monthLimit', { used: u.monthUsed, limit: u.monthLimit }) }}</span>
        <b>{{ t('billing.freeCreditsWorth', { amount: usd(u.monthUsed), total: usd(u.monthLimit) }) }}</b>
      </div>
      <div class="bar" :class="level"><span :style="{ width: pct + '%' }" /></div>
    </div>
  </section>
</template>
