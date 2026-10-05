import { onScopeDispose, watchEffect, type Ref } from 'vue'

// The browser tab shows hiro's mark with a live badge: a red count when
// tickets need you, else a blue dot while hiro codes or learns. The count
// also goes in the title. Browsers don't animate SVG favicons, so the
// dot is steady.

const MARK = `<style>.m{fill:#16181D}.i{stroke:#F4F3EF}@media (prefers-color-scheme: dark){.m{fill:#ECEBE6}.i{stroke:#16181D}}</style>`
const H = `<path class="i" transform="translate(1 0)" d="M10 9v12M10 15c1.2-2 2.6-3 4.5-3 2.2 0 3.5 1.4 3.5 3.8V21" stroke-width="2.4" fill="none" stroke-linecap="round"/>`

/** The favicon SVG for a state; the plain mark when idle. */
export function badgeSvg(needs: number, busy: boolean): string {
  const mark = (x: number, y: number, size: number) =>
    `<g transform="translate(${x} ${y}) scale(${size / 28}) translate(-1 -1)"><rect class="m" x="1" y="1" width="28" height="28" rx="7"/>${H}</g>`
  const text = needs > 9 ? '9+' : String(needs)
  const d = needs > 0 ? 16 : busy ? 11 : 0 // badge diameter
  if (!d) return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 30">${MARK}${mark(1, 1, 28)}</svg>`

  // A favicon cannot draw outside its box, so the mark shrinks to leave
  // room: the badge is centred on the mark's top-right corner, half of it
  // above the top edge and half past the right edge (top/right: -50%).
  const size = 30 - d / 2
  const x = (30 - (size + 0.5 * d)) / 2
  const y = d / 2
  const cx = x + size
  const cy = d / 2
  let badge = `<circle cx="${cx}" cy="${cy}" r="${d / 2}" fill="${needs > 0 ? '#E5484D' : '#3E63DD'}"/>`
  if (needs > 0) {
    badge += `<text x="${cx}" y="${cy}" dy=".36em" text-anchor="middle" font-family="system-ui,-apple-system,sans-serif" font-size="${text.length > 1 ? 9.5 : 12.5}" font-weight="800" fill="#fff">${text}</text>`
  }
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 30">${MARK}${mark(x, y, size)}${badge}</svg>`
}

/** The tab title: "(2) hiro" while tickets need you. */
export function badgeTitle(base: string, needs: number): string {
  return needs > 0 ? `(${needs > 99 ? '99+' : needs}) ${base}` : base
}

/** Keeps the favicon and title in step with the counts while mounted. */
export function useTabBadge(needs: Ref<number>, busy: Ref<boolean>, base = 'hiro') {
  const link = document.querySelector<HTMLLinkElement>('link[rel="icon"]')
  const original = link?.href
  watchEffect(() => {
    if (link) link.href = `data:image/svg+xml,${encodeURIComponent(badgeSvg(needs.value, busy.value))}`
    document.title = badgeTitle(base, needs.value)
  })
  onScopeDispose(() => {
    if (link && original) link.href = original
    document.title = base
  })
}
