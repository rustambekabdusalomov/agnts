<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { components } from '../../api/schema.gen'

type Result = components['schemas']['Result']
type Proof = components['schemas']['Proof']

// What the harness checked in a result: the proof that a bug fix fixes the
// bug, and how much of the change the tests ran. Advice for the reviewer.
const props = defineProps<{ result?: Result }>()
const { t } = useI18n()

const proof = computed(() => props.result?.proof)
const coverage = computed(() => props.result?.coverage)
const PROOF_TONE: Record<Proof['status'], string> = {
  proven: 'b-ok', not_reproduced: 'b-warn', still_failing: 'b-bad', inconclusive: 'b-gray', no_test: 'b-gray', error: 'b-warn',
}
const below = computed(() => {
  const c = coverage.value
  return !!c && !!c.threshold && c.total > 0 && c.percent < c.threshold
})
const ranges = (us: { from: number; to: number }[]) => us.map((u) => (u.from === u.to ? `${u.from}` : `${u.from}–${u.to}`)).join(', ')
</script>

<template>
  <div v-if="proof || coverage" class="hc">
    <div v-if="proof" class="sec hc-card">
      <div class="hc-h">
        <h3>{{ t('harnessTicket.proofTitle') }}</h3>
        <span class="badge" :class="PROOF_TONE[proof.status]">{{ t(`harnessTicket.proof_${proof.status}`) }}</span>
      </div>
      <p class="hint">{{ t(`harnessTicket.proofHelp_${proof.status}`) }}</p>
      <p v-if="proof.why" class="hc-why">{{ proof.why }}</p>
      <p v-if="proof.base" class="hint mono">{{ t('harnessTicket.proofBase', { sha: proof.base.slice(0, 10) }) }}</p>
      <div v-for="(x, i) in proof.tests" :key="i" class="hc-test">
        <p class="hc-name"><b>{{ x.name }}</b> <code>{{ x.file }}</code></p>
        <code class="hc-cmd">$ {{ x.command }}</code>
        <details>
          <summary>{{ t('harnessTicket.proofBefore', { code: x.before.exit }) }}</summary>
          <pre class="hc-out">{{ x.before.output }}</pre>
        </details>
        <details>
          <summary>{{ t('harnessTicket.proofAfter', { code: x.after.exit }) }}</summary>
          <pre class="hc-out">{{ x.after.output }}</pre>
        </details>
      </div>
    </div>

    <div v-if="coverage" class="sec hc-card">
      <div class="hc-h">
        <h3>{{ t('harnessTicket.coverageTitle') }}</h3>
        <span v-if="!coverage.error && coverage.total > 0" class="badge" :class="below ? 'b-warn' : 'b-ok'">{{ coverage.percent }}%</span>
      </div>
      <p v-if="coverage.error" class="help warn hc-why">{{ t('harnessTicket.coverageError', { error: coverage.error }) }}</p>
      <p v-else-if="coverage.total === 0" class="hint">{{ t('harnessTicket.coverageNone') }}</p>
      <template v-else>
        <p class="hc-pct">{{ t('harnessTicket.coveragePct', { pct: coverage.percent, covered: coverage.covered, total: coverage.total }) }}</p>
        <p v-if="below" class="hc-below">{{ t('harnessTicket.coverageBelow', { n: coverage.threshold }) }}</p>
        <ul class="hc-files">
          <li v-for="f in coverage.files.filter((x) => x.uncovered.length)" :key="f.path">
            <code>{{ f.path }}</code> <span class="hint">{{ f.covered }}/{{ f.total }}</span>
            <div class="hint">{{ t('harnessTicket.coverageLines', { ranges: ranges(f.uncovered) }) }}</div>
          </li>
        </ul>
      </template>
    </div>
  </div>
</template>

<style scoped>
.hc { display: grid; gap: 4px; }
.hc-h { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.hc-h h3 { margin: 0; }
.hc-card .hint { margin: 6px 0 0; }
.hc-why { margin: 6px 0 0; white-space: pre-wrap; }
.hc-test { border: 1px solid var(--line); border-radius: 12px; padding: 10px 14px; margin-top: 10px; display: grid; gap: 6px; }
.hc-name { margin: 0; overflow-wrap: anywhere; }
.hc-cmd { font-size: 12.5px; color: var(--ink-2); overflow-wrap: anywhere; }
.hc-test summary { cursor: pointer; font-size: 13.5px; color: var(--ink-2); }
.hc-out { margin: 6px 0 0; white-space: pre-wrap; overflow-wrap: anywhere; font: 12px/1.45 var(--mono); max-height: 260px; overflow: auto; }
.hc-pct { margin: 8px 0 0; }
.hc-below { margin: 4px 0 0; color: var(--warn-ink); font-weight: 600; }
.hc-files { list-style: none; padding: 0; margin: 8px 0 0; display: grid; gap: 6px; font-size: 13.5px; }
.hc-files code { overflow-wrap: anywhere; }
</style>
