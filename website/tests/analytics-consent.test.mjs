import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync, readdirSync } from 'node:fs';
import vm from 'node:vm';

const component = readFileSync(new URL('../src/components/AnalyticsConsent.astro', import.meta.url), 'utf8');
const script = component.match(/<script is:inline>([\s\S]*?)<\/script>/)[1];
// Independently frozen from Klackjoy consent-region.ts, HEAD 4b8d7f61aaaf75a8b71dd5a68dbc5f9f7d2f9b53.
const regions = 'AT BE BG BR CH CY CZ DE DK EE ES FI FR GB GR HR HU IE IS IT JP LI LT LU LV MT NL NO PL PT RO SE SI SK'.split(' ');
const key = 'yihu.analytics-consent.v1';
const ads = ['ad_storage', 'ad_user_data', 'ad_personalization'];
function harness({ value = null, origin = 'https://getyihu.com', readFails = false, writeFails = false, preDisabled = false, lang = 'en', canonical = 'https://getyihu.com/en/?secret=excluded#private' } = {}) {
  const storage = new Map(value === null ? [] : [[key, value]]);
  const events = []; const windows = {}; const nodes = {}; const cookieWrites = [];
  const window = {
    'ga-disable-G-CWT1FWEHCL': preDisabled,
    addEventListener(name, fn) { windows[name] = fn; },
  };
  const ids = ['analytics-consent', 'analytics-settings', 'analytics-deny', 'analytics-allow', 'analytics-status', 'main'];
  for (const id of ids) nodes[id] = {
    id, hidden: true, disabled: false, textContent: '', handlers: {}, attributes: {},
    addEventListener(name, fn) { this.handlers[name] = fn; },
    setAttribute(k, v) { this.attributes[k] = v; },
    focus() { document.activeElement = this; },
  };
  const document = {
    documentElement: { lang }, activeElement: null,
    getElementById(id) { return nodes[id]; },
    querySelector() { return canonical ? { href: canonical } : null; },
    createElement() { return {}; },
    head: { appendChild(node) { events.push({ script: node, disabled: window['ga-disable-G-CWT1FWEHCL'], queue: queue() }); } },
    get cookie() { return '_ga=sample; _ga_SAMPLE=sample; unrelated=retained'; },
    set cookie(value) { cookieWrites.push(value); },
  };
  function queue() { return Array.from(window.dataLayer || [], args => Array.from(args)); }
  vm.runInNewContext(script, {
    window, document, URL, location: { origin, hostname: new URL(origin).hostname },
    localStorage: {
      getItem(k) { if (readFails) throw Error('blocked'); return storage.get(k) ?? null; },
      setItem(k, v) { if (writeFails) throw Error('blocked'); storage.set(k, v); },
    },
  });
  return { window, nodes, windows, storage, events, queue, cookieWrites,
    click(id) { nodes[id].handlers.click(); },
  };
}
function effective(queue, country) {
  const result = {};
  // Model documented region specificity (not a claim of Google geo/network receipt).
  for (const c of queue.filter(x => x[0] === 'consent' && x[1] === 'default' && !x[2].region)) Object.assign(result, c[2]);
  for (const c of queue.filter(x => x[0] === 'consent' && x[1] === 'default' && x[2].region?.includes(country))) Object.assign(result, c[2]);
  for (const c of queue.filter(x => x[0] === 'consent' && x[1] === 'update')) Object.assign(result, c[2]);
  return result;
}

