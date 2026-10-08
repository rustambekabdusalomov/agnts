<script setup lang="ts">
import QRCode from 'qrcode'
import { ref, watchEffect } from 'vue'
import { useI18n } from 'vue-i18n'

// A two-factor secret to add to an authenticator app: a QR code of its
// otpauth:// URL, and the secret itself for typing in by hand.
const props = defineProps<{ url: string; secret: string }>()
const { t } = useI18n()
const svg = ref('')

watchEffect(async () => {
  // Drawn locally: the secret never leaves the browser for a QR service.
  svg.value = await QRCode.toString(props.url, { type: 'svg', margin: 1, errorCorrectionLevel: 'M' })
})
</script>

<template>
  <div class="totp-qr">
    <!-- eslint-disable-next-line vue/no-v-html -- an SVG the qrcode library drew from our own otpauth URL -->
    <div class="totp-qr-img" role="img" :aria-label="t('account.totpScan')" v-html="svg" />
    <div class="totp-qr-key">
      <span class="cfg-lbl">{{ t('account.totpSecret') }}</span>
      <code class="mono-box">{{ secret }}</code>
    </div>
  </div>
</template>
