<template>
  <section class="p-features1" id="features">
    <div class="p-row">
      <p class="p-mono p-rev p-features2"><span class="p-features3">04</span>  <span>{{ t('features.label') }}</span></p>
      <div>
        <h2 class="p-h2 p-rev p-features4"><span>{{ t('features.title') }}</span></h2>
        <div class="p-three">
          <div class="p-rev p-features5"><div class="p-rule"></div>
            <h3 class="p-features6"><span>{{ t('features.f1.title') }}</span></h3>
            <p class="p-features7"><span>{{ t('features.f1.text') }}</span></p>
          </div>
          <div class="p-rev p-features8"><div class="p-rule"></div>
            <h3 class="p-features6"><span>{{ t('features.f2.title') }}</span></h3>
            <p class="p-features7"><span>{{ t('features.f2.text') }}</span></p>
          </div>
          <div class="p-rev p-features9"><div class="p-rule"></div>
            <h3 class="p-features6"><span>{{ t('features.f3.title') }}</span></h3>
            <p class="p-features7"><span>{{ t('features.f3.text') }}</span></p>
          </div>
          <div class="p-rev p-features5"><div class="p-rule"></div>
            <h3 class="p-features6"><span>{{ t('features.f4.title') }}</span> <span class="p-mono p-soon"><span class="p-dot p-soon1" aria-hidden="true"></span><span>{{ t('common.soon') }}</span></span></h3>
            <p class="p-features7"><span>{{ t('features.f4.text') }}</span></p>
          </div>
          <div class="p-rev p-features8"><div class="p-rule"></div>
            <h3 class="p-features6"><span>{{ t('features.f5.title') }}</span></h3>
            <p class="p-features7"><span>{{ t('features.f5.text') }}</span></p>
          </div>
          <div class="p-rev p-features9"><div class="p-rule"></div>
            <h3 class="p-features6"><span>{{ t('features.f6.title') }}</span></h3>
            <p class="p-features7"><span>{{ t('features.f6.text') }}</span></p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const { t } = useI18n()
</script>
