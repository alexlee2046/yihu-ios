---
layout: ../../layouts/Wave3Guide.astro
title: "近讲偏好不等于路由实测：HFP允许、会话模式与当前输入核对"
description: "按现有近讲设置和短语音启动策略核playAndRecord/voiceChat、HFP允许与输入图；不承诺强制选麦、高噪性能或所有录音路径一致。"
lang: zh
---

<h2 id="first-answer">allowBluetoothHFP是允许条件，不是外设已被选中或更准确的证明</h2>

现有短语音在start读取近讲偏好。启用策略采用playAndRecord、voiceChat及mixWithOthers/allowBluetoothHFP；关闭策略为record/default。输入图策略也随该偏好分支。它们是实现选择，不是当前硬件已成功启用、强制选择某支麦克风或实测准确率；本页不新增降噪/选麦服务。

## 与外设适用性和恢复矩阵的区别

外设前检核场景条件，恢复矩阵核录中事件；这里核**保存的偏好、启动配置、输入图和实际系统路由的证据层级**。不切换系统设置或录音，长笔记另有自己的采集路径。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 保存偏好 | 缺值时源码默认true | 实际版本与入口 | 默认值等于系统已授权 |
| 启用会话 | playAndRecord/voiceChat | setCategory/setActive结果 | 所有设备都成功或无回声 |
| HFP | allowBluetoothHFP为允许 | 实际输入路由 | 强制选中已配对耳机麦克风 |
| 混音选项 | mixWithOthers策略 | 实际输出/页面播放状态 | 网页TTS与采集无限同时可用 |
| 输入图 | 近讲策略启用voice processing等 | 实际图配置是否成功 | 固定高噪成绩或说话人识别 |
| 关闭策略 | record/default原路径 | 对应入口与当前状态 | 所有外设自动兼容 |
| 启动快照 | 本次start读取偏好 | 本次会话和后续设置区别 | 改偏好就证明旧录音已重绑 |
| 其他采集 | 长笔记路径单独实现 | 实际入口与权限/格式 | 一套策略覆盖所有录音/网页 |

</div>

## 合成策略核查

已知：偏好启用；未知：实际HFP输入与图配置结果。结论：只能说启动策略允许，不报外设选择或高噪性能。若准备/启动失败，沿原错误处理，不强行复用不一致管线。

voiceChat或voice processing名称不是风噪、距离、延迟或准确率SLA。先核实际路由和安全环境，不让策略标签替代设备/系统验收，也不扩张服务和目标权限。

## FAQ

<h3 id="faq-1">偏好为true说明麦克风已授权吗？</h3>

不说明。保存偏好与系统授权、启动结果是不同条件。

<h3 id="faq-2">HFP允许是否强制选耳机麦克风？</h3>

不是。必须核实际系统输入路由，不能只看配对或配置选项。

<h3 id="faq-3">voiceChat是否保证骑行风噪可用？</h3>

没有这种实测或SLA，本页也不建议驾驶/骑行中操作。

<h3 id="faq-4">mixWithOthers是否保证所有网页朗读和采集同时工作？</h3>

不能保证。实际页面/系统/输入输出边界仍需核。

<h3 id="faq-5">长笔记也完全沿这套近讲策略吗？</h3>

不能推广。引用的是短语音入口，长笔记采集单独核。

<h3 id="faq-6">改设置等于旧会话已经重绑吗？</h3>

不能由保存值推断。核本次启动、实际相位/路由与原守卫。

## 相关指南与源码

[外设前检](/guides/vehicle-exhibition-microphone-preflight/) · [路由恢复](/guides/audio-route-recovery-matrix/) · [权限与格式](/guides/microphone-permission-sample-contract/) · [开始](/start/) · [隐私](/privacy/)

[近讲会话/图策略与启动](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift) · [既有设置入口](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieLinkSettingsView.swift) · [长笔记独立路径](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieNoteRecorder.swift)
