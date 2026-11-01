# SYN-AUDIO-32 · 蓝牙/外接麦克风路由抖动与录音恢复预检
# Bluetooth / external-mic route jitter and recording recovery

**预制合成样例，不是真机报告。Preset synthetic casebook, not a device report.**

本例是在安全静止处准备一条带数字/否定词的**短语音**：耳机能播放，但输入是否为耳机未知；假设采集中出现配置变更、重复通知、外接输入切换或来电。下面已填的是固定公开源码的条件/预期，**不是已观察到的系统事件或恢复成绩**。音频、实际录文、设备测量均为null/not_run；不沿用P7改期或P8商机样板任务。

Prepare a short phrase while safely stationary. Headset playback does not identify the recording input. Configuration changes, duplicate notifications, external-input changes and calls below are **invented conditions with source-derived expectations**, not observed events or recovery results. Actual audio, transcript and device measurements are null/not_run. This is not P7's reschedule or P8's opportunity exercise.

[中文JSON](audio-preflight.zh.json) · [English JSON](audio-preflight.en.json)

两文件是同一例的语言替代版：4组/13条去抖参数及8条源码分支参考。不是App可导入配置、设备日志、后台诊断服务或自动发系统通知的脚本。机读run/branch ID和枚举不翻译；解释文字按语言切换。SYN-INPUT-A/B只是脱敏演练别名，不是真实UID/型号。虚拟格式A=16000Hz/单声道/Float32/非交错，B仅改为48000Hz；这些不是任何耳机/USB麦克风规格或应强制设置的参数。

Choose one language variant: four runs/thirteen predicate calls and eight source-reference branches. These are not an app import schema, device logs, a background diagnostic service or OS-event injection. Route aliases and format examples are independent: a changed route may keep format A (R1); format A→B is R2. 格式与路由别名不绑定，不能从某别名推采样率。 Machine IDs/enums remain stable. Virtual route aliases and formats are illustrative, not measured accessory specifications or settings to force.

## 已填去抖答案 / Worked debouncer answers

相对毫秒只是传给源码`Date`参数的合成偏移，不修改系统时钟、不实际等待，也不测硬件延迟。假设arm发生于0ms，令牌A，默认gracePeriod=2秒；源码在重建tap后、调用engine.start**之前**arm，不是成功恢复后的计时承诺。

Milliseconds are synthetic offsets passed as `Date`, not a clock change, real waiting or hardware latency. Assume A armed at0ms with the default2-second grace period. The recorder arms **before** engine.start during recovery, not after proven success.

| 组 / Run | 已填条件 / Preset inputs | 逐条预期 / Expected shouldSuppress |
| --- | --- | --- |
| D1 | A；引擎运行、格式/路由相同；200、1000、2000、2001、2100ms / all flags true | **true,true,true,false,false**；恰2秒仍含在窗内，过期清窗 / inclusive deadline, then reset |
| D2 | 300ms错令牌B且其余flag假；400ms A全真；500ms A仅路由不同；600ms A又全真 / mismatch then route reset | **false,true,false,false**；错token不清A期望；A路由变则清窗，切回标志不自动re-arm |
| D3 | 400ms A引擎停止；500ms A全真 / engine stopped then flags true | **false,false**；停引擎条件清窗 / reset persists |
| D4 | 400ms A格式不同；500ms A全真 / changed format then flags true | **false,false**；格式条件清窗 / reset persists |

这只说明helper如何处理给定参数。真正observer还先检查activeToken和recordingActive，旧回调可在进入helper前被忽略。不能从一次false推“整个预期已清”，也不能从true推“事件不存在/音频无缺口”；源码明确同路由/同格式的真实变化也可能被窗口策略忽略。

表内只在0ms初始化arm；实际Recorder走R1恢复分支时可能再次arm。因此D1/D2不是完整恢复循环的真实时间线，也不意味着实际过期后永远不抑制。

