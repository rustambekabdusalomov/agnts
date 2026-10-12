#!/usr/bin/env node
// agnts-act: run scripted steps against the app under preview, for the
// acceptance check.
//
//   agnts-act <steps.json>
//
// steps.json: {"viewport": "desktop"|"phone", "steps": [...]}, where each
// step is one of:
//   {"goto": "/path"}                         open a page (localhost only)
//   {"fill": "<selector>", "text": "..."}     type into a field
//   {"click": "<selector>"}                   click
//   {"press": "Enter"}                        press a key
//   {"waitFor": "<selector>"}                 wait until visible
//   {"expectText": "...", "in": "<selector>"} the text is on the page (or in the element)
//   {"expectNoText": "..."}                   the text is not on the page
//   {"expectUrl": "..."}                      the URL contains this
//   {"expectVisible": "<selector>"}           the element is visible
//   {"request": {"method": "GET", "url": "/api/x", "body": {...}, "headers": {...}},
//    "expectStatus": 200, "expectBody": "..."} call the app's API
//   {"shot": "<id>"}                          screenshot to /agnts/out/shots/<id>.png
//   {"waitMs": 500}
//
// Steps run in order and stop at the first failure. Cookies and local
// storage are shared with agnts-shot, so a login done once sticks. Prints
// JSON: each step's outcome, the shots taken, console errors and failed
// requests. Exits 1 when a step fails.
import { chromium } from 'playwright'
import { mkdirSync, existsSync, readFileSync } from 'node:fs'
import { dirname } from 'node:path'

const STATE = '/tmp/agnts-shot/state.json'
const SHOTS = '/agnts/out/shots'
const VIEWPORTS = {
  desktop: { viewport: { width: 1440, height: 900 }, deviceScaleFactor: 1 },
  phone: { viewport: { width: 390, height: 844 }, deviceScaleFactor: 2, isMobile: true, hasTouch: true },
}
const LOCAL = ['localhost', '127.0.0.1', '[::1]']

function fail(msg) {
  console.error(`agnts-act: ${msg}`)
  process.exit(2)
}

const file = process.argv[2]
if (!file || process.argv.length > 3) fail('usage: agnts-act <steps.json>')
let spec
try {
  spec = JSON.parse(readFileSync(file, 'utf8'))
} catch (e) {
  fail(`cannot read ${file}: ${e.message}`)
}
const viewport = spec.viewport || 'desktop'
if (!VIEWPORTS[viewport]) fail('viewport is desktop or phone')
if (!Array.isArray(spec.steps) || spec.steps.length === 0) fail('steps must be a non-empty list')
if (spec.steps.length > 60) fail('at most 60 steps')

// Relative URLs are on the app agnts-preview started (its port is in the
// preview config).
let port = process.env.AGNTS_PREVIEW_PORT
if (!port) {
  try {
    port = JSON.parse(readFileSync(process.env.AGNTS_PREVIEW_CONFIG || '/agnts/out/preview-config.json', 'utf8')).port
  } catch {}
}
const base = new URL(process.env.AGNTS_PREVIEW_URL || `http://localhost:${port || 3000}`)
function local(u) {
  const url = new URL(u, base)
  if (!['http:', 'https:'].includes(url.protocol) || !LOCAL.includes(url.hostname)) {
    throw new Error(`only localhost URLs are allowed, not ${url.href}`)
  }
  return url.href
}
const id = (s) => String(s).toLowerCase().replace(/[^a-z0-9-]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 80)

