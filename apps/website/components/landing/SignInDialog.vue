<template>
  <div v-if="open" class="p-sg" role="dialog" aria-modal="true" aria-labelledby="signin-title" @click.self="close">
    <div class="p-sg-box">
      <button ref="closeBtn" type="button" class="p-sg-x" :aria-label="t('signin.close')" @click="close">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18" /></svg>
      </button>
      <img class="p-sg-logo" src="/wordmark.svg" alt="" width="69" height="20" />
      <h2 id="signin-title" class="p-sg-h">{{ t('signin.title') }}</h2>
      <p class="p-sg-lede">{{ t('signin.lede') }}</p>
      <p v-if="error" class="p-sg-err" role="alert">{{ t(`signin.errors.${error}`) }}</p>
      <div v-show="!busy && googleReady" ref="slot" class="p-sg-btn"></div>
      <p v-if="busy" class="p-sg-wait" role="status">{{ t('signin.redirecting') }}</p>
      <p v-else-if="configured && !googleReady && !loading" class="p-sg-err" role="alert">{{ t('signin.errors.google') }}</p>
      <ul class="p-sg-list">
        <li><span class="p-chk" aria-hidden="true"></span><span>{{ t('signin.p1') }}</span></li>
        <li><span class="p-chk" aria-hidden="true"></span><span>{{ t('signin.p2') }}</span></li>
      </ul>
      <p class="p-sg-fine">{{ t('signin.fine') }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
const { t, locale } = useI18n()
const { open, error, busy, configured, renderButton, readReturn } = useSignIn()

const slot = ref<HTMLElement | null>(null)
const closeBtn = ref<HTMLButtonElement | null>(null)
const googleReady = ref(false)
const loading = ref(false)
let lastFocus: HTMLElement | null = null

function close() {
  open.value = false
}

function onKey(e: KeyboardEvent) {
  if (e.key === 'Escape') close()
}

async function draw() {
  if (!slot.value || !configured) return
  loading.value = true
  googleReady.value = await renderButton(slot.value, locale.value)
  loading.value = false
}

watch(open, async (isOpen) => {
  if (isOpen) {
    lastFocus = document.activeElement as HTMLElement | null
    document.addEventListener('keydown', onKey)
    await nextTick()
    closeBtn.value?.focus()
    await draw()
  } else {
    document.removeEventListener('keydown', onKey)
    lastFocus?.focus()
  }
})
watch(locale, () => { if (open.value) draw() })

// Back from the server after a sign-in that did not work: show why.
onMounted(readReturn)
onBeforeUnmount(() => document.removeEventListener('keydown', onKey))
</script>

<style>
.p-sg{position:fixed;inset:0;z-index:60;display:grid;place-items:center;padding:16px;background:rgba(10,10,10,.45);font-family:var(--font-sans)}
.p-sg-box{position:relative;width:min(420px,100%);background:#FFFFFF;color:#0A0A0A;border-radius:20px;padding:32px 28px 26px;box-shadow:0 24px 60px rgba(0,0,0,.18)}
.p-sg-x{position:absolute;top:14px;right:14px;width:40px;height:40px;border:none;border-radius:50%;background:transparent;color:#555555;display:grid;place-items:center;cursor:pointer}
.p-sg-x:hover{background:#F5F5F5;color:#0A0A0A}
.p-sg-x:focus-visible{outline:2px solid #FF713C;outline-offset:2px}
.p-sg-logo{display:block;height:20px;width:auto}
.p-sg-h{margin:18px 0 6px;font-size:26px;line-height:1.15;font-weight:500;letter-spacing:-0.03em}
.p-sg-lede{margin:0 0 20px;font-size:15px;line-height:1.5;color:#555555}
.p-sg-btn{min-height:44px;display:flex;justify-content:center}
.p-sg-err{margin:0 0 16px;padding:10px 12px;border-radius:12px;background:#FFF1EB;color:#8A2E0B;font-size:14px;line-height:1.45}
.p-sg-wait{margin:0;min-height:44px;display:flex;align-items:center;justify-content:center;font-size:15px;color:#555555}
.p-sg-list{list-style:none;margin:20px 0 0;padding:0;display:grid;gap:8px;font-size:14px;color:#333333}
.p-sg-list li{display:flex;align-items:center;gap:10px}
.p-sg-fine{margin:16px 0 0;font-size:12.5px;line-height:1.5;color:#6B6B6B}
</style>
