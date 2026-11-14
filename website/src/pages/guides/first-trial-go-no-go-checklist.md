---
layout: ../../layouts/Wave3Guide.astro
title: "一呼怎么用？先试免登录草稿，再装 iPhone 客户端"
description: "无需登录或麦克风，先用示例体验一呼语音草稿，再从 App Store 安装。准备自己的 HTTPS 工作台与账号，需要语音时再下载模型，核对文字后发送。"
lang: zh
privacyPreview: true
---

<h2 id="first-answer">先试一句示例草稿，再准备自己的工作台</h2>

先从 App Store 安装，准备自己的 HTTPS 工作台、账号和一份安全草稿。需要语音输入时，再下载约 950 MB 的可选语音模型。

## 按这个顺序做

1. 写下这次要完成的任务：例如把一句想法放进自己的网页草稿。
2. [从 App Store 获取一呼](https://apps.apple.com/us/app/yihu/id6819057500)，再接入可信 HTTPS 工作台。商店安装不需要 Mac 或自行签名；设备与地区供应请查看商店。
3. 检查兼容模型已下载可用，再按需要准备麦克风权限和录音同意。
4. 用合成句子试一次，回看文字和目的地，再决定是否继续真实任务。

<div role="region" aria-label="按情况选择下一步" tabindex="0">

| 遇到的情况 | 你可以怎么做 | 继续前确认 |
|---|---|---|
| 任务匹配 | 已有Agent网页工作台，希望少切应用。 | 只需转文字时，轻量转录工具可能更省事。 |
| 安装条件 | 从 App Store 安装。 | 使用自己的工作台地址与账号；源码构建可另行选择。 |
| 模型与录音 | 模型可用、环境安全并有同意。 | 准备好后再试一句。 |
| 示例目的地 | 合适的未发送草稿。 | 网页可能保存/同步草稿，先了解资料处理方式。 |

</div>

## FAQ

<h3 id="faq-step-1">要多久才能装好？</h3>

按 App 安装、可选语音模型下载和工作台准备情况安排时间。开发者若选择源码构建，可另看构建与签名说明。

<h3 id="faq-step-2">官网预览能代替设备试用吗？</h3>

预览帮助理解操作；实际设备、模型和目的输入框仍要分别试。

<h3 id="faq-step-3">没有工作台怎么办？</h3>

先判断是否只需要转录工具；一呼接入你已有的工作台，地址、账号和后端由你自己准备。

<h3 id="faq-step-4">这张表可以导入App吗？</h3>

它是人工检查单，不是App的配置导入格式；下一步按接入指南操作。

## 回到自己的任务

[语音草稿](/guides/iphone-agent-voice-drafts/) · [输入排障](/guides/bluetooth-audio-input-troubleshooting/) · [录音笔记](/guides/recording-notes-handoff/) · [接入条件](/start/) · [隐私](/privacy/)

<details><summary>实现参考</summary>

[README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)

</details>
