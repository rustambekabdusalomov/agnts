<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { modelLabel, type StageSpend, type TokenSpend } from '../../api/types'
import { fmtTokens, fmtUsd, ioTokens } from '../../composables/format'

// Tokens a ticket used, in total and per stage. Input and output are the
// headline; cache traffic is listed apart so it does not swamp them.
const props = defineProps<{ spend?: TokenSpend; stages: StageSpend[]; report?: boolean }>()
const { t, locale } = useI18n()

const STAGE_KEY: Record<StageSpend['stage'], string> = {
  analyze: 'spend.stageAnalyze',
  coding: 'spend.stageCoding',
  retry: 'spend.stageRetry',
  review: 'spend.stageReview',
  preview: 'spend.stagePreview',
  learn: 'spend.stageLearn',
  helper: 'spend.stageHelper',
}
const stageLabel = (s: StageSpend) => t(s.stage === 'coding' && props.report ? 'spend.stageWriting' : STAGE_KEY[s.stage])

const top = computed(() => Math.max(1, ...props.stages.map((s) => ioTokens(s.spend))))
const tok = (n: number) => fmtTokens(n, locale.value)
const partial = computed(() => props.stages.some((s) => s.partial))
</script>

<template>
  <section class="card spend">
    <div class="ch">
      <div>
        <h2>{{ t('spend.title') }}</h2>
        <p v-if="spend" class="sub">{{ t('spend.sub', { tokens: tok(ioTokens(spend)), cost: fmtUsd(spend.costUsd, locale) }) }}</p>
      </div>
    </div>
    <p v-if="!spend" class="hint">{{ t('spend.empty') }}</p>
    <template v-else>
      <dl class="facts">
        <div><dt>{{ t('spend.input') }}</dt><dd>{{ tok(spend.input) }}</dd></div>
        <div><dt>{{ t('spend.output') }}</dt><dd>{{ tok(spend.output) }}</dd></div>
      </dl>
      <p class="hint spend-cache">{{ t('spend.cache', { read: tok(spend.cacheRead), write: tok(spend.cacheWrite) }) }}</p>
      <div v-for="s in stages" :key="`${s.stage}-${s.model}`" class="lim">
        <div class="lim-h">
          <span>{{ stageLabel(s) }} <span class="muted">· {{ modelLabel(s.model) }}</span></span>
          <b>{{ tok(ioTokens(s.spend)) }}</b>
        </div>
        <div class="bar"><span :style="{ width: (100 * ioTokens(s.spend)) / top + '%' }" /></div>
        <span class="hint">
          {{ t('spend.calls', { n: s.calls }) }} ·
          {{ t('spend.cache', { read: tok(s.spend.cacheRead), write: tok(s.spend.cacheWrite) }) }} ·
          {{ s.partial && !s.spend.costUsd ? '—' : fmtUsd(s.spend.costUsd, locale) }}
        </span>
      </div>
      <p v-if="partial" class="hint">{{ t('spend.partial') }}</p>
      <p class="hint spend-note">{{ t('spend.costNote') }}</p>
    </template>
  </section>
</template>

<style scoped>
.spend .facts { margin-top: 4px; }
.spend-cache { margin: 8px 0 4px; }
.spend-note { margin: 10px 0 0; font-size: 12.5px; }
</style>
