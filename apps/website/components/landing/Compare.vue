<template>
  <section class="p-compare1" id="compare">
    <div class="p-row">
      <p class="p-mono p-rev p-compare2"><span class="p-compare3">07</span>  <span>{{ t('compare.label') }}</span></p>
      <div>
        <h2 class="p-h2 p-rev p-compare4"><span>{{ t('compare.title') }}</span></h2>
        <div class="p-rev p-compare5">
          <table class="p-cmp">
            <thead>
              <tr><th scope="col"></th><th scope="col"><span>{{ t('compare.ide') }}</span></th><th scope="col"><span>{{ t('compare.cloud') }}</span></th><th scope="col" class="p-us p-compare6">agnts</th></tr>
            </thead>
            <tbody>
              <tr><td><span>{{ t('compare.r1') }}</span></td><td><span>{{ t('compare.no') }}</span></td><td><span>{{ t('compare.yes') }}</span></td><td class="p-us"><span>{{ t('compare.yes') }}</span></td></tr>
              <tr><td><span>{{ t('compare.r2') }}</span></td><td><span>{{ t('compare.no') }}</span></td><td><span>{{ t('compare.partly') }}</span></td><td class="p-us"><span>{{ t('compare.yes') }}</span></td></tr>
              <tr><td><span>{{ t('compare.r3') }}</span></td><td><span>{{ t('compare.whenPrompted') }}</span></td><td><span>{{ t('compare.rarely') }}</span></td><td class="p-us"><span>{{ t('compare.always') }}</span></td></tr>
              <tr><td><span>{{ t('compare.r4') }}</span></td><td><span>{{ t('compare.no') }}</span></td><td><span>{{ t('compare.yes') }}</span></td><td class="p-us"><span>{{ t('compare.yes') }}</span></td></tr>
              <tr><td><span>{{ t('compare.r5') }}</span></td><td><span>{{ t('compare.no') }}</span></td><td><span>{{ t('compare.varies') }}</span></td><td class="p-us"><span>{{ t('common.soon') }}</span></td></tr>
              <tr><td><span>{{ t('compare.r6') }}</span></td><td><span>{{ t('compare.rarely') }}</span></td><td><span>{{ t('compare.rarely') }}</span></td><td class="p-us"><span>{{ t('compare.yes') }}</span></td></tr>
              <tr><td><span>{{ t('compare.price') }}</span></td><td><span>{{ t('compare.varies') }}</span></td><td><span>{{ t('compare.varies') }}</span></td><td class="p-us"><span>{{ t('compare.priceUs') }}</span></td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const { t } = useI18n()
</script>
