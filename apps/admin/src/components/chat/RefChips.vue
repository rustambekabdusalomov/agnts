<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useUi } from '../../stores/ui'
import { AI_NAME } from './AiBadge.vue'
import { secs, type ChatMessage, type ChatRef } from './chat'
import { removeRef } from './useChat'
import { useChatLinks } from './useChatLinks'

// The tickets, PRs, repositories and findings a message is about. The ones
// a model linked fade in and say so on hover; any can be removed.
const props = defineProps<{ message: ChatMessage }>()
const { t } = useI18n()
const ui = useUi()
const { target } = useChatLinks()
const busy = ref('')

const key = (r: ChatRef) => `${r.type}:${r.id}`

function label(r: ChatRef): string {
  if (r.label) return r.label
  if (r.type === 'finding') return t('teamchat.citeFinding', { id: r.id })
  return r.id
}

function tip(r: ChatRef): string {
  if (r.source !== 'model') return label(r)
  const base = t('teamchat.linkedBy', { name: AI_NAME, secs: r.ai ? secs(r.ai.ms) : '–' })
  return r.reason ? `${base} — ${r.reason}` : base
}

const chips = computed(() =>
  props.message.refs.map((r) => {
    const to = target(r.type, r.id, props.message.refs)
    return { r, key: key(r), label: label(r), tip: tip(r), route: to && 'route' in to ? to.route : undefined, url: to && 'url' in to ? to.url : undefined }
  }),
)

async function remove(r: ChatRef) {
  busy.value = key(r)
  try {
    await removeRef(props.message.id, r)
  } catch (e) {
    ui.notify(e instanceof Error ? e.message : t('common.error'))
  } finally {
    busy.value = ''
  }
}
</script>

<template>
  <div v-if="chips.length" class="refs">
    <span v-for="c in chips" :key="c.key" class="ref" :class="[c.r.type, c.r.source, { busy: busy === c.key }]" :title="c.tip">
      <RouterLink v-if="c.route" class="ref-a" :to="c.route"><span v-if="c.r.source === 'model'" aria-hidden="true">✨</span>{{ c.label }}</RouterLink>
      <a v-else-if="c.url" class="ref-a" :href="c.url" target="_blank" rel="noopener"><span v-if="c.r.source === 'model'" aria-hidden="true">✨</span>{{ c.label }}</a>
      <span v-else class="ref-a"><span v-if="c.r.source === 'model'" aria-hidden="true">✨</span>{{ c.label }}</span>
      <button type="button" class="ref-x" :aria-label="t('teamchat.removeLink', { name: c.label })" :disabled="!!busy" @click="remove(c.r)">×</button>
    </span>
  </div>
</template>
<style scoped>
.refs { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 6px; }
.ref { position: relative; display: inline-flex; align-items: center; border-radius: 999px; background: var(--gray-soft); color: var(--gray-ink); font-size: 12.5px; font-weight: 700; }
.ref.ticket, .ref.pr { font-family: var(--mono); }
.ref.model { background: var(--primary-soft); color: var(--primary-ink); animation: ref-in 0.9s ease-out both; }
.ref.busy { opacity: 0.5; }
.ref-a { display: inline-flex; gap: 3px; padding: 2px 10px; color: inherit; text-decoration: none; }
a.ref-a:hover { text-decoration: underline; }
.ref-x { width: 0; overflow: hidden; padding: 0; border: 0; background: none; color: inherit; cursor: pointer; font-size: 14px; line-height: 1; opacity: 0; transition: width 0.15s, opacity 0.15s, margin 0.15s; }
.ref:hover .ref-x, .ref-x:focus-visible { width: 16px; margin: 0 6px 0 -6px; opacity: 0.7; }
.ref-x:hover { opacity: 1; }
@keyframes ref-in { from { opacity: 0; transform: translateY(3px); } to { opacity: 1; transform: none; } }
</style>
