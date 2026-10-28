<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import BrandLogo from '../components/BrandLogo.vue'
import MeetingLobby from '../components/meetings/MeetingLobby.vue'
import MeetingRoom from '../components/meetings/MeetingRoom.vue'
import { useCall } from '../components/meetings/useCall'
import { useSession } from '../stores/session'

// A meeting's link, /m/abc-defg-hij: the lobby, the waiting room, the
// call, and what is left once it is over. Anyone with the link opens it:
// members of the workspace by their session, everyone else as a guest.
const { t, te } = useI18n()
const route = useRoute()
const session = useSession()
const code = String(route.params.code)
const invite = typeof route.query.i === 'string' ? route.query.i : undefined
const call = useCall(code)
const phase = computed(() => call.phase.value)
const backTo = computed(() => {
  const ws = call.state.value?.workspace
  if (ws) return `/w/${ws}/meetings`
  return session.user ? '/' : ''
})

onMounted(() => void call.start())
</script>

<template>
  <div class="mrp" :class="{ dark: phase === 'in-call' || phase === 'connecting' }">
    <header v-if="phase !== 'in-call'" class="mrp-h">
      <RouterLink :to="session.user ? '/' : '/login'" class="mrp-logo"><BrandLogo /></RouterLink>
    </header>

    <MeetingLobby v-if="phase === 'lobby' || phase === 'joining'" :call="call" :invite="invite" />

    <div v-else-if="phase === 'waiting'" class="mrp-msg card">
      <div class="mrp-spin" aria-hidden="true" />
      <h1>{{ t('meetings.waitingTitle') }}</h1>
      <p class="hint">{{ t('meetings.waitingBody') }}</p>
      <button type="button" class="btn" @click="call.cancelKnock">{{ t('meetings.cancel') }}</button>
    </div>

    <div v-else-if="phase === 'connecting'" class="mrp-msg dark-msg">
      <div class="mrp-spin" aria-hidden="true" />
      <p>{{ t('meetings.connecting') }}</p>
    </div>

    <MeetingRoom v-else-if="phase === 'in-call'" :call="call" />

    <div v-else class="mrp-msg card">
      <template v-if="phase === 'left'">
        <h1>{{ call.error.value === 'duplicate' ? t('meetings.joinedElsewhere') : t('meetings.youLeft') }}</h1>
        <div class="mrp-acts">
          <button type="button" class="btn btn-p" @click="call.rejoin">{{ t('meetings.rejoin') }}</button>
          <RouterLink v-if="backTo" :to="backTo" class="btn">{{ t('meetings.backToMeetings') }}</RouterLink>
        </div>
      </template>
      <template v-else-if="phase === 'ended'">
        <h1>{{ t('meetings.ended') }}</h1>
        <p class="hint">{{ t('meetings.endedBody') }}</p>
        <RouterLink v-if="backTo" :to="backTo" class="btn">{{ t('meetings.backToMeetings') }}</RouterLink>
      </template>
      <template v-else-if="phase === 'removed'">
        <h1>{{ t('meetings.removedTitle') }}</h1>
        <p class="hint">{{ t('meetings.removedBody') }}</p>
      </template>
      <template v-else-if="phase === 'refused'">
        <h1>{{ te(`meetings.refused_${call.refusal.value}`) ? t(`meetings.refused_${call.refusal.value}`) : call.error.value }}</h1>
        <button v-if="call.refusal.value !== 'removed' && call.refusal.value !== 'cancelled'" type="button" class="btn" @click="call.rejoin">{{ t('meetings.tryAgain') }}</button>
      </template>
      <template v-else>
        <h1>{{ call.error.value === 'not_found' ? t('meetings.notFound') : t('meetings.somethingWrong') }}</h1>
        <p v-if="call.error.value !== 'not_found'" class="hint">{{ call.error.value }}</p>
        <button type="button" class="btn" @click="call.rejoin">{{ t('meetings.tryAgain') }}</button>
      </template>
    </div>
  </div>
</template>

<style scoped>
.mrp { min-height: 100vh; background: var(--bg); }
.mrp.dark { background: #131416; }
.mrp-h { padding: 14px 20px; }
.mrp-logo { display: inline-flex; color: inherit; }
.mrp-msg { max-width: 460px; margin: 64px auto; display: flex; flex-direction: column; gap: 12px; align-items: center; text-align: center; }
.mrp-msg h1 { margin: 0; font-size: 21px; }
.mrp-msg .hint { margin: 0; }
.dark-msg { color: #e8eaed; }
.mrp-acts { display: flex; gap: 10px; flex-wrap: wrap; justify-content: center; }
.mrp-spin { width: 36px; height: 36px; border-radius: 50%; border: 3px solid var(--line-3); border-top-color: var(--primary); animation: spin 0.9s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
@media (prefers-reduced-motion: reduce) { .mrp-spin { animation: none; } }
</style>
