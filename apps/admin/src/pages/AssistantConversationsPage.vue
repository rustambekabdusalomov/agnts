<script setup lang="ts">
import { useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../api/client'
import { stateKey, type AssistantConversation } from '../api/types'
import { isOpen } from '../components/assistant/assistant'
import SearchSnippet from '../components/chat/SearchSnippet.vue'
import PageHeader from '../components/PageHeader.vue'
import HiIcon from '../components/ui/HiIcon.vue'
import { ago } from '../composables/format'
import { askConfirm } from '../composables/useConfirm'
import { livePoll, useLive } from '../composables/useLive'

// The person's assistant conversations, newest first: open one in the
// chat, or delete it. Nobody else sees them; they are kept for 30 days.
const { t, locale } = useI18n()
const qc = useQueryClient()
useLive()

const list = useQuery({
  queryKey: ['assistant', 'list'],
  queryFn: () => unwrap(api.GET('/assistant/conversations')),
  refetchInterval: () => livePoll(60_000),
})

// Search: the person's messages (both modes) and their files' names.
const q = ref('')
const qSlow = ref('')
let qTimer: ReturnType<typeof setTimeout> | undefined
watch(q, (v) => {
  clearTimeout(qTimer)
  qTimer = setTimeout(() => (qSlow.value = v.trim()), 250)
})
const searching = computed(() => q.value.trim().length > 0)
const found = useQuery({
  queryKey: computed(() => ['assistant', 'search', qSlow.value]),
  queryFn: () => unwrap(api.GET('/assistant/search', { params: { query: { q: qSlow.value } } })),
  enabled: computed(() => qSlow.value.length >= 2),
  staleTime: 10_000,
})

/** The last message, as plain text. */
const preview = (c: AssistantConversation) => (c.messages.at(-1)?.text ?? '').replace(/[#*_`>]/g, '').replace(/\s+/g, ' ').trim()
const last = (c: AssistantConversation) => c.messages.at(-1)

async function remove(c: AssistantConversation) {
  if (!(await askConfirm({ title: t('massistant.deleteTitle'), message: t('massistant.deleteText'), confirmLabel: t('massistant.delete'), danger: true }))) return
  await unwrap(api.DELETE('/assistant/conversations/{conversationId}', { params: { path: { conversationId: c.id } } }))
  qc.removeQueries({ queryKey: ['assistant', 'conversation', c.id] })
  await qc.invalidateQueries({ queryKey: ['assistant', 'list'] })
}
</script>

<template>
  <PageHeader :title="t('nav.assistantConversations')">
    <div class="actions" style="margin: 0">
      <RouterLink class="btn btn-p" :to="{ name: 'assistant' }"><HiIcon name="plus" />{{ t('massistant.newConversation') }}</RouterLink>
    </div>
    <template #below><p class="sub" style="margin: 4px 0 0">{{ t('massistant.conversationsLede') }}</p></template>
  </PageHeader>

  <section class="card">
    <input
      v-model="q"
      type="search"
      class="cv-search"
      :placeholder="t('massistant.search')"
      :aria-label="t('massistant.search')"
      @keydown.esc="q = ''"
    >
    <template v-if="searching">
      <p v-if="q.trim().length < 2" class="hint">{{ t('teamchat.searchShort') }}</p>
      <p v-else-if="found.isFetching.value && !found.data.value" class="hint">{{ t('common.loading') }}</p>
      <p v-else-if="found.isError.value" class="ferr">{{ found.error.value?.message || t('common.error') }}</p>
      <p v-else-if="found.data.value && !found.data.value.length" class="hint">{{ t('massistant.searchNone', { q: qSlow }) }}</p>
      <ul v-if="q.trim().length >= 2 && found.data.value?.length" class="cv-list">
        <li v-for="h in found.data.value" :key="h.messageId">
          <RouterLink
            class="cv-open"
            :to="{ name: h.mode === 'code' ? 'assistantCode' : 'assistant', params: { id: h.conversationId }, query: h.mode === 'code' ? {} : { msg: h.messageId } }"
          >
            <span class="cv-title">
              <span v-if="h.mode === 'code'" class="badge b-info cv-mode"><HiIcon name="code" />{{ t('codechat.codeBadge') }}</span>
              {{ h.title }}
            </span>
            <span class="cv-prev cv-hit"><b>{{ h.role === 'user' ? t('massistant.you') : t('massistant.answer') }}:</b> <SearchSnippet :text="h.snippet" /></span>
          </RouterLink>
          <span class="hint cv-when">{{ ago(h.createdAt, locale) }}</span>
        </li>
      </ul>
    </template>
    <template v-else>
      <p v-if="list.isPending.value" class="hint">{{ t('common.loading') }}</p>
      <p v-else-if="list.isError.value" class="ferr">{{ t('common.error') }}</p>
      <div v-else-if="!list.data.value?.length" class="cv-empty">
        <p>{{ t('massistant.historyEmpty') }}</p>
        <RouterLink class="btn" :to="{ name: 'assistant' }"><HiIcon name="assistant" />{{ t('massistant.openChat') }}</RouterLink>
      </div>
      <ul v-else class="cv-list">
        <li v-for="c in list.data.value" :key="c.id">
          <RouterLink class="cv-open" :to="{ name: c.mode === 'code' ? 'assistantCode' : 'assistant', params: { id: c.id } }">
            <span class="cv-title">
              <span v-if="c.mode === 'code'" class="badge b-info cv-mode"><HiIcon name="code" />{{ t('codechat.codeBadge') }}</span>
              {{ c.title }}
              <span v-if="c.mode === 'code' && c.tickets?.[0]" class="cv-ticket mono">{{ c.tickets[0].key }} · {{ t(stateKey(c.tickets[0].state, c.tickets[0].kind)) }}</span>
            </span>
            <span v-if="last(c) && isOpen(last(c)!)" class="cv-prev">{{ t('massistant.thinking', { seconds: '…' }) }}</span>
            <span v-else-if="last(c)?.status === 'failed'" class="cv-prev bad">{{ t('massistant.failed') }}</span>
            <span v-else-if="preview(c)" class="cv-prev">{{ preview(c) }}</span>
          </RouterLink>
          <span class="hint cv-when">{{ ago(c.updatedAt, locale) }}</span>
          <button type="button" class="btn btn-s btn-d" :aria-label="`${t('massistant.delete')}: ${c.title}`" @click="remove(c)">{{ t('massistant.delete') }}</button>
        </li>
      </ul>
    </template>
  </section>
</template>

<style scoped>
.cv-search { width: 100%; max-width: 420px; height: 36px; padding: 0 12px; margin-bottom: 10px; }
.cv-hit { white-space: normal; }
.cv-empty { display: flex; flex-direction: column; align-items: flex-start; gap: 10px; }
.cv-empty p { margin: 0; }
.cv-list { list-style: none; margin: 0; padding: 0; }
.cv-list li { display: flex; align-items: center; gap: 12px; padding: 10px 4px; border-bottom: 1px solid var(--line); }
.cv-list li:last-child { border-bottom: 0; }
.cv-open { flex: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px; padding: 4px 8px; border-radius: 10px; color: var(--ink); text-decoration: none; }
.cv-open:hover { background: var(--hover); }
.cv-title { font-weight: 700; font-size: 15px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.cv-mode { display: inline-flex; align-items: center; gap: 4px; margin-right: 6px; vertical-align: 1px; }
.cv-mode svg { width: 13px; height: 13px; }
.cv-ticket { margin-left: 8px; font-weight: 400; font-size: 12.5px; color: var(--ink-3); }
.cv-prev { font-size: 13.5px; color: var(--ink-3); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.cv-prev.bad { color: var(--bad-ink); }
.cv-when { flex: none; white-space: nowrap; }
@media (max-width: 700px) { .cv-when { display: none; } }
</style>
