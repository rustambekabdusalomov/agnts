<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import { useUi } from '../../stores/ui'
import CopyField from '../form/CopyField.vue'
import { askConfirm } from '../../composables/useConfirm'

// Claude chat: the MCP connector URL, OAuth connections, and the optional
// static token for Claude Code and Claude Desktop.
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const status = useQuery({ queryKey: ['mcp'], queryFn: () => unwrap(api.GET('/mcp-settings')) })
const newToken = ref('')

const rotate = useMutation({
  mutationFn: () => unwrap(api.POST('/mcp-settings/token')),
  onSuccess: (r) => {
    newToken.value = r.token
    void qc.invalidateQueries({ queryKey: ['mcp'] })
  },
})
const revoke = useMutation({
  mutationFn: () => unwrap(api.POST('/mcp-settings/revoke')),
  onSuccess: () => {
    newToken.value = ''
    ui.notify(t('mcp.revoked'))
    void qc.invalidateQueries({ queryKey: ['mcp'] })
  },
})
async function confirmRevoke() {
  if (await askConfirm({ title: t('mcp.revoke'), message: t('mcp.revokeConfirm'), confirmLabel: t('mcp.revoke'), danger: true })) revoke.mutate()
}
</script>

<template>
  <section id="s-mcp" class="card">
    <div class="ch">
      <div>
        <h2>{{ t('mcp.title') }}</h2>
        <p class="sub">{{ t('mcp.sub') }}</p>
      </div>
    </div>
    <template v-if="status.data.value">
      <CopyField :label="t('mcp.url')" :value="status.data.value.url" />
      <div class="mini-kv"><span>{{ t('mcp.connections') }}</span><b>{{ status.data.value.connections }}</b></div>
      <div class="mini-kv"><span>{{ t('mcp.staticToken') }}</span><b>{{ status.data.value.staticToken ? t('mcp.set') : t('mcp.notSet') }}</b></div>
      <div class="help">
        <p>{{ t('mcp.howTo') }}</p>
      </div>
      <div v-if="newToken" class="sec">
        <CopyField :label="t('mcp.newToken')" :value="newToken" />
        <p class="hint">{{ t('mcp.shownOnce') }}</p>
      </div>
      <div class="actions">
        <button class="btn" type="button" :disabled="rotate.isPending.value" @click="rotate.mutate()">
          {{ status.data.value.staticToken ? t('mcp.rotate') : t('mcp.create') }}
        </button>
        <button class="btn btn-d" type="button" :disabled="revoke.isPending.value" @click="confirmRevoke">{{ t('mcp.revoke') }}</button>
      </div>
    </template>
  </section>
</template>
