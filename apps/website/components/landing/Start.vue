<template>
  <section class="p-start1" id="start">
    <div class="p-row">
      <p class="p-mono p-rev p-start2"><span class="p-start3">10</span>  <span>{{ t('start.label') }}</span></p>
      <div>
        <h2 class="p-h2 p-rev p-start4"><span>{{ t('start.title') }}</span></h2>
        <div class="p-three">
          <div class="p-rev p-start5"><div class="p-rule"></div>
            <div class="p-start6">1</div>
            <h3 class="p-start7"><span>{{ t('start.s1.title') }}</span></h3>
            <p class="p-start8"><span>{{ t('start.s1.text') }}</span></p>
          </div>
          <div class="p-rev p-start9"><div class="p-rule"></div>
            <div class="p-start10">2</div>
            <h3 class="p-start7"><span>{{ t('start.s2.title') }}</span></h3>
            <p class="p-start8"><span>{{ t('start.s2.text') }}</span></p>
          </div>
          <div class="p-rev p-start11"><div class="p-rule"></div>
            <div class="p-start10">3</div>
            <h3 class="p-start7"><span>{{ t('start.s3.title') }}</span></h3>
            <p class="p-start8"><span>{{ t('start.s3.text') }}</span></p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const { t } = useI18n()
</script>
