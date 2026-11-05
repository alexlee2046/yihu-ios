import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const dir = 'public/samples/p14-pcm-admission/';
const fixtures = ['zh', 'en'].map(lang => JSON.parse(read(dir + `pcm-admission-preflight.${lang}.json`)));

// This is a SYNTHETIC_EXAMPLE declaration worksheet, NOT an app/raw PCM decoder.
// Rate/endian comparisons require independently known producer fixture metadata.
function declarationErrors(c) {
  const errors = [];
  const bits = { s16le: 16, f32le: 32 }[c.encoding];
  if (!bits || bits !== c.declared_bit_depth) errors.push('encoding_bit_depth');
  if (c.declared_byte_order !== 'little' || c.producer_fixture_byte_order !== 'little') errors.push('byte_order');
  if (![16000, 24000, 48000].includes(c.declared_rate_hz) || c.declared_rate_hz !== c.producer_fixture_rate_hz) errors.push('rate_declaration');
  assert.ok(Number.isInteger(c.channels) && c.channels >= 1 && c.channels <= 2);
  assert.match(c.payload_hex, /^(?:[a-f0-9]{2})*$/);
  const frameBytes = c.channels * ((bits ?? 0) / 8);
  const aligned = frameBytes > 0 && Buffer.from(c.payload_hex, 'hex').length % frameBytes === 0;
  if (!aligned) errors.push('frame_alignment');
  if (c.stream_closed && c.explicit_end_marker !== 'explicit_eof') errors.push('closed_without_eof');
  if (!c.stream_closed && c.explicit_end_marker === 'explicit_eof') errors.push('premature_eof');
  if (c.tail_policy === 'synthetic_whole_silence_frames') {
    assert.ok(Number.isInteger(c.silence_padding_frames) && c.silence_padding_frames >= 0);
    if (!aligned) errors.push('padding_over_partial_frame');
  }
  return errors;
}
for (const f of fixtures) {
  test(`P14 ${f.language} SYNTHETIC_EXAMPLE declarations retain all intended positive/negative cases`, () => {
    assert.equal(f.case_id, 'SYN-PCM-36');
    assert.equal(f.classification, 'SYNTHETIC_EXAMPLE');
    assert.equal(f.is_app_import_schema, false);
    assert.equal(f.is_production_capture, false);
    assert.equal(f.observed_audio, null);
    assert.equal(f.observed_transcript, null);
    assert.equal(f.metadata_cases.length, 14);
    assert.equal(f.native_guard_cases.length, 7);
    assert.equal(f.stream_cases.length, 4);
    for (const c of f.metadata_cases) assert.deepEqual(declarationErrors(c), c.expected_errors, c.id);
    for (const v of Object.values(f.runtime_checks)) assert.equal(v, 'not_run');
    assert.deepEqual(f.source_native_contract.input_rate_hz_inclusive, [8000, 192000]);
    assert.equal(f.source_native_contract.interleaved, false);
    assert.equal(f.source_native_contract.output_rate_hz, 16000);
  });
}
test('P14 language variants keep identical machine conditions, no invented byte repair or real SLA', () => {
  for (const field of ['metadata_cases', 'native_guard_cases', 'stream_cases']) assert.deepEqual(fixtures[0][field], fixtures[1][field]);
  const card = read(dir + 'preflight-card.md');
  for (const x of ['SYNTHETIC_EXAMPLE', 'not_run', 's16le', 'f32le', 'noDataNow', 'endOfStream', '16']) assert.ok(card.includes(x));
  assert.ok(card.includes('不是新增App') && card.includes('not an app importer'));
});
const built = existsSync(new URL('dist/index.html', root));
test('P14 two active download/table regions and two retired forward-only regions retain150/30', () => {
  const sitemap = read('public/sitemap.xml');
  assert.equal([...sitemap.matchAll(/<loc>/g)].length, 150);
  for (const pre of ['', 'en/']) {
    const active = read(`src/pages/${pre}guides/pcm-format-admission-review.md`);
    const retired = read(`src/pages/${pre}guides/pcm-stream-end-boundaries.md`);
    assert.ok(!active.split('---')[1].includes('indexable: false'));
    assert.ok(retired.split('---')[1].includes('indexable: false'));
    assert.ok(sitemap.includes(`https://getyihu.com/${pre}guides/pcm-format-admission-review/`));
    assert.ok(!sitemap.includes(`https://getyihu.com/${pre}guides/pcm-stream-end-boundaries/`));
    assert.ok(active.includes('id="syn-pcm-36"') && active.includes('<table>'));
    const added = retired.split('## SYN-PCM-36')[1];
    assert.ok(added && !added.includes('/samples/'));
    assert.ok(added.includes(`/${pre}guides/pcm-format-admission-review/#syn-pcm-36`));
  }
});
test('P14 built content and both generated LLM files expose synthetic resources, not retired routes', { skip: !built }, () => {
  for (const [pre, lang] of [['', 'zh'], ['en/', 'en']]) {
    const active = read(`dist/${pre}guides/pcm-format-admission-review/index.html`);
    const retired = read(`dist/${pre}guides/pcm-stream-end-boundaries/index.html`);
    const jsonPath = `/samples/p14-pcm-admission/pcm-admission-preflight.${lang}.json`;
    assert.ok(active.includes(`href="${jsonPath}"`) && active.includes('download'));
    assert.ok(retired.includes('name="robots" content="noindex,follow"'));
    assert.ok(!active.includes('name="robots" content="noindex,follow"'));
    for (const name of ['llms.txt', 'llms-full.txt']) {
      const text = read('public/' + name);
      assert.ok(text.includes(jsonPath), name + ' keeps resource discovery within original short/full export contract');
      assert.ok(!text.includes(`Canonical: https://getyihu.com/${pre}guides/pcm-stream-end-boundaries/`));
    }
    assert.deepEqual(read(`dist${jsonPath}`), read(dir + `pcm-admission-preflight.${lang}.json`));
  }
});
