---
layout: ../../layouts/Wave3Guide.astro
title: "manifest出现后代表什么？本地批次可见点与残留目录核查"
description: "核先复制后写manifest、pending解码及缺manifest旧目录清理；可见不等所有文件已复核或服务提交，3600秒非统一保留期。"
lang: zh
---

<h2 id="first-answer">manifest是本地批次可见条件，不是服务回执或不可变归档</h2>

共享收件箱save先复制文件、组装条目，最后atomic写manifest.json；pending读取并解码manifest后列出批次。该列表并不在此逐个验证附件仍存在或内容已审核。后续update可重写manifest，所以它不是服务器提交、送达、业务批准或不可变归档凭证。

## 与混合批次交接、导出编码和文件保护的区别

交接指南核文件先行的网页阶段，导出指南核序列化契约，保护指南核写选项；这里核**本地构造可见点、读取失败和残留目录的解释**。不访问收件箱、执行清理或删除任何数据。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 构造顺序 | 文件复制而非移动，manifest最后写 | 原件与暂存副本 | 来源文件已被转移或业务已发送 |
| 可见条件 | 有可读取/解码manifest的批次可列出 | 列表与实际附件分开 | 每份文件存在/已审/完整校验 |
| pending失败 | 读目录/manifest/解码可缺项 | 真实错误和范围 | 空列表就是全部材料不存在 |
| update | 部分放置后可重写manifest | 当前批次阶段 | 永久不可变原始档案 |
| 缺manifest目录 | sweepIncomplete按条件尝试清理 | 是否缺manifest与目录时间 | 所有批次都按TTL删除 |
| 默认3600秒 | 比较修改时间，缺值可用distantPast | 年龄条件与调用时点 | 每小时定时清空/至少保存一小时 |
| 移除尝试 | try?不独立证明成功 | 实际目录/其他副本 | 安全擦除或全量回收 |
| 归档/服务 | 本地元数据与远端分账 | 实际草稿/附件/回执 | 服务器事务或接收确认 |

</div>

## 合成本地观察

目录甲没有manifest，因此不在pending解码列表；不能据此宣布文件从未复制或都已清除。目录乙有manifest并可解码，仍应分别核附件和阶段，不自动标全量归档。

默认清理年龄是3600秒、按目录修改时间判定；缺时间可用distantPast，不是从创建起至少保留一小时。清理需被调用，不是本页新建的定时服务；源原件、暂存和远端副本仍按实际授权范围核。

## FAQ

<h3 id="faq-1">有manifest就证明全部附件仍在吗？</h3>

pending只读取解码清单，不在此逐个核附件存在/内容，需另外验证。

<h3 id="faq-2">空列表能证明没有残留文件吗？</h3>

不能。目录、读取/解码失败或缺manifest等情况需分开看。

<h3 id="faq-3">3600秒是不是所有材料保留期？</h3>

不是，针对缺manifest目录的年龄条件，既非统一TTL也非固定定时清理承诺。

<h3 id="faq-4">缺修改时间也保证至少留一小时吗？</h3>

不保证，该路径可用distantPast判断，不能推创建后的最低保留。

<h3 id="faq-5">manifest是否不可变？</h3>

不是。已有update会随阶段重写，不是不可篡改日志。

<h3 id="faq-6">本页执行了清理/上传吗？</h3>

没有。只核本地结构，不访问、删除、上传或提供新归档服务。

## 相关指南与源码

[混合批次阶段](/guides/share-batch-item-preflight/) · [编码与内部清单](/guides/export-encoding-delimiter-preflight/) · [文件保护](/guides/local-file-protection-scope/) · [移除范围](/guides/note-removal-retention-boundaries/) · [开始](/start/) · [隐私](/privacy/)

[save/update/pending/sweepIncomplete](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/CollieShareInbox.swift) · [调用清理与放置阶段](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShareTray.swift)
