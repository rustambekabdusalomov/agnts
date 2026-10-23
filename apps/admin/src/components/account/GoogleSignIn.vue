<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { usePrefs } from '../../stores/prefs'

// "Continue with Google": Google's own button. Its ID token is posted as a form to /auth/google, which
// signs the person in (registering new people as solo developers with a workspace of their own) and
// opens the panel. A failed sign-in comes back to /login?signin=<reason>.
// With an invite token the sign-in also joins that workspace and opens it.
// With onCredential the ID token goes there instead, and nobody is signed
// in (a guest of a public document says who they are with it); the page
// around it says what the button is for, so there is no "or" above it.
const props = defineProps<{ clientId: string; invite?: string; onCredential?: (credential: string) => void }>()

const { t, locale } = useI18n()
const prefs = usePrefs()
const slot = ref<HTMLElement | null>(null)
const ready = ref(false)
const failed = ref(false)
const redirecting = ref(false)

interface GoogleId {
  initialize(o: { client_id: string, callback: (r: { credential: string }) => void, ux_mode: 'popup' }): void
  renderButton(el: HTMLElement, o: Record<string, unknown>): void
}
type GoogleWindow = Window & { google?: { accounts: { id: GoogleId } } }

let script: Promise<boolean> | undefined
function load(): Promise<boolean> {
  script ??= new Promise<boolean>((resolve) => {
    if ((window as GoogleWindow).google?.accounts) return resolve(true)
    const s = document.createElement('script')
    s.src = 'https://accounts.google.com/gsi/client'
    s.async = true
    s.onload = () => resolve(true)
    s.onerror = () => { script = undefined; resolve(false) }
    document.head.appendChild(s)
  })
  return script
}

/** A top-level form post, so the session cookie it sets comes with the navigation. */
function submit(credential: string) {
  redirecting.value = true
  const form = document.createElement('form')
  form.method = 'POST'
  form.action = '/auth/google'
  const input = document.createElement('input')
  input.type = 'hidden'
  input.name = 'credential'
  input.value = credential
  form.appendChild(input)
  if (props.invite) {
    const inv = document.createElement('input')
    inv.type = 'hidden'
    inv.name = 'invite'
    inv.value = props.invite
    form.appendChild(inv)
  }
  document.body.appendChild(form)
  form.submit()
}

function dark(): boolean {
  if (prefs.theme !== 'system') return prefs.theme === 'dark'
  return window.matchMedia?.('(prefers-color-scheme: dark)').matches ?? false
}

async function draw() {
  const g = (await load()) ? (window as GoogleWindow).google : undefined
  if (!g || !slot.value) {
    failed.value = true
    return
  }
  g.accounts.id.initialize({ client_id: props.clientId, ux_mode: 'popup', callback: ({ credential }) => (props.onCredential ? props.onCredential(credential) : submit(credential)) })
  slot.value.innerHTML = ''
  g.accounts.id.renderButton(slot.value, {
    type: 'standard', theme: dark() ? 'filled_black' : 'outline', size: 'large', shape: 'pill', text: 'continue_with',
    width: Math.min(400, slot.value.clientWidth || 400), locale: locale.value,
  })
  ready.value = true
}

onMounted(draw)
// Google draws the button once; redraw it in the new language or theme.
const stop = watch([locale, () => prefs.theme], () => { if (ready.value) draw() })
onBeforeUnmount(stop)
</script>

<template>
  <div class="gsi">
    <div v-if="!invite && !onCredential" class="gsi-or" aria-hidden="true"><span>{{ t('auth.or') }}</span></div>
    <p v-if="redirecting" class="gsi-wait" role="status"><span class="spin" aria-hidden="true" />{{ t('auth.googleRedirecting') }}</p>
    <div v-show="!redirecting" ref="slot" class="gsi-btn" />
    <p v-if="failed" class="fhelp">{{ t('auth.googleUnavailable') }}</p>
  </div>
</template>
