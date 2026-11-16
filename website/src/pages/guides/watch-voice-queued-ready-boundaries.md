---
layout: ../../layouts/Wave3Guide.astro
title: "Watch 语音 queued / ready：下一步看哪里？"
description: "先回手机查看原请求、转写结果与草稿，分别核对 queued 接纳与 ready 回报。页面预览无需麦克风或 Watch 配对；查看一呼隐私与 App Store 入口后再决定接入。"
lang: zh
privacyPreview: true
trialLabel: "先试页面草稿示例"
indexable: false
---

<h2 id="first-answer">先回手机核原请求，再分别看结果与草稿</h2>

先在配对手机核对原请求、目标和当前状态。queued 可确认接纳、同请求或缓存复用，仍须查看后续结果；ready 的有界回报不是phone reply草稿或网页插入。缺少下一阶段依据时保留原请求，不换 ID 或目标盲重发。receiveVoice 的接收与新转写仍受目标、前台和忙态条件约束。

## 与跨端显示、PCM和草稿恢复的区别

跨端显示核字段，PCM核形状，草稿恢复核phone待定记录；这里核**Watch语音请求/结果回报阶段及接收门**。不录Watch音频，不运行配对、转写或发送。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 目标指纹 | sourceToken/taskToken与当前目标匹配 | 本地字段指纹非签名 | 账户认证/服务批准 |
| queued | 接纳、同请求或缓存复用确认 | 实际请求/后续结果 | 识别完成/持久后台队列保证 |
| 音频门 | 16k单声道、0<帧数≤176000、有限样本 | 接收格式非任意转码 | 原始文件任意格式可上传 |
| 新转写 | 前台/忙态/模型等门 | 缓存回送和新执行分开 | 永远可后台接力 |
| ready | 再次核目标并校验结果codec/缓存 | 有界回报非phone草稿 | 网页已填/回复已发送 |
| 配对传递 | WCSession即时/后台通道另核队列门 | 原请求结果与实际接收 | 云中继/常驻轮询/必达 |
| 重试 | 原请求一致才复用已知缓存 | 不要改ID/token猜测重发 | 新ID就是原动作续传 |
| 最终交接 | 保存草稿和服务提交另核 | 实际目标/状态/用户确认 | 转写结果已完成业务 |

</div>

## 合成阶段记录

只有queued，没有ready或后续草稿证据，就记接纳阶段待定。即使ready带文字，也不能写手机草稿已保存；接收函数有意不调用web-composer交接回调。

缓存回报不是无限历史或恢复保证，配对后台传递不是云服务。声纹过滤亦非身份授权。本文无Watch/手机/网络实测，不为排错上传真实语音。

## FAQ

<h3 id="faq-1">queued能证明转写完成吗？</h3>

不能，它可表示新接纳、同请求或缓存复用，仍需结果。

<h3 id="faq-2">ready是不是手机回复草稿已保存？</h3>

不是，源码明确有界结果回报不等phone草稿或网页插入。

<h3 id="faq-3">176000帧是不是支持任意文件？</h3>

不是，还需16k单声道、有效长度/有限样本及其他门，采集能力另核。

<h3 id="faq-4">所有请求都必须当场重新转写吗？</h3>

不一定，一致原请求可复用缓存，新转写和回送条件分开。

<h3 id="faq-5">这是云语音中继或必达消息服务吗？</h3>

不是，只核配对通道和本地缓存，不作送达/后台可用性保证。

<h3 id="faq-6">本文实际配对或发送了Watch回复吗？</h3>

没有，只核固定接收/转写/结果路径，不获真实跨端验收。

## 相关指南与源码

[跨端字段](/guides/cross-device-field-presentation/) · [PCM门](/guides/pcm-format-admission-review/) · [phone草稿](/guides/reply-draft-restoration-scope/) · [声纹界限](/guides/voiceprint-filter-not-authorization/) · [开始](/start/) · [隐私](/privacy/)

[receiveVoice/缓存/回送](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWatchPhoneBridge.swift) · [transcribeWatchAudio前台与回调边界](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceController.swift)
