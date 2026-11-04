import { nextTick, onBeforeUnmount, ref, watch, type Ref } from 'vue'

/** Within this many pixels of the bottom, a chat follows what arrives. */
export const NEAR_BOTTOM = 80
/** Further up than this, the "scroll to the newest" button shows. */
export const FAR_FROM_BOTTOM = 300

/**
 * A chat's scroll position: whether it is near the bottom (and so follows
 * new messages), whether it is far enough up to offer a way back down, and
 * how to go there. follow() is called before the content changes (a
 * watcher with flush 'pre'): it keeps the chat at the bottom if it was
 * there, or always when forced (the person just sent something).
 */
export function useStickToBottom(scroller: Ref<HTMLElement | null>) {
  const far = ref(false)
  const distance = () => {
    const el = scroller.value
    return el ? el.scrollHeight - el.scrollTop - el.clientHeight : 0
  }
  const nearBottom = () => distance() < NEAR_BOTTOM
  const update = () => (far.value = distance() > FAR_FROM_BOTTOM)

  function toBottom(smooth = false) {
    const el = scroller.value
    if (!el) return
    if (smooth && typeof el.scrollTo === 'function') el.scrollTo({ top: el.scrollHeight, behavior: 'smooth' })
    else el.scrollTop = el.scrollHeight
    update()
  }

  function follow(force = false) {
    const stick = force || nearBottom()
    void nextTick(() => {
      if (stick) toBottom()
      update()
    })
  }

  // The scroller's own scrolling (the person's, or ours) updates far.
  let el: HTMLElement | null = null
  const onScroll = () => update()
  watch(
    scroller,
    (next) => {
      el?.removeEventListener('scroll', onScroll)
      el = next
      el?.addEventListener('scroll', onScroll, { passive: true })
      update()
    },
    { immediate: true },
  )
  onBeforeUnmount(() => el?.removeEventListener('scroll', onScroll))

  return { far, nearBottom, toBottom, follow, update }
}
