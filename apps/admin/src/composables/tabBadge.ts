import { onScopeDispose, watchEffect, type Ref } from 'vue'

// The browser tab shows agnts's mark with a live badge: a red count when
// tickets need you, else a blue dot while agnts codes or learns. The count
// also goes in the title. Browsers don't animate SVG favicons, so the
// dot is steady.

// The mark as in public/favicon.svg, on a 32-unit box.
const MARK = `<rect width="32" height="32" rx="7.04" fill="#0E0E10"/><g transform="translate(5.76 6.4) scale(0.2048)"><path d="M50 56 L50 18 M50 56 L18 76 M50 56 L82 76" stroke="#F4F3EF" stroke-width="8" stroke-linecap="round" fill="none"/><circle cx="50" cy="18" r="13" fill="#F4F3EF"/><circle cx="18" cy="76" r="13" fill="#F4F3EF"/><circle cx="82" cy="76" r="13" fill="#F4F3EF"/><circle cx="50" cy="56" r="16" fill="#FF5A1F"/></g>`

/** The favicon SVG for a state; the plain mark when idle. */
export function badgeSvg(needs: number, busy: boolean): string {
  const mark = (x: number, y: number, size: number) => `<g transform="translate(${x} ${y}) scale(${size / 32})">${MARK}</g>`
  const text = needs > 9 ? '9+' : String(needs)
  const d = needs > 0 ? 16 : busy ? 11 : 0 // badge diameter
  if (!d) return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">${MARK}</svg>`

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
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 30">${mark(x, y, size)}${badge}</svg>`
}

/** The tab title: "(2) agnts" while tickets need you. */
export function badgeTitle(base: string, needs: number): string {
  return needs > 0 ? `(${needs > 99 ? '99+' : needs}) ${base}` : base
}

/** Keeps the favicon and title in step with the counts while mounted. */
export function useTabBadge(needs: Ref<number>, busy: Ref<boolean>, base = 'agnts') {
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
