<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import PageHeader from '../components/PageHeader.vue'
import StateBadge from '../components/StateBadge.vue'
import InputSelect from '../components/form/InputSelect.vue'
import { canFix, SEC_SEVERITY_TONE, SEC_STATUS_TONE, where } from '../components/security/security'
import { useSecurityActions } from '../components/security/useSecurityActions'
import HiIcon from '../components/ui/HiIcon.vue'
import { ago } from '../composables/format'
import { livePoll, useLive } from '../composables/useLive'
import { useWorkspace } from '../stores/workspace'

// One finding: what it is, where, the evidence, the suggested fix, and
// Fix this, Dismiss or Reopen. Everything here came from scanners and the
// agent reading the repository: it is shown as text, never as HTML.
const { t, locale } = useI18n()
const route = useRoute()
const workspace = useWorkspace()
const { fix, dismiss, reopen } = useSecurityActions()
useLive()
const id = computed(() => Number(route.params.id))

const finding = useQuery({
  queryKey: computed(() => ['security', 'finding', id.value]),
  queryFn: () => unwrap(api.GET('/security/findings/{findingId}', { params: { path: { findingId: id.value } } })),
  refetchInterval: () => livePoll(30_000),
})
const f = computed(() => finding.data.value)
const when = (iso?: string) => (iso ? new Date(iso).toLocaleString(locale.value) : '—')
const safeRefs = computed(() => (f.value?.references ?? []).filter((r) => /^https?:\/\//.test(r)))

type Reason = 'false_positive' | 'accepted_risk' | 'wont_fix'
const dismissing = ref(false)
const reason = ref<Reason>('false_positive')
const note = ref('')
const reasons = computed(() => (['false_positive', 'accepted_risk', 'wont_fix'] as Reason[]).map((r) => ({ value: r, label: t(`security.reason_${r}`) })))
function doDismiss() {
  if (!f.value) return
  dismiss.mutate({ ids: [f.value.id], reason: reason.value, note: note.value.trim() }, {
    onSuccess: () => {
      dismissing.value = false
      note.value = ''
    },
  })
}
const busy = computed(() => fix.isPending.value || dismiss.isPending.value || reopen.isPending.value)
</script>

<template>
  <RouterLink class="back-btn" :to="{ name: 'security' }"><HiIcon name="back" />{{ t('security.back') }}</RouterLink>
  <p v-if="finding.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="finding.error.value instanceof HttpError && finding.error.value.status === 404" class="ferr">{{ t('security.notFound') }}</p>
  <p v-else-if="finding.isError.value" class="ferr">{{ t('common.error') }}</p>

  <template v-else-if="f">
    <PageHeader :title="f.title">
      <template #below>
        <div class="sec-head">
          <span class="badge" :class="`b-${SEC_STATUS_TONE[f.status]}`" :title="t(`security.statusHelp_${f.status}`)">{{ t(`security.status_${f.status}`) }}</span>
          <span class="badge" :class="`b-${SEC_SEVERITY_TONE[f.severity]}`">{{ t(`security.sev_${f.severity}`) }}</span>
          <span class="src">{{ t(`security.conf_${f.confidence}`) }}</span>
          <span class="src">{{ t(`security.source_${f.source}`) }}</span>
          <b>{{ f.repo }}</b>
          <span class="mono">{{ where(f) }}</span>
        </div>
      </template>
      <div v-if="workspace.canEdit || f.ticketKey" class="actions" style="margin: 0">
        <RouterLink v-if="f.ticketKey" class="btn" :to="{ name: 'ticket', params: { key: f.ticketKey } }">{{ t('security.openTicket', { key: f.ticketKey }) }}</RouterLink>
        <template v-if="workspace.canEdit">
          <button v-if="canFix(f)" type="button" class="btn btn-p" :disabled="busy" @click="fix.mutate([f.id])">{{ t('security.fix') }}</button>
          <template v-if="workspace.isOwner">
            <button v-if="f.status === 'dismissed' || f.status === 'fixed'" type="button" class="btn" :disabled="busy" @click="reopen.mutate(f.id)">{{ t('security.reopen') }}</button>
            <button v-else-if="!dismissing" type="button" class="btn" :disabled="busy" @click="dismissing = true">{{ t('security.dismiss') }}</button>
          </template>
        </template>
      </div>
    </PageHeader>

    <section v-if="dismissing" class="card">
      <div class="ch"><div><h2>{{ t('security.dismissTitle') }}</h2><p class="sub">{{ t('security.dismissSub') }}</p></div></div>
      <div class="sec-dismiss">
        <InputSelect v-model="reason" :options="reasons" :label="t('security.reason')" />
        <textarea v-model="note" rows="2" maxlength="1000" :placeholder="t('security.notePlaceholder')" :aria-label="t('security.note')" />
        <div class="actions" style="margin: 0">
          <button type="button" class="btn btn-p" :disabled="busy" @click="doDismiss">{{ t('security.dismiss') }}</button>
          <button type="button" class="btn" @click="dismissing = false">{{ t('security.cancel') }}</button>
        </div>
      </div>
    </section>

    <div v-if="f.status === 'reopened'" class="help bad" style="margin-bottom: 14px"><HiIcon name="info" /><p>{{ t('security.reopenedHelp') }}</p></div>
    <div v-if="f.status === 'dismissed'" class="help" style="margin-bottom: 14px">
      <HiIcon name="info" /><p>{{ t('security.dismissedAs', { reason: t(`security.reason_${f.dismissReason || 'false_positive'}`) }) }}<span v-if="f.dismissNote"> — {{ f.dismissNote }}</span></p>
    </div>
    <div v-if="f.note" class="help" style="margin-bottom: 14px"><HiIcon name="info" /><p>{{ t('security.lastRecheck') }}: {{ f.note }}</p></div>
    <div v-if="f.source === 'secret' || f.source === 'history'" class="help bad" style="margin-bottom: 14px"><HiIcon name="lock" /><p>{{ t('security.rotateFirst') }}</p></div>

    <div class="cfg-grid">
      <div class="col">
        <section v-if="f.evidence || f.impact" class="card">
          <div class="ch"><h2>{{ t('security.evidence') }}</h2></div>
          <p v-if="f.evidence" class="sec-text">{{ f.evidence }}</p>
          <template v-if="f.impact">
            <h3 class="sec-h3">{{ t('security.impact') }}</h3>
            <p class="sec-text">{{ f.impact }}</p>
          </template>
        </section>
        <section v-if="f.fixExplanation || f.fixPatch" class="card">
          <div class="ch"><div><h2>{{ t('security.suggestedFix') }}</h2><p class="sub">{{ t('security.suggestedFixSub') }}</p></div></div>
          <p v-if="f.fixExplanation" class="sec-text">{{ f.fixExplanation }}</p>
          <pre v-if="f.fixPatch" class="sec-patch">{{ f.fixPatch }}</pre>
        </section>
        <section v-if="f.package" class="card">
          <div class="ch"><h2>{{ t('security.dependency') }}</h2></div>
          <dl class="kv">
            <dt>{{ t('security.package') }}</dt><dd class="mono">{{ f.package }} {{ f.version }} ({{ f.ecosystem }})</dd>
            <template v-if="f.fixedIn"><dt>{{ t('security.fixedIn') }}</dt><dd class="mono">{{ f.fixedIn }}</dd></template>
            <template v-if="f.cvss"><dt>CVSS</dt><dd>{{ f.cvss }}</dd></template>
            <template v-if="f.advisories?.length"><dt>{{ t('security.advisories') }}</dt><dd class="mono sec-adv">{{ f.advisories.join(', ') }}</dd></template>
          </dl>
        </section>
        <section v-if="safeRefs.length" class="card">
          <div class="ch"><h2>{{ t('security.references') }}</h2></div>
          <ul class="sec-refs">
            <li v-for="r in safeRefs" :key="r"><a :href="r" target="_blank" rel="noopener noreferrer">{{ r }}</a></li>
          </ul>
        </section>
      </div>
      <aside class="cfg-side">
        <section class="card">
          <div class="ch"><h2>{{ t('security.facts') }}</h2></div>
          <dl class="kv">
            <dt>{{ t('security.where') }}</dt><dd class="mono">{{ where(f) || '—' }}</dd>
            <template v-if="f.symbol"><dt>{{ t('security.function') }}</dt><dd class="mono">{{ f.symbol }}</dd></template>
            <template v-if="f.cwe"><dt>{{ t('security.weakness') }}</dt><dd>{{ f.cwe }}<span v-if="f.owasp"> · OWASP {{ f.owasp }}</span></dd></template>
            <template v-if="f.tool"><dt>{{ t('security.foundBy') }}</dt><dd>{{ f.tool }}</dd></template>
            <template v-if="f.rules.length"><dt>{{ t('security.rules') }}</dt><dd class="mono sec-adv">{{ f.rules.join(', ') }}</dd></template>
            <template v-if="f.secretMask"><dt>{{ t('security.secret') }}</dt><dd class="mono">{{ f.secretMask }}</dd></template>
            <template v-if="f.commit"><dt>{{ t('security.commit') }}</dt><dd class="mono">{{ f.commit.slice(0, 10) }}</dd></template>
            <dt>{{ t('security.firstSeen') }}</dt><dd :title="when(f.firstSeen)">{{ ago(f.firstSeen, locale) }}</dd>
            <dt>{{ t('security.lastSeen') }}</dt><dd :title="when(f.lastSeen)">{{ ago(f.lastSeen, locale) }}</dd>
            <dt>{{ t('security.lastChecked') }}</dt><dd :title="when(f.lastChecked)">{{ ago(f.lastChecked, locale) }}</dd>
            <template v-if="f.ticketKey">
              <dt>{{ t('security.ticket') }}</dt>
              <dd><RouterLink :to="{ name: 'ticket', params: { key: f.ticketKey } }">{{ f.ticketKey }}</RouterLink> <StateBadge v-if="f.ticketState" :state="f.ticketState" /></dd>
            </template>
          </dl>
        </section>
      </aside>
    </div>
  </template>
</template>

<style scoped>
.sec-head { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-top: 6px; }
.sec-head .mono, .mono { font-family: var(--mono); font-size: 13px; overflow-wrap: anywhere; }
.sec-text { margin: 0; white-space: pre-wrap; overflow-wrap: anywhere; }
.sec-h3 { font-size: 14px; margin: 14px 0 6px; }
.sec-patch { margin: 10px 0 0; padding: 12px; background: var(--bg2, #f6f7f9); border-radius: 8px; font-family: var(--mono); font-size: 12.5px; overflow: auto; white-space: pre; }
.sec-adv { overflow-wrap: anywhere; }
.sec-refs { margin: 0; padding-left: 18px; }
.sec-refs a { overflow-wrap: anywhere; }
.sec-dismiss { display: grid; gap: 10px; max-width: 520px; }
</style>