for (const country of [...regions, 'US', 'CN', 'MY', 'AU', 'CA']) {
  for (const value of [null, 'granted', 'denied', 'malformed']) {
    test(`region/choice matrix ${country} / ${value}`, () => {
      const h = harness({ value }); const q = h.queue(); const state = effective(q, country);
      const choice = value === null ? null : value === 'granted' ? 'granted' : 'denied';
      assert.equal(state.analytics_storage, choice ?? (regions.includes(country) ? 'denied' : 'granted'));
      for (const k of ads) assert.equal(state[k], 'denied');
      assert.equal(h.events.length, 1, 'tag file requested even for denied consent; not zero network');
      const configIndex = q.findIndex(x => x[0] === 'config');
      assert.ok(configIndex > 1);
      assert.ok(q.slice(0, 2).every(x => x[0] === 'consent' && x[1] === 'default'));
      assert.deepEqual(Array.from(q[1][2].region), regions);
      for (const c of q.filter(x => x[0] === 'consent')) for (const k of ads) assert.equal(c[2][k], 'denied');
      if (choice !== null) assert.ok(q.findIndex(x => x[1] === 'update') < configIndex);
      if (choice === 'denied') {
        assert.equal(h.events[0].disabled, true);
        assert.ok(q.filter(x => x[0] === 'consent').every(x => x[2].analytics_storage === 'denied'), 'no transient grant');
      }
      assert.equal(h.events[0].queue.length, q.length, 'all defaults/updates queued before tag insertion');
      assert.equal(q[configIndex][2].page_location, 'https://getyihu.com/en/');
      assert.equal(q[configIndex][2].page_referrer, '');
      assert.equal(q[configIndex][2].allow_google_signals, false);
    });
  }
}
test('production www accepted; previews never load tag even after a grant click', () => {
  assert.equal(harness({ origin: 'https://www.getyihu.com' }).events.length, 1);
  for (const origin of ['http://localhost:43871', 'https://preview.vercel.app', 'https://getyihu.com.attacker.invalid']) {
    const h = harness({ origin });
    h.click('analytics-allow');
    assert.equal(h.events.length, 0); assert.equal(h.nodes['analytics-allow'].disabled, true);
    assert.equal(h.window['ga-disable-G-CWT1FWEHCL'], true);
  }
});
test('unreadable storage fails closed before config', () => {
  const h = harness({ readFails: true });
  assert.ok(h.queue().filter(x => x[0] === 'consent').every(x => x[2].analytics_storage === 'denied'));
  assert.equal(h.events[0].disabled, true);
});
test('allow, reload persistence, withdraw, refusal reload, focus and cookie cleanup', () => {
  const h = harness(); h.click('analytics-allow');
  assert.equal(h.storage.get(key), 'granted');
  assert.equal(h.window['ga-disable-G-CWT1FWEHCL'], false);
  assert.equal(effective(h.queue(), 'DE').analytics_storage, 'granted');
  const restored = harness({ value: h.storage.get(key) });
  assert.equal(effective(restored.queue(), 'DE').analytics_storage, 'granted');
  restored.click('analytics-settings');
  assert.equal(restored.nodes['analytics-consent'].hidden, false);
  assert.equal(restored.nodes['analytics-deny'].textContent, 'Withdraw consent');
  restored.click('analytics-deny');
  assert.equal(restored.storage.get(key), 'denied');
  assert.equal(restored.window['ga-disable-G-CWT1FWEHCL'], true);
  assert.equal(restored.nodes['analytics-settings'].attributes['aria-expanded'], 'false');
  assert.ok(restored.cookieWrites.length >= 6);
  assert.ok(restored.cookieWrites.every(x => x.startsWith('_ga') && x.includes('Max-Age=0')));
  assert.equal(effective(harness({ value: restored.storage.get(key) }).queue(), 'US').analytics_storage, 'denied');
});
test('write failure cannot undo current-page refusal; later storage/pageshow restores refusal', () => {
  const h = harness({ writeFails: true }); h.click('analytics-deny');
  assert.equal(h.window['ga-disable-G-CWT1FWEHCL'], true);
  assert.equal(effective(h.queue(), 'US').analytics_storage, 'denied');
  assert.equal(h.nodes['analytics-consent'].hidden, false);
  assert.match(h.nodes['analytics-status'].textContent, /Saving failed/);
  const other = harness({ value: 'granted' }); other.storage.set(key, 'denied');
  other.windows.storage({ key });
  assert.equal(other.window['ga-disable-G-CWT1FWEHCL'], true);
  assert.equal(effective(other.queue(), 'US').analytics_storage, 'denied');
  other.windows.pageshow({ persisted: true });
  assert.equal(effective(other.queue(), 'DE').analytics_storage, 'denied');
});
test('pre-existing browser opt-out beats a saved grant and cannot be overridden by allow', () => {
  const h = harness({ value: 'granted', preDisabled: true });
  assert.ok(h.queue().filter(x => x[0] === 'consent').every(x => x[2].analytics_storage === 'denied'));
  assert.equal(h.events[0].disabled, true);
  assert.equal(h.nodes['analytics-allow'].disabled, true);
  h.click('analytics-allow');
  assert.equal(h.window['ga-disable-G-CWT1FWEHCL'], true);
});
test('removing a saved grant fails closed on storage sync, including BFCache restoration', () => {
  const h = harness({ value: 'granted' }); h.storage.delete(key);
  h.windows.storage({ key });
  assert.equal(effective(h.queue(), 'DE').analytics_storage, 'denied');
  assert.equal(h.window['ga-disable-G-CWT1FWEHCL'], true);
  h.windows.pageshow({ persisted: true });
  assert.equal(effective(h.queue(), 'US').analytics_storage, 'denied');
});
test('no geography inferred from browser language; region list is complete and unique', () => {
  assert.equal(regions.length, 34); assert.equal(new Set(regions).size, 34);
  for (const lang of ['en', 'zh-CN']) {
    const h = harness({ lang });
    assert.equal(effective(h.queue(), 'DE').analytics_storage, 'denied');
    assert.equal(effective(h.queue(), 'US').analytics_storage, 'granted');
  }
});
test('canonical guard rejects missing or non-production targets', () => {
  for (const canonical of [null, 'https://example.invalid/']) assert.equal(harness({ canonical }).events.length, 0);
});
test('bilingual privacy describes advanced-mode traffic and persistent overrides', () => {
  const guide = readFileSync(new URL('../src/components/Guide.astro', import.meta.url), 'utf8');
  assert.ok(guide.includes('无 Cookie ping') && guide.includes('cookieless pings'));
  assert.ok(guide.includes('法律合规认证') && guide.includes('not legal certification'));
  assert.ok(!guide.includes('官网仅在你明确允许后加载'));
  assert.ok(!guide.includes('only after you explicitly allow it'));
});
test('built output: 60 routes, unchanged IndexNow, both privacy disclosures', { skip: !existsSync(new URL('../dist/', import.meta.url)) }, () => {
  const dist = new URL('../dist/', import.meta.url);
  function pages(path) { return readdirSync(path, { withFileTypes: true }).flatMap(x => x.isDirectory() ? pages(new URL(x.name+'/', path)) : x.name === 'index.html' ? [new URL(x.name,path)] : []); }
  assert.equal(pages(dist).length, 60);
  for (const page of pages(dist)) {
    const html = readFileSync(page, 'utf8');
    assert.ok(html.includes('consent\', \'default'));
    assert.ok(html.includes("ad_personalization: 'denied'"));
  }
  const verification = 'b52007745adc742dddf0852353e585f6';
  assert.equal(readFileSync(new URL(verification+'.txt', dist), 'utf8'), verification);
  assert.ok(readFileSync(new URL('privacy/index.html', dist), 'utf8').includes('无 Cookie ping'));
  assert.ok(readFileSync(new URL('en/privacy/index.html', dist), 'utf8').includes('cookieless pings'));
});
