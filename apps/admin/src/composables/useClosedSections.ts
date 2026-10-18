import { ref } from 'vue'

// The ticket page's sections a person closed (by id: "diff", "notes"),
// kept in this browser: closed once, a section stays closed on every
// ticket until it is opened again. Storage may be off (a private window):
// then it lasts until the page reloads.
const KEY = 'ticketSectionsClosed'

function load(): Set<string> {
  try {
    const v = JSON.parse(localStorage.getItem(KEY) ?? '[]')
    return new Set(Array.isArray(v) ? v.filter((x): x is string => typeof x === 'string') : [])
  } catch {
    return new Set()
  }
}

const closed = ref(load())

export function useClosedSections() {
  function toggle(id: string) {
    const next = new Set(closed.value)
    if (!next.delete(id)) next.add(id)
    closed.value = next
    try {
      localStorage.setItem(KEY, JSON.stringify([...next]))
    } catch {
      // kept for this page only
    }
  }
  return { closed, toggle, isOpen: (id: string) => !closed.value.has(id) }
}
