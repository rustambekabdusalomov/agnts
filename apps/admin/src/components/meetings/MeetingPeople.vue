<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { HttpError } from '../../api/client'
import type { MeetingPerson } from '../../api/types'
import { askConfirm } from '../../composables/useConfirm'
import HiIcon from '../ui/HiIcon.vue'
import type { Call } from './useCall'

// Who is in the call, who waits to come in, and whose hand is up. Hosts
// act on people from here: mute, ask to unmute, lower a hand, make a
// co-host, remove.
const props = defineProps<{ call: Call }>()
const { t } = useI18n()
const c = props.call
const error = ref('')
const menu = ref('')

const st = computed(() => c.state.value)
const people = computed(() => st.value?.people ?? [])
const knocks = computed(() => (st.value?.canAdmit ? (st.value.knocks ?? []) : []))
const rights = computed(() => st.value?.rights)
const manage = computed(() => !!rights.value?.manageCohosts)

async function run(fn: () => Promise<unknown>) {
  error.value = ''
  menu.value = ''
  try {
    await fn()
  } catch (e) {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  }
}

async function remove(p: MeetingPerson) {
  if (!(await askConfirm({ title: t('meetings.removeTitle', { name: p.name }), message: t('meetings.removeBody'), confirmLabel: t('meetings.remove'), danger: true }))) return
  await run(() => c.act(p.key, 'remove'))
}
async function makeCohost(p: MeetingPerson) {
  menu.value = ''
  if (!(await askConfirm({ title: t('meetings.cohostTitle', { name: p.name }), message: t('meetings.cohostBody'), confirmLabel: t('meetings.makeCohost') }))) return
  await run(() => c.act(p.key, 'cohost'))
}
async function muteAll() {
  if (!(await askConfirm({ title: t('meetings.muteAllTitle'), message: t('meetings.muteAllBody'), confirmLabel: t('meetings.muteAll') }))) return
  await run(c.muteAll)
}
async function admitAll(n: number) {
  if (!(await askConfirm({ title: t('meetings.admitAllTitle', { n }), message: t('meetings.admitAllBody'), confirmLabel: t('meetings.admitAll') }))) return
  await run(c.admitAll)
}
const isMe = (p: MeetingPerson) => p.key === st.value?.me.key
</script>

