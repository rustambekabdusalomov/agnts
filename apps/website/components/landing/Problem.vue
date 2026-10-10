<template>
  <section class="p-prob1" id="problem">
    <div class="p-row">
      <p class="p-mono p-rev p-prob2"><span class="p-prob3">01</span>  <span>{{ t('problem.label') }}</span></p>
      <div>
        <h2 class="p-h2 p-rev p-prob4"><span>{{ t('problem.title') }}</span></h2>
        <p class="p-rev p-prob5"><span>{{ t('problem.lead') }}</span></p>
        <div class="p-two">
          <div>
            <p class="p-mono p-rev p-prob6"><span>{{ t('problem.before') }}</span></p>
            <div v-for="n in 4" :key="n" class="p-rev p-prob7"><div class="p-rule"></div>
              <h3 class="p-prob8"><span>{{ t(`problem.p${n}.title`) }}</span></h3>
              <p class="p-prob9"><span>{{ t(`problem.p${n}.text`) }}</span></p>
            </div>
          </div>
          <div class="p-prob10">
            <p class="p-mono p-rev p-prob6"><span class="p-prob11">{{ t('problem.after') }}</span></p>
            <div v-for="n in 4" :key="n" class="p-rev p-prob7 p-prob12"><div class="p-rule"></div>
              <h3 class="p-prob8"><span>{{ t(`problem.s${n}.title`) }}</span></h3>
              <p class="p-prob9"><span>{{ t(`problem.s${n}.text`) }}</span></p>
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
