#!/usr/bin/env node
// agnts-shot: take one screenshot of the app under preview.
//
//   agnts-shot <url> --viewport desktop|phone --out <file.png>
//              [--full-page] [--wait <css selector>] [--wait-ms <ms>]
//              [--click <css selector>]... [--fill '<css selector>=<text>']...
//
// Clicks and fills run in the order given, after the page loads. Cookies and
// local storage are kept between calls, so a login done once sticks. Only
// localhost URLs are allowed. Prints JSON: the page title, size, console
// errors and failed requests.
import { chromium } from 'playwright'
import { mkdirSync, existsSync } from 'node:fs'
import { dirname } from 'node:path'

const STATE = '/tmp/agnts-shot/state.json'
const MAX_HEIGHT = 4000
const VIEWPORTS = {
  desktop: { viewport: { width: 1440, height: 900 }, deviceScaleFactor: 1 },
  phone: { viewport: { width: 390, height: 844 }, deviceScaleFactor: 2, isMobile: true, hasTouch: true },
}

function usage(msg) {
  if (msg) console.error(`agnts-shot: ${msg}`)
  console.error("usage: agnts-shot <url> --viewport desktop|phone --out <file.png> [--full-page] [--wait <selector>] [--wait-ms <ms>] [--click <selector>]... [--fill '<selector>=<text>']...")
  process.exit(2)
}

const args = process.argv.slice(2)
const opt = { viewport: 'desktop', actions: [], waitMs: 400 }
for (let i = 0; i < args.length; i++) {
  const a = args[i]
  const next = () => (i + 1 < args.length ? args[++i] : usage(`${a} needs a value`))
  if (a === '--viewport') opt.viewport = next()
  else if (a === '--out') opt.out = next()
  else if (a === '--full-page') opt.fullPage = true
  else if (a === '--wait') opt.wait = next()
  else if (a === '--wait-ms') opt.waitMs = Number(next())
  else if (a === '--click') opt.actions.push({ click: next() })
  else if (a === '--fill') {
    const v = next()
    const eq = v.indexOf('=')
    if (eq < 1) usage("--fill takes '<selector>=<text>'")
    opt.actions.push({ fill: v.slice(0, eq), text: v.slice(eq + 1) })
  } else if (a === '-h' || a === '--help') usage()
  else if (a.startsWith('--')) usage(`unknown option ${a}`)
  else if (!opt.url) opt.url = a
  else usage(`unexpected ${a}`)
}
if (!opt.url || !opt.out) usage('the url and --out are required')
if (!VIEWPORTS[opt.viewport]) usage('--viewport is desktop or phone')
if (!opt.out.endsWith('.png')) usage('--out must end in .png')
let url
try {
  url = new URL(opt.url)
} catch {
  usage(`${opt.url} is not a URL`)
}
if (!['http:', 'https:'].includes(url.protocol) || !['localhost', '127.0.0.1', '[::1]'].includes(url.hostname)) {
  usage('only http://localhost URLs can be captured')
}

const proxy = process.env.HTTPS_PROXY || process.env.https_proxy
const browser = await chromium.launch({
  args: ['--no-sandbox', '--disable-dev-shm-usage', '--disable-gpu'],
  // The app's own API calls go out through the egress proxy like everything else.
  proxy: proxy ? { server: proxy, bypass: 'localhost,127.0.0.1,[::1]' } : undefined,
})
const result = { out: opt.out, url: url.href, viewport: opt.viewport, consoleErrors: [], failedRequests: [] }
let code = 0
try {
  mkdirSync(dirname(STATE), { recursive: true })
  const context = await browser.newContext({
    ...VIEWPORTS[opt.viewport],
    reducedMotion: 'reduce',
    storageState: existsSync(STATE) ? STATE : undefined,
    ignoreHTTPSErrors: true,
  })
  const page = await context.newPage()
  page.on('console', (m) => m.type() === 'error' && result.consoleErrors.push(m.text().slice(0, 300)))
  page.on('pageerror', (e) => result.consoleErrors.push(String(e.message || e).slice(0, 300)))
  page.on('requestfailed', (r) => result.failedRequests.push(`${r.failure()?.errorText ?? 'failed'} ${r.url()}`.slice(0, 300)))
  page.on('response', (r) => r.status() >= 400 && result.failedRequests.push(`${r.status()} ${r.url()}`.slice(0, 300)))

  const resp = await page.goto(url.href, { waitUntil: 'load', timeout: 60_000 })
  result.status = resp?.status()
  await page.waitForLoadState('networkidle', { timeout: 10_000 }).catch(() => {})
  if (opt.wait) await page.locator(opt.wait).first().waitFor({ timeout: 15_000 })
  for (const a of opt.actions) {
    if (a.click) await page.locator(a.click).first().click({ timeout: 15_000 })
    else await page.locator(a.fill).first().fill(a.text, { timeout: 15_000 })
    await page.waitForLoadState('networkidle', { timeout: 5_000 }).catch(() => {})
  }
  if (opt.waitMs > 0) await page.waitForTimeout(Math.min(opt.waitMs, 10_000))

  mkdirSync(dirname(opt.out), { recursive: true })
  const shot = { path: opt.out, animations: 'disabled', caret: 'hide' }
  const vp = VIEWPORTS[opt.viewport].viewport
  if (opt.fullPage) {
    const h = await page.evaluate(() => document.documentElement.scrollHeight)
    if (h > MAX_HEIGHT) shot.clip = { x: 0, y: 0, width: vp.width, height: MAX_HEIGHT }
    else shot.fullPage = true
  }
  await page.screenshot(shot)
  result.title = await page.title()
  result.height = opt.fullPage ? Math.min(await page.evaluate(() => document.documentElement.scrollHeight), MAX_HEIGHT) : vp.height
  result.width = vp.width
  await context.storageState({ path: STATE })
} catch (e) {
  result.error = String(e.message || e).split('\n')[0]
  code = 1
} finally {
  await browser.close()
}
result.consoleErrors = result.consoleErrors.slice(0, 10)
result.failedRequests = result.failedRequests.slice(0, 10)
console.log(JSON.stringify(result, null, 2))
process.exit(code)
