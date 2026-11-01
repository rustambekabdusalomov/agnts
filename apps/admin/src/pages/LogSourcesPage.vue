<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../api/client'
import type { LogSource } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import CopyField from '../components/form/CopyField.vue'
import LogServicesDrawer from '../components/logwatch/LogServicesDrawer.vue'
import LogSourceDrawer from '../components/logwatch/LogSourceDrawer.vue'
import { pushSnippets, SOURCE_TONE } from '../components/logwatch/logwatch'
import HiIcon from '../components/ui/HiIcon.vue'
import { askConfirm } from '../composables/useConfirm'
import { ago } from '../composables/format'
import { livePoll, useLive } from '../composables/useLive'
import { useUi } from '../stores/ui'
import { useWorkspace } from '../stores/workspace'

// The logging systems agnts reads (by address, through a private network
// when the address is on one) and the push tokens shippers send with.
const { t, locale } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const workspace = useWorkspace()
useLive()

const sources = useQuery({
  queryKey: ['logwatch', 'sources'],
  queryFn: () => unwrap(api.GET('/log-sources')),
  refetchInterval: () => livePoll(30_000),
})
const editing = ref<LogSource | null>(null)
const drawer = ref(false)
const servicesOf = ref<LogSource | null>(null)
const servicesOpen = ref(false)
const token = ref<{ source: string; token: string; url: string } | null>(null)

function add() {
  editing.value = null
  drawer.value = true
}
function edit(s: LogSource) {
  editing.value = s
  drawer.value = true
}
function services(s: LogSource) {
  servicesOf.value = s
  servicesOpen.value = true
}
const fail = (e: unknown) => ui.notify(e instanceof HttpError ? e.message : t('common.error'))
const makeToken = useMutation({
  mutationFn: (s: LogSource) => unwrap(api.POST('/log-sources/{sourceId}/push-token', { params: { path: { sourceId: s.id } } })),
  onSuccess: (r, s) => {
    token.value = { source: s.name, ...r }
    void qc.invalidateQueries({ queryKey: ['logwatch'] })
  },
  onError: fail,
})
const remove = useMutation({
  mutationFn: (s: LogSource) => unwrap(api.DELETE('/log-sources/{sourceId}', { params: { path: { sourceId: s.id } } })),
  onSuccess: () => void qc.invalidateQueries({ queryKey: ['logwatch'] }),
  onError: fail,
})
async function del(s: LogSource) {
  if (await askConfirm({ title: t('logwatch.deleteTitle', { name: s.name }), message: t('logwatch.deleteBody'), confirmLabel: t('logwatch.delete'), danger: true })) remove.mutate(s)
}
function saved(s: LogSource) {
  if (s.kind === 'push' && !s.hasPushToken) makeToken.mutate(s)
  else if (s.kind !== 'push' && !s.services.length) services(s)
}
const snippets = computed(() => (token.value ? pushSnippets(token.value.url, token.value.token) : null))
const watched = (s: LogSource) => s.services.filter((v) => v.enabled).length
</script>

