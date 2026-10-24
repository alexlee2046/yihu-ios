import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { runInNewContext } from 'node:vm';
import ts from 'typescript';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const built = existsSync(new URL('dist/index.html', root));
const core = ['iphone-agent-voice-drafts','bluetooth-audio-input-troubleshooting','recording-notes-handoff','multi-project-radar-watch'];
const retired = { 'model-artifact-validation-evidence':core[0], 'app-group-inbox-access-evidence':core[0], 'attention-filter-identity-boundaries':core[3], 'followup-evidence-minimization':core[3], 'capture-completion-token-review':core[1] };
const landings = { 'audio-route-recovery-matrix':core[1], 'noisy-transcript-text-correction':core[2] };

test('P2 five reference pairs remain accessible and point to the appropriate buyer scenario', { skip: !built }, () => {
  const sitemap=read('public/sitemap.xml');assert.equal([...sitemap.matchAll(/<loc>/g)].length,150);
  for(const prefix of ['', 'en/']) for(const [slug,pillar] of Object.entries(retired)) {
    const url='https://getyihu.com/'+prefix+'guides/'+slug+'/';
    const html=read('dist/'+prefix+'guides/'+slug+'/index.html');
    assert.ok(html.includes('content="noindex,follow"'));assert.ok(html.includes('rel="canonical" href="'+url+'"'));
    assert.ok(!html.includes('hreflang='));assert.ok(!sitemap.includes(url));
    for(const file of ['llms.txt','llms-full.txt']) assert.ok(!read('public/'+file).includes(url));
    const context=html.match(/<nav class="guide-context"[\s\S]*?<\/nav>/)?.[0];
    assert.ok(context?.includes('href="/'+prefix+'guides/'+pillar+'/"'),slug);
  }
});
test('four practical landing pages put a single lightweight self-check before the long answer', { skip: !built }, () => {
  for(const prefix of ['', 'en/']) for(const [slug,destination] of Object.entries(landings)) {
    const html=read('dist/'+prefix+'guides/'+slug+'/index.html');
    assert.equal([...html.matchAll(/<section\b[^>]*\bdata-guide-quick-check\b/g)].length,1);
    assert.ok(html.indexOf('<h1')<html.indexOf('data-guide-quick-check'));
    assert.ok(html.indexOf('data-guide-quick-check')<html.indexOf('id="first-answer"'));
    assert.ok(!html.includes('<astro-island'),'do not mount a second heavy preview on a help landing');
    assert.match(html,/<select[^>]*id="quick-check-choice"[^>]*disabled/);
    assert.ok(html.includes('for="quick-check-choice"'));assert.ok(html.includes('role="status"'));
    assert.ok(html.includes('href="/'+prefix+'guides/'+destination+'/#interactive-preview"'));
    for(const pillar of core) {
      assert.ok(html.includes('href="/'+prefix+'guides/'+pillar+'/#interactive-preview"'));
      const target=read('dist/'+prefix+'guides/'+pillar+'/index.html');
      assert.equal([...target.matchAll(/id="interactive-preview"/g)].length,1);
      assert.equal([...target.matchAll(/data-preview=/g)].length,1);
    }
    assert.ok(html.includes('<noscript>'));assert.ok(!html.includes('data-contact-chat'));
  }
});
test('the local picker uses text-only scoped DOM state, including restored choices, without tracking or permissions', () => {
  const component=read('src/components/GuideQuickCheck.astro');
  const source=component.match(/<script>([\s\S]*?)<\/script>/)[1];
  for(const forbidden of ['localStorage','sessionStorage','fetch(','XMLHttpRequest','sendBeacon','gtag','trackPreviewEvent','getUserMedia','requestDevice','speechSynthesis','innerHTML']) assert.ok(!source.includes(forbidden),forbidden);
  const pageshow=[];
  const nodes=['zh','en'].map(lang=>{
    const result={textContent:lang+' initial'};
    const select={disabled:true,selectedOptions:[{dataset:{}}],addEventListener(name,fn){assert.equal(name,'change');this.change=fn;}};
    return {select,result,querySelector(selector){return selector==='select'?select:result;}};
  });
  const code=ts.transpileModule(source,{compilerOptions:{target:ts.ScriptTarget.ES2022,module:ts.ModuleKind.None}}).outputText;
  runInNewContext(code,{document:{querySelectorAll(){return nodes;}},window:{addEventListener(name,fn){assert.equal(name,'pageshow');pageshow.push(fn);}}});
  for(const n of nodes)assert.equal(n.select.disabled,false);
  nodes[0].select.selectedOptions=[{dataset:{advice:'<b>synthetic next step</b>'}}];nodes[0].select.change();
  assert.equal(nodes[0].result.textContent,'<b>synthetic next step</b>');assert.equal(nodes[1].result.textContent,'en initial');
  nodes[1].select.selectedOptions=[{dataset:{advice:'restored choice'}}];for(const fn of pageshow)fn();
  assert.equal(nodes[1].result.textContent,'restored choice');
  nodes[0].select.selectedOptions=[{dataset:{}}];nodes[0].select.change();assert.equal(nodes[0].result.textContent,'zh initial');
});
test('new landing UI does not expand the four-field preview event or the contact/consent contract', () => {
  const events=read('src/lib/preview-events.ts');
  for(const slug of Object.keys(landings))assert.ok(!events.includes(slug),'existing preview-only event allowlist unchanged');
  const component=read('src/components/GuideQuickCheck.astro');
  assert.ok(component.includes('not a measured user result'));assert.ok(component.includes('未作为真人耗时实测'));
  assert.ok(!component.includes('PUBLIC_'));assert.ok(!component.includes('chatwoot'));
});
test('practical first answers tell users what to check instead of opening with capture internals', { skip: !built }, () => {
  for(const prefix of ['', 'en/']) for(const slug of Object.keys(landings)) {
    const html=read('dist/'+prefix+'guides/'+slug+'/index.html');
    const answer=html.match(/id="first-answer"[^>]*>[^<]*<\/h2>\s*<p>([\s\S]*?)<\/p>/)?.[1];assert.ok(answer,slug);
    assert.ok(!/activeToken|PCM|writer|pipeline|retarget|源码分支|管线|去抖/.test(answer));
    assert.ok(html.includes('href="/'+prefix+'start/"'));
  }
});
