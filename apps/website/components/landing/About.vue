<template>
  <section class="p-about1" id="about">
    <div class="p-row">
      <p class="p-mono p-rev p-about2"><span class="p-about3">08</span>  <span>{{ t('nav.about') }}</span></p>
      <div>
        <h2 class="p-h2 p-rev p-about4"><span>{{ t('about.title') }}</span></h2>
        <div class="p-team">
          <div class="p-rev p-about5">
            <div class="p-about6" aria-hidden="true">RA</div>
            <p class="p-about7"><span>{{ t('about.name') }}</span></p>
            <p class="p-mono p-about8"><span>{{ t('about.role') }}</span></p>
            <p class="p-about9"><span>{{ t('about.bio') }}</span></p>
          </div>
          <div>
            <p v-for="n in 4" :key="n" class="p-rev p-about10"><span>{{ t(`about.story${n}`) }}</span></p>
            <p class="p-rev p-about11"><span>{{ t('about.signature') }}</span></p>
            <ol class="p-rev p-about12" :aria-label="t('about.timeline')">
              <li v-for="n in 6" :key="n" class="p-about13"><span class="p-mono p-about14">{{ t(`about.m${n}.when`) }}</span> <span>{{ t(`about.m${n}.title`) }}</span></li>
            </ol>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const { t } = useI18n()
</script>
