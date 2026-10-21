<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Analysis } from '../../api/types'
import { useTr } from '../../composables/useTranslation'

// The decisions behind a ticket's work: the approach the analysis chose and
// the ones it rejected, what it leaves out, how the change ships, and where
// the coding run departed from all that.
const props = defineProps<{ analysis?: Analysis; deviations?: string[] }>()
const { t } = useI18n()
const tr = useTr()

const chosen = computed(() => props.analysis?.approaches?.find((a) => a.chosen))
const others = computed(() => props.analysis?.approaches?.filter((a) => !a.chosen) ?? [])
const scope = computed(() => props.analysis?.outOfScope ?? [])
const ship = computed(() => {
  const s = props.analysis?.ship
  if (!s) return []
  return (['migrations', 'compatibility', 'rollout', 'rollback'] as const).filter((k) => s[k]).map((k) => ({ k, v: s[k] as string }))
})
const devs = computed(() => props.deviations ?? [])
const criteria = computed(() => props.analysis?.acceptance ?? [])
const second = computed(() => props.analysis?.secondOpinion)
const patterns = computed(() => props.analysis?.patterns ?? [])
const reuse = computed(() => props.analysis?.reuse ?? [])
const testPlan = computed(() => props.analysis?.testPlan ?? [])
const edges = computed(() => props.analysis?.edgeCases ?? [])
const repro = computed(() => props.analysis?.repro)
const any = computed(() => !!chosen.value || scope.value.length > 0 || ship.value.length > 0 || devs.value.length > 0 ||
  !!props.analysis?.defect || criteria.value.length > 0 || !!second.value || patterns.value.length > 0 || reuse.value.length > 0 ||
  testPlan.value.length > 0 || edges.value.length > 0 || !!repro.value)
</script>

