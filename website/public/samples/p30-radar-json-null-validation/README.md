# SYN-RJN-51 · Radar JSON类型与null / Radar JSON types and nulls

SYNTHETIC_EXAMPLE · pending · not_run。全部从零合成，非真实台账/完整性、用户身份、审批、写授权或远端回执。 / Synthetic from scratch, not a real/complete ledger, user identity, approval, write authority or remote receipt.

[中文 JSON](/samples/p30-radar-json-null-validation/preflight.zh.json) · [English JSON](/samples/p30-radar-json-null-validation/preflight.en.json)

缺失、null、空字符串、[]与错类型分账。tasks缺失/null回退decisions；[]不回退。派生attention、reply_supported=true与可见卡片都不授真实写权。 / Missing, null, empty strings, [] and wrong types differ. Missing/null tasks fall back to decisions; [] does not. Derived attention, reply_supported=true and visible cards do not grant real writes.

<div role="region" aria-label="JSON合成核对 / Synthetic JSON review" tabindex="0">

| ID | 检查 / Check | 预期 / Expectation |
| --- | --- | --- |
| J01 | tasks缺失回退 / Missing tasks falls back | decode=true; allTasks=1; attention=0; visible=0 |
| J02 | tasks null回退 / Null tasks falls back | decode=true; allTasks=1; attention=0; visible=0 |
| J03 | 空tasks不回退 / Empty tasks does not fall back | decode=true; allTasks=0; attention=0; visible=0 |
| J04 | 显式tasks覆盖回退 / Explicit tasks replaces fallback | decode=true; allTasks=1; attention=0; visible=0 |
| J05 | 可选null保未知 / Optional null stays unknown | decode=true; allTasks=1; attention=0; visible=0 |
| J06 | true和attention非写权 / True and attention are not authority | decode=true; allTasks=1; attention=1; visible=1 |
| J07 | next固定字样命中 / Fixed next literal matches | decode=true; allTasks=1; attention=1; visible=1 |
| J08 | 标题字样不代next / Title literal is not next | decode=true; allTasks=1; attention=0; visible=0 |
| J09 | 未知键不补契约 / Unknown key does not grant contract | decode=true; allTasks=1; attention=0; visible=0 |
| J10 | 必需数组显式空 / Explicit empty required arrays | decode=true; allTasks=0; attention=0; visible=0 |
| J11 | 项目过滤仍可排除 / Project filter may exclude | decode=true; allTasks=1; attention=1; visible=0 |
| J12 | 状态过滤仍可排除 / Status filter may exclude | decode=true; allTasks=1; attention=1; visible=0 |
| J13 | 必需日期缺失 / Required date missing | decode=false; views not_run |
| J14 | 必需数组null / Required array null | decode=false; views not_run |
| J15 | projects不能补active / projects cannot replace active | decode=false; views not_run |
| J16 | 必需title null / Required title null | decode=false; views not_run |
| J17 | 可选数字错类型 / Wrong optional numeric type | decode=false; views not_run |
| J18 | 字符串true非Bool / String true is not Bool | decode=false; views not_run |
| J19 | 空白project / Blank project | decode=false; views not_run |
| J20 | 空白title / Blank title | decode=false; views not_run |
| J21 | 无效来源日期 / Invalid source date | decode=false; views not_run |
| J22 | tasks非空ID重复 / Duplicate supplied task IDs | decode=false; views not_run |
| J23 | 项目时间越界 / Project timestamp out of range | decode=false; views not_run |
| J24 | 2MiB加1超限 / 2MiB plus one byte | decode=false; views not_run |
| M01 | 四层验收分账 / Four separate acceptance layers | JSON语法、模型类型、decode后校验、业务来源/权限各自留证；true可解码不等可写。 / Separate JSON syntax, model types, post-decode validation and business source/authority; decoded true is not write authority. |
| M02 | 缺失null空集合不同 / Missing null and empty differ | tasks缺失/null只兼容回退decisions，[]不回退；任一空列表都不证明全台账已清空。 / Missing/null tasks fall back to decisions for compatibility; [] does not. Empty views never prove the whole ledger cleared. |
| M03 | attention非账户 / Attention is not account identity | 状态trim或next固定Alex仅为源码派生条件；不读当前登录者，不改原status，不自动认领/审批。 / Trimmed status/fixed Alex in next are derived source conditions, not signed-in identity, raw-status edits, ownership or approval. |
| M04 | 多重过滤与能力分开 / Filters and capability are separate | onlyMentioningMe使用allTasks，项目/状态仍可排除；reply_supported、匹配与真实prepare/目标/账户写权分账。 / onlyMentioningMe uses allTasks; project/status can still exclude. reply_supported and matching do not replace prepare/target/account authority. |
| M05 | 不修出通过 / Do not manufacture acceptance | 不补当前时间、把null改0/false、复制旧记录改日期或伪造ID以消错；不转换纪要/抓线索或新建外贸源。 / No invented current times, null-to-zero/false fills, relabeled stale records or fabricated IDs; no minutes converter, lead scraping or new trade feed. |
| M06 | 最小披露与停止 / Minimal disclosure and stopping | 仅合成不读顾客正文或请求链接，保原件/缺口/既有一次标记；目标可保存同步，未知不盲重放。 / Synthetic only, no customer text/link fetch. Preserve originals/gaps/reservations; destinations may save/sync, no blind replay when unknown. |

</div>

## 宿主与真实运行分账 / Host versus live runtime

24例/语对原CollieRadarModel.swift整文件编译，原decode通过后才调用allTasks/requiresMyAttention/matchingActions，核原status字节与可选Bool未改写；拒绝后view预期为null、不执行派生筛选。Foundation/CoreFoundation/Observation真实，12通过+12按预期拒绝；不改方法、不用假解码器。完整JSON、原始类型和预期列表在双JSON。 / 24 cases per language compile the whole original CollieRadarModel.swift. Only original decode acceptance permits allTasks/requiresMyAttention/matchingActions checks, preserving raw status bytes and optional Bool; rejected cases keep view expectations null and do not execute derived filtering. Real Foundation/CoreFoundation/Observation,12 accepted+12 expected rejections, no modified methods/fake decoder. Full JSON/types/expected lists are in both fixtures.

六人工边界不算运行例。固定来源日期不是新鲜度或最新源证明；Alex仅固定公开代码字样，不是真实顾客/账户。实际源、存储、UserDefaults/Keychain/单例、SwiftUI、prepare/回复、Watch、设备与网络全not_run。 / Six manual boundaries are not executions. Fixed source dates prove no freshness/latest read; Alex is a fixed public code literal, not a real customer/account. Real feeds, storage, UserDefaults/Keychain/singletons, SwiftUI, prepare/replies, Watch/device/network remain not_run.

不补造来源时间/ID、把未知改false、凭空列表报全部完成、改姓名状态绕写门或重发。保原件/缺口/已有标记，目标可保存同步处理，未知即停；不宣称全数据不离机、全副本撤回/删除或合规认证。 / No invented timestamps/IDs, unknown-to-false fills, empty-view completion claims, renamed status/identity bypass or resend. Preserve originals/gaps/reservations; destinations may save/sync/process, stop when unknown; no all-on-device, universal recall/erasure or compliance claim.

Source: https://github.com/alexlee2046/yihu-ios/blob/0162ec5d7d98865b4b720d4a90f18287f955fc70/Apps/Collie/CollieRadarModel.swift

[中文指南](/guides/radar-json-null-validation/) · [English guide](/en/guides/radar-json-null-validation/)
