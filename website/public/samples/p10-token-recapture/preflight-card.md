# SYN-TOKEN-33 · 录音中断重采与采集完成令牌预检
# Recapture and capture-completion-token preflight

**纯合成、已填源码参考；没有真实录音/用户验收。Synthetic worked source reference, not a recording or user-test report.**

[中文JSON](token-recapture-preflight.zh.json) · [English JSON](token-recapture-preflight.en.json)

两语言是同一例的替代版，不合并导入App。机读操作/字段不翻译。令牌A/B为手工虚构UUID，只表示隔离夹具中两次采集；不是设备ID、账户身份、签名、写权或跨服务幂等键。本包不注入系统回调、不发通知、不运行真实麦克风/管线。

Choose one language variant; these are not app-import files. Machine operations/keys stay stable. Invented A/B UUIDs correlate two fixture captures, not device/account identity, signatures, write authority or cross-service idempotency. No OS callback injection, notifications, microphone or native pipeline is used.

## 先分清源码层次 / Separate the source layers

固定M的令牌守卫直接位于`CollieAudioRecorder`的start/stop/cancel/captureCompleted方法，没有独立可编译的completion-token helper。实际编译核验使用**原方法逐字提取的Foundation隔离适配器**：引擎、管线、导出/观察者/会话清理由内存替身承接。`seed`手工置入合成起始状态，不执行真实start或UUID生成；`complete_*`只调用适配器中的原完成方法，不是给运行中的App注入回调。

The pinned source has no standalone completion-token helper. The guard lives inside recorder methods. The compilation check uses **verbatim source methods in a Foundation-only adapter**, with memory spies for engine, pipeline, export and session/observer effects. `seed` supplies synthetic initial state; it does not run real start/UUID generation. `complete_*` calls the extracted method in isolation, not an app/OS callback.

只核这些方法在给定顺序下的令牌/状态/回调守卫，不证明真实队列排空、线程竞争、存储或设备安全。允许匹配的合成success仅表示回调分支，不是ASR或实际录音成功；`export_spy_calls`是内存计数，不是写出了音频文件。

This checks token/state/callback behavior in the supplied order, not queue draining, races, persistence or device behavior. A matching synthetic success is a callback branch, not successful capture or ASR. `export_spy_calls` counts an in-memory spy, not an exported audio file.

## 已填21步参考 / Twenty-one worked operations

| 组 / Run | 完整操作链 / Preset sequence | 已填答案 / Worked answer |
| --- | --- | --- |
| T1 · 6步 /6 steps | seed A → stop → probe_start → A success → A repeated success → probe_start | stop后recordingActive=false，但A与pipeline仍保留；排空前源码start的前两guard报busy。匹配A完成后清令牌/管线、回调1次；重复A忽略；最后只到“会进入权限检查”的边界，不代表已获权限。/ Stop retains A/pipeline while draining; the two source start guards report busy. Matching completion cleans up and forwards once; duplicate A is ignored. Final probe reaches only the unexecuted permission boundary. |
| T2 · 8步 /8 steps | seed A → cancel → A success → probe_start → seed B → A late success → B success → B repeated success | cancel清A并取消/移除管线；空闲或B期间的旧A都不导出/回调、不清理B。仅B匹配后回调1次，随后重复B忽略。/ Cancellation invalidates A; obsolete A neither forwards/exports nor cleans up B. Only matching B forwards; its repeat is ignored. |
| T3 · 7步 /7 steps | seed A → stop → A failure → seed B → A late failure → B failure → B repeated failure | 当前失败也要清理并转发failure；旧A失败不损坏B。A/B失败共回调2次、success/export spy均0，不走成功final结论。/ Current failures clean up and forward failure. Obsolete A leaves B intact. Two failures, no success/export claim. |

`probe_start`只执行原start前两条guard：正在录音时原入口会no-op；recordingActive=false但pipeline非空时busy；为空才继续到后续权限检查。夹具**不执行**权限、engine/tap启动、原UUID创建或新采集准入全流程。T2/T3只有旧管线已清后才手工seed B，不把stop未排空时直接替换B当合法start。

The probe runs only the two original start preconditions. It is not a permission grant or a real start. B is seeded only after the previous pipeline was cleared; a stopped-but-not-drained A is not silently replaced by B.

**同一阶段/同一句话不能替代令牌匹配。** 完成守卫先比activeToken；不匹配即返回，不能把旧A回调当成B，也不应清理B。匹配的完成清理后再转发结果；这不是任意路径、任意重启、网络或服务端的exactly-once保证。控制器sessionID、前台/目标守卫另有分工，不能混为同一个令牌。

**Same phase or same words do not replace token matching.** A mismatched completion returns before cleanup. Matching completion cleans up then forwards. This is not universal exactly-once across restarts, networks or services; controller sessionID and foreground/destination guards are separate.

## 已填重采范围核对 / Filled recapture worksheet

