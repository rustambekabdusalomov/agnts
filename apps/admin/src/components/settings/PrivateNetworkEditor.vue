<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { PrivateNetwork, PrivateNetworkInput } from '../../api/types'
import { askConfirm } from '../../composables/useConfirm'
import { useUi } from '../../stores/ui'
import CopyField from '../form/CopyField.vue'
import FormDrawer from '../form/FormDrawer.vue'
import SegButtons from '../form/SegButtons.vue'
import SwitchToggle from '../form/SwitchToggle.vue'
import HiIcon from '../ui/HiIcon.vue'

// Add or edit one private network: a tunnel (WireGuard, OpenVPN or the
// agnts-link connector), the routes that go through it and its CA bundle.
// `network` null adds one. A new connector stays open after saving so its
// token (shown once) and install command can be copied.
type Kind = PrivateNetwork['kind']
interface RouteRow {
  target: string
  ports: string
}

const props = defineProps<{ network: PrivateNetwork | null; linkUrl: string }>()
const open = defineModel<boolean>({ default: false })
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()

// The network as last saved here (a new one has none until its first save).
const current = ref<PrivateNetwork | null>(null)
const name = ref('')
const kind = ref<Kind>('connector')
const enabled = ref(true)
const config = ref('')
const username = ref('')
const password = ref('')
const routes = ref<RouteRow[]>([{ target: '', ports: '' }])
const caPem = ref('')
const caTouched = ref(false)
const error = ref('')
const newToken = ref('')

const kinds = computed(() => [
  { value: 'connector' as Kind, label: t('network.kindConnector') },
  { value: 'wireguard' as Kind, label: 'WireGuard' },
  { value: 'openvpn' as Kind, label: 'OpenVPN' },
])

function load(n: PrivateNetwork | null) {
  current.value = n
  name.value = n?.name ?? ''
  kind.value = n?.kind ?? 'connector'
  enabled.value = n?.enabled ?? true
  routes.value = n?.routes.length
    ? n.routes.map((r) => ({ target: r.host ?? r.cidr ?? '', ports: (r.ports ?? []).join(', ') }))
    : [{ target: '', ports: '' }]
  config.value = ''
  username.value = ''
  password.value = ''
  caPem.value = ''
  caTouched.value = false
  error.value = ''
}

watch(
  open,
  (v) => {
    if (!v) return
    newToken.value = ''
    load(props.network)
  },
  { immediate: true },
)

const keepsConfig = computed(() => current.value?.kind === kind.value && kind.value !== 'connector')

function toRoutes(): PrivateNetworkInput['routes'] {
  return routes.value
    .filter((r) => r.target.trim())
    .map((r) => {
      const target = r.target.trim()
      const ports = r.ports
        .split(/[,\s]+/)
        .map((p) => Number(p))
        .filter((p) => Number.isInteger(p) && p > 0)
      const route = target.includes('/') ? { cidr: target } : { host: target }
      return ports.length ? { ...route, ports } : route
    })
}

