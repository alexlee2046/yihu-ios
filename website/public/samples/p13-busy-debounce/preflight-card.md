# SYN-BUSY-36 · 忙态准入与通知防抖的分层预检
# Busy admission and notification debounce: separate evidence

**合成已填参考，不是真机录音/系统路由/外设恢复报告。Synthetic worked reference, not a device, route or accessory-recovery report.**

[中文JSON](busy-debounce-preflight.zh.json) · [English JSON](busy-debounce-preflight.en.json)

同一例的语言替代版，8场景/30步每语言；机读操作/phase保原名。非App配置导入，不注入OS通知、不改真实忙态/权限/声纹标记。preset、permission/foreground及engine等flag全是夹具输入，不是设备观测。

Choose one language variant; eight scenarios/thirty operations each. Machine names remain stable. Not app configuration or OS notification injection. Presets/readiness/engine flags are invented inputs, not observations or instructions to change real protection flags.

## 三层不可互推 / Do not collapse three layers

| 层 / Layer | 本例核什么 / What is checked | 不能据此认定 / Not established |
| --- | --- | --- |
| 主语音controller | primaryActionEnabled、canCancel、canRetryDelivery、isRecording、测试mic保留与前台准备条件 / local properties, reservation, preparing gate | 按钮true就是新采集可开始，或全局音频已空闲 / enabled means new capture or global idle |
| 底层recorder | 原start前两guard：已recording则no-op、pipeline未清则busy，之后才到权限边界 / two start guards only | 已获权限、完整engine/tap启动或任意入口都获准 / permission, real start or every entry admitted |
| 恢复debouncer | 原Date/token/engine/format/route抑制条件 / original suppression predicate | 释放忙态、重录/重发权、外设恢复成功或2秒SLA / admission release, recapture/send authority or recovery SLA |

这是主语音局部条件组合，不覆盖笔记worker、全部入口或全局调度器。控制器的recording字段也不能替代源recorder/system的独立实测状态。

These are selected local primary-voice predicates, not note workers, every entry point or a global scheduler. A controller phase is not independent proof of the recorder/system state.

## 已填8场景 / Eight worked scenarios

| 场景 / Case | 输入与操作 / Preset and operation | 已填答案 / Worked answer |
| --- | --- | --- |
| B1 · ready保留周期 | ready、pending=nil，claim→再claim→release | 初始按钮true；第一次claim=true后按钮false，第二次claim=false；release只清标记、按钮恢复，不启动录音 / reservation is not capture |
| B2 · 空字符串不是nil | ready、pending=""，claim→release | 按钮始终false、canRetryDelivery=true；claim仍可true，因为该局部方法不检查pending；release不删待核内容 / empty pending still blocks, reservation does not erase it |
| B3 · needsModel可点击 | needsModel，claim→release | 按钮true不等录音；claim后保留flag=true时按钮也仍true，该phase实际按钮分支是模型动作 / enabled is a model action, not readiness |
| B4 · delivering不可取消 | delivering，claim | canCancel=false但按钮false且claim=false；“不可取消”不等空闲 / non-cancellable is not idle |
| B5 · transcribing双门 | transcribing，claim/start_if_ready/底层probe | canCancel=true、isRecording=false；上层不start；底层独立probe可只到权限门，不能据此穿过上层忙态 / a free lower gate is not controller admission |
| B6 · 准备条件相交 | preparing；先无permission，再有permission但非前台，最后两者都真 | 前两次recorder start调用0；最后才调用内存start替身并进入夹具recording、预热/预览spy各1；claim仍false / permission and foreground intersect; no real start was performed |
| B7 · pipeline未清 | preparing、底层recordingActive=false但pipeline存在 | 底层原guard报busy，未执行权限或完整start；不能靠等2秒推已可录 / retained pipeline is busy, not a debounce deadline |
| B8 · 抑制与忙态正交 | recording；arm后400ms同条件true，700ms路由flag不同false，再claim | 抑制true/false后均仍recording/canCancel，claim=false；helper不把phase置ready。此phase按钮true实际表示stop，不是另开新录音 / suppression neither releases admission nor proves recovery |

B2/B3的claim结果只描述该方法局部guard，不等界面实际提供测试入口、系统许可或声纹身份通过；不能为过门删pending或手工置测试flag。正常结束测试与源码状态应由既有流程核，不通过修改这些字段“修复”业务。

B2/B3 describe a local guard, not available UI, microphone permission or voice identity. Do not delete pending content or falsify flags to pass. Use existing real flows, not fixture-field edits, for actual state changes.

## 本轮怎样核，不冒什么 / Execution scope

原controller属性、claim/release/startCaptureIfReady、recorder原前两start guard及原debouncer逐字提取到Foundation隔离适配器，未镜像重写判断。phase/pending/readiness手工预设；recorder、prewarm、preview是内存替身。

