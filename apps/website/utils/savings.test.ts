import { describe, expect, it } from 'vitest'
import { calcSavings, formatSavings, type SavingsInputs } from './savings'

// Verbatim copy of the prototype formula (docs/prototypes/website.html, calc()), with the DOM
// writes turned into a returned object. Price is hard-coded to 10 there.
function prototypeCalc(t: number, h: number, r: number, rate: number) {
  const money = function (n: number) { return '$' + Math.round(n).toLocaleString('en-US') }
  const weeks = 4.33, manual = t * h * weeks, rev = t * (r / 60) * weeks
  const saved = Math.max(0, manual - rev), value = saved * rate
  return {
    tickets: String(t),
    hours: String(h % 1 === 0 ? h : h.toFixed(1)),
    review: String(r),
    rate: String(rate),
    saved: Math.round(saved).toLocaleString('en-US'),
    days: (saved / 8).toFixed(1),
    value: money(value),
    year: money(value * 12),
    manual: String(Math.round(manual)),
    withAgnts: String(Math.round(rev * 10) / 10),
    bar: (manual > 0 ? Math.min(100, rev / manual * 100) : 0).toFixed(1) + '%',
    roi: Math.round(value / 10).toLocaleString('en-US'),
  }
}

const samples: Array<[number, number, number, number]> = [
  [5, 3, 20, 10], // the page defaults
  [1, 0.5, 5, 3], // all minimums
  [30, 12, 60, 60], // all maximums
  [12, 2.5, 35, 24],
  [7, 4.5, 15, 45],
  [30, 0.5, 60, 3], // review costs more than the ticket: saved clamps at 0
  [18, 8, 10, 17],
]

describe('calcSavings', () => {
  it.each(samples)('matches the prototype for %d tickets, %d h, %d min, $%d/h', (t, h, r, rate) => {
    const inputs: SavingsInputs = { tickets: t, hours: h, reviewMin: r, rate }
    const result = calcSavings(inputs, 10)
    expect(formatSavings(inputs, result)).toEqual(prototypeCalc(t, h, r, rate))
  })

  it('shows the page defaults', () => {
    const inputs = { tickets: 5, hours: 3, reviewMin: 20, rate: 10 }
    expect(formatSavings(inputs, calcSavings(inputs, 10))).toMatchObject({
      saved: '58', days: '7.2', value: '$577', year: '$6,928', manual: '65', withAgnts: '7.2', bar: '11.1%', roi: '58',
    })
  })

  it('divides the ROI by the configured price', () => {
    const inputs = { tickets: 5, hours: 3, reviewMin: 20, rate: 10 }
    const at10 = calcSavings(inputs, 10)
    const at20 = calcSavings(inputs, 20)
    expect(at20.roi).toBeCloseTo(at10.roi / 2)
    expect(formatSavings(inputs, at20).roi).toBe('29')
    expect(at20.saved).toBe(at10.saved)
  })

  it('never reports negative savings', () => {
    const r = calcSavings({ tickets: 10, hours: 0.5, reviewMin: 60, rate: 20 }, 10)
    expect(r.saved).toBe(0)
    expect(r.value).toBe(0)
    expect(r.roi).toBe(0)
  })
})
