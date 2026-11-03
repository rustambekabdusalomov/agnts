<script setup lang="ts">
import DOMPurify from 'dompurify'
import { marked } from 'marked'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter, type RouteLocationRaw } from 'vue-router'
import type { ChatRef } from './chat'
import { escapeHtml, replaceCitations, type Citation } from './citations'
import { useChatLinks } from './useChatLinks'

// Markdown, sanitised (anyone's text, or a model's). With cite, each
// citation token ([msg:812], [ticket:PAY-1] …) becomes a chip: ticket, repo
// and finding open their page, pr its URL. A message jumps to it in the team
// chat (emits jump); in the assistant (assistant), where the message is not
// on screen, it opens the Chat page at it, and a pr without a known URL
// stays plain.
const props = defineProps<{ body: string; refs?: ChatRef[]; cite?: boolean; assistant?: boolean }>()
const emit = defineEmits<{ jump: [id: number] }>()
const { t } = useI18n()
const router = useRouter()
const { target } = useChatLinks()

function label(c: Citation): string {
  if (c.kind === 'msg') return t('teamchat.citeMsg', { id: c.id })
  if (c.kind === 'finding') return t('teamchat.citeFinding', { id: c.id })
  return c.id
}

/** Where a chip leads: a URL, a page here, or nowhere. */
function dest(c: Citation): { url: string } | { route: RouteLocationRaw } | null {
  if (c.kind === 'msg') return props.assistant ? { route: { name: 'chat', query: { msg: c.id } } } : null
  const to = target(c.kind, c.id, props.refs ?? [])
  if (props.assistant && c.kind === 'pr' && to && !('url' in to)) return null
  return to
}

function chip(c: Citation): string {
  const to = dest(c)
  let href = ''
  if (c.kind === 'msg' && !props.assistant) href = `#chat-msg-${encodeURIComponent(c.id)}`
  else if (to && 'url' in to) href = to.url
  else if (to) href = router.resolve(to.route).href
  const attrs = `class="cite cite-${c.kind}" data-cite-kind="${c.kind}" data-cite-id="${escapeHtml(c.id)}"`
  return href ? `<a ${attrs} href="${escapeHtml(href)}">${escapeHtml(label(c))}</a>` : `<span ${attrs}>${escapeHtml(label(c))}</span>`
}

const html = computed(() => {
  const src = props.cite ? replaceCitations(props.body, chip) : props.body
  return DOMPurify.sanitize(marked.parse(src, { async: false, gfm: true, breaks: !props.assistant }))
})

function onClick(e: MouseEvent) {
  const a = (e.target as HTMLElement).closest<HTMLAnchorElement>('a')
  if (!a) return
  const kind = a.dataset.citeKind as Citation['kind'] | undefined
  if (!kind) {
    // Links in the text (file citations, URLs) open beside the chat.
    if (/^https?:/.test(a.getAttribute('href') ?? '')) {
      a.target = '_blank'
      a.rel = 'noopener'
    }
    return
  }
  if (e.metaKey || e.ctrlKey || e.shiftKey || e.button !== 0) return
  e.preventDefault()
  const id = a.dataset.citeId ?? ''
  if (kind === 'msg' && !props.assistant) {
    emit('jump', Number(id))
    return
  }
  const to = dest({ kind, id, raw: '' })
  if (!to) return
  if ('url' in to) window.open(to.url, '_blank', 'noopener')
  else void router.push(to.route)
}
</script>

<template>
  <!-- eslint-disable-next-line vue/no-v-html -- sanitised above -->
  <div class="report cited" :class="{ 'chat-md': !assistant }" @click="onClick" v-html="html" />
</template>

<style scoped>
.chat-md { overflow-wrap: anywhere; }
.chat-md :deep(p) { margin: 0 0 6px; }
.chat-md :deep(p:last-child) { margin-bottom: 0; }
.cited :deep(.cite) { display: inline-block; padding: 0 8px; margin: 0 1px; border-radius: 999px; background: var(--primary-soft); color: var(--primary-ink); font-size: 12.5px; font-weight: 700; line-height: 1.6; text-decoration: none; vertical-align: baseline; }
.cited :deep(a.cite:hover) { text-decoration: underline; }
.cited :deep(.cite-ticket), .cited :deep(.cite-pr) { font-family: var(--mono); }
</style>
