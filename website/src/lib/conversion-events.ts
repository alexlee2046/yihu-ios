import { analyticsContext, previewPaths, type BuyerScenario } from './preview-events';
import store from '../data/app-store.json';

// P5 explicit active-guide cards + the five unchanged retired P4 references.
// No runtime slug heuristics or index restoration. "brief" retains event value "radar".
export const conversionGuides: Record<string, BuyerScenario> = {
  '/en/guides/app-group-inbox-access-evidence/': 'voice',
  '/en/guides/attachment-name-metadata-provenance/': 'voice',
  '/en/guides/attention-filter-identity-boundaries/': 'radar',
  '/en/guides/audio-busy-state-admission/': 'audio',
  '/en/guides/audio-level-not-accuracy-review/': 'audio',
  '/en/guides/audio-route-recovery-matrix/': 'audio',
  '/en/guides/batch-change-record-retention/': 'voice',
  '/en/guides/bluetooth-audio-input-troubleshooting/': 'audio',
  '/en/guides/brief-format-change-compatibility/': 'notes',
  '/en/guides/capture-buffer-pressure-checklist/': 'audio',
  '/en/guides/carrier-redaction-archive-matrix/': 'notes',
  '/en/guides/cross-device-field-presentation/': 'radar',
  '/en/guides/degraded-handoff-go-no-go/': 'voice',
  '/en/guides/department-minutes-ownership-archive/': 'notes',
  '/en/guides/empty-field-display-defaults/': 'voice',
  '/en/guides/evidence-link-admission-preflight/': 'radar',
  '/en/guides/export-encoding-delimiter-preflight/': 'voice',
  '/en/guides/file-chunk-bridge-not-upload-receipt/': 'voice',
  '/en/guides/first-trial-go-no-go-checklist/': 'voice',
  '/en/guides/follow-up-context-preflight/': 'voice',
  '/en/guides/followup-evidence-minimization/': 'radar',
  '/en/guides/foreground-audio-rebind-preflight/': 'audio',
  '/en/guides/handoff-evidence-audit-checklist/': 'radar',
  '/en/guides/history-generation-receipt-priority/': 'radar',
  '/en/guides/history-reference-integrity-review/': 'radar',
  '/en/guides/history-retrieval-manual-comparison/': 'radar',
  '/en/guides/host-bridge-outcome-boundaries/': 'voice',
  '/en/guides/interruption-recapture-preflight/': 'audio',
  '/en/guides/keyboard-acknowledgement-scope/': 'voice',
  '/en/guides/list-preview-not-transcript-archive/': 'notes',
  '/en/guides/local-file-protection-scope/': 'voice',
  '/en/guides/meeting-notes-brief-fields/': 'notes',
  '/en/guides/microphone-permission-sample-contract/': 'audio',
  '/en/guides/mobile-agent-decisions/': 'radar',
  '/en/guides/multi-note-review-handoff/': 'notes',
  '/en/guides/multi-project-radar-watch/': 'radar',
  '/en/guides/multi-role-approval-receipt-checklist/': 'voice',
  '/en/guides/multilingual-terms-preflight/': 'voice',
  '/en/guides/near-field-policy-route-review/': 'voice',
  '/en/guides/noisy-transcript-text-correction/': 'notes',
  '/en/guides/note-audio-text-evidence-mapping/': 'radar',
  '/en/guides/note-organization-prompt-not-minutes/': 'notes',
  '/en/guides/note-radar-draft-candidate-preflight/': 'radar',
  '/en/guides/note-removal-retention-boundaries/': 'notes',
  '/en/guides/note-segment-join-provenance/': 'notes',
  '/en/guides/note-transcription-retry-checkpoint/': 'notes',
  '/en/guides/notification-payload-model-preflight/': 'voice',
  '/en/guides/offline-workbench-handoff-troubleshooting/': 'voice',
  '/en/guides/outdoor-store-voice-preflight/': 'audio',
  '/en/guides/pcm-format-admission-review/': 'audio',
  '/en/guides/privacy-declaration-evidence-scope/': 'radar',
  '/en/guides/radar-evidence-second-check/': 'radar',
  '/en/guides/radar-feed-url-boundary-preflight/': 'radar',
  '/en/guides/radar-json-null-validation/': 'radar',
  '/en/guides/radar-snapshot-batch-comparison/': 'radar',
  '/en/guides/radar-summary-claim-provenance/': 'radar',
  '/en/guides/recognition-error-layer-review/': 'audio',
  '/en/guides/recording-notes-handoff/': 'notes',
  '/en/guides/recording-segment-review-labels/': 'notes',
  '/en/guides/replaceable-voice-preview-review/': 'voice',
  '/en/guides/reply-draft-restoration-scope/': 'radar',
  '/en/guides/reply-request-receipt-mapping/': 'radar',
  '/en/guides/reply-transport-budget-preflight/': 'radar',
  '/en/guides/share-batch-item-preflight/': 'voice',
  '/en/guides/share-manifest-visibility-review/': 'voice',
  '/en/guides/source-switch-cache-isolation/': 'voice',
  '/en/guides/status-alias-approval-boundaries/': 'radar',
  '/en/guides/timezone-timestamp-review/': 'voice',
  '/en/guides/vehicle-exhibition-microphone-preflight/': 'audio',
  '/en/guides/voice-workbench-vs-radio-chat/': 'voice',
  '/en/guides/voiceprint-enrollment-profile-version-review/': 'audio',
  '/en/guides/voiceprint-filter-not-authorization/': 'audio',
  '/en/guides/web-read-aloud-microphone-boundaries/': 'audio',
  '/en/guides/workbench-origin-page-boundaries/': 'voice',
  '/guides/attachment-name-metadata-provenance/': 'voice',
  '/guides/audio-busy-state-admission/': 'audio',
  '/guides/audio-level-not-accuracy-review/': 'audio',
  '/guides/audio-route-recovery-matrix/': 'audio',
  '/guides/batch-change-record-retention/': 'voice',
  '/guides/bluetooth-audio-input-troubleshooting/': 'audio',
  '/guides/brief-format-change-compatibility/': 'notes',
  '/guides/capture-buffer-pressure-checklist/': 'audio',
  '/guides/capture-completion-token-review/': 'audio',
  '/guides/carrier-redaction-archive-matrix/': 'notes',
  '/guides/cross-device-field-presentation/': 'radar',
  '/guides/degraded-handoff-go-no-go/': 'voice',
  '/guides/department-minutes-ownership-archive/': 'notes',
  '/guides/empty-field-display-defaults/': 'voice',
  '/guides/evidence-link-admission-preflight/': 'radar',
  '/guides/export-encoding-delimiter-preflight/': 'voice',
  '/guides/file-chunk-bridge-not-upload-receipt/': 'voice',
  '/guides/first-trial-go-no-go-checklist/': 'voice',
  '/guides/follow-up-context-preflight/': 'voice',
  '/guides/foreground-audio-rebind-preflight/': 'audio',
  '/guides/handoff-evidence-audit-checklist/': 'radar',
  '/guides/history-generation-receipt-priority/': 'radar',
  '/guides/history-reference-integrity-review/': 'radar',
  '/guides/history-retrieval-manual-comparison/': 'radar',
  '/guides/host-bridge-outcome-boundaries/': 'voice',
  '/guides/interruption-recapture-preflight/': 'audio',
  '/guides/keyboard-acknowledgement-scope/': 'voice',
  '/guides/list-preview-not-transcript-archive/': 'notes',
  '/guides/local-file-protection-scope/': 'voice',
  '/guides/meeting-notes-brief-fields/': 'notes',
  '/guides/microphone-permission-sample-contract/': 'audio',
  '/guides/mobile-agent-decisions/': 'radar',
  '/guides/model-artifact-validation-evidence/': 'voice',
  '/guides/multi-note-review-handoff/': 'notes',
  '/guides/multi-project-radar-watch/': 'radar',
  '/guides/multi-role-approval-receipt-checklist/': 'voice',
  '/guides/multilingual-terms-preflight/': 'voice',
  '/guides/near-field-policy-route-review/': 'voice',
  '/guides/noisy-transcript-text-correction/': 'notes',
  '/guides/note-audio-text-evidence-mapping/': 'radar',
  '/guides/note-organization-prompt-not-minutes/': 'notes',
  '/guides/note-radar-draft-candidate-preflight/': 'radar',
  '/guides/note-removal-retention-boundaries/': 'notes',
  '/guides/note-segment-join-provenance/': 'notes',
  '/guides/note-transcription-retry-checkpoint/': 'notes',
  '/guides/notification-payload-model-preflight/': 'voice',
  '/guides/offline-workbench-handoff-troubleshooting/': 'voice',
  '/guides/outdoor-store-voice-preflight/': 'audio',
  '/guides/pcm-format-admission-review/': 'audio',
  '/guides/privacy-declaration-evidence-scope/': 'radar',
  '/guides/radar-evidence-second-check/': 'radar',
  '/guides/radar-feed-url-boundary-preflight/': 'radar',
  '/guides/radar-json-null-validation/': 'radar',
  '/guides/radar-snapshot-batch-comparison/': 'radar',
  '/guides/radar-summary-claim-provenance/': 'radar',
  '/guides/recognition-error-layer-review/': 'audio',
  '/guides/recording-notes-handoff/': 'notes',
  '/guides/recording-segment-review-labels/': 'notes',
  '/guides/replaceable-voice-preview-review/': 'voice',
  '/guides/reply-draft-restoration-scope/': 'radar',
  '/guides/reply-request-receipt-mapping/': 'radar',
  '/guides/reply-transport-budget-preflight/': 'radar',
  '/guides/share-batch-item-preflight/': 'voice',
  '/guides/share-manifest-visibility-review/': 'voice',
  '/guides/source-switch-cache-isolation/': 'voice',
  '/guides/status-alias-approval-boundaries/': 'radar',
  '/guides/timezone-timestamp-review/': 'voice',
  '/guides/vehicle-exhibition-microphone-preflight/': 'audio',
  '/guides/voice-workbench-vs-radio-chat/': 'voice',
  '/guides/voiceprint-enrollment-profile-version-review/': 'audio',
  '/guides/voiceprint-filter-not-authorization/': 'audio',
  '/guides/web-read-aloud-microphone-boundaries/': 'audio',
  '/guides/workbench-origin-page-boundaries/': 'voice',
};
const pillars: Record<BuyerScenario, string> = {
  voice: 'iphone-agent-voice-drafts', audio: 'bluetooth-audio-input-troubleshooting',
  notes: 'recording-notes-handoff', radar: 'multi-project-radar-watch',
};
export const conversionPaths = [...new Set([...previewPaths, '/start/', '/en/start/', ...Object.keys(conversionGuides)])];
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
  // Existing scenario pages keep their P4 group even when a paired card is added.
  const page_group = path.endsWith('/start/') ? 'setup' : path === '/' || path === '/en/' ? 'home' : previewPaths.includes(path) ? 'scenario' : 'guide';
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
