import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import { createHash } from 'node:crypto';

// SYNTHETIC_EXAMPLE. Ledger/category checks below are external manual worksheet rules,
// not App ASR timing, clinical detection or diagnosis functionality.
const sourceFragments = {"enum CollieNoteSegmenter": {"path": "Apps/Collie/CollieVoiceNotes.swift", "sha256": "106475513e00f5b418eb26fb7307ddeb2624997953a134ceb39dee38e04b771e"}, "    func reserveHandOff(_ id:": {"path": "Apps/Collie/CollieVoiceNotes.swift", "sha256": "351a51d038fbc99f6c2550917705bd586fd78adc4ecde3fd1f213f11e9fa6d40"}, "    func handOff(_ note:": {"path": "Apps/Collie/CollieVoiceNotes.swift", "sha256": "07d66c19bf46215a697446a71e135d26e304fdad0ed5361fa34cdb412eca9ead"}, "complete_note": {"path": "Apps/Collie/CollieVoiceNote.swift", "sha256": "419e3aad9564d54fc38d2a8571ae40e80586632a9437dd2ea9d1f51631f1a08b"}};
const root = fileURLToPath(new URL('../', import.meta.url));
const read = (p) => readFileSync(join(root, p), 'utf8');
const prefix = 'public/samples/p20-recording-notes-handoff/';
const fixture = (lang) => JSON.parse(read(`${prefix}preflight.${lang}.json`));
const active = 'recording-notes-handoff';
const retired = 'watch-open-request-ui-boundaries';
const canonical = 'https://getyihu.com/';
const page = (lang, slug) => `src/pages/${lang === 'en' ? 'en/' : ''}guides/${slug}.md`;
const route = (lang, slug) => `${lang === 'en' ? 'en/' : ''}guides/${slug}/`;
const resources = ['preflight.zh.json', 'preflight.en.json', 'preflight-card.md'];

test('P20: exact original note/segmenter/reservation/handoff fragments remain bound to source, not reimplemented ASR', () => {
  for (const [name, f] of Object.entries(sourceFragments)) {
    const raw = read(`../${f.path}`); let text;
    if (name === 'complete_note') text = raw;
    else {
      const start = raw.indexOf(name); assert.ok(start >= 0);
      let i = raw.indexOf('{', start) + 1; let depth = 1;
      while (depth) { if (raw[i] === '{') depth++; else if (raw[i] === '}') depth--; i++; }
      text = raw.slice(start, i);
    }
    assert.equal(createHash('sha256').update(text).digest('hex'), f.sha256, name);
  }
});

function ledgerReview(rows) {
  let prior;
  for (const row of rows) {
    const { start_frame: start, end_frame: end } = row;
    if (!Number.isInteger(start) || !Number.isInteger(end) || start < 0 || end <= start) return 'reject_interval';
    if (prior !== undefined && start > prior) return 'review_gap';
    if (prior !== undefined && start < prior) return 'review_overlap';
    prior = end;
  }
  return 'structurally_contiguous_not_verified_alignment';
}
function manualExclusion(category) {
  return new Set(['diagnosis_request', 'prescription_or_treatment_order', 'uncertain_clinical_inference_from_transcript']).has(category) ? 'excluded_medical_decision' : 'human_fact_review_only';
}

for (const lang of ['zh', 'en']) {
  test(`P20 ${lang}: synthetic note/segment/handoff metadata never implies generated minutes or clinical authority`, () => {
    const j = fixture(lang);
    assert.equal(j.classification, 'SYNTHETIC_EXAMPLE'); assert.equal(j.batch, 'SYN-REC-41'); assert.equal(j.language, lang);
    assert.equal(j.source_commit, '6e8dc35d713b418e2d8e6b256e887cb9a237f104'); assert.equal(j.source_tree, '1ae994ef9e4a2e3ba83252929bf45c6f8278eee4');
    assert.equal(j.is_app_import_schema, false); assert.equal(j.is_production_capture, false);
    assert.deepEqual(Object.values(j.runtime_checks), Array(10).fill('not_run'));
    assert.equal(j.source_contract.sample_rate, 16000); assert.equal(j.source_contract.max_window_frames, 448000);
    assert.equal(j.source_contract.segment_timestamps_persisted_by_note, false); assert.equal(j.source_contract.speaker_diarization_proved, false);
    assert.equal(j.source_contract.minutes_prompt_is_not_generated_minutes, true); assert.equal(j.source_contract.automatic_medical_filter_in_app_proved, false);
    assert.equal(j.review_ledger_contract.kind, 'external_manual_worksheet_not_App_export'); assert.equal(j.review_ledger_contract.alignment, 'not_run');
    for (const [group, count] of [['segment_cases', 8], ['join_cases', 8], ['handoff_cases', 11], ['external_ledger_cases', 5], ['manual_exclusion_cases', 4]]) {
      assert.equal(j[group].length, count); assert.equal(new Set(j[group].map((x) => x.id)).size, count);
    }
    const h = Object.fromEntries(j.handoff_cases.map((x) => [x.mode, x]));
    assert.equal(h.exact3000.expected.material, 'text'); assert.equal(h.over3000.expected.material, 'markdown');
    assert.equal(h.inbox_fail.expected.reserved, true); assert.equal(h.inbox_fail.expected.success, false);
    assert.equal(h.reserve_write_fail.expected.reserved, false); assert.equal(h.whitespace.expected.success, true);
    assert.equal(j.segment_cases.find((x) => x.mode === 'equal_energy').expected_keep, 320800);
    assert.equal(j.join_cases.find((x) => x.existing === 'Note.').expected, 'Note.Next');
  });
  test(`P20 ${lang}: independent review worksheet detects supplied-frame gaps and excludes requested medical decisions, not arbitrary transcript classification`, () => {
    const j = fixture(lang);
    for (const x of j.external_ledger_cases) assert.equal(ledgerReview(x.segments), x.expected, x.id);
    const sample = j.external_ledger_cases[0].segments;
    assert.equal(sample[0].start_frame / 16000, 0); assert.equal(sample[1].end_frame / 16000, 48);
    assert.ok(sample.every((x) => x.speaker === 'unknown'));
    for (const x of j.manual_exclusion_cases) assert.equal(manualExclusion(x.category), x.expected, x.id);
    assert.ok(j.manual_exclusion_cases.filter((x) => x.category !== 'ordinary_meeting_minutes').every((x) => x.expected === 'excluded_medical_decision'));
  });
}

