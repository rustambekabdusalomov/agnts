import createClient, { type Middleware } from 'openapi-fetch'
import type { components, paths } from './schema.gen'
import type { Attachment } from './types'

export type User = components['schemas']['User']
export type ApiError = components['schemas']['Error']

/** Thrown for any non-2xx response, carrying the server's error body. */
export class HttpError extends Error {
  readonly status: number
  readonly code: string
  readonly retryAfter?: number

  constructor(status: number, body: Partial<ApiError> | undefined, retryAfter?: number) {
    super(body?.message ?? `HTTP ${status}`)
    this.status = status
    this.code = body?.code ?? 'unknown'
    this.retryAfter = retryAfter
  }
}

let onUnauthorized: () => void = () => {}

/** Registers what to do when any request comes back 401 (sign the user out). */
export function setUnauthorizedHandler(fn: () => void) {
  onUnauthorized = fn
}

const authRedirect: Middleware = {
  onResponse({ response, schemaPath }) {
    // Not a session ending: /auth/me only asks whether anyone is signed in
    // (the router decides what a signed-out visitor may open, public pages
    // included), and a public link's 401 asks its reader who they are.
    if (response.status === 401 && schemaPath !== '/auth/login' && schemaPath !== '/auth/me' && !schemaPath.startsWith('/public/')) onUnauthorized()
  },
}

// The workspace the panel acts in. Workspace operations go to
// /api/w/<slug>/...; the person's own (account, workspaces, the Admin's
// console) stay at /api/....
let workspace = ''

/** Sets the workspace API calls act in (the route's :ws). */
export function setWorkspace(slug: string) {
  workspace = slug
}

/** The workspace API calls act in now. */
export function currentWorkspace(): string {
  return workspace
}

/** Operations that are the person's, not a workspace's (see x-scope in the spec). */
const USER_PATHS = ['/auth/', '/meta', '/models', '/account/', '/workspaces', '/invites/', '/platform/', '/devices', '/docs/', '/oauth/', '/public/']

export function isUserPath(path: string): boolean {
  return USER_PATHS.some((p) => path === p.replace(/\/$/, '') || path.startsWith(p))
}

/** The URL of an API path, in the current workspace when it is a workspace's. */
export function apiPath(path: string): string {
  return !isUserPath(path) && workspace ? `/api/w/${encodeURIComponent(workspace)}${path}` : `/api${path}`
}

const workspaceRoute: Middleware = {
  async onRequest({ request, schemaPath }) {
    if (!workspace || isUserPath(schemaPath)) return undefined
    const url = new URL(request.url)
    if (!url.pathname.startsWith('/api/') || url.pathname.startsWith('/api/w/')) return undefined
    url.pathname = `/api/w/${encodeURIComponent(workspace)}${url.pathname.slice(4)}`
    // Not new Request(url, request): that carries the body over as a stream,
    // and Chrome sends a streamed body only over HTTP/2. Over HTTP/1.1 (the
    // Vite dev server) every PUT and POST failed with ERR_ALPN_NEGOTIATION_FAILED.
    const body = request.method === 'GET' || request.method === 'HEAD' ? undefined : await request.blob()
    return new Request(url, {
      method: request.method,
      headers: request.headers,
      body,
      credentials: request.credentials,
      cache: request.cache,
      redirect: request.redirect,
      referrer: request.referrer,
      integrity: request.integrity,
      keepalive: request.keepalive,
      signal: request.signal,
    })
  },
}

// Same-origin: the session travels in the HttpOnly cookie. Array query
// parameters are comma-separated (?state=a,b), as the spec declares them
// (style: form, explode: false); openapi-fetch repeats them by default.
export const api = createClient<paths>({
  baseUrl: '/api',
  credentials: 'same-origin',
  querySerializer: { array: { style: 'form', explode: false } },
})
api.use(authRedirect)
api.use(workspaceRoute)

/** Unwraps an openapi-fetch result, throwing HttpError on failure. */
export async function unwrap<T>(
  p: Promise<{ data?: T; error?: unknown; response: Response }>,
): Promise<T> {
  const { data, error, response } = await p
  if (!response.ok) {
    const ra = Number(response.headers.get('Retry-After'))
    throw new HttpError(response.status, error as Partial<ApiError>, Number.isFinite(ra) && ra > 0 ? ra : undefined)
  }
  return data as T
}

