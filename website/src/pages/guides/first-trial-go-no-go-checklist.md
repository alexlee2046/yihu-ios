---
layout: ../../layouts/Wave3Guide.astro
title: "第一次试一呼：先确认四样准备，再试一份草稿"
description: "先确认自己有网页工作台、源码安装条件、可用语音模型和安全的示例草稿。缺哪一项就先补哪一项，不必用真实业务资料试探。"
lang: zh
---

<h2 id="first-answer">先做一个有用的检查</h2>

先确认自己有网页工作台、源码安装条件、可用语音模型和安全的示例草稿。缺哪一项就先补哪一项，不必用真实业务资料试探。

## 按这个顺序做

1. 写下这次要完成的任务：例如把一句想法放进自己的网页草稿。
2. 核对Mac/Xcode/XcodeGen、自有签名、iOS 18+与可信HTTPS工作台。
3. 检查兼容模型已下载可用，再按需要准备麦克风权限和录音同意。
4. 用合成句子试一次，回看文字和目的地，再决定是否继续真实任务。

<div role="region" aria-label="按情况选择下一步" tabindex="0">

| 遇到的情况 | 你可以怎么做 | 继续前确认 |
|---|---|---|
| 任务匹配 | 已有Agent网页工作台，希望少切应用。 | 只需转文字时，轻量转录工具可能更省事。 |
| 安装条件 | 有源码构建环境与自己的签名。 | 沿用接入指南准备，不借用账号或签名。 |
| 模型与录音 | 模型可用、环境安全并有同意。 | 准备好后再试一句。 |
| 示例目的地 | 合适的未发送草稿。 | 网页可能保存/同步草稿，先了解资料处理方式。 |

</div>

## FAQ

<h3 id="faq-step-1">要多久才能装好？</h3>

按实际构建、模型下载和服务情况准备；这是一份检查单，不承诺五分钟装好或接通。

<h3 id="faq-step-2">官网预览能代替设备试用吗？</h3>

预览帮助理解操作；实际设备、模型和目的输入框仍要分别试。

<h3 id="faq-step-3">没有工作台怎么办？</h3>

先判断是否只需要转录工具；一呼目前提供源码客户端与接入说明，后端由你自己准备。

<h3 id="faq-step-4">这张表可以导入App吗？</h3>

它是人工检查单，不是App的配置导入格式；下一步按接入指南操作。

## 回到自己的任务

[语音草稿](/guides/iphone-agent-voice-drafts/) · [输入排障](/guides/bluetooth-audio-input-troubleshooting/) · [录音笔记](/guides/recording-notes-handoff/) · [接入条件](/start/) · [隐私](/privacy/)

<details><summary>实现参考</summary>

[README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)

</details>
