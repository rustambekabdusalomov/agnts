<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { PublicDocumentInfo } from '../../api/types'
import GoogleSignIn from '../account/GoogleSignIn.vue'

// "Who are you?" before a public document opens. Someone signed in to
// agnts is not asked: their account answers, and the form never shows.
// Everyone else types a name and enters; Google is there below for those
// who would rather show who they are. The answer is a guest of this one
// document; nobody is signed in by it.
const props = defineProps<{ token: string; info: PublicDocumentInfo }>()
const emit = defineEmits<{ joined: [guestToken: string] }>()
const { t } = useI18n()
const name = ref('')
const error = ref('')
const busy = ref(false)
// Asking the server whether the reader is signed in.
const checking = ref(true)

async function join(body: { name?: string; googleCredential?: string }, quiet = false) {
  busy.value = true
  error.value = ''
  try {
    const s = await unwrap(api.POST('/public/documents/{token}/guest', { params: { path: { token: props.token } }, body }))
    emit('joined', s.token)
  } catch (e) {
    if (!quiet) error.value = e instanceof HttpError ? e.message : t('common.error')
  } finally {
    busy.value = false
  }
}
onMounted(async () => {
  await join({}, true)
  checking.value = false
})
</script>

<template>
  <p v-if="checking" class="hint gg-wait">{{ t('common.loading') }}</p>
  <div v-else class="gg card">
    <p class="hint gg-kind">{{ info.kind === 'slides' ? t('documents.docKind_slides') : t('documents.docKind_page') }}</p>
    <h1>{{ info.title }}</h1>
    <h2>{{ t('documents.whoAreYou') }}</h2>
    <p class="hint">{{ t('documents.whoAreYouSub') }}</p>
    <form class="gg-form" @submit.prevent="join({ name })">
      <label for="gg-name" class="flbl">{{ t('documents.yourName') }}</label>
      <input id="gg-name" v-model="name" type="text" maxlength="60" autocomplete="name" :placeholder="t('documents.yourNamePlaceholder')">
      <button type="submit" class="btn btn-p" :disabled="busy || name.trim().length < 2">{{ t('documents.enter') }}</button>
    </form>
    <div v-if="info.googleClientId" class="gg-google">
      <p class="hint">{{ t('documents.orGoogle') }}</p>
      <GoogleSignIn :client-id="info.googleClientId" :on-credential="(c: string) => join({ googleCredential: c })" />
    </div>
    <span v-if="error" class="ferr" role="alert">{{ error }}</span>
  </div>
</template>

<style scoped>
.gg { max-width: 440px; margin: 48px auto; display: flex; flex-direction: column; gap: 10px; }
.gg h1 { margin: 0; font-size: 22px; line-height: 1.25; overflow-wrap: anywhere; }
.gg h2 { margin: 10px 0 0; font-size: 17px; }
.gg .hint { margin: 0; }
.gg-kind { font-size: 12.5px; text-transform: uppercase; letter-spacing: 0.04em; }
.gg-form { display: flex; flex-direction: column; gap: 8px; margin-top: 6px; }
.gg-wait { text-align: center; margin: 64px 0; }
.gg-google { margin-top: 10px; padding-top: 12px; border-top: 1px solid var(--line-2); display: flex; flex-direction: column; gap: 8px; }
.gg-form input { border: 1px solid var(--line-3); border-radius: 9px; padding: 10px 12px; font: inherit; background: var(--surface); }
</style>
