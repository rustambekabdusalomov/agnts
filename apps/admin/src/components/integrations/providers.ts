// Providers shown in the UI, with their tile colour and icon (from the demo).
export type Provider = 'jira' | 'plane' | 'github' | 'gitlab' | 'claude' | 'telegram' | 'openai'

export const PROVIDERS: Provider[] = ['jira', 'plane', 'github', 'gitlab', 'claude', 'telegram', 'openai']

/** Providers that send tickets. */
export type Tracker = 'jira' | 'plane'
export const TRACKERS: Tracker[] = ['jira', 'plane']

/** Integrations listed on the Integrations page and in Settings: Claude
 * has its own card (the workspace's Claude tab), and the OpenAI key only
 * serves Codex, so it is shown only where the server offers Codex. */
export function listedProviders(codex: boolean): Provider[] {
  return PROVIDERS.filter((p) => p !== 'claude' && (codex || p !== 'openai'))
}

/** Tiles also stand for Muse Code, which is connected in the workspace, not here. */
export type Tile = Provider | 'muse'

export const PROVIDER_TINT: Record<Tile, string> = {
  jira: '#1D4ED8',
  plane: '#3F76FF',
  github: '#24292F',
  gitlab: '#C2410C',
  claude: '#C2410C',
  telegram: '#229ED9',
  openai: '#10A37F',
  muse: '#0866FF',
}

export const PROVIDER_ICON: Record<Tile, string> = {
  jira: '<rect x="4" y="3" width="16" height="18" rx="2.5"/><path d="M8 8h8M8 12h8M8 16h5"/>',
  plane: '<path d="M4 4h8v8H4zM12 12h8v8h-8zM12 4h8v8"/>',
  github: '<circle cx="6" cy="5" r="2.2"/><circle cx="6" cy="19" r="2.2"/><circle cx="18" cy="7" r="2.2"/><path d="M6 7.2v9.6M18 9.2c0 4-6 3.5-11.2 8"/>',
  gitlab: '<circle cx="6" cy="5" r="2.2"/><circle cx="6" cy="19" r="2.2"/><circle cx="18" cy="7" r="2.2"/><path d="M6 7.2v9.6M18 9.2c0 4-6 3.5-11.2 8"/>',
  claude: '<path d="M12 3v18M3 12h18M5.6 5.6l12.8 12.8M18.4 5.6L5.6 18.4"/>',
  telegram: '<path d="M21 4L3 11l6 2.5L19 7l-8 8 .5 5 3-3.5 4.5 3.5z"/>',
  openai: '<path d="M12 3l7.8 4.5v9L12 21l-7.8-4.5v-9z"/><circle cx="12" cy="12" r="3"/>',
  muse: '<path d="M3 17c1.5-6 3.5-9 5.5-9s3 3 3.5 4.5S14 17 16 17s3.5-4 5-10"/>',
}

export function isProvider(s: string): s is Provider {
  return (PROVIDERS as string[]).includes(s)
}
