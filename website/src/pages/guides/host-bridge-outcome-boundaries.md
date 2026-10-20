---
layout: ../../layouts/Wave3Guide.astro
title: "桥拒绝与桥不可用能混同吗？accepted/refused/unavailable核对"
description: "按页面桥协议观测与原生分支核回执；仅unavailable可继续受守卫DOM适配，拒绝/异常不盲降级，不新增发送或适配服务。"
lang: zh
---

<h2 id="first-answer">refused不是unavailable，accepted也不是服务端处理回执</h2>

当前页面collieBridgeScript先核origin、完整pageURL与页面可见性，再观测事件detail的读取/accepted设置及preventDefault。结果为accepted/refused/unavailable；原生分支只有明确unavailable才继续受守卫DOM适配，拒绝、异常或其他结果不因此变成安全降级。accepted也只是协议回报，不证明已发送或业务处理。

## 与origin、一次交接和完成审计的区别

origin指南核页面边界，一次交接核原尝试，审计核实际结果；这里核**可选页面桥的三态观测与何时允许走下一适配分支**。不注入事件、不伪造桥或改网页全局。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 前置条件 | origin/pageURL/hidden等检查 | 具体页面与当前相位 | 标题相同就可信 |
| accepted | detail明确设置为true时优先返回 | 宿主回报与实际目标内容 | 服务器收到/执行/审批 |
| observed | 读取text/accepted或设置accepted可被观测 | 是否按约定消费事件 | 全站能力已扫描 |
| refused | 未accepted且observed或defaultPrevented等情况 | 拒绝或不满足边界 | 可当没桥继续绕过 |
| unavailable | 未观察到协议处理的分支 | 仅这个结果可进入后续DOM尝试 | 页面绝对没有任何能力 |
| DOM下一分支 | 仍核allowed和适配器条件 | 焦点/草稿/页面/请求 | 无条件写入或发送 |
| 异常/未知 | 不自动当unavailable | 副作用和未知保留 | 失败就绝无写入可盲重试 |
| 不同回执层 | 隔离世界Bool回执与页面桥分别处理 | 明确哪一层实际返回 | 任意非Bool值都是发送成功 |

</div>

## 合成桥结果记录

结果refused：停止该路径，不把它改写成unavailable去尝试别的输入框。结果accepted：只报告宿主按协议接纳，再核真实目标内容，不填已发送/已执行。这里没有实际网页交接。

这条原生链路没有submit调用，但并不等于任意网站行为都已验收。协议观测不是安全扫描、账户认证或所有后端幂等保证；不以“兼容”为由注册假桥或改锁定/发送状态。

## FAQ

<h3 id="faq-1">refused可以当没有桥吗？</h3>

不能。原生分支不因拒绝继续DOM降级。

<h3 id="faq-2">unavailable证明整个站点没有适配能力吗？</h3>

不证明，只说明本协议观测路径的结果，后续尝试仍受守卫。

<h3 id="faq-3">accepted说明业务已处理吗？</h3>

不说明。宿主接纳、实际填入、发送、接收、业务完成分别核。

<h3 id="faq-4">preventDefault一定压过accepted吗？</h3>

不是这么概括，源码accepted=true优先；未accepted时取消事件可归refused。

<h3 id="faq-5">异常后能自动换框重发吗？</h3>

不应，保留未知与原请求/目标状态，不盲降级或重放。

<h3 id="faq-6">本文配置或测试了新桥吗？</h3>

没有，只核固定协议分支，不改页面或新增服务。

## 相关指南与源码

[页面与origin](/guides/workbench-origin-page-boundaries/) · [一次交接](/guides/recording-notes-handoff/) · [实际完成证据](/guides/handoff-evidence-audit-checklist/) · [开始](/start/) · [隐私](/privacy/)

[collieBridgeScript三态](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieTextInsertion.swift) · [insertTranscript分支](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWebView.swift)
