# SYN-DMO-44 · Department minutes ownership and archive / 部门纪要归属与归档

SYNTHETIC_EXAMPLE / pending / not_run for actual claim, approval, source disclosure and archives. Not an App import schema or actual customer meeting.

## 中文

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

## English

## SYN-DMO-44 · Department minutes ownership and minimal archive checks

SYNTHETIC_EXAMPLE / SYN-DMO-44. Real claims/archives remain pending / not_run. Manual ledger, not App import, automatic assignment or speaker recognition.

- 中文 JSON: [preflight.zh.json](https://getyihu.com/samples/p23-department-minutes-ownership-archive/preflight.zh.json) — https://getyihu.com/samples/p23-department-minutes-ownership-archive/preflight.zh.json
- English JSON: [preflight.en.json](https://getyihu.com/samples/p23-department-minutes-ownership-archive/preflight.en.json) — https://getyihu.com/samples/p23-department-minutes-ownership-archive/preflight.en.json
- Public bilingual check card: [README.md](https://getyihu.com/samples/p23-department-minutes-ownership-archive/README.md) — https://getyihu.com/samples/p23-department-minutes-ownership-archive/README.md

### Split proposed responsibilities manually, never silently claim them

S1/S2 and R1/R2 are hand-authored fictional speaker/role labels, not native diarization or accounts. C2 keeps U1/U2 proposal references in separate T1/T2 draft actions. proposed_role is not confirmed_owner. Every real confirmed owner, deadline, claim evidence, execution approval, archive location and retention reference remains null. C3 does not resolve ambiguous pronouns; C5 read/CC is not consent; C6 wording review does not authorize purchasing, sending, changes or release; C7 preserves conflicting versions instead of choosing an owner. pending/not_run describe the real workflow; separately passed host checks do not hide behind those labels.

### Original source guards do not establish ownership or formal archives

Source filter examples check data scope/text only: project is not a department ACL, session/next role text or fixed Alex is not login/owner identity, an empty list is not no responsible person. safeEvidenceURLs rejects some malformed shapes and deduplicates, but keeps allowed HTTPS query/fragment content (E9). HTTPS is not publication permission, redaction, trust or access authorization.

Original VoiceNote.reserveHandOff runs only on synthetic owned temporary metadata. done/nonempty/not-attempted gates an atomic marker reservation, not delivery, acceptance or archive completion. Failed metadata write preserves the original; an archive copy cannot reset an attempted marker. Whitespace-only nonempty text can pass this guard, not evidence of useful minutes or automatic repair. Real phone notes, Store.handOff, AppGroup/clipboard/workspace and network are not called.

### Disclosure, access and retention use existing approved processes

All public content is entirely synthetic, not renamed private customer material. Keep authorized original references private; verify archive purpose, approved readers/location/version, necessary copies and actual retention rules. Unknown stops at an approved draft, not a new account/share link/upload. Local deletion is not recall of attachments, workspace, sync or backups. No universal retention period, guaranteed deletion, compliance certification or CRM archive. 40 rows =12external manual+10URL+8meta+6filter+4copy boundaries; only24/language are original-source host execution, never actual acknowledgment or an App ownership engine.

<div role="region" aria-label="SYN-DMO-44 manual claim, source guards and copy scope, horizontally scrollable" tabindex="0">

| ID | Separate scope | Synthetic input/manual split | Host expectation or manual boundary |
| --- | --- | --- | --- |
| C1 | External human claim/archive ledger | `{"mode":"proposal_not_claim","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Explicit acknowledgment missing; proposal is not assignment.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C2 | External human claim/archive ledger | `{"mode":"split_atomic_responsibilities","speakers":["S1","S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":"R1","confirmed_owner":null,"deadline":null},{"draft_id":"T2","speech_refs":["U2"],"proposed_role":"R2","confirmed_owner":null,"deadline":null}]}` | `{"rule":"Keep separate draft actions/evidence references, no inferred joint owner.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C3 | External human claim/archive ledger | `{"mode":"ambiguous_pronoun","speakers":["S1","S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Leave proposed/confirmed owner and deadline null; ask existing authorized process.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C4 | External human claim/archive ledger | `{"mode":"quoted_role_not_consent","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"A role quoted in speech is not the role accepting responsibility.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C5 | External human claim/archive ledger | `{"mode":"read_receipt_not_ack","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"A synthetic read receipt or CC never establishes claim/approval.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C6 | External human claim/archive ledger | `{"mode":"review_scope_not_execution","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Text-review-only scope does not authorize purchase, sending, changes or release.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C7 | External human claim/archive ledger | `{"mode":"conflicting_versions","speakers":["S1","S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Preserve both synthetic references, do not pick a winner or overwrite source.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C8 | External human claim/archive ledger | `{"mode":"unconfirmed_owner_stays_empty","speakers":["S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"No auto owner/deadline inferred from session/title/next or placeholder.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C9 | External human claim/archive ledger | `{"mode":"archive_location_unknown","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"No new account, shared location or upload; existing access/retention must be verified.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C10 | External human claim/archive ledger | `{"mode":"copies_not_recalled","speakers":["S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Local note deletion is not deletion of clipboard, workspace, attachments, sync or backups.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C11 | External human claim/archive ledger | `{"mode":"public_synthetic_not_redaction","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Entire public example is synthetic; HTTPS parsing is not redaction/publication permission.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C12 | External human claim/archive ledger | `{"mode":"uncertain_handoff_no_resend","speakers":["S1","S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Check approved destination through existing process; never reset once-attempted marker for an archive copy.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| E1 | Original evidence URL parser | `null` | `{"host_expected_URLs":[],"disclosure_permission":"pending","live":"not_run"}` |
| E2 | Original evidence URL parser | `""` | `{"host_expected_URLs":[],"disclosure_permission":"pending","live":"not_run"}` |
| E3 | Original evidence URL parser | `"https://example.invalid/evidence/sample"` | `{"host_expected_URLs":["https://example.invalid/evidence/sample"],"disclosure_permission":"pending","live":"not_run"}` |
| E4 | Original evidence URL parser | `"(https://example.invalid/evidence/sample)"` | `{"host_expected_URLs":["https://example.invalid/evidence/sample"],"disclosure_permission":"pending","live":"not_run"}` |
| E5 | Original evidence URL parser | `"https://example.invalid/evidence/sample;https://example.invalid/evidence/sample"` | `{"host_expected_URLs":["https://example.invalid/evidence/sample"],"disclosure_permission":"pending","live":"not_run"}` |
| E6 | Original evidence URL parser | `"http://example.invalid/evidence/sample"` | `{"host_expected_URLs":[],"disclosure_permission":"pending","live":"not_run"}` |
| E7 | Original evidence URL parser | `"https://role@example.invalid/evidence/sample"` | `{"host_expected_URLs":[],"disclosure_permission":"pending","live":"not_run"}` |
| E8 | Original evidence URL parser | `"https://example.invalid:0/sample"` | `{"host_expected_URLs":[],"disclosure_permission":"pending","live":"not_run"}` |
| E9 | Original evidence URL parser | `"https://example.invalid/evidence/sample?ref=SYN-DMO-44#mock"` | `{"host_expected_URLs":["https://example.invalid/evidence/sample?ref=SYN-DMO-44#mock"],"disclosure_permission":"pending","live":"not_run"}` |
| E10 | Original evidence URL parser | `"https://example.invalid/evidence/sample,https://example.invalid/evidence/other"` | `{"host_expected_URLs":["https://example.invalid/evidence/sample","https://example.invalid/evidence/other"],"disclosure_permission":"pending","live":"not_run"}` |
| H1 | Original owned-meta reservation guard | `"done_text"` | `{"host_success":true,"host_attempted":true,"delivery_or_claim":"pending","live":"not_run"}` |
| H2 | Original owned-meta reservation guard | `"repeat_after_reserve"` | `{"host_success":true,"host_attempted":true,"delivery_or_claim":"pending","live":"not_run"}` |
| H3 | Original owned-meta reservation guard | `"explicit_false"` | `{"host_success":true,"host_attempted":true,"delivery_or_claim":"pending","live":"not_run"}` |
| H4 | Original owned-meta reservation guard | `"pending_status"` | `{"host_success":false,"host_attempted":null,"delivery_or_claim":"pending","live":"not_run"}` |
| H5 | Original owned-meta reservation guard | `"empty_transcript"` | `{"host_success":false,"host_attempted":null,"delivery_or_claim":"pending","live":"not_run"}` |
| H6 | Original owned-meta reservation guard | `"whitespace_transcript"` | `{"host_success":true,"host_attempted":true,"delivery_or_claim":"pending","live":"not_run"}` |
| H7 | Original owned-meta reservation guard | `"failed_meta_write"` | `{"host_success":false,"host_attempted":null,"delivery_or_claim":"pending","live":"not_run"}` |
| H8 | Original owned-meta reservation guard | `"already_attempted"` | `{"host_success":false,"host_attempted":true,"delivery_or_claim":"pending","live":"not_run"}` |
| S1 | Original scope/text filter | `"project_scope"` | `{"host_expected_ids":["a"],"owner_or_access":"pending","live":"not_run"}` |
| S2 | Original scope/text filter | `"other_project"` | `{"host_expected_ids":[],"owner_or_access":"pending","live":"not_run"}` |
| S3 | Original scope/text filter | `"role_text_search"` | `{"host_expected_ids":["a"],"owner_or_access":"pending","live":"not_run"}` |
| S4 | Original scope/text filter | `"role_not_identity"` | `{"host_expected_ids":[],"owner_or_access":"pending","live":"not_run"}` |
| S5 | Original scope/text filter | `"fixed_code_word"` | `{"host_expected_ids":["a"],"owner_or_access":"pending","live":"not_run"}` |
| S6 | Original scope/text filter | `"explicit_empty_tasks"` | `{"host_expected_ids":[],"owner_or_access":"pending","live":"not_run"}` |
| R1 | Read-only copy boundary | `"private_original"` | `{"rule":"Authorized original references stay in their approved private scope, no raw customer text in public.","status":"pending","live":"not_run"}` |
| R2 | Read-only copy boundary | `"local_note"` | `{"rule":"Synthetic host reservation only; actual phone note/audio not accessed or deleted.","status":"pending","live":"not_run"}` |
| R3 | Read-only copy boundary | `"clipboard_workspace_attachment"` | `{"rule":"Destination may save/sync/process separately; no remote delivery or ownership receipt.","status":"pending","live":"not_run"}` |
| R4 | Read-only copy boundary | `"retention_access_backup"` | `{"rule":"Unknown rules remain unknown, no invented retention duration/anonymization/deletion guarantee.","status":"pending","live":"not_run"}` |

</div>

Pinned source boundaries: [RadarModel](https://github.com/alexlee2046/yihu-ios/blob/0ddfe9805389827229d74a7adbf0c83a168d94e3/Apps/Collie/CollieRadarModel.swift) · [VoiceNote](https://github.com/alexlee2046/yihu-ios/blob/0ddfe9805389827229d74a7adbf0c83a168d94e3/Apps/Collie/CollieVoiceNote.swift)


## Execution boundary / 执行边界

Original complete RadarModel/VoiceNote source compiles verbatim once. Reservation atomically writes only synthetic metadata in a newly owned temporary root removed on exit; no actual note store/Keychain/UserDefaults/AppGroup/UI/account/network. External manual ledger does not perform NLP, diarization, assignment, acceptance, access control, archive or redaction. Public README.md is byte-identical to this card; root internal README.md is not published.
