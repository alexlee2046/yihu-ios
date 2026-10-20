---
layout: ../../layouts/Wave3Guide.astro
title: "没有文字就坏模型吗？采集、输入、模型与空转写错误分层"
description: "按采集/ASR错误映射核提示类别；emptyTranscript不证明语音不存在或模型损坏，短语音与长笔记分支不同，不执行重录或删除模型。"
lang: zh
---

<h2 id="first-answer">同样“没有文字”，可能是不同层失败，不能自动归为模型损坏</h2>

控制器将权限拒绝、录音/PCM失败和模型missing/load失败分到不同提示。ASR还检查非空、有限样本和长度；最终空文字会产生emptyTranscript。短语音将空结果视作录音类失败，长笔记可略过该片段文字并推进帧位。提示是分类，不是完整底层诊断或原音频无内容证明。

## 与格式准入、模型校验和续点的区别

格式核输入形状，模型校验核资产/运行准备，续点核重试位置；这里核**错误从哪一层产生、显示类别不能推出哪些结论**。不运行录音、模型、重试或文件操作。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 权限拒绝 | captureFailure有microphonePermission分支 | 真实系统授权 | 所有失败都因为权限 |
| 录音/PCM | 受控错误或录音fallback | 格式/中断/实际输入 | 模型一定坏了 |
| ASR数组 | 非空/有限/长度门 | 数组与硬件格式不同层 | 数组通过即语音有效/有业务内容 |
| 模型missing/load | 归模型提示 | 原校验与加载证据 | 唯一原因就是SHA被改 |
| emptyTranscript | 最终空文字错误 | 实际音频/语义/阶段 | 原来一定无人说话 |
| 短语音/长笔记 | 空结果处理分支不同 | 失败提示与略过片段分账 | 所有入口相同结果 |
| 卡片文案 | 有意不展示任意系统原始错误 | 可见分类非完整日志 | 所有底层原因都已确定 |
| 后续处理 | 原授权/目标/待核条件仍在 | 最小非敏感错误与范围 | 自动删模型/上云/盲重发 |

</div>

## 合成分层记录

收到emptyTranscript，只能记这次识别没有返回可用最终文字，不能宣布模型损坏或原会议信息为空。若是模型加载提示，也应核原完整性/运行证据，不能直接下篡改结论。

长笔记推进处理帧不保证每词捕获；错误文案不是服务回执。本文没有设备/真实语音回归，不为排错公开原录音、系统路径或账户内容。

## FAQ

<h3 id="faq-1">没文字一定是模型坏了吗？</h3>

不是，输入、采集、权限、空结果和模型阶段需分开。

<h3 id="faq-2">emptyTranscript证明原音频只有静音吗？</h3>

不能独立证明，原音频与内容另核。

<h3 id="faq-3">短语音和长笔记空结果一样吗？</h3>

不是，引用路径分别走失败提示或片段略过/进度逻辑。

<h3 id="faq-4">模型加载提示能证明恶意改文件吗？</h3>

不能，它不是完整根因诊断，版本/缺项/加载等证据另核。

<h3 id="faq-5">提示是否显示了全部系统原始异常？</h3>

没有，控制器对用户提示作分类和fallback，不把卡片当完整日志。

<h3 id="faq-6">本文是否删模型、重录或切云端？</h3>

没有，不新增自动回退/删除/重发；真实操作仍需既有授权和条件。

## 相关指南与源码

[输入格式](/guides/pcm-format-admission-review/) · [模型证据](/guides/model-artifact-validation-evidence/) · [重试续点](/guides/note-transcription-retry-checkpoint/) · [权限分层](/guides/microphone-permission-sample-contract/) · [开始](/start/) · [隐私](/privacy/)

[captureFailure/recognitionFailure](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceController.swift) · [样本/非空检查](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/Qwen3OnDeviceTranscriber.swift) · [空片与进度](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift)
