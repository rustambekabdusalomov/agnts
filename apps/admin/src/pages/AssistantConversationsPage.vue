<script setup lang="ts">
import { useQuery, useQueryClient } from '@tanstack/vue-query'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../api/client'
import type { AssistantConversation } from '../api/types'
import { isOpen } from '../components/assistant/assistant'
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
    <p v-if="list.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="list.isError.value" class="ferr">{{ t('common.error') }}</p>
    <div v-else-if="!list.data.value?.length" class="cv-empty">
      <p>{{ t('massistant.historyEmpty') }}</p>
      <RouterLink class="btn" :to="{ name: 'assistant' }"><HiIcon name="assistant" />{{ t('massistant.openChat') }}</RouterLink>
    </div>
    <ul v-else class="cv-list">
      <li v-for="c in list.data.value" :key="c.id">
        <RouterLink class="cv-open" :to="{ name: 'assistant', params: { id: c.id } }">
          <span class="cv-title">{{ c.title }}</span>
          <span v-if="last(c) && isOpen(last(c)!)" class="cv-prev">{{ t('massistant.thinking', { seconds: '…' }) }}</span>
          <span v-else-if="last(c)?.status === 'failed'" class="cv-prev bad">{{ t('massistant.failed') }}</span>
          <span v-else-if="preview(c)" class="cv-prev">{{ preview(c) }}</span>
        </RouterLink>
        <span class="hint cv-when">{{ ago(c.updatedAt, locale) }}</span>
        <button type="button" class="btn btn-s btn-d" :aria-label="`${t('massistant.delete')}: ${c.title}`" @click="remove(c)">{{ t('massistant.delete') }}</button>
      </li>
    </ul>
  </section>
</template>

<style scoped>
.cv-empty { display: flex; flex-direction: column; align-items: flex-start; gap: 10px; }
.cv-empty p { margin: 0; }
.cv-list { list-style: none; margin: 0; padding: 0; }
.cv-list li { display: flex; align-items: center; gap: 12px; padding: 10px 4px; border-bottom: 1px solid var(--line); }
.cv-list li:last-child { border-bottom: 0; }
.cv-open { flex: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px; padding: 4px 8px; border-radius: 10px; color: var(--ink); text-decoration: none; }
.cv-open:hover { background: var(--hover); }
.cv-title { font-weight: 700; font-size: 15px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.cv-prev { font-size: 13.5px; color: var(--ink-3); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.cv-prev.bad { color: var(--bad-ink); }
.cv-when { flex: none; white-space: nowrap; }
@media (max-width: 700px) { .cv-when { display: none; } }
</style>
