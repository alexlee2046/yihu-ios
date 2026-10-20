---
layout: ../../layouts/Wave3Guide.astro
title: "隐私manifest和权限文案能证明什么？声明、运行时与网页服务分账"
description: "核当前PrivacyInfo的API用途类别与Info.plist文案；声明不是实机网络审计、第三方网页零收集或App Store审核，不新增合规认证。"
lang: zh
---

<h2 id="first-answer">有声明不等全路径已验，权限说明也不是数据从未离机的证明</h2>

当前PrivacyInfo.xcprivacy列出UserDefaults和FileTimestamp访问API类别及理由码；Info.plist另有麦克风/相机用途等配置。它们说明源码声明/文案，不是运行时所有入口、第三方工作台脚本或后续交接的审计证据，不能据此宣传零收集、App Store已审核或合法合规认证。

## 与内容脱敏、文件保护和网站隐私说明的区别

脱敏核内容，保护核具体存储选项，站点/服务隐私有各自范围；这里核**静态声明在证据链中的位置**。不解释法律结论、不读私人数据、不发网络请求或更改权限。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| PrivacyInfo | 列NSPrivacyAccessedAPITypes | 当前实际文件与版本 | 全量运行时数据流已审 |
| 类别/理由 | UserDefaults/FileTimestamp及CA92.1/C617.1 | 按源码所列范围说明 | 补造未列Tracking/CollectedData字段 |
| Info.plist文案 | 麦克风/相机用途文字 | 文案与各入口实现另核 | 一句话证明所有路径行为 |
| 后台配置 | audio等配置声明 | 运行状态/系统条件另验 | 所有锁屏/低电量场景保证 |
| 原生与网页 | 不同代码/服务范围 | 目标脚本/Cookie/账户与后续动作 | 原生声明涵盖所有网页 |
| 本机转写与交接 | 不同处理阶段 | 实际目标与发送/上传证据 | 本地识别就全链永不离机 |
| 发行/审核 | 声明文件不等外部审核 | 真实发行证据另核 | 有App Store链接或sameAs可填写 |
| 归档结论 | 版本/声明/实测范围分账 | 只报告真正核过的证据 | 安全/隐私认证或法律结论 |

</div>

## 合成声明记录

已知：固定版本包含两类API用途声明；未证：设备所有运行路径、第三方网页或后续目标的数据处理。只能写声明已查阅，不写全链零收集/全合规。

文件未列某字段也不能被自动解读为某项运行时保证。权限文案、用户选择、代码行为和实际网络/目的地证据分别保留；本文不填写商店身份、注册认证或执行隐私测试。

## FAQ

<h3 id="faq-1">PrivacyInfo是否完整运行时审计报告？</h3>

不是，它是当前源码声明，实际数据流和第三方行为仍需实证。

<h3 id="faq-2">没有列某收集字段就证明全链零收集吗？</h3>

不能这样推出，不补造字段含义或覆盖范围。

<h3 id="faq-3">用途文案能代替测试所有入口吗？</h3>

不能，各原生/快捷入口、网页与后续动作需按实际实现核。

<h3 id="faq-4">本机识别是否证明后续文字永不上传？</h3>

不证明。识别与获准交接/目标服务是不同阶段。

<h3 id="faq-5">manifest存在说明App Store已上线审核吗？</h3>

不说明，不因此生成未核实商店链接或sameAs。

<h3 id="faq-6">本页是否给出法律或隐私认证？</h3>

没有。仅核静态证据范围，不运行测试、不作合规结论。

## 相关指南与源码

[文件选项](/guides/local-file-protection-scope/) · [内容敏感层](/guides/carrier-redaction-archive-matrix/) · [壳与服务](/guides/voice-workbench-vs-radio-chat/) · [实际交接证据](/guides/handoff-evidence-audit-checklist/) · [开始](/start/) · [隐私](/privacy/)

[实际API声明](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/PrivacyInfo.xcprivacy) · [用途/后台配置](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/Info.plist) · [原生与工作台产品边界](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)
