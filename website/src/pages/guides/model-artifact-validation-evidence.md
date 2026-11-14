---
layout: ../../layouts/Wave3Guide.astro
title: "模型校验通过代表什么？revision、资产SHA、加载与预热分账"
description: "isInstalled本身核revision/逐资产大小与SHA；文件完整性不等CoreML加载、预热或准确率，已加载实例可复用，不运行下载或模型。"
lang: zh
indexable: false
---

<h2 id="first-answer">固定资产匹配不是识别准确率，下载/加载/预热也非同一个门</h2>

Qwen3ModelStore.isInstalled会核固定revision标记，并对清单资产核大小和SHA-256，不只是检查目录存在。加载时仍有完整性门，之后CoreML加载和预热也可能失败；validateInstalledModel可复用已加载/预热实例，不代表每次都全盘重读。文件证据不证明每词准确或真实场景可用。

## 与首次试用、声纹和材料hash的区别

试用核整条链路，声纹是另一便捷过滤，材料hash核某份字节；这里核**本地ASR固定资产、安装判定、内存加载与预热的证据层级**。不下载模型、读取私有声音、卸载或运行推理。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 固定清单 | 指定repository revision和每项字节/SHA | 对应固定源码清单 | 任意同名权重都兼容 |
| isInstalled | 标记及列出资产逐项大小/摘要 | false的取消/缺项/失配等区别 | 仅有目录就已通过 |
| 清单范围 | 核列出的资产 | 已核文件与其他材料分开 | 整个目录全部文件真实性认证 |
| 发布安装树 | 已验证staging后再替换/移动 | 实际安装结果和错误 | 下载进度数字即加载成功 |
| 加载 | loadIfNeeded先看内存实例 | 新加载需要完整性/代际条件 | 每次调用都重新全盘校验 |
| 代际隔离 | installGeneration变化保护旧等待加载 | 旧准备与当前模型分开 | 数字提供身份签名 |
| 预热 | validate调用/已预热可复用 | 实际失败与结果 | 预热成功等真实讲话准确 |
| 归档证据 | 版本/清单/实际通过范围 | 设备/权限/原音频/内容另验 | 模型安全认证、语义正确或恢复SLA |

</div>

## 合成校验说明

已知：某固定清单资产匹配；未证：本机CoreML加载、预热和真实语音效果。只能写文件完整性范围通过，不报告识别成绩。若已加载实例被复用，也不写“刚刚全盘重新验过”。

不要改revision标记或清单来掩盖失配，不为页面演示下载/移除真实模型。哈希对应预期字节，不替代发布信任、使用许可、运行兼容或真实准确率验收；本页没有测这些项。

## FAQ

<h3 id="faq-1">isInstalled只看文件夹存在吗？</h3>

不是。当前实现核固定revision及清单资产的大小和SHA。

<h3 id="faq-2">全部hash对就每句话准确吗？</h3>

不能推出，文件完整性与运行、设备、语音内容和语义分别核。

<h3 id="faq-3">validate每次都重新读全部文件吗？</h3>

不能这样说，已加载/预热实例可复用，首次加载仍需完整性门。

<h3 id="faq-4">安装返回后还可能加载失败吗？</h3>

可能，CoreML加载/预热是不同阶段，不能用下载状态替代。

<h3 id="faq-5">isInstalled为false必定是恶意篡改吗？</h3>

不能单独判断，取消、缺项、读取/大小/摘要或版本等条件都需核。

<h3 id="faq-6">本页运行过模型或下载吗？</h3>

没有。只核源码和证据层级，不称模型性能或真实设备验收。

## 相关指南与源码

[整链试用](/guides/first-trial-go-no-go-checklist/) · [声纹区别](/guides/voiceprint-filter-not-authorization/) · [材料与版本](/guides/batch-change-record-retention/) · [预览与最终](/guides/replaceable-voice-preview-review/) · [开始](/start/) · [隐私](/privacy/)

[固定清单/isInstalled/install](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/Qwen3ModelStore.swift) · [loadIfNeeded/validateInstalledModel](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/Qwen3OnDeviceTranscriber.swift) · [现有准备入口](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceController.swift)
