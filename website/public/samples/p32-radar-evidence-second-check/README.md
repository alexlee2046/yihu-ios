# SYN-ESC-53 · 异常证据二次核实与最小披露 / Second-check claims and minimal disclosure

SYNTHETIC_EXAMPLE · pending · not_run。全部从零合成，非真实异常警报、内容真伪、脱敏审查、人工批准、远端执行或送达回执。 / Synthetic from scratch, not a verified alert, factual truth, redaction review, human approval, remote execution or delivery receipt.

[中文 JSON](/samples/p32-radar-evidence-second-check/preflight.zh.json) · [English JSON](/samples/p32-radar-evidence-second-check/preflight.en.json)

JSON为合成核对配方，不是App导入schema。先分证据链接形态、展示分类、人工确认结构与只读遥测，再谈下一步；HTTPS候选不自动脱敏，P0或紧急字样不授执行权。 / JSON contains synthetic test recipes, not an app import schema. Separate link shape, display classification, human confirmation structure and read-only telemetry before acting; HTTPS candidates are not auto-redacted and P0/urgent wording grants no execution authority.

<div role="region" aria-label="异常证据二次核实合成表 / Synthetic second-check review" tabindex="0">

| ID | 检查 / Check | 合成预期 / Synthetic expectation |
| --- | --- | --- |
| E01 | 紧急P0标题单HTTPS / Urgent P0 title with single HTTPS | urls=1; attention=false; state=progressing |
| E02 | 包裹符去重与待验收命中 / Wrapped deduplication and acceptance attention | urls=2; attention=true; state=waiting |
| E03 | 查询与片段原样保留未脱敏 / Query and fragment retained without redaction | urls=1; attention=false; state=waiting |
| E04 | next固定字样命中非审批 / Fixed next literal matches without approval | urls=0; attention=true; state=planned |
| E05 | 明文HTTP候选拒绝 / Plain HTTP candidate rejected | urls=1; attention=false; state=blocked |
| E06 | 内嵌凭据候选拒绝 / Embedded userinfo candidate rejected | urls=1; attention=false; state=completed |
| E07 | 越界端口拒绝与有效端口保留 / Out-of-range ports rejected while valid port kept | urls=1; attention=false; state=paused |
| E08 | 未知状态别名与纯文字无链接 / Unknown status alias and prose without link | urls=0; attention=false; state=unknown |
| A01 | colab.run带预算且未过期 / colab.run with budget and current | valid=true; current=true; budget_null=false |
| A02 | release.promote四十位指纹且budget显式null / release.promote 40-hex with explicit null budget | valid=true; current=true; budget_null=true |
| A03 | colab.recover结构有效但到达过期点 / colab.recover structurally valid but expired at now | valid=true; current=false; budget_null=true |
| A04 | colab.run缺预算拒绝 / colab.run missing budget rejected | valid=false; current=false; budget_null=true |
| A05 | colab.resume单次预算超总预算拒绝 / colab.resume session budget exceeding total rejected | valid=false; current=false; budget_null=false |
| A06 | release.promote携带预算拒绝 / release.promote with non-null budget rejected | valid=false; current=false; budget_null=false |
| A07 | release.promote指纹长度不符拒绝 / release.promote wrong fingerprint length rejected | valid=false; current=false; budget_null=true |
| A08 | 未知操作枚举拒绝 / Unsupported operation enum rejected | valid=false; current=false; budget_null=true |
| C01 | sampled遥测与实验执行结构通过 / Sampled telemetry with valid experiment and execution | colab_valid=true; snapshot_decode=true |
| C02 | not_requested且空指标通过 / not_requested with null usage metrics passes | colab_valid=true; snapshot_decode=true |
| C03 | unavailable携带残留balance拒绝 / unavailable usage with non-null balance rejected | colab_valid=false; snapshot_decode=false |
| C04 | usage观测时间超快照300秒拒绝 / Usage observed_at exceeding snapshot by >300s rejected | colab_valid=false; snapshot_decode=false |
| C05 | 实验完成数超总数拒绝 / Experiment completed_queries exceeding total rejected | colab_valid=false; snapshot_decode=false |
| C06 | 重复实验指纹ID拒绝 / Duplicate experiment fingerprint IDs rejected | colab_valid=false; snapshot_decode=false |
| C07 | 执行request_id非UUID拒绝 / Execution non-UUID request_id rejected | colab_valid=false; snapshot_decode=false |
| C08 | 执行operation越界拒绝 / Execution unsupported operation rejected | colab_valid=false; snapshot_decode=false |
| M01 | 二次核实先分五阶段 / Separate five verification stages | 证据已读、主张核实、操作批准、回复记录与事情处理完各自留证；卡片标P0或写紧急不授执行权。 / Evidence read, claim verified, operation approved, reply recorded and work handled require separate evidence; P0 or urgent text grants no execution authority. |
| M02 | HTTPS解析不是脱敏或真伪证明 / HTTPS parsing is neither redaction nor truth proof | safeEvidenceURLs只筛HTTPS形态并去重，原样保留query/fragment参数；不验证站点信誉、内容真伪或公开披露权限。 / safeEvidenceURLs checks HTTPS shape and deduplicates while retaining query/fragment parameters; it verifies neither site trust, truth nor public disclosure authority. |
| M03 | 分类与attention不改源值 / Classification and attention never rewrite source values | CollieRadarTaskState与requiresMyAttention仅为展示派生，原status/priority/evidence字节保留；不自动消解字段矛盾。 / CollieRadarTaskState and requiresMyAttention are derived display logic preserving raw status/priority/evidence bytes; they never auto-resolve conflicting claims. |
| M04 | 授权记录不是执行凭据或已跑完 / Authorization record is neither provider token nor execution proof | CollieRadarAuthorization仅核人工确认结构、预算上界与过期时间；recorded或current=true不证明远端已执行。 / CollieRadarAuthorization checks human confirmation structure, budget bounds and expiry only; recorded or current=true proves no remote execution. |
| M05 | 只读遥测非风险引擎或自动处置 / Read-only telemetry is not a risk engine or auto-remediation | CollieColabSnapshot仅校验生产者只读遥测与实验/执行字段边界，不新增外贸异常检测器、风险打分或自动发信回写。 / CollieColabSnapshot validates read-only producer telemetry and experiment/execution bounds only, adding no trade anomaly detector, risk score or automatic writeback. |
| M06 | 最小披露与不确定停止 / Minimal disclosure and stopping under uncertainty | 全部示例从零合成且仅用example.invalid，不抓链接、不收集客户原件；私有证据留原获准范围，结果不明先查回不盲重发。 / All examples are synthetic from scratch using example.invalid only, with no link fetching or customer capture; keep private originals scoped and check back without blind resend. |

