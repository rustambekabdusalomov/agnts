<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { apiPath } from '../../api/client'
import PageHeader from '../../components/PageHeader.vue'
import RunTimeline from '../../components/runs/RunTimeline.vue'
import { durationOf, field, statusBadge } from '../../components/runs/runs'
import CopyButton from '../../components/ui/CopyButton.vue'
import HiIcon from '../../components/ui/HiIcon.vue'
import { fmtBytes, fmtDur, fmtTokens, fmtUsd } from '../../composables/format'
import { useRun, useRunPrompt } from '../../composables/usePlatform'

// One invocation as Claude Code (or Codex) ran it: who, what, what it cost,
// and its whole timeline. This is customer content: the server logs every
// read, so the transcript is fetched once per visit and the prompt only when
// its tab is opened.
const { t, te, locale } = useI18n()
const route = useRoute()
const id = computed(() => Number(route.params.id) || 0)
const run = useRun(id)
const tr = computed(() => run.data.value?.transcript)

const TABS = ['timeline', 'prompt', 'result'] as const
const tab = ref<(typeof TABS)[number]>('timeline')
watch(id, () => (tab.value = 'timeline'))
const prompt = useRunPrompt(id, computed(() => tab.value === 'prompt'))
const result = computed(() => [...(run.data.value?.events ?? [])].reverse().find((e) => e.k === 'result'))
const siblings = computed(() => run.data.value?.siblings ?? [])

const notFound = computed(() => (run.error.value as { status?: number } | null)?.status === 404)
const purposeLabel = (p: string) => (te(`runs.p_${p}`) ? t(`runs.p_${p}`) : p)
const when = (iso?: string) => (iso ? new Date(iso).toLocaleString(locale.value) : '—')
const usd = (n: number) => fmtUsd(n, locale.value)
const tok = (n: number) => fmtTokens(n, locale.value)
const title = computed(() => (tr.value ? `${tr.value.ticketKey || tr.value.subject || tr.value.workspace} · ${purposeLabel(tr.value.purpose)}` : t('runs.runTitle')))
</script>

