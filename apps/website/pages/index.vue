<template>
  <div ref="wrap" class="p-wrap" :data-lang="locale">
    <LandingSiteHeader />
    <LandingHero />
    <LandingMarquee />
    <LandingProblem />
    <LandingHowItWorks />
    <LandingConnectors />
    <LandingSavings />
    <LandingFeatures />
    <LandingPrivacy />
    <LandingCompare />
    <!-- Reviews are hidden until there are real quotes; restore with the header link and numbering. -->
    <LandingAbout />
    <LandingPricing />
    <LandingStart />
    <LandingFaq />
    <LandingContact />
    <LandingSiteFooter />
    <LandingToTop />
    <LandingSignInDialog />
    <LandingConnectorRequestDialog />
  </div>
</template>

<script setup lang="ts">
import '~/assets/css/landing.css'

const { t, locale } = useI18n()
const wrap = ref<HTMLElement | null>(null)
useScrollReveal(wrap)

const i18nHead = useLocaleHead({ dir: true, seo: true })

useHead(() => ({
  htmlAttrs: { lang: locale.value, dir: i18nHead.value.htmlAttrs?.dir as 'ltr' | 'rtl' | 'auto' | undefined },
  link: i18nHead.value.link,
  meta: i18nHead.value.meta,
}))

useSeoMeta({
  title: () => t('meta.title'),
  description: () => t('meta.description'),
  ogTitle: () => t('meta.title'),
  ogDescription: () => t('meta.description'),
  ogType: 'website',
  twitterCard: 'summary',
})
</script>