<template>
  <div class="mp">
    <section v-if="knocks.length" class="mp-sec">
      <div class="mp-h">
        <h3>{{ t('meetings.waiting', { n: knocks.length }) }}</h3>
        <button v-if="knocks.length > 1" type="button" class="btn btn-s" @click="admitAll(knocks.length)">{{ t('meetings.admitAll') }}</button>
      </div>
      <div v-for="k in knocks" :key="k.id" class="mp-row">
        <div class="mp-who">
          <strong>{{ k.name }}</strong>
          <span class="hint">{{ k.guest ? (k.email || t('meetings.guest')) : t('meetings.member') }}</span>
        </div>
        <button type="button" class="btn btn-s btn-p" @click="run(() => c.decide(k.id, 'admit'))">{{ t('meetings.admit') }}</button>
        <button type="button" class="btn btn-s" @click="run(() => c.decide(k.id, 'deny'))">{{ t('meetings.deny') }}</button>
      </div>
    </section>

    <section v-if="c.hands.value.length" class="mp-sec">
      <h3>{{ t('meetings.hands', { n: c.hands.value.length }) }}</h3>
      <div v-for="h in c.hands.value" :key="h.identity" class="mp-row">
        <span class="mp-hand"><HiIcon name="hand" /></span>
        <div class="mp-who"><strong>{{ h.name }}</strong></div>
        <button v-if="rights?.moderate || h.local" type="button" class="btn btn-s" @click="run(() => (h.local ? c.toggleHand() : c.act(h.person, 'lower-hand')))">
          {{ t('meetings.lowerHand') }}
        </button>
      </div>
    </section>

    <section class="mp-sec">
      <div class="mp-h">
        <h3>{{ t('meetings.inCall', { n: people.length }) }}</h3>
        <button v-if="rights?.moderate && people.length > 1" type="button" class="btn btn-s" @click="muteAll">{{ t('meetings.muteAll') }}</button>
      </div>
      <div v-for="p in people" :key="p.key" class="mp-row">
        <div class="mp-who">
          <strong>{{ p.name }}<template v-if="isMe(p)"> ({{ t('meetings.youShort') }})</template></strong>
          <span class="hint">
            {{ t(`meetings.role_${p.role}`) }}<template v-if="p.email"> · {{ p.email }}</template><template v-if="p.identities.length > 1"> · {{ t('meetings.devices', { n: p.identities.length }) }}</template>
          </span>
        </div>
        <div v-if="rights?.moderate && !isMe(p)" class="mp-menu">
          <button type="button" class="ib" :aria-expanded="menu === p.key" :aria-label="t('meetings.actionsFor', { name: p.name })" @click="menu = menu === p.key ? '' : p.key">
            <HiIcon name="more" />
          </button>
          <div v-if="menu === p.key" class="mp-pop" role="menu">
            <button type="button" role="menuitem" @click="run(() => c.act(p.key, 'mute', 'microphone'))">{{ t('meetings.muteMic') }}</button>
            <button type="button" role="menuitem" @click="run(() => c.act(p.key, 'mute', 'camera'))">{{ t('meetings.stopCamera') }}</button>
            <button type="button" role="menuitem" @click="run(() => c.act(p.key, 'mute', 'screen_share'))">{{ t('meetings.stopScreen') }}</button>
            <button type="button" role="menuitem" @click="run(() => c.act(p.key, 'ask-unmute'))">{{ t('meetings.askUnmute') }}</button>
            <template v-if="manage && p.role !== 'guest' && p.role !== 'host'">
              <button v-if="p.role === 'cohost'" type="button" role="menuitem" @click="run(() => c.act(p.key, 'uncohost'))">{{ t('meetings.uncohost') }}</button>
              <button v-else type="button" role="menuitem" @click="makeCohost(p)">{{ t('meetings.makeCohost') }}</button>
            </template>
            <button type="button" role="menuitem" class="bad" @click="remove(p)">{{ t('meetings.remove') }}</button>
          </div>
        </div>
      </div>
    </section>
    <p v-if="error" class="ferr" role="alert">{{ error }}</p>
  </div>
</template>

<style scoped>
.mp { display: flex; flex-direction: column; gap: 18px; }
.mp-sec { display: flex; flex-direction: column; gap: 6px; }
.mp-h { display: flex; justify-content: space-between; align-items: center; gap: 8px; }
.mp h3 { margin: 0; font-size: 13px; text-transform: uppercase; letter-spacing: 0.04em; color: var(--ink-3); }
.mp-row { display: flex; gap: 8px; align-items: center; padding: 6px 0; }
.mp-who { flex: 1; min-width: 0; display: flex; flex-direction: column; }
.mp-who strong { font-size: 14px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.mp-who .hint { font-size: 12.5px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.mp-hand { width: 26px; height: 26px; border-radius: 50%; background: #f0b429; display: grid; place-items: center; flex: none; }
.mp-hand :deep(svg) { width: 15px; height: 15px; }
.mp-menu { position: relative; }
.ib { width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--line-3); background: var(--surface); display: grid; place-items: center; cursor: pointer; }
.ib :deep(svg) { width: 16px; height: 16px; }
.mp-pop { position: absolute; right: 0; top: 36px; z-index: 5; min-width: 200px; background: var(--surface); border: 1px solid var(--line-3); border-radius: 10px; box-shadow: 0 10px 30px -10px var(--shadow); padding: 4px; display: flex; flex-direction: column; }
.mp-pop button { text-align: left; border: 0; background: none; padding: 9px 10px; border-radius: 7px; font: inherit; font-size: 14px; cursor: pointer; color: var(--ink); }
.mp-pop button:hover { background: var(--line-2); }
.mp-pop button.bad { color: var(--bad-ink); }
</style>
