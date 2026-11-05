# SYN-REBIND-36 — 前台切回 / Foreground rebind preflight

**SYNTHETIC_EXAMPLE** · 不是设备录音/抓包/客服工单；not device logs, an App import protocol or a promise of lockscreen/background listening. Fixed source #57@45495e8888618fd1ec26607f7bf3d875549e68c4 / tree05150cb785391a85ea8d402fb787a026553d1a7f, not a store-binary parity assertion.

## 第一动作 / First action

先区分permission-sheet inactive与真正background；核UI phase、当前session、许可、模型、输入UID/格式、待处理文字及目标。前台回调不是自动重绑/已录音/已ASR/已交接回执。Inactive during preparing+permission request preserves that request; true background cancels cancellable phases. `canCancel` excludes ready/delivering; cancellation is not rollback of previous writes.

10 lifecycle cases,7 shortcut cases,7 format/route cases per language execute only original-method Foundation memory adapters.4 buffer-recovery notes are source reading only. Fake recorder start/cancel, tasks, preview/prewarm/failure sink and fake AV format/session types do not prove iOS scheduling, framework behavior or physical audio. `old_permission_guard_passes` observes session/preparing identity after the lifecycle method, not an executed real permission continuation.7 shortcut cases use real ContinuousClock instants advanced without waiting, with verbatim request/consume and30s lifetime. No Siri, shortcuts or hardware binding is invoked.

## 现在可核 / Review now

- **L1 vs L2/L3**: preparing+consent inactive differs from background/non-consent inactive. Old cancelled session must not take a late grant; active alone cannot resurrect it.
- **L4/L5**: recording/transcribing are cancellable; cancellation invalidates session and calls memory recorder.cancel, not certified silence/no-loss/resume.
- **L6/L7**: empty-string pending remains non-nil; ready/delivering are not this cancel path. Existing target content and possible previous side effects still need evidence.
- **L8/L9/L10**: start requires preparing+granted+foreground. Memory start throw goes to failure; no forced rebind or automatic retry guarantee.
- **S1–S7**: no request false;29.999s true;30.000s inclusive true once;30.001s false; repeated requests refresh one Bool/time; even expired consume clears the pending/time.30 seconds is freshness, not responsiveness or background authority.
- **F1–F7**: source compares rate/channels/commonFormat/interleaving and sorted input UIDs. Same UID set reordered is not drift; changed port with same format is still drift. Same format alone does not certify the converter/route/buffer as safe.
- **B1–B4**: active callback doesn't directly rebind the audio engine. Source engine-change recovery may retain converter/PCM only conditionally when format is unchanged; changed format/configure/start error fails and stops. Route/interruption guards are independent. These are not real buffer captures or hardware recovery results.

## 双语工作表 / Bilingual worksheets


