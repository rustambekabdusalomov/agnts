<script setup lang="ts">
import { computed, reactive, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Rule } from '../../api/types'
import { ago } from '../../composables/format'
import { askConfirm } from '../../composables/useConfirm'
import SwitchToggle from '../form/SwitchToggle.vue'
import { RULE_TONE, useRuleAction } from './useRules'
import CopyButton from '../ui/CopyButton.vue'

// One rule: its text, where Claude's review stands, and what to do next
// (answer its questions, retry a failed review, edit, turn off, delete).
const props = defineProps<{ rule: Rule }>()
const emit = defineEmits<{ edit: [rule: Rule] }>()
const { t, locale } = useI18n()
const act = useRuleAction()

const open = computed(() => props.rule.questions.filter((q) => !q.answer))
const answered = computed(() => props.rule.questions.filter((q) => q.answer))
const reviewing = computed(() => props.rule.status === 'pending' || props.rule.status === 'analyzing')

// Draft answers per question index, kept while the list refreshes.
const answers = reactive<Record<number, { answer: string; note: string }>>({})
watch(
  open,
  (qs) => {
    for (const q of qs) answers[q.index] ??= { answer: '', note: '' }
  },
  { immediate: true },
)
const left = computed(() => open.value.filter((q) => !answers[q.index]?.answer.trim()).length)

function submitAnswers() {
  act.mutate({
    kind: 'answers',
    id: props.rule.id,
    answers: open.value.map((q) => ({ index: q.index, answer: answers[q.index].answer.trim(), note: answers[q.index].note.trim() || undefined })),
  })
}

const enabled = computed({
  get: () => props.rule.enabled,
  set: (v: boolean) => act.mutate({ kind: 'enabled', rule: props.rule, enabled: v }),
})

async function accept() {
  if (await askConfirm({ title: t('rules.acceptTitle'), message: t('rules.acceptBody'), confirmLabel: t('rules.accept') })) {
    act.mutate({ kind: 'accept', id: props.rule.id })
  }
}

async function dismiss() {
  if (await askConfirm({ title: t('rules.dismiss'), message: t('rules.dismissBody', { title: props.rule.title }), confirmLabel: t('rules.dismiss') })) {
    act.mutate({ kind: 'dismiss', id: props.rule.id })
  }
}

async function remove() {
  if (await askConfirm({ title: t('rules.delete'), message: t('rules.deleteBody', { title: props.rule.title }), confirmLabel: t('rules.delete'), danger: true })) {
    act.mutate({ kind: 'delete', id: props.rule.id })
  }
}
</script>

