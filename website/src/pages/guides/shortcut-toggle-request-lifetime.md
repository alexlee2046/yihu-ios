---
layout: ../../layouts/Wave3Guide.astro
title: "快捷指令返回就开麦了吗？30秒录音切换请求与一次消费"
description: "核AppIntent仅置pendingToggle、前台就绪消费与录音中结束；30秒窗口非响应SLA/后台权限，重复请求Bool非N次排队，不保证设备绑定。"
lang: zh
indexable: false
---

<h2 id="first-answer">系统意图返回，不等录音、填入或发送已经完成</h2>

ToggleVoiceInputIntent设置pendingToggle并请求打开App，真正开始或结束由前台工作台消费。活请求窗口30秒、一次消费；重复请求刷新Bool/时点，不是逐次计数队列。就绪可开始、录音中可结束，其他条件等待或过期失效。窗口不是30秒必响应，也不绕过麦克风权限和目标交接。

## 与权限样本、忙态和前台音频重绑的区别

权限核授权，忙态核准入，重绑核音频路由；这里核**系统意图到本机录音切换请求的生命周期**。不注册或运行Siri/动作按钮/快捷指令，不开麦。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| Intent | perform仅requestToggle/result | 请求与实际采集分开 | 返回就是录音成功 |
| 系统入口 | openAppWhenRun声明 | 系统绑定/可用性另核 | 所有设备已绑定所有口令 |
| pendingToggle | Bool与requestedAt | 重复可刷新请求时点 | N次输入必执行N次录音 |
| consumeToggle | 活窗口一次消费且清待处理 | 30秒有效性非速度 | 30秒内一定开始 |
| 前台工作台 | active及笔记/录音等门 | 真实界面状态 | 后台长等后静默开麦 |
| 状态切换 | ready开始，recording结束 | 同一入口非永远启动 | 再次运行必新建一条录音 |
| 权限/目标 | 仍走原语音和交接条件 | 实际授权/目标/回执 | Intent已发送Agent命令 |
| 过期 | 不在很久后消费旧意图 | 需新鲜用户动作 | 无限排队/恢复保证 |

</div>

## 合成意图记录

只拿到系统意图result，应记录请求阶段，不能给出成功录音或已填输入框结论。若当时在录音，再次入口可用于结束而非另起一条；核实际状态，不按按钮次数猜材料数量。

声明可供系统使用的入口，不等所有Siri自然语言、硬件绑定或设备可用性已经实测。本文不自动配置入口、不授权后台录音或执行Agent任务。

## FAQ

<h3 id="faq-1">Intent返回是否录音已成功？</h3>

不是，perform设置请求，前台消费者和后续录音另核。

<h3 id="faq-2">30秒是响应时间承诺吗？</h3>

不是，是活请求消费窗口，不能推设备/识别延迟。

<h3 id="faq-3">多次运行是否积攒同样多录音？</h3>

不能推，pending是Bool而非计数队列，状态切换还可能结束当前录音。

<h3 id="faq-4">录音中再次运行会怎样？</h3>

现有入口支持结束录音，仍以实际前台状态/条件为准。

<h3 id="faq-5">后台或未授权时会强制开麦吗？</h3>

不会由这个意图绕过前台/权限门，也不保证后台接力。

<h3 id="faq-6">本文验证了Siri/硬件绑定吗？</h3>

没有。只核入口源码，不配置或测试具体设备入口。

## 相关指南与源码

[权限样本](/guides/microphone-permission-sample-contract/) · [忙态准入](/guides/audio-busy-state-admission/) · [前台重绑](/guides/foreground-audio-rebind-preflight/) · [开始](/start/) · [隐私](/privacy/)

[Intent/30秒/一次消费](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceShortcuts.swift) · [runPendingShortcut](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShellApp.swift) · [实际采集/交接状态](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceController.swift)
