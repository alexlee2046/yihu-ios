import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { execFileSync } from 'node:child_process';

const root = new URL('../', import.meta.url);
const read = path => readFileSync(new URL(path, root), 'utf8');
const built = existsSync(new URL('dist/index.html', root));
const slugs = ['voice-workbench-vs-radio-chat', 'outdoor-store-voice-preflight'];
const deepSlugs = ['bluetooth-audio-input-troubleshooting', 'offline-workbench-handoff-troubleshooting', 'meeting-notes-brief-fields'];
const wave6Slugs = ['web-read-aloud-microphone-boundaries', 'multi-note-review-handoff', 'radar-json-null-validation'];
const wave7Slugs = ['first-trial-go-no-go-checklist', 'recording-segment-review-labels', 'radar-snapshot-batch-comparison'];
const wave8Slugs = ['noisy-transcript-text-correction', 'department-minutes-ownership-archive', 'radar-evidence-second-check'];
const wave9Slugs = ['brief-format-change-compatibility', 'degraded-handoff-go-no-go', 'handoff-evidence-audit-checklist'];
const wave10Slugs = ['cross-device-field-presentation', 'audio-route-recovery-matrix', 'followup-evidence-minimization'];
const wave11Slugs = ['follow-up-context-preflight', 'radar-summary-claim-provenance', 'vehicle-exhibition-microphone-preflight'];
const wave12Slugs = ['multilingual-terms-preflight', 'timezone-timestamp-review', 'carrier-redaction-archive-matrix'];
const wave13Slugs = ['export-encoding-delimiter-preflight', 'microphone-permission-sample-contract', 'batch-change-record-retention'];
const wave14Slugs = ['empty-field-display-defaults', 'foreground-audio-rebind-preflight', 'multi-role-approval-receipt-checklist'];
const wave15Slugs = ["share-batch-item-preflight","interruption-recapture-preflight","history-retrieval-manual-comparison"];
const wave16Slugs = ["notification-payload-model-preflight","pcm-format-admission-review","reply-request-receipt-mapping"];
const wave17Slugs = ["evidence-link-admission-preflight","capture-buffer-pressure-checklist","note-audio-text-evidence-mapping"];
const wave18Slugs = ["radar-feed-url-boundary-preflight","near-field-policy-route-review","note-segment-join-provenance"];
const wave19Slugs = ["reply-transport-budget-preflight","voiceprint-filter-not-authorization","status-alias-approval-boundaries"];
const wave20Slugs = ["history-reference-integrity-review","capture-completion-token-review","reply-draft-restoration-scope"];
const wave21Slugs = ["source-switch-cache-isolation","audio-level-not-accuracy-review","note-removal-retention-boundaries"];
const wave22Slugs = ["note-radar-draft-candidate-preflight","audio-recovery-debounce-boundaries","local-file-protection-scope"];
const wave23Slugs = ["attention-filter-identity-boundaries","pcm-stream-end-boundaries","share-manifest-visibility-review"];
const wave24Slugs = ["workbench-origin-page-boundaries","replaceable-voice-preview-review","model-artifact-validation-evidence"];
const wave25Slugs = ["host-bridge-outcome-boundaries","audio-busy-state-admission","history-generation-receipt-priority"];
const wave26Slugs = ["keyboard-acknowledgement-scope","note-transcription-retry-checkpoint","privacy-declaration-evidence-scope"];
const wave27Slugs = ["file-chunk-bridge-not-upload-receipt","recognition-pass-parameter-budget","attachment-name-metadata-provenance"];
const wave28Slugs = ["focused-editable-admission-review","recognition-error-layer-review","list-preview-not-transcript-archive"];
const wave29Slugs = ["navigation-cancel-process-reload-boundaries","watch-voice-queued-ready-boundaries","app-group-inbox-access-evidence"];
const wave30Slugs = ["watch-open-request-ui-boundaries","shortcut-toggle-request-lifetime","note-organization-prompt-not-minutes"];
const wave31Slugs = ["reminder-link-pending-origin-routing","voiceprint-enrollment-profile-version-review","notification-disable-unregister-pending"];
const bots = ['OAI-SearchBot', 'ChatGPT-User', 'PerplexityBot', 'ClaudeBot', 'Claude-SearchBot', 'Google-Extended', 'Applebot-Extended'];
const urls = Array.from(read('public/sitemap.xml').matchAll(/<loc>([^<]+)<\/loc>/g), x => x[1]);
const page = url => 'dist/' + url.replace('https://getyihu.com/', '') + 'index.html';

