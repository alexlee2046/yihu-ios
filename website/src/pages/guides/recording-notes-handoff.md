---
layout: ../../layouts/Wave3Guide.astro
title: "把录音整理成行动项：原文、结论与下一步放在一起"
description: "从iPhone录音笔记到可跟进的结构化待办，展示一份合成会后笔记，并比较纯转写与行动项工作流。"
lang: zh
preview: voice
voiceSample: meeting
---

<h2 id="first-answer">先找到一个有用的下一步</h2>

先保留原录音与转写，再把材料交给你选择的工作台或工具整理。把“已确认的事”“要跟进的事”“还要问的问题”分开，下一次打开手机就知道先做什么。

## 一份会后笔记，可以更容易接着做

以下为合成示例，不含真实会议或客户资料：

<div role="region" aria-label="从录文到行动项" tabindex="0">

| 材料 | 示例 | 如何使用 |
|---|---|---|
| 原录文 | “规格资料还不齐，先确认报价需要哪些参数，交期等核过再回复。” | 保留原话，回来检查数字和条件。 |
| 结论 | 报价前先补齐规格资料。 | 与原文核对后再使用。 |
| 待办 | 列出缺失参数，交给对应同事确认。 | 负责人和时间未提供时写“待确认”。 |
| 待确认项 | 交期、最终报价范围。 | 资料齐后再答复，不从摘要补出承诺。 |

</div>

<h2 id="compare">转文字工具，还是录文→行动项工作流？</h2>

<div role="region" aria-label="录音笔记工具选型" tabindex="0">

| 你的任务 | 更合适的起点 | 需要多做的一步 |
|---|---|---|
| 只要保存录音并得到文字 | 独立录音/转录工具 | 核对文字、存储与分享设置。 |
| 要整理讨论结论和待办 | 原录文加整理工具 | 对照原文确认负责人、时间、提议与结论。 |
| 已有Agent网页工作台，要在手机继续处理 | 一呼录音笔记加你的工作台 | 准备模型与接入条件，选择交接方式并检查结果。 |

</div>

## 用一呼接续

1. 在iPhone录音，保留本地音频和分段转写。
2. 核对人名、数字与前后语境。
3. 选择整理提示及交接目的地；较长文本可通过已有Markdown材料路径带入。
4. 在所选工作台/工具查看整理结果，再决定下一步。

“会议纪要”是整理提示，不是本机已经生成的完整纪要。开始前请征得参与者所需的录音同意，并准备语音模型和自己的工作台。

## FAQ

<h3 id="faq-tool">只有转写需求，需要配置工作台吗？</h3>

独立录音或转录工具可能更省步骤；一呼更适合本来就有网页Agent工作台、想继续整理和跟进的人。

<h3 id="faq-action">负责人和截止时间能自动补出来吗？</h3>

先以原文为准，缺的标待确认。整理工具生成的结果仍应核对，尤其报价、交期和对外承诺。

<h3 id="faq-material">交接的是录音还是文字？</h3>

现有笔记交接使用文字或Markdown全文材料。音频与文字在本地保留，按你选择的出口分别检查交接内容。

<h3 id="faq-original">整理后为什么还留原文？</h3>

方便发现识别差异、回看上下文，并区分讨论提议与真正结论。

## 接着看

[语音草稿](/guides/iphone-agent-voice-drafts/) · [音频排障](/guides/bluetooth-audio-input-troubleshooting/) · [录音笔记](/guides/recording-notes-handoff/) · [每日简报](/guides/multi-project-radar-watch/) · [接入条件](/start/) · [隐私](/privacy/)

<details><summary>实现参考</summary>

[冻结实现](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift) · [README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)

</details>
