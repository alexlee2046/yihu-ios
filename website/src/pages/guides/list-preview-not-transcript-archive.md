---
layout: ../../layouts/Wave3Guide.astro
title: "列表只显示40字或两行代表什么？预览、正文与分享范围核对"
description: "区分text displayName前40 Character和SwiftUI两行布局；短显示不等原文截短、语义摘要或脱敏，分享仍按实际字段核。"
lang: zh
---

<h2 id="first-answer">看到短预览，不等保存或交接的内容也只有这么短</h2>

共享文字的displayName返回前40个Swift Character，而URL/文件名走其他分支；笔记done行用完整transcript的Text配lineLimit(2)限制布局。一个是派生前缀，一个是显示行数，都不是自动纪要、隐私脱敏或原文已截短的证明。分享应核真正text/transcript，不凭列表截图认定范围。

## 与空字段占位、摘要溯源和音文对应的区别

占位核缺项显示，溯源核人工摘要句子，音文核文件关系；这里核**列表预览怎样派生、它与真实存储/交接材料的差别**。不读取用户记录或导出真实正文。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 共享text预览 | displayName取prefix(40) | 单位是Swift Character | 40 token/字节或全文 |
| URL/文件分支 | 返回text或fileName等 | 不能套同一个40限制 | 所有附件名都仅有40字符 |
| 笔记done行 | Text(transcript).lineLimit(2) | 布局和源字符串分开 | 原文固定截成两行保存 |
| 其他笔记状态 | pending/failed等显示不同 | 旧字段/实际状态另核 | 卡片没正文就是正文丢了 |
| 交接字段 | 共享路径使用实际text等 | 实际内容/附件/权限 | 只会交出屏幕看见部分 |
| 语义 | 前缀/行限制非总结 | 原文与编辑稿分开 | 系统已抽出会议要点 |
| 敏感内容 | 短显示仍可能含识别信息 | 全文/复制/目的地分别核 | 省略号等于脱敏或匿名 |
| 归档证据 | 截图只说明显示范围 | 授权原引用与完整材料 | 预览就是全量/真实性凭证 |

</div>

## 合成预览核对

一份合成记录远长于40 Character，列表只显示开头；不能报告只保存了开头，或用这个截图证明后面的敏感内容不会被分享。两行显示位置也受布局影响，不等固定字数合同。

需要归档时在既有权限内核真实字段与版本，不为查全文扩张私有来源访问。本文未做屏幕/读屏/复制或实际交接测试，不把任何视图当全量档案和隐私保证。

## FAQ

<h3 id="faq-1">prefix40说明原text被改短了吗？</h3>

不能由派生displayName推原字段被修改，实际存储/交接另核。

<h3 id="faq-2">lineLimit2是否保存两行正文？</h3>

不是，它限制布局，不在此把transcript截为两行。

<h3 id="faq-3">URL和文件名也都按40截吗？</h3>

不能推广，源码有不同kind分支，视觉布局又是另一层。

<h3 id="faq-4">failed列表无正文说明旧文字被清空吗？</h3>

不说明，状态分支显示与真实transcript分开。

<h3 id="faq-5">短预览就是自动摘要/脱敏吗？</h3>

不是，前缀与行限制不是语义总结或内容清洗。

<h3 id="faq-6">本页导出或查看了完整用户记录吗？</h3>

没有。只核静态显示/数据路径，不作真实显示或分享验收。

## 相关指南与源码

[显示占位](/guides/empty-field-display-defaults/) · [摘要溯源](/guides/radar-summary-claim-provenance/) · [音文材料](/guides/note-audio-text-evidence-mapping/) · [逐项分享范围](/guides/share-batch-item-preflight/) · [开始](/start/) · [隐私](/privacy/)

[displayName分支](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/CollieShareInbox.swift) · [状态行与lineLimit](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotesView.swift) · [实际text放置](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShareTray.swift)