const retired = new Set(["shortcut-toggle-request-lifetime","notification-disable-unregister-pending","reminder-link-pending-origin-routing","capture-completion-token-review","watch-voice-queued-ready-boundaries","watch-open-request-ui-boundaries","navigation-cancel-process-reload-boundaries","audio-recovery-debounce-boundaries","recognition-pass-parameter-budget","focused-editable-admission-review","pcm-stream-end-boundaries","model-artifact-validation-evidence","app-group-inbox-access-evidence","attention-filter-identity-boundaries","followup-evidence-minimization"]);
test('150 indexable URLs retain guides except 30 approved technical-reference routes', () => {
  assert.equal(urls.length, 150); assert.equal(new Set(urls).size, 150);
  for (const slug of [...slugs, ...deepSlugs, ...wave6Slugs, ...wave7Slugs, ...wave8Slugs, ...wave9Slugs, ...wave10Slugs, ...wave11Slugs, ...wave12Slugs, ...wave13Slugs, ...wave14Slugs, ...wave15Slugs, ...wave16Slugs, ...wave17Slugs, ...wave18Slugs, ...wave19Slugs, ...wave20Slugs, ...wave21Slugs, ...wave22Slugs, ...wave23Slugs, ...wave24Slugs, ...wave25Slugs, ...wave26Slugs, ...wave27Slugs, ...wave28Slugs, ...wave29Slugs, ...wave30Slugs, ...wave31Slugs]) for (const prefix of ['', 'en/']) assert.equal(urls.includes(`https://getyihu.com/${prefix}guides/${slug}/`), !retired.has(slug));
});
test('seven explicit bot groups and general allow retain sitemap and LLM reference', () => {
  const robots = read('public/robots.txt');
  const groups = robots.split(/\n\s*\n/).filter(x => x.includes('User-agent:'));
  for (const bot of ['*', ...bots]) {
    const group = groups.find(x => x.split('\n').includes('User-agent: ' + bot));
    assert.ok(group, bot); assert.ok(group.split('\n').includes('Allow: /'), bot);
  }
  assert.ok(robots.includes('Sitemap: https://getyihu.com/sitemap.xml'));
  assert.ok(robots.includes('# LLMs: https://getyihu.com/llms.txt'));
});
test('static LLM references cover every bilingual canonical URL and factual topic boundaries', () => {
  for (const name of ['llms.txt', 'llms-full.txt']) {
    const text = read('public/' + name);
    assert.ok(Buffer.byteLength(text) > 8192, name);
    for (const url of urls) assert.ok(text.includes(url), name + ': ' + url);
    for (const term of ['Bluetooth', 'AirPods', 'Apple Watch', 'Offline', 'meeting', 'Foreign-trade', 'FAQ']) assert.ok(text.includes(term), term);
    assert.ok(!text.includes('https://apps.apple.com/'), 'no invented App Store identity');
  }
  assert.ok(read('public/llms-full.txt').includes('<table'));
});
test('source-only schema leaves no fabricated app-store or search endpoint', () => {
  const layout = read('src/layouts/Layout.astro');
  assert.ok(layout.includes("'@type': 'Organization'"));
  assert.ok(layout.includes("'@type': 'WebSite'"));
  assert.ok(!layout.includes('apps.apple.com'));
  assert.ok(!layout.includes('SearchAction'));
});
test('built homepage graph keeps existing software/FAQ plus organization and website', { skip: !built }, () => {
  for (const prefix of ['', 'en/']) {
    const html = read('dist/' + prefix + 'index.html');
    const scripts = Array.from(html.matchAll(/<script\b[^>]*type="application\/ld\+json"[^>]*>([\s\S]*?)<\/script>/g), x => JSON.parse(x[1]));
    const graph = scripts.flat();
    assert.equal(graph.length, 4);
    for (const type of ['SoftwareApplication', 'FAQPage', 'Organization', 'WebSite']) assert.equal(graph.filter(x => x['@type'] === type).length, 1);
    const organization = graph.find(x => x['@type'] === 'Organization');
    assert.equal(organization['@id'], 'https://getyihu.com/#organization');
    assert.deepEqual(organization.sameAs, ['https://github.com/alexlee2046/yihu-ios']);
    for (const type of ['SoftwareApplication', 'WebSite']) assert.equal(graph.find(x => x['@type'] === type).publisher['@id'], organization['@id']);
    for (const slug of ['iphone-agent-voice-drafts', 'bluetooth-audio-input-troubleshooting', 'recording-notes-handoff', 'multi-project-radar-watch']) assert.ok(html.includes(`href="/${prefix}guides/${slug}/"`));
  }
});
test('all 150 indexable pages have valid canonical/language pairs; new guides have table, first answer and FAQ', { skip: !built }, () => {
  for (const url of urls) {
    const html = read(page(url));
    assert.ok(html.includes(`<link rel="canonical" href="${url}"`), url);
    const zh = url.replace('https://getyihu.com/en/', 'https://getyihu.com/');
    const en = zh.replace('https://getyihu.com/', 'https://getyihu.com/en/');
    for (const [lang, href] of [['zh-CN', zh], ['en', en]]) assert.ok(html.includes(`hreflang="${lang}" href="${href}"`), url);
    if (!slugs.some(slug => url.includes(slug))) continue;
    assert.equal(Array.from(html.matchAll(/<h1\b/g)).length, 1);
    assert.ok(html.includes('id="first-answer"'));
    assert.equal(Array.from(html.matchAll(/id="faq-[^"]+"/g)).length, 4);
    assert.ok(html.includes('<table') && html.includes('<thead>') && html.includes('<tbody>'));
    assert.ok(html.includes('tabindex="0"'));
    const home = url.includes('/en/') ? '/en/' : '/';
    assert.ok(html.includes(`href="${home}privacy/"`) && html.includes(`href="${home}start/"`));
    for (const slug of slugs) assert.ok(html.includes(`href="${home}guides/${slug}/"`) || url.includes(slug));
  }
});
test('six Wave5 pages have reviewable content, FAQs, tables, source evidence and inbound links', { skip: !built }, () => {
  for (const prefix of ['', 'en/']) {
    const home = read('dist/' + prefix + 'index.html');
    for (const slug of deepSlugs) {
      assert.ok(home.includes('id="scenarios"'));
      const html = read('dist/' + prefix + 'guides/' + slug + '/index.html');
      assert.ok(html.includes('id="first-answer"'));
      assert.equal(Array.from(html.matchAll(/id="faq-[^"]+"/g)).length, 4);
      assert.ok(html.includes('<table') && html.includes('<thead>') && html.includes('<tbody>'));
      assert.ok(html.includes('tabindex="0"'));
      assert.ok(html.includes('github.com/alexlee2046/yihu-ios/blob/a59676a'));
      assert.ok(html.includes(`href="/${prefix}start/"`) && html.includes(`href="/${prefix}privacy/"`));
      assert.ok(html.includes(`href="/${prefix}guides/recording-notes-handoff/"`));
      assert.equal(Array.from(html.matchAll(/<h1\b/g)).length, 1);
    }
    const brief = read('dist/' + prefix + 'guides/meeting-notes-brief-fields/index.html');
    for (const field of prefix ? ['Decision', 'Action', 'Owner', 'Date', 'Open question'] : ['结论', '行动项', '负责人', '时间', '待确认问题']) assert.ok(brief.includes(field));
    assert.ok(brief.includes(prefix ? 'not an app import format' : '不是App导入格式'));
    const offline = read('dist/' + prefix + 'guides/offline-workbench-handoff-troubleshooting/index.html');
    for (const field of prefix ? ['Keep the original', 'source time', 'same request'] : ['保留原文', '来源时间', '同一次请求']) assert.ok(offline.includes(field));
  }
});
test('LLM static copies ship unchanged in dist, and full content matches the built site', { skip: !built }, () => {
  for (const file of ['llms.txt', 'llms-full.txt', 'robots.txt', 'sitemap.xml']) assert.equal(read('dist/' + file), read('public/' + file));
  execFileSync('python3', ['tools/export-llms.py', '--check'], { cwd: new URL('../', import.meta.url), stdio: 'pipe' });
});
