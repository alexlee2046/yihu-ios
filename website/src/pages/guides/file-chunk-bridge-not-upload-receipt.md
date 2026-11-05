---
layout: ../../layouts/Wave3Guide.astro
title: "文件分块交接代表什么？768KiB桥传输不是断点上传或服务回执"
description: "核原生读取/base64、JS parts和页面文件控件阶段；分块不等服务端流式/恒定总内存/断点续传，attached非业务送达。"
lang: zh
---

<h2 id="syn-chk-40">SYN-CHK-40：文件分片、页面接纳与收件箱解析</h2>

SYNTHETIC_EXAMPLE，仅自建临时文件/假WK/VM，不是真实App Group或服务上传。

[ZH: /samples/p19-file-chunk-bridge/preflight.zh.json](/samples/p19-file-chunk-bridge/preflight.zh.json) · [EN: /samples/p19-file-chunk-bridge/preflight.en.json](/samples/p19-file-chunk-bridge/preflight.en.json) · [Card: /samples/p19-file-chunk-bridge/preflight-card.md](/samples/p19-file-chunk-bridge/preflight-card.md)

<div role="region" aria-label="合成分片/页面回执/收件箱核查表，可左右滚动" tabindex="0">

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| N1 | no_web | {'result': 'failed', 'roles': []} | Original Swift + fake WK replies; not server upload |
| N2 | untrusted | {'result': 'failed', 'roles': []} | Original Swift + fake WK replies; not server upload |
| N3 | normal | {'result': 'attached', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N4 | no_input | {'result': 'noUploadControl', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N5 | single_only | {'result': 'oneAtATime', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N6 | unknown | {'result': 'failed', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N7 | chunk_false | {'result': 'failed', 'roles': ['begin', 'chunk', 'discard']} | Original Swift + fake WK replies; not server upload |
| N8 | chunk_throw | {'result': 'failed', 'roles': ['begin', 'chunk', 'discard']} | Original Swift + fake WK replies; not server upload |
| N9 | begin_throw | {'result': 'failed', 'roles': ['begin', 'discard']} | Original Swift + fake WK replies; not server upload |
| N10 | begin_false | {'result': 'attached', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N11 | attach_throw | {'result': 'failed', 'roles': ['begin', 'chunk', 'attach', 'discard']} | Original Swift + fake WK replies; not server upload |
| N12 | origin_drift | {'result': 'failed', 'roles': ['begin', 'chunk', 'discard']} | Original Swift + fake WK replies; not server upload |
| N13 | same_origin_path_drift | {'result': 'attached', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N14 | empty_file | {'result': 'attached', 'roles': ['begin', 'attach']} | Original Swift + fake WK replies; not server upload |
| N15 | empty_files | {'result': 'failed', 'roles': ['attach']} | Original Swift + fake WK replies; not server upload |
| N16 | two_chunks | {'result': 'attached', 'roles': ['begin', 'chunk', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| F1 | synthetic file bytes=0 | actual source raw chunks=[]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F2 | synthetic file bytes=1 | actual source raw chunks=[1]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F3 | synthetic file bytes=786432 | actual source raw chunks=[786432]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F4 | synthetic file bytes=786433 | actual source raw chunks=[786432, 1]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F5 | synthetic file bytes=1572881 | actual source raw chunks=[786432, 786432, 17]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| C1 | normal | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C2 | binary_split | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C3 | unknown_chunk | false | Original emitted JS with synthetic File/DataTransfer/input |
| C4 | duplicate | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C5 | reordered | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C6 | missing_chunk | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C7 | invalid_base64 | throws | Original emitted JS with synthetic File/DataTransfer/input |
| C8 | discard | false | Original emitted JS with synthetic File/DataTransfer/input |
| C9 | rebegin | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C10 | no_input | no-input | Original emitted JS with synthetic File/DataTransfer/input |
| C11 | single_only | single-only | Original emitted JS with synthetic File/DataTransfer/input |
| C12 | type_mismatch | no-input | Original emitted JS with synthetic File/DataTransfer/input |
| C13 | multiple | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C14 | partial_ids | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C15 | empty_file | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C16 | repeat_attach | failed | Original emitted JS with synthetic File/DataTransfer/input |
| C17 | empty_mime | attached | Original emitted JS with synthetic File/DataTransfer/input |
| I1 | orphan_file | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I2 | corrupt_json | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I3 | invalid_schema | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I4 | missing_payload | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I5 | save_copy | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I6 | empty_save_rollback | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I7 | inline_text | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I8 | duplicate_names | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I9 | oldest_first | pending decoded batches=2 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I10 | update_empty_items | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I11 | missing_root | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| R1 | AppGroup入口/声明/签名/解析分别留证 | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |
| R2 | attached不等远端上传或业务发送 | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |
| R3 | 分片无序号/校验和/断点续传保证 | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |
| R4 | 清JS暂存/移出批次不等撤回服务副本 | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |

</div>

768KiB是原始读块，不是总内存或断点上传；base64/JS parts/File另占内存。chunk true/attached只属于桥/页面阶段，没有序号/校验和/重试幂等或远端完成证明；合成重复/缺块/乱序仍可组File，缺请求ID也可能仅接纳现有子集。App Group声明、系统容器可达、manifest可见、pending解析、实际导入与远端回执分别留证。坏manifest会被pending跳过，合法manifest也可指缺文件；不造解析/导入成功。真实WK/容器权限/远端API/审核/业务发送全not_run，未知副作用不盲重发，目的地可保存/同步/自动处理。

<h2 id="first-answer">跨WK桥分块，不等于目标服务已收到完整文件</h2>

attachFiles将本地文件按最多768 KiB原始数据分块读成base64，交给页面侧helper，再请求页面自己的文件控件接纳。JS会累积parts并组装File；因此分块不证明所有端总内存恒定，也不是服务端流式/断点上传协议。attached是页面阶段结果，不是远端完成或消息发送回执。

## 与混合批次、manifest和文件保护的区别

批次指南核文件先行与文本后填，manifest核本地可见点，保护核写选项；这里核**原生文件到JS再到控件的跨进程阶段**。不读取或上传真实附件，不新增文件传输服务。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 原生读取 | 最多768 KiB/块，按offset继续 | 本地读取与实际错误 | 服务端断点位置 |
| base64 | 转换为桥参数字符串 | 编码开销与传输层分开 | 原始字节数就是全部RAM |
| JS暂存 | incoming/parts累积后组File | 页面内存与本地文件分开 | 全端恒定内存 |
| chunk回报 | 逐块Bool结果可能失败 | 这层接纳不是服务确认 | 后端已存每一块 |
| 最终控件 | 原页面上传input与accept等条件 | 实际控件限制/接纳 | 支持任意网站/类型/大文件 |
| 页面边界 | 此路径按isTrusted等核 | 不要套用文字通道所有页面条件 | 所有通道守卫完全一样 |
| discard | 清页面helper暂存ID | 本地暂存与远端副本 | 撤销已发生的服务上传 |
| 预算与结果 | 本地暂存预算/attached另核 | 实际阶段和剩余材料 | 200MiB暂存就保证网页能收 |

</div>

## 合成分块记录

已知：样例文件若干块已被helper接纳；未知：最终控件/服务状态。不能写“上传完成”，也不能从后续失败推前面都从未发生。保持目标页面稳定并核真正结果，不靠改扩展名或重复整批绕过限制。

分块避免单个巨型JS字符串是实现目的，不构成全局RAM、速度或后台续传SLA。源码没有在这条原生桥中提供通用服务端上传/恢复协议，本页也未测网络或设备。

## FAQ

<h3 id="faq-1">分块是否就是服务端流式上传？</h3>

不是，原生到JS桥与网站到服务端是不同阶段。

<h3 id="faq-2">768KiB是否总内存上限？</h3>

不是，还涉及base64/parts/File等，不作全端恒定内存保证。

<h3 id="faq-3">attached能证明对方服务保存了吗？</h3>

不能，只报页面接纳阶段，真实远端状态另核。

<h3 id="faq-4">discard是否能撤回远端附件？</h3>

不能由清helper暂存推出服务撤回。

<h3 id="faq-5">200MiB暂存预算代表所有网站兼容吗？</h3>

不代表，页面控件/服务还有各自限制和权限。

<h3 id="faq-6">本文执行了上传或断点测试吗？</h3>

没有，只核固定源码，不提供新传输/转码/续传功能。

## 相关指南与源码

[批次阶段](/guides/share-batch-item-preflight/) · [本地可见点](/guides/share-manifest-visibility-review/) · [文件保护](/guides/local-file-protection-scope/) · [开始](/start/) · [隐私](/privacy/)

[attachFiles/base64Chunk](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWebView.swift) · [incoming/parts/控件适配](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieTextInsertion.swift) · [本地暂存预算](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/CollieShareInbox.swift)
