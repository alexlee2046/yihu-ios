import Foundation
import WebKit

/// The existing private Dot workbench uses :10000 and /dot-voice signaling.
/// No credentials, public ingress or automatic calls are introduced here.
@MainActor
enum CollieDotLive {
    static func supports(_ url: URL?) -> Bool {
        url?.scheme == "https" && url?.port == 10000 && url?.host != nil
    }

    static func userScript(origin: String) -> WKUserScript? {
        guard supports(URL(string: origin)),
              let data = try? JSONEncoder().encode(origin),
              let literal = String(data: data, encoding: .utf8) else { return nil }
        return WKUserScript(
            source: "if (window === window.top && location.origin === \(literal)) {\n" + source + "\n}",
            injectionTime: .atDocumentEnd, forMainFrameOnly: true
        )
    }

    static let source = #"""
    (() => {
      if (window.__yihuDotLive) return;
      window.__yihuDotLive = true;
      let current = null;
      let ended = false;
      const native = action => {
        try { window.webkit?.messageHandlers?.collieDotVoiceCall?.postMessage({action}); } catch {}
      };
      const post = async (path, body) => {
        const response = await fetch('/dot-voice/' + path, {
          method: 'POST', credentials: 'same-origin', redirect: 'error',
          headers: {'Content-Type': 'application/json'}, body: JSON.stringify(body),
          keepalive: path === 'stop'
        });
        const result = await response.json();
        if (!response.ok || result.ok !== true) throw new Error('signaling failed');
        return result;
      };
      const releaseRemote = id => {
        if (id) void post('stop', {callId: id}).catch(() => {});
      };
      function paint(label) {
        const call = document.getElementById('yihu-dot-live-call');
        const mute = document.getElementById('yihu-dot-live-mute');
        const status = document.getElementById('yihu-dot-live-status');
        if (!call) return;
        call.textContent = current ? (current.connected ? '挂断' : '取消') : 'Live 通话';
        mute.hidden = !current?.connected;
        mute.textContent = current?.muted ? '取消静音' : '静音';
        mute.setAttribute('aria-pressed', String(!!current?.muted));
        status.textContent = label ?? (current ? (current.connected ? '通话中' : '连接中…') : '');
      }
      function stop(label = '') {
        const call = current;
        current = null; // invalidate pending permission, allocation and attachment first
        if (call) {
          call.stream?.getTracks().forEach(track => track.stop());
          if (call.pc) { call.pc.onconnectionstatechange = null; call.pc.close(); }
          if (call.audio) { call.audio.pause(); call.audio.srcObject = null; }
          releaseRemote(call.id);
          native('stop');
        }
        paint(label);
      }
      async function start() {
        if (current || ended) return;
        const call = {muted: false, connected: false};
        current = call;
        paint();
        native('start');
        try {
          const stream = await navigator.mediaDevices.getUserMedia({audio: {
            echoCancellation: true, noiseSuppression: true, autoGainControl: true
          }});
          if (current !== call) { stream.getTracks().forEach(track => track.stop()); return; }
          call.stream = stream;
          const pc = call.pc = new RTCPeerConnection();
          pc.createDataChannel('oai-events');
          const audio = call.audio = document.createElement('audio');
          audio.autoplay = true;
          audio.playsInline = true;
          pc.ontrack = event => {
            if (current !== call) return;
            audio.srcObject = event.streams[0] || new MediaStream([event.track]);
            void audio.play().catch(() => { if (current === call) stop('播放失败，请重试'); });
          };
          pc.onconnectionstatechange = () => {
            if (current === call && ['failed', 'disconnected', 'closed'].includes(pc.connectionState)) {
              stop('连接已断开，请重试');
            }
          };
          stream.getAudioTracks().forEach(track => pc.addTrack(track, stream));
          await pc.setLocalDescription(await pc.createOffer());
          if (current !== call) return;
          const result = await post('call', {sdp: pc.localDescription.sdp});
          if (current !== call) { releaseRemote(result.callId); return; }
          call.id = result.callId;
          if (typeof call.id !== 'string' || !call.id || typeof result.answer !== 'string' || !result.answer) {
            throw new Error('invalid allocation');
          }
          await pc.setRemoteDescription({type: 'answer', sdp: result.answer});
          if (current !== call) return;
          await post('attach', {callId: call.id});
          if (current !== call) return;
          call.connected = true;
          paint();
        } catch {
          if (current === call) stop('通话失败，请检查麦克风权限及服务后重试');
        }
      }
      function mount() {
        if (ended || !document.body || document.getElementById('yihu-dot-live')) return;
        const bar = document.createElement('div');
        bar.id = 'yihu-dot-live';
        bar.setAttribute('role', 'group');
        bar.setAttribute('aria-label', 'Dot Live 通话');
        bar.style.cssText = 'position:fixed;right:12px;bottom:calc(86px + env(safe-area-inset-bottom));z-index:2147483640;display:flex;flex-wrap:wrap;max-width:calc(100vw - 24px);gap:8px;align-items:center;padding:8px;border-radius:16px;background:#18212b;color:white;font:14px -apple-system,sans-serif';
        const status = document.createElement('span');
        status.id = 'yihu-dot-live-status';
        status.setAttribute('role', 'status');
        status.setAttribute('aria-live', 'polite');
        const call = document.createElement('button');
        call.id = 'yihu-dot-live-call';
        call.type = 'button';
        call.style.cssText = 'min-height:44px;min-width:44px;border:0;border-radius:12px;padding:8px 12px;background:#087e68;color:white;font:inherit';
        call.addEventListener('click', event => {
          event.preventDefault(); event.stopPropagation();
          if (current) stop(); else void start();
        });
        const mute = document.createElement('button');
        mute.id = 'yihu-dot-live-mute';
        mute.type = 'button';
        mute.style.cssText = 'min-height:44px;min-width:44px;border:0;border-radius:12px;padding:8px 12px;background:#364554;color:white;font:inherit';
        mute.addEventListener('click', event => {
          event.preventDefault(); event.stopPropagation();
          if (!current?.stream) return;
          current.muted = !current.muted;
          current.stream.getAudioTracks().forEach(track => { track.enabled = !current.muted; });
          paint();
        });
        bar.append(status, mute, call);
        document.body.appendChild(bar);
        paint();
      }
      const observer = new MutationObserver(mount);
      observer.observe(document.documentElement, {childList: true, subtree: true});
      window.addEventListener('pagehide', () => { ended = true; observer.disconnect(); stop(); });
      window.addEventListener('pageshow', () => {
        if (!ended) return;
        ended = false;
        observer.observe(document.documentElement, {childList: true, subtree: true});
        mount();
      });
      mount();
    })();
    """#
}
