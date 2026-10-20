---
layout: ../../layouts/Wave3Guide.astro
title: "waiting分类能当审批吗？原状态、展示别名与回复资格归档核对"
description: "按任务状态分类核trim/lowercase与显式别名；waiting/done图标不代表审批或执行证据，分类不回写源值，不新增工作流引擎。"
lang: zh
---

<h2 id="first-answer">展示类别是派生结果，不是源状态改写、审批或回复权限</h2>

CollieRadarTaskState.classify对状态去首尾空白、转小写后匹配显式别名；waiting/pending可归waiting，done/completed可归completed，未知仍unknown。分类说明展示语义，不把源原文改成中文状态，也不独立证明批准、业务完成或具备回复权限。

## 与空字段默认、角色审批和批次比对的区别

空字段指南核占位，角色清单核谁能确认，批次比较核两批原材料；这里核**非空状态经过展示分类后，原始值与派生类别怎样分别归档**。不修改源、不迁移枚举，不用翻译标签打开写入口。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 原始status | 来源实际给出的字符串 | 原文、来源和版本 | 类别名就是源值 |
| 分类输入 | trim/lowercase后按显式别名 | 展示派生与原始值分开 | 所有控件/写入口都同样归一 |
| waiting/pending | 可分类waiting | 等待何事仍需原内容 | 一定等你审批/验收 |
| done/completed | 可分类completed | 来源状态与真实证据 | 证明服务执行或PM验收 |
| 未知别名 | 落unknown | 保留原字符串与未知 | 自动猜成最接近的已知状态 |
| 回复资格 | 实际目标/能力/版本等另核 | 原生入口与fresh target | waiting图标就授予写权 |
| 翻译/整理 | 人工展示标签应标明 | 源文与编辑说明 | 改成等你验收就构成批准 |
| 归档比较 | 保留raw status/派生类别/依据 | 同类不同源值与范围 | 分类相同就是同一次事件 |

</div>

## 合成状态归档

材料A的原status为pending，展示类别waiting；材料B原文为等你验收，也可归waiting。两者同类不证明等待对象、操作许可或同一批准相同，不应把A改成B的原文。

source状态也只代表来源声明，真实性和完成证据另核。回复是否可用取决于原有流程及当前目标，不从分类单独得出“必可回复”或“永不可回复”，更不改原值绕过守卫。

## FAQ

<h3 id="faq-1">pending归waiting就能当等你验收吗？</h3>

不能。分类合组不代表原文、等待对象或审批范围相同。

<h3 id="faq-2">done是否证明后台已执行？</h3>

不独立证明。它是显式来源状态的展示分类，实际执行与验收另需证据。

<h3 id="faq-3">unknown会自动猜最接近的状态吗？</h3>

该分类未匹配时为unknown，不应人工补造业务结论。

<h3 id="faq-4">展示trim是否说明所有写入口都trim？</h3>

不说明。各入口条件分别核，不能由分类函数推广。

<h3 id="faq-5">改status标签能获得回复资格吗？</h3>

不应这样做。原生目标/能力/版本与身份条件不由编辑标签授予。

<h3 id="faq-6">同类状态能自动合并历史或批准吗？</h3>

没有新增此能力。保留原值、事件与确认范围，不以类别替真实关联。

## 相关指南与源码

[显示占位](/guides/empty-field-display-defaults/) · [角色与确认](/guides/multi-role-approval-receipt-checklist/) · [批次范围](/guides/radar-snapshot-batch-comparison/) · [请求身份](/guides/reply-request-receipt-mapping/) · [开始](/start/) · [隐私](/privacy/)

[状态显式分类](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift) · [原状态展示与入口](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarView.swift) · [当前回复守卫](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift)
