// Remote CI only. Uses the existing Ubuntu runner's Chrome; no new browser dependency.
import assert from 'node:assert/strict';
import { spawn, execFileSync } from 'node:child_process';
import { mkdtemp, readFile, writeFile, mkdir, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve, extname, sep } from 'node:path';
import { once } from 'node:events';
if (process.platform !== 'linux' || !process.env.CI) throw Error('Run browser acceptance in the existing remote CI job, not on the Mac.');
const dist = resolve('dist');
const output = resolve(process.env.RUNNER_TEMP || tmpdir(), 'yihu-preview-smoke');
await mkdir(output, { recursive: true });
const profile = await mkdtemp(resolve(tmpdir(), 'yihu-preview-chrome-'));
let chrome, socket;
const results = [], failures = [];
const pending = new Map(), listeners = new Map();
let sequence = 0;
function send(method, params = {}, sessionId) {
  const id = ++sequence;
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => { pending.delete(id); reject(Error('CDP timeout: ' + method)); }, 15000);
    pending.set(id, { resolve, reject, timeout });
    socket.send(JSON.stringify({ id, method, params, ...(sessionId ? { sessionId } : {}) }));
  });
}
function on(method, fn) { if (!listeners.has(method)) listeners.set(method, new Set()); listeners.get(method).add(fn); return () => listeners.get(method).delete(fn); }
function event(method, sessionId) {
  return new Promise((resolve, reject) => {
    const stop = on(method, (params, session) => { if (session === sessionId) { clearTimeout(timeout); stop(); resolve(params); } });
    const timeout = setTimeout(() => { stop(); reject(Error('Event timeout: ' + method)); }, 15000);
  });
}
async function evaluate(session, expression) {
  const result = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true, userGesture: true }, session);
  if (result.exceptionDetails) throw Error(result.exceptionDetails.text + ': ' + result.exceptionDetails.exception?.description);
  return result.result.value;
}
async function act(session, expression) { await evaluate(session, '(async()=>{' + expression + ';await new Promise(requestAnimationFrame);return true})()'); }
async function clickText(session, selector, text) {
  await act(session, `(()=>{const b=[...document.querySelectorAll(${JSON.stringify(selector)})].find(b=>b.textContent.includes(${JSON.stringify(text)}));if(!b)throw Error('Missing button');b.click()})()`);
}
const init = `window.__permissions=0;window.__speech={calls:[],cancels:0};
Object.defineProperty(window,'SpeechSynthesisUtterance',{configurable:true,value:class{constructor(text){this.text=text}}});
Object.defineProperty(window,'speechSynthesis',{configurable:true,value:{speak(value){window.__speech.calls.push(value)},cancel(){window.__speech.cancels++}}});
if(navigator.mediaDevices)navigator.mediaDevices.getUserMedia=()=>{window.__permissions++;return Promise.reject(Error('No mic in previews'))};
if(navigator.bluetooth)navigator.bluetooth.requestDevice=()=>{window.__permissions++;return Promise.reject(Error('No Bluetooth in previews'))};`;
async function openPage(path, width, height) {
  const { browserContextId } = await send('Target.createBrowserContext');
  const { targetId } = await send('Target.createTarget', { url: 'about:blank', browserContextId });
  const { sessionId } = await send('Target.attachToTarget', { targetId, flatten: true });
  await send('Page.enable', {}, sessionId);
  await send('Runtime.enable', {}, sessionId);
  await send('Emulation.setDeviceMetricsOverride', { width, height, deviceScaleFactor: 1, mobile: width < 700 }, sessionId);
  await send('Page.addScriptToEvaluateOnNewDocument', { source: init }, sessionId);
  await send('Fetch.enable', { patterns: [{ urlPattern: '*', requestStage: 'Request' }] }, sessionId);
  const loaded = event('Page.loadEventFired', sessionId);
  await send('Page.navigate', { url: 'https://getyihu.com' + path }, sessionId);
  await loaded;
  await evaluate(sessionId, '(async()=>{await document.fonts.ready;const i=document.querySelector("astro-island");if(i?.hasAttribute("ssr"))await new Promise(r=>i.addEventListener("astro:hydrate",r,{once:true}));return true})()');
  await act(sessionId, "document.getElementById('analytics-deny').click()");
  const geometry = await evaluate(sessionId, `({path:location.pathname,width:innerWidth,scrollWidth:document.documentElement.scrollWidth,font: getComputedStyle(document.body).fontFamily,permissions:__permissions,autoplay:__speech.calls.length,scene:document.querySelector('[data-preview]').dataset.preview,cards:[...document.querySelectorAll('.preview-scenes>button')].map(x=>({bottom:x.getBoundingClientRect().bottom,name:x.textContent.trim()}))})`);
  assert.ok(geometry.scrollWidth <= width, JSON.stringify(geometry));
  assert.equal(geometry.permissions, 0); assert.equal(geometry.autoplay, 0);
  assert.ok(geometry.font.includes('Manrope'));
  results.push(geometry);
  return { session: sessionId, close: () => send('Target.disposeBrowserContext', { browserContextId }) };
}
async function screenshot(session, name) {
  const { data } = await send('Page.captureScreenshot', { format: 'png', captureBeyondViewport: false }, session);
  await writeFile(resolve(output, name + '.png'), Buffer.from(data, 'base64'));
}
try {
  const binary = execFileSync('which', ['google-chrome'], { encoding: 'utf8' }).trim();
  chrome = spawn(binary, ['--headless=new', '--no-sandbox', '--disable-gpu', '--no-first-run', '--no-default-browser-check', '--disable-background-networking', '--disable-sync', '--disable-extensions', '--disable-component-update', '--remote-debugging-address=127.0.0.1', '--remote-debugging-port=0', '--user-data-dir=' + profile, 'about:blank'], { stdio: ['ignore', 'ignore', 'pipe'] });
  let stderr = '';
  const ready = new Promise((resolve, reject) => {
    const timeout = setTimeout(() => reject(Error('Chrome did not become ready')), 15000);
    chrome.stderr.on('data', value => { stderr += value; if (stderr.includes('DevTools listening on')) { clearTimeout(timeout); resolve(); } });
    chrome.once('exit', code => { clearTimeout(timeout); reject(Error('Chrome exited: ' + code)); });
    chrome.once('error', reject);
  });
  await ready;
  const [port, endpoint] = (await readFile(resolve(profile, 'DevToolsActivePort'), 'utf8')).trim().split('\n');
  socket = new WebSocket('ws://127.0.0.1:' + port + endpoint);
  await once(socket, 'open');
  socket.addEventListener('message', message => {
    const data = JSON.parse(message.data);
    if (data.id) {
      const p = pending.get(data.id); if (!p) return; pending.delete(data.id); clearTimeout(p.timeout);
      if (data.error) p.reject(Error(data.error.message)); else p.resolve(data.result);
    } else for (const fn of listeners.get(data.method) || []) Promise.resolve(fn(data.params, data.sessionId)).catch(error => failures.push(error.message));
  });
  on('Fetch.requestPaused', async ({ requestId, request }, session) => {
    const url = new URL(request.url);
    if (url.origin === 'https://www.googletagmanager.com') {
      await send('Fetch.fulfillRequest', { requestId, responseCode: 200, responseHeaders: [{ name: 'Content-Type', value: 'text/javascript' }], body: Buffer.from('// Network-isolated tag stub; bootstrap dataLayer remains inspectable.').toString('base64') }, session); return;
    }
    if (url.origin !== 'https://getyihu.com') {
      failures.push('Unexpected external request: ' + url.origin);
      await send('Fetch.failRequest', { requestId, errorReason: 'BlockedByClient' }, session); return;
    }
    const file = resolve(dist, '.' + decodeURIComponent(url.pathname) + (url.pathname.endsWith('/') ? 'index.html' : ''));
    if (!file.startsWith(dist + sep)) throw Error('Invalid static path');
    try {
      const body = await readFile(file);
      const mime = { '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.svg': 'image/svg+xml', '.png': 'image/png', '.webp': 'image/webp', '.woff2': 'font/woff2', '.m4a': 'audio/mp4' }[extname(file)] || 'application/octet-stream';
      await send('Fetch.fulfillRequest', { requestId, responseCode: 200, responseHeaders: [{ name: 'Content-Type', value: mime }], body: body.toString('base64') }, session);
    } catch (error) { failures.push('Static response failed: ' + url.pathname); await send('Fetch.failRequest', { requestId, errorReason: 'Failed' }, session); }
  });
  const page = await openPage('/', 390, 844), s = page.session;
  assert.ok(results[0].cards.every(x => x.bottom <= 844), 'all three homepage cards are in the first viewport');
  await screenshot(s, 'home-zh-390');
  await act(s, "document.querySelector('.preview-scenes>button').focus()");
  await send('Input.dispatchKeyEvent', { type: 'keyDown', key: 'Tab', code: 'Tab' }, s);
  await send('Input.dispatchKeyEvent', { type: 'keyUp', key: 'Tab', code: 'Tab' }, s);
  await send('Input.dispatchKeyEvent', { type: 'keyDown', key: 'Enter', code: 'Enter' }, s);
  await send('Input.dispatchKeyEvent', { type: 'keyUp', key: 'Enter', code: 'Enter' }, s);
  await act(s, 'void 0');
  assert.equal(await evaluate(s, "document.querySelector('[data-preview]').dataset.preview"), 'audio');
  await act(s, "[...document.querySelectorAll('.preview-checks select')].forEach((x,i)=>{x.value=['headset','yes','no','yes'][i];x.dispatchEvent(new Event('change',{bubbles:true}))})");
  await clickText(s, '.preview-actions button', '查看排查建议');
  assert.ok((await evaluate(s, "document.querySelector('.preview-panel .preview-status').textContent")).includes('手机对照'));
  await clickText(s, '.preview-scenes button', '外贸');
  await clickText(s, '.preview-switches button', '市场');
  await clickText(s, '.preview-switches button', 'JSON');
  assert.equal((await evaluate(s, "JSON.parse(document.querySelector('.preview-json').innerText)")).tasks[0].id, 'sample-market');
  await clickText(s, '.preview-scenes button', '网页朗读');
  await clickText(s, '.preview-actions button', '朗读示例');
  assert.equal(await evaluate(s, '__speech.calls.length'), 1);
  await clickText(s, '.preview-scenes button', '蓝牙');
  assert.equal(await evaluate(s, '__speech.cancels'), 1);
  await clickText(s, '.preview-scenes button', '网页朗读');
  await act(s, "Object.defineProperty(window,'speechSynthesis',{configurable:true,value:undefined})");
  await clickText(s, '.preview-actions button', '朗读示例');
  assert.ok((await evaluate(s, "document.querySelector('.preview-status').textContent")).includes('暂不可用'));
  const events = "(window.dataLayer||[]).map(x=>Array.from(x)).filter(x=>x[0]==='event')";
  assert.equal((await evaluate(s, events)).length, 0, 'no preview events after rejection');
  await act(s, "document.getElementById('analytics-settings').click();document.getElementById('analytics-allow').click()");
  await act(s, "(()=>{const t=document.querySelector('.preview-panel textarea');Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype,'value').set.call(t,'SYNTHETIC_EDIT_ONLY_42');t.dispatchEvent(new Event('input',{bubbles:true}))})()");
  await clickText(s, '.preview-actions button', '填入本页示例');
  assert.equal(await evaluate(s, "document.querySelector('.preview-draft').textContent"), 'SYNTHETIC_EDIT_ONLY_42');
  await clickText(s, '.preview-actions button', '填入本页示例');
  let captured = await evaluate(s, events);
  assert.deepEqual(captured.map(x => x[1]), ['scenario_select', 'preview_complete']);
  assert.ok(!JSON.stringify(captured).includes('SYNTHETIC_EDIT_ONLY_42'));
  for (const x of captured) assert.deepEqual(Object.keys(x[2]).sort(), ['action', 'language', 'page', 'scenario']);
  await act(s, "(()=>{const a=[...document.querySelectorAll('.preview-footer a')].find(x=>x.getAttribute('href')==='/start/');a.addEventListener('click',e=>e.preventDefault(),{once:true});a.click()})()");
  assert.equal((await evaluate(s, events)).length, 3);
  await act(s, "document.getElementById('analytics-settings').click();document.getElementById('analytics-deny').click()");
  await clickText(s, '.preview-scenes button', '外贸');
  await clickText(s, '.preview-switches button', '可读简报');
  await clickText(s, '.preview-switches button', 'JSON');
  captured = await evaluate(s, events); assert.equal(captured.length, 3, 'no events after withdrawal and no replay');
  assert.equal(await evaluate(s, '__permissions'), 0);
  results.push({ interactions: 'PASS', keyboard: 'Tab/Enter', consent: 'denied/granted/withdrawn; isolated tag stub', tts: 'mock start/cancel + unavailable fallback', telemetry: captured });
  await page.close();
  for (const [path, width, height, expected, name] of [
    ['/en/', 1440, 1000, 'voice', 'home-en-1440'],
    ['/guides/bluetooth-audio-input-troubleshooting/', 390, 844, 'audio', 'audio-zh-390'],
    ['/en/guides/multi-project-radar-watch/', 390, 844, 'radar', 'radar-en-390'],
    ['/en/guides/recording-notes-handoff/', 1440, 1000, 'voice', null],
  ]) {
    const p = await openPage(path, width, height);
    try {
      assert.equal(results.at(-1).scene, expected);
      if (name?.startsWith('radar')) { await clickText(p.session, '.preview-switches button', 'JSON'); await act(p.session, "document.querySelector('.preview-panel').scrollIntoView({block:'start'})"); }
      if (name) await screenshot(p.session, name);
    } finally { await p.close(); }
  }
  assert.deepEqual(failures, []);
  console.log('Browser preview acceptance PASS: 5 pages, 390/1440px, keyboard, sample switching, TTS mock/fallback, consent/privacy.');
} finally {
  await writeFile(resolve(output, 'evidence.json'), JSON.stringify({ results, failures }, null, 2));
  if (socket?.readyState === 1) { try { await send('Browser.close'); } catch { /* Exit may close the socket before a reply. */ } socket.close(); }
  if (chrome && chrome.exitCode === null) {
    chrome.kill('SIGTERM');
    await Promise.race([once(chrome, 'exit'), new Promise(resolve => { const t = setTimeout(() => { chrome.kill('SIGKILL'); resolve(); }, 3000); t.unref(); })]);
  }
  await rm(profile, { recursive: true, force: true });
}
