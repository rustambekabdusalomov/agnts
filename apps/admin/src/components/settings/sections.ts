/** The Settings sections, each its own page at /settings/<key>, listed
 * under Settings in the sidebar. label is an i18n key; icon a name from icons.ts. */
export const SETTINGS_SECTIONS = [
  { key: 'appearance', label: 'settings.appearance', icon: 'palette' },
  { key: 'integrations', label: 'settings.integrations', icon: 'plug' },
  { key: 'claude', label: 'settings.claude', icon: 'assistant' },
  { key: 'commits', label: 'settings.commits', icon: 'commit' },
  { key: 'runs', label: 'settings.runs', icon: 'running' },
  { key: 'guardrails', label: 'harnessSettings.title', icon: 'shield' },
  { key: 'preview', label: 'preview.settingsTitle', icon: 'eye' },
  { key: 'ci', label: 'ci.settingsTitle', icon: 'ci' },
  { key: 'network', label: 'network.title', icon: 'network' },
  { key: 'notify', label: 'settings.notify', icon: 'bell' },
  { key: 'mcp', label: 'mcp.title', icon: 'tool' },
] as const

export type SettingsSection = (typeof SETTINGS_SECTIONS)[number]['key']

/** The section a /settings/:section? route shows; the first when it names none. */
export function settingsSection(param: unknown): SettingsSection {
  return SETTINGS_SECTIONS.find((s) => s.key === param)?.key ?? 'appearance'
}
