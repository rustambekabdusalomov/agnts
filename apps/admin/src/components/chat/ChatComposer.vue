<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { MAX_CHAT, type ChatMessage } from './chat'

// The message box: Enter sends, Shift+Enter starts a new line. A reply shows
// what it answers above the box, with a way to drop it.
const props = defineProps<{ channelName: string; replyTo?: ChatMessage }>()
const emit = defineEmits<{ send: [body: string]; cancelReply: [] }>()
const { t } = useI18n()

const text = ref('')
const box = ref<HTMLTextAreaElement | null>(null)
const length = computed(() => text.value.trim().length)
const over = computed(() => text.value.length > MAX_CHAT)

function submit() {
  const body = text.value.trim()
  if (!body || over.value) return
  emit('send', body)
  text.value = ''
}

function onKey(e: KeyboardEvent) {
  if (e.key === 'Enter' && !e.shiftKey && !e.isComposing) {
    e.preventDefault()
    submit()
  } else if (e.key === 'Escape' && props.replyTo) emit('cancelReply')
}

watch(
  () => props.replyTo,
  (r) => {
    if (r) void nextTick(() => box.value?.focus())
  },
)

defineExpose({ focus: () => box.value?.focus() })
</script>

<template>
  <form class="cp" @submit.prevent="submit">
    <div v-if="replyTo" class="cp-reply">
      <span>↪ {{ t('teamchat.replyingTo', { name: replyTo.author }) }}: <i>{{ (replyTo.body || replyTo.card?.title || '').slice(0, 100) }}</i></span>
      <button type="button" class="cp-x" :aria-label="t('teamchat.cancelReply')" @click="emit('cancelReply')">×</button>
    </div>
    <textarea
      ref="box"
      v-model="text"
      rows="2"
      :placeholder="t('teamchat.placeholder', { channel: channelName })"
      :aria-label="t('teamchat.placeholder', { channel: channelName })"
      @keydown="onKey"
    />
    <div class="cp-f">
      <span class="hint" :class="{ ferr: over }">{{ text.length > MAX_CHAT - 500 ? t('teamchat.count', { n: text.length, max: MAX_CHAT }) : t('teamchat.sendHint') }}</span>
      <button type="submit" class="btn btn-p" :disabled="!length || over">{{ t('teamchat.send') }}</button>
    </div>
  </form>
</template>

<style scoped>
.cp { border-top: 1px solid var(--line); padding: 12px 16px; display: flex; flex-direction: column; gap: 8px; }
.cp textarea { min-height: 48px; resize: none; }
.cp-f { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
.cp-reply { display: flex; align-items: center; gap: 8px; justify-content: space-between; padding: 4px 10px; border-left: 3px solid var(--primary); border-radius: 6px; background: var(--primary-soft); color: var(--primary-ink); font-size: 13px; }
.cp-reply span { min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.cp-x { border: 0; background: none; color: inherit; font-size: 18px; line-height: 1; cursor: pointer; }
</style>
