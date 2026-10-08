import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { api, setWorkspace, unwrap } from '../api/client'
import type { components } from '../api/schema.gen'
import { restartLive } from '../composables/useLive'
import { queryClient } from '../queryClient'

export type WorkspaceDetail = components['schemas']['WorkspaceDetail']

/**
 * The workspace the panel acts in: the route's :ws. Switching empties the
 * query cache and reopens the live stream, so nothing of the previous
 * workspace shows in the next.
 */
export const useWorkspace = defineStore('workspace', () => {
  const slug = ref('')
  const detail = ref<WorkspaceDetail | null>(null)

  const isOwner = computed(() => detail.value?.role === 'owner')
  /** Viewers see everything but change nothing; the panel hides their actions. */
  const canEdit = computed(() => detail.value?.role !== 'viewer')
  const name = computed(() => detail.value?.name ?? slug.value)

  /** Opens workspace s; false when the person is not a member of it. */
  async function open(s: string): Promise<boolean> {
    if (s === slug.value && detail.value) return true
    const switching = slug.value !== '' && s !== slug.value
    setWorkspace(s)
    try {
      const d = await unwrap(api.GET('/workspace'))
      slug.value = s
      detail.value = d
    } catch {
      setWorkspace(slug.value)
      return false
    }
    if (switching) {
      queryClient.clear()
      restartLive()
    }
    return true
  }

  /** Reloads the current workspace (after a rename or a plan change). */
  async function refresh() {
    if (!slug.value) return
    detail.value = await unwrap(api.GET('/workspace'))
  }

  /** Forgets the workspace (signed out). */
  function reset() {
    slug.value = ''
    detail.value = null
    setWorkspace('')
  }

  return { slug, detail, isOwner, canEdit, name, open, refresh, reset }
})
