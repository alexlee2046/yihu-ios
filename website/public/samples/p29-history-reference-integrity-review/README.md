# SYN-HRI-50 · 历史引用完整性 / History reference integrity

SYNTHETIC_EXAMPLE · pending · not_run。全部从零合成，非真实历史、身份、权限、已读、审批或远端完成回执。 / Synthetic from scratch, not real history, identity, authority, reading, approval or remote completion receipts.

[中文 JSON](/samples/p29-history-reference-integrity-review/preflight.zh.json) · [English JSON](/samples/p29-history-reference-integrity-review/preflight.en.json)

结构通过不等已处理。原feedback只关联更晚位置的update，且须明确引用request UUID或非draft回复URL；正文说“已看”不能替代references。 / Valid structure is not handled status. Original feedback associates later updates only through explicit request UUID/non-draft reply URL references; seen prose cannot replace references.

<div role="region" aria-label="历史引用合成核对 / Synthetic history reference review" tabindex="0">

| ID | 检查 / Check | 合成预期 / Synthetic expectation |
| --- | --- | --- |
| H01 | UUID明确引用 / Explicit UUID reference | validate=true; feedback=1 associated update(s) |
| H02 | 评论URL明确引用 / Explicit comment URL reference | validate=true; feedback=1 associated update(s) |
| H03 | 仅说已看不关联 / Seen prose alone is not association | validate=true; feedback=0 associated update(s) |
| H04 | 引用其他请求 / Reference another request | validate=true; feedback=0 associated update(s) |
| H05 | 较早update不关联 / Earlier update is not feedback | validate=true; feedback=0 associated update(s) |
| H06 | draft UUID关联 / Draft UUID association | validate=true; feedback=1 associated update(s) |
| H07 | draft拒绝评论引用 / Draft rejects comment reference | validate=false; feedback=not_run |
| H08 | draft拒绝正式时间 / Draft rejects formal timestamp | validate=false; feedback=not_run |
| H09 | draft URL不完全相同 / Draft URL not identical | validate=false; feedback=not_run |
| H10 | 目标ID不符 / Target ID mismatch | validate=false; feedback=not_run |
| H11 | 重复entry ID / Duplicate entry ID | validate=false; feedback=not_run |
| H12 | 已加载ID冲突 / Previously loaded ID collision | validate=false; feedback=not_run |
| H13 | kind越界 / Unsupported kind | validate=false; feedback=not_run |
| H14 | reply UUID无效 / Invalid reply UUID | validate=false; feedback=not_run |
| H15 | 引用UUID非规范小写 / Reference UUID not canonical lowercase | validate=false; feedback=not_run |
| H16 | 重复reference / Duplicate reference | validate=false; feedback=not_run |
| H17 | 跨任务评论引用 / Cross-task comment reference | validate=false; feedback=not_run |
| H18 | entry host不符 / Entry host mismatch | validate=false; feedback=not_run |
| H19 | 显式端口组件不同 / Explicit port differs | validate=false; feedback=not_run |
| H20 | entry path不符 / Entry path mismatch | validate=false; feedback=not_run |
| H21 | entry query不符 / Entry query mismatch | validate=false; feedback=not_run |
| H22 | position次序错误 / Wrong position order | validate=false; feedback=not_run |
| H23 | 未完页缺cursor / Missing cursor on incomplete page | validate=false; feedback=not_run |
| H24 | 5条页保未读缺口 / Five-entry page retains remaining gap | validate=true; feedback=4 associated update(s) |
| M01 | 关联不等已读/处理 / Association is not read/handled | 结构通过/明确references只给原关联，不授身份、审批、真实性或业务完成。 / Valid structure/explicit references establish association only, not identity, approval, truth or completion. |
| M02 | Web重载不等历史读成 / Web reload is not successful history read | spinner、取消过滤或reload不是原生历史已加载/当前目标完整/服务动作完成的证据。 / Spinner, cancellation filtering or reload do not prove native history loaded, current-target completeness or service completion. |
| M03 | 不同取消路径不互代 / Cancellation paths are distinct | 网页导航取消与原生历史generation/请求回执不同；不把旧结果或迟到正文自动拼入新目标，不以取消抹回执。 / Web navigation cancellation differs from native history generation/request receipts; never merge stale text into a new target or erase receipts on cancel. |
| M04 | 调度非恢复SLA / Scheduling is not recovery SLA | NSURLErrorDomain取消与WebKitErrorDomain/102按域代码合核，500ms复核和15秒防环不是恢复/未执行保证。 / Match cancellation domains/codes; WebKitErrorDomain/102, 500ms recheck and 15s loop guard are not recovery/non-execution guarantees. |
| M05 | 缺口不补造引用 / Never fabricate missing references | 保原目标、位置、引用与缺口，不从正文猜reference、不改时间/URL修出通过，不跨账户建索引。 / Preserve target, positions, references and gaps; no guessed references, rewritten timestamps/URLs or cross-account index. |
| M06 | 最小披露与停止 / Minimal disclosure and stopping | 全部合成不访问链接；真实授权、已读、处理与远端回执未知即停，目的地可保存同步，不盲重放。 / All synthetic, no link fetch; stop when real authority/read/handled/remote receipts are unknown. Destinations may save/sync; no blind replay. |

</div>

## 原函数与真实运行分账 / Original functions versus live runtime

24例/语编译原CollieRadarModel.swift整文件，使用真实Foundation/CoreFoundation/Observation，JSONDecoder读合成完整history，调用原validate；仅validate通过后调用原feedback。失败不执行关联，expected_feedback_ids为null。原JSON输入、caller target/loaded/existingIDs、固定now=10000和完整反馈ID预期均在JSON。 / 24 cases per language compile the whole original CollieRadarModel.swift with real Foundation/CoreFoundation/Observation. JSONDecoder reads synthetic complete histories; original validate runs before original feedback. Rejected histories never run association and expected_feedback_ids remains null. Inputs/caller target/loaded/existingIDs/fixed now=10000/full expected IDs are in JSON.

固定epoch时间、SYN ID、UUID与example.invalid仅为合成测试，不表示真实创建时间、合法用户、评论或授权；不访问链接、不读存储、不创建历史数据库。仅本机内存结构宿主，真实读取/JSON响应传输/UI/分页请求/导航重载/账户/网络均not_run。 / Fixed epoch timestamps, SYN IDs, UUIDs and example.invalid are synthetic, not actual creation times, users/comments or authority. No fetch/storage/history database. Host checks are in-memory only; real reads/transport/UI/paging requests/reloads/accounts/network remain not_run.

六项人工边界不混算运行例。保留原件和缺口，不伪造references、不手改真实历史消错、不补审批人、不把结构校验当安全扫描或不可篡改日志。Web导航取消不能代替原生历史generation与已记录回执。目的地可保存同步处理，未知副作用不盲重试，不称全副本撤回或全数据不离机。 / Six manual boundaries are not executions. Preserve originals/gaps, never fabricate references, alter real history to hide errors, invent approvers or call validation a security scan/immutable log. Web cancellation does not replace native-history generation or recorded receipts. Destinations may save/sync/process; no blind retry under uncertainty, universal recall or all-on-device claim.

Source: https://github.com/alexlee2046/yihu-ios/blob/3f5a931472f2397cba5c2ee043dd9a16957fdda3/Apps/Collie/CollieRadarModel.swift

[中文指南](/guides/history-reference-integrity-review/) · [English guide](/en/guides/history-reference-integrity-review/)
