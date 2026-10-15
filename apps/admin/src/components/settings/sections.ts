/** The Settings sections, each its own page at /settings/<key>, listed
 * under Settings in the sidebar. label is an i18n key. */
export const SETTINGS_SECTIONS = [
  { key: 'appearance', label: 'settings.appearance' },
  { key: 'integrations', label: 'settings.integrations' },
  { key: 'claude', label: 'settings.claude' },
  { key: 'commits', label: 'settings.commits' },
  { key: 'runs', label: 'settings.runs' },
  { key: 'guardrails', label: 'harnessSettings.title' },
  { key: 'preview', label: 'preview.settingsTitle' },
  { key: 'ci', label: 'ci.settingsTitle' },
  { key: 'network', label: 'network.title' },
  { key: 'notify', label: 'settings.notify' },
  { key: 'mcp', label: 'mcp.title' },
] as const

export type SettingsSection = (typeof SETTINGS_SECTIONS)[number]['key']

/** The section a /settings/:section? route shows; the first when it names none. */
export function settingsSection(param: unknown): SettingsSection {
  return SETTINGS_SECTIONS.find((s) => s.key === param)?.key ?? 'appearance'
}
