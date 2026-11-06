import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import { createHash } from 'node:crypto';

// SYNTHETIC_EXAMPLE: metadata and original-source fingerprints, not a JS reimplementation of APNs.
const sourceFragments = {"struct CollieRadarNotificationEvent:": {"path": "Apps/Collie/CollieRadarModel.swift", "sha256": "b9da34a7fa41dce17ffb69f611a35859f4695a9a80a71a79446fa0e6042b4894"}, "struct CollieNativeNotificationPayload:": {"path": "Apps/Collie/CollieNativeNotifications.swift", "sha256": "3219be7e245697f1275c6eacc66b0d46d19fa98005dd3e1a635e0e0615e1ada9"}, "enum CollieConnectionOrigin": {"path": "Apps/Collie/CollieConnectionSettings.swift", "sha256": "a96c4d36c4c65cdb964eb63d75534d02ac44c8506e1dd2a1a517b6985ee759ab"}, "enum CollieNativeNotificationRoute": {"path": "Apps/Collie/CollieNativeNotifications.swift", "sha256": "4fd3949464638b8fceb3c97ac98f6e8e3b698d4a2f1bbc361630fe3545896e53"}, "    private func origin(for payload:": {"path": "Apps/Collie/CollieNativeNotifications.swift", "sha256": "f02b504a74077fb762d8ca55666bae3bc977bb37fc68e9194cd79877da312333"}, "    func handleNotification(payload:": {"path": "Apps/Collie/CollieNativeNotifications.swift", "sha256": "be09702d024524aab8d963027a3ad7ff51a0906243a7e5bda722bc8d8d531798"}, "    private func processPendingNotificationIfPossible()": {"path": "Apps/Collie/CollieNativeNotifications.swift", "sha256": "848134ef582199f182d27f3e094f91c598cabdae1df4df6e144d51493f33ee09"}, "    private func resolve(_ payload:": {"path": "Apps/Collie/CollieNativeNotifications.swift", "sha256": "7beb6ab4cee2a8cba05e7cc804ca1eccdf1f7a9ec2b1ebc013660496ffedf8bb"}, "    private func canonicalOrigin(": {"path": "Apps/Collie/CollieNativeNotifications.swift", "sha256": "0a375f3538f2544d611089f418273d36b1fe28fe038589d545c113e9cbe2449b"}, "    func isEnabled(for origin:": {"path": "Apps/Collie/CollieNativeNotifications.swift", "sha256": "243ac2217d0f125216a9c2569fc568bd0c8822421f8e15c9a8f9d23d52f83e39"}, "    private func originKey(": {"path": "Apps/Collie/CollieNativeNotifications.swift", "sha256": "90b059b1a16a678f5f4c624a5965d9a96f27fa282ce48cec6c4234b9625e58f5"}};
const root = fileURLToPath(new URL('../', import.meta.url));
const read = (p) => readFileSync(join(root, p), 'utf8');
const prefix = 'public/samples/p21-notification-payload-model/';
const fixture = (lang) => JSON.parse(read(`${prefix}preflight.${lang}.json`));
const active = 'notification-payload-model-preflight';
const retired = 'notification-disable-unregister-pending';
const canonical = 'https://getyihu.com/';
const page = (lang, slug) => `src/pages/${lang === 'en' ? 'en/' : ''}guides/${slug}.md`;
const route = (lang, slug) => `${lang === 'en' ? 'en/' : ''}guides/${slug}/`;
const resources = ['preflight.zh.json', 'preflight.en.json', 'preflight-card.md'];

test('P21: frozen descriptors bind to actual original decoder/route/pending source, not a mirrored notification engine', () => {
  for (const [name, f] of Object.entries(sourceFragments)) {
    const raw = read(`../${f.path}`); const start = raw.indexOf(name); assert.ok(start >= 0);
    let i = raw.indexOf('{', start) + 1; let depth = 1;
    while (depth) { if (raw[i] === '{') depth++; else if (raw[i] === '}') depth--; i++; }
    assert.equal(createHash('sha256').update(raw.slice(start, i)).digest('hex'), f.sha256, name);
  }
});

