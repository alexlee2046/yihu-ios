---
layout: ../../layouts/Wave3Guide.astro
title: "提醒点开为什么还没跳转？pendingURL、语音保护与已保存来源"
description: "核Hermes提醒URL门、未填录文/笔记阻塞、当前或已保存origin及connected后消费；不添加新服务器，不保证登录/会话或服务完成。"
lang: zh
---

<h2 id="first-answer">点击提醒只产生待处理链接，不等目标会话已经可用</h2>

Hermes提醒先经既有HTTPS/host解析门并设置pendingURL。界面路由还核笔记、语音取消/交接/待填文字等条件；当前源要connected后才消费，其他源只允许已保存origin，未知源会丢弃而不新建服务器。点开不证明登录、会话存在或业务动作成功，也不代表自带通用推送服务。

## 与通知载荷、Watch打开和origin准入的区别

载荷核字段，Watch核另一条消息/本地任务路由，origin核来源边界；这里核**提醒tap到既有网页工作台的待定导航**。不点击真实通知、不注册服务或修改来源。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 解析入口 | isHermesSessionURL既有HTTPS/host门 | 解析范围非所有Agent兼容 | 任意通知URL都可开 |
| pendingURL | 单一待处理链接，消费后清 | 当前槽非完整点击历史 | 可靠全量审计队列 |
| 已有录文 | canCancel/delivering/canRetryDelivery等阻塞 | 录文和导航分账 | 提醒可挤掉未填文字 |
| 笔记/切换门 | notesPresented/onWillSaveConnection等 | 原UI保护仍在 | 点开就覆盖原材料 |
| 当前源 | isConnected后consumePendingURL | 本机加载条件非业务健康 | 登录/会话/服务已验证 |
| 其他源 | recentOrigins中才切换 | 用户已有来源 | 通知自动添加新服务器 |
| 未知源 | 消费丢弃而非创建 | 未知目标另核 | 放宽可信来源就解决一切 |
| 真正结果 | 导航/登录/会话/写入各核 | 不同入口不要互抄全部guard | 点击即已提交或审批 |

</div>

## 合成提醒记录

只有pendingURL时，记录待处理导航，不写“会话已打开”。已有未填录文可能阻塞，不能为了跳转自动丢弃原材料；未知来源不会因此变成可用服务。

来源门和connected都不证明目标账户或业务成功。本文无推送服务、消息送达、设备或视觉实测，不把原生客户端声明为托管Agent/推送平台。

## FAQ

<h3 id="faq-1">点击提醒等于目标会话已打开吗？</h3>

不是，待处理链接、界面保护与实际导航分开。

<h3 id="faq-2">所有通知URL都会被接受吗？</h3>

不是，先有特定解析门，再核当前/已保存来源和具体条件。

<h3 id="faq-3">未保存的服务器会自动加入吗？</h3>

这条路由不这样做，未知来源会丢弃而非新建。

<h3 id="faq-4">connected是不是已登录且会话存在？</h3>

不能由本机连接状态独立推出，目标服务另核。

<h3 id="faq-5">提醒能覆盖未交接的录文吗？</h3>

不能据点击越过现有语音/笔记/切换保护，待定材料需保留复核。

<h3 id="faq-6">本文启用推送或打开了真实链接吗？</h3>

没有，只核既有提醒入口/路由，不注册或授权第三方服务。

## 相关指南与源码

[通知载荷](/guides/notification-payload-model-preflight/) · [Watch另一条路由](/guides/watch-open-request-ui-boundaries/) · [origin边界](/guides/workbench-origin-page-boundaries/) · [待定材料](/guides/degraded-handoff-go-no-go/) · [开始](/start/) · [隐私](/privacy/)

[提醒解析/pendingURL](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieHermesPush.swift) · [openPendingHermesURL](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShellApp.swift) · [连接/导航范围](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWebView.swift)
