<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Footprint, Relation, Relations, RelationType, Ticket } from '../../api/types'
import { askConfirm } from '../../composables/useConfirm'
import { useTr } from '../../composables/useTranslation'
import { useUi } from '../../stores/ui'
import StateBadge from '../StateBadge.vue'
import InputSelect from '../form/InputSelect.vue'

// The ticket's place in the queue: what it waits for, what it must not run
// beside, and what agnts suggests and is not sure about. Only active
// relations hold the queue; proposed ones wait here for a decision.
const props = defineProps<{ ticket: Ticket; relations?: Relations; footprint?: Footprint }>()
const { t } = useI18n()
const tr = useTr()
const qc = useQueryClient()
const ui = useUi()

const items = computed(() => props.relations?.items ?? [])
const proposed = computed(() => items.value.filter((r) => r.status === 'proposed'))
const active = computed(() => items.value.filter((r) => r.status === 'active'))
const dismissed = computed(() => items.value.filter((r) => r.status === 'dismissed'))
const blockedBy = computed(() => props.relations?.blockedBy ?? [])

const refresh = () => {
  void qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] })
  for (const k of ['tickets', 'nav']) void qc.invalidateQueries({ queryKey: [k] })
}
const fail = (e: unknown) => ui.notify(e instanceof HttpError ? e.message : t('common.error'))

const decide = useMutation({
  mutationFn: ({ r, accept }: { r: Relation; accept: boolean }) =>
    unwrap(
      api.POST(accept ? '/tickets/{key}/relations/{id}/accept' : '/tickets/{key}/relations/{id}/dismiss', {
        params: { path: { key: props.ticket.key, id: r.id } },
      }),
    ),
  onSuccess: refresh,
  onError: fail,
})

async function runAnyway(r: Relation) {
  const ok = await askConfirm({
    title: t('relations.remove'),
    message: t('relations.removeConfirm', { key: props.ticket.key, other: r.other.key }),
    confirmLabel: t('relations.remove'),
  })
  if (ok) decide.mutate({ r, accept: false })
}

// Adding: pick another ticket and how the two relate.
const newType = ref<RelationType>('depends_on')
const newOther = ref<string | undefined>(undefined)
const typeOptions = computed(() => [
  { value: 'depends_on' as const, label: t('relations.waitsFor') },
  { value: 'conflicts' as const, label: t('relations.conflicts') },
])
const others = useQuery({
  queryKey: ['tickets', 'relation-picker'],
  queryFn: () => unwrap(api.GET('/tickets', {})),
  staleTime: 30_000,
})
const otherOptions = computed(() =>
  (others.data.value ?? [])
    .filter((x) => x.key !== props.ticket.key && x.state !== 'rejected' && !(x.state === 'done' && (x.mergedAt || x.kind !== 'code')))
    .map((x) => ({ value: x.key as string | undefined, label: `${x.key} · ${x.title}` })),
)
const add = useMutation({
  mutationFn: () =>
    unwrap(
      api.POST('/tickets/{key}/relations', {
        params: { path: { key: props.ticket.key } },
        body: { otherKey: newOther.value ?? '', type: newType.value },
      }),
    ),
  onSuccess: () => {
    newOther.value = undefined
    ui.notify(t('relations.added'))
    refresh()
  },
  onError: fail,
})

const dirLabel = (r: Relation) => t(r.direction === 'waits_for' ? 'relations.waitsFor' : r.direction === 'waited_by' ? 'relations.waitedBy' : 'relations.conflicts')
const basisText = (r: Relation) => {
  if (!r.basis) return ''
  const files = r.files.slice(0, 4).join(', ') + (r.files.length > 4 ? ` +${r.files.length - 4}` : '')
  return t(`relations.basis_${r.basis}`, { files })
}
const tone = (r: Relation) => (r.direction === 'conflicts' ? 'warn' : 'info')
</script>

