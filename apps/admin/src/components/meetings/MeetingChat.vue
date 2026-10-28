<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { HttpError } from '../../api/client'
import type { Call } from './useCall'

// The call's chat. Messages go through agnts (stored, checked for
// secrets) and come back through the room to everyone. Links open in a
// new tab; text is never treated as HTML.
const props = defineProps<{ call: Call }>()
const { t, locale } = useI18n()
const c = props.call
const draft = ref('')
const busy = ref(false)
const error = ref('')
const list = ref<HTMLElement | null>(null)

const canChat = computed(() => c.state.value?.rights.chat ?? c.grant.value?.rights.chat ?? false)

async function send() {
  const body = draft.value.trim()
  if (!body || busy.value) return
  busy.value = true
  error.value = ''
  try {
    await c.send(body)
    draft.value = ''
  } catch (e) {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  } finally {
    busy.value = false
  }
}

watch(
  () => c.messages.value.length,
  async () => {
    await nextTick()
    list.value?.scrollTo({ top: list.value.scrollHeight })
  },
  { immediate: true },
)

/** Text and links of a message, for safe rendering. */
function parts(body: string): { text: string; href?: string }[] {
  const out: { text: string; href?: string }[] = []
  const re = /https?:\/\/[^\s<>"]+/g
  let at = 0
  for (const m of body.matchAll(re)) {
    if (m.index! > at) out.push({ text: body.slice(at, m.index) })
    out.push({ text: m[0], href: m[0] })
    at = m.index! + m[0].length
  }
  if (at < body.length) out.push({ text: body.slice(at) })
  return out
}
const time = (iso: string) => new Date(iso).toLocaleTimeString(locale.value, { hour: '2-digit', minute: '2-digit' })
const mine = (person: string) => person === c.state.value?.me.key
</script>

<template>
  <div class="mc">
    <div ref="list" class="mc-list" aria-live="polite">
      <p v-if="!c.messages.value.length" class="hint mc-empty">{{ t('meetings.chatEmpty') }}</p>
      <div v-for="m in c.messages.value" :key="m.id" class="mc-msg" :class="{ mine: mine(m.person) }">
        <div class="mc-meta"><strong>{{ m.name }}</strong><span class="hint">{{ time(m.at) }}</span></div>
        <p class="mc-body">
          <template v-for="(p, i) in parts(m.body)" :key="i"><a v-if="p.href" :href="p.href" target="_blank" rel="noopener noreferrer">{{ p.text }}</a><template v-else>{{ p.text }}</template></template>
        </p>
      </div>
    </div>
    <form v-if="canChat" class="mc-form" @submit.prevent="send">
      <textarea v-model="draft" rows="2" maxlength="2000" :placeholder="t('meetings.chatPlaceholder')" @keydown.enter.exact.prevent="send" />
      <button type="submit" class="btn btn-p btn-s" :disabled="busy || !draft.trim()">{{ t('meetings.send') }}</button>
    </form>
    <p v-else class="hint">{{ t('meetings.chatOff') }}</p>
    <p v-if="error" class="ferr" role="alert">{{ error }}</p>
  </div>
</template>

<style scoped>
.mc { display: flex; flex-direction: column; gap: 10px; height: 100%; min-height: 0; }
.mc-list { flex: 1; overflow-y: auto; display: flex; flex-direction: column; gap: 10px; min-height: 0; }
.mc-empty { text-align: center; margin-top: 24px; }
.mc-msg { display: flex; flex-direction: column; gap: 2px; }
.mc-meta { display: flex; gap: 8px; align-items: baseline; font-size: 13px; }
.mc-meta .hint { font-size: 12px; }
.mc-body { margin: 0; font-size: 14px; white-space: pre-wrap; overflow-wrap: anywhere; }
.mc-msg.mine .mc-meta strong { color: var(--primary); }
.mc-form { display: flex; gap: 8px; align-items: flex-end; }
.mc-form textarea { flex: 1; resize: none; border: 1px solid var(--line-3); border-radius: 9px; padding: 8px 10px; font: inherit; background: var(--surface); }
</style>
