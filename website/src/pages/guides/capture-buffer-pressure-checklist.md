---
layout: ../../layouts/Wave3Guide.astro
title: "录音处理跟不上输入怎样核？短语音队列、预览快照与最终结果"
description: "核短语音源帧队列预算与bufferOverflow、停止排空和final边界；半秒量级预算非延迟SLA、总内存或长笔记上限，不新增自适应调参。"
lang: zh
---

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
