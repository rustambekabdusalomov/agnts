import type { components } from '../../api/schema.gen'

// Shared by the Analytics page's tabs.
export type Analytics = components['schemas']['Analytics']
export type AnalyticsDelivery = components['schemas']['AnalyticsDelivery']
export type AnalyticsCI = components['schemas']['AnalyticsCI']
export type AnalyticsLearning = components['schemas']['AnalyticsLearning']
export type Spread = components['schemas']['Spread']
export type Days = 7 | 30 | 90

export const TABS = ['overview', 'delivery', 'quality', 'learning', 'cost', 'repos', 'assistant'] as const
export type Tab = (typeof TABS)[number]

export const pctOf = (n: number, d: number) => (d ? Math.round((n / d) * 100) : 0)

/** Minutes as "12 min" or "3 h 5 min"; long spans as days and hours. */
export function minutesText(t: (k: string, v?: Record<string, unknown>) => string, m: number): string {
  const v = Math.max(0, Math.round(m))
  if (v < 60) return t('analytics.minutes', { n: v })
  if (v < 48 * 60) return t('analytics.hoursMinutes', { h: Math.floor(v / 60), m: v % 60 })
  return t('analytics.daysHours', { d: Math.floor(v / 1440), h: Math.round((v % 1440) / 60) })
}

/** Day labels for a chart's x axis: weekdays for a week, dates otherwise. */
export function dayLabels(dates: string[], days: number, locale: string): string[] {
  return dates.map((d) => {
    const dt = new Date(`${d}T00:00:00`)
    return days <= 7
      ? dt.toLocaleDateString(locale, { weekday: 'short' })
      : dt.toLocaleDateString(locale, { day: 'numeric', month: 'short' })
  })
}

/** One CSV field, quoted when it holds a comma, quote or new line. */
export function csvField(v: string | number | null | undefined): string {
  const s = v == null ? '' : String(v)
  return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s
}

export function toCsv(rows: (string | number | null | undefined)[][]): string {
  return rows.map((r) => r.map(csvField).join(',')).join('\n') + '\n'
}

export function downloadCsv(rows: (string | number | null | undefined)[][], name: string) {
  const blob = new Blob([toCsv(rows)], { type: 'text/csv;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = name
  document.body.appendChild(link)
  link.click()
  link.remove()
  URL.revokeObjectURL(url)
}
