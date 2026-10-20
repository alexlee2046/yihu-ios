---
layout: ../../layouts/Wave3Guide.astro
title: "关闭历史是否撤回提交？迟到历史、generation与已记录回执优先级"
description: "核历史读取代际与recorded后失效旧读取；关闭只读视图不等取消写入，旧响应不是新证据，不新增回执或归档服务。"
lang: zh
---

<h2 id="first-answer">关闭历史回显不撤回提交，先发出的历史也不能抢走已确认回执</h2>

历史读取捕获historyGeneration，返回后还核historyActive、当前来源、generation和任务取消。cancelHistory更新本地活动/代际；写回复complete也使旧历史代际失效，避免预提交读取抢在已确认回执后生效。它不是服务器撤回，不能把迟到/被忽略的历史当最新absent或业务状态。

## 与历史检索、引用结构和请求ID的区别

检索核覆盖，结构核目标/引用，请求ID核写入关联；这里核**异步历史查询与确认写回执的时序优先级**。不发送/取消真实网络请求，不清本地记录或操作旧回复。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 本地代际 | 每次读取捕获generation | 查询生命周期 | 服务器版本/request_id |
| 返回守卫 | active/currentSource/代际/取消条件 | 这次响应是否仍适用 | 网络有响应就最新 |
| cancelHistory | 标非活动、递增代际、清本地busy | 视图状态与提交状态分开 | 撤销已发POST或服务写入 |
| 旧读取defer | 只在同代际清busy | 新读取忙态不被旧回包接管 | 全局网络请求已取消 |
| complete | 使先前历史读失效，recorded=true | 确认回执与新查历史分账 | 业务已处理/审批通过 |
| 迟到响应 | 不满足守卫不应用 | 原响应范围与未知 | 自动判absent可重发 |
| 读失败/无历史 | 按实际错误/原结果核 | 未显示不等没写入 | 记录从未存在 |
| 人工归档 | 保留读取/提交/回执各自范围 | 真实关联与实际时间 | 本地代际成永久审计证书 |

</div>

## 合成竞序核对

历史查询甲先发出，随后写回复已有recorded回执；甲后来返回。不能把甲当确认之后的最新全貌或据它重发。源码通过代际守卫保护时序，真实结果仍要按请求与原条目核。

关闭历史不意味着底层网络一定没发生或服务副作用被撤销；generation也不是账户凭据、来源epoch或持久日志。本文无并发回归/服务端测试，不承诺所有系统下零竞态。

## FAQ

<h3 id="faq-1">关历史能撤回已提交回复吗？</h3>

不能。只读视图状态与写操作/服务结果不同。

<h3 id="faq-2">historyGeneration就是request_id吗？</h3>

不是，一个是本地读取代际，一个关联真实写请求。

<h3 id="faq-3">旧响应最后到达就最新吗？</h3>

不是，须看发起范围、代际和实际事件顺序，不以到达顺序判真。

<h3 id="faq-4">recorded后还可用旧查询宣告absent吗？</h3>

不应，旧读取失效不能推翻确认，也不能由未显示自动授权重发。

<h3 id="faq-5">cancelHistory保证杀掉全部网络吗？</h3>

本文不作此保证，源码主要更新本地状态/代际，是否已发请求与副作用另核。

<h3 id="faq-6">这些守卫能当永久档案或零竞态证书吗？</h3>

不能。固定本地逻辑不代真实服务、并发或归档验收。

## 相关指南与源码

[历史检索](/guides/history-retrieval-manual-comparison/) · [引用结构](/guides/history-reference-integrity-review/) · [请求与回执](/guides/reply-request-receipt-mapping/) · [开始](/start/) · [隐私](/privacy/)

[cancelHistory/loadHistory/complete](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift)
