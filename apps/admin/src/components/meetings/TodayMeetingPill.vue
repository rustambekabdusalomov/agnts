<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Meeting } from '../../api/types'
import HiIcon from '../ui/HiIcon.vue'
import { callPath, useTodayMeetings } from './useMeetings'

// The header's word on the person's day: the meeting live now, else the
// next one today. Within the early-join window (15 minutes) it links
// straight into the call; before that, to the meeting's page. Hidden when
// nothing is left today.
const EARLY_JOIN_MS = 15 * 60_000

const { t, locale } = useI18n()
const { today, now } = useTodayMeetings()

const m = computed(() => today.value.first)
const time = (iso: string) => new Date(iso).toLocaleTimeString(locale.value, { hour: '2-digit', minute: '2-digit' })
// Minutes until the start; 0 once it has started.
const minsLeft = computed(() => (m.value?.startsAt ? Math.max(0, Math.ceil((new Date(m.value.startsAt).getTime() - now.value.getTime()) / 60_000)) : 0))
const state = computed<'live' | 'soon' | 'later'>(() => {
  if (!m.value) return 'later'
  if (m.value.live) return 'live'
  return minsLeft.value * 60_000 <= EARLY_JOIN_MS ? 'soon' : 'later'
})
const to = computed(() => (m.value && state.value !== 'later' ? callPath(m.value.code) : { name: 'meeting', params: { id: m.value?.id } }))

function line(x: Meeting): string {
  if (x.live) return t('meetings.todayLiveLine', { title: x.title || x.code })
  return `${x.startsAt ? time(x.startsAt) : ''} ${x.title || x.code}`.trim()
}
const label = computed(() => {
  if (!m.value) return ''
  const title = m.value.title || m.value.code
  const head =
    state.value === 'live'
      ? t('meetings.todayLiveAria', { title, n: m.value.live?.inCall ?? 0 })
      : state.value === 'soon'
        ? minsLeft.value
          ? t('meetings.todaySoonAria', { title, n: minsLeft.value })
          : t('meetings.todayNowAria', { title })
        : t('meetings.todayLaterAria', { title, time: time(m.value.startsAt!) })
  return today.value.rest.length ? `${head}. ${t('meetings.todayMoreAria', { n: today.value.rest.length })}` : head
})
const tip = computed(() => (today.value.rest.length ? [t('meetings.todayLater'), ...today.value.rest.map(line)].join('\n') : undefined))
</script>

<template>
  <RouterLink v-if="m" class="today-pill" :class="state" :to="to" :aria-label="label" :title="tip">
    <span v-if="state === 'live'" class="today-dot" aria-hidden="true" />
    <HiIcon v-else :name="state === 'soon' ? 'video' : 'calendar'" />
    <span v-if="state === 'live'" class="today-tag">{{ t('meetings.todayLive') }}</span>
    <span v-else-if="state === 'later'" class="today-time">{{ time(m.startsAt!) }}</span>
    <span class="today-title">{{ m.title || m.code }}</span>
    <span v-if="state === 'live' && m.live?.inCall" class="today-sub">{{ t('meetings.todayInCall', { n: m.live.inCall }) }}</span>
    <span v-else-if="state === 'soon'" class="today-sub">{{ minsLeft ? t('meetings.todayIn', { n: minsLeft }) : t('meetings.todayNow') }}</span>
    <span v-if="state !== 'later'" class="today-join">{{ t('meetings.todayJoin') }}</span>
    <span v-if="today.rest.length" class="today-more" aria-hidden="true">+{{ today.rest.length }}</span>
  </RouterLink>
</template>
