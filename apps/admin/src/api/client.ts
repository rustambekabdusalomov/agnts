import createClient, { type Middleware } from 'openapi-fetch'
import type { components, paths } from './schema.gen'

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
    if (response.status === 401 && schemaPath !== '/auth/login') onUnauthorized()
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
