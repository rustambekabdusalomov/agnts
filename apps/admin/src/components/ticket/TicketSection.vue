<script setup lang="ts">
import { computed } from 'vue'
import { useClosedSections } from '../../composables/useClosedSections'
import HiIcon from '../ui/HiIcon.vue'

// A titled part of the ticket page (Commits, Notes, Diff…): its title
// closes or opens it, remembered in this browser for every ticket, and
// while open the title stays under the page's top bar as the content
// scrolls past. A file's header inside (a diff) sticks under it. hint
// shows next to the title (a count), so a closed section still says what
// is in it.
const props = defineProps<{ id: string; title: string; hint?: string }>()
const sections = useClosedSections()
const open = computed(() => sections.isOpen(props.id))
</script>

<template>
  <section class="sec tsec" :class="{ closed: !open }">
    <h3 class="tsec-h">
      <button type="button" class="tsec-btn" :aria-expanded="open" @click="sections.toggle(id)">
        <span class="tsec-t">{{ title }}</span>
        <span v-if="hint" class="tsec-n">{{ hint }}</span>
        <HiIcon name="back" class="tsec-i" />
      </button>
    </h3>
    <div v-if="open" class="tsec-b">
      <slot />
    </div>
  </section>
</template>

<style scoped>
.tsec-h {
  position: sticky; top: var(--top-h, 0px); z-index: 3;
  margin: 0; background: var(--surface);
}
.tsec-btn {
  display: flex; align-items: center; gap: 8px; width: 100%; min-height: 40px; padding: 8px 0;
  border: 0; border-bottom: 1px solid transparent; background: none; color: inherit; font: inherit; text-align: left; cursor: pointer;
}
.tsec-btn:hover .tsec-t { text-decoration: underline; text-underline-offset: 3px; }
.tsec-t { flex: 1 1 auto; min-width: 0; }
.tsec-n { font-size: 13px; font-weight: 500; color: var(--ink-3); font-variant-numeric: tabular-nums; }
/* "back" points left: turned down while open, right while closed. */
.tsec-i { width: 16px; height: 16px; color: var(--ink-3); transform: rotate(-90deg); transition: transform 0.15s; }
.closed .tsec-i { transform: rotate(180deg); }
/* Headers stuck inside (a diff's files) go under this one. */
.tsec-b { --sticky-in: calc(var(--top-h, 0px) + 40px); }
</style>