These answers concern the pure helper only. The table arms only at0ms; a real R1 recovery may re-arm. This is not a full recorder recovery timeline. The real observer first checks activeToken/recordingActive. One false does not always mean a reset; true proves neither that no event occurred nor gap-free audio. Source comments explicitly allow a real same-route/same-format change to be suppressed inside the window.

## 已填录音分支核对 / Worked recorder branch review

以下8行是**源码阅读结论**，不是AVFoundation引擎、外设或控制器实测；去抖参数检查即使通过也不能代替这些集成验证。

These eight rows are **source-reading expectations**, not AVFoundation, accessory or controller runtime tests.

| 分支 / Branch | 条件与下一步 / Condition and expected branch | 不应推断 / Not established |
| --- | --- | --- |
| R1 | 未被抑制的engine配置通知；四个格式字段仍相同，可尝试重建tap/重启，保留converter与已有PCM / attempt rebuild with unchanged format | 重启成功、无采样缺口、已存音频或2秒内必恢复 / successful, lossless or timely recovery |
| R2 | 重建后sampleRate/channelCount/commonFormat/isInterleaved任一不同，fail(interrupted)并停 / any format mismatch fails closed | 自动重采样接续任何输入 / arbitrary-format seamless continuation |
| R3 | 配图或engine.start抛错，清去抖预期、fail并停 / configure/start error resets and stops | arm已证明恢复成功 / arm proves successful restart |
| R4 | 有效routeChange原因oldDeviceUnavailable或noSuitableRouteForCategory，直接fail并停 / route-loss branch stops capture | 与R1同一恢复分支，或重连自动续录 / same as R1 or automatic resume |
| R5 | interruption began、media services lost/reset会fail并停；有效ended通知被此observer忽略 / began/loss/reset fail, valid ended ignored | 电话结束自动恢复，或后台常驻监听 / auto-resume after call or background listening |
| R6 | 有效newDeviceAvailable原因只忽略**这条**route通知 / ignore this valid route notification | 已选中外接麦克风，或另无配置通知 / accessory selected or no other event |
| R7 | token旧/recordingActive=false，忽略该observer回调 / ignore obsolete callback | token认证账户或证明硬件正常 / identity authentication or healthy input |
| R8 | 短语音completion失败时controller清preview并进入failed，不走成功final转写 / failure is not final-transcription success | 已自动保存此前PCM、笔记式部分保存或自动交接 / saved partial audio, note-style persistence or delivery |

**路由变化使“抑制”不成立，不等于每种通知都直接失败。** R1配置事件若格式仍同可尝试恢复；R4是另一条停止分支。四字段相同比较不认证麦克风身份；路由签名是系统当前input UID排序后的比较，不能靠耳机图标/播放声判断。

**A route difference breaks suppression; it does not make every event follow the same failure branch.** R1 can attempt recovery with the same format; R4 stops. Format equality does not authenticate a microphone. Source compares sorted current input UIDs, not headset icons or playback sound.

源码近场偏好默认true时使用playAndRecord/voiceChat及mixWithOthers、allowBluetoothHFP；关闭时为record/default/无这些选项。这里没有要求改开关/音频配置，这些选项也不等于已选中某个蓝牙输入、所有播放profile可录音或降噪/距离成绩。录音笔记另有保存路径，不能移植它的“已存部分”承诺给本短语音失败分支。

Source near-field defaults use playAndRecord/voiceChat with mixWithOthers and allowBluetoothHFP; the opt-out differs. This is not an instruction to change settings, proof of input selection or universal Bluetooth/noise/range performance. Note recording has a separate persistence path; do not promise its partial-save behavior for short-voice failure.

## 买方可用的安全下一步 / Safe buyer next step

