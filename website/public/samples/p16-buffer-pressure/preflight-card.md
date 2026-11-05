# SYN-BUF-37 — 采集等待水位与完成边界 / Capture pressure preflight

**SYNTHETIC_EXAMPLE** · 中英JSON是可核的脚本/结果契约，不是App导入协议、录音抓包、工单或实际设备压测。Fixed source #58@d51c1bff6d133a4e0617ee1e4f1e20167ee04224 / tree d46a435376b99342dd378ccaa5ab3c359c1691d2, not store-binary parity.

## 先纠正“环形”前提 / Correct the ring-buffer premise

固定源码用`pending: [ColliePCMChunk]`、`pendingFrames`、`removeFirst()`组成有界数组FIFO；**没有ring head/tail、wrap/覆盖旧帧策略**。环形索引记not_applicable，不凭派单术语创造App能力。等待上限是max(ceil(sourceRate / 2),4096)源帧，48kHz为24000，8kHz由4096下限主导；水位不是字节、整个App RAM或端到端延迟。正在转换的块、输出数组、声道副本及其他内存不在pendingFrames内。

The fixed source is an array FIFO, not a circular overwrite-oldest queue. Overflow is reported, not silent-drop success. Frame budget is not total memory or speed; no new drop counter, adaptive queue, segment manager or configuration is implemented.

## 如何读本包 / How to read

完整原ColliePCMRecordingPipeline及错误enum逐字编译进Foundation宿主。NSLock/Swift数组真实，但**DispatchQueue是可手动drain的单线程替身**；AVAudioFormat/PCMBuffer/Chunk/Converter都是计数/脚本替身，不复制真实声道、不作真实截波形/重采样/flush。`converted_samples`与`scripted_tail_samples`由测试注入，不能据此算实测转换比、丢帧率、RAM或时延。Q7只核admitted count/停止旗标，不验证真实PCM末块裁剪。上游格式/权限/模型/目标守卫仍需原条件，本替身不绕过或测试真实AV构造。

The complete source pipeline is unchanged. A deterministic fake scheduler holds workers to exercise admission watermarks, then drains them without sleeping or a benchmark. Read-only instrumentation observes private counters/receipts. There is no concurrency/lock-contention/realtime safety test, no actual audio buffer and no iOS SDK execution.16 scripts plus8 duration guard cases/language;4 boundary notes are source reading only. Batch37 is not37 physical tests.

- **D1–D8**: finite positive duration<=30 plus both floor frame budgets>0; NaN/infinity are string sentinels mapped only in host fixture, not invalid JSON numbers.
- **Q1/Q16**: snapshot不排空，旧Swift数组快照不随新输出增长；正常stop处理已入队块再排尾。Preview existence is not complete capture or final success.
- **Q2–Q6**: exact limit admitted, one extra fails; lower4096 floor andceil rounding; draining lowers pending while cumulative accepted grows. Overflow stops admission/reports failure, not automatic drop-oldest success.
- **Q7/Q8**: 到源时长用min(available,remaining)裁最后计数且停止，不自动另开分段；这与转换输出超过maximumFrames时durationExceeded不同。Excess offered frames are not a new captured segment or recovered content.
- **Q9**: **final tail overflow can return failure while snapshot remains readable**: failure field was not assigned by that branch. Do not replace completion receipt with snapshot/no-error-field. This is the unchanged source boundary, not a native bug fix or success claim.
- **Q10**: no input/empty tail gives tooShort completion while snapshot can still be empty. **Q11**: cancel clears pending/output and prevents callback; no hidden full backup. **Q12–Q15**: explicit failure/copy or conversion throw vs once-only completion remain distinct; later stop/input cannot duplicate final callback.

## 完整双语工作表 / Full bilingual worksheet

