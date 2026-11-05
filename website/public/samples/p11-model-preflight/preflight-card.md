# SYN-MODEL-34 · 本地ASR清单/SHA、代际隔离与首次试用预检
# Local ASR manifest/SHA, generation isolation and first-trial preflight

**合成已填参考，不是真机模型成绩。Synthetic worked reference, not a device/model benchmark.**

[中文JSON](model-preflight.zh.json) · [English JSON](model-preflight.en.json)

同一例的两语言替代版，非App导入配置。数据同时给出**固定源码真实清单的只读参考**与**完全分开的微型测试清单**：原清单24项、合计945,583,332字节，未下载/验其权重；隔离测试只有SYN-A/B两个8字节文本文件。两者不得混称。不要改真实revision标记、清单或SHA来掩盖失配，也不为本卡下载/卸载模型。

Choose one language; not app configuration. The JSON separates the **real pinned-source manifest reference** from a **tiny synthetic test manifest**. The real24 assets total945,583,332 bytes and were not downloaded/verified here. Tests use only two8-byte text files. Never equate them or alter real markers/hashes to force a pass.

## 先分清三个版本/状态 / Separate version and state meanings

| 项 / Item | 固定源码事实 / Source fact | 不代表 / Does not establish |
| --- | --- | --- |
| 清单revision / manifest revision | ModelStore核`.collie-model-revision`与固定Self.revision精确相等；原值和5组修订字段保JSON / exact marker match, source revisions preserved in JSON | 安装进度、语音质量或身份签名 / download progress, speech quality or identity |
| 资产 / assets | 逐项核清单path、byteCount和SHA-256；不是只看目录存在 / listed path, size and digest, not directory existence | 未列文件也全部认证、发布方/许可或运行兼容认证 / authentication of every file, publisher/license/runtime certification |
| installGeneration | **在Qwen3OnDeviceTranscriber，不在ModelStore**；下载/移除入口递增并清model/isWarmedUp / incremented by transcriber download/removal wrappers | repository修订、账户令牌或跨服务事务 / repository revision, account token or distributed transaction |
| 已加载 / loaded | loadIfNeeded先见model非nil即返回；并非每次都重新读盘 / loaded instance can bypass a new disk scan | 刚刚又完整校验过，或可忽略真实错误 / freshly verified bytes or permission to ignore an error |
| 已预热 / warmed | validate在已预热时复用；未预热则调用warmUp / validate may reuse a warmed instance | 真实讲话准确、低延迟或所有设备可用 / accuracy, latency or universal device compatibility |

原源码分别固定ModelScope/Hugging Face的CoreML与tokenizer修订，原24项SHA在JSON；这是**源码预期**，不是已向供应站核当前文件、可用性或许可。SHA匹配也不替代信任/许可/设备与语音测试。

Source pins CoreML/tokenizer revisions for both providers. The24 hashes are source expectations, not a fresh provider download, availability or licensing check. Matching bytes do not replace trust, licensing, device or speech evidence.

## 微型文件层：8个已填答案 / Eight tiny-file integrity answers

实际执行的`isInstalled`与`sha256`方法逐字取自固定源；目录为新建临时测试目录，revision/marker/清单依赖换为显式合成值，不触真实App Support模型。使用系统CryptoKit对测试文本真算SHA，**不是把SHA结果简单设成true**。

Verbatim source `isInstalled`/`sha256` run on fresh temporary test directories with an explicitly synthetic marker/revision/manifest. CryptoKit computes actual tiny-file digests; this is not a preset hash=true flag. No real cache is scanned.

| 例 / Case | 合成输入 / Synthetic input | 文件判定预期 / Expected tiny-manifest result |
| --- | --- | --- |
| I1 | 有目录/文本，无marker / directory/files, no marker | false |
| I2 | marker错误，文件正确 / wrong revision | false |
| I3 | marker正确，缺B / missing listed asset | false |
| I4 | B字节数错误 / wrong size | false |
| I5 | B同大小但内容/SHA错 / same-size wrong digest | false |
| I6 | marker及两列出资产大小/SHA匹配 / listed files match | true，仅测试清单 / test manifest only |
| I7 | I6加额外未列文件 / extra unlisted file | true；不认证额外文件 / extra file not authenticated |
| I8 | 当前Task已取消 / cancelled task before scan | false；不等恶意改动 / not proof of tampering |

真实isInstalled=false还可能涉及取消、缺项、读取/大小/SHA/revision等，不凭一个false给用户诊断恶意篡改或擅自重下模型。本例不执行staging发布/备份排除/下载重试，也不删任何真实模型。

A real false can have many causes; do not diagnose malicious tampering or initiate a download from that boolean alone. Staging publication, backup exclusion and download/retry behavior are not executed here.

## 内存加载层：7个已填答案 / Seven controlled loading/generation answers

这里Store/CoreML全是内存替身，load/warm计数不是原生模型操作。**这一层的isInstalled返回脚本布尔值，不是再扫描真实24资产**；与上面的真实小文件SHA测试分层。源`loadIfNeeded/validateInstalledModel/removeModel/downloadModel`方法保持原文；用continuation控制await交错，不睡眠、不轮询、不宣全部并发零竞态。

This layer scripts Store integrity results and uses CoreML memory spies, separately from the tiny-file SHA tests. Original method bodies are retained. Continuations control await interleavings without sleeps/polling; this is not a proof of all races or actual model execution.