<template>
  <PageHeader :title="title">
    <template #below>
      <p class="sub" style="margin: 2px 0 0"><RouterLink class="link-btn" :to="{ name: 'adminRuns' }">← {{ t('runs.back') }}</RouterLink></p>
    </template>
    <div v-if="tr" class="actions" style="margin: 0">
      <a class="btn" :href="apiPath(`/platform/runs/${tr.id}/download`)" download>{{ t('runs.download') }}</a>
    </div>
  </PageHeader>

  <p class="ro-banner" role="note"><HiIcon name="eye" />{{ t('runs.banner') }}</p>

  <p v-if="run.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="notFound" class="empty">{{ t('runs.notFound') }}</p>
  <p v-else-if="run.isError.value || !tr" class="ferr">{{ t('common.error') }}</p>
  <template v-else>
    <div v-if="run.data.value?.unreadable" class="wait-banner" role="alert"><HiIcon name="needs" /><p>{{ t('runs.unreadable') }}</p></div>
    <div v-if="tr.truncated" class="wait-banner" role="note"><HiIcon name="needs" /><p>{{ t('runs.truncated') }}</p></div>

    <section class="card">
      <dl class="facts">
        <div><dt>{{ t('runs.colWorkspace') }}</dt><dd>{{ tr.workspace }}</dd></div>
        <div><dt>{{ t('runs.colTicket') }}</dt><dd :class="{ mono: !!tr.ticketKey }">{{ tr.ticketKey || tr.subject || '—' }}</dd></div>
        <div><dt>{{ t('runs.colPurpose') }}</dt><dd>{{ purposeLabel(tr.purpose) }}<template v-if="tr.modelStage && tr.modelStage !== tr.purpose"> · {{ tr.modelStage }}</template></dd></div>
        <div><dt>{{ t('runs.colModel') }}</dt><dd><span class="run-small">{{ t(`runs.e_${tr.engine}`) }}</span> <span class="mono run-small">{{ tr.model || '—' }}</span></dd></div>
        <div><dt>{{ t('runs.account') }}</dt><dd class="run-small">{{ tr.claudeAccount || '—' }}<template v-if="tr.claudeUser"> · {{ tr.claudeUser }}</template></dd></div>
        <div><dt>{{ t('runs.session') }}</dt><dd class="mono run-small run-wrap">{{ tr.sessionId || '—' }}</dd></div>
        <div><dt>{{ t('runs.startedAt') }}</dt><dd class="run-small">{{ when(tr.startedAt) }}</dd></div>
        <div><dt>{{ t('runs.finishedAt') }}</dt><dd class="run-small">{{ when(tr.finishedAt) }}</dd></div>
        <div><dt>{{ t('runs.colDuration') }}</dt><dd>{{ fmtDur(durationOf(tr)) }}</dd></div>
        <div><dt>{{ t('runs.colTurns') }}</dt><dd>{{ tr.turns }}</dd></div>
        <div><dt>{{ t('runs.colTools') }}</dt><dd>{{ tr.toolCalls }} <span :class="tr.toolErrors ? 'bad' : 'muted'">/ {{ tr.toolErrors }}</span></dd></div>
        <div>
          <dt>{{ t('runs.tokens') }}</dt>
          <dd class="run-small">{{ t('runs.tokensVal', { input: tok(tr.inputTokens), output: tok(tr.outputTokens) }) }}</dd>
          <dd class="hint">{{ t('runs.cacheVal', { read: tok(tr.cacheReadTokens), write: tok(tr.cacheWriteTokens) }) }}</dd>
        </div>
        <div><dt>{{ t('runs.colCost') }}</dt><dd>{{ usd(tr.costUsd) }}</dd></div>
        <div>
          <dt>{{ t('runs.colOutcome') }}</dt>
          <dd>
            <span v-if="tr.status === 'running'" class="live">{{ t('runs.s_running') }}</span>
            <span v-else class="badge" :class="statusBadge(tr.status)">{{ t(`runs.s_${tr.status}`) }}</span>
            <span v-if="tr.stalls" class="run-stall"> ⚠ {{ tr.stalls }}</span>
          </dd>
        </div>
        <div><dt>{{ t('runs.size') }}</dt><dd class="run-small">{{ fmtBytes(tr.storedBytes) }} / {{ fmtBytes(tr.rawBytes) }}</dd></div>
        <div v-if="tr.exitReason" class="run-wide"><dt>{{ t('runs.exitReason') }}</dt><dd class="mono run-small run-wrap">{{ tr.exitReason }}</dd></div>
      </dl>
      <div v-if="tr.status === 'running'" class="actions">
        <span class="hint">{{ t('runs.runningNote') }}</span>
        <button class="btn btn-s" type="button" :disabled="run.isFetching.value" @click="run.refetch()">{{ t('runs.reload') }}</button>
      </div>
    </section>

    <section v-if="siblings.length" class="card">
      <div class="ch"><div><h2>{{ t('runs.siblings') }}</h2><p class="sub">{{ t('runs.siblingsSub') }}</p></div></div>
      <ul class="adm-list">
        <li v-for="s in siblings" :key="s.id">
          <span class="adm-who">
            <RouterLink v-if="s.id !== tr.id" class="link-btn" :to="{ name: 'adminRun', params: { id: s.id } }">{{ purposeLabel(s.purpose) }}<template v-if="s.modelStage && s.modelStage !== s.purpose"> · {{ s.modelStage }}</template></RouterLink>
            <b v-else>{{ purposeLabel(s.purpose) }} · {{ t('runs.thisOne') }}</b>
            <small>{{ when(s.startedAt) }} · {{ s.model }} · {{ usd(s.costUsd) }}</small>
          </span>
          <span class="badge" :class="statusBadge(s.status)">{{ t(`runs.s_${s.status}`) }}</span>
        </li>
      </ul>
    </section>

    <section class="card">
      <div class="page-tabs" role="tablist">
        <button v-for="x in TABS" :key="x" class="page-tab" type="button" role="tab" :aria-selected="tab === x" @click="tab = x">{{ t(`runs.tab_${x}`) }}</button>
      </div>
      <RunTimeline v-if="tab === 'timeline'" :events="run.data.value?.events ?? []" />
      <template v-else-if="tab === 'prompt'">
        <p v-if="prompt.isPending.value" class="hint">{{ t('common.loading') }}</p>
        <p v-else-if="prompt.isError.value" class="ferr">{{ t('common.error') }}</p>
        <template v-else>
          <div class="actions" style="margin: 0 0 10px"><CopyButton :text="prompt.data.value?.prompt ?? ''" /></div>
          <pre class="run-pre">{{ prompt.data.value?.prompt || t('runs.noPrompt') }}</pre>
        </template>
      </template>
      <template v-else>
        <p v-if="!result" class="empty">{{ t('runs.noResult') }}</p>
        <template v-else>
          <dl class="facts" style="margin-bottom: 12px">
            <div><dt>{{ t('runs.subtype') }}</dt><dd class="run-small" :class="{ bad: result.error === true }">{{ field(result, 'subtype') || '—' }}</dd></div>
            <div><dt>{{ t('runs.colTurns') }}</dt><dd>{{ field(result, 'turns') || '—' }}</dd></div>
            <div><dt>{{ t('runs.colCost') }}</dt><dd>{{ typeof result.cost === 'number' ? usd(result.cost) : '—' }}</dd></div>
          </dl>
          <pre class="run-pre" :class="{ err: result.error === true }">{{ field(result, 'text') || t('runs.noOutput') }}</pre>
        </template>
      </template>
    </section>
  </template>
</template>

<style scoped>
.run-small { font-size: 14px; }
.run-wrap { overflow-wrap: anywhere; }
.run-wide { grid-column: 1 / -1; }
.run-stall { color: var(--warn-ink); font-weight: 700; }
.facts dd.bad, .facts .bad { color: var(--bad-ink); }
.run-pre { margin: 0; padding: 12px 14px; border-radius: 10px; background: var(--code); color: var(--code-ink); font-family: var(--mono); font-size: 13px; line-height: 1.55; white-space: pre-wrap; overflow-wrap: anywhere; max-height: 70vh; overflow: auto; }
.run-pre.err { box-shadow: inset 3px 0 0 var(--bad); }
</style>
