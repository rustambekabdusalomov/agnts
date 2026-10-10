<template>
  <section class="p-pricing1" id="pricing">
    <div class="p-row">
      <p class="p-mono p-rev p-pricing2"><span class="p-pricing3">09</span>  <span>{{ t('nav.pricing') }}</span></p>
      <div>
        <h2 class="p-h2 p-rev p-pricing4"><span>{{ t('pricing.title') }}</span></h2>
        <div class="p-price p-rev">
          <div class="p-pricing5">
            <p class="p-mono p-pricing6"><span>{{ t('pricing.plan') }}</span></p>
            <div class="p-pricing7"><span class="p-big p-pricing8">${{ p.workspaceUsd }}</span><span class="p-pricing9"><span>{{ t('pricing.perMonth') }}</span></span></div>
            <p class="p-pricing25"><span class="p-mono p-pricing20"><span class="p-dot p-pricing21" aria-hidden="true"></span><span>{{ t('pricing.demo') }}</span></span></p>
            <p class="p-pricing10"><span>{{ t('pricing.text', { members: p.includedMembers }) }}</span></p>
            <button type="button" class="p-btn p-pricing11" @click="signIn.show()"><span>{{ t('pricing.start') }}</span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6"></path></svg>
            </button>
          </div>
          <div class="p-pricing13">
            <div>
              <p class="p-mono p-pricing14"><span>{{ t('pricing.included') }}</span></p>
              <ul class="p-pricing15">
                <li class="p-li"><span class="p-chk" aria-hidden="true"></span><span>{{ t('pricing.i1') }}</span></li>
                <li class="p-li"><span class="p-chk" aria-hidden="true"></span><span>{{ t('pricing.i2', { members: p.includedMembers }) }}</span></li>
                <li class="p-li"><span class="p-chk" aria-hidden="true"></span><span>{{ t('pricing.i3') }}</span></li>
                <li class="p-li"><span class="p-chk" aria-hidden="true"></span><span>{{ t('pricing.i4') }} <span class="p-mono p-soon"><span class="p-dot p-soon1" aria-hidden="true"></span><span>{{ t('common.soon') }}</span></span></span></li>
                <li class="p-li"><span class="p-chk" aria-hidden="true"></span><span>{{ t('pricing.i5') }}</span></li>
                <li class="p-li"><span class="p-chk" aria-hidden="true"></span><span>{{ t('pricing.i6') }}</span></li>
              </ul>
            </div>
            <div>
              <p class="p-mono p-pricing14"><span>{{ t('pricing.youBring') }}</span></p>
              <ul class="p-pricing15">
                <li class="p-li"><span class="p-dash" aria-hidden="true"></span><span>{{ t('pricing.b1') }}</span></li>
                <li class="p-li"><span class="p-dash" aria-hidden="true"></span><span>{{ t('pricing.b2') }}</span></li>
              </ul>
            </div>
          </div>
        </div>

        <div class="p-rev p-pricing16">
          <div class="p-pricing17">
            <div class="p-pricing18">
              <span class="p-pricing19">{{ t('pricing.addons') }}</span>
              <span class="p-mono p-pricing20"><span class="p-dot p-pricing21" aria-hidden="true"></span><span>{{ t('pricing.addonsTag') }}</span></span>
            </div>
            <span class="p-pricing9"><span>{{ t('pricing.prepaid') }}</span></span>
          </div>
          <p class="p-pricing22"><span>{{ t('pricing.addonsText') }}</span></p>
          <div class="p-two p-pricing23">
            <ul class="p-pricing15">
              <li class="p-li"><span class="p-chk" aria-hidden="true"></span><span>{{ t('pricing.a1', { price: p.slotUsd, max: p.maxSlots }) }}</span></li>
              <li class="p-li"><span class="p-chk" aria-hidden="true"></span><span>{{ t('pricing.a2', { price: p.memberUsd, members: p.includedMembers }) }}</span></li>
            </ul>
            <ul class="p-pricing15">
              <li class="p-li"><span class="p-chk" aria-hidden="true"></span><span>{{ t('pricing.a3', { markup: markupPct }) }}</span></li>
              <li class="p-li"><span class="p-chk" aria-hidden="true"></span><span>{{ t('pricing.a4') }}</span></li>
            </ul>
          </div>
          <div>
            <a class="p-btn p-pricing24" href="https://t.me/agnts_admin" target="_blank" rel="noopener"><span>{{ t('pricing.selfHosted') }}</span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6"></path></svg>
            </a>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const { t } = useI18n()
const signIn = useSignIn()
const p = usePrices()
const markupPct = Math.round((p.creditMarkup - 1) * 100)
</script>
