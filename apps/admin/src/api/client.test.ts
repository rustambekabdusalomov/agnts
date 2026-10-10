import { afterEach, describe, expect, it } from 'vitest'
import { api, setWorkspace } from './client'

// Records what the client sends, instead of the network.
function recorder() {
  const seen: Request[] = []
  const fetch = async (req: Request) => {
    seen.push(req)
    return new Response('{}', { status: 200, headers: { 'Content-Type': 'application/json' } })
  }
  return { seen, fetch }
}

describe('workspace routes', () => {
  afterEach(() => setWorkspace(''))

  it('sends a workspace call to its workspace with the whole body', async () => {
    // The body is rebuilt from bytes, not passed on as the original Request's
    // stream: Chrome sends a streamed body only over HTTP/2, so over HTTP/1.1
    // (the Vite dev server) every PUT and POST failed.
    const r = recorder()
    setWorkspace('acme')
    await api.PUT('/workspace/claude/connection', { baseUrl: 'http://localhost/api', fetch: r.fetch, body: { kind: 'subscription', token: 'sk-ant-oat01-x' } })
    const req = r.seen[0]!
    expect(new URL(req.url).pathname).toBe('/api/w/acme/workspace/claude/connection')
    expect(req.method).toBe('PUT')
    expect(req.headers.get('Content-Type')).toContain('application/json')
    expect(JSON.parse(await req.text())).toEqual({ kind: 'subscription', token: 'sk-ant-oat01-x' })
  })

  it('keeps a GET without a body', async () => {
    const r = recorder()
    setWorkspace('acme')
    await api.GET('/workspace/claude', { baseUrl: 'http://localhost/api', fetch: r.fetch })
    expect(new URL(r.seen[0]!.url).pathname).toBe('/api/w/acme/workspace/claude')
    expect(r.seen[0]!.body).toBeNull()
  })

  it("leaves the person's own calls where they are", async () => {
    const r = recorder()
    setWorkspace('acme')
    await api.PUT('/account/claude', { baseUrl: 'http://localhost/api', fetch: r.fetch, body: { kind: 'subscription', token: 'x' } })
    expect(new URL(r.seen[0]!.url).pathname).toBe('/api/account/claude')
  })
})