for (const lang of ['zh', 'en']) {
  test(`P21 ${lang}: two payload schemas, host routing and receipt levels are explicit synthetic descriptors`, () => {
    const j = fixture(lang);
    assert.equal(j.classification, 'SYNTHETIC_EXAMPLE'); assert.equal(j.batch, 'SYN-NTF-42'); assert.equal(j.language, lang);
    assert.equal(j.source_commit, 'c5387fa57bf996f8c0a4121bddbf9c7801321e57'); assert.equal(j.source_tree, '64615872797aae8252e2c7e10efe94e4a326871c');
    assert.equal(j.is_app_import_schema, false); assert.equal(j.is_production_capture, false); assert.deepEqual(Object.values(j.runtime_checks), Array(10).fill('not_run'));
    assert.equal(j.source_contract.radar_envelope, 'yihuRadar'); assert.equal(j.source_contract.native_envelope, 'collie');
    assert.equal(j.source_contract.native_path_utf8_max, 2048); assert.equal(j.source_contract.pending_seconds_exclusive, 300);
    assert.equal(j.source_contract.remote_delivery_proved, false); assert.equal(j.source_contract.registration_lookup_not_authentication, true);
    for (const [group, count] of [['radar_cases', 12], ['native_payload_cases', 12], ['route_cases', 15], ['navigation_cases', 16], ['boundary_reviews', 4]]) {
      assert.equal(j[group].length, count); assert.equal(new Set(j[group].map((x) => x.id)).size, count);
    }
    const radar = Object.fromEntries(j.radar_cases.map((x) => [x.id, x])); const native = Object.fromEntries(j.native_payload_cases.map((x) => [x.id, x]));
    assert.equal(radar.A2.accepted, false); assert.equal(radar.A10.accepted, false);
    assert.equal(native.P2.accepted, true); assert.equal(native.P11.accepted, true);
    assert.equal(native.P5.accepted, true); assert.equal(native.P6.accepted, true);
    assert.equal(native.P7.accepted, true); assert.equal(native.P8.accepted, false); assert.equal(native.P9.accepted, true); assert.equal(native.P10.accepted, false);
    const q = Object.fromEntries(j.navigation_cases.map((x) => [x.id, x]));
    assert.equal(q.Q2.expected.pending, true); assert.equal(q.Q3.expected.open_calls, 1); assert.equal(q.Q4.expected.open_calls, 0);
    assert.equal(q.Q7.expected.blocks, 1); assert.equal(q.Q8.expected.open_calls, 1); assert.equal(q.Q8.expected.callbacks, 0);
    assert.equal(q.Q10.expected.pending, true); assert.equal(q.Q11.expected.callbacks, 1);
    assert.equal(q.Q12.expected.open_calls, 0); assert.equal(q.Q13.expected.open_calls, 1);
    assert.equal(q.Q14.expected.open_calls, 0); assert.equal(q.Q15.expected.open_calls, 0);
    assert.ok(j.boundary_reviews.every((x) => x.runtime === 'not_run'));
  });
}

test('P21: translated labels preserve exact schema/route/pending machine expectations', () => {
  const normalize = (j) => { const v = structuredClone(j); delete v.language; for (const x of v.boundary_reviews) delete x.label; return v; };
  assert.deepEqual(normalize(fixture('zh')), normalize(fixture('en')));
});

test('P21: only active pair gets exactly3 public files and accessible branch table,180/150/30 intact', () => {
  const walk = (dir) => readdirSync(join(root, dir), { withFileTypes: true }).flatMap((x) => x.isDirectory() ? walk(`${dir}/${x.name}`) : [`${dir}/${x.name}`]);
  const pages = walk('src/pages').filter((p) => /\.(astro|md)$/.test(p)); assert.equal(pages.length, 180);
  assert.equal(pages.filter((p) => /^---\n[\s\S]*?\nindexable: false\n[\s\S]*?---/.test(read(p))).length, 30);
  assert.deepEqual(readdirSync(join(root, prefix)).sort(), [...resources].sort()); const sitemap = read('public/sitemap.xml'); assert.equal((sitemap.match(/<loc>/g) || []).length, 150);
  for (const lang of ['zh', 'en']) {
    const a = read(page(lang, active)); const r = read(page(lang, retired));
    assert.ok(!a.split('---')[1].includes('indexable: false')); assert.ok(r.split('---')[1].includes('indexable: false'));
    assert.ok(sitemap.includes(canonical + route(lang, active))); assert.ok(!sitemap.includes(canonical + route(lang, retired)));
    assert.ok(a.includes('SYNTHETIC_EXAMPLE') && a.includes('SYN-NTF-42') && a.includes('role="region"') && a.includes('tabindex="0"'));
    for (const name of resources) assert.ok(a.includes(`/samples/p21-notification-payload-model/${name}`));
    for (const group of ['radar_cases', 'native_payload_cases', 'route_cases', 'navigation_cases', 'boundary_reviews']) for (const row of fixture(lang)[group]) assert.ok(a.includes(`| ${row.id} |`));
    assert.ok(r.includes(`](/${route(lang, active)})`)); assert.ok(!r.includes('/samples/p21-notification-payload-model/'));
  }
});

test('P21: rebuilt samples and original LLM exports discover active URLs, never retired standalone sections', { skip: !existsSync(join(root, 'dist/index.html')) }, () => {
  for (const name of resources) assert.equal(read(`dist/samples/p21-notification-payload-model/${name}`), read(`${prefix}${name}`));
  const short = read('public/llms.txt'); const full = read('public/llms-full.txt'); assert.equal((full.match(/^Canonical: https:\/\/getyihu\.com\//gm) || []).length, 150);
  for (const lang of ['zh', 'en']) {
    const html = read(`dist/${route(lang, active)}index.html`); for (const name of resources) assert.ok(html.includes(`/samples/p21-notification-payload-model/${name}`));
    for (const text of [short, full]) assert.ok(text.includes(`/samples/p21-notification-payload-model/preflight.${lang}.json`));
    assert.ok(full.includes(`Canonical: ${canonical}${route(lang, active)}\n`)); assert.ok(!full.includes(`Canonical: ${canonical}${route(lang, retired)}\n`));
    assert.ok(!short.includes(`](${canonical}${route(lang, retired)})\n`)); const retiredHtml = read(`dist/${route(lang, retired)}index.html`);
    assert.ok(retiredHtml.includes('noindex,follow')); assert.ok(!retiredHtml.includes('/samples/p21-notification-payload-model/'));
  }
});
