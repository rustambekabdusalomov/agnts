/**
 * Scroll reveal for `.p-rev` blocks: those below the fold start hidden (`p-wait`) and fade in when
 * they scroll into view. Content stays visible if this never runs, and a timer reveals everything
 * after 5 s (as in the prototype).
 */
export function useScrollReveal(root: Ref<HTMLElement | null>) {
  let io: IntersectionObserver | undefined
  let timer: ReturnType<typeof setTimeout> | undefined

  onMounted(() => {
    const wrap = root.value
    if (!wrap || !('IntersectionObserver' in window)) return
    const vh = window.innerHeight || 800
    io = new IntersectionObserver((entries) => {
      entries.forEach((e) => {
        if (e.isIntersecting) {
          e.target.classList.remove('p-wait')
          io?.unobserve(e.target)
        }
      })
    }, { threshold: 0.1 })
    wrap.querySelectorAll('.p-rev').forEach((el) => {
      if (el.getBoundingClientRect().top > vh) {
        el.classList.add('p-wait')
        io?.observe(el)
      }
    })
    timer = setTimeout(() => wrap.querySelectorAll('.p-wait').forEach(el => el.classList.remove('p-wait')), 5000)
  })

  onBeforeUnmount(() => {
    io?.disconnect()
    clearTimeout(timer)
  })
}
