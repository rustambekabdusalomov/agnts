<template>
  <section class="p-faq1" id="faq">
    <div class="p-row">
      <p class="p-mono p-rev p-faq2"><span class="p-faq3">09</span>  <span>{{ t('nav.faq') }}</span></p>
      <div>
        <h2 class="p-h2 p-rev p-faq4"><span>{{ t('faq.title') }}</span></h2>
        <div class="p-rev p-faq5">
          <details class="p-faq">
            <summary><span>{{ t('faq.q2') }}</span></summary>
            <p><span>{{ t('faq.a2') }}</span></p>
          </details>
          <details class="p-faq">
            <summary><span>{{ t('faq.q3') }}</span></summary>
            <p><span>{{ t('faq.a3') }}</span></p>
          </details>
          <details class="p-faq">
            <summary><span>{{ t('faq.q4') }}</span></summary>
            <p><span>{{ t('faq.a4') }}</span></p>
          </details>
          <details class="p-faq">
            <summary><span>{{ t('faq.q5') }}</span></summary>
            <p><span>{{ t('faq.a5') }}</span></p>
          </details>
          <details class="p-faq">
            <summary><span>{{ t('faq.q6') }}</span></summary>
            <p><span>{{ t('faq.a6') }}</span></p>
          </details>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const { t } = useI18n()
</script>
