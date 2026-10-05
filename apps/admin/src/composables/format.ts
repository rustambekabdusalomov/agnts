// Formatting helpers shared by pages (ported from the demo).

export function fmtDur(ms: number | null | undefined): string {
  if (ms == null) return ''
  const sec = Math.round(ms / 1000)
  if (sec < 60) return `${sec}s`
  const m = Math.floor(sec / 60)
  const h = Math.floor(m / 60)
  if (h >= 24) return `${Math.floor(h / 24)}d ${h % 24}h`
  if (h) return `${h}h ${m % 60}m`
  return `${m}m ${sec % 60}s`
}

export function since(iso: string | undefined): number {
  return iso ? Math.max(0, Date.now() - new Date(iso).getTime()) : 0
}

export function fmtTime(iso: string, locale: string): string {
  const d = new Date(iso)
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const hms = d.toLocaleTimeString(locale, { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false })
  if (d >= today) return hms
  return d.toLocaleDateString(locale, { weekday: 'short' }) + ' ' + hms.slice(0, 5)
}

export function ago(iso: string | undefined, locale: string): string {
  if (!iso) return '—'
  const s = Math.round((Date.now() - new Date(iso).getTime()) / 1000)
  const rtf = new Intl.RelativeTimeFormat(locale, { numeric: 'auto' })
  if (s < 60) return rtf.format(-s, 'second')
  if (s < 3600) return rtf.format(-Math.round(s / 60), 'minute')
  if (s < 86400) return rtf.format(-Math.round(s / 3600), 'hour')
  return rtf.format(-Math.round(s / 86400), 'day')
}

/** "warn" from 80%, "bad" at 100%, as the demo colours usage bars. */
export function level(u: number | undefined | null): '' | 'warn' | 'bad' {
  if (u == null) return ''
  return u >= 1 ? 'bad' : u >= 0.8 ? 'warn' : ''
}

export function pct(u: number | undefined | null): number {
  return u == null ? 0 : Math.min(100, Math.round(u * 100))
}
