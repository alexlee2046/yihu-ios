---
layout: ../../layouts/Wave3Guide.astro
title: "识别参数什么时候生效？每pass快照与输出token预算核对"
description: "核语言/usesTerms/maxTokens快照、448默认64–1024范围；token不是字数/音频秒，调高不直接提高准确率，不提供实时或Agent云端调参。"
lang: zh
---

<h2 id="first-answer">一次识别的参数快照，不等整段会话永久同设置或实时调参</h2>

Qwen3OnDeviceTranscriber每次transcribe先读取语言、usesTerms和maxTokens偏好，再按该pass使用。默认最大输出448 token，配置范围64–1024并作clamp。token不是字数或音频时长；提高只增输出上限，仍受模型缓存等条件影响，不直接证明准确率。UI忙态会禁用该设置区，本页不新增录音中实时调参。

## 与术语列表、PCM格式和预览的区别

术语指南核列表解析，PCM指南核输入采样，预览指南核替换语义；这里核**每次识别调用的参数时点与输出预算单位**。不改设置、不运行模型，也不调整Agent服务端温度/费用。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 偏好快照 | 每pass读取language/usesTerms/maxTokens | 本次调用与以后调用分开 | 整个录音会话所有pass永远相同 |
| 语言 | 单一modelHint或自动 | 实际语言选项 | 自动翻译/准确率保证 |
| 输出预算 | 默认448，64–1024配置范围 | token非Character/字节 | 能录448秒或448字必完整 |
| clamp | 偏好值按允许范围限制 | 实际消费者与源值 | 任意数值都执行 |
| 词表开关/内容 | 开关快照与构造contextTerms分别核 | 解码入参不混为全会话实时配置 | 输出token数就是可带词表项数 |
| 预算不足 | 可能截断输出，缓存仍有限 | 真实结果与原音频 | 调高必更准/覆盖全部内容 |
| 音频限制 | 16k单声道及原输入长度门仍在 | 采样/时长与输出预算分开 | maxTokens能绕30秒采集/识别门 |
| 证据比较 | 记录实际调用参数与已核范围 | 旧预览/最终/重试不同pass | 设置标签就是准确率或送达 |

</div>

## 合成参数核查

两次识别的输出上限不同，不能只按字数长短判更准确，也不能说较长结果一定保留全部条件。若UI忙态不可改，不为测试绕过它；源码快照语义不是承诺有实时调参入口。

contextTerms在构造解码入参时取得，不能把每项配置读取描述成一个全会话永久锁定时点。结果用于简报仍须核原文、否定和未知，本文没有模型基准或参数优化成绩。

## FAQ

<h3 id="faq-1">448 token就是448字吗？</h3>

不是。token、字符、标量和字节不同，也不是音频秒数。

<h3 id="faq-2">调到1024就一定更准确吗？</h3>

不会直接保证，只增加输出预算，仍受模型/缓存/输入等限制。

<h3 id="faq-3">改maxTokens会延长音频准入吗？</h3>

不会由这个参数绕过原16k/时长等输入条件。

<h3 id="faq-4">所有预览和final必须同一参数吗？</h3>

不能从每pass快照推出整个会话永久相同，比较需核实际调用。

<h3 id="faq-5">这是Agent云端温度或beam设置吗？</h3>

不是。现有识别设置不提供任意温度/top-p/beam控制或通用Agent后台。

<h3 id="faq-6">本文改了参数或跑了优化吗？</h3>

没有。只核源码单位/时点，不承诺设备性能或准确率。

## 相关指南与源码

[词表](/guides/multilingual-terms-preflight/) · [PCM准入](/guides/pcm-format-admission-review/) · [预览语义](/guides/replaceable-voice-preview-review/) · [重试范围](/guides/note-transcription-retry-checkpoint/) · [开始](/start/) · [隐私](/privacy/)

[每pass偏好与入参](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/Qwen3OnDeviceTranscriber.swift) · [默认值/范围/clamp](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceInterfaces.swift) · [设置文案与忙态](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieLinkSettingsView.swift)
