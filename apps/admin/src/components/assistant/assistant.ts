import { reactive } from 'vue'
import type { AssistantLanguage, AssistantMessage, TicketEvent } from '../../api/types'

type T = (key: string, values?: Record<string, unknown>) => string

export const MAX_QUESTION = 1000

/** What an answer being made reads and says, from live events, by message id. */
export const live = reactive(new Map<number, { file?: string; text?: string }>())

/** Keeps `live` up to date; pass it to useLive. */
export function applyLive(e: TicketEvent) {
  const id = Number(e.data?.message_id)
  if (!id) return
  const now = live.get(id) ?? {}
  switch (e.type) {
    case 'assistant_progress':
      live.set(id, { ...now, file: String(e.data.file ?? '') || undefined })
      break
    case 'assistant_partial':
      live.set(id, { ...now, text: String(e.data.text ?? '') || undefined })
      break
    case 'assistant_answered':
    case 'assistant_failed':
      live.delete(id)
  }
}

/** Whether the answer is still being made. */
export const isOpen = (m: AssistantMessage) => m.status === 'pending' || m.status === 'answering'

/** The language answers come in: the panel's. */
export function assistantLang(locale: string): AssistantLanguage {
  return locale === 'ru' || locale === 'uz' ? locale : 'en'
}

/** What the assistant reads, in words: "ci.json" -> "CI failures". */
export function fileLabel(t: T, file: string): string {
  if (file.startsWith('ticket-')) return t('massistant.fileTicket', { key: file.slice(7).replace(/\.json$/, '') })
  if (file.startsWith('ci')) return t('massistant.fileCi')
  const key = ({
    'inbox.json': 'fileInbox',
    'tickets.json': 'fileTickets',
    'usage.json': 'fileUsage',
    'analytics.json': 'fileAnalytics',
    'repositories.json': 'fileRepos',
    'lessons.json': 'fileLessons',
    'conversation.json': 'fileConversation',
    'question.txt': 'fileQuestion',
  } as Record<string, string>)[file]
  return t(`massistant.${key ?? 'fileOther'}`)
}

/** Seconds for a duration in milliseconds: 12000 -> "12s", 1500 -> "1.5s". */
export const secs = (ms: number) => `${(ms / 1000).toFixed(ms < 10_000 ? 1 : 0)}s`
