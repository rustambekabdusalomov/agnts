<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import { useWorkspace } from '../../stores/workspace'
import ConfirmDialog from '../ui/ConfirmDialog.vue'
import { channelName, type ChatChannel } from './chat'
import { upsertChannel } from './useChat'

// The channels, with your unread counts; agnts's channel is marked. Editors
// can make another one.
defineProps<{ channels: ChatChannel[]; current: number }>()
const emit = defineEmits<{ created: [c: ChatChannel] }>()
const { t } = useI18n()
const workspace = useWorkspace()

const creating = ref(false)
const form = reactive({ name: '', topic: '', agents: false, busy: false, error: '' })

function startNew() {
  Object.assign(form, { name: '', topic: '', agents: false, busy: false, error: '' })
  creating.value = true
}

async function create() {
  const name = channelName(form.name)
  if (!name) return
  form.busy = true
  form.error = ''
  try {
    const c = await unwrap(api.POST('/chat/channels', { body: { name, topic: form.topic.trim(), agents: form.agents } }))
    upsertChannel(c)
    creating.value = false
    emit('created', c)
  } catch (e) {
    form.error = e instanceof Error ? e.message : t('common.error')
  } finally {
    form.busy = false
  }
}
</script>

<template>
  <nav class="chl" :aria-label="t('teamchat.channels')">
    <div class="chl-h">
      <b>{{ t('teamchat.channels') }}</b>
      <button v-if="workspace.canEdit" type="button" class="chl-new" :title="t('teamchat.newChannel')" :aria-label="t('teamchat.newChannel')" @click="startNew">+</button>
    </div>
    <RouterLink
      v-for="c in channels"
      :key="c.id"
      class="chl-a"
      :class="{ on: c.id === current, unread: c.unread > 0 && c.id !== current }"
      :to="{ name: 'chat', params: { channelId: c.id } }"
      :title="c.topic || undefined"
    >
      <span class="chl-n">#{{ c.name }}</span>
      <span v-if="c.agents" class="chl-ag" :title="t('teamchat.agentsHere')">✨</span>
      <span v-if="c.unread > 0 && c.id !== current" class="cnt">{{ c.unread > 99 ? '99+' : c.unread }}</span>
    </RouterLink>
  </nav>

  <ConfirmDialog
    v-model="creating"
    :title="t('teamchat.newChannel')"
    :confirm-label="t('teamchat.create')"
    :busy="form.busy"
    :disabled="!channelName(form.name)"
    @confirm="create"
  >
    <form class="chl-form" @submit.prevent="create">
      <div class="field">
        <label for="chl-name">{{ t('teamchat.channelName') }}</label>
        <input id="chl-name" v-model="form.name" type="text" maxlength="40" placeholder="payments" autocomplete="off">
        <span class="fhelp">{{ t('teamchat.channelNameHelp') }}</span>
      </div>
      <div class="field">
        <label for="chl-topic">{{ t('teamchat.topic') }}</label>
        <input id="chl-topic" v-model="form.topic" type="text" maxlength="200">
      </div>
      <label class="chl-check"><input v-model="form.agents" type="checkbox"> {{ t('teamchat.agentsHere') }}</label>
      <p v-if="form.error" class="ferr">{{ form.error }}</p>
    </form>
  </ConfirmDialog>
</template>

<style scoped>
.chl { display: flex; flex-direction: column; gap: 2px; padding: 12px 10px; min-width: 0; overflow-y: auto; border-right: 1px solid var(--line); }
@media (max-width: 900px) {
  .chl { border-right: 0; border-bottom: 1px solid var(--line); max-height: 104px; padding: 8px 10px; }
}
.chl-h { display: flex; align-items: center; justify-content: space-between; padding: 0 6px 6px; font-size: 13px; color: var(--ink-3); }
.chl-new { width: 26px; height: 26px; border: 1px solid var(--line-3); border-radius: 7px; background: var(--surface); color: var(--ink-2); font-size: 16px; line-height: 1; cursor: pointer; }
.chl-new:hover { border-color: var(--ink); color: var(--ink); }
.chl-a { display: flex; align-items: center; gap: 6px; min-height: 34px; padding: 0 8px; border-radius: 8px; color: var(--ink-2); font-size: 14.5px; text-decoration: none; }
.chl-a:hover { background: var(--hover); color: var(--ink); }
.chl-a.on { background: var(--primary-soft); color: var(--primary-ink); font-weight: 700; }
.chl-a.unread { color: var(--ink); font-weight: 700; }
.chl-n { min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.chl-ag { font-size: 12px; }
.chl-a .cnt { margin-left: auto; }
.chl-form { display: flex; flex-direction: column; gap: 12px; margin: 8px 0 4px; text-align: left; }
.chl-check { display: flex; align-items: center; gap: 8px; font-size: 14px; }
</style>
