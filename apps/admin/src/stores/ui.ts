import { defineStore } from 'pinia'
import { ref } from 'vue'

/** Cross-page UI state: the top-bar search and the toast. */
export const useUi = defineStore('ui', () => {
  const search = ref('')
  const toast = ref('')
  let timer: ReturnType<typeof setTimeout> | undefined

  function notify(msg: string) {
    toast.value = msg
    clearTimeout(timer)
    timer = setTimeout(() => (toast.value = ''), 2600)
  }
  return { search, toast, notify }
})
