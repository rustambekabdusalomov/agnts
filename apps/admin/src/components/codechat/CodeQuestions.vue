<script setup lang="ts">
import { computed, reactive } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Question } from '../../api/types'

// The questions a Code conversation's ticket asks before it goes on, one
// field each: options fill the field (several, one per line, where the
// question allows more than one). The page sends them as the next message.
const props = defineProps<{ ticketKey: string; questions: Question[]; busy?: boolean }>()
const emit = defineEmits<{ send: [answers: { questionId: number; answer: string }[]] }>()
const { t } = useI18n()

const open = computed(() => props.questions.filter((q) => q.answer == null))
const answers = reactive<Record<number, string>>({})
const lines = (q: Question) => (answers[q.id] ?? '').split('\n').map((s) => s.trim()).filter(Boolean)

function pick(q: Question, o: string) {
  if (!q.multiple) return void (answers[q.id] = o)
  const have = lines(q)
  answers[q.id] = (have.includes(o) ? have.filter((x) => x !== o) : [...have, o]).join('\n')
}
const ready = computed(() => open.value.length > 0 && open.value.every((q) => (answers[q.id] ?? '').trim()))

function send() {
  if (!ready.value || props.busy) return
  emit('send', open.value.map((q) => ({ questionId: q.id, answer: answers[q.id].trim() })))
}
</script>

<template>
  <form class="cq" @submit.prevent="send">
    <b>{{ t('codechat.questionsTitle', { key: ticketKey }) }}</b>
    <div v-for="q in open" :key="q.id" class="cq-q">
      <label :for="`cq-${q.id}`">{{ q.text }}</label>
      <div v-if="q.options?.length" class="cq-opts">
        <button
          v-for="o in q.options"
          :key="o"
          type="button"
          class="btn btn-s"
          :aria-pressed="lines(q).includes(o)"
          @click="pick(q, o)"
        >
          {{ o }}
        </button>
      </div>
      <textarea :id="`cq-${q.id}`" v-model="answers[q.id]" class="cfg-in" rows="2" maxlength="5000" />
    </div>
    <div><button type="submit" class="btn btn-p" :disabled="!ready || busy">{{ t('codechat.answersSend') }}</button></div>
  </form>
</template>

<style scoped>
.cq { display: flex; flex-direction: column; gap: 10px; padding: 14px 16px; border-radius: 16px; border: 1px solid var(--warn); background: var(--surface); }
.cq-q { display: flex; flex-direction: column; gap: 6px; }
.cq-q label { font-weight: 600; }
.cq-opts { display: flex; flex-wrap: wrap; gap: 6px; }
.cq-opts .btn[aria-pressed="true"] { background: var(--primary-soft); color: var(--primary-ink); border-color: var(--primary); }
.cq textarea { resize: vertical; }
</style>
