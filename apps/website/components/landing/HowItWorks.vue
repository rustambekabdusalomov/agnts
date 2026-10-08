<template>
  <section class="p-how1" id="how">
    <div class="p-row">
      <p class="p-mono p-rev p-how2"><span class="p-how3">01</span>  <span>{{ t('nav.how') }}</span></p>
      <div>
        <h2 class="p-h2 p-rev p-how4"><span>{{ t('how.title') }}</span></h2>
        <p class="p-rev p-how5"><span>{{ t('how.lead') }}</span></p>
        <div class="p-two">
          <div class="p-rev p-how6"><div class="p-rule"></div>
            <span class="p-mono p-how7">1</span>
            <h3 class="p-how8"><span>{{ t('how.s1.title') }}</span></h3>
            <p class="p-how9"><span>{{ t('how.s1.text') }}</span></p>
          </div>
          <div class="p-rev p-how10"><div class="p-rule"></div>
            <span class="p-mono p-how7">2</span>
            <h3 class="p-how8"><span>{{ t('how.s2.title') }}</span></h3>
            <p class="p-how9"><span>{{ t('how.s2.text') }}</span></p>
          </div>
          <div class="p-rev p-how6"><div class="p-rule"></div>
            <span class="p-mono p-how7">3</span>
            <h3 class="p-how8"><span>{{ t('how.s3.title') }}</span></h3>
            <p class="p-how9"><span>{{ t('how.s3.text') }}</span></p>
          </div>
          <div class="p-rev p-how10"><div class="p-rule"></div>
            <span class="p-mono p-how7">4</span>
            <h3 class="p-how8"><span>{{ t('how.s4.title') }}</span></h3>
            <p class="p-how9"><span>{{ t('how.s4.text') }}</span></p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const { t } = useI18n()
</script>
