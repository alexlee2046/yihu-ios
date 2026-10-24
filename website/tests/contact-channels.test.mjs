import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';
import ts from 'typescript';

const root = new URL('../', import.meta.url);
const read = path => readFileSync(new URL(path, root), 'utf8');
const source = read('src/lib/contact-channels.ts');
const js = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 } }).outputText;
const base = { PUBLIC_CHATWOOT_ENABLED: 'true', PUBLIC_CHATWOOT_BASE_URL: 'https://chatwoot.kynora.world', PUBLIC_CHATWOOT_WEBSITE_TOKEN: 'synthetic-not-a-real-inbox' };
function module(context = {}) {
  const exports = {};
  vm.runInNewContext(js, { exports, URL, ...context });
  return exports;
}
const config = value => JSON.parse(JSON.stringify(module().contactConfig(value)));

test('contact is off unless each channel is explicitly enabled with complete public configuration', () => {
  for (const env of [{}, { ...base, PUBLIC_CHATWOOT_ENABLED: undefined }, { ...base, PUBLIC_CHATWOOT_ENABLED: true }, { ...base, PUBLIC_CHATWOOT_ENABLED: 'false' }, { ...base, PUBLIC_CHATWOOT_WEBSITE_TOKEN: undefined }, { ...base, PUBLIC_CHATWOOT_BASE_URL: undefined }]) assert.deepEqual(config(env), { chat: null, email: null });
  assert.deepEqual(config(base), { chat: { baseUrl: base.PUBLIC_CHATWOOT_BASE_URL, websiteToken: base.PUBLIC_CHATWOOT_WEBSITE_TOKEN }, email: null });
});
for (const url of ['http://chatwoot.kynora.world', 'https://chatwoot.kynora.world.evil.example', 'https://other.example', 'https://name:password@chatwoot.kynora.world', 'https://chatwoot.kynora.world/path', 'https://chatwoot.kynora.world/?context=example', 'https://chatwoot.kynora.world/#fragment', 'https://chatwoot.kynora.world:8443', 'javascript:void(0)']) {
  test('executable script origin rejects ' + url, () => assert.equal(config({ ...base, PUBLIC_CHATWOOT_BASE_URL: url }).chat, null));
}
for (const token of ['', ' ', 'two tokens', 'token\nvalue', 'x'.repeat(513), 42, {}, null]) {
  test('malformed public identifier stays off: ' + JSON.stringify(token).slice(0,30), () => assert.equal(config({ ...base, PUBLIC_CHATWOOT_WEBSITE_TOKEN: token }).chat, null));
}
test('mail is separately enabled, single-target and not a sending API', () => {
  assert.equal(config({ PUBLIC_CONTACT_EMAIL: 'support@example.test' }).email, null);
  assert.equal(config({ PUBLIC_CONTACT_EMAIL_ENABLED: true, PUBLIC_CONTACT_EMAIL: 'support@example.test' }).email, null);
  assert.equal(config({ PUBLIC_CONTACT_EMAIL_ENABLED: 'true', PUBLIC_CONTACT_EMAIL: 'support@example.test' }).email, 'support@example.test');
  for (const email of ['x@example.test?bcc=elsewhere', 'x@example.test\r\nSubject:injected', 'Name <x@example.test>', 'mailto:x@example.test', 'x@example.test,y@example.test', 'x@example..test', 'x@-example.test', '.x@example.test', 'x..y@example.test', 'x.@example.test', 'x'.repeat(250)+'@example.test']) assert.equal(config({ PUBLIC_CONTACT_EMAIL_ENABLED: 'true', PUBLIC_CONTACT_EMAIL: email }).email, null);
  assert.equal(config({ ...base, PUBLIC_CONTACT_EMAIL_ENABLED: 'false', PUBLIC_CONTACT_EMAIL: 'support@example.test' }).chat.websiteToken, base.PUBLIC_CHATWOOT_WEBSITE_TOKEN);
});

