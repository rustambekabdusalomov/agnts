/**
 * The hosted price list in dollars, from runtime config (NUXT_PUBLIC_*). The defaults match the
 * server's AGNTS_PRICE_* and related settings (server/internal/config), which bill in so'm: a
 * workspace a month with one slot and the included members, an extra slot, an extra member, and
 * credits at API cost times the markup.
 */
export function usePrices() {
  const c = useRuntimeConfig().public
  const num = (v: unknown, def: number) => Number(v) || def
  return {
    workspaceUsd: num(c.priceUsd, 25),
    slotUsd: num(c.priceSlotUsd, 15),
    memberUsd: num(c.priceMemberUsd, 5),
    includedMembers: num(c.includedMembers, 5),
    maxSlots: num(c.maxSlots, 5),
    creditMarkup: num(c.creditMarkup, 1.4),
  }
}
