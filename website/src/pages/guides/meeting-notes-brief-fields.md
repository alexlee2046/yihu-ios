---
layout: ../../layouts/Wave3Guide.astro
title: "会议纪要模板：结论、行动项与待确认问题"
description: "把录文整理成能接着做的会后笔记，包含结论、负责人、时间与待确认事项的合成样例。"
lang: zh
---

<h2 id="first-answer">保留原文，把下一步写清楚</h2>

从原录文出发，把结论、行动项和问题分开。没有说清的负责人或时间，先标待确认。你选择的整理工具可以帮忙起草，最后仍对照原文检查。

<div role="region" aria-label="会议纪要模板" tabindex="0">

| 栏目 | 写什么 | 合成示例 |
|---|---|---|
| 结论 | 已确认的事，以及对应原文 | 报价前先补齐规格资料。 |
| 行动项 | 一个具体的下一步 | 列出还缺哪些参数。 |
| 负责人 | 由谁认领 | 待确认。 |
| 时间 | 已约定的截止时间，或待确认 | 待确认。 |
| 待确认问题 | 作出承诺前要补的信息 | 核过交期后再回复。 |

</div>

## 按任务选工具

只需要一份可查录文时，独立转录工具往往已经够用。要继续跟进，就多做一步行动项、负责人和时间核对。已有 Agent 网页工作台的人，可以用一呼把手机上的录音文字接过去。

[比较转文字与行动项工作流](/guides/recording-notes-handoff/#compare)

这是编辑模板，不是App导入格式；要接入Radar JSON时，请使用受支持的简报结构，不把这些栏目当成新API字段。

## FAQ

<h3 id="faq-summary">选了模板就有完整纪要吗？</h3>

它提供整理提示。查看所选工具的结果，并对照原录音确认。

<h3 id="faq-missing">没有负责人或时间怎么办？</h3>

标待确认，再问清楚，不替谈话补出人选或截止时间。

<h3 id="faq-proposal">讨论中的建议放哪里？</h3>

先记作建议或待确认问题，确认后再放进结论。

<h3 id="faq-review">交接前先查什么？</h3>

检查目的地、需要带入的材料，以及是否已有草稿；有不确定结果时，保留原文再核对。

[录音笔记](/guides/recording-notes-handoff/) · [每日简报](/guides/multi-project-radar-watch/) · [接入条件](/start/) · [隐私](/privacy/)

<details><summary>实现参考</summary>

[Voice notes](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift)

</details>