test('P20: Chinese and English keep identical machine facts and manual boundaries', () => {
  const a = structuredClone(fixture('zh')); const b = structuredClone(fixture('en')); delete a.language; delete b.language; assert.deepEqual(a, b);
});

test('P20: true source-page paths and original preview metadata preserved, only active receives3 resources, exact180/150/30', () => {
  const walk = (dir) => readdirSync(join(root, dir), { withFileTypes: true }).flatMap((x) => x.isDirectory() ? walk(`${dir}/${x.name}`) : [`${dir}/${x.name}`]);
  const pages = walk('src/pages').filter((p) => /\.(astro|md)$/.test(p)); assert.equal(pages.length, 180);
  assert.equal(pages.filter((p) => /^---\n[\s\S]*?\nindexable: false\n[\s\S]*?---/.test(read(p))).length, 30);
  assert.deepEqual(readdirSync(join(root, prefix)).sort(), [...resources].sort());
  const sitemap = read('public/sitemap.xml'); assert.equal((sitemap.match(/<loc>/g) || []).length, 150);
  for (const lang of ['zh', 'en']) {
    const a = read(page(lang, active)); const r = read(page(lang, retired));
    assert.ok(!a.split('---')[1].includes('indexable: false')); assert.ok(a.split('---')[1].includes('preview: voice') && a.split('---')[1].includes('voiceSample: meeting'));
    assert.ok(r.split('---')[1].includes('indexable: false'));
    assert.ok(sitemap.includes(canonical + route(lang, active))); assert.ok(!sitemap.includes(canonical + route(lang, retired)));
    assert.ok(a.includes('SYNTHETIC_EXAMPLE') && a.includes('SYN-REC-41') && a.includes('role="region"') && a.includes('tabindex="0"'));
    for (const name of resources) assert.ok(a.includes(`/samples/p20-recording-notes-handoff/${name}`));
    for (const group of ['segment_cases', 'join_cases', 'handoff_cases', 'external_ledger_cases', 'manual_exclusion_cases']) for (const row of fixture(lang)[group]) assert.ok(a.includes(`| ${row.id} |`));
    assert.ok(r.includes(`](/${route(lang, active)})`)); assert.ok(!r.includes('/samples/p20-recording-notes-handoff/'));
  }
});

test('P20: built samples and regenerated LLMs include actual active URLs, not retired independent exports', { skip: !existsSync(join(root, 'dist/index.html')) }, () => {
  for (const name of resources) assert.equal(read(`dist/samples/p20-recording-notes-handoff/${name}`), read(`${prefix}${name}`));
  const short = read('public/llms.txt'); const full = read('public/llms-full.txt'); assert.equal((full.match(/^Canonical: https:\/\/getyihu\.com\//gm) || []).length, 150);
  for (const lang of ['zh', 'en']) {
    const html = read(`dist/${route(lang, active)}index.html`); for (const name of resources) assert.ok(html.includes(`/samples/p20-recording-notes-handoff/${name}`));
    for (const text of [short, full]) assert.ok(text.includes(`/samples/p20-recording-notes-handoff/preflight.${lang}.json`));
    assert.ok(full.includes(`Canonical: ${canonical}${route(lang, active)}\n`)); assert.ok(!full.includes(`Canonical: ${canonical}${route(lang, retired)}\n`));
    assert.ok(!short.includes(`](${canonical}${route(lang, retired)})\n`)); const retiredHtml = read(`dist/${route(lang, retired)}index.html`);
    assert.ok(retiredHtml.includes('noindex,follow')); assert.ok(!retiredHtml.includes('/samples/p20-recording-notes-handoff/'));
  }
});
