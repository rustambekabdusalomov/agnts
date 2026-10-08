// Savings calculator maths for the landing page (ported from docs/prototypes/website.html calc()).
// Pure functions: inputs and the monthly price go in, numbers and display strings come out.

export const WEEKS_PER_MONTH = 4.33
export const WORKDAY_HOURS = 8

export interface SavingsInputs {
  /** Tickets agnts handles per week. */
  tickets: number
  /** Hours the developer would spend per ticket. */
  hours: number
  /** Minutes to review one agnts pull request. */
  reviewMin: number
  /** Developer hourly rate, USD. */
  rate: number
}

export interface SavingsResult {
  /** Hours per month without agnts. */
  manual: number
  /** Hours per month spent reviewing with agnts. */
  review: number
  /** Hours saved per month. */
  saved: number
  /** Saved time in 8-hour workdays. */
  days: number
  /** USD value of the saved time per month. */
  value: number
  /** USD value per year. */
  year: number
  /** Width of the "with agnts" bar, percent of the "without" bar. */
  barPct: number
  /** Return on every dollar of subscription. */
  roi: number
}

/** The numbers behind the calculator. `priceUsd` is the monthly subscription price. */
export function calcSavings(i: SavingsInputs, priceUsd: number): SavingsResult {
  const manual = i.tickets * i.hours * WEEKS_PER_MONTH
  const review = i.tickets * (i.reviewMin / 60) * WEEKS_PER_MONTH
  const saved = Math.max(0, manual - review)
  const value = saved * i.rate
  return {
    manual,
    review,
    saved,
    days: saved / WORKDAY_HOURS,
    value,
    year: value * 12,
    barPct: manual > 0 ? Math.min(100, review / manual * 100) : 0,
    roi: value / priceUsd,
  }
}

export const formatMoney = (n: number) => '$' + Math.round(n).toLocaleString('en-US')

export interface SavingsDisplay {
  tickets: string
  hours: string
  review: string
  rate: string
  saved: string
  days: string
  value: string
  year: string
  manual: string
  withAgnts: string
  bar: string
  roi: string
}

/** Display strings for every output field, formatted exactly like the prototype. */
export function formatSavings(i: SavingsInputs, r: SavingsResult): SavingsDisplay {
  return {
    tickets: String(i.tickets),
    hours: String(i.hours % 1 === 0 ? i.hours : i.hours.toFixed(1)),
    review: String(i.reviewMin),
    rate: String(i.rate),
    saved: Math.round(r.saved).toLocaleString('en-US'),
    days: (r.saved / WORKDAY_HOURS).toFixed(1),
    value: formatMoney(r.value),
    year: formatMoney(r.year),
    manual: String(Math.round(r.manual)),
    withAgnts: String(Math.round(r.review * 10) / 10),
    bar: r.barPct.toFixed(1) + '%',
    roi: Math.round(r.roi).toLocaleString('en-US'),
  }
}
