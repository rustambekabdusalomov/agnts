<template>
  <header class="p-hd1">
    <a href="#top" class="p-link p-hd2">
      <img class="p-hd3" src="/wordmark.svg" alt="agnts" width="86" height="25" />
    </a>
    <nav class="p-nav p-hd5" :aria-label="t('aria.main')">
      <a class="p-link" href="#how"><span>{{ t('nav.how') }}</span></a>
      <a class="p-link" href="#connectors"><span>{{ t('nav.connectors') }}</span></a>
      <a class="p-link" href="#savings"><span>{{ t('nav.savings') }}</span></a>
      <a class="p-link" href="#privacy"><span>{{ t('nav.privacy') }}</span></a>
      <a class="p-link" href="#about"><span>{{ t('nav.about') }}</span></a>
      <a class="p-link" href="#pricing"><span>{{ t('nav.pricing') }}</span></a>
      <a class="p-link" href="#faq"><span>{{ t('nav.faq') }}</span></a>
    </nav>
    <div class="p-hright">
      <LandingLangSwitch />
      <button type="button" class="p-signin" @click="signIn.show()">{{ t('nav.signIn') }}</button>
    </div>
  </header>
</template>

<script setup lang="ts">
const { t } = useI18n()
const signIn = useSignIn()
</script>
