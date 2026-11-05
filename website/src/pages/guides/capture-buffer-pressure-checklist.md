---
layout: ../../layouts/Wave3Guide.astro
title: "录音处理跟不上输入怎样核？短语音队列、预览快照与最终结果"
description: "核短语音源帧队列预算与bufferOverflow、停止排空和final边界；半秒量级预算非延迟SLA、总内存或长笔记上限，不新增自适应调参。"
lang: zh
---

<h2 id="syn-buf-37">SYN-BUF-37：等待帧水位、失败与分段边界</h2>

SYNTHETIC_EXAMPLE，仅源管线+可控内存队列；不是设备压力/丢帧实测。

[ZH: /samples/p16-buffer-pressure/buffer-pressure-preflight.zh.json](/samples/p16-buffer-pressure/buffer-pressure-preflight.zh.json) · [EN: /samples/p16-buffer-pressure/buffer-pressure-preflight.en.json](/samples/p16-buffer-pressure/buffer-pressure-preflight.en.json) · [Card: /samples/p16-buffer-pressure/preflight-card.md](/samples/p16-buffer-pressure/preflight-card.md)

<div role="region" aria-label="合成采集队列水位与完成边界核查，可左右滚动" tabindex="0">

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

</div>

源是有界数组FIFO，不是覆盖旧帧的环形队列；ring索引不适用。max(ceil(sourceRate/2),4096)是等待源帧，不是字节、总RAM或延迟SLA。溢出失败与到时长裁末块不同，不自动另开分段。Q9尾超预算可出现snapshot仍可读但最终失败，Q10空快照也不能当成功。真实转换/并发/硬件丢帧/ASR/填入发送全not_run，保留失败原件与未知，不盲重录/重发；token预算不能修补采集缺口。商店安装无需Mac/自签名，自有可信工作台/模型/权限与目的地另核，目的地可能存/同步/自动处理。

<h2 id="first-answer">bufferOverflow是失败边界，不应把部分预览当完整录音</h2>

短语音PCM管线用串行队列和有界源帧预算；等待帧超过max(ceil(sourceRate / 2), 4096)会记录bufferOverflow并停止接纳，最终走失败。snapshot不等待队列排空，只是当前输出快照。不能凭预览已有文字/音量，宣布完整采集和交付成功。

## 与PCM准入和路由恢复的区别

格式准入核输入形状，路由恢复核系统事件；这里核**处理压力下的队列、停止、快照和最终结果含义**。只限该短语音管线，不把其预算推广为长笔记限制或设备性能测试。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 队列预算 | max(ceil(sourceRate / 2), 4096)源帧 | 等待量与实际错误 | 固定半秒端到端延迟SLA |
| 合成算例 | 48000 Hz对应24000等待源帧 | 这是帧预算，不是字节 | 整个App总RAM精确上限 |
| 溢出 | bufferOverflow失败、停止接纳 | 实际错误和未完成状态 | 静默丢块后仍完整成功 |
| snapshot | 不为预览排空队列 | 当前输出与最终输出分开 | 预览包含所有已入队音频 |
| 正常requestStop | 停止接纳，处理队列并flush尾部 | 返回的最终结果或失败 | 按停按钮立即证明全部完成 |
| 时长边界 | 入参有限且至多30秒 | 正常到限停止与durationExceeded分开 | 所有到30秒都报错或长笔记也30秒 |
| cancel | 清待处理/输出并重置 | 取消与已提交副作用分开 | 还有隐形备份可完整恢复 |
| 后续交接 | 仍依final与原守卫 | 结果/目标/旧尝试 | 调参数或重录自动授予重发 |

</div>

## 合成压力结论

预览存在，但最终返回bufferOverflow。结论：不能把预览当完整最终结果；标明失败与缺口。排查不应任意放大队列、跳过格式/模型条件或据此宣称特定设备算力不足。

源码预算不证明实时性能、噪声或识别准确率；正在转换的块、输出和其他内存也不是只由等待帧数代表。本页没有压测、录音或修改管线。

## FAQ

<h3 id="faq-1">半秒源帧预算就是半秒延迟吗？</h3>

不是。它是等待帧准入量，不能等同端到端延迟或所有系统调度。

<h3 id="faq-2">24000帧是不是24000字节？</h3>

不是。帧、声道、采样数据布局与总内存不同，不能直接混算。

<h3 id="faq-3">预览有文字能忽略溢出吗？</h3>

不能。最终失败不因部分预览存在而变成完整成功。

<h3 id="faq-4">snapshot会等所有输入处理完吗？</h3>

当前实现不为预览排空队列，须与最终停止结果区分。

<h3 id="faq-5">30秒上限适用于所有长笔记吗？</h3>

不适用。这里是短语音管线，长录音写盘路径不同。

<h3 id="faq-6">本文是否新增自动调队列或云回退？</h3>

没有。只核源码失败边界，不提供调参/回退/零丢失保证。

## 相关指南与源码

[PCM格式准入](/guides/pcm-format-admission-review/) · [路由恢复](/guides/audio-route-recovery-matrix/) · [重录缺口](/guides/interruption-recapture-preflight/) · [开始](/start/) · [隐私](/privacy/)

[队列预算/snapshot/停止与失败](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/ColliePCMStream.swift) · [短语音时长入口](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift)