<template>
  <section class="card rel">
    <div class="ch">
      <div>
        <h2>{{ t('relations.title') }}</h2>
        <p class="sub">{{ t('relations.sub') }}</p>
      </div>
    </div>

    <div v-if="blockedBy.length" class="help warn rel-wait" role="status">
      <p>
        <b>{{ t('relations.waitingTitle') }}:</b>
        <template v-for="(b, i) in blockedBy" :key="b.key">
          <template v-if="i">, </template><RouterLink :to="`/tickets/${b.key}`">{{ b.key }}</RouterLink>
        </template>.
        {{ t('relations.waitingSub') }}
      </p>
    </div>

    <template v-if="proposed.length">
      <h3 class="rel-h3">{{ t('relations.proposedTitle') }}</h3>
      <p class="hint rel-hint">{{ t('relations.proposedSub') }}</p>
      <ul class="rel-list">
        <li v-for="r in proposed" :key="r.id" class="rel-item rel-prop">
          <div class="rel-main">
            <div class="rel-tags">
              <span class="badge" :class="`b-${tone(r)}`">{{ dirLabel(r) }}</span>
              <RouterLink :to="`/tickets/${r.other.key}`" class="tkey">{{ r.other.key }}</RouterLink>
              <span class="rel-title">{{ r.other.title }}</span>
              <StateBadge :state="r.other.state" />
            </div>
            <p v-if="r.reason" class="rel-reason">{{ tr(r.reason) }}</p>
            <p class="rel-src">{{ t(`relations.source_${r.source}`) }} · {{ t('relations.confidence', { pct: Math.round(r.confidence * 100) }) }}</p>
          </div>
          <div class="rel-act">
            <button type="button" class="btn btn-p btn-s" :disabled="decide.isPending.value" @click="decide.mutate({ r, accept: true })">{{ t('relations.accept') }}</button>
            <button type="button" class="btn btn-s" :disabled="decide.isPending.value" @click="decide.mutate({ r, accept: false })">{{ t('relations.dismiss') }}</button>
          </div>
        </li>
      </ul>
    </template>

    <h3 class="rel-h3">{{ t('relations.activeTitle') }}</h3>
    <p v-if="!active.length" class="hint">{{ t('relations.empty') }}</p>
    <ul v-else class="rel-list">
      <li v-for="r in active" :key="r.id" class="rel-item">
        <div class="rel-main">
          <div class="rel-tags">
            <span class="badge" :class="`b-${tone(r)}`">{{ dirLabel(r) }}</span>
            <RouterLink :to="`/tickets/${r.other.key}`" class="tkey">{{ r.other.key }}</RouterLink>
            <span class="rel-title">{{ r.other.title }}</span>
            <StateBadge :state="r.other.state" />
            <span v-if="r.other.landed" class="badge b-ok">{{ t('relations.landed') }}</span>
          </div>
          <p v-if="basisText(r)" class="rel-reason">{{ basisText(r) }}</p>
          <p v-if="r.reason" class="rel-reason">{{ tr(r.reason) }}</p>
          <p class="rel-src">
            {{ t(`relations.source_${r.source}`) }}<template v-if="r.confirmedAt"> · {{ t('relations.confirmed') }}</template>
          </p>
        </div>
        <div class="rel-act">
          <button type="button" class="btn btn-s" :disabled="decide.isPending.value" @click="runAnyway(r)">{{ t('relations.remove') }}</button>
        </div>
      </li>
    </ul>

    <details v-if="dismissed.length" class="rel-dismissed">
      <summary>{{ t('relations.dismissedCount', { count: dismissed.length }) }}</summary>
      <ul>
        <li v-for="r in dismissed" :key="r.id">
          {{ dirLabel(r) }} <RouterLink :to="`/tickets/${r.other.key}`">{{ r.other.key }}</RouterLink>
          <template v-if="r.reason">: {{ tr(r.reason) }}</template>
        </li>
      </ul>
    </details>

    <h3 class="rel-h3">{{ t('relations.addTitle') }}</h3>
    <form class="rel-add" @submit.prevent="add.mutate()">
      <InputSelect v-model="newType" :options="typeOptions" :label="t('relations.addType')" />
      <InputSelect v-model="newOther" :options="otherOptions" :label="t('relations.addOther')" :placeholder="t('relations.addOtherPh')" />
      <button class="btn btn-p" type="submit" :disabled="!newOther || add.isPending.value">{{ t('relations.add') }}</button>
    </form>
    <p class="hint rel-hint">{{ t('relations.addHint') }}</p>

    <template v-if="footprint && (footprint.files.length || footprint.provides?.length || footprint.consumes?.length || footprint.migrations)">
      <h3 class="rel-h3">{{ t('relations.footprintTitle') }}</h3>
      <p class="hint rel-hint">{{ t('relations.footprintSub') }}</p>
      <dl class="kv rel-fp">
        <template v-if="footprint.files.length">
          <dt>{{ t('relations.footprintFiles') }}</dt>
          <dd><code v-for="f in footprint.files" :key="f" class="rel-file">{{ f }}</code></dd>
        </template>
        <template v-if="footprint.provides?.length">
          <dt>{{ t('relations.footprintProvides') }}</dt>
          <dd>{{ footprint.provides.map((x) => tr(x)).join('; ') }}</dd>
        </template>
        <template v-if="footprint.consumes?.length">
          <dt>{{ t('relations.footprintConsumes') }}</dt>
          <dd>{{ footprint.consumes.map((x) => tr(x)).join('; ') }}</dd>
        </template>
        <template v-if="footprint.migrations">
          <dt />
          <dd>{{ t('relations.footprintMigrations') }}</dd>
        </template>
      </dl>
    </template>
  </section>
</template>

<style scoped>
.rel-wait { margin: 4px 0 6px; }
.rel-h3 { margin: 18px 0 8px; }
.rel-hint { margin: -2px 0 10px; font-size: 13.5px; }
.rel-list { list-style: none; margin: 0; padding: 0; display: grid; gap: 10px; }
.rel-item { display: flex; gap: 12px; align-items: flex-start; border: 1px solid var(--line); border-radius: 12px; padding: 12px 14px; }
.rel-prop { border-style: dashed; }
.rel-main { flex: 1; min-width: 0; }
.rel-tags { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.rel-title { min-width: 0; overflow-wrap: anywhere; font-weight: 600; }
.rel-reason { margin: 6px 0 0; font-size: 14px; }
.rel-src { margin: 6px 0 0; font-size: 12.5px; color: var(--ink-3); font-weight: 600; }
.rel-act { display: flex; gap: 8px; flex-wrap: wrap; justify-content: flex-end; }
.rel-dismissed { margin-top: 14px; font-size: 13.5px; color: var(--ink-3); }
.rel-dismissed ul { margin: 6px 0 0; }
.rel-add { display: grid; grid-template-columns: minmax(140px, 1fr) minmax(180px, 2fr) auto; gap: 10px; align-items: end; }
.rel-fp dd { display: flex; flex-wrap: wrap; gap: 6px; }
.rel-file { font-size: 12.5px; padding: 2px 6px; border-radius: 6px; background: var(--hover); overflow-wrap: anywhere; }
@media (max-width: 640px) {
  .rel-item { flex-direction: column; }
  .rel-add { grid-template-columns: 1fr; }
}
</style>
