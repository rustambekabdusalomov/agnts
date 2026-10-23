// agnts-pdf: print an HTML file to an A4 PDF with page numbers, or, when
// the page says <meta name="agnts-layout" content="slides">, to 16:9
// landscape pages with no margins (the slides number themselves).
//
//   node agnts-pdf.mjs <in.html> <out.pdf>
//
// Uses the Playwright the runner image installs for previews. Every
// request the page makes is refused: a document's PDF never fetches
// anything.
import { chromium } from '/opt/agnts-shot/node_modules/playwright/index.mjs'
import { readFileSync } from 'node:fs'

const [input, output] = process.argv.slice(2)
if (!input || !output) {
  console.error('usage: agnts-pdf <in.html> <out.pdf>')
  process.exit(2)
}

const browser = await chromium.launch()
try {
  const page = await browser.newPage({ javaScriptEnabled: false })
  await page.route('**/*', (route) => route.abort())
  const html = readFileSync(input, 'utf8')
  await page.setContent(html, { waitUntil: 'load' })
  const slides = /<meta name="agnts-layout" content="slides">/.test(html)
  await page.pdf(
    slides
      ? {
          path: output,
          width: '254mm',
          height: '142.875mm',
          printBackground: true,
          preferCSSPageSize: true,
          margin: { top: '0', bottom: '0', left: '0', right: '0' },
        }
      : {
          path: output,
          format: 'A4',
          printBackground: true,
          preferCSSPageSize: true,
          displayHeaderFooter: true,
          headerTemplate: '<span></span>',
          footerTemplate:
            '<div style="width:100%;font-size:8px;color:#888;text-align:center;font-family:sans-serif">' +
            '<span class="pageNumber"></span> / <span class="totalPages"></span></div>',
          margin: { top: '18mm', bottom: '20mm', left: '16mm', right: '16mm' },
        },
  )
} finally {
  await browser.close()
}