### zh

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| D1 | duration=0 | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D2 | duration=-1 | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D3 | duration=31 | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D4 | duration=nan | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D5 | duration=infinity | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D6 | duration=0.000001 | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D7 | duration=0.001 | source init accepted=True; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D8 | duration=30 | source init accepted=True; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| Q1 | 预览不排空；正常停后排尾; sourceRate=48000; duration=30 | {'pending_frames': 0, 'accepted_source_frames': 1024, 'output_samples': 3, 'completed': True, 'failure': 'none', 'completion': 'success', 'callback_count': 1, 'snapshot': 'samples:3'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q2 | 等待帧恰等24000可接纳; sourceRate=48000; duration=30 | {'accepted_source_frames': 24000, 'output_samples': 2, 'completion': 'success', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q3 | 超一帧报错，不环形覆盖后宣成功; sourceRate=48000; duration=30 | {'accepted_source_frames': 24000, 'completion': 'bufferOverflow', 'failure': 'bufferOverflow', 'callback_count': 1, 'snapshot': 'error:bufferOverflow'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q4 | 低率4096下限而非一律半秒; sourceRate=8000; duration=30 | {'queue_limit': 4096, 'accepted_source_frames': 4096, 'completion': 'bufferOverflow'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q5 | ceil向上取整，仅假格式字段; sourceRate=44100.5; duration=30 | {'queue_limit': 22051, 'accepted_source_frames': 22051, 'completion': 'success'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q6 | 排空释放水位，累计接纳量不是等待量; sourceRate=48000; duration=30 | {'accepted_source_frames': 48000, 'output_samples': 2, 'completion': 'success', 'pending_frames': 0} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q7 | 时长裁最后块且不自动另开分段; sourceRate=48000; duration=0.001 | {'maximum_source_frames': 48, 'maximum_output_samples': 16, 'accepted_source_frames': 48, 'output_samples': 16, 'completion': 'success', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q8 | 转换输出超预算失败; sourceRate=48000; duration=0.001 | {'accepted_source_frames': 48, 'output_samples': 0, 'pending_frames': 0, 'failure': 'durationExceeded', 'completion': 'durationExceeded'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q9 | 尾输出越界的最终失败可与可读快照并存; sourceRate=48000; duration=0.001 | {'output_samples': 16, 'failure': 'none', 'completion': 'durationExceeded', 'snapshot': 'samples:16', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q10 | 空停失败，空快照不能作完成回执; sourceRate=48000; duration=30 | {'output_samples': 0, 'failure': 'none', 'completion': 'tooShort', 'snapshot': 'samples:0', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q11 | 取消清队列和输出，不给隐形完整备份; sourceRate=48000; duration=30 | {'pending_frames': 0, 'output_samples': 0, 'cancelled': True, 'completed': False, 'callback_count': 0, 'completion': 'none', 'snapshot': 'error:cancelled', 'reset_calls': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q12 | 显式fail清等待量并给失败; sourceRate=48000; duration=30 | {'pending_frames': 0, 'output_samples': 0, 'failure': 'conversionFailed', 'completion': 'conversionFailed', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q13 | 替身转换抛错测试catch路径; sourceRate=48000; duration=30 | {'output_samples': 0, 'pending_frames': 0, 'failure': 'conversionFailed', 'completion': 'conversionFailed'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q14 | 替身块复制失败不假称已入队; sourceRate=48000; duration=30 | {'accepted_source_frames': 0, 'pending_frames': 0, 'failure': 'unsupportedFormat', 'completion': 'unsupportedFormat'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q15 | 完成后停止/新输入不重复回调; sourceRate=48000; duration=30 | {'accepted_source_frames': 1, 'output_samples': 2, 'completion': 'success', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q16 | Swift数组旧快照不随新输出增长; sourceRate=48000; duration=30 | {'output_samples': 5, 'completion': 'success', 'snapshot': 'samples:5', 'saved_snapshot_sizes': [2, 5]} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| B1 | 源是数组FIFO，不是环形丢旧帧 | pending:[ColliePCMChunk], pendingFrames, removeFirst; ring head/tail indices not_applicable; overflow final failure, not silent-drop success | Source reading only; runtime not_run |
| B2 | 正常到限裁块不等自动分段 | count=min(available,remaining), accepting=false at limit; no new session/segment or lost-content padding created | Source reading only; runtime not_run |
| B3 | 长笔记路径独立，水位非总RAM/延迟 | CollieNoteRecorder file-writing path is distinct; in-flight chunk/output/channels/other allocations not included in pendingFrames budget | Source reading only; runtime not_run |
| B4 | 输出token预算不能修采集丢口 | Per-pass output maxTokens is not source frames, queue size, seconds or guaranteed accuracy; no model/prefs changes or pass execution | Source reading only; runtime not_run |

### en

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| D1 | duration=0 | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D2 | duration=-1 | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D3 | duration=31 | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D4 | duration=nan | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D5 | duration=infinity | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D6 | duration=0.000001 | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D7 | duration=0.001 | source init accepted=True; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D8 | duration=30 | source init accepted=True; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| Q1 | Preview does not drain; normal stop flushes tail; sourceRate=48000; duration=30 | {'pending_frames': 0, 'accepted_source_frames': 1024, 'output_samples': 3, 'completed': True, 'failure': 'none', 'completion': 'success', 'callback_count': 1, 'snapshot': 'samples:3'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q2 | Exactly24000 waiting source frames admitted; sourceRate=48000; duration=30 | {'accepted_source_frames': 24000, 'output_samples': 2, 'completion': 'success', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q3 | One over limit fails, not circular overwrite success; sourceRate=48000; duration=30 | {'accepted_source_frames': 24000, 'completion': 'bufferOverflow', 'failure': 'bufferOverflow', 'callback_count': 1, 'snapshot': 'error:bufferOverflow'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q4 | 4096 floor at low rate, not universally half a second; sourceRate=8000; duration=30 | {'queue_limit': 4096, 'accepted_source_frames': 4096, 'completion': 'bufferOverflow'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q5 | Ceil rounding with fake format fields only; sourceRate=44100.5; duration=30 | {'queue_limit': 22051, 'accepted_source_frames': 22051, 'completion': 'success'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q6 | Draining frees pending budget, cumulative accepted is distinct; sourceRate=48000; duration=30 | {'accepted_source_frames': 48000, 'output_samples': 2, 'completion': 'success', 'pending_frames': 0} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q7 | Duration clips final block without opening next segment; sourceRate=48000; duration=0.001 | {'maximum_source_frames': 48, 'maximum_output_samples': 16, 'accepted_source_frames': 48, 'output_samples': 16, 'completion': 'success', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q8 | Scripted converted output exceeds budget; sourceRate=48000; duration=0.001 | {'accepted_source_frames': 48, 'output_samples': 0, 'pending_frames': 0, 'failure': 'durationExceeded', 'completion': 'durationExceeded'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q9 | Final tail overflow can coexist with readable snapshot; sourceRate=48000; duration=0.001 | {'output_samples': 16, 'failure': 'none', 'completion': 'durationExceeded', 'snapshot': 'samples:16', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q10 | Empty stop fails; empty snapshot is not final receipt; sourceRate=48000; duration=30 | {'output_samples': 0, 'failure': 'none', 'completion': 'tooShort', 'snapshot': 'samples:0', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q11 | Cancel clears pending/output, no hidden complete backup; sourceRate=48000; duration=30 | {'pending_frames': 0, 'output_samples': 0, 'cancelled': True, 'completed': False, 'callback_count': 0, 'completion': 'none', 'snapshot': 'error:cancelled', 'reset_calls': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q12 | Explicit failure clears pending and reports failure; sourceRate=48000; duration=30 | {'pending_frames': 0, 'output_samples': 0, 'failure': 'conversionFailed', 'completion': 'conversionFailed', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q13 | Scripted converter throw exercises catch path; sourceRate=48000; duration=30 | {'output_samples': 0, 'pending_frames': 0, 'failure': 'conversionFailed', 'completion': 'conversionFailed'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q14 | Scripted chunk-copy failure is not admitted; sourceRate=48000; duration=30 | {'accepted_source_frames': 0, 'pending_frames': 0, 'failure': 'unsupportedFormat', 'completion': 'unsupportedFormat'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q15 | Post-completion stop/input cannot double-complete; sourceRate=48000; duration=30 | {'accepted_source_frames': 1, 'output_samples': 2, 'completion': 'success', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q16 | Old Swift array snapshot remains separate from later output; sourceRate=48000; duration=30 | {'output_samples': 5, 'completion': 'success', 'snapshot': 'samples:5', 'saved_snapshot_sizes': [2, 5]} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| B1 | Source is array FIFO, not overwrite-oldest ring | pending:[ColliePCMChunk], pendingFrames, removeFirst; ring head/tail indices not_applicable; overflow final failure, not silent-drop success | Source reading only; runtime not_run |
| B2 | Duration clipping is not automatic segmentation | count=min(available,remaining), accepting=false at limit; no new session/segment or lost-content padding created | Source reading only; runtime not_run |
| B3 | Long notes are separate; watermark is not RAM/latency | CollieNoteRecorder file-writing path is distinct; in-flight chunk/output/channels/other allocations not included in pendingFrames budget | Source reading only; runtime not_run |
| B4 | Decoder token budget cannot repair capture gaps | Per-pass output maxTokens is not source frames, queue size, seconds or guaranteed accuracy; no model/prefs changes or pass execution | Source reading only; runtime not_run |

## 分段、token与人工No-Go / Segments, tokens and manual No-Go

短语音源帧/输出样本上限不是长笔记写盘上限，队列不自动生成下一段/补静音修复缺口。Recognizing-pass maxTokens is output decoder budget, not frames, source seconds or allowed queue growth. Raising tokens cannot recover dropped/uncaptured material, certify accuracy or authorize another handoff. We do not change preferences or execute a model.

最终失败/不确定完整性、有文字但缺源、取消/裁余块、未知旧副作用或单位混淆 => No-Go；保原错误/未知，先核当前目标、可用原件与明确的新鲜用户选择，不盲重录/填入/重发。The destination may save, sync or auto-process; App not auto-sending is not a guarantee all data stays local. These are manual review criteria, not new App guards or device Go certification.

官方US商店沿已保存11/05观察0.1.0/id6819057500/iOS18+，非本轮新查最新/全球供应。商店安装不需Mac/Xcode/自签名；自己的可信HTTPS工作台/账号、模型（商店描述可选约950MB）与许可另核。Source may be ahead, not proof of installed binary parity. https://apps.apple.com/us/app/yihu/id6819057500

Real microphone/pressure/drop telemetry, AV conversion/tail, contention/race safety, automatic segments/recovery, long-note disk pressure, ASR, insertion/send, hardware memory/latency/SLA: **not_run**. No zero-loss/always-on recording promise, no synthetic padding presented as recovered original audio.

Only two active capture pages link this pack; retired recognition-budget pair stays false without downloads/Store cards or own LLM/sitemap entry. Source canonical getyihu.com remains, dispatch yihu.st not migration authorization. No production/IndexNow/Google calls or external authorizations here.
