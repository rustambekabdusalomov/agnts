<script setup lang="ts">
import { computed, nextTick, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import type { RunEvent } from '../../composables/usePlatform'
import { clock, field, inputText, kb, timeline } from './runs'

// A transcript's lines in order: Claude's text, each tool call with its
// result (folded), rate limits, agnts's own notes and the result. Everything
// is customer content shown as text, never as HTML. Long transcripts are
// shown a page at a time.
const props = defineProps<{ events: RunEvent[] }>()
const { t } = useI18n()

const PAGE = 500
const items = computed(() => timeline(props.events))
const shown = ref(PAGE)
const visible = computed(() => items.value.slice(0, shown.value))
const opened = reactive(new Set<number>())
const toggle = (i: number) => (opened.has(i) ? opened.delete(i) : opened.add(i))

const errors = computed(() => items.value.flatMap((it, i) => (it.error ? [i] : [])))
const current = ref(-1)
watch(() => props.events, () => {
  shown.value = PAGE
  opened.clear()
  current.value = -1
})

/** Scrolls to the next failed tool call or error result, wrapping around. */
async function nextError() {
  const i = errors.value.find((e) => e > current.value) ?? errors.value[0]
  if (i === undefined) return
  current.value = i
  if (i >= shown.value) shown.value = Math.ceil((i + 1) / PAGE) * PAGE
  if (items.value[i]!.kind === 'tool') opened.add(i)
  await nextTick()
  document.getElementById(`ev-${i}`)?.scrollIntoView?.({ block: 'center', behavior: 'smooth' })
}

const cut = (e: RunEvent | undefined) => (typeof e?.cut === 'number' && e.cut > 0 ? t('runs.cutNote', { kb: kb(e.cut) }) : '')
const num = (e: RunEvent | undefined, k: string) => (typeof e?.[k] === 'number' ? (e[k] as number) : undefined)
const pretty = (e: RunEvent) => {
  const rest: Record<string, unknown> = { ...e }
  delete rest.k
  delete rest.t
  return JSON.stringify(rest, null, 2)
}
defineExpose({ nextError })
</script>

<template>
  <div class="filters">
    <span class="hint">{{ t('runs.eventsCount', { n: items.length }) }}</span>
    <button class="btn btn-s" type="button" :disabled="!errors.length" @click="nextError">
      {{ errors.length ? t('runs.nextError', { n: errors.length }) : t('runs.noErrors') }}
    </button>
  </div>
  <p v-if="!items.length" class="empty">{{ t('runs.noEvents') }}</p>
  <ol v-else class="rtl">
    <li v-for="(it, i) in visible" :id="`ev-${i}`" :key="i" class="rtl-i" :class="{ err: it.error, cur: current === i }">
      <span class="rtl-t">{{ clock(it.at) }}</span>
      <div class="rtl-b">
        <template v-if="it.kind === 'tool'">
          <button class="rtl-h" type="button" :aria-expanded="opened.has(i)" @click="toggle(i)">
            <span class="rtl-chev" aria-hidden="true">{{ opened.has(i) ? '▾' : '▸' }}</span>
            <b class="mono">{{ field(it.tool, 'name') || t('runs.kTool') }}</b>
            <span class="rtl-sum">{{ field(it.tool, 'summary') }}</span>
            <span v-if="!it.result" class="muted">…</span>
            <span v-else-if="it.error" class="rtl-bad" :title="t('runs.toolFailed')">✗<template v-if="num(it.result, 'exit_code') !== undefined"> {{ t('runs.exitCode', { code: num(it.result, 'exit_code')! }) }}</template></span>
            <span v-else class="rtl-ok" :title="t('runs.toolOk')">✓<template v-if="num(it.result, 'exit_code')"> {{ t('runs.exitCode', { code: num(it.result, 'exit_code')! }) }}</template></span>
          </button>
          <div v-if="opened.has(i)" class="rtl-d">
            <template v-if="inputText(it.tool.input)">
              <div class="rtl-lbl">{{ t('runs.input') }} <span v-if="cut(it.tool)" class="rtl-cut">{{ cut(it.tool) }}</span></div>
              <pre class="rtl-pre">{{ inputText(it.tool.input) }}</pre>
            </template>
            <template v-if="it.result">
              <div class="rtl-lbl">{{ t('runs.output') }} <span v-if="cut(it.result)" class="rtl-cut">{{ cut(it.result) }}</span></div>
              <pre class="rtl-pre" :class="{ err: it.error }">{{ field(it.result, 'output') || t('runs.noOutput') }}</pre>
            </template>
          </div>
        </template>
        <template v-else-if="it.ev.k === 'text'">
          <div class="rtl-text">{{ field(it.ev, 'text') }}</div>
          <div v-if="cut(it.ev)" class="rtl-cut">{{ cut(it.ev) }}</div>
        </template>
        <template v-else-if="it.ev.k === 'init'">
          <span class="badge b-gray">{{ t('runs.kInit') }}</span> <span class="mono rtl-sum">{{ [field(it.ev, 'model'), field(it.ev, 'session_id')].filter(Boolean).join(' · ') }}</span>
        </template>
        <template v-else-if="it.ev.k === 'rate_limit'">
          <span class="badge b-warn">{{ t('runs.kRateLimit') }}</span> <span class="rtl-sum">{{ field(it.ev, 'status') }}</span>
        </template>
        <template v-else-if="it.ev.k === 'note'">
          <span class="badge b-warn">{{ t('runs.kNote') }}</span> <span class="rtl-note">{{ field(it.ev, 'text') }}</span>
        </template>
        <template v-else-if="it.ev.k === 'result'">
          <span class="badge" :class="it.error ? 'b-bad' : 'b-ok'">{{ t('runs.kResult') }}</span>
          <span class="rtl-sum"> {{ [field(it.ev, 'subtype'), field(it.ev, 'turns') && t('runs.turnsN', { n: Number(field(it.ev, 'turns')) })].filter(Boolean).join(' · ') }}</span>
          <div v-if="field(it.ev, 'text')" class="rtl-text" :class="{ 'rtl-bad': it.error }">{{ field(it.ev, 'text') }}</div>
          <div v-if="cut(it.ev)" class="rtl-cut">{{ cut(it.ev) }}</div>
        </template>
        <template v-else-if="it.ev.k === 'tool_result'">
          <span class="badge" :class="it.error ? 'b-bad' : 'b-gray'">{{ t('runs.kToolResult') }}</span>
          <pre class="rtl-pre" :class="{ err: it.error }">{{ field(it.ev, 'output') || t('runs.noOutput') }}</pre>
          <div v-if="cut(it.ev)" class="rtl-cut">{{ cut(it.ev) }}</div>
        </template>
        <template v-else>
          <span class="badge b-gray">{{ it.ev.k }}</span>
          <pre class="rtl-pre">{{ pretty(it.ev) }}</pre>
        </template>
      </div>
    </li>
  </ol>
  <div v-if="items.length > shown" class="actions" style="justify-content: center">
    <button class="btn" type="button" @click="shown += PAGE">{{ t('runs.showMore', { n: Math.min(PAGE, items.length - shown) }) }}</button>
  </div>
</template>

<style scoped>
.rtl { list-style: none; margin: 0; padding: 0; }
.rtl-i { display: grid; grid-template-columns: 52px minmax(0, 1fr); gap: 10px; padding: 8px 0; border-bottom: 1px solid var(--line-2); }
.rtl-i:last-child { border-bottom: 0; }
.rtl-i.cur { box-shadow: inset 3px 0 0 var(--bad); }
.rtl-t { font-family: var(--mono); font-size: 12.5px; color: var(--ink-3); padding-top: 3px; }
.rtl-b { min-width: 0; }
.rtl-h { display: flex; align-items: baseline; gap: 8px; width: 100%; padding: 2px 0; border: 0; background: none; text-align: left; cursor: pointer; font-size: 14px; }
.rtl-chev { flex: none; width: 12px; color: var(--ink-3); }
.rtl-sum { flex: 1; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: var(--ink-2); font-size: 13.5px; }
.rtl-ok { color: var(--ok-ink); font-weight: 700; white-space: nowrap; }
.rtl-bad { color: var(--bad-ink); font-weight: 700; }
.rtl-i.err .rtl-h b { color: var(--bad-ink); }
.rtl-d { margin: 6px 0 2px 20px; }
.rtl-lbl { margin: 8px 0 4px; font-size: 12.5px; font-weight: 700; color: var(--ink-3); }
.rtl-pre { margin: 4px 0 0; padding: 10px 12px; border-radius: 8px; background: var(--code); color: var(--code-ink); font-family: var(--mono); font-size: 12.5px; line-height: 1.55; white-space: pre-wrap; overflow-wrap: anywhere; max-height: 420px; overflow: auto; }
.rtl-pre.err { box-shadow: inset 3px 0 0 var(--bad); }
.rtl-text { white-space: pre-wrap; overflow-wrap: anywhere; font-size: 14px; }
.rtl-note { color: var(--warn-ink); font-size: 14px; }
.rtl-cut { font-size: 12.5px; font-weight: 400; color: var(--warn-ink); }
</style>