<template>
  <div v-if="any" class="sec design">
    <p v-if="analysis?.defect"><span class="badge b-warn">{{ t('harnessTicket.defect') }}</span></p>
    <template v-if="chosen">
      <h3>{{ t('design.approach') }}</h3>
      <p><b>{{ tr(chosen.title) }}</b> — {{ tr(chosen.sketch) }}</p>
      <p v-if="chosen.why" class="hint">{{ tr(chosen.why) }}</p>
      <p v-if="chosen.fit" class="hint">{{ t('design.fit') }}: {{ tr(chosen.fit) }}</p>
      <details v-if="others.length" class="design-alt">
        <summary>{{ t('design.alternatives', { n: others.length }) }}</summary>
        <div v-for="(a, i) in others" :key="i" class="design-alt-item">
          <p><b>{{ tr(a.title) }}</b> — {{ tr(a.sketch) }}</p>
          <p v-if="a.why" class="hint">{{ t('design.whyNot') }}: {{ tr(a.why) }}</p>
          <ul v-if="a.pros.length || a.cons.length" class="design-pc">
            <li v-for="(p, j) in a.pros" :key="`p${j}`" class="ok">+ {{ tr(p) }}</li>
            <li v-for="(c, j) in a.cons" :key="`c${j}`" class="bad">− {{ tr(c) }}</li>
          </ul>
        </div>
      </details>
    </template>
    <template v-if="repro">
      <h3>{{ t('design.reproTitle') }}</h3>
      <template v-if="repro.reproduced">
        <pre class="design-repro"><span v-if="repro.command">$ {{ repro.command }}</span>{{ repro.output ? `\n${repro.output}` : '' }}</pre>
      </template>
      <p v-else class="hint">{{ t('design.reproNot') }}<template v-if="repro.why">: {{ tr(repro.why) }}</template></p>
    </template>
    <template v-if="patterns.length || reuse.length">
      <h3>{{ t('design.fitTitle') }}</h3>
      <ul class="design-acc">
        <li v-for="p in patterns" :key="p.file">
          <code>{{ p.file }}</code>
          <span class="badge" :class="p.kind === 'new' ? 'b-warn' : 'b-gray'">{{ t(`design.kind_${p.kind}`) }}</span>
          <template v-if="p.kind === 'new'">
            <span v-if="p.like" class="hint"> {{ t('design.conventionsFrom') }} <code>{{ p.like }}</code></span>
            <span v-if="p.place" class="hint"> · {{ t('design.goesIn') }} {{ tr(p.place) }}</span>
          </template>
          <span v-else class="hint"> {{ t('design.like') }} <code>{{ p.like }}</code></span>
          <span v-if="p.layer" class="hint"> · {{ tr(p.layer) }}</span>
          <p v-if="p.why" class="hint" style="margin: 2px 0 0">{{ tr(p.why) }}</p>
          <p v-if="p.precedent" class="hint" style="margin: 2px 0 0; color: var(--warn-ink)">{{ t('design.precedent') }}</p>
        </li>
      </ul>
      <template v-if="reuse.length">
        <p class="hint" style="margin: 8px 0 4px">{{ t('design.reuseTitle') }}</p>
        <ul class="design-acc">
          <li v-for="r in reuse" :key="`${r.where}/${r.name}`"><code>{{ r.name }}</code> <span class="hint">{{ r.where }}</span><template v-if="r.for"> — {{ tr(r.for) }}</template></li>
        </ul>
      </template>
    </template>
    <template v-if="testPlan.length">
      <h3>{{ t('design.testPlanTitle') }}</h3>
      <ul class="design-acc"><li v-for="(x, i) in testPlan" :key="i"><code>{{ x.file }}</code> {{ tr(x.what) }}</li></ul>
    </template>
    <template v-if="edges.length">
      <h3>{{ t('design.edgeCasesTitle') }}</h3>
      <ul class="design-acc"><li v-for="(e, i) in edges" :key="i">{{ tr(e) }}</li></ul>
    </template>
    <template v-if="scope.length">
      <h3>{{ t('design.outOfScope') }}</h3>
      <ul><li v-for="(s, i) in scope" :key="i">{{ tr(s) }}</li></ul>
    </template>
    <template v-if="ship.length">
      <h3>{{ t('design.shipping') }}</h3>
      <dl class="design-ship">
        <div v-for="x in ship" :key="x.k"><dt>{{ t(`design.ship_${x.k}`) }}</dt><dd>{{ tr(x.v) }}</dd></div>
      </dl>
    </template>
    <template v-if="criteria.length">
      <h3>{{ t('harnessTicket.acceptanceTitle') }}</h3>
      <ul class="design-acc">
        <li v-for="c in criteria" :key="c.id">
          <code>{{ c.id }}</code> {{ tr(c.criterion) }} <span class="badge b-gray">{{ t(`harnessTicket.check_${c.check}`) }}</span>
        </li>
      </ul>
    </template>
    <template v-if="second">
      <h3>{{ t('harnessTicket.secondTitle') }}</h3>
      <div class="design-second">
        <p v-if="second.error" class="hint">{{ t('harnessTicket.secondError', { error: second.error }) }}</p>
        <template v-else>
          <p>
            <span class="badge" :class="second.agrees ? 'b-ok' : 'b-warn'">{{ second.agrees ? t('harnessTicket.secondAgrees') : t('harnessTicket.secondConcerns') }}</span>
            <span class="hint"> {{ t('harnessTicket.secondBy', { model: second.model }) }}</span>
          </p>
          <p>{{ tr(second.summary) }}</p>
          <ul v-if="second.concerns?.length"><li v-for="(c, i) in second.concerns" :key="i">{{ tr(c) }}</li></ul>
          <p v-if="second.alternative"><b>{{ t('harnessTicket.secondAlternative') }}:</b> {{ tr(second.alternative) }}</p>
        </template>
      </div>
    </template>
    <template v-if="devs.length">
      <h3>{{ t('design.deviations') }}</h3>
      <div class="help warn"><ul><li v-for="(d, i) in devs" :key="i">{{ tr(d) }}</li></ul></div>
    </template>
  </div>
</template>

<style scoped>
.design p { margin: 0 0 6px; }
.design-alt { margin: 6px 0 4px; }
.design-alt summary { cursor: pointer; color: var(--ink-2); font-size: 14px; }
.design-alt-item { padding: 8px 0 0 12px; border-left: 2px solid var(--line); margin-top: 8px; }
.design-pc { list-style: none; padding: 0; margin: 4px 0 0; font-size: 13.5px; }
.design-pc .ok { color: var(--ok); }
.design-pc .bad { color: var(--bad); }
.design-ship { margin: 0 0 6px; }
.design-acc { padding-left: 18px; margin: 0 0 6px; }
.design-acc li { margin: 4px 0; }
.design-repro { white-space: pre-wrap; font-size: 12.5px; background: var(--code); color: var(--code-ink); border-radius: 8px; padding: 8px 10px; margin: 0 0 6px; overflow-x: auto; }
.design-second { border: 1px solid var(--line); border-radius: 12px; padding: 10px 14px; margin-bottom: 6px; }
.design-ship div { display: grid; grid-template-columns: 130px 1fr; gap: 12px; padding: 8px 0; border-top: 1px solid var(--line-2); }
.design-ship div:first-child { border-top: 0; padding-top: 0; }
.design-ship dt { font-size: 13px; color: var(--ink-3); padding-top: 1px; }
.design-ship dd { margin: 0; max-width: 72ch; }
@media (max-width: 560px) {
  .design-ship div { grid-template-columns: 1fr; gap: 2px; }
}
</style>
