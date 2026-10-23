---
layout: ../../layouts/Wave3Guide.astro
title: "外贸每日跟进简报：在iPhone先看询盘、依据与下一步"
description: "把已有询盘与市场资料整理成受支持的JSON事项，在手机上查看优先跟进内容、来源与下一步；含合成示例。"
lang: zh
preview: radar
---

<h2 id="first-answer">先找到一个有用的下一步</h2>

每天打开手机，先看需要你决定或跟进的事项，再核来源和下一步。一呼读取你自己的结构化简报；客户资料与市场信息由你现有的业务工作流准备。

## 三类材料，三种下一步

<div role="region" aria-label="每日外贸简报" tabindex="0">

| 你已有的材料 | 手机简报怎么写 | 下一步 |
|---|---|---|
| 询盘资料不完整 | 规格参数待补，报价范围待确认。 | 列出要问的问题，核对后回复。 |
| 市场资料有变化 | 标明资料来源与更新时间。 | 回看原资料，确认是否影响当前报价。 |
| 昨日跟进未完成 | 写清当前卡点和下一次联系准备。 | 在自己的业务工具中继续处理。 |

</div>

<h2 id="brief-format">一个当前格式的合成简报</h2>

示例只演示结构，不是真实商机或市场情报。下面的任务project与项目path对应；完整数据还包含decisions和active/stale/cold集合。

```json
{"date_str":"2026-10-22 09:00","tasks":[{"id":"sample-inquiry","project":"export-demo","title":"询盘规格待补","status":"等你决策","priority":"P1","next":"确认缺少的规格参数后起草回复","url":"https://example.com/brief","evidence":"合成材料，仅供预览"}],"decisions":[],"active":[{"name":"外贸跟进","path":"export-demo","timestamp":1792630800,"message":"合成示例，非实时资料"}],"stale":[],"cold":[]}
```

把已有资料按受支持格式准备好，再通过兼容来源或文件导出接入。需要登录的数据按既有文件导出路径处理；网页账户登录与简报读取各自准备。

## 与日常业务工具怎么分工

一呼便于在手机查看事项和接续工作台；你现有的邮箱、CRM或业务文档继续负责数据和实际跟进。一呼不自动连接这些账户，也不提供客户数据库或商机采集服务。来源时间不清时先回看原资料。

配对Apple Watch可接收手机摘要，方便提醒你回手机继续查看；关键决定仍在手机和原业务流程中确认。

<h2 id="case-guide">询盘、市场、跟进三种样例，各自准备什么</h2>

预览切换的是业务情境，不是隐藏的处理队列；三种情境都沿用同一套已支持的任务字段。

<div role="region" aria-label="询盘市场跟进资料准备" tabindex="0">

| 情境 | 你提供的材料 | 映射到已有字段 | 使用前核对 |
|---|---|---|---|
| 询盘 | 实际提问与缺少的规格信息。 | title写缺口，next写要问什么，evidence/url放原材料。 | 报价范围和交期确认后再答复。 |
| 市场 | 与当前任务有关、带日期的资料。 | title写待核项目，evidence/url留来源，next写核什么。 | 合成样例不是行情情报或买入信号。 |
| 跟进 | 上次联系记录与未解决的问题。 | title写待办，next写准备动作，project对应项目path。 | 复核后回原业务工具继续，不暗示定时发送。 |

</div>

date_str是快照最后一次成功读取来源的时间，按UTC+08:00使用严格的yyyy-MM-dd HH:mm格式（不含秒），不是询盘或市场文档的日期。读取失败时保留原时间；原资料日期可记在evidence文字里，缺少的事实仍写“待确认”。任务project与已有项目path对应；不新增CRM编号、联系人、商机评分或API字段。三个预设样例用于理解结构，不把顾客资料导入本网页。

## FAQ

<h3 id="faq-source">简报会自动抓取客户询盘吗？</h3>

数据由你的业务工作流提供。一呼读取已准备的结构化来源，不代替邮箱/CRM接入或市场数据服务。

<h3 id="faq-json">一定要自己搭一个后端吗？</h3>

先看现有工作流能否提供兼容JSON或受支持的文件导出；一呼本身是客户端，接入步骤见使用条件。

<h3 id="faq-fresh">手机显示了事项，就代表来源是最新的吗？</h3>

查看来源时间与读取状态。遇到旧资料或读取失败时，先在原业务系统核对再做决定。

<h3 id="faq-send">看完就会自动回复客户吗？</h3>

不会。你先选择和核对下一步；实际回复取决于原业务工具和已配置的工作台能力。

## 接着看

[语音草稿](/guides/iphone-agent-voice-drafts/) · [音频排障](/guides/bluetooth-audio-input-troubleshooting/) · [录音笔记](/guides/recording-notes-handoff/) · [每日简报](/guides/multi-project-radar-watch/) · [接入条件](/start/) · [隐私](/privacy/)

<details><summary>实现参考</summary>

[冻结实现](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift) · [README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)

</details>
