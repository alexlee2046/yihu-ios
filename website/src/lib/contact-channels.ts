// Public build-time identifiers only; platform credentials never belong here.
export interface ContactConfig {
  email: string | null;
  chat: { baseUrl: string; websiteToken: string } | null;
}
export function contactConfig(env: Record<string, unknown>): ContactConfig {
  const email = typeof env.PUBLIC_CONTACT_EMAIL === 'string' ? env.PUBLIC_CONTACT_EMAIL.trim() : '';
  const result: ContactConfig = { email: null, chat: null };
  // No query, header, display-name or multi-recipient syntax in a mailto target.
  const [local = '', domain = ''] = email.split('@');
  const emailSyntax = email.length <= 254 && /^[a-zA-Z0-9._+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(email)
    && !local.startsWith('.') && !local.endsWith('.') && !local.includes('..')
    && domain.split('.').every(label => /^[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$/.test(label));
  if (env.PUBLIC_CONTACT_EMAIL_ENABLED === 'true' && emailSyntax) result.email = email;
  if (env.PUBLIC_CHATWOOT_ENABLED !== 'true') return result;
  const token = env.PUBLIC_CHATWOOT_WEBSITE_TOKEN;
  if (typeof token !== 'string' || !token || token.length > 512 || /[\s\u0000-\u001f\u007f]/.test(token)) return result;
  try {
    const url = new URL(String(env.PUBLIC_CHATWOOT_BASE_URL ?? ''));
    // Only the approved platform origin, not arbitrary executable script hosts.
    if (url.origin !== 'https://chatwoot.kynora.world' || url.pathname !== '/' || url.search || url.hash || url.username || url.password) return result;
    result.chat = { baseUrl: url.origin, websiteToken: token };
  } catch { /* Missing or malformed configuration stays off. */ }
  return result;
}

type ChatAPI = { toggle(state?: 'open' | 'close'): void };
type ChatWindow = Window & {
  chatwootSettings?: Record<string, unknown>;
  chatwootSDK?: { run(config: { baseUrl: string; websiteToken: string }): void };
  $chatwoot?: ChatAPI;
};

export function mountContactChat(root: HTMLElement) {
  const button = root.querySelector<HTMLButtonElement>('button');
  const status = root.querySelector<HTMLElement>('[role="status"]');
  const config = contactConfig({ PUBLIC_CHATWOOT_ENABLED: 'true', PUBLIC_CHATWOOT_BASE_URL: root.dataset.baseUrl, PUBLIC_CHATWOOT_WEBSITE_TOKEN: root.dataset.websiteToken });
  if (!button || !status || !config.chat || root.dataset.contactMounted === 'true') return;
  root.dataset.contactMounted = 'true';
  const { baseUrl, websiteToken } = config.chat;
  const win = window as ChatWindow;
  const en = root.dataset.lang === 'en';
  let started = false, ready = false, failed = false, inactive = false, sdkStarted = false;
  let ownedAPI: ChatAPI | undefined;
  let script: HTMLScriptElement | undefined;
  let timer: ReturnType<typeof setTimeout> | undefined;
  const banner = document.getElementById('analytics-consent');
  const position = () => {
    // Keep the launcher above the existing banner without changing its consent.
    const overlap = banner && !banner.hidden ? Math.max(0, window.innerHeight - banner.getBoundingClientRect().top) : 0;
    root.style.setProperty('--contact-bottom', `${overlap + 20}px`);
  };
  const resize = typeof ResizeObserver === 'undefined' ? undefined : new ResizeObserver(position);
  const mutation = typeof MutationObserver === 'undefined' ? undefined : new MutationObserver(position);
  if (banner) { resize?.observe(banner); mutation?.observe(banner, { attributes: true, attributeFilter: ['hidden'] }); }
  window.addEventListener('resize', position);
  position();
  const fail = () => {
    failed = true;
    clearTimeout(timer);
    script?.remove();
    button.disabled = true;
    button.removeAttribute('aria-busy');
    status.textContent = en ? 'Chat could not load. Refresh the page to try again.' : '客服暂未能加载，请刷新页面后重试。';
  };
  const api = () => ready && !failed && !inactive && win.$chatwoot === ownedAPI ? ownedAPI : null;
  window.addEventListener('chatwoot:ready', () => {
    if (!sdkStarted || failed || inactive || ready) return;
    if (typeof win.$chatwoot?.toggle !== 'function') { fail(); return; }
    ownedAPI = win.$chatwoot;
    ready = true;
    clearTimeout(timer);
    button.disabled = false;
    button.removeAttribute('aria-busy');
    status.textContent = '';
    try { win.$chatwoot.toggle('open'); } catch { fail(); }
  });
  button.addEventListener('click', () => {
    const current = api();
    if (current) { try { current.toggle(); } catch { fail(); } return; }
    if (ready && !inactive && !failed) { fail(); return; }
    if (started || failed || inactive) return;
    started = true;
    // Never adopt a pre-existing widget which could belong to another inbox.
    if (win.chatwootSDK || win.$chatwoot || win.chatwootSettings) { fail(); return; }
    win.chatwootSettings = { hideMessageBubble: true, showUnreadMessagesDialog: false, locale: en ? 'en' : 'zh_CN', useBrowserLanguage: false };
    // Keep native keyboard focus while the guarded single attempt is pending.
    button.setAttribute('aria-busy', 'true');
    status.textContent = en ? 'Loading chat…' : '正在加载客服…';
    script = document.createElement('script');
    script.src = `${baseUrl}/packs/js/sdk.js`;
    script.async = true;
    script.referrerPolicy = 'no-referrer';
    script.onerror = fail;
    script.onload = () => {
      if (failed || inactive) return;
      if (typeof win.chatwootSDK?.run !== 'function') { fail(); return; }
      sdkStarted = true;
      try { win.chatwootSDK.run({ baseUrl, websiteToken }); } catch { fail(); }
    };
    timer = setTimeout(fail, 15000);
    document.head.appendChild(script);
  });
  // Native Enter/Space click behavior stays intact. This handles only the focused launcher.
  button.addEventListener('keydown', event => {
    const current = api();
    if (event.key === 'Escape' && current) { event.preventDefault(); try { current.toggle('close'); button.focus(); } catch { fail(); } }
  });
  window.addEventListener('pagehide', () => {
    const current = api();
    if (current) { try { current.toggle('close'); } catch { /* Leaving the document. */ } }
    inactive = true;
    clearTimeout(timer);
    if (started && !ready) { failed = true; script?.remove(); }
    resize?.disconnect(); mutation?.disconnect();
    window.removeEventListener('resize', position);
  });
  window.addEventListener('pageshow', () => {
    inactive = false;
    if (failed) { fail(); return; }
    if (banner) { resize?.observe(banner); mutation?.observe(banner, { attributes: true, attributeFilter: ['hidden'] }); }
    window.addEventListener('resize', position);
    position();
  });
}
