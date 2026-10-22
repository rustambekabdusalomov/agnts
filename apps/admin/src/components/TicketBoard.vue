<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { STATE_TONE, TERMINAL, ticketNo, type Ticket, type TicketState } from '../api/types'
import { ago, fmtTokens, ioTokens } from '../composables/format'
import StateBadge from './StateBadge.vue'
import WaitBadge from './WaitBadge.vue'
import KindBadge from './ticket/KindBadge.vue'
import RepoChip from './repos/RepoChip.vue'

// The "Board" view of tickets and tasks: one column per group of states,
// cards in the order the list gives them (most recently updated first).
export type BoardColumn = { id: string; label: string; states: TicketState[] }
const props = defineProps<{ items: Ticket[]; columns: BoardColumn[]; showSource?: boolean }>()
const emit = defineEmits<{ open: [key: string] }>()
const { t, locale } = useI18n()

const cols = computed(() => props.columns.map((c) => ({ ...c, cards: props.items.filter((x) => c.states.includes(x.state)) })))
// The column's colour follows its first state (queue grey, running blue, needs amber, finished green).
const tone = (c: BoardColumn) => STATE_TONE[c.states[0]]
</script>

<template>
  <div class="board" role="list">
    <section v-for="c in cols" :key="c.id" class="bcol" role="listitem" :aria-label="c.label">
      <header class="bcol-h" :class="`bt-${tone(c)}`">
        <span>{{ c.label }}</span>
        <span class="bcol-n">{{ c.cards.length }}</span>
      </header>
      <div class="bcol-b">
        <article
          v-for="tk in c.cards"
          :key="tk.key"
          class="bcard"
          role="link"
          tabindex="0"
          @click="emit('open', tk.key)"
          @keydown.enter="emit('open', tk.key)"
        >
          <div class="bcard-top">
            <span class="tkey">{{ ticketNo(tk) }}</span>
            <span v-if="tk.revision > 0 && !TERMINAL.includes(tk.state)" class="hint">{{ t('tickets.rev', { n: tk.revision }) }}</span>
          </div>
          <div class="bcard-title">{{ tk.title }}</div>
          <div v-if="c.states.length > 1 || tk.waitReason"><StateBadge v-if="c.states.length > 1" :state="tk.state" :kind="tk.kind" /> <WaitBadge :ticket="tk" /></div>
          <div class="bcard-meta">
            <template v-if="showSource">
              <span v-if="tk.source === 'local'" class="src local">{{ t('tickets.sourceTask') }}</span>
              <span v-else class="src">{{ tk.source === 'plane' ? t('tickets.sourcePlane') : tk.source === 'git' ? t('tickets.sourceGit') : tk.source === 'ci' ? t('tickets.sourceCi') : t('tickets.sourceJira') }}</span>
            </template>
            <KindBadge v-if="tk.kind !== 'code'" :ticket="tk" />
            <span v-if="tk.openSuggestions" class="badge b-info">{{ t('followUps.openBadge', { count: tk.openSuggestions }) }}</span>
            <span v-if="tk.blockedBy?.length" class="badge b-warn" :title="tk.blockedBy.map((b) => b.key).join(', ')">{{ t('relations.waitingBadge') }}</span>
            <RepoChip :ticket="tk" />
            <span v-if="tk.spend">{{ t('spend.tokens', { n: fmtTokens(ioTokens(tk.spend), locale) }) }}</span>
            <span>{{ ago(tk.updatedAt, locale) }}</span>
          </div>
        </article>
        <p v-if="!c.cards.length" class="bcol-empty">{{ t('tickets.boardEmpty') }}</p>
      </div>
    </section>
  </div>
</template>
