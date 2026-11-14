---
layout: ../../layouts/Wave3Guide.astro
title: "停止、取消与迟到回调怎样区分？短语音activeToken核对"
description: "按短语音异步完成令牌核stop排空与cancel失效，旧回调不代表新录音结果；token不是认证或通用幂等，不新增自动重录。"
lang: zh
indexable: false
---

<h2 id="first-answer">stop后可有本次排空结果，cancel后旧令牌不能代表新会话</h2>

短语音start为采集创建UUID令牌，captureCompleted只接纳与activeToken相同的完成。stop先停止接纳并让管线排空，不立即废掉本次令牌；cancel清activeToken并取消管线。相同界面阶段或迟到回调不能代替会话归属核对；这是进程内完成守卫，不是身份认证或跨服务exactly-once。

## 与前台生命周期和队列压力的分工

前台指南核请求何时失效，压力指南核snapshot/final；这里核**异步结果属于哪次采集，停止和取消为何不能互换**。不触发录音、取消或回调注入。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| start | 每次捕获令牌对应当次完成闭包 | 当前有效采集 | UUID就是用户授权 |
| stop | 停止接纳、引擎停止后异步排空 | 本次final或失败 | 按钮点下即已完成或完全取消 |
| cancel | 清activeToken、取消管线 | 已取消与已发生结果分别核 | 撤回服务端副作用 |
| captureCompleted | 先比activeToken与token | 旧结果不冒新会话 | 文字相同就可接到当前目标 |
| 完成后清理 | 令牌与管线等状态清理 | 真实完成结果与错误 | 所有调用链永不重复 |
| 预览/音量 | 与final/令牌不是同证据 | 已有预览何时生成 | 迟到预览证明最终送达 |
| 目标交付 | 仍有控制器/插入等原守卫 | 当前目标和许可 | 采集令牌授写权 |
| 重新采集 | 新次操作与旧副作用分开 | 缺口/版本/旧尝试 | 自动补录、合并或重发 |

</div>

## 合成时序核对

采集甲已cancel；随后收到携带甲令牌的完成，而当前令牌不是甲。不能把该结果说成新采集乙或自动交接。若只是stop，仍可能等待甲的正常排空结果；两种情况不可混记。

这里不提供绝对无竞态/无丢失保证，不推断所有路径都会自动恢复。令牌是实现关联，不是账户凭据或签名；旧副作用仍沿原回执和不确定停止检查。

## FAQ

<h3 id="faq-1">stop等于cancel吗？</h3>

不等于。stop保留本次异步排空路径，cancel使旧令牌失效并取消管线。

<h3 id="faq-2">旧回调带UUID就可接新草稿吗？</h3>

不能。先核当前有效令牌，还需原目标/许可守卫。

<h3 id="faq-3">activeToken是否身份认证？</h3>

不是。它是采集内关联状态，不提供身份或业务操作权。

<h3 id="faq-4">点停止是否已经拿到final？</h3>

不能直接推断，需等实际完成或失败，不从按钮事件报结果。

<h3 id="faq-5">取消能撤回之前已写入的内容吗？</h3>

不能由取消推出撤回；实际旧内容/远端副作用另核。

<h3 id="faq-6">本页是否证明所有回调零竞态？</h3>

没有。只核固定源码守卫，未运行设备/并发测试或新增恢复功能。

## 相关指南与源码

[生命周期](/guides/foreground-audio-rebind-preflight/) · [队列与最终结果](/guides/capture-buffer-pressure-checklist/) · [重录范围](/guides/interruption-recapture-preflight/) · [开始](/start/) · [隐私](/privacy/)

[start/stop/cancel/captureCompleted](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift) · [管线停止与取消](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/ColliePCMStream.swift)
