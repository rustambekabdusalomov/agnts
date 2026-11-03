<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useAgo, useEgress } from '../../composables/usePlatform'

// How Muse's traffic leaves the server: straight, or through the egress
// proxy's upstream (a proxy elsewhere, or a laptop's SSH tunnel), with the
// last half hour of egress's own checks.
const { t, locale } = useI18n()
const ago = useAgo()
const q = useEgress()

const s = computed(() => q.data.value)
const up = computed(() => s.value?.upstream)
type State = 'loading' | 'unknown' | 'direct' | 'waiting' | 'up' | 'down'
const state = computed<State>(() => {
  if (!s.value) return q.isError.value ? 'unknown' : 'loading'
  if (!s.value.reachable) return 'unknown'
  if (!up.value?.configured) return 'direct'
  if (!up.value.checkedAt) return 'waiting'
  return up.value.ok ? 'up' : 'down'
})
const badge = computed(() => ({ up: 'b-ok', down: 'b-bad', waiting: 'b-info', direct: 'b-gray', unknown: 'b-warn', loading: 'b-gray' })[state.value])
const time = (iso?: string) => (iso ? new Date(iso).toLocaleTimeString(locale.value, { hour: '2-digit', minute: '2-digit' }) : '—')
// Oldest first; empty slots fill the left so the strip is always 60 wide.
const bars = computed(() => {
  const h = up.value?.history ?? []
  return [...Array(Math.max(0, 60 - h.length)).fill(null), ...h]
})
const okShare = computed(() => {
  const h = up.value?.history ?? []
  return h.length ? Math.round((100 * h.filter((c) => c.ok).length) / h.length) : 0
})
// A SOCKS proxy on a private address is a laptop's SSH tunnel (deploy.md):
// say how to start it again, on this server's host name.
const tunnel = computed(() => {
  const m = /^socks5h?:\/\/((?:10|127|172|192)\.[\d.]+:\d+)$/.exec(up.value?.via ?? '')
  return m ? `ssh -N -o ServerAliveInterval=30 -o ExitOnForwardFailure=yes -R ${m[1]} root@${location.hostname}` : ''
})
</script>

<template>
  <section class="card mr">
    <div class="ch">
      <div>
        <h2>{{ t('platform.museRoute') }}</h2>
        <p class="sub">{{ t('platform.museRouteSub') }}</p>
      </div>
      <span class="badge" :class="badge">
        <i class="mr-dot" :class="state" aria-hidden="true" />
        {{ t(`platform.museState.${state}`) }}
      </span>
    </div>

    <p v-if="state === 'unknown'" class="mr-msg bad">{{ s?.error || t('common.error') }}</p>
    <p v-else-if="state === 'direct'" class="mr-msg">{{ t('platform.museDirect') }}</p>

    <template v-else-if="up && state !== 'loading'">
      <div class="mini-kv"><span>{{ t('platform.museVia') }}</span><b class="mono">{{ up.via }}</b></div>
      <div class="mini-kv">
        <span>{{ t('platform.museExit') }}</span>
        <b v-if="up.exit">{{ up.exit.ip }} <small class="mr-org">{{ [up.exit.org, up.exit.city, up.exit.country].filter(Boolean).join(' · ') }}</small></b>
        <b v-else>—</b>
      </div>
      <div class="mini-kv">
        <span>{{ t('platform.museCheck') }}</span>
        <b>{{ up.target }} · {{ up.ok ? `${up.latencyMs} ms` : '✕' }} · {{ ago(up.checkedAt) }}</b>
      </div>
      <div v-if="!up.ok" class="mini-kv">
        <span>{{ t('platform.museDownSince') }}</span>
        <b>{{ time(up.downSince) }} <small v-if="up.lastOkAt" class="mr-org">{{ t('platform.museLastOk', { at: time(up.lastOkAt) }) }}</small></b>
      </div>
      <div class="mini-kv">
        <span>{{ t('platform.museCalls') }}</span>
        <b>{{ up.calls }}<template v-if="up.failed"> · <span class="bad">{{ t('platform.museFailed', { n: up.failed }) }}</span></template></b>
      </div>

      <div class="mr-strip" role="img" :aria-label="t('platform.museStrip', { pct: okShare })">
        <span
          v-for="(c, i) in bars"
          :key="i"
          class="mr-bar"
          :class="c ? (c.ok ? 'ok' : 'bad') : 'none'"
          :title="c ? `${time(c.at)} · ${c.ok ? c.ms + ' ms' : '✕'}` : ''"
        />
      </div>
      <p class="mr-legend">{{ t('platform.museStrip', { pct: okShare }) }}</p>

      <div v-if="!up.ok" class="mr-help">
        <p class="mr-msg bad">{{ up.error }}</p>
        <template v-if="tunnel">
          <p class="mr-msg">{{ t('platform.museFixTunnel') }}</p>
          <code class="mr-cmd">{{ tunnel }}</code>
        </template>
        <p v-else class="mr-msg">{{ t('platform.museFixProxy') }}</p>
      </div>
      <p v-else-if="up.lastCallError && up.failed" class="mr-msg muted">{{ t('platform.museLastCallError', { err: up.lastCallError }) }}</p>
    </template>
    <p v-else class="empty">{{ t('common.loading') }}</p>
  </section>
</template>

<style scoped>
.mr .badge { display: inline-flex; align-items: center; gap: 6px; }
.mr-dot { width: 8px; height: 8px; border-radius: 50%; background: var(--ink-3); }
.mr-dot.up { background: var(--ok); box-shadow: 0 0 0 3px color-mix(in srgb, var(--ok) 25%, transparent); }
.mr-dot.down { background: var(--bad); animation: mr-pulse 1.4s ease-in-out infinite; }
.mr-dot.waiting { background: var(--info, var(--primary)); }
.mr-dot.unknown { background: var(--warn); }
@keyframes mr-pulse { 50% { opacity: 0.35; } }
@media (prefers-reduced-motion: reduce) { .mr-dot.down { animation: none; } }
.mr-org { color: var(--ink-3); font-weight: 400; }
.mr-strip { display: grid; grid-template-columns: repeat(60, 1fr); gap: 2px; height: 26px; margin: 14px 0 4px; }
.mr-bar { border-radius: 2px; background: var(--line-2); }
.mr-bar.ok { background: var(--ok); }
.mr-bar.bad { background: var(--bad); }
.mr-legend { margin: 0; font-size: 12.5px; color: var(--ink-3); }
.mr-msg { margin: 10px 0 0; font-size: 14px; color: var(--ink-2); overflow-wrap: anywhere; }
.mr-msg.bad, .bad { color: var(--bad); }
.mr-msg.muted { color: var(--ink-3); font-size: 13px; }
.mr-help { margin-top: 6px; }
.mr-cmd { display: block; margin-top: 8px; padding: 8px 10px; border-radius: 8px; background: var(--field); border: 1px solid var(--line); font-size: 12.5px; overflow-x: auto; white-space: nowrap; user-select: all; }
</style>
