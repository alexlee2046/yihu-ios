---
layout: ../../layouts/Wave3Guide.astro
title: "录音按钮可点却没录？先查模型与忙态｜一呼"
description: "先看当前阶段、待处理文字、模型与麦克风权限，分清录音、转写和测试入口。试用无需登录或麦克风的四问预览，再查看一呼隐私与 App Store 接入条件。"
lang: zh
privacyPreview: true
trialLabel: "先试录音状态四问"
---

<h2 id="first-answer">先看阶段与待处理文字，再决定是否录音</h2>

先确认当前是在准备模型、录音、转写还是交接，并保留已有待核文字。needsModel 时先准备模型，pendingTranscript 存在时先核结果；再分别检查所用入口的权限、测试保留与实际返回。不要靠反复点按钮判断收音，也不要为开始新录音清掉不确定的结果。

## 与权限、生命周期和声纹结论的区别

实现参考分别核对主按钮 `primaryActionEnabled`、`canCancel` 与笔记入口 `canRecord` / 前台 `canTranscribe`。逐项看对应阶段和返回结果，不把这些属性合成一个全局就绪结论。

权限核系统许可，生命周期核前后台，声纹核过滤结果；这里核**资源/入口忙态的不同含义与调用范围**。不启动录音、校准、模型或清空待处理文字。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 主按钮 | needsModel/recording/failed等动作可不同 | 当前phase与实际动作 | enabled就是新录音可开始 |
| ready | 还看pendingTranscript/测试标记 | 已有文字与测试状态 | ready就是全部空闲 |
| canCancel | preparing/recording/transcribing | 可取消阶段非只采样 | 麦克风始终在录 |
| delivering | 部分入口单独阻止 | 实际交付状态 | 不可取消就必定空闲 |
| 笔记录音 | canRecord与isStarting等入口条件 | 实际调用链/权限结果 | 一个guard证明所有异步阶段互斥 |
| 笔记转写 | 让步主语音，要求前台 | 可转写与已在采集分开 | 后台持续推理或录音已丢 |
| 声纹测试 | claimVoiceprintTestMic保留入口标记 | 测试保留与真正采集不同 | 标记就系统授权/身份通过 |
| 共享模型 | 笔记使用voice.transcriber | 共享对象与让步条件 | 两个模型任意多路并行/无竞态 |

</div>

## 合成忙态记录

界面主按钮可用，但phase=needsModel：不能把一次点击称为已开始采集。另有ready且pendingTranscript存在时，也不能说无待处理结果。按具体入口和实际返回核，不用一个busy标签代替全部状态。

这些是现有局部守卫，不是全局并发安全或延迟SLA。await前后的状态可能变化，仍沿原流程条件，不为吞吐反复点录音、删除待核文字或关闭保护。

## FAQ

<h3 id="faq-1">按钮enabled是否证明正在收音？</h3>

不是。不同phase可对应准备、模型或停止等不同动作。

<h3 id="faq-2">canCancel=true是否只可能录音中？</h3>

不是，准备和转写阶段也可满足该属性。

<h3 id="faq-3">phase=ready是否总能开始？</h3>

不能，只看phase不足，待处理文字/测试标记等仍要核。

<h3 id="faq-4">笔记不能转写是否等于没录到？</h3>

不等于。录音、转写、前台与模型忙态分开。

<h3 id="faq-5">共享transcriber是否承诺多路同时推理？</h3>

不承诺，源码有让步策略，不能从共享对象推出并发或性能保证。

<h3 id="faq-6">本文证明所有入口全局互斥吗？</h3>

没有。只核局部条件及调用范围，不运行并发/设备测试或新增调度器。

## 相关指南与源码

[权限与采样](/guides/microphone-permission-sample-contract/) · [前后台](/guides/foreground-audio-rebind-preflight/) · [声纹结果](/guides/voiceprint-filter-not-authorization/) · [预览与final](/guides/replaceable-voice-preview-review/) · [开始](/start/) · [隐私](/privacy/)

[按钮/phase/测试保留](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceController.swift) · [笔记canRecord/canTranscribe](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShellApp.swift) · [笔记录制与worker入口](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift)
