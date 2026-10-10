<template>
  <section class="p-privacy1" id="privacy">
    <div class="p-privacy2" aria-hidden="true"><span class="p-privacy3"></span></div>
    <div class="p-privacy4">
      <div class="p-row">
        <p class="p-mono p-rev p-privacy5"><span class="p-privacy6">06</span>  <span>{{ t('nav.privacy') }}</span></p>
        <div>
          <h2 class="p-h2 p-rev p-privacy7"><span>{{ t('privacy.title') }}</span></h2>
          <p class="p-rev p-privacy8"><span>{{ t('privacy.lead') }}</span></p>
          <div class="p-two">
            <div class="p-rev p-privacy9">
              <h3 class="p-privacy10"><span>{{ t('privacy.p1.title') }}</span></h3>
              <p class="p-privacy11"><span>{{ t('privacy.p1.text') }}</span></p>
            </div>
            <div class="p-rev p-privacy12">
              <h3 class="p-privacy10"><span>{{ t('privacy.p2.title') }}</span></h3>
              <p class="p-privacy11"><span>{{ t('privacy.p2.text') }}</span></p>
            </div>
            <div class="p-rev p-privacy9">
              <h3 class="p-privacy10"><span>{{ t('privacy.p3.title') }}</span></h3>
              <p class="p-privacy11"><span>{{ t('privacy.p3.text') }}</span></p>
            </div>
            <div class="p-rev p-privacy12">
              <h3 class="p-privacy10"><span>{{ t('privacy.p4.title') }}</span></h3>
              <p class="p-privacy11"><span>{{ t('privacy.p4.text') }}</span></p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const { t } = useI18n()
</script>
