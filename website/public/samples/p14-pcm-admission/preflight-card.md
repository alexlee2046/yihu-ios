# SYN-PCM-36 · PCM声明、帧对齐与流结束预检
# PCM declarations, frame alignment and stream-end preflight

**SYNTHETIC_EXAMPLE：全部合成，无生产录音抓包、真机故障工单或ASR SLA。All synthetic; no production capture, device ticket or ASR SLA.**

[中文JSON](pcm-admission-preflight.zh.json) · [English JSON](pcm-admission-preflight.en.json)

## 先区分两个契约 / Two distinct contracts

1. **原始字节工作表**：s16le/f32le、字节序/位深、16/24/48kHz声明、帧对齐和EOF是本包显式的外部声明自检，**不是新增App raw PCM导入/修复工具**。结构符合不等可直接送入原转换器。
2. **固定Swift原生缓冲准入**：sourceFormat采样率有限且8000…192000Hz、声道1…8、pcmFormatFloat32且**非交错**，之后还要创建转换器成功。输出目标16kHz单声道。后续块还须匹配isStandard/采样率/声道/Float32/非交错；创建/转换失败仍可能发生。

The raw-byte worksheet is **not an app importer or repair tool**. Native source accepts finite8000–192000Hz,1–8 channels, Float32 non-interleaved buffers before attempting conversion to16kHz mono. A valid raw interleaved/int16 declaration is not native admission. Later blocks must still match; metadata alone guarantees no creation/conversion success.

16/24/48kHz只是本例声明覆盖点，不是原代码仅支持这三档，也不表示任意真实设备已测。声道准入不是多人分离/音轨识别。只改header/标签不会重采样、变位深、换字节序或重排交错平面。

These three rates are example coverage, not an exclusive source list or hardware certification. Channel support is not speaker separation. Relabeling bytes does not resample, convert bit depth/endian or reorder layouts.

## 已填字节结构核对 / Worked byte-structure checks

本例有独立已知producer声明；任意raw PCM**不自描述采样率/字节序**，不能从长度或全零数据自动识别它们。LE表示小端，s16le为16位有符号整数，f32le为32位浮点。全零hex仅为微型合成材料，不是现场静音实测。

An independent known fixture producer declaration enables these comparisons. Raw bytes do not self-describe rate/endian, particularly zeros. LE means little-endian; s16le is signed16-bit, f32le float32. No live silence was recorded.

交错完整帧字节=`channels × (encoding bits/8)`；必须先有位深/编码一致证据，再核整帧。双声道s16le每帧4B，双声道f32le每帧8B，单声道f32le每帧4B。平面布局还须各平面样本对齐/帧数一致；本包不凭总长度给任意双声道平面raw背书。

Interleaved frame bytes are channels × bytes per encoded sample. Verify the codec/bit-depth contract first. Planar multi-channel data also needs per-plane alignment and equal frame counts; total length alone is insufficient.

| 例 / Case | 输入与已填结论 / Input and worked result |
| --- | --- |
| P1 | 16k/s16le/mono、4B：结构完整2帧，但整数格式不满足原转换器Float32门 / aligned worksheet, not native float admission |
| P2 | 24k/s16le/stereo交错、8B：2帧结构完整，原转换器仍不接整数/交错 / aligned, still not native admission |
| P3 | 48k/f32le/stereo交错、16B：2帧完整，但交错不满足原非交错门 / alignment is not layout admission |
| P4 | 16k/f32le/mono平面、8B：结构完整，原格式前提可满足，实际创建/转换未测 / conditions are not runtime success |
| P5 | s16le却声明32bit：No-Go，编码/位深冲突 / codec-bit-depth conflict |
| P6 | f32le却独立声明big-endian：No-Go，不靠改标签掩盖 / known-endian conflict |
| P7 | stereo s16le只有6B：No-Go，1整帧+残余2B / partial frame |
| P8 | mono f32le只有6B：No-Go，截断样本 / partial sample |
| P9 | producer48k却标16k：No-Go，字节长度不能证明采样率 / rate mislabel |
| P10 | 声称已结束但只有no_data_now：No-Go，未显式结束 / missing EOF declaration |
| P11 | 原8B完整双声道s16le，另显式声明1个完整静音帧：只是合成工作表计划，不是原finish自动填充 / separately declared whole silence frame |
| P12 | 对6B残缺双声道帧要求补静音：仍No-Go，不用padding伪装原件完整 / never hide a cut frame |
| P13 | 流未结束，块后no_data_now：工作表控制声明一致 / temporary lack of input is not EOF |
| P14 | 流仍开放却声明EOF：No-Go，过早结束 / premature EOF |

