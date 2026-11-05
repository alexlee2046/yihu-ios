---
layout: ../../layouts/Wave3Guide.astro
title: "户外停下后或门店空闲时，把一句想法留成草稿"
description: "先找安全静止的位置，用一条无真实业务内容的句子试通录音、文字和目的草稿，再决定是否继续。需要即时联络时，沿用团队已有通信方式。"
lang: zh
---

<h2 id="first-answer">先做一个有用的检查</h2>

先找安全静止的位置，用一条无真实业务内容的句子试通录音、文字和目的草稿，再决定是否继续。需要即时联络时，沿用团队已有通信方式。

## 按这个顺序做

1. 户外先停稳；门店避开热源、车辆、通道与正在服务的区域。
2. 准备好自己的签名、兼容模型、麦克风权限和可信HTTPS工作台。
3. 选择短语音草稿或本地录音笔记的一条路径，试一句“整理示例物品清单”。
4. 看目的地是否已有文字；核对后再使用。若结果不清楚，保留原文先查目标。

<div role="region" aria-label="按情况选择下一步" tabindex="0">

| 遇到的情况 | 你可以怎么做 | 继续前确认 |
|---|---|---|
| 有话要即时通知同事 | 先用既有通信工具。 | 一呼适合记录并接续文字任务。 |
| 一句简短想法 | 转写后检查网页草稿。 | 网页仍可能保存或同步草稿。 |
| 一段较长记录 | 保留录音与分段文字，再选择整理工具。 | 较长文字可走现有Markdown材料路径。 |
| 现场网络不稳定 | 先保留可用的本地音频和文字。 | 远程网页与业务回复等联网后再核对。 |

</div>

## FAQ

<h3 id="faq-step-1">骑行时可以一直口述吗？</h3>

请停车后操作；本页不提供驾驶、持续免按键或锁屏调度方案。

<h3 id="faq-step-2">语音不清楚怎么办？</h3>

先回放，换到更安静位置或手动记下要点；没有针对风噪或特定耳机的实测成绩。

<h3 id="faq-step-3">门店适合先试什么？</h3>

用不含订单和个人资料的合成清单，得到同意后再录。

<h3 id="faq-step-4">已经出现旧草稿怎么办？</h3>

先核对已有内容，按目的地的编辑方式修改；不要把重复填入当成自动去重。

## 回到自己的任务

[语音草稿](/guides/iphone-agent-voice-drafts/) · [输入排障](/guides/bluetooth-audio-input-troubleshooting/) · [录音笔记](/guides/recording-notes-handoff/) · [相关场景选型](/guides/voice-workbench-vs-radio-chat/) · [接入条件](/start/) · [隐私](/privacy/)

<details><summary>实现参考</summary>

[README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md) · [冻结实现](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift)

</details>

<h2 id="syn-level-35">SYN-LEVEL-35：静止试音先核原词，不追满电平条</h2>

合成包预填14组双管线数值：短语音RMS乘2限制到0至1，长笔记成功写入后RMS乘12并上限1。同输入可短条未满/长条已满，不同RMS也可显示同0.5；空新块或合成写失败可保长路旧level。条长不是风噪/标准dB SPL/识别率或已保存证据，显示裁剪也不证明麦克风削波。

<a href="/samples/p12-level-preflight/level-preflight.zh.json" download>下载SYN-LEVEL-35中文合成输入与预期</a> · <a href="/samples/p12-level-preflight/preflight-card.md" download>阅读中英已填静止试音核对卡</a>

仅原函数隔离数值/内存替身核验；真实麦克风、风噪、标准声压、准确率、ASR/填入/发送全not_run。商店0.1.0/id6819057500安装不需Mac/Xcode/自行签名，与上文源码准备分开；沿11/05官方证据按同语商店段核自有工作台/账号、模型/权限/安全目标。先静止并取得同意，不为追满条加音量、重复填入或后台监听。
