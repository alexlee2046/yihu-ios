// OFFLINE CONTRACT ONLY: every SDK byte is a literal stub; no live SDK, visitor or mail traffic.
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { resolve, extname, sep } from 'node:path';
if (process.platform !== 'linux' || !process.env.CI || !process.env.YIHU_CONTACT_DIST) throw Error('Use the existing remote CI with the synthetic contact build.');
const { chromium, webkit } = createRequire(import.meta.url)('playwright');
const defaults = resolve('dist'), configured = resolve(process.env.YIHU_CONTACT_DIST);
const output = resolve(process.env.RUNNER_TEMP, 'yihu-contact-offline');
await mkdir(output, { recursive: true });
const results = [], failures = [];
let activeBrowser;
const sdkURL = 'https://chatwoot.kynora.world/packs/js/sdk.js';
const sdkStub = `// Literal fixture, never fetched from the platform.
window.__contactFixture = { runs: [], toggles: [] };
window.chatwootSDK = { run(config) {
  window.__contactFixture.runs.push(config);
  window.$chatwoot = { ...config, hasLoaded:true, toggle(state) { window.__contactFixture.toggles.push(state ?? 'toggle'); } };
  window.dispatchEvent(new Event('chatwoot:ready'));
} };`;
for (const signal of ['SIGTERM','SIGINT']) process.once(signal, async () => {
  try { await activeBrowser?.close(); } finally { process.exit(signal === 'SIGINT' ? 130 : 143); }
});
async function open(browser, dir, path, width, mode) {
  const context = await browser.newContext({ viewport:{ width,height:width<700?844:1000 }, deviceScaleFactor:1, isMobile:width<700, hasTouch:width<700, locale:path==='/en/'?'en-US':'zh-CN', reducedMotion:'reduce', serviceWorkers:'block' });
  const network = { sdkStubRequests:0, injectedSdkFailures:0, unexpected:[] }, errors=[];
  try {
    await context.addInitScript(() => document.addEventListener('DOMContentLoaded', () => {
      const note=document.createElement('div'); note.textContent='OFFLINE SYNTHETIC CONTRACT · NOT LIVE CHAT';
      note.style.cssText='position:fixed;top:0;left:0;right:0;text-align:center;font:11px sans-serif;background:#fff;color:#111;z-index:2147483647;pointer-events:none'; document.body.append(note);
    }));
    await context.route('**/*', async route => {
      const url=new URL(route.request().url());
      if (url.origin==='https://www.googletagmanager.com') return route.fulfill({ contentType:'text/javascript',body:'// Existing analytics is isolated, not altered by contact.' });
      if (url.href===sdkURL) {
        if (mode==='configured') { network.sdkStubRequests++; return route.fulfill({ contentType:'text/javascript',body:sdkStub }); }
        if (mode==='sdk-error') { network.injectedSdkFailures++; return route.abort(); }
        network.unexpected.push('SDK requested while configuration is absent'); return route.abort();
      }
      if (url.origin!=='https://getyihu.com') { network.unexpected.push(url.origin+url.pathname); return route.abort(); }
      const file=resolve(dir,'.'+decodeURIComponent(url.pathname)+(url.pathname.endsWith('/')?'index.html':''));
      assert.ok(file.startsWith(dir+sep));
      try {
        const body=await readFile(file);
        const contentType={'.html':'text/html','.js':'text/javascript','.css':'text/css','.svg':'image/svg+xml','.png':'image/png','.webp':'image/webp','.woff2':'font/woff2'}[extname(file)]||'application/octet-stream';
        await route.fulfill({status:200,contentType,body});
      } catch { network.unexpected.push('Missing local static file '+url.pathname); await route.abort(); }
    });
    const page=await context.newPage();
    page.on('pageerror',e=>errors.push(e.message));
    await page.goto('https://getyihu.com'+path,{waitUntil:'load',timeout:20000});
    await page.evaluate(()=>document.fonts.ready);
    return {context,page,network,errors};
  } catch(error) { await context.close(); throw error; }
}
async function geometry(page) {
  return page.evaluate(()=>{
    const launcher=document.querySelector('[data-contact-chat] button');
    const r=launcher?.getBoundingClientRect(),banner=document.getElementById('analytics-consent');
    return {width:innerWidth,scrollWidth:document.documentElement.scrollWidth,launcher:r?{top:r.top,bottom:r.bottom,left:r.left,right:r.right,width:r.width,height:r.height}:null,bannerTop:banner&&!banner.hidden?banner.getBoundingClientRect().top:null};
  });
}
for (const [engine,type] of [['chromium',chromium],['webkit',webkit]]) {
  const record={engine,pages:[],cleanup:'pending',kind:'offline synthetic SDK contracts; not a real Chatwoot, visitor, mail, deployed CSP, Safari or device test'};
  results.push(record);
  try {
    activeBrowser=await type.launch({headless:true,...(engine==='chromium'?{channel:'chrome'}:{})});
    record.version=activeBrowser.version();
    for (const [path,width] of [['/',390],['/en/',1440]]) for (const mode of ['default-off','configured']) {
      const p=await open(activeBrowser,mode==='default-off'?defaults:configured,path,width,mode);
      try {
        const {page,network,errors}=p;
        const item={path,width,mode,network};record.pages.push(item);
        assert.equal(await page.locator('[data-contact-chat]').count(),mode==='default-off'?0:1);
        assert.equal(network.sdkStubRequests,0,'nothing loads before a deliberate click');
        const email=page.locator('.site-footer a[href^="mailto:"]');
        if (mode==='default-off') assert.equal(await email.count(),0);
        else {
          assert.equal(await email.getAttribute('href'),'mailto:support@example.test');
          const button=page.locator('[data-contact-chat] button');
          await button.focus();
          assert.ok(await button.evaluate(b=>getComputedStyle(b).outlineStyle!=='none'&&parseFloat(getComputedStyle(b).outlineWidth)>=3),'visible keyboard focus');
          item.before=await geometry(page);
          assert.ok(item.before.launcher.top>=0 && item.before.launcher.right<=width);
          if(item.before.bannerTop!==null) assert.ok(item.before.launcher.bottom<=item.before.bannerTop,'launcher does not cover consent controls');
          await page.keyboard.press('Enter');
          await page.waitForFunction(()=>window.__contactFixture?.toggles.length===1,null,{timeout:5000});
          assert.equal(network.sdkStubRequests,1);
          assert.deepEqual(await page.evaluate(()=>window.__contactFixture.runs),[{baseUrl:'https://chatwoot.kynora.world',websiteToken:'synthetic-not-a-real-inbox'}]);
          assert.ok(await button.evaluate(b=>b===document.activeElement),'loading preserves keyboard focus');
          await page.keyboard.press('Space'); await page.keyboard.press('Escape');
          assert.deepEqual(await page.evaluate(()=>window.__contactFixture.toggles),['open','toggle','close']);
          assert.equal(await button.getAttribute('aria-expanded'),null,'do not invent external iframe state');
          await page.locator('#analytics-deny').click();
          await page.waitForFunction(()=>document.querySelector('[data-contact-chat]').style.getPropertyValue('--contact-bottom')==='20px');
          await button.focus(); await page.keyboard.press('Enter');
          assert.equal(await page.evaluate(()=>window.__contactFixture.toggles.at(-1)),'toggle','contact remains independent after analytics denial');
          item.afterDenial=await geometry(page);
          const events=await page.evaluate(()=>(window.dataLayer||[]).map(x=>Array.from(x)).filter(x=>x[0]==='event'));
          assert.equal(events.length,0,'contact never adds preview/user-content telemetry');
          item.keys='native Enter/Space and focused-launcher Escape; external iframe keyboard untested';
          item.mail='href only; no mail app or sending API invoked';
          await page.screenshot({path:resolve(output,`${engine}-configured-main-${path==='/en/'?'en':'zh'}-${width}.png`),fullPage:false});
          await email.scrollIntoViewIfNeeded();
          item.footer=await email.evaluate(a=>{
            const r=a.getBoundingClientRect(),b=document.querySelector('[data-contact-chat] button').getBoundingClientRect();
            const controls=[...document.querySelectorAll('.site-footer a,.site-footer button')].map(node=>{ const c=node.getBoundingClientRect(); return {control:node.id||node.className||node.tagName,width:c.width,height:c.height,covered:!(c.right<=b.left||c.left>=b.right||c.bottom<=b.top||c.top>=b.bottom)}; }).filter(c=>c.width>0&&c.height>0);
            return {width:r.width,height:r.height,controls};
          });
          assert.ok(item.footer.width>=44 && item.footer.height>=44,'mail touch target');
          assert.ok(item.footer.controls.every(c=>!c.covered),'launcher must not cover any footer control, including analytics preferences');
        }
        const g=await geometry(page);assert.ok(g.scrollWidth<=width,'no page-level horizontal overflow');
        assert.deepEqual(network.unexpected,[]);assert.deepEqual(errors,[]);
        await page.screenshot({path:resolve(output,`${engine}-${mode}-${path==='/en/'?'en':'zh'}-${width}.png`),fullPage:false});
      } finally { await p.context.close(); }
    }
    const p=await open(activeBrowser,configured,'/',390,'sdk-error');
    try {
      const button=p.page.locator('[data-contact-chat] button');await button.click();
      await p.page.waitForFunction(()=>document.querySelector('[data-contact-chat] button').disabled,null,{timeout:5000});
      assert.match(await p.page.locator('[data-contact-chat] [role="status"]').innerText(),/刷新/);
      assert.equal(p.network.injectedSdkFailures,1);assert.deepEqual(p.network.unexpected,[]);assert.deepEqual(p.errors,[]);
      record.pages.push({path:'/',width:390,mode:'injected SDK unavailable',network:p.network});
      await p.page.screenshot({path:resolve(output,`${engine}-injected-sdk-unavailable-zh-390.png`),fullPage:false});
    } finally { await p.context.close(); }
  } catch(error) { failures.push(`${engine}: ${error.stack||error}`); }
  finally {
    await activeBrowser?.close();activeBrowser=undefined;record.cleanup='closed';
    await writeFile(resolve(output,'evidence.json'),JSON.stringify({offlineOnly:true,liveSdkExecuted:false,visitorsCreated:false,mailSent:false,deployedCspTested:false,results,failures},null,2));
  }
}
assert.deepEqual(failures,[]);
console.log('Offline contact contracts PASS: Chromium/WebKit, default-off + synthetic configuration, native launcher keys, injected SDK failure; no live SDK/visitor/mail; browsers closed.');
