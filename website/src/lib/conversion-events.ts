import { analyticsContext, previewPaths, type BuyerScenario } from './preview-events';
import store from '../data/app-store.json';

// P4's selected 14 references only. "brief" uses the existing "radar" event value.
export const conversionGuides: Record<string, BuyerScenario> = {
  '/en/guides/audio-route-recovery-matrix/': 'audio',
  '/guides/audio-level-not-accuracy-review/': 'audio',
  '/en/guides/attention-filter-identity-boundaries/': 'radar',
  '/en/guides/radar-evidence-second-check/': 'radar',
  '/guides/capture-completion-token-review/': 'audio',
  '/guides/model-artifact-validation-evidence/': 'voice',
  '/en/guides/app-group-inbox-access-evidence/': 'voice',
  '/en/guides/audio-busy-state-admission/': 'audio',
  '/en/guides/followup-evidence-minimization/': 'radar',
  '/en/guides/mobile-agent-decisions/': 'radar',
  '/en/guides/outdoor-store-voice-preflight/': 'audio',
  '/en/guides/pcm-format-admission-review/': 'audio',
  '/guides/cross-device-field-presentation/': 'radar',
  '/guides/noisy-transcript-text-correction/': 'notes',
};
const pillars: Record<BuyerScenario, string> = {
  voice: 'iphone-agent-voice-drafts', audio: 'bluetooth-audio-input-troubleshooting',
  notes: 'recording-notes-handoff', radar: 'multi-project-radar-watch',
};
export const conversionPaths = [...previewPaths, '/start/', '/en/start/', ...Object.keys(conversionGuides)];
const copy = {
  zh: {
    labels: { voice: '先试语音草稿示例', audio: '先做蓝牙四问预览', notes: '先看录文到待办示例', radar: '先看合成简报示例' },
    storeLabel: '在 App Store 查看 · ' + store.version,
    storeContext: '已核美区商店，当前地区是否可获取以商店为准。安装不需 Mac 或自行签名；需你已有的工作台地址与账号，语音模型约 950 MB、按需下载。',
    sourceContext: '本页是源码/排障参考，示例不证明商店版已包含本页全部能力。若你需要已有工作台的语音草稿入口，可查看已核 0.1.0 商店版。',
  },
  en: {
    labels: { voice: 'Try a voice-draft sample', audio: 'Try the four-question audio preview', notes: 'See transcript-to-next-step samples', radar: 'See a synthetic brief' },
    storeLabel: 'View on App Store · ' + store.version,
    storeContext: 'US listing verified; availability depends on your storefront. No Mac or self-signing for store installation. Bring your workspace address and account; the optional speech model is about 950 MB.',
    sourceContext: 'This is a source/troubleshooting reference. Its samples do not establish that the store edition contains every described capability. For voice drafts into an existing workspace, see the verified 0.1.0 listing.',
  },
};
export function guideConversion(path: string) {
  if (!Object.hasOwn(conversionGuides, path)) return null;
  const scenario = conversionGuides[path], language = path.startsWith('/en/') ? 'en' : 'zh';
  return { ...copy[language], scenario, demoLabel: copy[language].labels[scenario], demoHref: (language === 'en' ? '/en/' : '/') + 'guides/' + pillars[scenario] + '/#interactive-preview', storeHref: store.url };
}
function pageContext(path: string) {
  if (!conversionPaths.includes(path)) return null;
  const language = path.startsWith('/en/') ? 'en' : 'zh';
  const page_group = Object.hasOwn(conversionGuides, path) ? 'guide' : path.endsWith('/start/') ? 'setup' : path === '/' || path === '/en/' ? 'home' : 'scenario';
  const scenario = conversionGuides[path] ?? (Object.keys(pillars) as BuyerScenario[]).find(s => path.endsWith('/' + pillars[s] + '/')) ?? 'voice';
  return { language, page_group, scenario } as const;
}
type ConversionEvent = 'funnel_entry' | 'guide_demo_click' | 'app_store_click';
type Placement = 'page_entry' | 'guide_intro' | 'page_link';
export function trackConversionEvent(event: ConversionEvent, scenario: BuyerScenario, placement: Placement): boolean {
  try {
    if (!['funnel_entry', 'guide_demo_click', 'app_store_click'].includes(event)
      || !['voice', 'audio', 'notes', 'radar'].includes(scenario)
      || !(event === 'funnel_entry' ? placement === 'page_entry' : ['guide_intro', 'page_link'].includes(placement))) return false;
    const context = analyticsContext(conversionPaths);
    if (!context) return false;
    const page = pageContext(context.page.pathname);
    if (!page) return false;
    context.browser.gtag!('event', event, { language: page.language, scenario, placement, page_group: page.page_group });
    return true;
  } catch { return false; }
}
export function bindConversionEvents(): void {
  const canonical = document.querySelector<HTMLLinkElement>('link[rel="canonical"]');
  if (!canonical) return;
  let page: ReturnType<typeof pageContext>;
  try { page = pageContext(new URL(canonical.href).pathname); } catch { return; }
  if (!page) return;
  const current = page;
  // Per-document successful entry only; no queued actions, new storage or session IDs.
  let entered = false;
  const enter = () => {
    if (!entered) entered = trackConversionEvent('funnel_entry', current.scenario, 'page_entry');
    return entered;
  };
  enter();
  window.addEventListener('yihu:analytics-choice', enter);
  document.addEventListener('click', event => {
    if (!(event.target instanceof Element)) return;
    const anchor = event.target.closest<HTMLAnchorElement>('a[href]');
    if (!anchor) return;
    const placement = anchor.closest('[data-guide-conversion]') ? 'guide_intro' : 'page_link';
    if (anchor.href === store.url) {
      if (enter()) trackConversionEvent('app_store_click', current.scenario, placement);
      return;
    }
    let target: URL;
    try { target = new URL(anchor.href); } catch { return; }
    const prefix = current.language === 'en' ? '/en/' : '/';
    const scenario = (Object.keys(pillars) as BuyerScenario[]).find(s => target.pathname === prefix + 'guides/' + pillars[s] + '/');
    if (['https://getyihu.com', 'https://www.getyihu.com'].includes(target.origin) && target.hash === '#interactive-preview' && !target.search && scenario && enter()) {
      trackConversionEvent('guide_demo_click', scenario, placement);
    }
    // Native navigation is never delayed or prevented for measurement.
  });
}
