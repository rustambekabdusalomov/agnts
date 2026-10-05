import { useInfiniteQuery } from '@tanstack/vue-query'
import { computed, onBeforeUnmount, ref, watch, type Ref } from 'vue'

/**
 * A list loaded a page at a time (pages from 1), the next page when the
 * sentinel element scrolls into view. A page shorter than perPage is the
 * last. Items that new data shifts onto a later page appear once.
 */
export function useScrollPages<T>(opts: {
  key: Ref<unknown[]>
  fetch: (page: number) => Promise<T[]>
  perPage: number
  id: (item: T) => string | number
  refetchInterval?: number
}) {
  const query = useInfiniteQuery({
    queryKey: opts.key,
    queryFn: ({ pageParam }) => opts.fetch(pageParam),
    initialPageParam: 1,
    getNextPageParam: (last: T[], pages: T[][]) => (last.length === opts.perPage && pages.length < 1000 ? pages.length + 1 : undefined),
    refetchInterval: opts.refetchInterval,
  })
  const all = computed(() => {
    const seen = new Set<string | number>()
    return (query.data.value?.pages.flat() ?? []).filter((x) => {
      const k = opts.id(x as T)
      return !seen.has(k) && !!seen.add(k)
    }) as T[]
  })
  const more = () => {
    if (query.hasNextPage.value && !query.isFetchingNextPage.value) void query.fetchNextPage()
  }

  // Bind with :ref="sentinel" on an element or a component (its root element is watched).
  const target = ref<Element | null>(null)
  const sentinel = (x: unknown) => {
    target.value = x instanceof Element ? x : ((x as { $el?: Element } | null)?.$el ?? null)
  }
  // Without IntersectionObserver (old browsers, tests) the Load more button still works.
  const io =
    typeof IntersectionObserver === 'undefined'
      ? null
      : new IntersectionObserver((es) => es.some((e) => e.isIntersecting) && more(), { rootMargin: '400px' })
  watch(target, (el, old) => {
    if (old) io?.unobserve(old)
    if (el) io?.observe(el)
  })
  onBeforeUnmount(() => io?.disconnect())

  return { query, all, more, sentinel }
}
