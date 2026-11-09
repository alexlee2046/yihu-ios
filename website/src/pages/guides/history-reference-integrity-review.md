---
layout: ../../layouts/Wave3Guide.astro
title: "历史反馈怎样关联原回复？目标、位置与references结构核查"
description: "核来源历史的目标组件、entry身份与明确引用；结构合法不证明已读/已处理，引用文字相似不替代关联，不新增历史数据库。"
lang: zh
---

## SYN-HRI-50 历史引用完整性自检

SYNTHETIC_EXAMPLE · pending · not_run。结构/关联不等身份、已读、审批或完成。

[/samples/p29-history-reference-integrity-review/README.md](/samples/p29-history-reference-integrity-review/README.md) · [/samples/p29-history-reference-integrity-review/preflight.zh.json](/samples/p29-history-reference-integrity-review/preflight.zh.json) · [/samples/p29-history-reference-integrity-review/preflight.en.json](/samples/p29-history-reference-integrity-review/preflight.en.json)

<div role="region" aria-label="SYN-HRI-50" tabindex="0">

| ID | 检查 | 预期/边界 |
| --- | --- | --- |
| H01 | UUID明确引用 | validate=true; feedback=1 associated update(s); synthetic only |
| H02 | 评论URL明确引用 | validate=true; feedback=1 associated update(s); synthetic only |
| H03 | 仅说已看不关联 | validate=true; feedback=0 associated update(s); synthetic only |
| H04 | 引用其他请求 | validate=true; feedback=0 associated update(s); synthetic only |
| H05 | 较早update不关联 | validate=true; feedback=0 associated update(s); synthetic only |
| H06 | draft UUID关联 | validate=true; feedback=1 associated update(s); synthetic only |
| H07 | draft拒绝评论引用 | validate=false; feedback=not_run; synthetic only |
| H08 | draft拒绝正式时间 | validate=false; feedback=not_run; synthetic only |
| H09 | draft URL不完全相同 | validate=false; feedback=not_run; synthetic only |
| H10 | 目标ID不符 | validate=false; feedback=not_run; synthetic only |
| H11 | 重复entry ID | validate=false; feedback=not_run; synthetic only |
| H12 | 已加载ID冲突 | validate=false; feedback=not_run; synthetic only |
| H13 | kind越界 | validate=false; feedback=not_run; synthetic only |
| H14 | reply UUID无效 | validate=false; feedback=not_run; synthetic only |
| H15 | 引用UUID非规范小写 | validate=false; feedback=not_run; synthetic only |
| H16 | 重复reference | validate=false; feedback=not_run; synthetic only |
| H17 | 跨任务评论引用 | validate=false; feedback=not_run; synthetic only |
| H18 | entry host不符 | validate=false; feedback=not_run; synthetic only |
| H19 | 显式端口组件不同 | validate=false; feedback=not_run; synthetic only |
| H20 | entry path不符 | validate=false; feedback=not_run; synthetic only |
| H21 | entry query不符 | validate=false; feedback=not_run; synthetic only |
| H22 | position次序错误 | validate=false; feedback=not_run; synthetic only |
| H23 | 未完页缺cursor | validate=false; feedback=not_run; synthetic only |
| H24 | 5条页保未读缺口 | validate=true; feedback=4 associated update(s); synthetic only |
| M01 | 关联不等已读/处理 | 结构通过/明确references只给原关联，不授身份、审批、真实性或业务完成。 |
| M02 | Web重载不等历史读成 | spinner、取消过滤或reload不是原生历史已加载/当前目标完整/服务动作完成的证据。 |
| M03 | 不同取消路径不互代 | 网页导航取消与原生历史generation/请求回执不同；不把旧结果或迟到正文自动拼入新目标，不以取消抹回执。 |
| M04 | 调度非恢复SLA | NSURLErrorDomain取消与WebKitErrorDomain/102按域代码合核，500ms复核和15秒防环不是恢复/未执行保证。 |
| M05 | 缺口不补造引用 | 保原目标、位置、引用与缺口，不从正文猜reference、不改时间/URL修出通过，不跨账户建索引。 |
| M06 | 最小披露与停止 | 全部合成不访问链接；真实授权、已读、处理与远端回执未知即停，目的地可保存同步，不盲重放。 |

</div>



<h2 id="first-answer">有后续文字不等于关联反馈，明确引用也不代表已处理</h2>

CollieRadarReplyHistory只把位置晚于原reply、kind为update且references明确指向request_id或非draft回复URL的记录关联为反馈。历史还校验目标、条目身份、位置与URL组件。它是只读来源结构，不是已读、业务完成或真实性认证；本文不新建历史库或关联引擎。

## 与历史检索和请求回执的分工

检索核覆盖范围，请求回执核提交结果；这里核**取到的历史结构是否属于同一目标、哪些后续记录可关联到原回复**。不访问原条目或手改私有记录。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| entry身份 | id非空且不能重复，kind限reply/update | 真实记录与已加载集合 | 同文就是同条 |
| 目标URL | 核host/port/path/query等组件 | 不是只看域名外观 | 任意跨任务评论都可拼入 |
| position | 有序位置与加载计数一致 | 前后记录关系 | 时间相近就证明关联 |
| request_id | reply带合法UUID | 与明确引用分别核 | UUID形状就是审批/签名 |
| references | 数量/唯一性与合法引用形态校验 | 合法小写UUID或允许评论引用 | 从正文自动猜关联 |
| feedback | 后续update明确引用原reply | 关联存在和内容含义分开 | 已读/已完成/已批准 |
| draft历史 | URL/时间字段有专门条件 | 草稿与非draft模式 | 两种材料可无条件混拼 |
| 人工归档 | 保留目标、原引用和未知 | 只记录获准范围 | 新建跨账户索引或不可篡改日志 |

</div>

## 合成关联核对

后续记录写“已看”，但references没有指向样例原回复：不能仅凭文字认定该reply已有反馈。反过来，有合法关联也需看实际内容，不能自动标业务处理完成。

相同目标组件不是来源可信认证；结构失败应保留缺口并回原入口核，不补造references让结果看似完整。本文未运行真实历史读取、账号授权或跨目标拼接。

## FAQ

<h3 id="faq-1">后面有人提任务就等于对本次回复反馈吗？</h3>

不等于。当前关联需要明确引用与位置/kind条件，不能靠语义猜。

<h3 id="faq-2">references合法就表示已处理吗？</h3>

不表示。关联与反馈实际含义、已读和完成不同。

<h3 id="faq-3">同域名的评论都能合进同一历史吗？</h3>

不能这样推断。还核端口、路径、查询、目标与条目规则。

<h3 id="faq-4">UUID形状可证明谁批准吗？</h3>

不能。身份、权限与批准依据不是引用形状提供的。

<h3 id="faq-5">draft与正式历史能直接混拼吗？</h3>

不能无条件混用。两类URL/时间字段和翻页一致性要分别核。

<h3 id="faq-6">可以补写引用来消除错误吗？</h3>

不应伪造关联。保留原材料与缺口，沿真实来源维护流程处理。

## 相关指南与源码

[历史检索范围](/guides/history-retrieval-manual-comparison/) · [请求回执](/guides/reply-request-receipt-mapping/) · [确认范围](/guides/multi-role-approval-receipt-checklist/) · [开始](/start/) · [隐私](/privacy/)

[History.validate/feedback](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift) · [只读历史加载](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift)
