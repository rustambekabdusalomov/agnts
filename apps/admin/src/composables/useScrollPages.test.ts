import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { mount, flushPromises } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import { computed, defineComponent, h } from 'vue'
import { useScrollPages } from './useScrollPages'

type Item = { id: number }

// Pages of 2: page 2 repeats item 2 (a new item shifted it), page 3 is short.
const PAGES: Record<number, Item[]> = { 1: [{ id: 1 }, { id: 2 }], 2: [{ id: 2 }, { id: 3 }], 3: [{ id: 4 }] }

function setup() {
  const asked: number[] = []
  let api!: ReturnType<typeof useScrollPages<Item>>
  const C = defineComponent({
    setup() {
      api = useScrollPages<Item>({
        key: computed(() => ['test']),
        fetch: async (page) => (asked.push(page), PAGES[page] ?? []),
        perPage: 2,
        id: (x) => x.id,
      })
      return () => h('div')
    },
  })
  mount(C, { global: { plugins: [[VueQueryPlugin, { queryClient: new QueryClient() }]] } })
  return { asked, api: () => api }
}

describe('useScrollPages', () => {
  it('loads page by page, stops after a short page, and shows each item once', async () => {
    const { asked, api } = setup()
    await flushPromises()
    expect(api().all.value.map((x) => x.id)).toEqual([1, 2])
    expect(api().query.hasNextPage.value).toBe(true)

    api().more()
    await flushPromises()
    expect(api().all.value.map((x) => x.id)).toEqual([1, 2, 3])

    api().more()
    await flushPromises()
    expect(api().all.value.map((x) => x.id)).toEqual([1, 2, 3, 4])
    expect(api().query.hasNextPage.value).toBe(false)

    api().more() // nothing left: no request
    await flushPromises()
    expect(asked).toEqual([1, 2, 3])
  })
})
