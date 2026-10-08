import { defineStore } from 'pinia'
import { ref } from 'vue'
import { api, HttpError, unwrap, type User } from '../api/client'

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

  /**
   * Signs in. Returns what is still needed: 'code' for an account with
   * two-factor sign-in (the server answered code_required), 'setup' for an
   * Admin who must turn it on first (totp_setup_required; sign in again with
   * the new secret and a code), or null once signed in.
   */
  async function login(username: string, password: string, code: string, totpSecret?: string): Promise<'code' | 'setup' | null> {
    try {
      const res = await unwrap(api.POST('/auth/login', {
        body: { username, password, ...(code ? { code } : {}), ...(totpSecret ? { totpSecret } : {}), client: 'web' },
      }))
      user.value = res.user
      checked.value = true
      return null
    } catch (e) {
      if (e instanceof HttpError && e.code === 'code_required') return 'code'
      if (e instanceof HttpError && e.code === 'totp_setup_required') return 'setup'
      throw e
    }
  }

  async function logout() {
    try {
      await api.POST('/auth/logout')
    } finally {
      user.value = null
    }
  }

  /** The workspace to open: the last one, else the first. */
  function homeWorkspace(): string {
    const u = user.value
    if (!u) return ''
    if (u.lastWorkspace && u.workspaces?.some((w) => w.slug === u.lastWorkspace)) return u.lastWorkspace
    return u.workspaces?.[0]?.slug ?? ''
  }

  return { user, checked, load, login, logout, homeWorkspace }
})
