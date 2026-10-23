---
layout: ../../layouts/Wave3Guide.astro
title: "音频块结束不等录音结束：noDataNow、endOfStream与尾部排空"
description: "核有状态转换器跨块保留、finish至多16次排空与停止边界；块/尾部不是语义断句或零丢失保证，不新增文件转码器。"
lang: zh
indexable: false
---

<h2 id="first-answer">暂时没有下一块，不该被解释成整段音频已经结束</h2>

现有PCM转换器跨tap块保留状态，普通块之后用noDataNow，而非每块endOfStream。finish才发出流结束并在有界循环中排出延迟样本，最多16次且可提前结束。它是内部流处理，不是文件转码工具、语义分段或录音完整性认证。

## 与格式准入、队列压力和分段转写的区别

格式指南核输入形状，队列指南核积压，分段指南核后续识别窗口；这里核**块间状态与整条流的结束契约**。没有执行音频转换、重置或实际录音。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 转换器寿命 | 整次采集保留有状态实例 | 原sourceFormat与块序列 | 每块重建都无边界影响 |
| 普通输入 | 一次供给当前块后可noDataNow | 暂缺数据与结束分开 | 每块都能当完整流 |
| endOfStream | 留给finish阶段 | 实际停止/排空结果 | 看到空块就全部处理完 |
| 尾部循环 | 最多16次，遇结束/空样本可停 | 调用预算不是时间/帧数 | 16秒/16帧完成SLA |
| reset | 取消/原路径按实现重置 | 旧状态与新采集分开 | 重置能恢复未采到内容 |
| 块复制 | PCMChunk将数据复制跨队列 | 可复用输入缓冲的生命周期 | 源码复制就是内容真实性 |
| 最终结果 | 仍核管线失败/时长/空结果 | final与预览/按钮分开 | finish必定成功且每词无损 |
| 对外交接 | 原目标/一次标记继续 | 真正文字和服务回执 | 内部转换等于可发送或云转码 |

</div>

## 合成流序列

块甲后暂时没有块乙：实现使用noDataNow维持转换状态；真正结束才进入finish。不能把每次tap回调的结束当整段结束，也不能把有尾部输出当每个原词完整的证明。

源码注释解释保留状态是为避免重置造成边界历史损失，但这不是实际设备的零丢失成绩。本文不建议通过反复reset、改结束标志或扩大循环绕过错误，也不把内部转换宣传为新导入/转码服务。

## FAQ

<h3 id="faq-1">每个tap块结束都该endOfStream吗？</h3>

当前实现不是这样，普通块间用noDataNow，finish才结束流。

<h3 id="faq-2">16次就是16秒或16帧吗？</h3>

不是。它是排空调用次数上限，不是时延或音频长度单位。

<h3 id="faq-3">每块重新建转换器是否完全等价？</h3>

不能这样说。有状态转换保留历史/priming，重建不等原设计连续处理。

<h3 id="faq-4">finish有输出是否证明整段无损？</h3>

不证明。实际音频、错误、最终文字与完整性仍需核。

<h3 id="faq-5">块复制是不是归档原件校验？</h3>

不是，它处理缓冲生命周期，不提供签名或内容真实性。

<h3 id="faq-6">这里能转换任意文件吗？</h3>

没有新增这类工具，只核现有内部PCM流，不运行文件转换。

## 相关指南与源码

[格式准入](/guides/pcm-format-admission-review/) · [队列与final](/guides/capture-buffer-pressure-checklist/) · [识别分段](/guides/note-segment-join-provenance/) · [开始](/start/) · [隐私](/privacy/)

[转换器/convertOnce/finish](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/ColliePCMStream.swift) · [tap与停止入口](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift)
