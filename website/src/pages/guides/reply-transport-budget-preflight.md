---
layout: ../../layouts/Wave3Guide.astro
title: "回复超时或响应过大怎样核？传输预算不是服务端未记录证明"
description: "核原生回复20k请求、40k/128KiB响应和不同超时设置；配置值不是服务SLA，传输失败不自动清除待核或允许重发。"
lang: zh
---

<h2 id="first-answer">字节/超时上限是消费者保护，不是业务结果或响应SLA</h2>

原生回复请求体上限为20000字节；非history响应上限40000字节，history为128 KiB，并在流式读取中继续限额。请求/资源超时也按操作分支设置。触及这些边界不证明服务端从未记录，不能把传输异常自动改为安全重发；本页不发请求、不新增API或调参功能。

## 与源URL、请求身份和历史检索的分工

源URL核地址形状，请求身份核request_id与回执，检索核覆盖范围；这里专门核**客户端传输设置为什么可能终止读取、它能证明什么**。实际消息和历史仍受原模型、身份与目标校验。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 请求体 | 最多20000字节，含JSON元数据 | 编码后总量非只数字数 | 20000字符都可交付 |
| 非history响应 | 最多40000字节 | 真实响应/解码结果 | HTTP成功就业务成功 |
| history响应 | 最多128 KiB | 流式计数与原模型校验 | 一次返回全部历史 |
| Content-Length | 已知过大先拒，读流仍限 | 未知/不可信长度下的实际字节 | 没有长度头就无限读 |
| 请求超时 | history 45秒，其他25秒 | 客户端配置和实际错误 | 服务承诺此时限必完成 |
| 资源超时 | history 60秒，其他45秒 | 单独资源预算 | 端到端业务处理SLA |
| 会话/重定向 | 原生Cookie/凭据存储另设，拒自动重定向 | 原来源与实际权限 | 浏览器登录自动成为原生写权 |
| 提交结果不明 | pending/check原路径保留 | 请求身份与真实结果 | 响应读失败就没有副作用 |

</div>

## 合成传输记录

已有：一次提交后读响应超时；未知：原回复是否已记录。结论：保存待核状态，沿check查回，不从客户端超时编造absent，也不改URL或新request_id盲重试。

这里的字节/时间是固定源码配置，不是压测、线上可用性、网络延迟或成本保证；浏览器页面登录与原生请求不应互相推定权限。原source/epoch/版本和确认守卫继续有效。

## FAQ

<h3 id="faq-1">20k请求体是否等于20k中文字符？</h3>

不是。它是JSON编码后字节，元数据也占用，不能直接当字符门槛。

<h3 id="faq-2">响应超过上限是否说明服务未写入？</h3>

不说明。读取失败与服务端结果分开，仍需原请求查回。

<h3 id="faq-3">没有Content-Length就不受限制吗？</h3>

不是。现有读流还有逐字节上限检查。

<h3 id="faq-4">45/60秒是不是保证服务此时完成？</h3>

不是。分别是客户端操作分支配置，不是业务SLA。

<h3 id="faq-5">重定向能自动去另一个网站继续吗？</h3>

该原生路径拒绝自动重定向，不为兼容放宽源与权限边界。

<h3 id="faq-6">本文是否运行接口或负载测试？</h3>

没有。仅核固定源码，不声称真实请求、性能或服务可用性验收。

## 相关指南与源码

[源URL](/guides/radar-feed-url-boundary-preflight/) · [请求与回执](/guides/reply-request-receipt-mapping/) · [历史检索范围](/guides/history-retrieval-manual-comparison/) · [开始](/start/) · [隐私](/privacy/)

[请求/响应限额、超时与拒重定向](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift) · [消费者模型](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift)
