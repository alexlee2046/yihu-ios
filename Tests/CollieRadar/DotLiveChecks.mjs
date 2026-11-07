import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

const swift = fs.readFileSync('Apps/Collie/CollieDotLive.swift', 'utf8');
const source = swift.match(/static let source = #"""\n([\s\S]*?)\n    """#/)[1];
const webView = fs.readFileSync('Apps/Collie/CollieWebView.swift', 'utf8');
assert(webView.includes('CollieDotLive.userScript(origin: session.trustedOrigin)'));
assert(webView.includes('return .prompt'));
assert(!webView.includes('return .grant'));
assert(swift.includes('location.origin ==='));
assert(swift.includes('url?.scheme == "https" && url?.port == 10000'));

const deferred = () => {
  let resolve, reject;
  const promise = new Promise((a, b) => { resolve = a; reject = b; });
  return {promise, resolve, reject};
};
const flush = async () => { for (let i = 0; i < 25; i++) await Promise.resolve(); };
function fixture({media, allocation, attachOK = true} = {}) {
  const elements = new Map(), events = {}, requests = [], native = [];
  let mediaCalls = 0, stopped = 0, closed = 0, observe;
  const track = {enabled: true, stop() { stopped++; }};
  const stream = {getTracks: () => [track], getAudioTracks: () => [track]};
  class Element {
    constructor() { this.listeners = {}; this.style = {}; }
    setAttribute(k, v) { this[k] = v; }
    append(...children) { children.forEach(x => this.appendChild(x)); }
    appendChild(child) { if (child.id) elements.set(child.id, child); }
    addEventListener(name, handler) { this.listeners[name] = handler; }
    click() { this.listeners.click({preventDefault() {}, stopPropagation() {}}); }
    pause() {}
    play() { return Promise.resolve(); }
  }
  class Peer {
    createDataChannel() {}
    addTrack() {}
    createOffer() { return Promise.resolve({type: 'offer', sdp: 'synthetic offer'}); }
    setLocalDescription(offer) { this.localDescription = offer; return Promise.resolve(); }
    setRemoteDescription() { return Promise.resolve(); }
    close() { closed++; }
  }
  const context = vm.createContext({
    document: {body: new Element(), documentElement: new Element(),
      createElement: () => new Element(), getElementById: id => elements.get(id)},
    window: {webkit: {messageHandlers: {collieDotVoiceCall: {postMessage: x => native.push(x.action)}}},
      addEventListener: (name, handler) => { events[name] = handler; }},
    navigator: {mediaDevices: {getUserMedia: () => { mediaCalls++; return media?.promise ?? Promise.resolve(stream); }}},
    RTCPeerConnection: Peer,
    MutationObserver: class { constructor(fn) { observe = fn; } observe() {} disconnect() {} },
    fetch: async (url, options) => {
      requests.push({url, ...options, body: JSON.parse(options.body)});
      if (url.endsWith('/call') && allocation) return allocation.promise;
      return {ok: !url.endsWith('/attach') || attachOK,
        json: async () => ({ok: !url.endsWith('/attach') || attachOK, callId: 'synthetic-call', answer: 'synthetic answer'})};
    }
  });
  vm.runInContext(source, context);
  return {elements, events, requests, native, stream, track, context, observe,
    call: () => elements.get('yihu-dot-live-call').click(),
    status: () => elements.get('yihu-dot-live-status').textContent,
    counts: () => ({mediaCalls, stopped, closed})};
}

{
  const f = fixture();
  assert.equal(f.elements.get('yihu-dot-live-call').textContent, 'Live 通话');
  assert.equal(f.counts().mediaCalls, 0, 'mount must not activate the microphone');
  assert.equal(f.requests.length, 0, 'mount must not allocate a remote call');
  const button = f.elements.get('yihu-dot-live-call');
  vm.runInContext(source, f.context);
  assert.equal(f.elements.get('yihu-dot-live-call'), button, 'duplicate injection is inert');
  await f.call(); await flush();
  assert.equal(f.status(), '通话中');
  f.elements.get('yihu-dot-live-mute').click();
  assert.equal(f.track.enabled, false);
  f.elements.get('yihu-dot-live-mute').click();
  assert.equal(f.track.enabled, true);
  f.call(); await flush();
  assert.deepEqual(f.counts(), {mediaCalls: 1, stopped: 1, closed: 1});
  assert.deepEqual(f.native, ['start', 'stop']);
  assert.deepEqual(f.requests.map(x => x.url), ['/dot-voice/call', '/dot-voice/attach', '/dot-voice/stop']);
  assert(f.requests.every(x => x.credentials === 'same-origin' && x.redirect === 'error'));
}
{
  const media = deferred(), f = fixture({media});
  f.call(); f.call();
  media.resolve(f.stream); await flush();
  assert.equal(f.counts().stopped, 1, 'late permission stream is released after cancel');
  assert.equal(f.requests.length, 0);
}
{
  const allocation = deferred(), f = fixture({allocation});
  f.call(); await flush(); f.call();
  allocation.resolve({ok: true, json: async () => ({ok: true, callId: 'late-call', answer: 'answer'})});
  await flush();
  assert.equal(f.requests.at(-1).url, '/dot-voice/stop');
  assert.equal(f.requests.at(-1).body.callId, 'late-call');
  assert(!f.requests.some(x => x.url.endsWith('/attach')), 'cancelled allocation must not attach');
}
{
  const f = fixture({attachOK: false});
  f.call(); await flush();
  assert(f.status().includes('通话失败'));
  assert.equal(f.requests.at(-1).url, '/dot-voice/stop');
  assert.equal(f.counts().stopped, 1);
}
{
  const media = deferred(), f = fixture({media});
  f.call(); media.reject(new Error('permission denied')); await flush();
  assert(f.status().includes('麦克风权限'));
  assert.equal(f.requests.length, 0);
  assert.deepEqual(f.native, ['start', 'stop']);
}
{
  const f = fixture(); f.call(); await flush();
  f.events.pagehide(); await flush();
  assert.equal(f.counts().stopped, 1, 'leaving the document releases capture');
  assert.equal(f.requests.at(-1).url, '/dot-voice/stop');
  f.events.pageshow();
  f.elements.delete('yihu-dot-live'); f.observe();
  assert(f.elements.has('yihu-dot-live'), 'SPA body replacement remounts the button');
  assert.equal(f.counts().mediaCalls, 1, 'remount does not start another call');
}
console.log('Dot Live checks passed: mount, opt-in, mute, cancel races, failure, teardown and remount');
