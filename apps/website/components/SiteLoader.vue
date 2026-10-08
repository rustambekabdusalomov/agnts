<template>
  <div :key="run" class="site-loader" :class="{ 'is-active': active }" aria-hidden="true">
    <!-- A fresh URL per run: a cached SVG image would otherwise resume at its finished frame. -->
    <img class="site-loader-mark" :src="run ? `/loader.svg?run=${run}` : '/loader.svg'" alt="" width="454" height="173" />
  </div>
</template>

<script setup lang="ts">
// Splash screen with the animated agnts logo. It plays on every page load and again when the
// language changes. CSS fades it out the moment the logo animation ends (the orange dot lands at
// 2.13 s), so it never waits for JavaScript. Server-rendered pages carry it in the HTML and start
// at the first paint; pages rendered by the client start when the app mounts.
//
// While a run is active the page underneath rises in behind the splash and the hero entrance is
// delayed by --intro. A run stays active until the hero entrance has finished (RUN_MS); after that
// the page carries no splash timing, so later navigations show their pages straight away.
const RUN_MS = 5000

const { locale } = useI18n()
const run = ref(0)
const active = ref(true)
let timer: ReturnType<typeof setTimeout> | undefined

function finishAfter(ms: number) {
  clearTimeout(timer)
  timer = setTimeout(() => (active.value = false), Math.max(0, ms))
}

// Hydrated from the HTML: the run started at the first paint. Rendered by the client: it starts now.
const fromHtml = useNuxtApp().isHydrating

onMounted(() => finishAfter(fromHtml ? RUN_MS - performance.now() : RUN_MS))

watch(locale, () => {
  run.value++
  active.value = true
  finishAfter(RUN_MS)
})

onBeforeUnmount(() => clearTimeout(timer))
</script>

<style>
/* At 2.15 s, when the orange dot lands, the splash fades while the logo grows slightly, and the page
   rises into place underneath, so the hand-over reads as one motion. */
.site-loader{position:fixed;inset:0;z-index:1000;display:grid;place-items:center;background:#FFFFFF;animation:site-loader-out .6s cubic-bezier(.4,0,.2,1) 2.15s forwards}
.site-loader-mark{width:min(260px, 64vw);height:auto;animation:site-loader-mark-out .6s cubic-bezier(.4,0,.2,1) 2.15s forwards}
/* Fill backwards only: a transform animation that keeps filling after it ends makes the page a
   containing block for position:fixed children, pinning the scroll-to-top button to the page bottom. */
.site-loader.is-active ~ *{--intro:2.05s;animation:site-page-in .8s cubic-bezier(.2,.7,.2,1) 1.95s backwards}
@keyframes site-loader-out{to{opacity:0;visibility:hidden;pointer-events:none}}
@keyframes site-loader-mark-out{to{opacity:0;transform:scale(1.06)}}
@keyframes site-page-in{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:none}}
/* The logo does not animate under reduced motion: a short plain fade, and the page does not move. */
@media (prefers-reduced-motion: reduce){
.site-loader,.site-loader-mark{animation-delay:.6s}
.site-loader-mark{animation-name:none}
.site-loader.is-active ~ *{animation:none}
}
</style>