Original predicates/methods are extracted verbatim into a Foundation adapter. Initial states are manually supplied; recorder/prewarm/preview effects are memory spies, not reimplemented device logic.

- B6出现夹具phase=recording、start/预热/预览计数1，**不代表麦克风/模型/ASR已运行**；底层start只执行前两guard，完整SDK/权限不执行。
- B8只调用debouncer，**没有执行外层恢复函数/系统通知**。true会保留抑制预期，route不同返回false并清它，但不影响本例controller状态；实际外层可能重建、重arm或失败，另需设备/集成验证。
- 默认2秒是源码通知宽限，不是必须等待2秒才能再次准入、引擎恢复耗时或SLA。本例不重跑P9的2.000秒边界表，不重放P10完成回调，也不测全局并发/每种调度。
- 回调token只作关联，不是账户/硬件身份或写权；没有pending文字/保留flag也不代表实际权限、模型、前台与目的地已齐。

Fixture recording/start/prewarm/preview markers are **not real capture or inference**. Debounce is tested without the outer recovery handler. A false suppression result may lead to other source branches, not automatic admission or success. The2-second grace is no wait requirement or recovery SLA. No all-races, UI/error-mapping, identity or delivery result is established.

## 买方安全下一步 / Safe buyer next step

**当前只获离线材料可用，不从任一true报告设备Go。** 如有旧pending/未知尝试先核原内容，不丢弃/覆盖来换按钮可点；有真实测试占用就按原界面结束并确认，不反复点击录音争抢麦克风。需要即时联络沿团队现有通信方式。

**Offline use is available, not device-trial Go.** Preserve pending/uncertain results rather than deleting them to enable a button. End genuine tests through existing UI and verify state; do not repeatedly compete for the microphone. Use established communications for urgent contact.

商店边界沿用11/05已保存官方US证据 **Yihu0.1.0/id6819057500/iOS18+**，不是本包重新确认最新供应：[US App Store](https://apps.apple.com/us/app/yihu/id6819057500) · [中文商店段](https://getyihu.com/start/#store-start) · [English setup](https://getyihu.com/en/start/#store-start)。商店安装不需Mac/Xcode/自行签名；自有可信工作台/账号、可选约950MB语音模型和必要权限另核。源码行为不证明商店二进制同版，也不反推一定没有。

Version-limited store scope uses the saved11/05 official observation, not a fresh availability check. No Mac/Xcode/self-signing for store installation. Bring your own trusted workspace/account, models and permission; source contracts do not certify binary parity or absence.

**另获准且准备齐全时可照读；理想逐字文本相同，未做ASR：**
> 样本三十六。先核对二号记录，不发送，也不覆盖待核内容。

**Separately authorized phrase and ideal verbatim text, not observed ASR:**
> Sample thirty-six. Check record two first; do not send or overwrite pending content.

安全静止、前台、录音同意/权限/模型/真实忙态/目标不会自动执行都已核才另做新空白未发送练习草稿，检查36、2与否定词。先查看已有填入，不盲重插，不按Send/Run、不后台常驻监听。目的地仍可能保存/同步/处理输入；App不代发不等全数据不离机。

Only authorized stationary foreground practice with known readiness and safe destination, checking36,2 and both negations. Inspect before repeating insertion. No Send/Run or continuous background listening. A destination may save/sync/process input.

**真机中断、系统路由、外设恢复、真实权限/收音、模型预热/预览、ASR/填入/发送及全局并发全部not_run。** 不提供新的调度、认证、回写或诊断后端。

**Device interruption, system routes, accessory recovery, real permission/capture, model/preview, ASR/insertion/sending and global concurrency: all not_run.** No new scheduling/authentication/diagnostic backend.

## 固定一手依据 / Fixed first-party sources

M`915523951dfc5ae7458954c6989d3664396ef558`，不是本包已发布的证明：
- [主按钮/保留与实际动作](https://github.com/alexlee2046/yihu-ios/blob/915523951dfc5ae7458954c6989d3664396ef558/Apps/Collie/CollieVoiceController.swift#L131-L223)
- [前台准备入口](https://github.com/alexlee2046/yihu-ios/blob/915523951dfc5ae7458954c6989d3664396ef558/Apps/Collie/CollieVoiceController.swift#L360-L374)
- [原debouncer及recorder准入](https://github.com/alexlee2046/yihu-ios/blob/915523951dfc5ae7458954c6989d3664396ef558/Apps/Collie/CollieAudioRecorder.swift#L39-L105)
- [中文忙态指南](https://getyihu.com/guides/audio-busy-state-admission/) · [English busy-state guide](https://getyihu.com/en/guides/audio-busy-state-admission/)

新写合成材料Apache-2.0；既有源码保原许可。无真实录音、客户正文、设备UID或凭据；不使用任何真实测试标记或账号来运行此例。
