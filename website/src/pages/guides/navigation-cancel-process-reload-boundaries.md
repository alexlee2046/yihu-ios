---
layout: ../../layouts/Wave3Guide.astro
title: "取消导航等于断网吗？加载替换、转圈复核与进程重载边界"
description: "按error domain/code区分取消/策略交接与真实加载错误；500ms复核和15秒防重载环不是恢复SLA，不保证表单或服务动作恢复。"
lang: zh
---

<h2 id="first-answer">导航被替换、页面加载失败与Web进程关闭，不是同一结论</h2>

isSupersededNavigation过滤NSURLErrorDomain的取消和WebKitErrorDomain的102；它们不直接设置加载失败卡片。延迟500ms仅在没有继续加载/错误时复核spinner。Web进程终止则尝试reload；连续终止间隔小于15秒会停下提示手动处理。这些是UI控制，不是网络、草稿或服务动作恢复保证。

## 与离线预检、origin和识别错误的区别

离线预检核业务链，origin核页面范围，识别错误核语音层；这里核**导航回调/加载替换与进程终止展示策略**。不重载真实页面，不修改证书/网络/服务。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 取消分类 | domain与code合核 | NSURLErrorCancelled所属域 | 所有取消都断网 |
| 策略交接 | WebKitErrorDomain/102 | 非HTTP业务状态 | 外部页面一定打开/服务已处理 |
| 500ms复核 | 只在无继续加载且无error时清spinner | 条件与调度分开 | 500ms恢复SLA |
| 普通加载错误 | userFacingMessage按域/代码归类 | 可见提示非完整根因 | 所有错误都一个原因 |
| 进程终止 | 先走reload策略 | Web进程与业务服务分开 | Agent任务一定失败/成功 |
| 15秒门 | 相邻终止太近则停自动重载 | 防环不等可用性保证 | 后台无限重试 |
| 重载结果 | 页面/草稿/动作另核 | 原请求实际状态 | 所有未提交字段/已执行动作恢复 |
| 安全边界 | 不为错误关闭HTTPS校验 | 原地址/权限保持 | 忽略安全错误换可用性 |

</div>

## 合成回调记录

旧加载被替换而回调取消，不能写整个工作台已离线；出现WebKit 102也不能当成HTTP102或业务确认。spinner和错误卡片只说明这一层状态，未独立核服务动作。

发生重载前后，材料/请求仍可能有待定结果，不能盲重发或承诺恢复。本文无真实页面、网络或进程回收测试；不把源码延迟当设备性能承诺。

## FAQ

<h3 id="faq-1">取消加载一定是断网吗？</h3>

不一定，替换或策略交接可被过滤，具体域/代码要合核。

<h3 id="faq-2">102就是HTTP处理成功吗？</h3>

不是，此处指WebKitErrorDomain代码，不是服务器业务回执。

<h3 id="faq-3">500ms代表半秒恢复吗？</h3>

不代表，只是条件性spinner复核的调度延迟。

<h3 id="faq-4">15秒后一定能重载成功吗？</h3>

不保证，它是防连续重载门，不是恢复SLA。

<h3 id="faq-5">reload能保证原草稿和动作恢复吗？</h3>

不能，需要原材料/实际服务状态另核，勿盲重发。

<h3 id="faq-6">本文改了网络或做过故障注入吗？</h3>

没有，只核固定导航策略，无网络/视觉/设备验收。

## 相关指南与源码

[离线链路](/guides/offline-workbench-handoff-troubleshooting/) · [页面边界](/guides/workbench-origin-page-boundaries/) · [语音错误层](/guides/recognition-error-layer-review/) · [开始](/start/) · [隐私](/privacy/)

[取消分类/导航失败/进程终止](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWebView.swift)
