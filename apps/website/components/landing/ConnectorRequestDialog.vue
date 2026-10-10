<template>
  <div v-if="open" class="p-sg" role="dialog" aria-modal="true" aria-labelledby="cr-title" @click.self="close">
    <div class="p-sg-box p-cr-box">
      <button ref="closeBtn" type="button" class="p-sg-x" :aria-label="t('signin.close')" @click="close">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18" /></svg>
      </button>
      <template v-if="sent">
        <h2 id="cr-title" class="p-sg-h">{{ t('connectors.request.sentTitle') }}</h2>
        <p class="p-sg-lede">{{ t('connectors.request.sentText') }}</p>
        <button type="button" class="p-btn p-cr-submit" @click="close"><span>{{ t('signin.close') }}</span></button>
      </template>
      <form v-else novalidate @submit.prevent="submit">
        <h2 id="cr-title" class="p-sg-h">{{ t('connectors.request.formTitle') }}</h2>
        <p class="p-sg-lede">{{ t('connectors.request.formLede') }}</p>
        <p v-if="error" class="p-sg-err" role="alert">{{ error }}</p>
        <label class="p-cr-f">
          <span>{{ t('connectors.request.tool') }} <b aria-hidden="true">*</b></span>
          <input v-model="form.tool" required maxlength="80" :placeholder="t('connectors.request.toolPh')" autocomplete="off">
        </label>
        <label class="p-cr-f">
          <span>{{ t('connectors.request.link') }}</span>
          <input v-model="form.link" type="url" maxlength="300" placeholder="https://" autocomplete="off">
        </label>
        <fieldset class="p-cr-f p-cr-hosting">
          <legend>{{ t('connectors.request.hosting') }}</legend>
          <label v-for="h in hostings" :key="h.value"><input v-model="form.hosting" type="radio" name="hosting" :value="h.value"> <span>{{ t(h.label) }}</span></label>
        </fieldset>
        <label class="p-cr-f">
          <span>{{ t('connectors.request.usage') }}</span>
          <textarea v-model="form.usage" rows="3" maxlength="3000" :placeholder="t('connectors.request.usagePh')"></textarea>
        </label>
        <div class="p-cr-row">
          <label class="p-cr-f">
            <span>{{ t('connectors.request.name') }}</span>
            <input v-model="form.name" maxlength="80" autocomplete="name">
          </label>
          <label class="p-cr-f">
            <span>{{ t('connectors.request.email') }} <b aria-hidden="true">*</b></span>
            <input v-model="form.email" type="email" required maxlength="254" autocomplete="email">
          </label>
        </div>
        <!-- People never see this field; bots that fill it in are ignored. -->
        <input v-model="form.website" class="p-cr-hp" tabindex="-1" autocomplete="off" aria-hidden="true" name="website">
        <button type="submit" class="p-btn p-cr-submit" :disabled="busy">
          <span>{{ busy ? t('connectors.request.sending') : t('connectors.request.send') }}</span>
        </button>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
const { t } = useI18n()
const { open } = useConnectorRequest()
const { appUrl } = useRuntimeConfig().public

const hostings = [
  { value: 'cloud', label: 'connectors.request.cloud' },
  { value: 'self-hosted', label: 'connectors.request.selfHosted' },
  { value: '', label: 'connectors.request.notSure' },
]
const blank = () => ({ tool: '', link: '', hosting: '', usage: '', name: '', email: '', website: '' })
const form = ref(blank())
const busy = ref(false)
const sent = ref(false)
const error = ref('')
const closeBtn = ref<HTMLButtonElement | null>(null)
let lastFocus: HTMLElement | null = null

function close() {
  open.value = false
}
function onKey(e: KeyboardEvent) {
  if (e.key === 'Escape') close()
}

async function submit() {
  error.value = ''
  if (!form.value.tool.trim() || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.value.email.trim())) {
    error.value = t('connectors.request.invalid')
    return
  }
  busy.value = true
  try {
    const res = await fetch(`${String(appUrl).replace(/\/+$/, '')}/site/connector-request`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form.value),
    })
    if (res.ok) {
      sent.value = true
      form.value = blank()
    } else {
      const body = await res.json().catch(() => null) as { message?: string } | null
      error.value = res.status === 429 ? t('connectors.request.tooMany') : body?.message || t('connectors.request.failed')
    }
  } catch {
    error.value = t('connectors.request.failed')
  } finally {
    busy.value = false
  }
}

watch(open, async (isOpen) => {
  if (isOpen) {
    sent.value = false
    error.value = ''
    lastFocus = document.activeElement as HTMLElement | null
    document.addEventListener('keydown', onKey)
    await nextTick()
    closeBtn.value?.focus()
  } else {
    document.removeEventListener('keydown', onKey)
    lastFocus?.focus()
  }
})
onBeforeUnmount(() => document.removeEventListener('keydown', onKey))
</script>

<style>
.p-cr-box{width:min(520px,100%);max-height:calc(100dvh - 32px);overflow-y:auto}
.p-cr-f{display:grid;gap:6px;margin:0 0 14px;font-size:14px;color:#333333;min-width:0}
.p-cr-f b{color:#FF713C;font-weight:500}
.p-cr-f input:not([type=radio]),.p-cr-f textarea{width:100%;box-sizing:border-box;border:1px solid #D9D9D9;border-radius:12px;padding:11px 13px;font:inherit;font-size:15px;color:#0A0A0A;background:#FFFFFF}
.p-cr-f textarea{resize:vertical;min-height:84px}
.p-cr-f input:not([type=radio]):focus-visible,.p-cr-f textarea:focus-visible{outline:2px solid #FF713C;outline-offset:1px;border-color:transparent}
.p-cr-hosting{border:none;padding:0;display:flex;flex-wrap:wrap;gap:8px 18px}
.p-cr-hosting legend{padding:0;margin-bottom:6px}
.p-cr-hosting label{display:inline-flex;align-items:center;gap:6px;cursor:pointer}
.p-cr-hosting input{margin:0;accent-color:#FF713C}
.p-cr-hosting input:focus-visible{outline:2px solid #FF713C;outline-offset:2px}
.p-cr-row{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:0 12px}
.p-cr-hp{position:absolute;left:-10000px;width:1px;height:1px;opacity:0}
.p-cr-submit{width:100%;justify-content:center;margin-top:4px;background:#0A0A0A;color:#FFFFFF;font-weight:500;font-size:15px;padding:14px 24px;border-radius:999px;min-height:48px;transition:background .2s ease,color .2s ease}
.p-cr-submit:hover:not(:disabled){background:#FF713C;color:#0A0A0A}
.p-cr-submit:disabled{opacity:.6;cursor:default}
.p-cr-submit:focus-visible{outline:2px solid #FF713C;outline-offset:3px}
@media (max-width:480px){.p-cr-row{grid-template-columns:minmax(0,1fr)}.p-sg-box.p-cr-box{padding:28px 20px 22px}}
</style>