const proxy = process.env.HTTPS_PROXY || process.env.https_proxy
const browser = await chromium.launch({
  args: ['--no-sandbox', '--disable-dev-shm-usage', '--disable-gpu'],
  proxy: proxy ? { server: proxy, bypass: 'localhost,127.0.0.1,[::1]' } : undefined,
})
const out = { viewport, steps: [], shots: [], consoleErrors: [], failedRequests: [], ok: true }
try {
  mkdirSync(dirname(STATE), { recursive: true })
  const context = await browser.newContext({
    ...VIEWPORTS[viewport],
    reducedMotion: 'reduce',
    storageState: existsSync(STATE) ? STATE : undefined,
    ignoreHTTPSErrors: true,
  })
  const page = await context.newPage()
  page.on('console', (m) => m.type() === 'error' && out.consoleErrors.push(m.text().slice(0, 300)))
  page.on('pageerror', (e) => out.consoleErrors.push(String(e.message || e).slice(0, 300)))
  page.on('requestfailed', (r) => out.failedRequests.push(`${r.failure()?.errorText ?? 'failed'} ${r.url()}`.slice(0, 300)))
  page.on('response', (r) => r.status() >= 400 && out.failedRequests.push(`${r.status()} ${r.url()}`.slice(0, 300)))
  const settle = () => page.waitForLoadState('networkidle', { timeout: 5_000 }).catch(() => {})

  for (const [i, s] of spec.steps.entries()) {
    const started = Date.now()
    const res = { i, step: Object.keys(s)[0], ok: true }
    try {
      if (s.goto !== undefined) {
        const r = await page.goto(local(s.goto), { waitUntil: 'load', timeout: 60_000 })
        res.status = r?.status()
        await settle()
      } else if (s.fill !== undefined) {
        await page.locator(s.fill).first().fill(String(s.text ?? ''), { timeout: 15_000 })
      } else if (s.click !== undefined) {
        await page.locator(s.click).first().click({ timeout: 15_000 })
        await settle()
      } else if (s.press !== undefined) {
        await page.keyboard.press(String(s.press))
        await settle()
      } else if (s.waitFor !== undefined) {
        await page.locator(s.waitFor).first().waitFor({ state: 'visible', timeout: 15_000 })
      } else if (s.expectText !== undefined) {
        const scope = s.in ? page.locator(s.in).first() : page.locator('body')
        const text = await scope.innerText({ timeout: 15_000 })
        if (!text.includes(String(s.expectText))) throw new Error(`text not found: ${s.expectText}`)
      } else if (s.expectNoText !== undefined) {
        const text = await page.locator('body').innerText({ timeout: 15_000 })
        if (text.includes(String(s.expectNoText))) throw new Error(`text present: ${s.expectNoText}`)
      } else if (s.expectUrl !== undefined) {
        if (!page.url().includes(String(s.expectUrl))) throw new Error(`url is ${page.url()}`)
      } else if (s.expectVisible !== undefined) {
        if (!(await page.locator(s.expectVisible).first().isVisible())) throw new Error(`not visible: ${s.expectVisible}`)
      } else if (s.request !== undefined) {
        const q = s.request
        const r = await context.request.fetch(local(q.url), {
          method: (q.method || 'GET').toUpperCase(),
          data: q.body,
          headers: q.headers,
          timeout: 30_000,
          failOnStatusCode: false,
        })
        const body = await r.text()
        res.status = r.status()
        res.body = body.slice(0, 1000)
        if (s.expectStatus !== undefined && r.status() !== Number(s.expectStatus)) throw new Error(`status ${r.status()}, want ${s.expectStatus}`)
        if (s.expectBody !== undefined && !body.includes(String(s.expectBody))) throw new Error(`body lacks ${s.expectBody}`)
      } else if (s.shot !== undefined) {
        const path = `${SHOTS}/${id(s.shot)}.png`
        mkdirSync(SHOTS, { recursive: true })
        await page.screenshot({ path, animations: 'disabled', caret: 'hide' })
        out.shots.push({ id: id(s.shot), file: `shots/${id(s.shot)}.png`, url: page.url() })
      } else if (s.waitMs !== undefined) {
        await page.waitForTimeout(Math.min(Number(s.waitMs) || 0, 10_000))
      } else {
        throw new Error(`unknown step ${JSON.stringify(s)}`)
      }
    } catch (e) {
      res.ok = false
      res.error = String(e.message || e).split('\n')[0].slice(0, 300)
      out.ok = false
    }
    res.ms = Date.now() - started
    out.steps.push(res)
    if (!res.ok) {
      // Keep what the page looked like when it failed.
      const path = `${SHOTS}/act-failure-${i}.png`
      mkdirSync(SHOTS, { recursive: true })
      await page.screenshot({ path }).catch(() => {})
      out.shots.push({ id: `act-failure-${i}`, file: `shots/act-failure-${i}.png`, url: page.url() })
      break
    }
  }
  await context.storageState({ path: STATE })
} catch (e) {
  out.ok = false
  out.error = String(e.message || e).split('\n')[0]
} finally {
  await browser.close()
}
out.consoleErrors = out.consoleErrors.slice(0, 10)
out.failedRequests = out.failedRequests.slice(0, 10)
console.log(JSON.stringify(out, null, 2))
process.exit(out.ok ? 0 : 1)
