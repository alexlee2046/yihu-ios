---
layout: ../../layouts/Wave3Guide.astro
title: "声纹为什么要六句？注册有效帧、旧档版本与采集模式核对"
description: "区分当前6句注册、v1三组/v2六组加载条件与32000有效帧门；部分一致不等完整注册，兼容非任意导入/身份认证，不读取声纹。"
lang: zh
---

<h2 id="first-answer">六句、有效语音计数与旧档兼容，是不同的注册条件</h2>

当前注册要求6句，注册每句有效语音门为32000帧，区别匹配阶段16000帧。计数由voicedRange估计，不是总录音秒数或语义真值。当前v2档要求6组，旧v1分支为3组且还有维度/有限值/一致性等条件；并非任意三句都能导入，模式匹配也不能省略，更不是身份认证。

## 与声纹匹配、近场策略和模型资产的区别

匹配核便捷过滤结果，近场核采集策略，资产核固定文件；这里核**注册样本完备性、profile版本及模式前提**。不录音、不读取或替换真实声纹档案。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 当前注册 | enrollmentPhraseCount=6 | 安静/日常提示与实际材料 | 录满6秒即注册成功 |
| 每句有效门 | enrollmentMinimumVoicedSamples=32000 | 16k计数约2秒有效估计非墙钟 | 总录音两秒一定够 |
| 匹配门 | minimumVoicedSamples=16000 | 注册和匹配不同阶段 | 两个门可互换 |
| 逐步一致性 | enrollmentIsConsistent可核部分集合 | 部分通过非六句完备 | 一两句通过就是完成 |
| 版本 | 当前v2六组；legacy v1三组分支 | 格式/维度/有限/一致性仍在 | 任意旧档都兼容 |
| 文件选择 | 当前文件存在优先，不直接借旧档绕过 | 实际加载结果 | 坏v2自动靠v1恢复 |
| 模式 | profileCaptureModeMatches等前提 | 采集开关与其他路由分开 | 换模式原档必然一样可用 |
| 身份边界 | 注册/相似度是本地便捷策略 | 真实授权另核 | 生物认证/抗伪造/准确率保证 |

</div>

## 合成注册记录

已有三组向量通过某个辅助检查，不能写当前六句注册完成；引用旧v1分支也不能省略版本、维度和一致性条件。若采集模式变化，按原设置提示核对，不自动覆盖或导入其他人的资料。

有效帧与相似度均是算法条件，不是说话内容、身份或真实场景成绩。本文不收集生物特征或做真人/设备测试，也不承诺跨环境、距离或噪声表现。

## FAQ

<h3 id="faq-1">六句是不是六秒总录音？</h3>

不是，是样本句数；每句还有有效帧等门。

<h3 id="faq-2">录满两秒就满足32000有效帧吗？</h3>

不能推，总时长与voicedRange估计的有效计数不同。

<h3 id="faq-3">旧三句profile都能无条件用吗？</h3>

不能，只有相应v1分支且须其他校验，当前v2要求六组。

<h3 id="faq-4">部分一致性通过就是注册完成吗？</h3>

不是，辅助检查与最终样本完备性分开。

<h3 id="faq-5">当前档坏了会自动用旧档恢复吗？</h3>

不能如此保证，源码先按当前文件是否存在选择路径，不能借旧档绕过失败。

<h3 id="faq-6">本文读取或重新注册了声纹吗？</h3>

没有，只核源码条件，不处理真实生物特征或宣称身份能力。

## 相关指南与源码

[匹配与授权](/guides/voiceprint-filter-not-authorization/) · [采集模式](/guides/near-field-policy-route-review/) · [模型证据](/guides/model-artifact-validation-evidence/) · [开始](/start/) · [隐私](/privacy/)

[注册常量/版本加载/一致性](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceprint.swift) · [注册有效帧与界面流程](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceprintSettingsView.swift)