</div>

## 原模型宿主与真实业务分账 / Original host versus live operations

24例/语：8例原Action `safeEvidenceURLs`/`requiresMyAttention`/`CollieRadarTaskState.classify`、8例原`CollieRadarAuthorization`结构/预算/`current(at:)`与显式null编码、8例原`CollieColabSnapshot.valid(at:)`与`CollieRadarSnapshot.decode`联动门。整原`CollieRadarModel.swift`单次编译，原方法不改，在`TZ=UTC`与`TZ=America/Los_Angeles`双环境下对每语24例运行且输出逐字节一致。 / 24 cases per language: 8 original Action `safeEvidenceURLs`/`requiresMyAttention`/`CollieRadarTaskState.classify`, 8 original `CollieRadarAuthorization` structure/budget/`current(at:)` and explicit null encoding, 8 original `CollieColabSnapshot.valid(at:)` and `CollieRadarSnapshot.decode` gates. The whole unmodified `CollieRadarModel.swift` compiles once and runs in `TZ=UTC` and `TZ=America/Los_Angeles` with byte-identical results per language.

E03证明`safeEvidenceURLs`原样保留查询参数与fragment而不自动脱敏；A02/A03证明无预算操作在线路JSON中显式编码`"budget":null`且过期边界`expires_at<=now`使`current(at:)`为false；C03/C04/C05/C06/C07/C08证明无效只读遥测被原`Snapshot.decode`拒绝。 / E03 proves `safeEvidenceURLs` retains query/fragment parameters without auto-redaction; A02/A03 prove budgetless operations encode explicit `"budget":null` while `expires_at<=now` makes `current(at:)` false; C03-C08 prove invalid read-only telemetry is rejected by original `Snapshot.decode`.

6人工边界不算运行例。真实来源、外部站点、账号权限、脱敏审查、人工审批、原生prepare/submit/check、Watch与网络全not_run。保原件、矛盾与缺口，不把样例写进生产台账，不在结果不明时换ID盲重发，不承诺全副本撤回或自动脱敏。 / Six manual boundaries are not executions. Real feeds, external sites, account permissions, redaction reviews, approvals, native prepare/submit/check, Watch and network remain not_run. Preserve originals, conflicts and gaps; never write synthetic examples into live ledgers, resend with a new ID under uncertainty, or claim universal recall/automatic redaction.

Source: https://github.com/alexlee2046/yihu-ios/blob/402a7f828c47d41c8ebebf9f06f1f4615d5e3ddd/Apps/Collie/CollieRadarModel.swift

[中文指南](/guides/radar-evidence-second-check/) · [English guide](/en/guides/radar-evidence-second-check/)
