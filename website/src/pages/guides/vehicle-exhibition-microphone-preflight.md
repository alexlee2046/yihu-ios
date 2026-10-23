---
layout: ../../layouts/Wave3Guide.astro
title: "停车或展会记录前，先试录一句"
description: "先到安全、允许录音的位置，选好想用的麦克风，录一句合成内容再回放。确认声音和文字都可用后，再开始自己的笔记。"
lang: zh
---

<h2 id="first-answer">先做一个有用的检查</h2>

先到安全、允许录音的位置，选好想用的麦克风，录一句合成内容再回放。确认声音和文字都可用后，再开始自己的笔记。

## 按这个顺序做

1. 停车停稳或离开展会通道，确认参与者的录音同意与采集范围。
2. 暂停其他播放与通话，核对系统提供的输入选项；输入和输出分开看。
3. 用“不要发送这3项示例清单，只留草稿”试录一句，回放后核对转写中的数字和否定词。
4. 打开正确的未发送草稿，检查文字和目的地；换设备或接完电话后再试一句。

<div role="region" aria-label="按情况选择下一步" tabindex="0">

| 遇到的情况 | 你可以怎么做 | 继续前确认 |
|---|---|---|
| 手机麦克风 | 先做一次对照录音。 | 能录到后再比较外设。 |
| 蓝牙耳机 / 停车后的车机 | 看实际可选输入，再试录。 | 能播放音乐只说明输出正常。 |
| 有线 / USB 外设 | 检查系统是否提供输入。 | 已有设备先试，不必先买新配件。 |
| 现场声音太复杂 | 换到更安静的位置或改用手动笔记。 | 设备、环境和模型一起影响结果。 |

</div>

## FAQ

<h3 id="faq-step-1">可以边开车边试吗？</h3>

请先停车。不得在驾驶或需要注意环境时操作手机。

<h3 id="faq-step-2">展会上用什么材料试？</h3>

用合成句子并限定录音范围，避免顾客资料和无关人员谈话。

<h3 id="faq-step-3">哪个耳机一定更好？</h3>

先在自己的设备试录。这里没有高噪实测或型号性能保证。

<h3 id="faq-step-4">换设备后从哪里继续？</h3>

回到开始前的短试录，核对新输入和已有草稿，再继续。

## 回到自己的任务

[语音草稿](/guides/iphone-agent-voice-drafts/) · [输入排障](/guides/bluetooth-audio-input-troubleshooting/) · [录音笔记](/guides/recording-notes-handoff/) · [接入条件](/start/) · [隐私](/privacy/)

<details><summary>实现参考</summary>

[README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md) · [冻结实现](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift)

</details>
