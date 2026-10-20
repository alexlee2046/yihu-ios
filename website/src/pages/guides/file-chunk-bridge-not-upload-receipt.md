---
layout: ../../layouts/Wave3Guide.astro
title: "文件分块交接代表什么？768KiB桥传输不是断点上传或服务回执"
description: "核原生读取/base64、JS parts和页面文件控件阶段；分块不等服务端流式/恒定总内存/断点续传，attached非业务送达。"
lang: zh
---

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
