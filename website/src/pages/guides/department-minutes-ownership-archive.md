---
layout: ../../layouts/Wave3Guide.astro
title: "跨部门纪要怎样认领与归档？责任角色、确认依据和副本清单"
description: "在人工纪要整理之后核对责任角色是否确认、批准范围和归档规则；不是一呼任务分配、电子签署、文档库或自动归档功能。"
lang: zh
---

## SYN-DMO-44 · 部门纪要归属与最小归档自检

SYNTHETIC_EXAMPLE / SYN-DMO-44。真实认领/归档均pending / not_run；人工清单不是App导入、自动认领或多人说话人识别。

- 中文JSON：[preflight.zh.json](https://getyihu.com/samples/p23-department-minutes-ownership-archive/preflight.zh.json) — https://getyihu.com/samples/p23-department-minutes-ownership-archive/preflight.zh.json
- English JSON：[preflight.en.json](https://getyihu.com/samples/p23-department-minutes-ownership-archive/preflight.en.json) — https://getyihu.com/samples/p23-department-minutes-ownership-archive/preflight.en.json
- 公开双语自检卡：[README.md](https://getyihu.com/samples/p23-department-minutes-ownership-archive/README.md) — https://getyihu.com/samples/p23-department-minutes-ownership-archive/README.md

### 先人工切分原话与拟议责任，不把角色写成已认领

S1/S2和R1/R2均是手工写出的虚构说话人/角色代号，不是原生识别结果或账户。C2把两段合成提议分别引用U1/U2，形成T1/T2待核草稿；proposed_role不同于confirmed_owner。所有confirmed_owner、期限、实际认领依据、执行批准、归档位置和保留规则仍为null。C3“他们”不推定角色；C5已读/抄送不等接受；C6只核文字不等采购、发送、变更或发布授权；C7保留相冲突版本，不自动裁定负责人。SYNTHETIC_EXAMPLE的pending/not_run指真实流程，宿主跑过的结果另在checks回执分账。

### 原生守卫只证该函数行为，不建立归属或正式档案

24个源函数宿主例中，Radar解析/筛选部分仅核来源范围和文本：project筛选不是部门ACL，session/next出现角色或固定Alex不是登录/负责人识别，空列表不证明没人负责。safeEvidenceURLs拒部分不合形状链接、去重复，但保留合法HTTPS的查询/片段（E9）；HTTPS不保证可公开、已脱敏、内容可信或访问授权。

原VoiceNote.reserveHandOff只在合成临时meta上执行：done、非空串、未attempted才尝试原子落标记；先保留一次标记不证明交付、对方认领或归档。写meta失败保持原值，已attempted不能因换纪要副本重发；全空白但非空串也可能过该guard，不等有效纪要或自动修复。本轮不调用真实phone note、Store.handOff、AppGroup/剪贴板/工作台或网络。

### 最小披露、访问和保留都回原有获准流程

公开材料全部从零合成，不用改名私有客户正文冒匿名化。私有原证据仍留原权限内，先核归档目的、获准位置/读者、版本、必要副本与真实保留规则；未知则停在获准草稿，不新建账号、共享链接、不上传。删除本地记录不等撤回文档/附件/工作台/同步/备份；不提供统一保留时长、绝对删除、合规认证或CRM归档。12人工例+10原URL+8原meta+6原筛选+4副本边界共40行，只有24例/语是源函数宿主执行，不能把其余人工规则冒App功能或真实签收。

<div role="region" aria-label="SYN-DMO-44人工认领、原源守卫与副本范围表，可左右滚动" tabindex="0">

| 编号 | 分账范围 | 合成输入/人工拆分 | 宿主期望或人工边界 |
| --- | --- | --- | --- |
| C1 | 外部人工认领/归档例 | `{"mode":"proposal_not_claim","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Explicit acknowledgment missing; proposal is not assignment.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C2 | 外部人工认领/归档例 | `{"mode":"split_atomic_responsibilities","speakers":["S1","S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":"R1","confirmed_owner":null,"deadline":null},{"draft_id":"T2","speech_refs":["U2"],"proposed_role":"R2","confirmed_owner":null,"deadline":null}]}` | `{"rule":"Keep separate draft actions/evidence references, no inferred joint owner.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C3 | 外部人工认领/归档例 | `{"mode":"ambiguous_pronoun","speakers":["S1","S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Leave proposed/confirmed owner and deadline null; ask existing authorized process.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C4 | 外部人工认领/归档例 | `{"mode":"quoted_role_not_consent","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"A role quoted in speech is not the role accepting responsibility.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C5 | 外部人工认领/归档例 | `{"mode":"read_receipt_not_ack","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"A synthetic read receipt or CC never establishes claim/approval.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C6 | 外部人工认领/归档例 | `{"mode":"review_scope_not_execution","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Text-review-only scope does not authorize purchase, sending, changes or release.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C7 | 外部人工认领/归档例 | `{"mode":"conflicting_versions","speakers":["S1","S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Preserve both synthetic references, do not pick a winner or overwrite source.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C8 | 外部人工认领/归档例 | `{"mode":"unconfirmed_owner_stays_empty","speakers":["S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"No auto owner/deadline inferred from session/title/next or placeholder.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C9 | 外部人工认领/归档例 | `{"mode":"archive_location_unknown","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"No new account, shared location or upload; existing access/retention must be verified.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C10 | 外部人工认领/归档例 | `{"mode":"copies_not_recalled","speakers":["S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Local note deletion is not deletion of clipboard, workspace, attachments, sync or backups.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C11 | 外部人工认领/归档例 | `{"mode":"public_synthetic_not_redaction","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Entire public example is synthetic; HTTPS parsing is not redaction/publication permission.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C12 | 外部人工认领/归档例 | `{"mode":"uncertain_handoff_no_resend","speakers":["S1","S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Check approved destination through existing process; never reset once-attempted marker for an archive copy.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| E1 | 原证据URL解析 | `null` | `{"host_expected_URLs":[],"disclosure_permission":"pending","live":"not_run"}` |
| E2 | 原证据URL解析 | `""` | `{"host_expected_URLs":[],"disclosure_permission":"pending","live":"not_run"}` |
| E3 | 原证据URL解析 | `"https://example.invalid/evidence/sample"` | `{"host_expected_URLs":["https://example.invalid/evidence/sample"],"disclosure_permission":"pending","live":"not_run"}` |
| E4 | 原证据URL解析 | `"(https://example.invalid/evidence/sample)"` | `{"host_expected_URLs":["https://example.invalid/evidence/sample"],"disclosure_permission":"pending","live":"not_run"}` |
| E5 | 原证据URL解析 | `"https://example.invalid/evidence/sample;https://example.invalid/evidence/sample"` | `{"host_expected_URLs":["https://example.invalid/evidence/sample"],"disclosure_permission":"pending","live":"not_run"}` |
| E6 | 原证据URL解析 | `"http://example.invalid/evidence/sample"` | `{"host_expected_URLs":[],"disclosure_permission":"pending","live":"not_run"}` |
| E7 | 原证据URL解析 | `"https://role@example.invalid/evidence/sample"` | `{"host_expected_URLs":[],"disclosure_permission":"pending","live":"not_run"}` |
| E8 | 原证据URL解析 | `"https://example.invalid:0/sample"` | `{"host_expected_URLs":[],"disclosure_permission":"pending","live":"not_run"}` |
| E9 | 原证据URL解析 | `"https://example.invalid/evidence/sample?ref=SYN-DMO-44#mock"` | `{"host_expected_URLs":["https://example.invalid/evidence/sample?ref=SYN-DMO-44#mock"],"disclosure_permission":"pending","live":"not_run"}` |
| E10 | 原证据URL解析 | `"https://example.invalid/evidence/sample,https://example.invalid/evidence/other"` | `{"host_expected_URLs":["https://example.invalid/evidence/sample","https://example.invalid/evidence/other"],"disclosure_permission":"pending","live":"not_run"}` |
| H1 | 原笔记临时meta守卫 | `"done_text"` | `{"host_success":true,"host_attempted":true,"delivery_or_claim":"pending","live":"not_run"}` |
| H2 | 原笔记临时meta守卫 | `"repeat_after_reserve"` | `{"host_success":true,"host_attempted":true,"delivery_or_claim":"pending","live":"not_run"}` |
| H3 | 原笔记临时meta守卫 | `"explicit_false"` | `{"host_success":true,"host_attempted":true,"delivery_or_claim":"pending","live":"not_run"}` |
| H4 | 原笔记临时meta守卫 | `"pending_status"` | `{"host_success":false,"host_attempted":null,"delivery_or_claim":"pending","live":"not_run"}` |
| H5 | 原笔记临时meta守卫 | `"empty_transcript"` | `{"host_success":false,"host_attempted":null,"delivery_or_claim":"pending","live":"not_run"}` |
| H6 | 原笔记临时meta守卫 | `"whitespace_transcript"` | `{"host_success":true,"host_attempted":true,"delivery_or_claim":"pending","live":"not_run"}` |
| H7 | 原笔记临时meta守卫 | `"failed_meta_write"` | `{"host_success":false,"host_attempted":null,"delivery_or_claim":"pending","live":"not_run"}` |
| H8 | 原笔记临时meta守卫 | `"already_attempted"` | `{"host_success":false,"host_attempted":true,"delivery_or_claim":"pending","live":"not_run"}` |
| S1 | 原范围/文本筛选 | `"project_scope"` | `{"host_expected_ids":["a"],"owner_or_access":"pending","live":"not_run"}` |
| S2 | 原范围/文本筛选 | `"other_project"` | `{"host_expected_ids":[],"owner_or_access":"pending","live":"not_run"}` |
| S3 | 原范围/文本筛选 | `"role_text_search"` | `{"host_expected_ids":["a"],"owner_or_access":"pending","live":"not_run"}` |
| S4 | 原范围/文本筛选 | `"role_not_identity"` | `{"host_expected_ids":[],"owner_or_access":"pending","live":"not_run"}` |
| S5 | 原范围/文本筛选 | `"fixed_code_word"` | `{"host_expected_ids":["a"],"owner_or_access":"pending","live":"not_run"}` |
| S6 | 原范围/文本筛选 | `"explicit_empty_tasks"` | `{"host_expected_ids":[],"owner_or_access":"pending","live":"not_run"}` |
| R1 | 只读副本边界 | `"private_original"` | `{"rule":"Authorized original references stay in their approved private scope, no raw customer text in public.","status":"pending","live":"not_run"}` |
| R2 | 只读副本边界 | `"local_note"` | `{"rule":"Synthetic host reservation only; actual phone note/audio not accessed or deleted.","status":"pending","live":"not_run"}` |
| R3 | 只读副本边界 | `"clipboard_workspace_attachment"` | `{"rule":"Destination may save/sync/process separately; no remote delivery or ownership receipt.","status":"pending","live":"not_run"}` |
| R4 | 只读副本边界 | `"retention_access_backup"` | `{"rule":"Unknown rules remain unknown, no invented retention duration/anonymization/deletion guarantee.","status":"pending","live":"not_run"}` |

</div>

固定源边界: [RadarModel](https://github.com/alexlee2046/yihu-ios/blob/0ddfe9805389827229d74a7adbf0c83a168d94e3/Apps/Collie/CollieRadarModel.swift) · [VoiceNote](https://github.com/alexlee2046/yihu-ios/blob/0ddfe9805389827229d74a7adbf0c83a168d94e3/Apps/Collie/CollieVoiceNote.swift)


<h2 id="first-answer">写下责任角色不等于对方认领，保存文档也不等于正式归档</h2>

一呼提供语音文字、笔记和工作台交接，不由本文新增跨部门任务认领或归档系统。本清单用于已有人工纪要之后：区分建议由哪个角色负责、该角色是否通过已有流程确认、被批准的范围是什么，以及文档能存在哪里。草稿可见、对方收到、责任认领、批准与执行完成需要不同证据，不能用一个“已保存”概括。

## 与纪要字段和待办提取的分工

纪要字段指南处理事实/提案/未决项；多笔记指南处理跨记录冲突；这里不再提取新任务，而是检查**已经拟定的交接是否得到对应角色认可，以及副本归档条件是否清楚**。不得为了表格完整而填写真实姓名、推定负责人或自行设置部门权限。

## 人工认领与归档检查表

<div role="region" aria-label="跨部门认领与归档检查表，可左右滚动" tabindex="0">

| 检查维度 | 应有的已有依据 | 合成记录方式 | 缺失时怎样处理 |
| --- | --- | --- | --- |
| 建议角色 | 原文或既有流程提出的负责角色 | 建议角色A，尚未认领 | 保留“建议”，不自动分配 |
| 认领确认 | 对应角色在获准流程中的明确确认 | 确认依据未提供 | 不把抄送、消息已读或姓名出现当认领 |
| 批准范围 | 已确认的事项、约束及未批准部分 | 只准核对样例，不准执行 | 不扩展为采购、发信、变更或发布授权 |
| 未决问题 | 仍需哪个既有流程确认 | 角色与期限均待核 | 不补猜测负责人或日期 |
| 归档位置 | 团队已有且获准的文档位置与访问范围 | 位置未核，不上传 | 本地/工作台草稿不自动等于正式档案 |
| 保留规则 | 团队实际规则与引用，不编造保留时长 | 按已有规则，待维护者说明 | 不承诺永久保留、无备份或绝对删除 |
| 副本范围 | 原笔记、剪贴板、文档和工作台的实际副本 | 仅核本地样例，其余未知 | 不把删一份当撤回全部资料 |
| 交接阶段 | 草稿/暂存/已记录/不确定各自证据 | 草稿供核对，未发送 | 不把saved/queued当认领或完成 |

</div>

## 一个不安排真实工作的合成认领卡

```text
事项：示例纪要中的三个待核字段（非真实任务）
proposed_role：角色A，建议而非已分配
acknowledgment_evidence：未提供，不能标已认领
approved_scope：仅核样例文字；无执行授权
open_question：应由哪个已有流程确认认领？
archive_location：未核，不上传到新位置
retention_rule_reference：待团队按已有规则确认
handoff_state：本地草稿，未发送
```

这些字段是人工清单，不是App、Radar导入或签署API。页面不发送邀请、不更改权限、不创建共享文档，也不收集姓名/联系方式。正式确认应沿团队原有获准渠道处理，而不是把合成卡复制到真实台账来测试。

## 归档前的先后关系

1. 先核原文与纪要版本，避免把尚未修订的识别错误交给别人确认。
2. 区分“提议角色”和“已有认领确认”，只记录实际得到的依据，不推断未回应者同意。
3. 核被确认的内容范围与权限。角色认领核对文字不等于授权自动执行任务。
4. 再核已有归档位置、访问和保留规则；没有依据就停在获准本地草稿，不自行建账号、共享链接或公开附件。
5. 列出必要副本和不确定交接结果。已尝试过的笔记仍按原一次标记处理，归档流程不能被用来绕过重复交接。

如果需要Radar回复，仍须符合原事项资格、服务端写授权、手机确认和回执回读。服务记录了回复也不代表负责人已经完成事项，回复历史也不是通用文档档案库。

## FAQ

<h3 id="faq-owner">在纪要写上角色A就算已经认领吗？</h3>

不算。那只是一段文字或提议，需要对应角色通过已有获准流程明确确认；不能用抄送或未回应代替。

<h3 id="faq-feature">一呼是否提供部门任务分配或电子签署？</h3>

本页不声明或新增这些能力。清单用于人工核对，现有语音草稿和笔记交接不自动建立组织审批系统。

<h3 id="faq-archive">保存到工作台草稿就完成正式归档了吗？</h3>

不一定。正式位置、版本、访问范围与保留规则由团队已有流程定义，草稿保存本身不足以证明满足要求。

<h3 id="faq-consent">有人认领了核对动作，就可以执行全部提案吗？</h3>

不能。确认范围必须明确，核对、批准和执行授权是不同事实，未获准部分仍保持未决。

<h3 id="faq-retention">本文能给出统一删除或保留期限吗？</h3>

不能。各目的地、账户、备份和团队规则不同，应引用实际规则，不编造时长或删除保证。

<h3 id="faq-reply-history">Radar回复历史可以当完整跨部门档案库吗？</h3>

不可以据此推断。它是有独立权限和实现边界的原事项回复/反馈读取；不是任意文档、版本、签署或认领数据库。

## 相关指南与依据

[人工纪要字段](/guides/meeting-notes-brief-fields/) · [多笔记待办核对](/guides/multi-note-review-handoff/) · [噪声后人工修订](/guides/noisy-transcript-text-correction/) · [手机决策与回执](/guides/mobile-agent-decisions/) · [开始](/start/) · [隐私](/privacy/)

实现边界依据：[README回复与历史说明](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)、[笔记一次交接模型](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNote.swift)。认领卡和归档清单是本文人工建议，不冒充代码功能或合规认证。
