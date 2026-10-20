---
layout: ../../layouts/Wave3Guide.astro
title: "点重试会从头转写吗？已有文字、transcribedFrames与pending核对"
description: "按retry/load/transcribe核保留文字与帧断点；pending不是恢复成功，重试不等重录、自动去重或云端续传，不修改真实笔记。"
lang: zh
---

<h2 id="first-answer">retry保留原字段并排队，不是自动清空全文从头识别</h2>

笔记retry把传入笔记状态设pending、清failure后保存，未在此清空transcript或transcribedFrames。转写读取音频时从已记帧位置继续并拼接后续结果；加载时遗留recording/transcribing也可转pending。状态重置不是完整恢复或逐词准确率验收，更不是自动重新录制。

## 与重录前检、音文映射和拼接的区别

重录核缺口是否需新采集，映射核材料对应，join核边界规则；这里核**重试动作保留哪些旧结果、从什么位置继续**。不点实际重试、不改内部帧位、不执行模型或文件恢复。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| retry | 设pending并清failure | 保留的原笔记字段 | 全文被清空/开始新录音 |
| 已有文字 | transcript仍在 | 旧结果和后续新增分开 | 全部都由这次重试新生成 |
| 已记帧位 | 从transcribedFrames读取 | 记录断点与实际音频 | 每词已对齐/完整性已证 |
| 加载遗留状态 | recording/transcribing转pending | 排队与实际成功分开 | 崩溃后所有缓冲已恢复 |
| worker | 处理pending且检查canTranscribe | 前台/忙态与实际结果 | 点击后立即或后台必完成 |
| 空转写分支 | 可推进帧而不加文字 | 真实内容仍需听核 | 没有遗漏业务话语 |
| 保存/失败 | 实际错误与持久结果另核 | 内存/磁盘/版本范围 | 无损或永久恢复SLA |
| 交接标记 | 重试不在此清handOffAttempted | 旧尝试与权限保留 | 再转写就允许重复交接 |

</div>

## 合成续点记录

样例笔记已有甲段文字、记录了帧位置N，状态failed。retry仅把它排为pending；后续按记录的N继续，不把甲段称为新录文，也不凭pending宣布恢复成功。

实际音频、最近保存与调用对象是否一致仍需证据，不能用手改transcribedFrames来隐藏缺口。新录制应另标版本，原一次交接与不确定停止不因重试取消。

## FAQ

<h3 id="faq-1">retry一定从0开始吗？</h3>

当前方法没有清帧位/文字，转写按已记位置继续，不可概括为从头重跑。

<h3 id="faq-2">pending等于成功恢复吗？</h3>

不是，只是待处理状态，实际文件/模型/权限和错误仍需核。

<h3 id="faq-3">旧文字是否全算新一次输出？</h3>

不能，已有transcript与新增片段须分开说明。

<h3 id="faq-4">空片段推进位置说明没有业务内容吗？</h3>

不能独立证明，原音频与语义另核。

<h3 id="faq-5">转写重试是否自动清交接标记？</h3>

不会由该方法提供，不把重试当重发授权。

<h3 id="faq-6">本文执行了重试或模型吗？</h3>

没有，只核源码；不提供无损恢复、云续传或新录音服务。

## 相关指南与源码

[是否重录](/guides/interruption-recapture-preflight/) · [音文材料](/guides/note-audio-text-evidence-mapping/) · [片段拼接](/guides/note-segment-join-provenance/) · [一次交接](/guides/recording-notes-handoff/) · [开始](/start/) · [隐私](/privacy/)

[retry/load/worker/transcribe](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift) · [帧位与交接字段](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNote.swift)