const save = useMutation({
  mutationFn: () => {
    const body: PrivateNetworkInput = { name: name.value.trim(), kind: kind.value, enabled: enabled.value, routes: toRoutes() }
    if (config.value.trim()) body.config = config.value
    if (kind.value === 'openvpn') {
      body.username = username.value
      if (password.value) body.password = password.value
    }
    if (caTouched.value) body.caPem = caPem.value
    const id = current.value?.id
    return id
      ? unwrap(api.PUT('/networks/{networkId}', { params: { path: { networkId: id } }, body }))
      : unwrap(api.POST('/networks', { body }))
  },
  onSuccess: (r) => {
    void qc.invalidateQueries({ queryKey: ['networks'] })
    void qc.invalidateQueries({ queryKey: ['network-activity'] })
    ui.notify(t('network.saved', { name: r.network.name }))
    if (r.token) {
      // Keep the drawer open: the token is shown only now.
      load(r.network)
      newToken.value = r.token
      return
    }
    open.value = false
  },
  onError: (e) => {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})

const rotate = useMutation({
  mutationFn: (id: number) => unwrap(api.POST('/networks/{networkId}/token', { params: { path: { networkId: id } } })),
  onSuccess: (r) => {
    newToken.value = r.token
    void qc.invalidateQueries({ queryKey: ['networks'] })
  },
  onError: (e) => {
    ui.notify(e instanceof HttpError ? e.message : t('common.error'))
  },
})
async function confirmRotate() {
  const id = current.value?.id
  if (!id) return
  if (await askConfirm({ title: t('network.rotate'), message: t('network.rotateConfirm'), confirmLabel: t('network.rotate') })) rotate.mutate(id)
}

const allowList = computed(() => {
  const list = toRoutes().map((r) => ('host' in r ? r.host : r.cidr))
  return list.length ? list.join(',') : 'gitlab.corp.local,10.20.0.0/16'
})
const linkCommand = computed(() =>
  [
    `docker run -d --restart unless-stopped --name ${containerName.value} -p 8080:8080 \\`,
    `  -e AGNTS_LINK_URL=${props.linkUrl} \\`,
    `  -e AGNTS_LINK_TOKEN=${newToken.value || '<token>'} \\`,
    `  -e AGNTS_LINK_ALLOW=${allowList.value} \\`,
    '  registry.agnts.uz/agnts-link:latest',
  ].join('\n'),
)
// A container name per network, so one machine can run links for several.
const containerName = computed(() => {
  const slug = (current.value?.name ?? name.value)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
  return slug ? `agnts-link-${slug}` : 'agnts-link'
})
</script>

<template>
  <FormDrawer v-model="open" :title="current ? current.name : t('network.addTitle')" :subtitle="t('network.editorSub')">
    <form id="pn-form" style="display: contents" @submit.prevent="save.mutate()">
      <div class="field">
        <label for="pn-name">{{ t('network.name') }}</label>
        <input id="pn-name" v-model="name" type="text" required maxlength="60" :placeholder="t('network.namePlaceholder')">
        <span class="fhelp">{{ t('network.nameHelp') }}</span>
      </div>
      <div class="field">
        <span class="flbl">{{ t('network.kind') }}</span>
        <SegButtons v-model="kind" :options="kinds" :label="t('network.kind')" />
        <span class="fhelp">{{ t(`network.kindHelp_${kind}`) }}</span>
      </div>
      <div class="field" style="flex-direction: row; align-items: center; justify-content: space-between">
        <span class="flbl">{{ t('network.enabled') }}</span>
        <SwitchToggle v-model="enabled" :label="t('network.enabled')" />
      </div>

      <div v-if="kind !== 'connector'" class="field">
        <label for="pn-config">{{ kind === 'wireguard' ? t('network.configWg') : t('network.configOvpn') }}</label>
        <p v-if="keepsConfig && current?.summary" class="hint" style="margin: 0 0 6px">
          {{ t('network.savedConfig', { summary: current.summary }) }}
        </p>
        <textarea
          id="pn-config"
          v-model="config"
          rows="7"
          spellcheck="false"
          autocomplete="off"
          :placeholder="kind === 'wireguard' ? '[Interface]\nPrivateKey = …\nAddress = 10.8.0.2/32\nDNS = 10.8.0.1\n\n[Peer]\nPublicKey = …\nEndpoint = vpn.example.com:51820\nAllowedIPs = 10.0.0.0/8' : 'client\ndev tun\nremote vpn.example.com 1194\n<ca>…</ca>'"
          style="font-family: var(--mono); font-size: 13px"
        />
        <span class="fhelp">{{ kind === 'wireguard' ? t('network.configWgHelp') : t('network.configOvpnHelp') }}</span>
      </div>
      <div v-if="kind === 'openvpn'" style="display: flex; gap: 12px">
        <div class="field" style="flex: 1">
          <label for="pn-user">{{ t('network.username') }}</label>
          <input id="pn-user" v-model="username" type="text" autocomplete="off" maxlength="256">
        </div>
        <div class="field" style="flex: 1">
          <label for="pn-pass">{{ t('network.password') }}</label>
          <input id="pn-pass" v-model="password" type="password" autocomplete="new-password" maxlength="256" :placeholder="keepsConfig ? t('network.passwordKeep') : ''">
        </div>
      </div>

      <div class="field">
        <span class="flbl">{{ t('network.routes') }}</span>
        <span class="fhelp" style="margin: 0 0 4px">{{ t('network.routesHelp') }}</span>
        <div v-for="(r, i) in routes" :key="i" style="display: flex; gap: 8px">
          <input v-model="r.target" class="mono" style="flex: 3" type="text" placeholder="gitlab.corp.local · .corp.local · 10.20.0.0/16" :aria-label="t('network.routeTarget')">
          <input v-model="r.ports" class="mono" style="flex: 1" type="text" placeholder="80, 443" :aria-label="t('network.routePorts')">
          <button type="button" class="btn btn-s" :aria-label="t('network.removeRoute')" @click="routes.splice(i, 1)">×</button>
        </div>
        <button type="button" class="btn btn-s" style="align-self: flex-start" @click="routes.push({ target: '', ports: '' })">{{ t('network.addRoute') }}</button>
        <div class="help warn">
          <HiIcon name="info" />
          <p>{{ t('network.blastRadius') }}</p>
        </div>
      </div>

      <div class="field">
        <span class="flbl">{{ t('network.ca') }}</span>
        <p v-if="current?.ca && !caTouched" class="hint" style="margin: 0 0 6px">
          {{ t('network.caSaved', { subjects: current.ca.subjects.join(', '), date: new Date(current.ca.notAfter).toLocaleDateString() }) }}
          <button type="button" class="btn btn-s" @click="caTouched = true; caPem = ''">{{ t('network.caRemove') }}</button>
        </p>
        <textarea v-model="caPem" rows="3" spellcheck="false" placeholder="-----BEGIN CERTIFICATE-----" style="font-family: var(--mono); font-size: 12.5px" :aria-label="t('network.ca')" @input="caTouched = true" />
        <span class="fhelp">{{ t('network.caHelp') }}</span>
      </div>

      <div v-if="kind === 'connector' && current?.kind === 'connector'" class="field">
        <span class="flbl">{{ t('network.linkTitle') }}</span>
        <span class="fhelp">{{ t('network.linkHelp') }}</span>
        <div v-if="newToken">
          <CopyField :label="t('network.token')" :value="newToken" />
          <p class="hint">{{ t('network.tokenOnce') }}</p>
        </div>
        <pre class="mono-box" style="white-space: pre-wrap">{{ linkCommand }}</pre>
        <span class="fhelp">{{ t('network.linkHooks') }}</span>
        <button type="button" class="btn btn-s" style="align-self: flex-start" :disabled="rotate.isPending.value" @click="confirmRotate">{{ t('network.rotate') }}</button>
      </div>

      <span v-if="error" class="ferr" role="alert">{{ error }}</span>
    </form>
    <template #footer>
      <button type="button" class="btn" @click="open = false">{{ newToken ? t('network.done') : t('form.cancel') }}</button>
      <button type="submit" form="pn-form" class="btn btn-p" :disabled="save.isPending.value || !name.trim()">
        {{ current ? t('form.save') : t('network.addSubmit') }}
      </button>
    </template>
  </FormDrawer>
</template>
