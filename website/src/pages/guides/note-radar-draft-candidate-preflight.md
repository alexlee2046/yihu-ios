---
layout: ../../layouts/Wave3Guide.astro
title: "笔记存为Radar草稿前：候选目标为什么不等于已具备回复写权"
description: "按本地候选枚举与saveUnsubmittedDraft核源/状态/ID、原标记和eligible=false；候选不是实时能力或批量分发，不新增商机后台。"
lang: zh
---

<h2 id="first-answer">看见候选只说明本地筛选通过，保存草稿不是提交回复</h2>

writableDraftCandidates从本地工作台与快照枚举目标：源URL形态有效、无本地回复记录、指定待决策/验收状态及非空id。该枚举不额外证明reply_supported或快照时效。保存后target设eligible=false、epoch/version为空且submitted=false，仍需原生prepare/确认；不是自动发送或商机采集后台。

## 与草稿恢复、状态别名和多笔记交接的分工

恢复核旧草稿所属，别名核展示语义，多笔记核原文顺序；这里核**语音笔记进入Radar本地草稿前的候选范围和保存结果**。不操作真实笔记、候选或服务。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 候选来源 | 本地ordered工作台及snapshot.allTasks | 实际来源与原条目 | 全组织任务发现/同步 |
| 候选条件 | 有效源URL、无本地记录、原状态/非空id | 缺项原因与已有记录 | 有候选等服务已开放写权 |
| 非候选保证 | 枚举未额外核reply_supported/时效 | 后续真实目标与能力 | 候选就是新鲜可提交 |
| 保存时复核 | 工作台/source/id/url/状态等再比 | 候选是否已变更 | 列表快照永远有效 |
| 文字 | 去首尾空白且最多4000 Unicode标量 | 原文与实际保存范围 | 字符/字节预算可混用 |
| 保存草稿 | eligible=false、epoch/version空、submitted=false | 本地记录与后续prepare | 已提交/授权/执行 |
| 笔记标记 | shell先reserveHandOff再保存 | 失败可能已有预留 | 保存失败可盲重放 |
| 后续动作 | 原canSend/来源/目标/确认仍核 | 真实回执与旧副作用 | 自动批量分发或回写CRM |

</div>

## 合成候选核对

有样例候选甲，但服务能力/时效尚未核。结论：候选不是可提交证明；即使本地草稿保存成功，仍不能标已发送。若保存失败，先核笔记一次标记与本地记录，不跳过旧尝试。

本文没有创建新目标发现器或回复适配服务。候选名称含writable不代表所有写条件已满足；界面动作只支持它真实执行的阶段。

## FAQ

<h3 id="faq-1">候选出现证明reply_supported=true吗？</h3>

不证明。该枚举不额外检查此字段，原生后续能力/目标仍需核。

<h3 id="faq-2">没候选就表示没有任务吗？</h3>

不能，可能无快照、状态/id不符或已有本地记录；不从筛选缺项推全局不存在。

<h3 id="faq-3">存为草稿是否提交到后台？</h3>

引用路径写本地未提交记录，不把它当服务已收或审批。

<h3 id="faq-4">为什么eligible是false？</h3>

本地草稿不预授写权，后续沿原prepare和确认取得真实目标状态。

<h3 id="faq-5">保存失败能直接换目标再试吗？</h3>

不能盲试，shell可先预留笔记交接标记，需核旧状态与结果。

<h3 id="faq-6">本文新增自动商机归档或批量写入吗？</h3>

没有。只核已有本地草稿候选路径，不提供托管后台或自动分发。

## 相关指南与源码

[草稿所属](/guides/reply-draft-restoration-scope/) · [状态与资格](/guides/status-alias-approval-boundaries/) · [笔记一次交接](/guides/recording-notes-handoff/) · [开始](/start/) · [隐私](/privacy/)

[候选与本地草稿](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarStore.swift) · [预留后保存顺序](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShellApp.swift) · [已有候选入口](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotesView.swift)
