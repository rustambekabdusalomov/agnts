import { ref, watch, type Ref } from 'vue'
import { api, unwrap } from '../api/client'
import type { TicketEvent } from '../api/types'
import { useLive } from './useLive'

/** A ticket's events: loaded once, then appended from the live stream. */
export function useEventLog(key: Ref<string>) {
  const events = ref<TicketEvent[]>([])
  const error = ref<unknown>(null)
  let last = 0

  async function load() {
    events.value = []
    last = 0
    try {
      for (;;) {
        const batch = await unwrap(
          api.GET('/tickets/{key}/events', { params: { path: { key: key.value }, query: { after: last, limit: 1000 } } }),
        )
        if (batch.length) {
          last = batch[batch.length - 1].id
          events.value = events.value.concat(batch)
        }
        if (batch.length < 1000) break
      }
      error.value = null
    } catch (e) {
      error.value = e
    }
  }

  useLive((e) => {
    if (e.ticketKey === key.value && e.id > last) {
      last = e.id
      events.value = events.value.concat(e)
    }
  })
  watch(key, load, { immediate: true })
  return { events, error, reload: load }
}
