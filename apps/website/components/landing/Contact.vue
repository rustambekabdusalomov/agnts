<template>
  <section class="p-contact1" id="contact">
    <div class="p-contact2">
      <h2 class="p-cta p-rev p-contact3"><template v-if="t('contact.title1')"><span>{{ t('contact.title1') }}</span>{{ ' ' }}</template><span class="p-contact4"><span>{{ t('contact.title2') }}</span></span><template v-if="t('contact.title3')">{{ joinsWord ? '' : ' ' }}<span>{{ t('contact.title3') }}</span></template></h2>
      <p class="p-rev p-contact5"><span>{{ t('contact.text') }}</span></p>
      <div class="p-rev p-contact6">
        <button type="button" class="p-btn p-contact7" @click="signIn.show()"><span>{{ t('common.getStarted') }}</span>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6"></path></svg>
        </button>
        <a class="p-link p-contact8" href="mailto:abdusalomovrustambek@gmail.com"><span>{{ t('contact.email') }}</span></a>
        <a class="p-link p-contact8" href="https://t.me/agnts_uz" target="_blank" rel="noopener"><span>{{ t('social.channel') }}</span></a>
        <a class="p-link p-contact8" href="https://t.me/agnts_community" target="_blank" rel="noopener"><span>{{ t('social.community') }}</span></a>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const { t } = useI18n()
const signIn = useSignIn()
// Russian ends the title with a bare "." that must sit right after the highlighted word.
const joinsWord = computed(() => /^[.,!?]/.test(t('contact.title3')))
</script>
