---
layout: ../../layouts/Wave3Guide.astro
title: "语音预览为何会改字？可替换partial、最终返回与归档范围"
description: "按完整可替换partial字符串、bufferingNewest和会话/阶段守卫核预览；中间文字不可累计成原话，不代表最终识别或送达。"
lang: zh
---

<h2 id="first-answer">partial是可替换显示，不是一段段可直接相加的录文</h2>

识别接口把onPartialText定义为完整、可替换的部分文字，只有返回的最终结果进入原可交付边界。控制器用bufferingNewest(1)处理更新，并核sessionID、阶段和取消状态。预览可能被重解码或最终结果纠正，不能把多次显示拼成多条原话、批准或执行证据。

## 与电平、分段拼接和最终回执的区别

电平是能量显示，长笔记join处理识别片段，回执核实际交接；这里核**同次识别预览更新的替换语义与取证范围**。没有运行模型或保存实际讲话。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 接口语义 | onPartialText是完整可替换字符串 | 不是增量token追加合同 | 每次更新都是新句子 |
| 更新缓冲 | bufferingNewest(1)保留最新 | 中间事件可不逐一显示 | 完整逐token时间线 |
| 会话/阶段 | sessionID/expectedPhase/取消条件 | 更新属于哪次识别 | 旧预览可接新目标 |
| 长度门槛 | 部分显示按调用前长度条件筛 | 最终返回仍可纠正 | 显示始终单调不改字 |
| 最终识别 | 停止后完整pass优先 | 真正返回/错误与旧预览 | 预览有字就final成功 |
| previewUnavailable | 可只表示预览路径失败 | 最终流程另核 | 模型必损坏/应删模型 |
| 后续过滤/目标 | final还受声纹/目标等原条件 | 文字存在不代写权 | 最终文字必已送达 |
| 人工归档 | 最终稿/处理/原音频分账 | 实际已核范围 | 预览截图是真实逐字证书 |

</div>

## 合成预览序列

先显示“样例”，后显示“样例需要复核”，最终返回“样例暂缓”。它们不是三句可直接串接的原话；不能拼成多项决策。这里仅示意替换，不代表真实模型输出或准确率。

若预览失败、取消或最终结果不同，保留实际状态和未知，不复制旧预览绕过最终/交接条件，也不把bufferingNewest当所有中间事件永久档案。

## FAQ

<h3 id="faq-1">每次partial都该append到档案吗？</h3>

不能。接口语义为完整可替换文本，追加会制造重复或冲突。

<h3 id="faq-2">看见预览就说明最终成功吗？</h3>

不说明。最终识别、过滤与交接仍可能失败或未获准。

<h3 id="faq-3">预览文字会永远只增长吗？</h3>

不作这种保证，重解码/最终结果可纠正，显示门槛也不是语义稳定性认证。

<h3 id="faq-4">bufferingNewest是否完整保存每个token？</h3>

不是。它不是全量事件档案或时间对齐功能。

<h3 id="faq-5">previewUnavailable就应删除模型吗？</h3>

不能由它推断，源码保留最终路径另核，不为预览故障自动删模型。

<h3 id="faq-6">最终文字一定已写入目标吗？</h3>

不一定。声纹/目标/原许可与实际回执仍需独立确认。

## 相关指南与源码

[电平区别](/guides/audio-level-not-accuracy-review/) · [长笔记拼接](/guides/note-segment-join-provenance/) · [回调归属](/guides/capture-completion-token-review/) · [实际回执](/guides/handoff-evidence-audit-checklist/) · [开始](/start/) · [隐私](/privacy/)

[partial接口契约](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceInterfaces.swift) · [预览/最终/目标路径](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceController.swift)