<template>
  <RouterLink class="back-btn" :to="{ name: 'logWatcher' }"><HiIcon name="back" />{{ t('logwatch.title') }}</RouterLink>
  <PageHeader :title="t('logwatch.sources')">
    <template #below><p class="sub" style="margin: 4px 0 0">{{ t('logwatch.sourcesLede') }}</p></template>
    <div v-if="workspace.isOwner" class="actions" style="margin: 0">
      <button type="button" class="btn btn-p" @click="add">{{ t('logwatch.addSource') }}</button>
    </div>
  </PageHeader>

  <section v-if="token && snippets" class="card">
    <div class="ch"><div><h2>{{ t('logwatch.tokenTitle', { name: token.source }) }}</h2><p class="sub">{{ t('logwatch.tokenSub') }}</p></div></div>
    <CopyField :value="token.url" :label="t('logwatch.pushUrl')" />
    <CopyField :value="token.token" :label="t('logwatch.pushToken')" />
    <h3 class="lw-h3">Vector</h3>
    <pre class="lw-snip">{{ snippets.vector }}</pre>
    <h3 class="lw-h3">Fluent Bit</h3>
    <pre class="lw-snip">{{ snippets.fluentbit }}</pre>
    <h3 class="lw-h3">Promtail / Grafana Alloy</h3>
    <pre class="lw-snip">{{ snippets.promtail }}</pre>
    <button type="button" class="btn btn-s" @click="token = null">{{ t('logwatch.tokenDone') }}</button>
  </section>

  <section class="card">
    <p v-if="sources.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="sources.isError.value" class="ferr">{{ t('common.error') }}</p>
    <div v-else-if="sources.data.value?.length" class="tw">
      <table class="tbl">
        <thead>
          <tr><th>{{ t('logwatch.colSource') }}</th><th>{{ t('logwatch.colHealth') }}</th><th>{{ t('logwatch.colServices') }}</th><th>{{ t('logwatch.colLastRead') }}</th><th /></tr>
        </thead>
        <tbody>
          <tr v-for="s in sources.data.value" :key="s.id" class="ls-row">
            <td>
              <div><b>{{ s.name }}</b> <span class="src">{{ t(`logwatch.kind_${s.kind}`) }}</span> <span class="hint">{{ t(`logwatch.env_${s.environment}`) }}</span></div>
              <div class="hint mono">{{ s.kind === 'push' ? s.pushUrl : s.address }}</div>
              <div v-if="s.networkId" class="hint">{{ t('logwatch.privateNetwork') }}</div>
            </td>
            <td>
              <span class="badge" :class="`b-${SOURCE_TONE[s.status]}`">{{ t(`logwatch.source_${s.status}`) }}</span>
              <div v-if="s.lastError" class="hint ls-err">{{ s.lastError }}</div>
              <div v-if="s.dropped" class="hint">{{ t('logwatch.dropped', { n: s.dropped }) }}</div>
              <div v-if="s.gapFrom && s.gapTo" class="hint">{{ t('logwatch.gap', { from: new Date(s.gapFrom).toLocaleString(locale), to: new Date(s.gapTo).toLocaleString(locale) }) }}</div>
              <div v-if="!s.enabled" class="hint">{{ t('logwatch.disabled') }}</div>
            </td>
            <td>
              <span v-if="s.kind === 'push'" class="muted">{{ s.hasPushToken ? t('logwatch.hasToken') : t('logwatch.noToken') }}</span>
              <span v-else>{{ t('logwatch.watching', { n: watched(s) }) }}</span>
            </td>
            <td class="muted">{{ s.lastReadAt ? ago(s.lastReadAt, locale) : '—' }}</td>
            <td>
              <div v-if="workspace.isOwner || workspace.canEdit" class="row-actions">
                <button type="button" class="btn btn-s" @click="services(s)">{{ t('logwatch.services') }}</button>
                <template v-if="workspace.isOwner">
                  <button v-if="s.kind === 'push'" type="button" class="btn btn-s" :disabled="makeToken.isPending.value" @click="makeToken.mutate(s)">{{ s.hasPushToken ? t('logwatch.newToken') : t('logwatch.makeToken') }}</button>
                  <button type="button" class="btn btn-s" @click="edit(s)">{{ t('logwatch.edit') }}</button>
                  <button type="button" class="btn btn-s" @click="del(s)">{{ t('logwatch.delete') }}</button>
                </template>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else class="empty">
      <p style="margin: 0 0 14px">{{ t('logwatch.noSources') }}</p>
      <div class="help lw-how">
        <HiIcon name="info" />
        <div>
          <p>{{ t('logwatch.howPull') }}</p>
          <p>{{ t('logwatch.howPrivate') }}</p>
          <p>{{ t('logwatch.howPush') }}</p>
        </div>
      </div>
    </div>
  </section>

  <LogSourceDrawer v-model="drawer" :current="editing" @saved="saved" />
  <LogServicesDrawer v-if="servicesOf" v-model="servicesOpen" :source="servicesOf" />
</template>

<style scoped>
.ls-row { cursor: default; }
.ls-err { max-width: 320px; overflow-wrap: anywhere; color: var(--bad-ink); }
.lw-h3 { font-size: 14px; margin: 14px 0 6px; }
.lw-snip { margin: 0 0 8px; font-family: var(--mono); font-size: 12.5px; background: var(--code); color: var(--code-ink); border-radius: 10px; padding: 12px 14px; white-space: pre; overflow: auto; }
.lw-how { text-align: left; max-width: 640px; margin: 0 auto; }
.lw-how p + p { margin-top: 6px; }
</style>
