<template>
  <section class="p-top1" id="top">
    <div class="p-hero">
      <div class="p-hero-text">
        <h1 class="p-h1 p-top3">
          <template v-for="(w, i) in titleWords" :key="i">
            <span v-if="w === ACCENT" class="p-top9"><span class="p-word" :style="wordDelay(i)">{{ t('hero.accent') }}</span><span class="p-under" aria-hidden="true"></span></span>
            <span v-else class="p-word" :style="wordDelay(i)">{{ w }}</span>
            {{ ' ' }}
          </template>
        </h1>
        <p class="p-in p-top11"><span>{{ t('hero.lead') }}</span></p>
        <div class="p-in p-top12">
          <a class="p-btn p-top13" href="#pricing"><span>{{ t('common.getStarted') }}</span>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6"></path></svg>
          </a>
          <a class="p-link p-top14" href="#how"><span>{{ t('hero.see') }}</span></a>
        </div>
      </div>
      <div class="p-sun p-in p-top15" aria-hidden="true">
        <div class="p-top16"></div>
        <div class="p-ring-mid p-top17">
          <span class="p-top18"></span>
          <span class="p-top19"></span>
        </div>
        <div class="p-top20"></div>
        <div class="p-orbit-in p-top21">
          <div v-for="(c, i) in cards.slice(0, 3)" :key="i" class="p-slot" :style="slotStyle(c)">
            <div class="p-tk"><div class="p-tk-sm">
              <div class="p-top23"><span class="p-mono p-tk-id p-top24">{{ c.id }}</span><span aria-hidden="true" class="p-tk-s" :class="c.state"></span></div>
              <div class="p-tk-t p-top25">{{ c.ticket[LANG_COL[locale] ?? 1] }}</div>
            </div></div>
          </div>
        </div>
        <div class="p-orbit-out p-top21">
          <div v-for="(c, i) in cards.slice(3)" :key="i" class="p-slot" :style="slotStyle(c)">
            <div class="p-tk"><div class="p-tk-in">
              <div class="p-top23"><span class="p-mono p-tk-id p-top24">{{ c.id }}</span><span aria-hidden="true" class="p-tk-s" :class="c.state"></span></div>
              <div class="p-tk-t p-top25">{{ c.ticket[LANG_COL[locale] ?? 1] }}</div>
            </div></div>
          </div>
        </div>
      </div>
    </div>

    <div class="p-in p-top33">
      <div class="p-top34">
        <div class="p-top35">
          <span class="p-mono p-top36">PAY-214</span>
          <span class="p-top37"><span>{{ t('hero.ticketTitle') }}</span></span>
        </div>
        <span class="p-top38"><span class="p-dot p-top39" aria-hidden="true"></span><span>{{ t('hero.ready') }}</span></span>
      </div>
      <div class="p-top40"><div class="p-top41"></div></div>
      <div class="p-mono p-log p-top42">
        <div class="p-top43"><span class="p-top44">14:02</span><span>{{ t('hero.log1') }}</span></div>
        <div class="p-top45"><span class="p-top44">14:11</span>edit internal/transfer/handler.go</div>
        <div class="p-top46"><span class="p-top44">14:24</span>go test ./...  <span class="p-top47"><span>{{ t('hero.log3') }}</span></span></div>
        <div class="p-top48"><span class="p-top44">14:25</span><span>{{ t('hero.log4') }}</span><span class="p-top49">_</span></div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { TICKETS, type Ticket } from '~/utils/tickets'

type TicketState = 'st-review' | 'st-coding' | 'st-done'
interface BoardCard {
  id: string
  ticket: Ticket
  state: TicketState
  angle: number
  radius: number
}

const { t, locale } = useI18n()

// Word-by-word title: the translated sentence carries an {accent} slot that gets the underline.
const ACCENT = '@@accent@@'
const titleWords = computed(() => t('hero.title', { accent: ACCENT }).split(' ').filter(Boolean))
// --intro is the splash screen's duration (SiteLoader), so the entrance starts once the splash hides.
const wordDelay = (i: number) => ({ animationDelay: `calc(var(--intro, 0s) + ${(0.15 + i * 0.1).toFixed(2)}s)` })

// Ring slots: the first three sit on the inner ring, the rest on the outer ring.
const SLOTS: ReadonlyArray<readonly [angle: number, radius: number]> = [
  [-90, 140], [30, 140], [150, 140],
  [-54, 270], [18, 270], [90, 270], [162, 270], [234, 270],
]
const LANG_COL: Record<string, number> = { en: 1, ru: 2, uz: 3 }
const STATES: TicketState[] = ['st-review', 'st-coding', 'st-done']

const findTicket = (en: string): Ticket => TICKETS.find(tk => tk[1] === en) ?? TICKETS[0]!

// Board rendered on the server and on first paint; shuffled after mount.
const DEFAULT_BOARD: ReadonlyArray<readonly [id: string, en: string, state: TicketState]> = [
  ['DB-19', 'Index on orders.created_at', 'st-review'],
  ['CI-07', 'Fix flaky test', 'st-coding'],
  ['DOC-12', 'Update README', 'st-done'],
  ['PAY-214', 'Idempotency key on transfers', 'st-review'],
  ['API-88', 'Paginate /orders endpoint', 'st-coding'],
  ['BUG-301', 'Timezone bug in reports', 'st-done'],
  ['AUTH-57', 'Refresh-token rotation', 'st-coding'],
  ['UI-142', 'Validate +998 phone numbers', 'st-done'],
]

const cards = ref<BoardCard[]>(DEFAULT_BOARD.map(([id, en, state], i) => ({
  id, ticket: findTicket(en), state, angle: SLOTS[i]![0], radius: SLOTS[i]![1],
})))

function shuffle() {
  const pool = TICKETS.slice()
  for (let i = pool.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[pool[i], pool[j]] = [pool[j]!, pool[i]!]
  }
  cards.value = SLOTS.map(([angle, radius], i) => {
    const tk = pool[i]!
    return {
      id: `${tk[0]}-${10 + Math.floor(Math.random() * 390)}`,
      ticket: tk,
      state: STATES[Math.floor(Math.random() * STATES.length)]!,
      angle,
      radius,
    }
  })
}

function slotStyle(c: BoardCard) {
  return { transform: `rotate(${c.angle}deg) translateX(${c.radius}px) rotate(${-c.angle}deg)` }
}

onMounted(shuffle)
</script>
