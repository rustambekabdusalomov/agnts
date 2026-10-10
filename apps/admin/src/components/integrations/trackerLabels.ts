// The kinds a tracker label can name, in the order the server picks one
// when an issue has several (domain.Kinds).
export const KINDS = ['code', 'test', 'plan', 'analysis', 'bug'] as const

// trackerLabels are the labels that hand a ticket to agnts.
export const trackerLabels = (base: string) => [base, ...KINDS.map((k) => `${base}-${k}`)]
