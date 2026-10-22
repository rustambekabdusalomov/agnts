// agnts-pdf: print an HTML file to an A4 PDF with page numbers.
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
  await page.setContent(readFileSync(input, 'utf8'), { waitUntil: 'load' })
  await page.pdf({
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
  })
} finally {
  await browser.close()
}
