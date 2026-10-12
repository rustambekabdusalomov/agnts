import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import LineChart from './LineChart.vue'

describe('LineChart', () => {
  it('leaves a gap for days without a value and still shows a lone day', () => {
    const w = mount(LineChart, {
      props: {
        aria: 'chart',
        labels: ['1', '2', '3', '4', '5', '6'],
        series: [{ label: 's', values: [5, 6, null, 7, null, null], color: 'red', area: true }],
      },
    })
    // Days 1–2 are one line; day 4 stands alone.
    expect(w.findAll('polyline')).toHaveLength(2)
    expect(w.findAll('polygon')).toHaveLength(2)
    const dots = w.findAll('circle')
    expect(dots).toHaveLength(3)
    expect(dots.map((d) => d.find('title').text())).toEqual(['1: s 5', '2: s 6', '4: s 7'])
  })

  it('shows a lone dot even when a long period hides the dots', () => {
    const labels = Array.from({ length: 60 }, (_, i) => String(i))
    const values: (number | null)[] = labels.map(() => null)
    values[10] = 4
    const w = mount(LineChart, { props: { aria: 'chart', labels, series: [{ label: 's', values, color: 'red' }] } })
    expect(Number(w.find('circle').attributes('r'))).toBeGreaterThan(0)
  })
})
