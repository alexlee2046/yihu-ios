---
layout: ../../layouts/Wave3Guide.astro
title: "本地文件保护能证明什么？atomic、备份排除与不同载体分账"
description: "按路径核本地写入选项；atomic不等端到端加密、排除备份不等全无副本，未显式选项不代表明文，不新增安全或恢复认证。"
lang: zh
---

<h2 id="first-answer">本地写选项不能替代传输、远端、备份与保留规则</h2>

源码不同路径使用不同文件选项：部分iOS缓存/待核/临时图片写入带completeFileProtection，收件箱manifest和笔记元数据有atomic写入；部分目录设置备份排除。必须按实际路径核，不能把单个选项扩展为端到端加密、全部文件统一保护或所有副本消失。

## 与脱敏、删除与材料归档的分工

脱敏核内容层，删除核移除范围，归档核证据对应；这里核**存储选项到底覆盖哪些载体、哪些结论还需实际属性与系统条件**。不读取私有文件、不改属性、不备份或恢复数据。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| atomic | 用于写入替换的一致性选项 | 具体文件与失败结果 | 加密/签名/整个目录事务 |
| iOS缓存/待核 | 引用路径有completeFileProtection | 实际文件/系统条件 | 所有平台/文件同一保护 |
| 临时图片 | 明确暂存JPEG路径有保护写入 | 暂存文件与后续副本分开 | 所有分享文件自动加同类选项 |
| manifest/笔记元数据 | 某些写出只显式atomic | 默认/继承属性另核 | 未显式选项就证明明文 |
| 备份排除 | 按目录设置，错误处理不同 | 设置是否成功及其他副本 | 完全没有备份或永不留存 |
| 传输/远端 | 本地选项不覆盖服务端 | 实际网络/目标与权限 | 端到端加密或远端已擦除 |
| 平台分支 | iOS与测试平台写选项不同 | 条件编译与实际运行环境 | 代码有macOS分支就有Mac发行 |
| 安全/保留结论 | 需实际范围和规则 | 内容脱敏/副本/权限独立 | 隐私认证、永久备份或恢复SLA |

</div>

## 合成保护核对

已知：样例路径的写调用显式带completeFileProtection；未证：其他副本属性与目的地保留。只能报告该调用选项，不能宣布整个材料包已端到端加密或不可恢复删除。

没有显式保护选项也不能直接宣布明文，默认/继承属性需在获准测试中核。本文不运行安全审计或解锁设备，不从atomic或排除备份推出业务证据可信与合规。

## FAQ

<h3 id="faq-1">atomic是不是加密？</h3>

不是本文所称加密/签名，它不能独自证明内容保密或身份。

<h3 id="faq-2">一个路径有completeFileProtection能覆盖全部附件吗？</h3>

不能。按写出路径和后续副本分别核，不概括所有文件。

<h3 id="faq-3">仅写atomic就一定明文吗？</h3>

不能这样推断，默认/继承属性及实际系统条件另核。

<h3 id="faq-4">备份排除能保证所有副本都不存在吗？</h3>

不能。设置成功、其他备份/远端/人工副本是不同范围。

<h3 id="faq-5">macOS条件分支代表Mac App上线吗？</h3>

不代表。测试/条件编译不证明发行、商店或生产能力。

<h3 id="faq-6">本页能当隐私或恢复认证吗？</h3>

不能。没有新增认证/备份/恢复服务，实际权限与保留依据仍需核。

## 相关指南与源码

[内容脱敏](/guides/carrier-redaction-archive-matrix/) · [删除范围](/guides/note-removal-retention-boundaries/) · [材料归档](/guides/batch-change-record-retention/) · [开始](/start/) · [隐私](/privacy/)

[待核写入与目录属性](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift) · [缓存/草稿平台写选项](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarStore.swift) · [笔记写入与备份排除](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift) · [临时图片](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieDiagnosticImage.swift) · [manifest写入](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/CollieShareInbox.swift)
