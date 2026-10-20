---
layout: ../../layouts/Wave3Guide.astro
title: "键盘开关亮了就就绪吗？本地状态、异步回执与页面焦点核对"
description: "核setKeyboardEnabled乐观状态、keyboardRequest顺序与Bool回执；显示/DOM焦点非所有输入兼容或草稿送达，不执行网页操作。"
lang: zh
---

<h2 id="first-answer">本地enabled/visible不等网页已确认，更不等文字已填入</h2>

setKeyboardEnabled先更新本地keyboardEnabled/keyboardVisible，再等enqueueKeyboard的脚本Bool回执，并用keyboardRequest排除旧结果。失败可回退显示并提示进入会话。dismissKeyboard发起UIKit结束编辑并排队禁用页面；本地隐藏不独立证明网页立即确认，也不代表草稿保存或发送。

## 与origin、页面桥及音频忙态的区别

origin核边界，桥回执核文字插入分支，音频忙态核资源；这里核**键盘状态是意图、页面确认还是实际输入会话**。不启用键盘、输入文字或修改网页。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 乐观状态 | 先设enabled/visible | 调用阶段与最终结果 | true就是已成功弹出 |
| 脚本回执 | 返回Bool true才视为接纳 | 页面实际条件和错误 | 所有输入框都支持 |
| keyboardRequest | 新请求使旧UI结果不适用 | 本地顺序与请求归属 | 账户/服务request_id |
| 串行任务 | 等待前一键盘任务再核当前请求 | 已派发和待派发区别 | 旧事件从未执行 |
| 原生焦点 | 启用时尝试becomeFirstResponder | 原生/DOM/实机显示分开 | DOM focus保证物理键盘出现 |
| 隐藏路径 | 清本地状态、endEditing、排队disable | UI意图与页面确认分开 | 网页已立即完成所有变更 |
| 页面守卫 | 当前webView与isTrusted仍核 | 真实页面/输入槽 | 同名会话就可输入 |
| 后续交接 | 文字/草稿/回执另核 | 实际内容与权限 | 键盘状态证明已发送 |

</div>

## 合成键盘时序

刚请求启用时本地字段为true，但脚本尚未回报。只能报告请求中，不称网页已就绪。若随后发出禁用，较早enable的返回也不能替新请求更新UI结论。

键盘行为需要实际设备/输入环境证据，本页未测试。源码避免忙网页阻塞原生隐藏/麦克风准备的设计意图不构成零延迟或所有网页兼容保证，不靠改本地Bool绕过页面条件。

## FAQ

<h3 id="faq-1">开关true就证明键盘实际出现吗？</h3>

不能，先有乐观状态、后有回执，物理设备输入环境另核。

<h3 id="faq-2">Bool回执能证明文字已填入吗？</h3>

不能，它属于键盘设置，不是转写插入/发送回执。

<h3 id="faq-3">keyboardRequest是服务端请求ID吗？</h3>

不是，是本地键盘请求顺序，不授身份或写权。

<h3 id="faq-4">隐藏后网页一定同时完成禁用吗？</h3>

不能独立推断，页面操作排队执行，本地显示与异步结果分开。

<h3 id="faq-5">DOM focus是否保证实机软键盘？</h3>

不保证，原生输入会话及实际设备条件仍要验证。

<h3 id="faq-6">本页是否点了键盘或输入真实数据？</h3>

没有，只核固定源码，不做浏览器/设备验收。

## 相关指南与源码

[页面与origin](/guides/workbench-origin-page-boundaries/) · [文字桥回执](/guides/host-bridge-outcome-boundaries/) · [忙态区别](/guides/audio-busy-state-admission/) · [开始](/start/) · [隐私](/privacy/)

[setKeyboardEnabled/enqueueKeyboard/dismissKeyboard](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWebView.swift) · [页面键盘策略](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieKeyboardPolicy.swift)
