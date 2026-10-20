---
layout: ../../layouts/Wave3Guide.astro
title: "切换Radar源前核什么？旧缓存、待核记录与迟到读取隔离"
description: "按source变更流程核旧缓存清理、sourceRevisions与显示筛选重置；本地隔离非服务身份认证或全量迁移，不执行切源。"
lang: zh
---

<h2 id="first-answer">配置改成新源，不表示旧缓存或旧请求可当新源材料</h2>

CollieRadarStore在source字段实际变化时先查本地回复记录，未处理时拒绝切源；旧缓存清理失败也不提交本次来源变更。成功路径递增本地sourceRevisions、清内存快照、更新Watch来源标识并重置部分筛选。异步读取写入前核revision，不把旧源迟到结果作为新源成功。

## 与源URL、离线缓存及草稿恢复的区别

URL指南核地址形状，离线指南核读取失败，草稿指南核原目标；这里核**切换配置时旧数据与新来源的隔离范围**。不切真实源、不删缓存、不修改待核记录或凭据。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 变更判断 | 去首尾空白后的source比较 | 真实变更与改名称分开 | 所有设置修改都等于切源 |
| 本地回复记录 | 存在时先处理草稿/待核 | 原请求和原目标 | 改源可清掉不确定状态 |
| 旧缓存清理 | 删除失败则拒本次切源 | 实际错误与原配置 | 忽略失败也已安全切换 |
| 内存快照 | 成功路径清该工作台快照 | 清本地显示与源数据分开 | 服务器历史/任务被删除 |
| sourceRevisions | 本机内部读取隔离计数 | 旧任务捕获值与当前值 | 服务端数据版本或认证 |
| Watch标识 | 更新watchSourceIdentity | 本地来源呈现身份 | 所有手表旧数据已擦除 |
| 筛选重置 | project/status/priority重置 | 这些项不代表全部偏好 | 新源任务不存在/已完成 |
| 异步结果 | 存储前及后续读取核revision | 晚到数据不能冒新源 | 旧网络请求从未发出或已撤回 |

</div>

## 合成切源核对

旧请求甲捕获revision甲，配置成功切换后当前revision为乙。甲返回不能被说成乙的最新读取。若旧缓存清理失败，则先报告未切源，不把准备动作当已成功保存。

本机标识不是后端身份凭据，显示重置不是业务迁移。本文不承诺跨设备原子同步、恢复或全量清理；原来源权限、未完成回复与实际保留规则继续有效。

## FAQ

<h3 id="faq-1">切源能绕过旧待核回复吗？</h3>

不能。存在回复记录时该变更路径要求先处理，不通过改URL重置不确定性。

<h3 id="faq-2">清旧缓存失败还会提交新源吗？</h3>

引用路径会报告失败并拒本次来源变更，不能报成功切换。

<h3 id="faq-3">revision就是服务器任务版本吗？</h3>

不是。sourceRevisions是客户端内部隔离状态，与业务版本/认证分账。

<h3 id="faq-4">筛选重置表示所有任务消失吗？</h3>

不表示。这里只重置部分显示条件，不改服务器业务材料。

<h3 id="faq-5">旧请求被忽略说明根本没联网吗？</h3>

不说明。忽略结果与旧请求是否已发出不同，不承诺网络撤回。

<h3 id="faq-6">本文执行了切源或缓存删除吗？</h3>

没有。只读源码核范围，无真实配置/数据修改。

## 相关指南与源码

[源URL](/guides/radar-feed-url-boundary-preflight/) · [离线与旧值](/guides/offline-workbench-handoff-troubleshooting/) · [草稿所属](/guides/reply-draft-restoration-scope/) · [开始](/start/) · [隐私](/privacy/)

[update/refresh隔离](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarStore.swift) · [来源与显示模型](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift)
