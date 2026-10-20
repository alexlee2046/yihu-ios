---
layout: ../../layouts/Wave3Guide.astro
title: "Watch点了在手机打开就打开了吗？queued、前台路由与本地任务核对"
description: "核open基本消息确认与phone前台二次验证；sourceToken不当登录权限，不套用voice/draft的taskToken门，queued非UI/业务成功。"
lang: zh
---

<h2 id="first-answer">接纳打开请求，不等手机已经显示正确事项</h2>

open消息的queued仅确认基本字段形状，随后才设置openRequest。phone须前台，再核UUID、当前本地snapshot事项、待处理状态及sourceToken，且通过切换/交接门才呈现。不能把queued当已打开，也不能把voice/draft路径的taskToken检查搬到这条open路径。打开不是提交或审批。

## 与跨端字段、Watch语音和草稿恢复的区别

字段核显示，语音核queued/ready转写，恢复核phone草稿；这里核**打开请求从配对消息到手机UI路由的时点**。不操作Watch/手机或触发真实跳转。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 接收形状 | kind/open与workbench/task/sourceToken字符串 | 更深验证在phone路由 | queued已验证全部语义 |
| pending请求 | openRequest含nonce | 本地待处理触发值 | 任务版本或审批凭证 |
| 前台 | scenePhase.active才路由 | 未前台可仍保留请求 | 必能唤醒/解锁手机 |
| 事项 | 当前本地snapshot查id/状态 | 本地已知，不是保证网络最新 | 点击必自动刷新后台 |
| 来源 | sourceToken对配置字段 | 指纹非账户授权 | 登录/任务签字完成 |
| 不同通道 | open不是voice/draft准入集合 | 不套taskToken规则 | 所有消息检查一样 |
| 阻塞/无效 | 切换受阻可保留，无效清请求并提示 | 实际剩余请求/台账 | 失败就后台盲重试业务 |
| 显示设置 | 调整tasks/筛选/标题搜索后呈现 | UI选择非源数据变更 | 完成审批或服务回执 |

</div>

## 合成打开记录

只有queued，手机仍未前台，便记录待路由而非已展示事项。若提示事项变化或不可见，在既有权限内核手机台账，不用旧表卡作最终业务判断。

nonce和筛选更新不代表服务动作、来源真实性或新审批。本文未测配对/唤醒/视觉，不保证外部源实时刷新或后台接力。

## FAQ

<h3 id="faq-1">queued能证明手机已打开吗？</h3>

不能，接纳与后续UI验证/呈现分开。

<h3 id="faq-2">open也核taskToken吗？</h3>

不能从voice/draft路径套用，引用的open路由核sourceToken及本地任务等。

<h3 id="faq-3">手机后台会自动解锁展示吗？</h3>

没有此保证，路由要求前台，消息接纳不是解锁授权。

<h3 id="faq-4">查到任务就是服务器最新吗？</h3>

不是独立证明，此处查当前本地snapshot，真实源状态另核。

<h3 id="faq-5">改筛选意味着改了事项状态吗？</h3>

不意味着，UI显示设置与源事项业务状态不同。

<h3 id="faq-6">本文实际发起了打开或审批吗？</h3>

没有，只核消息与UI路由，不执行真实跳转或业务动作。

## 相关指南与源码

[跨端字段](/guides/cross-device-field-presentation/) · [语音回报](/guides/watch-voice-queued-ready-boundaries/) · [草稿恢复](/guides/reply-draft-restoration-scope/) · [开始](/start/) · [隐私](/privacy/)

[open接纳](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWatchPhoneBridge.swift) · [openWatchTask路由](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShellApp.swift)