- **原A / Original A：**纸面设定已有材料可用；本包没有真实文件或音频可证明它。/ Availability is a paper assumption, not a verified file here.
- **段B / Segment B：**是否保存、是否有缺口仍未知。没有文字不等于没有音频；“已中断”也不证明此前全失。/ Saved/gap status is unknown; absent text is not proof of absent audio or complete loss.
- **当前决定 / Decision：**先核实际文件、待转写状态、原版本与目标已有草稿。未知就停，不从头重采、不让模型补造失录原话。/ Inspect real material, transcription state, version and existing draft first. Stop for unknowns; do not rerecord everything or generate missing original speech.
- **条件后续 / Conditional next step：**若另有真实证据确认只缺B、且另外获准练习，才另录`B-v2`并注明新版本，保留A/B原件和缺口说明。不覆盖旧稿、不伪装连续录音、不自动合并/去重/重发。/ Only separately confirmed gaps and authorization justify a new B-v2; preserve originals and version/gap notes, without fabricated continuity or auto-merge/resend.

长笔记写盘/中断与短语音不是同一路径。源码的长笔记writer有已写部分与失败状态处理，但不能据此宣称任何掉电/锁屏/存储条件都零丢失，或商店0.1.0已完整交付源码长笔记功能。短语音失败也不承诺保存此前音频。

Long-note persistence and short voice are different source paths. Written portions/failure handling are not a universal power/lock/storage survival guarantee or certification of long-note features in store0.1.0. Short-voice failure does not promise saved partial audio.

## 独立商店版短句 / Separate store-edition phrase

截至2026-11-02，美区官方lookup仍**Yihu0.1.0 / id6819057500 / iOS18+**。[真实US App Store](https://apps.apple.com/us/app/yihu/id6819057500) · [中文商店版上手](https://getyihu.com/start/#store-start) · [English setup](https://getyihu.com/en/start/#store-start)。地区供应以实际商店为准；安装不需Mac/自行签名，需自有可信工作台/账号，可选语音模型约950MB。

US lookup rechecked2026-11-02: **0.1.0 / id6819057500 / iOS18+**. Availability follows the storefront. Store installation needs no Mac/self-signing; bring your own trusted workspace/account, with an optional speech model about950MB. Source contracts do not certify binary parity or prove those implementations absent.

**可照读中文，理想逐字文本相同，不是已测ASR：**
> 样本三十三。先核对九号附件，不提交，也不覆盖旧稿。

**English phrase and ideal verbatim text, not observed ASR:**
> Sample thirty-three. Check attachment nine first; do not submit or overwrite the old draft.

如另获准真实练习，安全停下、前台使用新空白练习草稿；先核权限、模型、当前输入和目的地不会自动执行/发送。检查33、9与两个否定词，不把不同次音频拼成无中断成功。已有文字先看，不盲重插；到未发送草稿即停，不按Send/Run、不后台常驻监听。App不代发不保证目的地不保存/同步/处理；取消也不是撤销已发生的远端副作用。

Only separately authorized, stationary foreground practice in an empty training draft, with known permissions/model/input and no downstream execution. Check33,9 and both negations. Inspect before repeating insertion. Stop unsent; no Send/Run or background listening. Destinations may save/sync/process; cancellation does not undo remote effects already incurred.

| 真实动作 / Real action | 本包状态 / Status |
| --- | --- |
| 真机中断、锁屏/低电量、真实重采 / device interruption, lock/battery, recapture | not_run |
| 原生引擎、PCM排空/写盘、并发压力 / engine, drain/persistence, concurrency | not_run |
| ASR、填入、发送/送达 / ASR, insertion, send/delivery | not_run |
| 账户身份/写权与远端回撤 / identity/authority, remote undo | not_run |

## 固定一手来源 / Fixed first-party references

采集2026-11-02，基底M`318dbfaa9976568ff6c052c011a5e636612f6419`，是已合入主干源证，**不据此宣本包已部署或商店新交付**。
- [start绑定回调与activeToken](https://github.com/alexlee2046/yihu-ios/blob/318dbfaa9976568ff6c052c011a5e636612f6419/Apps/Collie/CollieAudioRecorder.swift#L99-L154)
- [stop/cancel/captureCompleted](https://github.com/alexlee2046/yihu-ios/blob/318dbfaa9976568ff6c052c011a5e636612f6419/Apps/Collie/CollieAudioRecorder.swift#L194-L256)
- [原PCM停止/取消/完成守卫](https://github.com/alexlee2046/yihu-ios/blob/318dbfaa9976568ff6c052c011a5e636612f6419/Apps/Collie/ColliePCMStream.swift#L270-L420)，只作源码依据，未运行原PCM队列。
- [长笔记writer](https://github.com/alexlee2046/yihu-ios/blob/318dbfaa9976568ff6c052c011a5e636612f6419/Apps/Collie/CollieNoteRecorder.swift#L9-L87)，不是本包存储实测。
- [中文在役重采指南](https://getyihu.com/guides/interruption-recapture-preflight/) · [English active recapture guide](https://getyihu.com/en/guides/interruption-recapture-preflight/)

新写合成文字Apache-2.0，既有源码保原许可；无真实客户正文、设备UID、账户或凭据，不新增录音/回复/身份后端。