### zh

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| L1 | 权限弹窗inactive保留准备请求 | phase=preparing; session_changed=false; cancel/start=0/0 | Memory spy only; no real permission/capture/handoff |
| L2 | 真正background使旧请求失效；迟到许可不能复活 | phase=failed; session_changed=true; cancel/start=1/0 | Memory spy only; no real permission/capture/handoff |
| L3 | 非许可弹窗的inactive取消准备 | phase=failed; session_changed=true; cancel/start=1/0 | Memory spy only; no real permission/capture/handoff |
| L4 | 录音后台取消，不承诺续录 | phase=failed; session_changed=true; cancel/start=1/0 | Memory spy only; no real permission/capture/handoff |
| L5 | 转写离活动态取消，不抹已发生副作用 | phase=failed; session_changed=true; cancel/start=1/0 | Memory spy only; no real permission/capture/handoff |
| L6 | ready且空字符串pending仍保留，不自动交接 | phase=ready; session_changed=false; cancel/start=0/0 | Memory spy only; no real permission/capture/handoff |
| L7 | delivering不在canCancel集合，不能宣已撤回 | phase=delivering; session_changed=false; cancel/start=0/0 | Memory spy only; no real permission/capture/handoff |
| L8 | active但尚不在foreground不启动 | phase=preparing; session_changed=false; cancel/start=0/0 | Memory spy only; no real permission/capture/handoff |
| L9 | 许可+前台+准备才调用内存采集spy | phase=recording; session_changed=false; cancel/start=0/1 | Memory spy only; no real permission/capture/handoff |
| L10 | 内存start抛错走失败，不强制重绑 | phase=failed; session_changed=false; cancel/start=0/1 | Memory spy only; no real permission/capture/handoff |
| S1 | request_ms=[]; consume_ms=[0] | consume=[False]; pending Bool consumed/expired, not a queue | Injected monotonic instants; no Siri binding or30s SLA |
| S2 | request_ms=[0]; consume_ms=[29999] | consume=[True]; pending Bool consumed/expired, not a queue | Injected monotonic instants; no Siri binding or30s SLA |
| S3 | request_ms=[0]; consume_ms=[30000, 30001] | consume=[True, False]; pending Bool consumed/expired, not a queue | Injected monotonic instants; no Siri binding or30s SLA |
| S4 | request_ms=[0]; consume_ms=[30001] | consume=[False]; pending Bool consumed/expired, not a queue | Injected monotonic instants; no Siri binding or30s SLA |
| S5 | request_ms=[0, 25000]; consume_ms=[50000, 50001] | consume=[True, False]; pending Bool consumed/expired, not a queue | Injected monotonic instants; no Siri binding or30s SLA |
| S6 | request_ms=[0]; consume_ms=[31000, 31000] | consume=[False, False]; pending Bool consumed/expired, not a queue | Injected monotonic instants; no Siri binding or30s SLA |
| S7 | request_ms=[0, 1, 2]; consume_ms=[3, 4, 5] | consume=[True, False, False]; pending Bool consumed/expired, not a queue | Injected monotonic instants; no Siri binding or30s SLA |
| F1 | {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False} → {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False}; inputs=['port-A', 'port-B'] | same format=True; same sorted UIDs=True | Fake formats/ports; no physical route or real PCM |
| F2 | {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False} → {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False}; inputs=['port-B', 'port-A'] | same format=True; same sorted UIDs=True | Fake formats/ports; no physical route or real PCM |
| F3 | {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False} → {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False}; inputs=['port-C'] | same format=True; same sorted UIDs=False | Fake formats/ports; no physical route or real PCM |
| F4 | {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False} → {'sample_rate': 44100, 'channels': 1, 'common_format': 1, 'interleaved': False}; inputs=['port-A', 'port-B'] | same format=False; same sorted UIDs=True | Fake formats/ports; no physical route or real PCM |
| F5 | {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False} → {'sample_rate': 48000, 'channels': 2, 'common_format': 1, 'interleaved': False}; inputs=['port-A', 'port-B'] | same format=False; same sorted UIDs=True | Fake formats/ports; no physical route or real PCM |
| F6 | {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False} → {'sample_rate': 48000, 'channels': 1, 'common_format': 3, 'interleaved': False}; inputs=['port-A', 'port-B'] | same format=False; same sorted UIDs=True | Fake formats/ports; no physical route or real PCM |
| F7 | {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False} → {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': True}; inputs=['port-A', 'port-B'] | same format=False; same sorted UIDs=True | Fake formats/ports; no physical route or real PCM |
| B1 | foreground callback alone | startCaptureIfReady + prewarm; not direct engine recovery | Source read only; runtime not_run |
| B2 | current-token engine-change recovery with unchanged format | source keeps converter/PCM, reinstalls tap; conditional source path, no no-loss guarantee | Source read only; runtime not_run |
| B3 | changed native format or configure/start throw | source fails pipeline, clears recordingActive and stops engine; no padding/relabel fix | Source read only; runtime not_run |
| B4 | input UID drift even with equal format | source route comparison is false; route notifications and expected-recovery suppression have independent guards | Source read only; runtime not_run |

### en

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| L1 | Consent-sheet inactive retains preparing request | phase=preparing; session_changed=false; cancel/start=0/0 | Memory spy only; no real permission/capture/handoff |
| L2 | Real background invalidates old request; late grant cannot revive it | phase=failed; session_changed=true; cancel/start=1/0 | Memory spy only; no real permission/capture/handoff |
| L3 | Inactive without permission request cancels preparing | phase=failed; session_changed=true; cancel/start=1/0 | Memory spy only; no real permission/capture/handoff |
| L4 | Recording is cancelled on background, not promised continuous | phase=failed; session_changed=true; cancel/start=1/0 | Memory spy only; no real permission/capture/handoff |
| L5 | Leaving active cancels transcription, not existing side effects | phase=failed; session_changed=true; cancel/start=1/0 | Memory spy only; no real permission/capture/handoff |
| L6 | Ready with empty-string pending retains it, no automatic handoff | phase=ready; session_changed=false; cancel/start=0/0 | Memory spy only; no real permission/capture/handoff |
| L7 | Delivering is outside canCancel; no rollback assertion | phase=delivering; session_changed=false; cancel/start=0/0 | Memory spy only; no real permission/capture/handoff |
| L8 | Active callback while foreground predicate false cannot start | phase=preparing; session_changed=false; cancel/start=0/0 | Memory spy only; no real permission/capture/handoff |
| L9 | Permission plus foreground plus preparing calls memory recorder spy | phase=recording; session_changed=false; cancel/start=0/1 | Memory spy only; no real permission/capture/handoff |
| L10 | Memory start throw fails; no forced rebind | phase=failed; session_changed=false; cancel/start=0/1 | Memory spy only; no real permission/capture/handoff |
| S1 | request_ms=[]; consume_ms=[0] | consume=[False]; pending Bool consumed/expired, not a queue | Injected monotonic instants; no Siri binding or30s SLA |
| S2 | request_ms=[0]; consume_ms=[29999] | consume=[True]; pending Bool consumed/expired, not a queue | Injected monotonic instants; no Siri binding or30s SLA |
| S3 | request_ms=[0]; consume_ms=[30000, 30001] | consume=[True, False]; pending Bool consumed/expired, not a queue | Injected monotonic instants; no Siri binding or30s SLA |
| S4 | request_ms=[0]; consume_ms=[30001] | consume=[False]; pending Bool consumed/expired, not a queue | Injected monotonic instants; no Siri binding or30s SLA |
| S5 | request_ms=[0, 25000]; consume_ms=[50000, 50001] | consume=[True, False]; pending Bool consumed/expired, not a queue | Injected monotonic instants; no Siri binding or30s SLA |
| S6 | request_ms=[0]; consume_ms=[31000, 31000] | consume=[False, False]; pending Bool consumed/expired, not a queue | Injected monotonic instants; no Siri binding or30s SLA |
| S7 | request_ms=[0, 1, 2]; consume_ms=[3, 4, 5] | consume=[True, False, False]; pending Bool consumed/expired, not a queue | Injected monotonic instants; no Siri binding or30s SLA |
| F1 | {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False} → {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False}; inputs=['port-A', 'port-B'] | same format=True; same sorted UIDs=True | Fake formats/ports; no physical route or real PCM |
| F2 | {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False} → {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False}; inputs=['port-B', 'port-A'] | same format=True; same sorted UIDs=True | Fake formats/ports; no physical route or real PCM |
| F3 | {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False} → {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False}; inputs=['port-C'] | same format=True; same sorted UIDs=False | Fake formats/ports; no physical route or real PCM |
| F4 | {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False} → {'sample_rate': 44100, 'channels': 1, 'common_format': 1, 'interleaved': False}; inputs=['port-A', 'port-B'] | same format=False; same sorted UIDs=True | Fake formats/ports; no physical route or real PCM |
| F5 | {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False} → {'sample_rate': 48000, 'channels': 2, 'common_format': 1, 'interleaved': False}; inputs=['port-A', 'port-B'] | same format=False; same sorted UIDs=True | Fake formats/ports; no physical route or real PCM |
| F6 | {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False} → {'sample_rate': 48000, 'channels': 1, 'common_format': 3, 'interleaved': False}; inputs=['port-A', 'port-B'] | same format=False; same sorted UIDs=True | Fake formats/ports; no physical route or real PCM |
| F7 | {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': False} → {'sample_rate': 48000, 'channels': 1, 'common_format': 1, 'interleaved': True}; inputs=['port-A', 'port-B'] | same format=False; same sorted UIDs=True | Fake formats/ports; no physical route or real PCM |
| B1 | foreground callback alone | startCaptureIfReady + prewarm; not direct engine recovery | Source read only; runtime not_run |
| B2 | current-token engine-change recovery with unchanged format | source keeps converter/PCM, reinstalls tap; conditional source path, no no-loss guarantee | Source read only; runtime not_run |
| B3 | changed native format or configure/start throw | source fails pipeline, clears recordingActive and stops engine; no padding/relabel fix | Source read only; runtime not_run |
| B4 | input UID drift even with equal format | source route comparison is false; route notifications and expected-recovery suppression have independent guards | Source read only; runtime not_run |

## Go / No-Go and destination

只有明确的新鲜用户选择、当前UI/许可/模型/输入与安全目的地已核，才考虑现有入口下一步。Unknown event, changed request/port/format, retained text, uncertain old side effects, busy/notes-open/non-active workbench or expired intent => stop in scope; retain original failure, no blind rerecord/refill/resend. These are manual decision criteria, not implemented extra app guards or certified device Go.

Shell source: active calls voice prep/prewarm, note resume, share refresh and pending shortcut handling; non-active calls short-voice resign and note pause, then dismisses keyboard. `resumeTranscription` is not live microphone continuity. Existing runPendingShortcut requires active workbench/scene, no note presentation/recording; ready without retained text starts through the normal action, recording can stop through it. This shell flow was read, not executed with SwiftUI/AppIntents.

官方US商店保存证据沿11/05观察0.1.0（非11/06新查最新版本），id6819057500，iOS18+；安装商店版不需要Mac/Xcode/自签名，不证全球可用。Bring your own trusted HTTPS workspace/account; verify model, microphone permission and destination. Optional model about950MB per store description, separate from installing the app. Destination may save/sync/auto-process; App not auto-sending is not a global all-data-stays-local claim. Source availability must be checked against installed version. https://apps.apple.com/us/app/yihu/id6819057500

Real scene events, permission sheets, input port drift, buffer/format conversion, background/lockscreen recording, Siri/Action Button, ASR accuracy, insertion/send and hardware/performance/SLA: **not_run**. No always-on listener, no zero-loss recovery or automatic repair promise; no synthetic padding advertised as recovered audio.

No production deployment/IndexNow/Google calls or new authorizations here. Retired shortcut pages remain false without downloads; only active foreground pair may link this pack. Source canonical https://getyihu.com remains unchanged; dispatch label yihu.st is not migration authorization.
