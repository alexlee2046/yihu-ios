---
layout: ../../layouts/Wave3Guide.astro
title: "回复归档怎样对应请求？request_id、目标版本与待核回执分账"
description: "按原生回复的持久待核、check与recorded路径人工核请求身份，不拿文字相似或超时当重试许可，不新增通用幂等/归档服务。"
lang: zh
---

<h2 id="first-answer">同一文字不代表同一次请求，recorded也不代表已执行</h2>

原生Radar回复在submit前持久保存含requestID的待核记录，避免不确定写入变成新回复；网络结果不明时先check。recorded会显示已记录、待处理，授权确认的提示更明确说明尚未执行。归档要对应实际请求与目标，不把文字相似、时间接近或HTTP阶段当业务完成。

## 与最终主张审计、角色清单的区别

这里核**请求身份与待核记录/回执怎样对应**，不是重新审批正文或给所有服务保证exactly-once。本文不提交请求、不清理本地记录、不提供后台幂等服务。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| request_id | 请求用UUID关联 | 同次操作和原记录 | 同文自动等于同ID |
| 目标id/version/epoch | 按当前目标与来源守卫 | 确认时版本和来源 | 只凭标题/URL外观认定同目标 |
| 持久待核 | 先保存submitted再发送 | 保存是否成功、原请求身份 | 这是永久归档或备份服务 |
| 传输不确定 | 保留pending并先查回 | 超时与业务拒绝分开 | 超时说明从未写入 |
| check recorded | 走已记录路径 | 原请求与真实返回 | 业务已执行/所有角色处理完 |
| check absent | 重新prepare并保留同requestID | 遵循原入口与确认 | 用户可随意删标记制造新ID |
| 明确拒绝 | 只有对应分支清理后可能新ID | 实际错误类别与清理结果 | 把所有错误都当安全重试 |
| 人工归档 | 请求、版本、范围与回执对应 | 只留获准必要信息 | App新建操作日志库或所有后端恰好一次 |

</div>

## 合成请求核对

记录A：请求甲，结果待核；记录B：文字相同但请求身份未知。结论：不能合并成一次成功，也不能因B没记录就重发A。先沿原查回流程核。

内部待核记录不是供手工编辑的归档接口；源码有备份排除和文件保护等范围，不构成永久保留/恢复保证。人工档案不能改变请求ID、来源epoch或授权范围来绕过不确定停止。

## FAQ

<h3 id="faq-1">同文就是同一个请求吗？</h3>

不是。应以真实请求身份和目标/来源关系核，不能仅凭文本去重。

<h3 id="faq-2">超时能生成新ID直接再发吗？</h3>

不应。原路径保留待核并先check，不能把传输不确定当已拒绝。

<h3 id="faq-3">recorded是否证明执行完成？</h3>

不是。源码提示是已记录待处理；授权确认也明确尚未执行。

<h3 id="faq-4">查回absent是否一定换新ID？</h3>

当前该路径保留同requestID并重新prepare，不能自造新的重复写入。

<h3 id="faq-5">本地待核文件就是永久备份吗？</h3>

不是。它为不确定恢复服务，文件保护/备份排除不等于归档与恢复SLA。

<h3 id="faq-6">这里保证任何服务exactly-once吗？</h3>

不保证。核的是当前客户端及协议路径，不能扩展到任意后端。

## 相关指南与源码

[完成主张](/guides/handoff-evidence-audit-checklist/) · [角色确认](/guides/multi-role-approval-receipt-checklist/) · [材料归档](/guides/batch-change-record-retention/) · [开始](/start/) · [隐私](/privacy/)

[持久待核/submit/check/recorded](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift) · [目标与历史模型](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift)