截至2026-11-01重新核[US App Store id6819057500](https://apps.apple.com/us/app/yihu/id6819057500)仍为**0.1.0、iOS18+**。源码契约不等商店二进制实现已逐项验收，也不证明商店缺该实现。本卡不需设备即可先离线核对；若另获准实机练习，用自有可信工作台/账号和空白未发送练习草稿，模型/权限/实际输入/目的地自动执行联动不明就停。可选语音模型约950MB，商店安装不需Mac或自行签名；供应以实际地区商店为准。

US listing rechecked2026-11-01: **0.1.0 / iOS18+**. Source contracts do not certify store-binary parity or prove absence. Use this card offline first. Only separately authorized device practice with your own trusted workspace/account and empty unsent training draft; stop if models, permissions, input or downstream automation are uncertain. Optional speech model about950MB; no Mac/self-signing for store installation. Regional supply follows the storefront.

[中文商店版上手](https://getyihu.com/start/#store-start) · [English store setup](https://getyihu.com/en/start/#store-start)

**预制中文口述 = 理想逐字文本；不是已测ASR：**
> 音频样本三十二。先核对七号标签，不提交，也不覆盖原稿。

**Preset English phrase = ideal verbatim text; not observed ASR:**
> Audio sample thirty-two. Check label seven first; do not submit or overwrite the original.

1. **先保留/核对已有结果。** 查看当前入口是短语音还是笔记、仍在录音还是错误；能回放的已存材料再回放，不能假定失败短语音已有可回放文件。/ Inspect the actual capture path/state and any existing result; replay only material actually saved.
2. **分别核输出和输入。** 耳机有声不证明耳机麦克风录入；如获准，先稳定使用手机麦克风做单独短样本，再在另一独立样本中比较外设。不要为复现而主动来电、热拔插、模拟系统中断或叠录。/ Playback is not capture. If authorized, make separate stable phone/accessory samples; do not induce calls, hot-unplugging, OS interruptions or overlapping captures for this exercise.
3. **核32、7及两个否定。** 有缺字、截断、错误或输入未知就标未通过/未知，不把不同次音频/录文拼接为“一次无中断成功”。前一次可能已有文字，先看目标草稿，不盲目重插。/ Check32,7 and both negations. Mark gaps/uncertainty honestly; do not stitch separate takes into a single successful capture or blindly repeat insertion.
4. **到未发送草稿即停。** 不按Send/Run、不覆盖原件、不后台常驻监听；App不代发不保证目的工作台不保存/同步/自动处理。反馈只给脱敏版本/型号/事件类别/合成结果，不公开完整设备UID、真实音频或客户正文。/ Stop unsent; no Send/Run, overwrite or background listening. Destinations may save/sync/process input. Share only sanitized diagnostics, not full UIDs or real recordings/customer text.

**本包真实蓝牙/USB/车载、麦克风选择、录音恢复、时延/缺帧、ASR/填入/发送全not_run。** 没有设备成绩、语言准确率或硬件兼容推荐。

**Real Bluetooth/USB/car input, selection, recovery, latency/loss, ASR, insertion and sending: all not_run.** No hardware recommendation or accuracy result is supplied.

## 固定一手依据 / Fixed first-party references

采集2026-11-01，源码M`bf339e21b5ffad3f899715c285d6c52d3e291a76`：
- [原去抖helper](https://github.com/alexlee2046/yihu-ios/blob/bf339e21b5ffad3f899715c285d6c52d3e291a76/Apps/Collie/CollieAudioRecorder.swift#L39-L70)
- [observer分支/恢复/格式与路由](https://github.com/alexlee2046/yihu-ios/blob/bf339e21b5ffad3f899715c285d6c52d3e291a76/Apps/Collie/CollieAudioRecorder.swift#L281-L393)
- [短语音完成失败与final分流](https://github.com/alexlee2046/yihu-ios/blob/bf339e21b5ffad3f899715c285d6c52d3e291a76/Apps/Collie/CollieVoiceController.swift#L437-L495)
- [中文在役恢复矩阵](https://getyihu.com/guides/audio-route-recovery-matrix/) · [English recovery matrix](https://getyihu.com/en/guides/audio-route-recovery-matrix/)
- [中文蓝牙输入](https://getyihu.com/guides/bluetooth-audio-input-troubleshooting/) · [English Bluetooth input](https://getyihu.com/en/guides/bluetooth-audio-input-troubleshooting/)

新写合成材料Apache-2.0；既有源码保原许可。无真实客户/硬件实测背书，不创建商机/设备监控/回复后端。
