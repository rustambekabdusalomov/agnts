<template>
  <footer class="p-ft1">
    <span class="p-ft2"><img class="p-ft3" src="/wordmark.svg" alt="agnts" width="69" height="20" /><span>{{ t('footer.tagline') }}</span></span>
    <nav class="p-ft5" :aria-label="t('aria.footer')">
      <a class="p-link" href="#how"><span>{{ t('nav.how') }}</span></a>
      <a class="p-link" href="#privacy"><span>{{ t('nav.privacy') }}</span></a>
      <a class="p-link" href="#pricing"><span>{{ t('nav.pricing') }}</span></a>
      <a class="p-link" href="#faq"><span>{{ t('nav.faq') }}</span></a>
      <a class="p-link" href="https://t.me/agnts_uz" target="_blank" rel="noopener"><span>{{ t('social.channel') }}</span></a>
      <a class="p-link" href="https://t.me/agnts_community" target="_blank" rel="noopener"><span>{{ t('social.community') }}</span></a>
    </nav>
    <span>{{ t('footer.made') }}</span>
  </footer>
</template>

<script setup lang="ts">
const { t } = useI18n()
</script>
