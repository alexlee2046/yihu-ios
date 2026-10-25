export type PreviewScenario = 'voice' | 'audio' | 'radar';
export type BuyerScenario = PreviewScenario | 'notes';
type PreviewEvent = 'scenario_select' | 'preview_complete' | 'setup_click';
type PreviewAction = 'select' | 'insert' | 'self_check' | 'view_json' | 'view_readable' | 'setup';

export const previewPaths = ['/', '/en/'];
for (const prefix of ['', 'en/']) for (const slug of [
  'iphone-agent-voice-drafts', 'bluetooth-audio-input-troubleshooting',
  'recording-notes-handoff', 'multi-project-radar-watch',
]) previewPaths.push('/' + prefix + 'guides/' + slug + '/');

// Shared fail-closed eligibility; each caller retains its own exact route allowlist.
export function analyticsContext(paths: readonly string[]) {
  try {
    const browser = window as Window & {
      gtag?: (command: string, event: string, parameters: Record<string, string>) => void;
      'ga-disable-G-CWT1FWEHCL'?: boolean;
    };
    if (!['https://getyihu.com', 'https://www.getyihu.com'].includes(browser.location.origin)) return null;
    // The existing consent bootstrap owns the opt-out flag, including failed storage writes.
    if (browser['ga-disable-G-CWT1FWEHCL'] !== false || typeof browser.gtag !== 'function') return null;
    if (browser.localStorage.getItem('yihu.analytics-consent.v1') !== 'granted') return null;
    const canonical = browser.document.querySelector<HTMLLinkElement>('link[rel="canonical"]');
    if (!canonical) return null;
    const page = new URL(canonical.href);
    if (page.origin !== 'https://getyihu.com' || page.username || page.password || !paths.includes(page.pathname)) return null;
    if (browser.location.pathname && browser.location.pathname !== page.pathname) return null;
    return { browser, page };
  } catch { return null; }
}

// No queue, stored funnel state, editor contents, source JSON or query strings.
export function trackPreviewEvent(event: PreviewEvent, scenario: BuyerScenario, language: 'zh' | 'en', action: PreviewAction): boolean {
  try {
    if (!['scenario_select', 'preview_complete', 'setup_click'].includes(event)
      || !['voice', 'audio', 'notes', 'radar'].includes(scenario)
      || !['zh', 'en'].includes(language)
      || !['select', 'insert', 'self_check', 'view_json', 'view_readable', 'setup'].includes(action)) return false;
    const context = analyticsContext(previewPaths);
    if (!context) return false;
    const { browser, page } = context;
    browser.gtag!('event', event, { language, scenario, page: page.pathname, action });
    return true;
  } catch { return false; } // Storage, missing bootstrap and blocked tags fail closed.
}
