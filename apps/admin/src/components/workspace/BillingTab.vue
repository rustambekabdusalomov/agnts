<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { useUi } from '../../stores/ui'
import { useWorkspace } from '../../stores/workspace'
import CfgRow from '../form/CfgRow.vue'
import NumberStepper from '../form/NumberStepper.vue'

// The owner's billing page: plan, parallel runs, members and credits.
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const workspace = useWorkspace()
const errText = (e: unknown) => (e instanceof HttpError ? e.message : t('common.error'))

const billing = useQuery({ queryKey: ['billing'], queryFn: () => unwrap(api.GET('/workspace/billing')) })
const b = computed(() => billing.data.value)
const som = (n: number) => n.toLocaleString('ru-RU').replace(/,/g, ' ')
// Prices are shown in US dollars only (cents, or tenths of a cent for a credit).
const usd = (n: number) =>
  new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', minimumFractionDigits: Number.isInteger(n) ? 0 : 2, maximumFractionDigits: n < 1 ? 3 : 2 }).format(n)
const fmt = (s?: string) => (s ? new Date(s).toLocaleDateString() : '')

const slots = ref(1)
watch(b, (x) => {
  if (x) slots.value = x.slots
}, { immediate: true })
const setSlots = useMutation({
  mutationFn: () => unwrap(api.PUT('/workspace/billing/slots', { body: { slots: slots.value } })),
  onSuccess: (v) => {
    qc.setQueryData(['billing'], v)
    ui.notify(t('billing.slotsSaved', { n: v.slots }))
    void workspace.refresh()
  },
  onError: (e) => ui.notify(errText(e)),
})

const amount = ref(100000)
const credits = computed(() => (b.value ? Math.floor(amount.value / b.value.prices.creditUzs) : 0))
const checkout = useMutation({
  mutationFn: (provider: 'payme' | 'click') => unwrap(api.POST('/workspace/billing/checkout', { body: { amountUzs: amount.value, provider } })),
  onSuccess: (r) => {
    window.location.href = r.url
  },
  onError: (e) => ui.notify(errText(e)),
})
const reasonBadge: Record<string, string> = { purchase: 'b-ok', grant: 'b-info', refund: 'b-warn', run: 'b-gray' }
</script>

<template>
  <p v-if="billing.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="billing.isError.value" class="ferr">{{ t('common.error') }}</p>
  <div v-else-if="b" class="stack">
    <p v-if="b.selfHosted" class="login-note">{{ t('billing.selfHosted') }}</p>

    <section class="card">
      <div class="ch">
        <div><h2>{{ t('billing.plan') }}</h2><p class="sub">{{ t('billing.planSub', { members: b.prices.includedMembers }) }}</p></div>
        <span class="badge b-info">{{ b.plan }}</span>
      </div>
      <dl class="kv">
        <template v-if="b.monthlyUsd"><dt>{{ t('billing.plan') }}</dt><dd>{{ t('billing.monthly', { amount: usd(b.monthlyUsd) }) }}</dd></template>
        <template v-if="b.trialEndsAt"><dt /><dd>{{ t('billing.trialUntil', { date: fmt(b.trialEndsAt) }) }}</dd></template>
      </dl>
      <CfgRow :label="t('billing.slots')" :help="b.selfHosted ? t('billing.slotsHelpSelfHosted', { max: b.maxSlots }) : t('billing.slotsHelp', { price: usd(b.prices.slotUsd) })">
        <span class="row-actions">
          <NumberStepper v-model="slots" :min="1" :max="b.maxSlots" :step="1" :label="t('billing.slots')" />
          <button class="btn btn-s" :disabled="slots === b.slots || setSlots.isPending.value" @click="setSlots.mutate()">{{ t('billing.slotsSave') }}</button>
        </span>
      </CfgRow>
      <CfgRow :label="t('billing.members')" :help="t('billing.membersHelp', { included: b.prices.includedMembers, price: usd(b.prices.memberUsd) })">
        <span class="mono">{{ b.memberLimit > 0 ? `${b.members} / ${b.memberLimit}` : b.members }}</span>
      </CfgRow>
    </section>

    <section class="card">
      <div class="ch">
        <div><h2>{{ t('billing.credits') }}</h2><p class="sub">{{ t('billing.creditsSub') }}</p></div>
        <span class="badge" :class="b.creditsBalance > 0 ? 'b-ok' : 'b-gray'">{{ t('ws.credits', { n: b.creditsBalance }) }}</span>
      </div>
      <p class="hint">{{ t('billing.creditPrice', { price: usd(b.prices.creditUsd) }) }}</p>
      <template v-if="b.paymentsEnabled">
        <CfgRow :label="t('billing.amount')" :help="t('billing.youGet', { n: credits })">
          <NumberStepper v-model="amount" :min="10000" :max="50000000" :step="50000" :label="t('billing.amount')" :format="som" />
        </CfgRow>
        <div class="row-actions">
          <button class="btn btn-p btn-s" :disabled="checkout.isPending.value" @click="checkout.mutate('payme')">{{ t('billing.payWith', { provider: 'Payme' }) }}</button>
          <button class="btn btn-p btn-s" :disabled="checkout.isPending.value" @click="checkout.mutate('click')">{{ t('billing.payWith', { provider: 'Click' }) }}</button>
        </div>
      </template>
      <p v-else class="hint">{{ t('billing.paymentsOff') }}</p>
    </section>

    <section class="card">
      <div class="ch"><div><h2>{{ t('billing.history') }}</h2></div></div>
      <p v-if="!b.ledger.length" class="empty">{{ t('billing.noHistory') }}</p>
      <div v-else class="tw">
        <table class="tbl">
          <tbody>
            <tr v-for="e in b.ledger" :key="e.id" style="cursor: default">
              <td class="hint">{{ new Date(e.createdAt).toLocaleString() }}</td>
              <td><span class="badge" :class="reasonBadge[e.reason]">{{ t(`billing.reason_${e.reason}`) }}</span></td>
              <td class="mono" :style="{ color: e.amount < 0 ? 'var(--bad-ink)' : 'var(--ok-ink)' }">{{ e.amount > 0 ? '+' : '' }}{{ e.amount }}</td>
              <td>
                <RouterLink v-if="e.ticketKey" :to="{ name: 'ticket', params: { key: e.ticketKey } }" class="tkey">{{ e.ticketKey }}</RouterLink>
                <span class="hint"> {{ e.note }}</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>
