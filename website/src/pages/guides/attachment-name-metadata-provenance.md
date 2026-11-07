---
layout: ../../layouts/Wave3Guide.astro
title: "同名附件加2是新版本吗？批次命名、MIME与大小元数据核对"
description: "核uniqueName不区分大小写的局部冲突处理、扩展名类型和byteCount；编号非业务版本/内容去重，名称大小不等hash或真实性。"
lang: zh
---

## SYN-ANM-45 附件名称与元数据自检卡

SYNTHETIC_EXAMPLE · pending · not_run。仅合成附件对应核对，不是版本批准、内容去重、脱敏或权限授予。

[/samples/p24-attachment-name-metadata-provenance/README.md](/samples/p24-attachment-name-metadata-provenance/README.md) · [/samples/p24-attachment-name-metadata-provenance/preflight.zh.json](/samples/p24-attachment-name-metadata-provenance/preflight.zh.json) · [/samples/p24-attachment-name-metadata-provenance/preflight.en.json](/samples/p24-attachment-name-metadata-provenance/preflight.en.json)

编号不等业务版本、大小不等hash、MIME不等真实格式；原引用、实际版本与回执未知即停。测试目录不证明App Group系统访问；真实附件、跨进程与远端全部not_run。

<div role="region" aria-label="SYN-ANM-45" tabindex="0">

| ID | 检查项 | 合成观察 | 不应推断 |
| --- | --- | --- | --- |
| C01 | 批次局部命名 | sample.txt → sample.txt；新批次可重用。 | 不是全账户去重。 |
| C02 | 大小写冲突 | sample.txt 后 SAMPLE.TXT → SAMPLE 2.TXT。 | 不合并内容；2不是业务版本。 |
| C03 | 已有编号占位 | report.txt/report 2.txt占用时 → report 3.txt。 | 不是批准顺序。 |
| C04 | 空名称后备 | 空名 → file，再次空名 → file 2。 | 非原件身份恢复。 |
| C05 | 斜线替换 | a/b.txt → a_b.txt。 | 不是任意路径安全认证或恶意软件扫描。 |
| C06 | 多段扩展名 | a.tar.gz冲突 → a.tar 2.gz。 | 不解包、不验证格式。 |
| C07 | 扩展名类型 | 合成sample.txt推断text/plain。 | MIME不是内容嗅探、信任或脱敏证明。 |
| C08 | 同大小异内容 | alpha与bravo各5字节。 | 大小相同不是相同SHA或真实性。 |
| C09 | 缺失来源大小 | byteCount读取不到大小可回0。 | 0不证明真实空文件或复制成功。 |
| C10 | 目录统计 | 受控目录两份5字节文件合计10。 | 非全链内存、冻结快照或完整性承诺。 |
| C11 | 暂存预算 | 文件测量累计门200MiB=209715200字节。 | 不是全部文字URL限制或网页上传额度。 |
| C12 | 复制与原引用 | save复制而非移动文件；合成原文件仍在。 | 没有自动记录原路径/内容hash/批准版本；外部对应表另核。 |
| C13 | manifest最后写 | 先复制文件，最后原子写manifest。 | 不是跨进程锁、所有文件事务或真实Extension取证。 |
| C14 | pending解析边界 | 坏JSON被跳过；合法manifest即使缺副本也可返回。 | 可见不等文件齐全、已导入或已交付。 |
| C15 | App Group三层证据 | 源码声明、最终签名、系统containerURL分别留证。 | 测试root可写不等系统共享权限；nil非唯一网络故障。 |
| C16 | 目的地与副本 | 按获准原引用核版本与必要副本，未知即停。 | 填入/attached非远端完成；目的地可保存同步处理，discard非服务器撤回。 |

</div>



<h2 id="first-answer">暂存重命名只是区分文件，不是版本、去重或内容认证</h2>

收件箱save为每个批次新建usedNames，uniqueName不区分大小写检测命名冲突，保留文件并加数字区分；不是丢弃或合并同名内容。contentType由扩展名推断，byteCount为来源大小统计。它们都不能证明业务版本、真实格式、字节一致或已脱敏，本页不新增档案去重/鉴定服务。

## 与批次逐项、编码和变更档案的区别

逐项指南核内容/阶段，编码指南核序列化，变更档案核前后关系；这里核**原文件名到暂存名的对应及元数据能证明什么**。不复制真实文件，不改名或公开附件。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 局部命名 | usedNames在本批次内使用 | 批次/条目ID与原引用 | 全收件箱或全账户去重 |
| 大小写 | 候选lowercased后检测冲突 | 原名与暂存名保留对应 | 仅大小写不同可当同内容 |
| 数字后缀 | 冲突时保留文件并编号 | 编号由命名占用产生 | 版本2/最新批准稿 |
| 路径清理 | uniqueName处理名称字符 | 显示名与实际材料区别 | 安全扫描/内容鉴定 |
| 类型提示 | UTType按扩展名取MIME | 真实格式/目的地另核 | 扩展名正确就内容可信 |
| byteCount | 文件/目录包大小统计，读取失败需另核 | 大小测量与实际副本 | 同大小就是相同SHA |
| 暂存预算 | 按测得文件大小累计200MiB门 | 非全部文字/网页限制 | 任意网页都能上传200MiB |
| 归档身份 | batch/item/id/原引用分账 | 实际版本/内容证据 | 名字、数字和MIME就是业务身份 |

</div>

## 合成命名示意

同一批次先有sample.txt，再来SAMPLE.TXT，后者可暂存为SAMPLE 2.TXT。只是命名冲突处理，两份仍不同条目，不能称第二份为业务v2，也不能据此认定两份内容相同或已合并。

不同批次可重复使用同名，类型和大小元数据也不是密码学摘要。若需要版本比对，沿已有获准原引用和实际字节/内容核；不要改扩展名伪装格式或用命名绕过交接/权限。

## FAQ

<h3 id="faq-1">文件名2是不是版本v2？</h3>

不是，数字是局部冲突编号，不是业务版本或批准顺序。

<h3 id="faq-2">大小写不同会保留两个未改名的同名项吗？</h3>

当前uniqueName按小写检测冲突，会给冲突候选编号；并不合并内容。

<h3 id="faq-3">是否全局删除重复内容？</h3>

没有，这里是每批次命名唯一性，不是内容去重。

<h3 id="faq-4">MIME能证明文件真实格式吗？</h3>

不能，它由扩展名推断，真实内容和目的地条件另核。

<h3 id="faq-5">byteCount相同是否字节一致？</h3>

不能，只是大小，非SHA或原件真实性证据。

<h3 id="faq-6">本文执行了复制/改名/鉴定吗？</h3>

没有，只核合成例子和源码，不操作实际附件或新增服务。

## 相关指南与源码

[逐项检查](/guides/share-batch-item-preflight/) · [编码与文件名](/guides/export-encoding-delimiter-preflight/) · [版本材料](/guides/batch-change-record-retention/) · [文件桥阶段](/guides/file-chunk-bridge-not-upload-receipt/) · [开始](/start/) · [隐私](/privacy/)

[uniqueName/byteCount/save](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/CollieShareInbox.swift) · [附件条目与后续放置](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShareTray.swift)
