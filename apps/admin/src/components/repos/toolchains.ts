import type { Toolchain } from '../../api/types'

const TOOL = /^[a-z][a-z0-9-]{0,39}$/
const VERSION = /^[A-Za-z0-9][A-Za-z0-9.+_-]{0,63}$/

/** Reads "tool@version" (version defaults to latest), or null when invalid. */
export function parseToolchain(s: string): Toolchain | null {
  const [tool, version = 'latest'] = s.trim().toLowerCase().split('@', 2) as [string, string?]
  const v = version || 'latest'
  if (!TOOL.test(tool) || !VERSION.test(v)) return null
  return { tool, version: v, source: 'manual' }
}

/** tool@version, as mise takes it. */
export const spec = (t: Toolchain) => `${t.tool}@${t.version}`
