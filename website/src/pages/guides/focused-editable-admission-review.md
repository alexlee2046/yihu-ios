---
layout: ../../layouts/Wave3Guide.astro
title: "焦点框为什么不能接收录文？DOM可编辑、可用与草稿准入"
description: "核受守卫DOM的元素类型、连接/禁用/只读例外与已知Collie草稿条件；焦点非授权或通用表单支持，不操作网页。"
lang: zh
indexable: false
---

<h2 id="first-answer">有焦点只是一项条件，不是任意输入框都能接收原生文字</h2>

现有DOM适配关注textarea、指定text类input和contenteditable，并进一步核连接、禁用、只读/键盘策略例外、inert/aria状态及可见性。已知Collie结构还须证明单一草稿模式。不是看到框或placeholder就自动识别所有表单，未知布局也不应被假定兼容。

## 与origin、桥回执和键盘的区别

origin核边界，桥回执核分支，键盘核输入会话；这里核**DOM候选本身是否满足适配条件**。不点击、注入或改属性，不测试真实页面。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 类型 | textarea、指定text/search/url/email等input、contenteditable | 实际元素类型 | 所有password/number/按钮都支持 |
| 焦点跟踪 | focusin/composedPath记录最后目标 | 可观测目标与当前页 | 任意闭合shadow/iframe自动可达 |
| 脚本范围 | forMainFrameOnly主框架 | 主文档与其他frame分开 | 所有跨域iframe支持 |
| usable | 连接、未disabled/无inert/aria-busy等 | 真实状态 | 有节点就可写 |
| readOnly | 普通限制，键盘策略canInsert可有例外 | 按原策略核，不一概而论 | 改属性可绕锁或所有只读绝对相同 |
| 可见检查 | clientRects/visibility等 | 代码条件非完整视觉验收 | 一定在视口可点/安全 |
| Collie结构 | 已知字段/控件须满足草稿条件 | 单一目标与状态 | 结构匹配就账户/审批通过 |
| 最终结果 | 框架可接受或拒正常编辑 | 实际回执和值 | 候选通过就已发送 |

</div>

## 合成DOM核查

一个已聚焦input若类型为password，不是这组text类型候选；一个普通textarea也仍须通过可用/草稿条件。不能把“看见输入框”当成功，也不通过解除disabled/aria-busy等绕过原界面。

原生仅在已允许范围尝试正常编辑，未知框架不保证兼容。本文不把主框架、shadow事件路径或isSafeDraft当完整安全/身份认证，也没有新通用表单自动化。

## FAQ

<h3 id="faq-1">焦点在框里就必能插入吗？</h3>

不能，还核类型、可用状态、页面和具体适配条件。

<h3 id="faq-2">所有只读框都绝对相同吗？</h3>

不能概括，源码允许App键盘策略明确认可的例外，不据此绕过其他只读。

<h3 id="faq-3">所有iframe或shadow都支持吗？</h3>

没有这种保证，脚本主框架范围与可观测事件目标要分开。

<h3 id="faq-4">placeholder能证明是正确任务草稿吗？</h3>

不能，结构与状态及原目标条件另核，不靠显示文字认身份。

<h3 id="faq-5">已知Collie标记出现就自动放宽吗？</h3>

不是，已知结构要求证明草稿条件，不借通用框假设绕门。

<h3 id="faq-6">本文实际改过网页属性吗？</h3>

没有，只核固定适配源码，不作页面/框架兼容认证。

## 相关指南与源码

[页面边界](/guides/workbench-origin-page-boundaries/) · [桥回执](/guides/host-bridge-outcome-boundaries/) · [键盘确认](/guides/keyboard-acknowledgement-scope/) · [开始](/start/) · [隐私](/privacy/)

[editable/usable/isSafeDraft/主框架](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieTextInsertion.swift) · [原生插入条件](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWebView.swift)