<template>
  <section class="card rule" :class="{ off: !rule.enabled }">
    <div class="ch rule-h">
      <div class="rule-head">
        <h2>{{ rule.title }}</h2>
        <div class="srcs">
          <span v-if="rule.repoName" class="src local">{{ rule.repoName }}</span>
          <span v-else class="src">{{ t('rules.global') }}</span>
          <span class="badge" :class="`b-${RULE_TONE[rule.status]}`">{{ t(`rules.status_${rule.status}`) }}</span>
          <span v-if="rule.kind === 'context'" class="badge b-gray">{{ t('rules.kindContext') }}</span>
          <span v-if="!rule.enabled" class="badge b-gray">{{ t('rules.off') }}</span>
        </div>
      </div>
      <div class="rule-tools">
        <SwitchToggle v-model="enabled" :label="t('rules.enabledFor', { title: rule.title })" />
        <button type="button" class="btn btn-s" @click="emit('edit', rule)">{{ t('rules.edit') }}</button>
        <button v-if="rule.status !== 'suggested'" type="button" class="btn btn-s" :disabled="act.isPending.value" @click="remove">{{ t('rules.delete') }}</button>
      </div>
    </div>

    <p class="rule-body">{{ rule.body }}</p>

    <!-- Suggested by agnts from feedback -->
    <template v-if="rule.status === 'suggested'">
      <div class="help">
        <p>
          {{ t('rules.suggestedFrom') }}
          <RouterLink v-if="rule.sourceTicket" :to="{ name: 'ticket', params: { key: rule.sourceTicket } }">{{ rule.sourceTicket }}</RouterLink><template v-if="rule.reason">: {{ rule.reason }}</template>
        </p>
      </div>
      <div class="actions">
        <button class="btn btn-p" type="button" :disabled="act.isPending.value" @click="act.mutate({ kind: 'review', id: rule.id })">{{ t('rules.adopt') }}</button>
        <button class="btn" type="button" :disabled="act.isPending.value" @click="act.mutate({ kind: 'accept', id: rule.id })">{{ t('rules.adoptAsWritten') }}</button>
        <button class="btn" type="button" :disabled="act.isPending.value" @click="dismiss">{{ t('rules.dismiss') }}</button>
      </div>
      <p class="hint">{{ t('rules.suggestedHint') }}</p>
    </template>

    <!-- Review queued or running -->
    <div v-else-if="reviewing" class="help"><p>{{ rule.status === 'analyzing' ? t('rules.analyzing') : t('rules.pending') }}</p></div>

    <!-- Questions from the review -->
    <form v-else-if="rule.status === 'questions'" class="sec" @submit.prevent="submitAnswers">
      <h3>{{ t('rules.questionsTitle', { n: open.length }) }}</h3>
      <p class="sub">{{ t('rules.questionsSub') }}</p>
      <div v-for="(q, i) in open" :key="q.index" class="q">
        <p>{{ q.text }}</p>
        <div v-if="q.options.length" class="tabs" role="group">
          <button v-for="o in q.options" :key="o" type="button" class="tab" :aria-pressed="answers[q.index].answer === o" @click="answers[q.index].answer = o">{{ o }}</button>
        </div>
        <input v-model="answers[q.index].answer" class="cfg-in" :placeholder="t('rules.yourAnswer')" :aria-label="t('rules.answerFor', { n: i + 1 })">
        <textarea v-model="answers[q.index].note" :placeholder="t('rules.addDetails')" :aria-label="t('rules.detailsFor', { n: i + 1 })" />
      </div>
      <div class="actions">
        <button class="btn btn-p" type="submit" :disabled="left > 0 || act.isPending.value">{{ t('rules.sendAnswers') }}</button>
        <button class="btn" type="button" :disabled="act.isPending.value" @click="accept">{{ t('rules.accept') }}</button>
        <span class="hint">{{ left ? t('rules.questionsLeft', { n: left }) : t('rules.allAnswered') }}</span>
      </div>
    </form>

    <!-- Review failed -->
    <template v-else-if="rule.status === 'failed'">
      <div class="help bad"><p class="err-text">{{ t('rules.failed', { error: rule.error }) }}</p><CopyButton v-if="rule.error" :text="rule.error" /></div>
      <div class="actions">
        <button class="btn btn-p" type="button" :disabled="act.isPending.value" @click="act.mutate({ kind: 'review', id: rule.id })">{{ t('rules.reviewAgain') }}</button>
        <button class="btn" type="button" :disabled="act.isPending.value" @click="accept">{{ t('rules.accept') }}</button>
      </div>
    </template>

    <!-- Clear: what tickets get -->
    <template v-else-if="rule.status === 'ready'">
      <div v-if="rule.interpretation" class="sec">
        <h3>{{ t('rules.interpretation') }}</h3>
        <p class="rule-text">{{ rule.interpretation }}</p>
      </div>
      <div v-if="rule.text !== rule.body" class="sec">
        <h3>{{ t('rules.clarified') }}</h3>
        <p class="rule-text">{{ rule.text }}</p>
      </div>
      <p v-if="!rule.interpretation" class="hint">{{ t('rules.asWritten') }}</p>
    </template>

    <details v-if="answered.length && rule.status !== 'questions'" class="sec">
      <summary>{{ t('rules.answersTitle', { n: answered.length }) }}</summary>
      <div v-for="q in answered" :key="q.index" class="ans">
        <span class="qq">{{ q.text }}</span>
        <span><b>{{ q.answer }}</b><template v-if="q.note">. {{ q.note }}</template></span>
      </div>
    </details>

    <div class="rule-foot">
      <span class="tkey">{{ rule.analyzedAt ? t('rules.reviewedAgo', { ago: ago(rule.analyzedAt, locale) }) : t('rules.addedAgo', { ago: ago(rule.createdAt, locale) }) }}</span>
      <button v-if="rule.status === 'ready' || rule.status === 'questions'" type="button" class="btn btn-s" :disabled="act.isPending.value" @click="act.mutate({ kind: 'review', id: rule.id })">{{ t('rules.reviewAgain') }}</button>
    </div>
  </section>
</template>

<style scoped>
.rule.off { opacity: 0.72; }
.rule-h { align-items: flex-start; gap: 12px; flex-wrap: wrap; }
.rule-head { display: flex; flex-direction: column; gap: 6px; min-width: 0; flex: 1; }
.rule-head h2 { margin: 0; overflow-wrap: anywhere; }
.rule-tools { display: flex; gap: 8px; align-items: center; }
.rule-body, .rule-text { white-space: pre-wrap; overflow-wrap: anywhere; max-width: 80ch; margin: 0 0 12px; }
.rule-body { padding: 12px 14px; background: var(--field); border: 1px solid var(--line-2); border-radius: 10px; }
.rule-foot { display: flex; align-items: center; justify-content: space-between; gap: 10px; margin-top: 12px; }
details summary { cursor: pointer; font-weight: 700; }
</style>
