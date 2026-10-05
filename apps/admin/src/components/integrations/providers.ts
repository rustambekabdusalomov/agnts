// Providers shown in the UI, with their tile colour and icon (from the demo).
export type Provider = 'jira' | 'github' | 'gitlab' | 'claude' | 'telegram'

export const PROVIDERS: Provider[] = ['jira', 'github', 'gitlab', 'claude', 'telegram']

export const PROVIDER_TINT: Record<Provider, string> = {
  jira: '#1D4ED8',
  github: '#24292F',
  gitlab: '#C2410C',
  claude: '#C2410C',
  telegram: '#229ED9',
}

export const PROVIDER_ICON: Record<Provider, string> = {
  jira: '<rect x="4" y="3" width="16" height="18" rx="2.5"/><path d="M8 8h8M8 12h8M8 16h5"/>',
  github: '<circle cx="6" cy="5" r="2.2"/><circle cx="6" cy="19" r="2.2"/><circle cx="18" cy="7" r="2.2"/><path d="M6 7.2v9.6M18 9.2c0 4-6 3.5-11.2 8"/>',
  gitlab: '<circle cx="6" cy="5" r="2.2"/><circle cx="6" cy="19" r="2.2"/><circle cx="18" cy="7" r="2.2"/><path d="M6 7.2v9.6M18 9.2c0 4-6 3.5-11.2 8"/>',
  claude: '<path d="M12 3v18M3 12h18M5.6 5.6l12.8 12.8M18.4 5.6L5.6 18.4"/>',
  telegram: '<path d="M21 4L3 11l6 2.5L19 7l-8 8 .5 5 3-3.5 4.5 3.5z"/>',
}

export function isProvider(s: string): s is Provider {
  return (PROVIDERS as string[]).includes(s)
}
