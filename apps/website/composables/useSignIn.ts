/**
 * Sign-in with Google. The website only shows Google's button: the ID token it returns is posted, as
 * a form, to the agnts server (`appUrl`), which signs the person in (registering new people as solo
 * developers) and opens the admin panel. A failed sign-in comes back here with `?signin=<reason>`.
 */
export type SignInError = 'failed' | 'closed' | 'rate_limited' | 'unavailable' | 'not_configured'

const REASONS: readonly SignInError[] = ['failed', 'closed', 'rate_limited', 'unavailable']

interface GoogleId {
  initialize(o: { client_id: string, callback: (r: { credential: string }) => void, ux_mode: 'popup' }): void
  renderButton(el: HTMLElement, o: Record<string, unknown>): void
}
declare global {
  interface Window { google?: { accounts: { id: GoogleId } } }
}

let script: Promise<boolean> | undefined

/** Loads Google Identity Services once; resolves false when it cannot be loaded. */
function loadGoogle(): Promise<boolean> {
  script ??= new Promise<boolean>((resolve) => {
    if (window.google?.accounts) return resolve(true)
    const s = document.createElement('script')
    s.src = 'https://accounts.google.com/gsi/client'
    s.async = true
    s.onload = () => resolve(true)
    s.onerror = () => { script = undefined; resolve(false) }
    document.head.appendChild(s)
  })
  return script
}

/** Sends the credential to the server with a top-level form post, so its session cookie is set there. */
function submit(appUrl: string, credential: string) {
  const form = document.createElement('form')
  form.method = 'POST'
  form.action = `${appUrl.replace(/\/+$/, '')}/auth/google`
  const input = document.createElement('input')
  input.type = 'hidden'
  input.name = 'credential'
  input.value = credential
  form.appendChild(input)
  document.body.appendChild(form)
  form.submit()
}

export function useSignIn() {
  const open = useState('signin-open', () => false)
  const error = useState<SignInError | null>('signin-error', () => null)
  const busy = useState('signin-busy', () => false)
  const { googleClientId, appUrl } = useRuntimeConfig().public
  const configured = !!googleClientId && !!appUrl

  function show() {
    error.value = configured ? null : 'not_configured'
    open.value = true
  }

  /** Draws Google's button into `el` in `locale`; false when Google could not be reached. */
  async function renderButton(el: HTMLElement, locale: string): Promise<boolean> {
    if (!configured || !(await loadGoogle()) || !window.google) return false
    window.google.accounts.id.initialize({
      client_id: String(googleClientId),
      ux_mode: 'popup',
      callback: ({ credential }) => {
        busy.value = true
        submit(String(appUrl), credential)
      },
    })
    el.innerHTML = ''
    window.google.accounts.id.renderButton(el, {
      type: 'standard', theme: 'outline', size: 'large', shape: 'pill', text: 'continue_with', width: Math.min(320, el.clientWidth || 320), locale,
    })
    return true
  }

  /** Opens the dialog with the reason when the server sent the visitor back (?signin=...), and drops it from the URL. */
  function readReturn() {
    const url = new URL(window.location.href)
    const reason = url.searchParams.get('signin') as SignInError | null
    if (!reason) return
    url.searchParams.delete('signin')
    history.replaceState(history.state, '', url.pathname + url.search + url.hash)
    error.value = REASONS.includes(reason) ? reason : 'failed'
    open.value = true
  }

  return { open, error, busy, configured, show, renderButton, readReturn }
}
