<template>
  <section class="p-savings1" id="savings">
    <div class="p-row">
      <p class="p-mono p-rev p-savings2"><span class="p-savings3">03</span>  <span>{{ t('savings.label') }}</span></p>
      <div>
        <h2 class="p-h2 p-rev p-savings4"><span>{{ t('savings.title') }}</span></h2>
        <p class="p-rev p-savings5"><span>{{ t('savings.lead') }}</span></p>
        <div class="p-calc p-rev">
          <div class="p-savings6">
            <div class="p-field">
              <label for="calc-tickets"><span>{{ t('savings.tickets') }}</span><span class="p-mono p-savings7"><span>{{ out.tickets }}</span></span></label>
              <input id="calc-tickets" v-model.number="inputs.tickets" class="p-range" type="range" min="1" max="30" step="1">
            </div>
            <div class="p-field">
              <label for="calc-hours"><span>{{ t('savings.hours') }}</span><span class="p-mono p-savings7"><span>{{ out.hours }}</span> <span>{{ t('savings.hoursUnit') }}</span></span></label>
              <input id="calc-hours" v-model.number="inputs.hours" class="p-range" type="range" min="0.5" max="12" step="0.5">
            </div>
            <div class="p-field">
              <label for="calc-review"><span>{{ t('savings.review') }}</span><span class="p-mono p-savings7"><span>{{ out.review }}</span> <span>{{ t('savings.minUnit') }}</span></span></label>
              <input id="calc-review" v-model.number="inputs.reviewMin" class="p-range" type="range" min="5" max="60" step="5">
            </div>
            <div class="p-field">
              <label for="calc-rate"><span>{{ t('savings.rate') }}</span><span class="p-mono p-savings7">$<span>{{ out.rate }}</span> <span>{{ t('savings.rateUnit') }}</span></span></label>
              <input id="calc-rate" v-model.number="inputs.rate" class="p-range" type="range" min="3" max="60" step="1">
            </div>
          </div>
  
          <div class="p-savings8">
            <div class="p-out">
              <div>
                <div class="p-mono p-savings9"><span>{{ t('savings.savedLabel') }}</span></div>
                <div class="p-num p-savings10"><span>{{ out.saved }}</span></div>
                <div class="p-savings11"><span>{{ t('savings.about') }}</span> <span>{{ out.days }}</span> <span>{{ t('savings.workdays') }}</span></div>
              </div>
              <div>
                <div class="p-mono p-savings9"><span>{{ t('savings.valueLabel') }}</span></div>
                <div class="p-num p-savings10"><span>{{ out.value }}</span></div>
                <div class="p-savings11"><span>{{ t('savings.perMonth') }}</span> <span>{{ out.year }}</span> <span>{{ t('savings.perYear') }}</span></div>
              </div>
            </div>
  
            <div class="p-savings12">
              <div class="p-savings13"><span>{{ t('savings.without') }}</span><span class="p-mono"><span>{{ out.manual }}</span> <span>{{ t('savings.hoursPerMonth') }}</span></span></div>
              <div class="p-savings14"><div class="p-savings15"></div></div>
              <div class="p-savings16"><span>{{ t('savings.with') }}</span><span class="p-mono"><span>{{ out.withAgnts }}</span> <span>{{ t('savings.hoursPerMonth') }}</span></span></div>
              <div class="p-savings14"><div class="p-savings17" :style="{ width: out.bar }"></div></div>
            </div>
  
            <div class="p-savings18">
              <span class="p-savings19"><span>{{ t('savings.roi') }}</span></span>
              <span class="p-savings20">$<span>{{ out.roi }}</span></span>
            </div>
            <p class="p-savings21"><span>{{ t('savings.note') }}</span></p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { calcSavings, formatSavings, type SavingsInputs } from '~/utils/savings'

const { t } = useI18n()
const { workspaceUsd: priceUsd } = usePrices()

const inputs = reactive<SavingsInputs>({ tickets: 5, hours: 3, reviewMin: 20, rate: 10 })
const out = computed(() => formatSavings(inputs, calcSavings(inputs, priceUsd)))
</script>
