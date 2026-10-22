---
layout: ../../layouts/Wave3Guide.astro
title: "iPhone 蓝牙耳机能听到却录不到？四步检查输入设备"
description: "用四个实际检查区分播放与拾音，排查蓝牙耳机、停车后的车载音频和手机麦克风；附清晰的下一步。"
lang: zh
---

<h2 id="first-answer">先找到一个有用的下一步</h2>

先停车或停在安全位置，暂停通话与其他播放，再试录一句。按“当前设备→能否听见→录音回放→切换后再试”对照，比反复重连更容易定位问题。

## 四步自检

<div role="region" aria-label="蓝牙音频四步检查" tabindex="0">

| 步骤 | 你要确认什么 | 下一步 |
|---|---|---|
| 1. 当前设备 | 手机、蓝牙耳机，还是停车后的车载设备？ | 先确认想用哪一支麦克风；配对名称不等于当前输入。 |
| 2. 播放声音 | 暂停其他播放后，系统提示或回放能听见吗？ | 听不见先查音量与输出；听得见后继续查录音。 |
| 3. 试录一句 | 在有权限的录音App录一句再回放。 | 若无声或很小，检查该App麦克风权限，并用手机自身麦克风对照。 |
| 4. 切换再试 | 断开外设、用手机试录，再连接外设对比。 | 手机正常而外设异常时，核系统可用的输入选择、外设状态和App兼容。 |

</div>

## 看结果，选一个动作

- **能播放、录不到：**先看所用App的麦克风权限。系统提供输入选择时核对实际设备，再试一句。
- **手机能录、耳机不能录：**保留这组对照结果，再查耳机/车机设置和连接；不要把输出正常当作麦克风已就绪。
- **切回前台或接完电话后异常：**先停当前录音，再在前台重新选择录音入口，检查保留的文字后再开始新一段。
- **都能录，只有网页没文字：**检查转写模型、当前工作台与输入框；可先保留录文，再核对目的地。

## 一呼在这条流程里做什么

一呼使用iPhone的音频输入并在准备好模型后转写，随后把文字交给兼容的网页草稿。这个检查清单帮助你选择下一步，不读取或切换网页访客的蓝牙设备。具体输入选择取决于系统、机型与所用App。车载检查请停车后进行。

## FAQ

<h3 id="faq-output">耳机能播放音乐，为什么录音还是来自手机？</h3>

播放和拾音是两个选择。先做一段手机/外设的对照录音，查看系统提供的实际输入选项。

<h3 id="faq-permission">去哪里查麦克风权限？</h3>

在iPhone“设置→隐私与安全性→麦克风”核对所用App；网页工作台的权限与原生录音入口也应分别确认。

<h3 id="faq-car">可以边开车边完成检查吗？</h3>

请停车后操作。这里是音频排障清单，不提供驾驶中操作指引或CarPlay专用界面。

<h3 id="faq-quality">能保证某款耳机的录音效果吗？</h3>

先在自己的设备和环境试录。没有逐机验证的数据时，不给耳机型号、风噪、距离或准确率承诺。

## 接着看

[语音草稿](/guides/iphone-agent-voice-drafts/) · [音频排障](/guides/bluetooth-audio-input-troubleshooting/) · [录音笔记](/guides/recording-notes-handoff/) · [每日简报](/guides/multi-project-radar-watch/) · [接入条件](/start/) · [隐私](/privacy/)

<details><summary>实现参考</summary>

[冻结实现](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift) · [README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md) · [Apple microphone help](https://support.apple.com/en-ie/101600)

</details>
