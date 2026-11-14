import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8');
const slugs = ['followup-evidence-minimization', 'history-retrieval-manual-comparison', 'handoff-evidence-audit-checklist'];
const store = JSON.parse(read('src/data/app-store.json'));

for (const prefix of ['', 'en/']) {
  test(`D60 ${prefix || 'zh'} branded home offers direct download and a collapsed privacy preview`, () => {
    const html = read(`dist/${prefix}index.html`);
    const title = html.match(/<title>(.*?)<\/title>/)[1];
    assert.ok(title.includes('Yihu'));
    assert.ok(title.includes(prefix ? 'iPhone Voice Client' : 'iPhone 语音客户端'));
    const hero = html.split('class="task-hero wrap"')[1].split('</section>')[0];
    assert.match(hero, /<h1[^>]*>[^<]*Yihu/);
    assert.ok(hero.includes(`href="${store.url}"`));
    assert.ok(hero.includes('href="#experience"'));
    assert.ok(hero.includes(prefix ? 'HTTPS address and account' : 'HTTPS 地址与账号'));
    assert.ok(hero.includes(prefix ? 'on-device speech' : '端侧识别'));
    assert.ok(hero.includes('<details class="privacy-preview" id="privacy-preview">'));
    assert.ok(hero.includes(prefix ? 'reloading resets them' : '刷新即重置'));
    assert.ok(hero.includes(prefix ? 'browser’s voice service' : '浏览器语音服务'));
    assert.ok(hero.includes(prefix ? 'analytics require your consent' : '使用统计须经你同意'));
    assert.ok(hero.includes(`href="/${prefix}privacy/"`));
    assert.ok(!hero.includes('3.93'));
  });

  for (const slug of slugs) test(`D60 ${prefix || 'zh'} ${slug} keeps scope and adds same-language download/privacy actions`, () => {
    const html = read(`dist/${prefix}guides/${slug}/index.html`);
    const source = read(`src/pages/${prefix}guides/${slug}.md`);
    assert.ok(source.includes('privacyPreview: true'));
    assert.ok(html.match(/<title>(.*?)<\/title>/)[1].includes('Yihu'));
    assert.equal(html.includes('content="noindex,follow"'), slug === 'followup-evidence-minimization');
    assert.ok(html.includes(`rel="canonical" href="https://getyihu.com/${prefix}guides/${slug}/"`));
    const block = html.match(/<section\b[^>]*data-guide-conversion[^>]*>[\s\S]*?<\/section>/)[0];
    const pillar = slug === 'handoff-evidence-audit-checklist' ? 'recording-notes-handoff' : 'multi-project-radar-watch';
    assert.ok(block.includes(`href="/${prefix}guides/${pillar}/#interactive-preview"`));
    assert.ok(block.includes(`href="${store.url}"`));
    assert.ok(block.includes('<details class="privacy-preview" id="privacy-preview">'));
    assert.ok(block.includes(`href="/${prefix}privacy/"`));
    assert.ok(block.includes(prefix ? 'no login or microphone' : '无需登录或麦克风'));
    assert.ok(block.includes(prefix ? 'private originals' : '私有原件'));
    assert.ok(block.includes(prefix ? 'installed version' : '已安装版本'));
    assert.ok(!html.includes('<astro-island'));
    assert.ok(html.includes('id="first-answer"'));
    if (slug === 'handoff-evidence-audit-checklist') {
      assert.ok(block.includes('href="#download-checklist"'));
      assert.ok(html.includes('id="download-checklist"'));
      assert.ok(html.includes(`/samples/p33-clinical-shift-handover/checklist.${prefix ? 'en' : 'zh'}.json`));
      assert.ok(html.includes(prefix ? 'not clinical handover' : '不是临床交班工具'));
    }
  });
}
