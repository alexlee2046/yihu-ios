---
layout: ../../layouts/Wave3Guide.astro
title: "提到我为何命中或漏项？固定展示规则不等账户与负责人识别"
description: "按requiresMyAttention核指定状态与next固定字样匹配，其他显示条件仍有效；过滤不是权限、审批或当前账户身份识别。"
lang: zh
---

<h2 id="first-answer">“提到我”是派生筛选，不是服务端认领、身份或授权结论</h2>

当前requiresMyAttention在状态去首尾空白后匹配等你决策/等你验收，或检查next是否包含源码固定字样Alex。它没有在这个getter中读取当前登录账户。命中不等于任务属于某个真实用户，也不授予回复权；未命中同样不能证明没有工作需要处理。

## 与状态别名、认领与空字段的区别

别名指南核展示类别，认领清单核责任范围，空字段指南核占位；这里核**“只看提到我”的匹配原因和过滤覆盖**。源码固定字样仅作代码条件说明，不是真实顾客记录或新账户识别服务。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 状态分支 | trim后两个明确状态可命中 | 原status与匹配条件 | 正文必须含名字才命中 |
| next分支 | localizedStandardContains检查固定Alex | 检查的是next而非所有正文 | 动态读取当前账号/联系人 |
| 过滤开启 | matchingActions可基于allTasks | 全台账/来源范围另核 | 后台发现全部待办 |
| 其他条件 | 项目/状态/优先级/搜索/历史仍可过滤 | 当前显示配置 | 匹配后一定显示 |
| 未命中/空列表 | 受来源与多重条件影响 | 原材料、范围和未知 | 没人找我或任务全完成 |
| 派生Bool | 不把原状态改写 | 源字段与显示结论分开 | 自动认领/批准 |
| 回复资格 | 实际目标/能力/权限另核 | 原生prepare/确认 | 匹配即可提交 |
| 人工归档 | 保留原值与实际核查范围 | 编辑说明非原生reason API | 自动生成负责人证据 |

</div>

## 合成筛选记录

样例A的状态为等你验收，即使next不含固定字样也可命中；样例B的next包含该字样，也不由此证明实际登录人是负责人。列表被项目过滤后变空，不能报告原来源没有待处理项。

若要用匹配结果整理简报，注明来源和已核范围，不把UI筛选截图当账户、审批或签收证明。不修改名字/状态来绕过写入口条件。

## FAQ

<h3 id="faq-1">提到我是否读取当前登录账号？</h3>

该getter用固定状态/字样条件，不提供动态账户身份识别保证。

<h3 id="faq-2">没有名字为什么仍命中？</h3>

明确待决策/验收状态本身可命中，不只检查next。

<h3 id="faq-3">标题提了名字就必命中吗？</h3>

该名字分支检查next，不等于扫描所有字段；其他条件仍可能影响结果。

<h3 id="faq-4">列表为空就证明没有待办吗？</h3>

不能。来源范围、其他显示条件和数据缺口都要核。

<h3 id="faq-5">命中后自动成为负责人或可回复吗？</h3>

不会由这个筛选授予责任/写权，原生目标和权限仍独立。

<h3 id="faq-6">本页新增多用户身份或自动认领吗？</h3>

没有。只核派生展示逻辑，不创建账户/授权或分发流程。

## 相关指南与源码

[状态别名](/guides/status-alias-approval-boundaries/) · [认领责任](/guides/department-minutes-ownership-archive/) · [显示占位](/guides/empty-field-display-defaults/) · [开始](/start/) · [隐私](/privacy/)

[requiresMyAttention/matchingActions](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift) · [显示过滤入口](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarView.swift)