| 例 / Case | 条件与已填结论 / Condition and worked result |
| --- | --- |
| L1 | 未安装→modelMissing，不调用load/warm / not installed, no load/warm |
| L2 | 文件门true但load替身抛错→modelLoadFailed，model仍nil / file gate does not imply load success |
| L3 | validate两次；第一次后把Store替身返回设false，第二次仍复用已加载/预热对象；check/load/warm各1 / cached reuse, not a second fresh scan |
| L4 | 首次warm替身失败后对象仍已加载、未预热；重试warm成功，check/load各1、warm2 / retry warmth without another load/scan |
| L5 | 旧load等待完整性时remove入口增代并清内存；旧check即使回true仍modelMissing，load0 / stale generation cannot resurrect the removed model |
| L6 | 旧load等待时download入口增代；旧结果拒绝，新的validate才load/warm；下载只是内存spy，不取权重 / stale load rejected after generation bump, then new-generation validation |
| L7 | 两个同代冷load均等待；放行后第二个再查model，合计check2/load1，后续validate warm1 / post-await loaded-state recheck avoids duplicate load in this fixture |

L3不是绕完整性门的建议。真实模型/文件或状态有疑问仍先停止并按原界面处理，不手工把“已加载/预热”标志当作刚验过SHA。L5/L6只覆盖给定交错，不保证所有取消、崩溃、安装失败或跨进程事务。

L3 is not advice to bypass integrity checks. Stop for real uncertainty; a cached state is not a fresh SHA result. L5/L6 cover selected interleavings, not every cancellation/crash/install failure or cross-process transaction.

## 买方Go/No-Go：哪些证据尚缺 / Buyer Go/No-Go

**当前答案：离线预检可用；真实设备试用未获Go。** 源清单正确、小文件门通过或内存load/warm成功都不证明本机CoreML/语音效果。设备加载、预热、权限、实际输入与目的地任一未核，就保unknown/not_run，不把它写成识别通过。

**Current decision: usable offline preflight, no device-trial Go established.** Source manifests, tiny-file passes and memory-spy success do not establish device CoreML or speech readiness. Unverified loading, warmth, permission, input or destination stay unknown/not_run.

截至2026-11-05官方美区仍**Yihu0.1.0 / id6819057500 / iOS18+**：[US App Store](https://apps.apple.com/us/app/yihu/id6819057500) · [中文商店段](https://getyihu.com/start/#store-start) · [English store setup](https://getyihu.com/en/start/#store-start)。**商店安装无需Mac/Xcode/自行签名**；旧指南的源码构建步骤是另一条路径。需自有可信工作台/账号，可选语音模型约950MB；供应以实际地区商店为准。源实现不认证商店二进制同版，也不反推商店一定没有。

US listing rechecked2026-11-05:0.1.0/iOS18+. **Store installation needs no Mac/Xcode/self-signing**; source building is a separate path. Bring your own trusted workspace/account; optional speech model about950MB. Availability follows the storefront; no binary parity or absence is inferred from source.

**若另获准真实练习，可照读中文；理想逐字稿相同，不是已测ASR：**
> 样本三十四。先核对六号记录，不发送，也不改写原稿。

**Separately authorized phrase and ideal verbatim text, not observed ASR:**
> Sample thirty-four. Check record six first; do not send or rewrite the original.

安全静止、前台、权限/模型准备完成且目标不会自动执行时，才用新空白未发送练习草稿。核34、6及两个否定，原文未知不自动改写；已有填入先看，不盲重插、不按Send/Run、不后台监听。目的工作台可能保存/同步/处理；App不代发不等数据全留本机。

Only stationary foreground practice after preparation/permission and with no downstream execution: use an empty unsent training draft. Check34,6 and both negations; do not blindly repeat insertion, Send/Run or background listening. A workspace may save/sync/process input; no automatic send does not imply all data remains local.

**真实模型下载/安装/移除/缓存扫描、真机CoreML加载/预热、识别准确率、麦克风/填入/发送全not_run。** 没有设备成绩、客户验收、模型安全/许可认证或安装转化结果。

**Real model download/install/removal/cache scan, device CoreML loading/warm-up, speech accuracy, capture/insertion/sending: all not_run.** No device, customer, security/licensing or conversion result is claimed.

## 固定一手来源 / Fixed first-party evidence

源基底M`acd44181a445e6c497709ba26b63e4302b21044e`（已合入主干，不宣本包已部署）：
- [ModelStore固定清单/isInstalled](https://github.com/alexlee2046/yihu-ios/blob/acd44181a445e6c497709ba26b63e4302b21044e/Apps/Collie/Qwen3ModelStore.swift#L26-L107)
- [SHA扫描及取消](https://github.com/alexlee2046/yihu-ios/blob/acd44181a445e6c497709ba26b63e4302b21044e/Apps/Collie/Qwen3ModelStore.swift#L302-L318)
- [代际/validate/loadIfNeeded](https://github.com/alexlee2046/yihu-ios/blob/acd44181a445e6c497709ba26b63e4302b21044e/Apps/Collie/Qwen3OnDeviceTranscriber.swift#L10-L135)
- [中文在役首次试用清单](https://getyihu.com/guides/first-trial-go-no-go-checklist/) · [English active first-trial checklist](https://getyihu.com/en/guides/first-trial-go-no-go-checklist/)

新写合成文字Apache-2.0；既有源码保原许可，未分发原权重/申请新授权。无真实客户录音、设备UID或凭据，不创建模型下载/推理/账号后端。
