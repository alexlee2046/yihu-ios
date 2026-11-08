# SYN-ALR-48 · 电平不是准确率 / Audio level is not accuracy

SYNTHETIC_EXAMPLE · pending · not_run。全部从零合成，非真实音频、身份、ASR置信度、校准声压、权限或送达回执。 / Synthetic from scratch, not real audio, identity, ASR confidence, calibrated pressure, authority or delivery evidence.

[中文 JSON](/samples/p27-audio-level-not-accuracy-review/preflight.zh.json) · [English JSON](/samples/p27-audio-level-not-accuracy-review/preflight.en.json)

原短RMS乘2并裁0..1；原长append成功写入后RMS乘12并上限1。相同RMS/同条不等同原话，不同系数/饱和也可同条。 / Original short RMS scales by2 and bounds0..1; original long append updates after a successful write with RMS×12 capped at1. Equal RMS/meters do not mean identical words; different gains/clipping can yield equal bars.

<div role="region" aria-label="电平合成核对 / Synthetic meter review" tabindex="0">

| ID | 检查 / Check | 合成预期 / Synthetic expectation |
| --- | --- | --- |
| L01 | 空数组 / Empty vector | short≈0.000000; note≈0.000000; frames=0 |
| L02 | 零值 / Zeros | short≈0.000000; note≈0.000000; frames=2 |
| L03 | 正DC / Positive DC | short≈0.020000; note≈0.120000; frames=2 |
| L04 | 负DC / Negative DC | short≈0.020000; note≈0.120000; frames=2 |
| L05 | 交替符号 / Alternating signs | short≈0.020000; note≈0.120000; frames=2 |
| L06 | 未饱和双缩放 / Two unsaturated gains | short≈0.100000; note≈0.600000; frames=2 |
| L07 | 长条饱和 / Long meter saturated | short≈0.200000; note≈1.000000; frames=2 |
| L08 | 半短满长 / Half short, full long | short≈0.500000; note≈1.000000; frames=2 |
| L09 | 双条满 / Both full | short≈1.000000; note≈1.000000; frames=2 |
| L10 | 满幅样本 / Full-scale samples | short≈1.000000; note≈1.000000; frames=2 |
| L11 | 有限越界值 / Finite out-of-range values | short≈1.000000; note≈1.000000; frames=2 |
| L12 | 稀疏高值 / Sparse high value | short≈1.000000; note≈1.000000; frames=2 |
| L13 | 稀疏低值 / Sparse low value | short≈0.141421; note≈0.848528; frames=2 |
| L14 | 不同幅度 / Unequal amplitudes | short≈0.632456; note≈1.000000; frames=2 |
| L15 | 同能量DC / Equal-energy DC | short≈0.200000; note≈1.000000; frames=2 |
| L16 | 同能量负DC / Equal-energy negative DC | short≈0.200000; note≈1.000000; frames=2 |
| L17 | 四点稀疏 / Four-point sparse vector | short≈0.200000; note≈1.000000; frames=4 |
| L18 | 低幅混合 / Low mixed amplitude | short≈0.070711; note≈0.424264; frames=2 |
| L19 | 饱和DC / Saturated DC | short≈1.000000; note≈1.000000; frames=2 |
| L20 | 极低有限值 / Small finite values | short≈0.010000; note≈0.060000; frames=2 |
| S01 | 空输入保留旧条 / Empty input retains meter | empty_retains: note≈0.600000; frames=2 |
| S02 | 真零样本更新 / Zero samples update | zero_updates: note≈0.000000; frames=4 |
| S03 | 关闭后保留旧条 / Closed file retains prior meter | closed_after_seed: note≈0.600000; frames=2 |
| S04 | 无文件不更新 / No file means no update | closed_initial: note≈0.000000; frames=0 |
| M01 | 电平不是识别/声纹 / Meter is not ASR or identity | 同RMS的DC、交替、稀疏向量可同条，不说明同一句话或本人；未跑ASR/声纹。 / DC, alternating and sparse vectors can share RMS/meters without the same words or speaker; no ASR/voiceprint run. |
| M02 | 缩放不校准 / Gain is not calibration | 2与12不是dB SPL、风噪等级或概率；饱和会丢显示区分，不推荐硬件增益。 / Gains 2/12 are not dB SPL, wind ratings or probabilities; clipping loses display distinction, not a hardware-gain recommendation. |
| M03 | 显示与写入分账 / Display versus writing | 长append仅写成功更新；空输入/无file可保旧level，关闭file守卫不等存储失败注入。计时读取不承诺UI无延迟。 / Long append updates after successful writes; empty input/no file can retain level. Closed-file guard is not injected storage failure; timer reads do not promise zero UI latency. |
| M04 | 令牌先于完成 / Token before completion | captureCompleted先比activeToken再导出/清理；token只是本次关联，不是身份、写权或通用exactly-once。 / captureCompleted compares activeToken before export/cleanup; token is capture association, not identity, write authority or universal exactly-once. |
| M05 | stop与cancel分开 / Separate stop and cancel | stop可等待本次排空，cancel清activeToken；旧满条或迟到回调不证明新会话final或已送达。 / Stop may await this drain; cancel clears activeToken. Old full meters or late callbacks prove neither a new final nor delivery. |
| M06 | 真实内容和许可另核 / Review real content and authority separately | 本包不收客户音频，不上传或重录；许可、原文、缺口、已保存/远端回执另核，未知不盲重试。 / No customer audio, upload or recapture. Check authority, originals, gaps, saved/remote receipts separately; no blind retry when unknown. |

</div>

## 验证边界 / Verification boundary

24例/语：20有限向量+4原append状态例。宿主用完整原PCM文件、完整原CollieNoteWriter类及原错误enum，追加同文件测试访问器，不改原方法；AVFoundation buffer/CAF与OSAllocatedUnfairLock真实，临时根仅本测试所有。不启动engine/tap/麦克风，不调用convert/finish/真实设备；初始化converter不是转换/录音验收。CAF为16-bit PCM，原level在写后从Float计算，不称磁盘量化后字节或真实声压测量。 / 24 cases per language:20 finite vectors+4 original append states. Host uses the whole original PCM file, whole original CollieNoteWriter class and original error enum, with same-file accessors appended without changing original methods. AVFoundation buffer/CAF and OSAllocatedUnfairLock are real in an owned temporary root. No engine/tap/microphone or convert/finish/device execution; converter initialization is not conversion/capture acceptance. CAF is16-bit PCM; original level uses Float after writing, not quantized-byte fidelity or physical pressure.

六项人工源码边界不是运行例；captureCompleted/stop/cancel/计时UI/存储失败/NaN/Inf/ASR/网络全部not_run。没有新音频评分、诊断、自动重录/合并/重发后端。 / Six manual source boundaries are not executions; captureCompleted/stop/cancel/UI timer/storage failure/NaN/Inf/ASR/network remain not_run. No new scoring, diagnostics, auto-recapture/merge/resend backend.

保原文、缺口、许可与一次标记；不收顾客声音、不凭电平修改原件或授访问/发送权，未知即停。目的地可保存同步自动处理，不称全部副本撤回或全数据不离机。 / Preserve originals, gaps, authority and reservations. No customer voices or meter-based source changes/access/send authority; stop when unknown. Destinations may save/sync/process; no universal recall/all-on-device claim.

Source: https://github.com/alexlee2046/yihu-ios/blob/d58dd159e3306d9d46643e0eaa78be26a4679e2b/Apps/Collie/ColliePCMStream.swift

[中文指南](/guides/audio-level-not-accuracy-review/) · [English guide](/en/guides/audio-level-not-accuracy-review/)
