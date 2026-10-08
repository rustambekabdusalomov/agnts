<script setup lang="ts">
import { computed, reactive, useId, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Lesson } from '../../api/types'
import RadioButton from '../form/RadioButton.vue'

// The lesson's quiz: one pick per question, then right or wrong with why.
const props = defineProps<{ quiz: Lesson['quiz'] }>()
const { t } = useI18n()
const picked = reactive<Record<number, number>>({})
const done = computed(() => props.quiz.length > 0 && props.quiz.every((_, i) => i in picked))
const right = computed(() => props.quiz.filter((q, i) => picked[i] === q.answer).length)
function reset() {
  for (const k of Object.keys(picked)) delete picked[Number(k)]
}
watch(() => props.quiz, reset)

function optClass(qi: number, oi: number) {
  if (!(qi in picked)) return ''
  if (oi === props.quiz[qi].answer) return 'right'
  return picked[qi] === oi ? 'wrong' : 'dim'
}

// A pick is final, so arrow keys only move focus here (natively they would
// pick as they go); Space or a click picks.
const group = useId()
function moveFocus(e: KeyboardEvent) {
  const step = { ArrowDown: 1, ArrowRight: 1, ArrowUp: -1, ArrowLeft: -1 }[e.key]
  if (!step) return
  e.preventDefault()
  const inputs = [...(e.currentTarget as HTMLElement).querySelectorAll<HTMLInputElement>('input:not(:disabled)')]
  const i = inputs.indexOf(e.target as HTMLInputElement)
  inputs[(i + step + inputs.length) % inputs.length]?.focus()
}
</script>

<template>
  <ol class="quiz">
    <li v-for="(q, qi) in quiz" :key="qi" class="quiz-q">
      <p class="quiz-text">{{ q.question }}</p>
      <div class="quiz-opts" role="radiogroup" :aria-label="q.question" @keydown="moveFocus">
        <RadioButton
          v-for="(o, oi) in q.options"
          :key="oi"
          v-model="picked[qi]"
          class="quiz-opt"
          :class="optClass(qi, oi)"
          :name="`${group}-${qi}`"
          :value="oi"
          :disabled="qi in picked"
          :tone="picked[qi] === oi ? (oi === q.answer ? 'ok' : 'bad') : undefined"
        >
          {{ o }}
        </RadioButton>
      </div>
      <p v-if="qi in picked" class="quiz-why" :class="picked[qi] === q.answer ? 'ok' : 'bad'" aria-live="polite">
        <strong>{{ picked[qi] === q.answer ? t('learn.correct') : t('learn.wrong') }}</strong>
        <template v-if="q.explanation">{{ " " + q.explanation }}</template>
      </p>
    </li>
  </ol>
  <div v-if="done" class="actions" style="align-items: center">
    <span class="badge" :class="right === quiz.length ? 'b-ok' : 'b-warn'">{{ t('learn.score', { right, total: quiz.length }) }}</span>
    <button type="button" class="btn btn-s" @click="reset">{{ t('learn.retry') }}</button>
  </div>
</template>
