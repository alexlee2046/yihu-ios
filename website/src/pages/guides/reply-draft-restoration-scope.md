---
layout: ../../layouts/Wave3Guide.astro
title: "恢复的回复草稿属于谁？submitted、原目标与来源绑定核对"
description: "区分提交前草稿、旧待核记录与当前选择；恢复文本不证明已提交/可发送，不新增云同步或后台自动接力。"
lang: zh
---

<h2 id="first-answer">恢复文字不是提交回执，也可能仍属于先前目标</h2>

原生回复会按工作台读取本地记录，核保存来源后恢复text、target、requestID。submitted明确false视为提交前草稿；缺失等情况保守按待核处理。恢复的目标可与当前选择不同，prepare会提示先处理原草稿。文本出现不代表服务器已收到，也不代表新目标获授权。

## 与待核回执和材料归档的分工

回执指南核已尝试提交的结果，材料归档核评审引用；这里核**提交前本地草稿怎样恢复，以及它与当前选择/来源的关系**。不编辑或删除实际文件，不新增云草稿、同步或后台代发。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 读取本地记录 | 有大小/解码/来源URL条件 | 读取失败与原材料保留 | 静默丢坏文件再发送 |
| 来源匹配 | saved.source须匹配当前来源 | 真实来源和现有状态 | 同名工作台就是同源 |
| 恢复字段 | text/target/requestID一起看 | 草稿原目标与当前选择 | 文字显示就属于当前点开的任务 |
| submitted=false | 提交前草稿分支 | 实际持久结果与当前许可 | 服务器已记录或自动批准 |
| submitted缺失/不明 | 恢复按待核处理 | 先沿查回流程 | 当作绝对未提交安全重发 |
| prepare | 重新读目标并提示变化 | 最新状态/next与原目标 | 本地旧版本永远有效 |
| 无法读取 | blocked并保留原记录 | 原错误和维护流程 | 改名/删标记绕过待核 |
| 人工归档 | 草稿/提交/回执分账 | 最小获准材料与版本 | 永久档案、云同步或接力执行 |

</div>

## 合成恢复核对

当前选中样例任务乙，但恢复草稿targetID为先前任务甲。不能把甲的文字当乙的批准或直接更改归属；先核原草稿与最新目标。submitted未知也不能自动填false。

草稿保存成功仍是本地阶段，保存失败提示保留当前页面输入也不是备份保证。原canSend、来源/目标、4000 Unicode标量等条件仍适用；本文不给改内部字段绕过检查的方法。

## FAQ

<h3 id="faq-1">恢复出文字说明已经发给服务了吗？</h3>

不说明。草稿、submitted待核与recorded是不同状态。

<h3 id="faq-2">草稿必定属于当前点击的任务吗？</h3>

不必，恢复可指向先前条目，需核target与提示。

<h3 id="faq-3">submitted缺失是否按false理解？</h3>

当前恢复采取保守待核，而非绝对未提交，不据此盲发。

<h3 id="faq-4">来源变更后能自动带草稿过去吗？</h3>

不能这样推断。读取核来源，异常会阻塞并保留原记录。

<h3 id="faq-5">本地草稿算永久云备份吗？</h3>

不是。没有新增云同步/永久保留或恢复SLA。

<h3 id="faq-6">可以改内部文件来解锁发送吗？</h3>

不应绕过守卫或伪造状态。沿真实来源/目标及既有维护流程核。

## 相关指南与源码

[待核与回执](/guides/reply-request-receipt-mapping/) · [材料归档](/guides/batch-change-record-retention/) · [目标与上下文](/guides/follow-up-context-preflight/) · [开始](/start/) · [隐私](/privacy/)

[初始化恢复/prepare/preserveDraft/canSend](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift) · [PendingReply字段](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift)
