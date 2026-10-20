---
layout: ../../layouts/Wave3Guide.astro
title: "同源为什么仍不能填入？浏览器origin、页面与存储范围核对"
description: "核scheme/host/有效端口、origin派生WebKit存储及页面/请求守卫；工作台名不同不保证存储隔离，同源不等账户、草稿或写权限。"
lang: zh
---

<h2 id="first-answer">同origin不是同页面、同草稿或已获得操作许可</h2>

CollieWebSession的isTrusted比较配置baseURL的scheme、host和有效端口，并检查会话未失效；不是靠页面标题或域名看起来相似。WebKit持久存储键从归一origin派生，路径或工作台名称不同不自动变成独立存储。插入路径仍可核expectedPageURL、requestID和适配器条件，同源通过不等可发送。

## 与Radar源URL、追问上下文和草稿恢复的区别

源URL指南核数据源地址，追问指南核上下文，恢复指南核本地草稿；这里核**浏览器origin比较、存储隔离键与具体页面插入条件**。不打开网页、读Cookie或改配置。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 原生origin比较 | scheme/host按小写比较及有效端口 | 配置边界与当前URL | 可信账户/内容认证 |
| 默认端口 | HTTPS 443、HTTP 80按实现比较 | 省略与显式默认值 | 可为兼容随意降级HTTP |
| path/标题 | 不是该origin比较的身份键 | 具体页面与完整URL条件 | 同标题/路径就有授权 |
| 持久存储键 | 归一origin的SHA摘要派生identifier | 同origin容器可能复用 | 每个工作台名字独立Cookie仓 |
| 同存储不等账号 | 服务Cookie路径/登录状态另核 | 实际账户与权限 | 共享容器就保证同一登录人 |
| 页面/请求 | 可选expectedPageURL和准备请求等条件 | 当前页面与请求归属 | origin通过即跳过目标守卫 |
| 适配结果 | 拒绝/未知不随便降级重试 | 真实结果与草稿状态 | 填入即发送/审批 |
| 原生其他数据 | Radar/笔记有独立路径 | 不同存储面分别核 | WebKit容器就是全部档案 |

</div>

## 合成origin比较

https://example.com/a与https://example.com:443/b可归同origin存储键；并不因此成为同一页面或草稿。若具体交接绑定原页面，页面变化仍需按该路径的条件处理。

这里不把isTrusted名字当网站安全、账户真实性或AI会话记忆认证，也不把持久存储容器相同当业务登录有效。示例未访问，未读取任何用户浏览数据。

## FAQ

<h3 id="faq-1">同源就能向任何输入框写吗？</h3>

不能。页面、请求、焦点/适配器及调用者许可等原守卫仍在。

<h3 id="faq-2">工作台名字不同就各有独立Cookie吗？</h3>

不能由名称推断，引用存储键由归一origin派生。

<h3 id="faq-3">HTTPS省端口和写443是否一定不同源？</h3>

该有效端口比较将默认端口对应起来，但完整页面条件另核。

<h3 id="faq-4">同一个容器就证明同一账号吗？</h3>

不证明。实际Cookie范围、登录与服务权限独立核。

<h3 id="faq-5">isTrusted是否安全或真实性认证？</h3>

不是本文提供的认证，它是实现边界条件，不能代内容/身份/权限。

<h3 id="faq-6">本页打开网页或检查Cookie了吗？</h3>

没有，只核固定源码，不执行登录、数据读取或配置变更。

## 相关指南与源码

[源URL区别](/guides/radar-feed-url-boundary-preflight/) · [追问目标](/guides/follow-up-context-preflight/) · [原生草稿](/guides/reply-draft-restoration-scope/) · [工作台边界](/guides/voice-workbench-vs-radio-chat/) · [开始](/start/) · [隐私](/privacy/)

[isTrusted/origin存储/insertTranscript](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWebView.swift) · [页面适配守卫](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieTextInsertion.swift)
