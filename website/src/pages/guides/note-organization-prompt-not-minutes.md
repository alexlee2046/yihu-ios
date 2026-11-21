---
layout: ../../layouts/Wave3Guide.astro
title: "选了「会议纪要」就有成稿？先核交接内容｜一呼"
description: "「会议纪要」只是整理指令。先核直接填入、托盘和 Radar 草稿各带什么，再用本地示例练习核对交接文字。"
lang: zh
privacyPreview: true
trialLabel: "先试交接文字核对"
---

<h2 id="first-answer">先看交接要带什么，再判断有没有纪要成稿</h2>

保留转写原文，先确认要走哪个交接入口。直接填入可附整理指令；托盘短文带指令和正文，长文将 Markdown 正文和指令分开；Radar 草稿传的是原转写。Picker 选的是 `instruction`，不重写保存的transcript。只有看到目标端实际产物并对照原文，才能判断纪要是否可用；负责人或日期不明就保持待核。

## 与字段简报、多笔记复核和草稿候选的区别

简报核人工字段，多笔记核材料范围，候选核目标资格；这里核**整理模板是请求还是产物、不同出口究竟带什么文字**。不运行摘要模型或交接真实笔记。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| Picker | 三种现有instructions模板 | UI选择与产物分开 | 已自动生成会议纪要 |
| 原文 | transcript作为材料 | 模板选择不重写原文 | 点击标签就修正识别 |
| 直接填入 | 非空instruction可前置正文 | 实际文本/目标/条件 | 只交原文或已代发送 |
| 托盘短文 | 指令+正文 | 保存材料非目标完成 | 进入托盘就纪要完成 |
| 托盘长文 | UTF-8 Markdown正文，指令说明见附件 | 文本和文件分别核 | 本机转码/批量导入服务 |
| Radar草稿 | 传current.transcript | 不套模板前缀规则 | 三路payload一模一样 |
| 重复防线 | 状态/长度/handOffAttempted等仍在 | 换模板不绕准入 | 可通过改模板无条件重发 |
| 产物验收 | 目标若整理仍需独核原文/未知 | 人名/时间不臆补 | 模板保证准确/完整/批准 |

</div>

## 合成模板记录

只选择“会议纪要”尚无目标结果，应记已选择请求模板而非纪要已完成。若目标仅收到原文Radar草稿，不因Picker标签存在就宣称指令前缀也随行。

最终编辑稿应与原录文、未知和获准范围分账；提示“不要遗漏”不是完整性保证。本文未生成或分享真实内容，不提供新纪要、CSV、转码或审批服务。

## FAQ

<h3 id="faq-1">选会议纪要会修改保存的录文吗？</h3>

这个Picker选instruction，不在此重写transcript。

<h3 id="faq-2">整理任务是本机ASR自动完成吗？</h3>

不能由模板推出，原生这里构造交接提示，不是纪要产物。

<h3 id="faq-3">三条出口带同样文字吗？</h3>

不是，direct/托盘可含指令，Radar草稿传原transcript，长文还有文件材料。

<h3 id="faq-4">长文附件就是转码服务吗？</h3>

不是，这里写UTF-8 Markdown录文材料，不是通用音频/文件转码。

<h3 id="faq-5">模板能保证负责人和时间吗？</h3>

不能，目标结果/原文/未知另核，不能补造姓名或截止时间。

<h3 id="faq-6">本文跑过摘要或实际交接吗？</h3>

没有，只核模板与载荷，不执行真实模型或目的地操作。

## 相关指南与源码

[字段简报](/guides/meeting-notes-brief-fields/) · [多笔记范围](/guides/multi-note-review-handoff/) · [目标候选](/guides/note-radar-draft-candidate-preflight/) · [材料对应](/guides/note-audio-text-evidence-mapping/) · [开始](/start/) · [隐私](/privacy/)

[instructions/三路入口](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotesView.swift) · [短文/Markdown托盘材料](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift)
