<script setup lang="ts">
import type { Track } from 'livekit-client'
import { onBeforeUnmount, ref, watch } from 'vue'

// A video track drawn in a <video>: attached while shown, detached when
// the track changes or the element goes, so adaptive stream sends the size
// it is drawn at.
const props = defineProps<{ track?: Track; mirror?: boolean; fit?: 'cover' | 'contain' }>()
const el = ref<HTMLVideoElement | null>(null)
let attached: Track | undefined

function sync() {
  if (attached && attached !== props.track && el.value) attached.detach(el.value)
  attached = undefined
  if (props.track && el.value) {
    props.track.attach(el.value)
    attached = props.track
  }
}

watch([() => props.track, el], sync, { immediate: true })
onBeforeUnmount(() => {
  if (attached && el.value) attached.detach(el.value)
})
</script>

<template>
  <video ref="el" class="vt" :class="{ mirror, contain: fit === 'contain' }" autoplay playsinline muted />
</template>

<style scoped>
.vt { width: 100%; height: 100%; object-fit: cover; background: #111; display: block; }
.vt.contain { object-fit: contain; }
.vt.mirror { transform: scaleX(-1); }
</style>
