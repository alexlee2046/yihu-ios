---
layout: ../../layouts/Wave3Guide.astro
title: "声纹结果能证明什么？便捷过滤、未就绪与账户权限分账"
description: "源码明确本地声纹是便捷过滤而非认证；match/bypass/unavailable与0.70阈值不构成实名、概率、签名或操作授权，不运行采样或登记。"
lang: zh
---

<h2 id="first-answer">声纹match不是身份认证，bypass也不是成功匹配</h2>

CollieVoiceprint源码明确写明“便捷过滤、不是认证，误接受始终可能”。其Decision有bypass、match、mismatch、unavailable；未启用时bypass不表示做过比较。数值阈值0.70也不是70%身份概率。任何过滤结果都不能代替账户、目标权限、手机确认或实际执行回执。

## 与采样权限、路由和多角色确认的区别

采样指南核音频输入，路由指南核系统状态，角色清单核动作许可；这里核**本地声音过滤分支的结论能否被过度解释为身份/授权**。本页不录制、登记或读取真实声纹，不修改开关与模型。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 未启用 | decide返回bypass | 没比较与匹配成功分开 | 证明是本人 |
| match/mismatch | 按分数与阈值分类 | 实际分支与有限上下文 | 实名认证或不可伪造签名 |
| 阈值0.70 | 实现比较门槛 | 分数不是校准身份概率 | 70%置信或真实人群准确率 |
| unavailable | 模式不符/样本或向量等条件不足 | 未就绪与不匹配不同 | 证明不是本人或应绕过检查 |
| 最少有声样本 | 16000有声样本，16k下约1秒 | 有声统计与总录音时长 | 录够1秒就总能判断 |
| 收音模式 | 保存模式与当前模式另核 | 已有设置提示与原流程 | 更改偏好后旧资料永远适用 |
| 原交付路径 | 仍有前台/会话/目标守卫 | 当前入口真实状态 | 本地声音分支授予服务端写权 |
| 归档证据 | 只记录实际过滤范围 | 身份、正文真实性与授权另证 | 自动签收、审批或业务执行完成 |

</div>

## 合成结论记录

样例结果：bypass；原因：该本地比较未启用。只能记录未比较，不能写成“本人声音验证通过”。若结果unavailable，也保留原因范围，不伪造match或改成已授权。

声纹和声音是敏感材料；公开检查不需要真实录音、向量或资料。本文没有人群/设备、抗伪造或低噪/高噪测试，不为兼容建议关闭保护，也不把便捷功能升级成生物识别认证服务。

## FAQ

<h3 id="faq-1">match能当本人已授权的证据吗？</h3>

不能。源码明确非认证，账户、动作范围与确认仍独立核。

<h3 id="faq-2">bypass和match是同一意思吗？</h3>

不是。未启用时可bypass，不能说实际比较成功。

<h3 id="faq-3">0.70代表70%身份可信度吗？</h3>

不代表。它是分数阈值，不是经校准的概率或人群准确率。

<h3 id="faq-4">unavailable证明声音不是本人吗？</h3>

不证明。它可表示模式、样本或资料未就绪，与不匹配分开。

<h3 id="faq-5">录一秒是否一定够有声样本？</h3>

不一定。总时长和有声样本计数不同，不能拿计时替真实输入条件。

<h3 id="faq-6">本页是否新增认证、登记或签署能力？</h3>

没有。只核固定源码边界，不采集生物特征、不建立身份认证或授权流程。

## 相关指南与源码

[采样权限](/guides/microphone-permission-sample-contract/) · [收音模式](/guides/near-field-policy-route-review/) · [确认与权限](/guides/multi-role-approval-receipt-checklist/) · [开始](/start/) · [隐私](/privacy/)

[非认证注释与Decision](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceprint.swift) · [原生入口与交付守卫](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceController.swift)