class Element extends EventTarget {
  constructor() { super(); this.textContent = 'Chat'; this.disabled = false; this.attrs = {}; this.focusCount = 0; }
  setAttribute(k,v) { this.attrs[k]=v; }
  removeAttribute(k) { delete this.attrs[k]; }
  focus() { this.focusCount++; }
}
function harness(options = {}) {
  const button = new Element(), status = new Element(); status.textContent = '';
  const win = new EventTarget(); win.innerHeight = 900;
  Object.defineProperty(win, 'localStorage', { get() { throw Error('must not access storage'); } });
  Object.defineProperty(win, 'location', { get() { throw Error('must not copy URL context'); } });
  win.gtag = () => { throw Error('must not change analytics consent or send events'); };
  const styles = {}, scripts = [], calls = [], runs = [], timers = new Map(), observers = [];
  let nextTimer = 1;
  const banner = { hidden: false, getBoundingClientRect: () => ({ top: 740 }) };
  const box = { dataset: { baseUrl: base.PUBLIC_CHATWOOT_BASE_URL, websiteToken: base.PUBLIC_CHATWOOT_WEBSITE_TOKEN, lang: 'en', ...options.dataset }, style: { setProperty(k,v) { styles[k]=v; } }, querySelector(selector) { return selector === 'button' ? button : status; } };
  class Observer { constructor(fn) { this.fn=fn; observers.push(this); } observe() {} disconnect() {} }
  const doc = { getElementById(id) { assert.equal(id, 'analytics-consent'); return banner; }, createElement(tag) { assert.equal(tag, 'script'); return { removed:false, remove() { this.removed=true; } }; }, head: { appendChild(s) { scripts.push(s); } } };
  const exports = module({ window: win, document: doc, ResizeObserver: Observer, MutationObserver: Observer, setTimeout(fn) { const n=nextTimer++; timers.set(n,fn); return n; }, clearTimeout(n) { timers.delete(n); } });
  const ownedAPI = { baseUrl:base.PUBLIC_CHATWOOT_BASE_URL, websiteToken:base.PUBLIC_CHATWOOT_WEBSITE_TOKEN, hasLoaded:true, toggle(state) { calls.push(state); } };
  const mount = () => exports.mountContactChat(box);
  const click = () => button.dispatchEvent(new Event('click'));
  const ready = () => win.dispatchEvent(new Event('chatwoot:ready'));
  const load = (run = args => { runs.push(JSON.parse(JSON.stringify(args))); win.$chatwoot = ownedAPI; ready(); }) => { win.chatwootSDK = { run }; scripts[0].onload(); };
  if (options.foreign) win.$chatwoot = { toggle() { throw Error('must not adopt another widget'); } };
  mount();
  return { button, status, win, box, styles, scripts, calls, runs, timers, observers, banner, ownedAPI, mount, click, ready, load, fireTimers() { for (const fn of [...timers.values()]) fn(); } };
}
test('mount stays inert before a deliberate click, never adopting storage or URL context', () => {
  const h = harness();
  assert.equal(h.scripts.length,0); assert.equal(h.win.chatwootSettings,undefined);
  assert.equal(h.styles['--contact-bottom'],'180px');
  h.banner.hidden=true; h.observers[0].fn(); assert.equal(h.styles['--contact-bottom'],'20px');
  assert.equal(h.banner.hidden,true);
});
test('one click lazily loads only the approved SDK and only two public run fields', () => {
  const h = harness(); h.click(); h.click();
  assert.equal(h.scripts.length,1);
  assert.equal(h.scripts[0].src,'https://chatwoot.kynora.world/packs/js/sdk.js');
  assert.equal(h.scripts[0].referrerPolicy,'no-referrer');
  assert.equal(h.button.disabled,false,'loading must preserve native keyboard focus');
  assert.equal(h.button.attrs['aria-busy'],'true');
  h.load();
  assert.deepEqual(h.runs,[{ baseUrl:base.PUBLIC_CHATWOOT_BASE_URL, websiteToken:base.PUBLIC_CHATWOOT_WEBSITE_TOKEN }]);
  assert.deepEqual(h.calls,['open']); assert.equal(h.timers.size,0);
  assert.equal(h.win.chatwootSettings.hideMessageBubble,true);
  assert.equal(h.win.chatwootSettings.showUnreadMessagesDialog,false);
  assert.equal(h.win.chatwootSettings.locale,'en');
  assert.equal('aria-expanded' in h.button.attrs,false,'do not invent a cross-frame open state');
});
test('early/duplicate ready events cannot run/open the widget again', () => {
  const h = harness(); h.ready(); assert.equal(h.calls.length,0);
  h.click(); h.ready(); assert.equal(h.calls.length,0);
  h.load(); h.ready(); assert.deepEqual(h.calls,['open']);
});
test('subsequent native clicks use official toggle; Escape is scoped to the launcher', () => {
  const h = harness(); h.click(); h.load(); h.click();
  const e=new Event('keydown',{cancelable:true}); Object.defineProperty(e,'key',{value:'Escape'}); h.button.dispatchEvent(e);
  assert.deepEqual(h.calls,['open',undefined,'close']); assert.equal(e.defaultPrevented,true); assert.equal(h.button.focusCount,1);
  const unrelated=new Event('keydown',{cancelable:true}); Object.defineProperty(unrelated,'key',{value:'Enter'}); h.button.dispatchEvent(unrelated);
  assert.equal(unrelated.defaultPrevented,false,'preserve native Enter/Space behavior');
});
test('Chinese locale, duplicate mounts and malformed datasets stay bounded', () => {
  const h=harness({dataset:{lang:'zh'}}); h.mount(); h.click(); assert.equal(h.scripts.length,1); h.load(); assert.equal(h.win.chatwootSettings.locale,'zh_CN');
  const bad=harness({dataset:{baseUrl:'https://elsewhere.example'}}); bad.click(); assert.equal(bad.scripts.length,0);
});
test('run-to-ready replacement is rejected without opening a foreign API', () => {
  const h=harness(); let sdkRuns=0, foreignOpens=0;
  h.click(); h.load(()=>{sdkRuns++;h.win.$chatwoot=h.ownedAPI;});
  const foreign={baseUrl:base.PUBLIC_CHATWOOT_BASE_URL,websiteToken:'synthetic-other-inbox',hasLoaded:true,toggle(){foreignOpens++;}};
  h.win.$chatwoot=foreign; h.ready();
  console.log('OFFLINE run-to-ready probe',JSON.stringify({sdkRuns,ownOpens:h.calls.length,foreignOpens}));
  assert.equal(foreignOpens,0);
  assert.equal(h.button.disabled,true);
  assert.equal(h.win.$chatwoot,foreign,'do not reset or replace another session');
});
test('matching public fields cannot substitute another API, SDK or run method after installation', () => {
  for (const kind of ['api','sdk','run','toggle']) {
    const h=harness(); let foreignOpens=0;
    h.click(); h.load(()=>{h.win.$chatwoot=h.ownedAPI;});
    if(kind==='api') h.win.$chatwoot={...h.ownedAPI,toggle(){foreignOpens++;}};
    if(kind==='sdk') h.win.chatwootSDK={run(){throw Error('foreign installer');}};
    if(kind==='run') h.win.chatwootSDK.run=()=>{throw Error('replaced run');};
    if(kind==='toggle') h.ownedAPI.toggle=()=>{foreignOpens++;};
    h.ready(); assert.equal(h.button.disabled,true,kind);
    assert.deepEqual(h.calls,[],kind);assert.equal(foreignOpens,0,kind);
  }
});
test('installed tenant fields are checked at ready and again on subsequent use', () => {
  for(const key of ['baseUrl','websiteToken']) for(const phase of ['before-ready','after-ready']) {
    const h=harness();h.click();
    if(phase==='before-ready') h.load(()=>{h.win.$chatwoot=h.ownedAPI;}); else h.load();
    h.ownedAPI[key]='synthetic-other-tenant';
    if(phase==='before-ready') h.ready(); else h.click();
    assert.equal(h.button.disabled,true,key+' '+phase);
    assert.deepEqual(h.calls,phase==='before-ready'?[]:['open']);
    assert.equal(h.win.$chatwoot,h.ownedAPI,'never reset another identity/session');
    assert.equal(h.ownedAPI[key],'synthetic-other-tenant');
  }
});
test('a forged ready without loaded state or a synchronous run-installed API is not adopted', () => {
  const h=harness();h.ownedAPI.hasLoaded=false;h.click();h.load(()=>{h.win.$chatwoot=h.ownedAPI;});
  h.ready();assert.deepEqual(h.calls,[]);assert.equal(h.button.attrs['aria-busy'],'true');
  h.ownedAPI.hasLoaded=true;h.ready();assert.deepEqual(h.calls,['open'],'later genuine ready still works');
  const missing=harness();missing.click();missing.load(()=>{});assert.equal(missing.button.disabled,true);
  missing.win.$chatwoot=missing.ownedAPI;missing.ready();assert.deepEqual(missing.calls,[],'no late adoption');
  const preexisting=harness();preexisting.click();preexisting.win.$chatwoot=preexisting.ownedAPI;
  preexisting.load(()=>{throw Error('must not run against a pre-existing API');});assert.equal(preexisting.button.disabled,true);
});
test('synchronous ready is deferred through run and rejects replacement before run returns', () => {
  const sync=harness();sync.click();sync.load(()=>{
    sync.ready();assert.deepEqual(sync.calls,[]);
    sync.win.$chatwoot=sync.ownedAPI;
  });assert.deepEqual(sync.calls,['open']);assert.equal(sync.button.disabled,false);
  for(const kind of ['api','toggle']) {
    const replaced=harness();let foreignOpens=0;replaced.click();replaced.load(()=>{
      replaced.win.$chatwoot=replaced.ownedAPI;replaced.ready();assert.deepEqual(replaced.calls,[]);
      if(kind==='api') replaced.win.$chatwoot={...replaced.ownedAPI,toggle(){foreignOpens++;}};
      else replaced.ownedAPI.toggle=()=>{foreignOpens++;};
    });assert.equal(replaced.button.disabled,true);assert.deepEqual(replaced.calls,[]);assert.equal(foreignOpens,0);
  }
});
test('pre-existing or replaced SDK state is never borrowed across inboxes', () => {
  const h=harness({foreign:true}); h.click(); assert.equal(h.scripts.length,0); assert.equal(h.button.disabled,true);
  const replaced=harness(); replaced.click(); replaced.load(); replaced.win.$chatwoot={toggle() { throw Error('foreign API'); }}; replaced.click(); assert.equal(replaced.button.disabled,true); assert.deepEqual(replaced.calls,['open']);
});
test('network errors, missing SDK, thrown run and missing API fail closed', () => {
  const network=harness(); network.click(); network.scripts[0].onerror(); assert.equal(network.button.disabled,true); assert.match(network.status.textContent,/Refresh/); assert.equal(network.scripts[0].removed,true);
  const missing=harness(); missing.click(); missing.scripts[0].onload(); assert.equal(missing.button.disabled,true);
  const thrown=harness(); thrown.click(); thrown.load(()=>{throw Error('blocked');}); assert.equal(thrown.button.disabled,true);
  const api=harness(); api.click(); api.load(()=>api.ready()); assert.equal(api.button.disabled,true);
});
test('timeout and pagehide reject late callbacks without creating a visitor', () => {
  const timeout=harness(); timeout.click(); timeout.fireTimers(); timeout.load(); timeout.ready(); assert.equal(timeout.runs.length,0); assert.deepEqual(timeout.calls,[]);
  const hidden=harness(); hidden.click(); hidden.win.dispatchEvent(new Event('pagehide')); hidden.load(); hidden.ready(); assert.equal(hidden.runs.length,0); assert.equal(hidden.timers.size,0);
  hidden.win.dispatchEvent(new Event('pageshow')); assert.equal(hidden.button.disabled,true);
});
test('a ready owned widget closes for navigation and resumes only its own API on restore', () => {
  const h=harness(); h.click(); h.load(); h.win.dispatchEvent(new Event('pagehide')); h.click(); assert.deepEqual(h.calls,['open','close']);
  h.win.dispatchEvent(new Event('pageshow')); h.click(); assert.deepEqual(h.calls,['open','close',undefined]);
});
test('integration never adds user identity, draft extraction, sending APIs or analytics changes', () => {
  for (const forbidden of ['.reset(', 'document.cookie', 'setUser(', 'setCustomAttributes(', 'getUserMedia', 'localStorage', 'sessionStorage', 'gtag(', 'fetch(', 'XMLHttpRequest', 'chatwoot:on-message', 'chatwoot:closed', 'chatwoot:opened']) assert.ok(!source.includes(forbidden),forbidden);
  const layout=read('src/layouts/Layout.astro');
  assert.ok(layout.includes('contact.chat && <ContactChat'));
  assert.ok(layout.includes('contact.email && <a class="contact-email" href={`mailto:${contact.email}`}'));
  assert.ok(!layout.includes('bcc=') && !layout.includes('subject='));
});
