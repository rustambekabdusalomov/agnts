/** The Settings sections, each its own page at /settings/<key>, listed
 * under Settings in the sidebar. label is an i18n key; icon a name from icons.ts. */
export const SETTINGS_SECTIONS = [
  { key: 'appearance', label: 'settings.appearance', icon: 'palette' },
  { key: 'integrations', label: 'settings.integrations', icon: 'plug' },
  { key: 'muse', label: 'settings.claude', museLabel: 'settings.claudeMuse', icon: 'assistant', museIcon: 'meta' },
  { key: 'commits', label: 'settings.commits', icon: 'commit' },
  { key: 'runs', label: 'settings.runs', icon: 'running' },
  { key: 'guardrails', label: 'harnessSettings.title', icon: 'shield' },
  { key: 'preview', label: 'preview.settingsTitle', icon: 'eye' },
  { key: 'ci', label: 'ci.settingsTitle', icon: 'ci' },
  { key: 'network', label: 'network.title', icon: 'network' },
  { key: 'notify', label: 'settings.notify', icon: 'bell' },
  // Claude chat's connector: only where Claude is offered.
  { key: 'mcp', label: 'mcp.title', icon: 'tool', claudeOnly: true },
] as const

export type SettingsSection = (typeof SETTINGS_SECTIONS)[number]['key']

/** The sections to list: without Claude-only ones where Claude is not offered. */
export function visibleSections(claudeOff: boolean) {
  return SETTINGS_SECTIONS.filter((s) => !(claudeOff && 'claudeOnly' in s && s.claudeOnly))
}

/** A section's label key; the coding model's reads Muse where Claude Code is not offered. */
export function sectionLabel(s: (typeof SETTINGS_SECTIONS)[number], claudeOff: boolean): string {
  return claudeOff && 'museLabel' in s ? s.museLabel : s.label
}

/** A section's icon; the coding model's is Meta's where Muse is the tool. */
export function sectionIcon(s: (typeof SETTINGS_SECTIONS)[number], claudeOff: boolean): string {
  return claudeOff && 'museIcon' in s ? s.museIcon : s.icon
}

/** The section a /settings/:section? route shows; the first when it names
 * none. /settings/claude, the coding model's old address, opens muse. */
export function settingsSection(param: unknown): SettingsSection {
  const key = param === 'claude' ? 'muse' : param
  return SETTINGS_SECTIONS.find((s) => s.key === key)?.key ?? 'appearance'
}
