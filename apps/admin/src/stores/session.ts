import { defineStore } from 'pinia'
import { ref } from 'vue'
import { api, unwrap, type User } from '../api/client'

/** The signed-in user. The session itself lives in an HttpOnly cookie. */
export const useSession = defineStore('session', () => {
  const user = ref<User | null>(null)
  const checked = ref(false)

  /** Asks the server who we are; resolves to null when signed out. */
  async function load(): Promise<User | null> {
    try {
      user.value = await unwrap(api.GET('/auth/me'))
    } catch {
      user.value = null
    }
    checked.value = true
    return user.value
  }

  async function login(username: string, password: string, code: string) {
    const res = await unwrap(api.POST('/auth/login', { body: { username, password, code, client: 'web' } }))
    user.value = res.user
    checked.value = true
  }

  async function logout() {
    try {
      await api.POST('/auth/logout')
    } finally {
      user.value = null
    }
  }

  return { user, checked, load, login, logout }
})
