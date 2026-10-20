---
layout: ../../layouts/Wave3Guide.astro
title: "音频、笔记元数据与转写归档怎样对应？进度不等于逐字真实性"
description: "区分audio.caf、note.json、transcript与transcribedFrames，以及只交接文字的范围；处理完成不证明每词准确，不新增音文强制对齐或原件备份。"
lang: zh
---

<h2 id="first-answer">文字、音频与元数据是不同材料，交接文字不代表音频也已分享</h2>

现有笔记按同一id管理audio.caf与note.json，转写从transcribedFrames继续并累积transcript。处理到done不等于每个词都已核对；emptyTranscript分支可以推进帧进度却不增加文字。交给工作台的路径分享转写文字，不含录音文件。本页是人工材料对应清单，不新增音文对齐或原件归档服务。

## 与片段审校和版本材料归档的区别

片段审校核听到什么，变更归档核评审前后材料；这里核**本地音频、元数据、处理进度和对外交接文字是否被误当同一份证据**。不访问沙盒、不导出实际文件、不建立新索引或备份。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| note id | 同一笔记材料定位关系 | 实际原件与版本 | 同名文件就同一记录 |
| audio.caf | 本地采集文件 | 实际可读范围/状态 | 显示文字证明音频完整 |
| note.json | 元数据/状态/转写等 | 原始状态与人工副本 | 不可篡改审计证书 |
| transcribedFrames | 16k帧处理位置 | 处理覆盖与原内容另核 | 字级时间对齐或逐词准确率 |
| emptyTranscript | 可跳过文字但仍推进位置 | 实际内容是否需回查 | 原音频一定无业务内容 |
| done | 这次转写流程完成 | 原文、未知和错误范围 | 真实性/语义完整自动验收 |
| 文字交接 | 短文本或长Markdown | 实际交出的文字与附件 | 默认分享audio.caf或所有原件 |
| 本地保留 | 源码尝试排除笔记备份 | 实际权限、保留规则/其他副本 | 永久备份、灾后恢复或一键原件归档 |

</div>

## 合成材料对应

笔记甲的元数据为done，正文只有一段文字；不能仅凭done宣布整段音频逐词已核，也不能因托盘有Markdown就标记音频已移交。先核真正材料与范围。

人工可保留原引用、实际文字版本、已核内容与未知，但不要把内部字段当可手改的导入/恢复API。修改副本不改变真实源材料，处理进度不是内容真实性证明；一次交接标记也不因另建档案取消。

## FAQ

<h3 id="faq-1">100%或done是否证明每词正确？</h3>

不是。它反映处理流程，不代替听核、语义与原文验收。

<h3 id="faq-2">emptyTranscript是否一定说明原音频只有静音？</h3>

不能由该分支独立证明。实现可略过文字并推进进度，真实内容另核。

<h3 id="faq-3">transcribedFrames是每个词的时间戳吗？</h3>

不是。它是16k帧处理位置，不提供字级强制对齐功能。

<h3 id="faq-4">交接长Markdown是否连音频一起上传？</h3>

引用路径交接文字，不含录音文件；不能从文字附件推原件分享。

<h3 id="faq-5">note.json是不可篡改证据吗？</h3>

本文不声明签名或不可篡改机制，元数据与可信/真实性不同。

<h3 id="faq-6">本地有音频是否等于永久备份？</h3>

不是。源码尝试排除备份且不提供本页新增的恢复保证，按实际保留规则核。

## 相关指南与源码

[片段审校](/guides/recording-segment-review-labels/) · [文字附件格式](/guides/export-encoding-delimiter-preflight/) · [材料归档链](/guides/batch-change-record-retention/) · [逐项分享范围](/guides/share-batch-item-preflight/) · [开始](/start/) · [隐私](/privacy/)

[元数据与一次标记](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNote.swift) · [音频/帧进度/文字交接](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift) · [仅分享文字说明](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotesView.swift)
