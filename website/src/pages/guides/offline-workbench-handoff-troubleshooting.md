---
layout: ../../layouts/Wave3Guide.astro
title: "文字已经转出、网页却打不开？按这三步继续"
description: "保留原文，先看手机上的音频和文字，再单独检查网页连接。等网络与目的地确认后继续，避免为了重试而重复交接。"
lang: zh
---

<h2 id="first-answer">先做一个有用的检查</h2>

保留原文，先看手机上的音频和文字，再单独检查网页连接。等网络与目的地确认后继续，避免为了重试而重复交接。

## 按这个顺序做

1. 保留原文和已有录音，查看这次处理是否完成或中断。模型应已下载、校验并可用。
2. 在手机上检查正确工作台能否通过可信HTTPS打开和登录；保持原有安全设置。
3. 回到目的地看是否已有草稿；已出现就检查它，结果不明先核对同一次请求的记录。

<div role="region" aria-label="按情况选择下一步" tabindex="0">

| 遇到的情况 | 你可以怎么做 | 继续前确认 |
|---|---|---|
| 本地有文字，网页打不开 | 先留下录文。 | 再查手机连接、HTTPS和服务登录。 |
| 附件留在分享托盘 | 检查具体文字/Markdown版本。 | 暂存之后的上传与发送按目标服务确认。 |
| Radar卡片还在，刷新失败 | 查看来源时间和读取提示。 | 以旧资料待核处理，不把请求时间当资料更新。 |
| 确认回复后超时 | 保留同一次请求的记录。 | 在原服务核结果，不换新身份盲目重发。 |

</div>

## FAQ

<h3 id="faq-step-1">所有步骤都能离线吗？</h3>

已准备的模型与本地笔记可有本地处理路径，模型下载、网页与服务操作仍各有联网条件。

<h3 id="faq-step-2">网页已登录，简报源为什么读不到？</h3>

原生读取与网页会话分开。需要登录的资料按支持的文件导出路径准备，避免把凭据放进URL。

<h3 id="faq-step-3">筛选后为零怎么办？</h3>

先核项目、状态、搜索与来源提供的范围，再决定是否真的没有待办。

<h3 id="faq-step-4">网络恢复后马上重试吗？</h3>

先看原目的地和同一次请求是否已有结果，再决定下一步，避免重复副本或业务操作。

## 回到自己的任务

[语音草稿](/guides/iphone-agent-voice-drafts/) · [输入排障](/guides/bluetooth-audio-input-troubleshooting/) · [录音笔记](/guides/recording-notes-handoff/) · [每日简报](/guides/multi-project-radar-watch/) · [接入条件](/start/) · [隐私](/privacy/)

<details><summary>实现参考</summary>

[README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md) · [冻结实现](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarStore.swift)

</details>