**静音补帧必须与真实采集内容分开记。** 本包的whole-silence-frame字段只说明合成计划，不执行或宣称App具备尾部修复/自动补音。损坏尾部保留原件与缺口，不能填零后称“原音频完整”。

Silence padding must remain separate from captured content. The fixture's whole-frame padding field is a synthetic declaration, not an implemented app repair feature. Preserve damaged originals/gaps; zero-filled bytes are not recovered speech.

## 流结束与尾部排空 / EOF and delayed samples

- **E1**：正常块供一次haveData，块间缺数据是noDataNow；保同一有状态转换器。不要每个tap都结束流或重建转换器。
- **E2**：finish模拟输出2样本后下一次空样本，即使status尚非EOS也可停止；不从此推“原始每帧均保全”。
- **E3**：finish首调返回尾部3样本且EOS，先append再停止；不是附加静音帧。
- **E4**：持续非空且不报结束时，原finish最多调用16次；16是调用预算，**不是16秒/16帧/零丢失或完整转换SLA**。

Ordinary lack of input is noDataNow, not endOfStream. Source finish drains delayed converter samples with at most16 calls, breaking on EOS **or empty samples**. It is not automatic zero padding or a guarantee of complete, lossless recognition.

EOF是API/工作表控制状态，不是PCM中的零采样、静音尾段或某个魔术字节。输出buffer容量、帧长度、有效内容也分开：容量大不等已写入等量音频。实际AVAudioConverter、采样率转换、硬件路由和尾部恢复均未运行。

EOF is control state, not silence or magic payload bytes. Buffer capacity is not valid frame length. No actual AVAudioConverter, resampling, route or tail recovery is measured here.

## 安全静止语音检查 / Separately authorized stationary phrase

**当前仅离线自检可用，不由结构合规宣设备Go。** 若另获准真实试用，先核自有可信工作台/账号、模型/权限/输入和目的地不会自动执行。商店0.1.0/id6819057500范围沿已保存11/05官方US证据，不是本轮刷新最新版本；iOS18+、可选语音模型约950MB。商店安装不需Mac/Xcode/自行签名，源码构建是另一条路径。

Offline checks do not grant device Go. Separately authorized trials require your own trusted workspace/account, models, permission/input and a safe destination. Version-limited US0.1.0 evidence is reused, not freshly refreshed. Store installation needs no Mac/Xcode/self-signing; source building is separate.

[US App Store](https://apps.apple.com/us/app/yihu/id6819057500) · [中文商店上手](https://getyihu.com/start/#store-start) · [English setup](https://getyihu.com/en/start/#store-start)

**预制口述 = 理想逐字稿，未测ASR：**
> 合成PCM样本。先核对帧边界，不补造缺失内容，也不发送。

**Preset phrase = ideal verbatim text, not observed ASR:**
> Synthetic PCM sample. Check frame boundaries first; do not fabricate missing content or send.

停稳并取得录音同意，用新空白未发送草稿；保留旧材料/错误和截断边界，已有填入先看，不盲重插，不Send/Run/后台监听。目的工作台可能保存/同步/处理。不要向公开反馈上传真实录音抓包、客户正文或设备标识。

Be stationary with consent. Preserve originals/errors/gaps; inspect before repeating insertion. No Send/Run or background listening. Destinations may save/sync/process input. Share no real captures, customer content or device identifiers.

**真实麦克风、系统转换器/重采样、尾部恢复/补静音、生产故障工单/抓包、ASR准确率/SLA、填入/发送全部not_run。** SYNTHETIC_EXAMPLE自检通过只在本包已列条件内成立。

## 固定一手来源 / Fixed first-party sources

基底`da294b3f290fc817aa3359c354a2e67d21e2af47`，canonical仍getyihu.com，本卡不声明改域名或已上线：
- [原格式/块准入、convertOnce与finish](https://github.com/alexlee2046/yihu-ios/blob/da294b3f290fc817aa3359c354a2e67d21e2af47/Apps/Collie/ColliePCMStream.swift#L32-L126)
- [转写文件/样本条件](https://github.com/alexlee2046/yihu-ios/blob/da294b3f290fc817aa3359c354a2e67d21e2af47/Apps/Collie/Qwen3OnDeviceTranscriber.swift)
- [中文在役PCM准入](https://getyihu.com/guides/pcm-format-admission-review/) · [English PCM admission](https://getyihu.com/en/guides/pcm-format-admission-review/)

新写合成文字Apache-2.0，既有源码保原许可。无真实录音/客户正文/凭据、生产故障或声学/识别认证，不新增导入/云转码/修复/诊断后端。
