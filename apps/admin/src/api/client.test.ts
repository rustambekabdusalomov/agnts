import { describe, expect, it } from 'vitest'
import { api } from './client'

describe('api client', () => {
  it('sends array query parameters comma-separated, as the spec declares', async () => {
    let url = ''
    const fetch = async (r: Request) => {
      url = r.url
      return new Response('[]', { headers: { 'Content-Type': 'application/json' } })
    }
    await api.GET('/tickets', { baseUrl: 'http://agnts.test/api', fetch, params: { query: { state: ['analyzing', 'coding'] } } })
    expect(new URL(url).searchParams.getAll('state')).toEqual(['analyzing,coding'])
  })
})