/** Largest file the server takes, and how many one task, answer or retry carries. */
export const MAX_ATTACHMENT_BYTES = 10 << 20
export const MAX_ATTACHMENTS = 10

/**
 * Uploads one file for a later createTask / answers / retry request. A
 * multipart body is simpler with fetch than through openapi-fetch.
 */
export async function uploadAttachment(file: File): Promise<Attachment> {
  const body = new FormData()
  body.append('file', file, file.name)
  const response = await fetch(apiPath('/attachments'), { method: 'POST', body, credentials: 'same-origin' })
  const data = await response.json().catch(() => undefined)
  if (!response.ok) {
    if (response.status === 401) onUnauthorized()
    throw new HttpError(response.status, data as Partial<ApiError> | undefined)
  }
  return data as Attachment
}

/**
 * Uploads a recording of a meeting held elsewhere. XMLHttpRequest, not
 * fetch: fetch can't tell how much of a big upload has gone. The fields
 * go before the file, which the server streams to disk as it comes.
 */
export function uploadMeetingRecording(
  meetingId: number,
  file: File,
  v: { startedAt?: string; people: number[] },
  onProgress: (fraction: number) => void,
): Promise<components['schemas']['MeetingSessionBrief']> {
  const body = new FormData()
  if (v.startedAt) body.append('startedAt', v.startedAt)
  if (v.people.length) body.append('people', v.people.join(','))
  body.append('file', file, file.name)
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest()
    xhr.open('POST', apiPath(`/meetings/${meetingId}/uploads`))
    xhr.withCredentials = true
    xhr.responseType = 'json'
    xhr.upload.onprogress = (e) => {
      if (e.lengthComputable) onProgress(e.loaded / e.total)
    }
    xhr.onload = () => {
      if (xhr.status >= 200 && xhr.status < 300) return resolve(xhr.response)
      if (xhr.status === 401) onUnauthorized()
      reject(new HttpError(xhr.status, (xhr.response ?? undefined) as Partial<ApiError> | undefined))
    }
    xhr.onerror = () => reject(new HttpError(0, undefined))
    xhr.send(body)
  })
}

/** Muse's words for a spoken question (a WAV clip), to ask as typed ones are. */
/** Sends a team chat voice message: the recording to keep and play, and the same audio as WAV for Muse to hear. */
export async function sendChatVoice(
  channelId: number,
  v: { clientMsgId: string; durationMs: number; replyTo?: number; recording: Blob; wav: Blob },
): Promise<components['schemas']['ChatMessage']> {
  const body = new FormData()
  body.append('clientMsgId', v.clientMsgId)
  body.append('durationMs', String(Math.round(v.durationMs)))
  if (v.replyTo) body.append('replyTo', String(v.replyTo))
  const type = (v.recording.type || 'audio/webm').split(';')[0]
  const ext = type.includes('mp4') ? 'm4a' : type.includes('ogg') ? 'ogg' : type.includes('mpeg') ? 'mp3' : 'webm'
  body.append('audio', new Blob([v.recording], { type }), `voice.${ext}`)
  body.append('wav', v.wav, 'voice.wav')
  const response = await fetch(apiPath(`/chat/channels/${channelId}/voice`), { method: 'POST', body, credentials: 'same-origin' })
  const data = await response.json().catch(() => undefined)
  if (!response.ok) {
    if (response.status === 401) onUnauthorized()
    throw new HttpError(response.status, data as Partial<ApiError> | undefined)
  }
  return data as components['schemas']['ChatMessage']
}

/** Where a voice message's recording plays from. */
export function chatAudioPath(messageId: number): string {
  return apiPath(`/chat/messages/${messageId}/audio`)
}

export async function transcribeQuestion(wav: Blob): Promise<string> {
  const body = new FormData()
  body.append('file', wav, 'question.wav')
  const response = await fetch(apiPath('/assistant/transcribe'), { method: 'POST', body, credentials: 'same-origin' })
  const data = await response.json().catch(() => undefined)
  if (!response.ok) {
    if (response.status === 401) onUnauthorized()
    throw new HttpError(response.status, data as Partial<ApiError> | undefined)
  }
  return (data as components['schemas']['AssistantTranscript']).text
}
