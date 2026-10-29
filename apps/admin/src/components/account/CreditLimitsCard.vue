<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'

// The person's own limits on agnts's Muse key this month: the monthly
// limit an Admin may set, and their allowance on the fallback provider
// (Baseten), which runs use only while agnts's Meta key is out. Shown when
// either applies (1 credit = $0.01).
const { t } = useI18n()
const usage = useQuery({ queryKey: ['credit-usage'], queryFn: () => unwrap(api.GET('/account/credit-usage')) })
const u = computed(() => usage.data.value)
const fb = computed(() => u.value?.fallback)
const shown = computed(() => !!u.value && (u.value.monthLimit > 0 || !!fb.value))
const usd = (credits: number) => new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(credits / 100)
const pct = (used: number, limit: number) => (limit > 0 ? Math.min(100, Math.round((used / limit) * 100)) : 0)
const level = (p: number) => (p >= 100 ? 'bad' : p >= 80 ? 'warn' : '')
</script>

<template>
  <section v-if="shown && u" class="card">
    <div class="ch">
      <div><h2>{{ t('billing.limitsTitle') }}</h2><p class="sub">{{ t('billing.limitsSub') }}</p></div>
    </div>
    <div v-if="u.monthLimit" class="lim">
      <div class="lim-h">
        <span>{{ t('billing.monthLimit', { used: u.monthUsed, limit: u.monthLimit }) }}</span>
        <b>{{ t('billing.freeCreditsWorth', { amount: usd(u.monthUsed), total: usd(u.monthLimit) }) }}</b>
      </div>
      <div class="bar" :class="level(pct(u.monthUsed, u.monthLimit))"><span :style="{ width: pct(u.monthUsed, u.monthLimit) + '%' }" /></div>
    </div>
    <div v-if="fb" class="lim" :style="u.monthLimit ? 'margin-top: 14px' : ''">
      <div class="lim-h">
        <span v-if="fb.monthLimit">{{ t('billing.fallbackLimit', { name: fb.provider, used: fb.monthUsed, limit: fb.monthLimit }) }}</span>
        <span v-else>{{ t('billing.fallbackNoLimit', { name: fb.provider, used: fb.monthUsed }) }}</span>
        <b v-if="fb.monthLimit">{{ t('billing.freeCreditsWorth', { amount: usd(fb.monthUsed), total: usd(fb.monthLimit) }) }}</b>
      </div>
      <div v-if="fb.monthLimit" class="bar" :class="level(pct(fb.monthUsed, fb.monthLimit))"><span :style="{ width: pct(fb.monthUsed, fb.monthLimit) + '%' }" /></div>
      <p class="hint">{{ t('billing.fallbackHint', { name: fb.provider }) }}</p>
    </div>
  </section>
</template>
