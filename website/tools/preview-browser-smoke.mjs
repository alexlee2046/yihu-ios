// Test-only SDK is pinned and installed in RUNNER_TEMP by the existing CI job.
// WebKit here is a real WebKit engine, NOT branded Safari or an iPhone test.
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import { resolve, extname, sep } from 'node:path';
if (process.platform !== 'linux' || !process.env.CI) throw Error('Use the existing remote CI job for browser acceptance.');
const { chromium, webkit } = createRequire(import.meta.url)('playwright');
const dist = resolve('dist'), output = resolve(process.env.RUNNER_TEMP || tmpdir(), 'yihu-preview-smoke');
await mkdir(output, { recursive: true });
const results = [], failures = [];
let activeBrowser;
for (const signal of ['SIGTERM', 'SIGINT']) process.once(signal, async () => {
  try { await activeBrowser?.close(); } finally { process.exit(signal === 'SIGINT' ? 130 : 143); }
});
const cjk = execFileSync('fc-match', ['--format=%{family}', ':lang=zh-cn'], { encoding: 'utf8' });
assert.ok(/Noto.*CJK/.test(cjk), 'CJK glyphs are required, not tofu.');
const scene = (page, value) => page.locator('.preview-scenes>button').nth({ voice: 0, audio: 1, radar: 2 }[value]);
const events = page => page.evaluate(() => (window.dataLayer || []).map(x => Array.from(x)).filter(x => x[0] === 'event'));
const frame = page => page.evaluate(() => new Promise(requestAnimationFrame));
async function shot(page, engine, name) { await page.screenshot({ path: resolve(output, engine + '-' + name + '.png'), fullPage: false }); }
async function geometry(page, width) {
  const data = await page.evaluate(() => ({ width: innerWidth, scrollWidth: document.documentElement.scrollWidth, font: getComputedStyle(document.body).fontFamily, permissions: window.__permissions, cards: [...document.querySelectorAll('.preview-scenes>button')].map(x => x.getBoundingClientRect().bottom) }));
  assert.equal(data.width, width); assert.ok(data.scrollWidth <= width, JSON.stringify(data));
  assert.equal(data.permissions, 0); assert.ok(data.font.includes('Manrope'));
  return data;
}
async function openPage(browser, path, width, height) {
  const context = await browser.newContext({ viewport: { width, height }, deviceScaleFactor: 1, isMobile: width < 700, hasTouch: width < 700, reducedMotion: 'reduce', locale: path.startsWith('/en/') ? 'en-US' : 'zh-CN' });
  try {
    await context.addInitScript(() => {
      window.__permissions = 0;
      if (navigator.mediaDevices) navigator.mediaDevices.getUserMedia = () => { window.__permissions++; return Promise.reject(Error('No mic in preview')); };
      if (navigator.bluetooth) navigator.bluetooth.requestDevice = () => { window.__permissions++; return Promise.reject(Error('No Bluetooth in preview')); };
    });
    await context.route('**/*', async route => {
      const url = new URL(route.request().url());
      if (url.origin === 'https://www.googletagmanager.com') return route.fulfill({ contentType: 'text/javascript', body: '// Isolated tag stub; inspect the actual consent bootstrap dataLayer.' });
      if (url.origin !== 'https://getyihu.com') { failures.push('Unexpected external request: ' + url.origin); return route.abort(); }
      const file = resolve(dist, '.' + decodeURIComponent(url.pathname) + (url.pathname.endsWith('/') ? 'index.html' : ''));
      assert.ok(file.startsWith(dist + sep));
      try {
        const body = await readFile(file);
        const contentType = { '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.svg': 'image/svg+xml', '.png': 'image/png', '.webp': 'image/webp', '.woff2': 'font/woff2' }[extname(file)] || 'application/octet-stream';
        await route.fulfill({ status: 200, contentType, body });
      } catch { failures.push('Missing static file: ' + url.pathname); await route.abort(); }
    });
    const page = await context.newPage();
    page.on('pageerror', error => failures.push('Page error: ' + error.message));
    await page.goto('https://getyihu.com' + path, { waitUntil: 'load', timeout: 20000 });
    await page.waitForFunction(() => !document.querySelector('astro-island')?.hasAttribute('ssr'), null, { timeout: 15000 });
    await page.evaluate(() => document.fonts.ready);
    assert.equal((await events(page)).length, 0, 'no preview events before consent');
    assert.equal(await page.evaluate(() => !!window.speechSynthesis?.speaking || !!window.speechSynthesis?.pending), false, 'no autoplay');
    await page.locator('#analytics-deny').click();
    await page.evaluate(() => document.activeElement?.blur());
    return { page, close: () => context.close() };
  } catch (error) { await context.close(); throw error; }
}
async function nativeSpeech(page, en) {
  const capability = await page.evaluate(() => ({ available: !!window.speechSynthesis && typeof SpeechSynthesisUtterance === 'function', voices: typeof window.speechSynthesis?.getVoices === 'function' ? window.speechSynthesis.getVoices().length : 0 }));
  await page.getByRole('button', { name: en ? 'Read sample aloud' : '朗读示例材料', exact: true }).click();
  await frame(page);
  const state = await page.evaluate(() => ({ speaking: !!window.speechSynthesis?.speaking, pending: !!window.speechSynthesis?.pending }));
  let outcome;
  const stopped = await page.evaluate(name => { const button = [...document.querySelectorAll('.preview-actions button')].find(x => x.textContent === name); if (!button) return false; button.click(); return true; }, en ? 'Stop read-aloud' : '停止朗读');
  if (stopped) {
    await frame(page);
    await page.waitForFunction(() => !window.speechSynthesis?.speaking && !window.speechSynthesis?.pending, null, { timeout: 5000 });
    assert.ok((await page.locator('.preview-status').first().innerText()).includes(en ? 'stopped' : '停止'));
    outcome = 'actual API start/stop; queue state only, audible output not measured';
  } else {
    const status = await page.locator('.preview-status').first().innerText();
    assert.ok(/unavailable|finished|不可用|朗读结束/.test(status), status);
    outcome = /unavailable|不可用/.test(status) ? 'actual platform unavailable fallback' : 'actual API end event';
  }
  return { ...capability, state, outcome, audibleOutput: 'not measured' };
}
async function speechContracts(page, en) {
  await page.evaluate(() => {
    window.__speech = { calls: [], cancels: 0 };
    Object.defineProperty(window, 'SpeechSynthesisUtterance', { configurable: true, value: class { constructor(text) { this.text = text; } } });
    Object.defineProperty(window, 'speechSynthesis', { configurable: true, value: { speak(value) { window.__speech.calls.push(value); }, cancel() { window.__speech.cancels++; } } });
  });
  const read = () => page.getByRole('button', { name: en ? 'Read sample aloud' : '朗读示例材料', exact: true }).click();
  await read();
  await page.evaluate(() => { window.__lateEnd = window.__speech.calls.at(-1).onend; });
  await page.getByRole('button', { name: en ? 'Stop read-aloud' : '停止朗读', exact: true }).click();
  await page.evaluate(() => window.__lateEnd());
  assert.ok((await page.locator('.preview-status').first().innerText()).includes(en ? 'stopped' : '停止'), 'late callback cannot revive canceled playback');
  await read();
  await page.locator('.preview-toolbar select').selectOption('meeting');
  assert.equal(await page.evaluate(() => window.__speech.cancels), 2);
  await read(); await scene(page, 'audio').click();
  assert.equal(await page.evaluate(() => window.__speech.cancels), 3);
  await scene(page, 'voice').click(); await read();
  await page.evaluate(() => window.dispatchEvent(new Event('pagehide')));
  assert.equal(await page.evaluate(() => window.__speech.cancels), 4);
  await read();
  await page.evaluate(() => { Object.defineProperty(document, 'hidden', { configurable: true, get: () => true }); document.dispatchEvent(new Event('visibilitychange')); delete document.hidden; });
  assert.equal(await page.evaluate(() => window.__speech.cancels), 5);
  await page.evaluate(() => Object.defineProperty(window, 'speechSynthesis', { configurable: true, value: undefined }));
  await read();
  assert.ok((await page.locator('.preview-status').first().innerText()).includes(en ? 'unavailable' : '不可用'));
  await page.locator('.preview-toolbar select').selectOption('web');
  return 'fault-injected stop/sample/scene/pagehide/hidden/late callback/unavailable paths PASS; separate from native API probe';
}
async function interactions(page, en) {
  await scene(page, 'voice').focus();
  await page.keyboard.press('Tab');
  assert.ok(await scene(page, 'audio').evaluate(x => x === document.activeElement), 'Tab reaches next scene');
  await page.keyboard.press('Enter');
  assert.equal(await page.locator('[data-preview]').getAttribute('data-preview'), 'audio');
  assert.ok(await scene(page, 'audio').evaluate(x => getComputedStyle(x).outlineStyle !== 'none' && parseFloat(getComputedStyle(x).outlineWidth) > 0), 'keyboard focus is visible');
  await page.keyboard.press('ArrowRight');
  assert.ok(await scene(page, 'radar').evaluate(x => x === document.activeElement));
  await page.keyboard.press('Space');
  assert.equal(await page.locator('[data-preview]').getAttribute('data-preview'), 'radar');
  await scene(page, 'audio').click();
  const check = page.locator('.preview-actions button').first();
  assert.equal(await check.isDisabled(), true);
  const selects = page.locator('.preview-checks select');
  for (const [i, value] of ['headset', 'yes', 'no', 'yes'].entries()) await selects.nth(i).selectOption(value);
  await check.click();
  assert.ok((await page.locator('.preview-panel .preview-status').innerText()).includes(en ? 'phone comparison' : '手机对照'));
  await scene(page, 'radar').click();
  const sampleGroup = page.getByRole('group', { name: en ? 'Synthetic brief samples' : '切换合成简报' });
  const view = page.getByRole('group', { name: en ? 'Brief view' : '简报视图', exact: true });
  for (const [name, id] of en ? [['Inquiry', 'inquiry'], ['Market', 'market'], ['Follow-up', 'followup']] : [['询盘', 'inquiry'], ['市场', 'market'], ['跟进', 'followup']]) {
    await sampleGroup.getByRole('button', { name, exact: true }).focus();
    await page.keyboard.press('Enter');
    assert.ok(await sampleGroup.getByRole('button', { name, exact: true }).evaluate(x => x === document.activeElement));
    await view.getByRole('button', { name: 'JSON', exact: true }).click();
    const sample = JSON.parse(await page.locator('.preview-json').innerText()); assert.equal(sample.tasks[0].id, 'sample-' + id);
    await page.locator('.preview-json').focus(); await page.keyboard.press('ArrowRight');
    await view.getByRole('button', { name: en ? 'Readable brief' : '可读简报', exact: true }).click();
    assert.ok((await page.locator('.preview-brief').innerText()).includes(sample.tasks[0].title));
  }
  await scene(page, 'voice').click();
  const native = await nativeSpeech(page, en);
  const contracts = await speechContracts(page, en);
  assert.equal((await events(page)).length, 0, 'denied interactions are not queued');
  await page.locator('#analytics-settings').click(); await page.locator('#analytics-allow').click();
  await page.locator('.preview-panel textarea').fill('SYNTHETIC_EDIT_ONLY_42');
  const insert = page.getByRole('button', { name: en ? 'Place in sample draft' : '填入本页示例草稿', exact: true });
  await insert.focus(); await page.keyboard.press('Enter'); assert.equal(await page.locator('.preview-draft').innerText(), 'SYNTHETIC_EDIT_ONLY_42');
  assert.ok(await insert.evaluate(x => x === document.activeElement), 'insertion preserves focus');
  await insert.click();
  let captured = await events(page); assert.deepEqual(captured.map(x => x[1]), ['scenario_select', 'preview_complete']);
  assert.ok(!JSON.stringify(captured).includes('SYNTHETIC_EDIT_ONLY_42'));
  for (const x of captured) assert.deepEqual(Object.keys(x[2]).sort(), ['action', 'language', 'page', 'scenario']);
  await page.locator('.preview-footer a[href$="/start/"]').evaluate(a => { a.addEventListener('click', e => e.preventDefault(), { once: true }); a.click(); });
  assert.equal((await events(page)).length, 3);
  await page.locator('#analytics-settings').click(); await page.locator('#analytics-deny').click();
  await scene(page, 'radar').click(); await view.getByRole('button', { name: 'JSON', exact: true }).click();
  captured = await events(page); assert.equal(captured.length, 3, 'withdrawal blocks further events');
  await geometry(page, page.viewportSize().width);
  await scene(page, 'voice').click();
  // Test-only counter survives this isolated page's navigation; app code stores nothing.
  await page.evaluate(() => { sessionStorage.removeItem('preview-test-cancel'); Object.defineProperty(window, 'speechSynthesis', { configurable: true, value: { speak() {}, cancel() { sessionStorage.setItem('preview-test-cancel', String(Number(sessionStorage.getItem('preview-test-cancel') || 0) + 1)); } } }); });
  await page.getByRole('button', { name: en ? 'Read sample aloud' : '朗读示例材料', exact: true }).click();
  assert.equal(await page.evaluate(() => window.__permissions), 0);
  await page.goto('https://getyihu.com/' + (en ? 'en/' : '') + 'start/', { waitUntil: 'load' });
  const canceledOnNavigation = await page.evaluate(() => Number(sessionStorage.getItem('preview-test-cancel') || 0));
  assert.equal(canceledOnNavigation, 1, 'actual navigation cancels the owned utterance exactly once');
  return { keyboard: 'Tab/Enter/Arrow/Space and visible focus PASS', nativeSpeech: native, speechContracts: contracts, actualNavigationCancellation: canceledOnNavigation, telemetry: captured };
}
const targets = [
  ['/', 390, 844, 'voice', 'home-zh-390'], ['/en/', 1440, 1000, 'voice', 'home-en-1440'],
  ['/guides/bluetooth-audio-input-troubleshooting/', 390, 844, 'audio', 'audio-zh-390'],
  ['/en/guides/multi-project-radar-watch/', 390, 844, 'radar', 'radar-en-390'],
  ['/en/guides/recording-notes-handoff/', 1440, 1000, 'voice', 'comparison-en-1440'],
];
for (const [engine, type] of [['chromium', chromium], ['webkit', webkit]]) {
  const record = { engine, platform: process.platform, safariOrDevice: false, pages: [], cleanup: 'pending' };
  results.push(record);
  try {
    activeBrowser = await type.launch({ headless: true, ...(engine === 'chromium' ? { channel: 'chrome' } : {}) });
    record.version = activeBrowser.version();
    for (const [path, width, height, expected, name] of targets) {
      const p = await openPage(activeBrowser, path, width, height);
      try {
        const g = await geometry(p.page, width); assert.equal(await p.page.locator('[data-preview]').getAttribute('data-preview'), expected);
        if (path === '/') assert.ok(g.cards.every(bottom => bottom <= height), 'three cards in first viewport');
        if (path.includes('multi-project')) {
          await p.page.getByRole('group', { name: 'Brief view', exact: true }).getByRole('button', { name: 'JSON', exact: true }).click();
          await p.page.locator('.preview-panel').scrollIntoViewIfNeeded();
        }
        if (path.includes('recording-notes')) await p.page.locator('#same-task').scrollIntoViewIfNeeded();
        await shot(p.page, engine, name);
        const item = { path, ...g };
        record.pages.push(item);
        if (path === '/' || path === '/en/') item.interactions = await interactions(p.page, path === '/en/');
        else await geometry(p.page, width);
      } finally { await p.close(); }
    }
    assert.deepEqual(failures, []);
  } finally {
    await activeBrowser?.close(); activeBrowser = undefined;
    record.cleanup = 'closed';
    await writeFile(resolve(output, 'evidence.json'), JSON.stringify({ results, failures }, null, 2));
  }
}
console.log('Browser preview acceptance PASS: Chromium + WebKit, 5 pages per engine, 390/1440px; native speech API and injected contracts reported separately; browsers closed.');
