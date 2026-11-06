# SYN-EFD-43 / 空字段与显示默认值 · Empty-field display checks

## 中文

## SYN-EFD-43 · 空字段、占位和派生筛选只读自检

SYNTHETIC_EXAMPLE / SYN-EFD-43，只读自检，不是App导入协议或真实客户记录。44例/语只核原模型和显示表达式，不截图、不回填源、不发回复。

- 中文JSON：[preflight.zh.json](https://getyihu.com/samples/p22-empty-field-display-defaults/preflight.zh.json) — https://getyihu.com/samples/p22-empty-field-display-defaults/preflight.zh.json
- English JSON：[preflight.en.json](https://getyihu.com/samples/p22-empty-field-display-defaults/preflight.en.json) — https://getyihu.com/samples/p22-empty-field-display-defaults/preflight.en.json
- 双语自检卡：[preflight-card.md](https://getyihu.com/samples/p22-empty-field-display-defaults/preflight-card.md) — https://getyihu.com/samples/p22-empty-field-display-defaults/preflight-card.md

### 先分清源值、显示、排序与权限

`status`与任务卡片`next`只在判断空白时trim，返回非空文本仍保留原文；priority/session/window_status/evidence只判`isEmpty`，空格可能原样显示。接续详情的`next.isEmpty`又不同于任务卡片。null证据与字面“待补”可显示相同，但原值不同；这里记录源码中文文案key，不验证英语译文或SwiftUI像素。

P0/P1/P2的rank为0/1/2，其他为3，不把未知设成P2。启用最近修改排序时，同一rank只要有缺时间，原模型会保留该组原顺序；不是补0或当前时间后排序。`tasks: []`仍是空列表，不等`tasks: null/缺失`回退decisions；匹配后被项目/状态/搜索/历史排除，不等后台没有待办。

`reply_supported == true`只通过这一UI能力条件。原卡片精确匹配两个未trim的状态且id非nil；空id甚至非URL但非空source可通过所测UI谓词，不证明有效条目/来源或服务写权，不新增绕过。prepare、current-source、目标版本/eligible、文本、服务授权及发送结果另核且本轮not_run。派生attention会trim状态或在next用固定Alex做localizedStandardContains；不读当前账号，不扫描标题，不认领/授权。例A2可命中attention却不满足原始状态UI门；例A7已完成仍可命中getter，但默认历史过滤可再排除。

44宿主例=4显示+8attention+9回复门+9排序/筛选+14decode；另4条只读边界。缺标题/next等不能靠占位修复；JSON布尔类型门与上波APNs的NSNumber桥接不混用。所有源值保留，不创建默认值修复器/身份服务/原生reason API。

<div role="region" aria-label="SYN-EFD-43 空字段、能力位与派生筛选自检表，可左右滚动" tabindex="0">

| 编号 | 范围 | 合成输入/模式 | 宿主期望/只读边界 |
| --- | --- | --- | --- |
| F1 | 字段显示表达式 | `{"status":null,"priority":null,"next":"","session":null,"window_status":null,"evidence":null}` | `{"status":"任务状态未提供","priority":"优先级待补","card_next":"下一步待补","detail_next":"下一步待补","session":"待补","window_status":"未提供","evidence":"待补"}` |
| F2 | 字段显示表达式 | `{"status":" \n","priority":" ","next":" ","session":" ","window_status":" ","evidence":" "}` | `{"status":"任务状态未提供","priority":" ","card_next":"下一步待补","detail_next":" ","session":" ","window_status":" ","evidence":" "}` |
| F3 | 字段显示表达式 | `{"status":"待补","priority":"优先级待补","next":"下一步待补","session":"待补","window_status":"未提供","evidence":"待补"}` | `{"status":"待补","priority":"优先级待补","card_next":"下一步待补","detail_next":"下一步待补","session":"待补","window_status":"未提供","evidence":"待补"}` |
| F4 | 字段显示表达式 | `{"status":"进行中","priority":"","next":"SYNTHETIC_EXAMPLE: unknown owner/deadline","session":"","window_status":"","evidence":""}` | `{"status":"进行中","priority":"优先级待补","card_next":"SYNTHETIC_EXAMPLE: unknown owner/deadline","detail_next":"SYNTHETIC_EXAMPLE: unknown owner/deadline","session":"待补","window_status":"未提供","evidence":"待补"}` |
| A1 | 派生attention | `{"status":"等你决策","next":"","title":"synthetic"}` | `true` |
| A2 | 派生attention | `{"status":" 等你验收 \n","next":"","title":"synthetic"}` | `true` |
| A3 | 派生attention | `{"status":"进行中","next":"Alex please review","title":"synthetic"}` | `true` |
| A4 | 派生attention | `{"status":"进行中","next":"alex review","title":"synthetic"}` | `true` |
| A5 | 派生attention | `{"status":"进行中","next":"","title":"Alex in title only"}` | `false` |
| A6 | 派生attention | `{"status":null,"next":"","title":"synthetic"}` | `false` |
| A7 | 派生attention | `{"status":"已完成","next":"Alex","title":"synthetic"}` | `true` |
| A8 | 派生attention | `{"status":"进行中","next":"someone else","title":"synthetic"}` | `false` |
| G1 | UI回复门表达式 | `{"reply_supported":null,"status":"等你决策","item_id":"syn-id","source":"https://synthetic.invalid/radar.json"}` | `{"visible":true,"ui_enabled":false}` |
| G2 | UI回复门表达式 | `{"reply_supported":false,"status":"等你决策","item_id":"syn-id","source":"https://synthetic.invalid/radar.json"}` | `{"visible":true,"ui_enabled":false}` |
| G3 | UI回复门表达式 | `{"reply_supported":true,"status":"等你决策","item_id":"syn-id","source":"https://synthetic.invalid/radar.json"}` | `{"visible":true,"ui_enabled":true}` |
| G4 | UI回复门表达式 | `{"reply_supported":true,"status":"等你决策","item_id":"syn-id","source":""}` | `{"visible":true,"ui_enabled":false}` |
| G5 | UI回复门表达式 | `{"reply_supported":true,"status":" 等你决策 ","item_id":"syn-id","source":"https://synthetic.invalid/radar.json"}` | `{"visible":false,"ui_enabled":false}` |
| G6 | UI回复门表达式 | `{"reply_supported":true,"status":"等你决策","item_id":null,"source":"https://synthetic.invalid/radar.json"}` | `{"visible":false,"ui_enabled":false}` |
| G7 | UI回复门表达式 | `{"reply_supported":true,"status":"等你决策","item_id":"","source":"https://synthetic.invalid/radar.json"}` | `{"visible":true,"ui_enabled":true}` |
| G8 | UI回复门表达式 | `{"reply_supported":true,"status":"等你决策","item_id":"syn-id","source":"not a URL"}` | `{"visible":true,"ui_enabled":true}` |
| G9 | UI回复门表达式 | `{"reply_supported":true,"status":"等你决策","item_id":"syn-id","source":null}` | `{"visible":true,"ui_enabled":false}` |
| S1 | 排序/筛选 | `{"mode":"priority_rank"}` | `["zero","one","two","missing","unknown"]` |
| S2 | 排序/筛选 | `{"mode":"missing_time_stable"}` | `["older","missing","newer"]` |
| S3 | 排序/筛选 | `{"mode":"complete_time"}` | `["newer","older"]` |
| S4 | 排序/筛选 | `{"mode":"priority_off_missing_time"}` | `["older","missing","newer"]` |
| S5 | 排序/筛选 | `{"mode":"priority_exact"}` | `["exact"]` |
| S6 | 排序/筛选 | `{"mode":"attention_project_excludes"}` | `[]` |
| S7 | 排序/筛选 | `{"mode":"attention_alltasks"}` | `["waiting"]` |
| S8 | 排序/筛选 | `{"mode":"explicit_empty_tasks"}` | `[]` |
| S9 | 排序/筛选 | `{"mode":"legacy_fallback"}` | `["waiting"]` |
| D1 | 原始decode | `{"mode":"normal"}` | `true` |
| D2 | 原始decode | `{"mode":"missing_title"}` | `false` |
| D3 | 原始decode | `{"mode":"null_title"}` | `false` |
| D4 | 原始decode | `{"mode":"blank_title"}` | `false` |
| D5 | 原始decode | `{"mode":"missing_next"}` | `false` |
| D6 | 原始decode | `{"mode":"null_next"}` | `false` |
| D7 | 原始decode | `{"mode":"empty_next"}` | `true` |
| D8 | 原始decode | `{"mode":"missing_priority"}` | `true` |
| D9 | 原始decode | `{"mode":"null_priority"}` | `true` |
| D10 | 原始decode | `{"mode":"empty_priority"}` | `true` |
| D11 | 原始decode | `{"mode":"reply_number"}` | `false` |
| D12 | 原始decode | `{"mode":"reply_string"}` | `false` |
| D13 | 原始decode | `{"mode":"reply_null"}` | `true` |
| D14 | 原始decode | `{"mode":"duplicate_ids"}` | `false` |
| R1 | 只读人工边界 | `{"review":"占位标签不回填源/未知不等业务状态"}` | `"not_run"` |
| R2 | 只读人工边界 | `{"review":"rank兜底/缺时间稳定序不是赋默认P2或当前时间"}` | `"not_run"` |
| R3 | 只读人工边界 | `{"review":"UI回复能力位/显示不等prepare或服务写授权"}` | `"not_run"` |
| R4 | 只读人工边界 | `{"review":"attention是派生筛选非当前账号/负责人识别"}` | `"not_run"` |

</div>

固定源码: [Radar model](https://github.com/alexlee2046/yihu-ios/blob/521ca77e1cf5d827617ae8963c2fc4f6cc232b3f/Apps/Collie/CollieRadarModel.swift) · [UI expressions](https://github.com/alexlee2046/yihu-ios/blob/521ca77e1cf5d827617ae8963c2fc4f6cc232b3f/Apps/Collie/CollieRadarView.swift) · [reply follow-on boundaries](https://github.com/alexlee2046/yihu-ios/blob/521ca77e1cf5d827617ae8963c2fc4f6cc232b3f/Apps/Collie/CollieRadarReply.swift)

## English

## SYN-EFD-43 · Empty fields, placeholders and derived-filter checks

SYNTHETIC_EXAMPLE / SYN-EFD-43: read-only checks, not an App import schema or real customer records. 44 host cases per language test original model/display expressions, not UI pixels, backfill or replies.

- 中文 JSON: [preflight.zh.json](https://getyihu.com/samples/p22-empty-field-display-defaults/preflight.zh.json) — https://getyihu.com/samples/p22-empty-field-display-defaults/preflight.zh.json
- English JSON: [preflight.en.json](https://getyihu.com/samples/p22-empty-field-display-defaults/preflight.en.json) — https://getyihu.com/samples/p22-empty-field-display-defaults/preflight.en.json
- Bilingual card: [preflight-card.md](https://getyihu.com/samples/p22-empty-field-display-defaults/preflight-card.md) — https://getyihu.com/samples/p22-empty-field-display-defaults/preflight-card.md

### Source values, display, ordering and permission are different

Status and action-card next test trimmed emptiness but preserve nonempty original text. Priority/session/window_status/evidence only test isEmpty: whitespace can remain visible. The continuation detail next uses isEmpty instead of the card's trim predicate. Null evidence and literal 待补 can share a label but are different source values. Chinese source label keys are checked, not English localization or SwiftUI pixels.

P0/P1/P2 rank 0/1/2; all other priorities rank 3, never a source assignment to P2. With newest-first, a missing timestamp preserves original order across its rank group, not a fabricated zero/current time. Explicit tasks: [] remains empty; missing/null tasks can fall back to decisions. Project/status/search/history filters can hide attention hits without proving there are no tasks.

reply_supported == true satisfies only that UI capability condition. The card checks two exact untrimmed statuses and a non-nil id. Even an empty id or nonempty invalid-URL source can satisfy the tested UI predicates: this is not a valid target, source, prepare or server-write authorization, and no bypass is added. Current source, target version/eligible, text and service authorization/send remain separate and not_run. requiresMyAttention trims status or uses localizedStandardContains on next for fixed Alex, not current-login identity or title scanning. A2 can hit attention but fail raw-status button visibility; A7 can hit the getter while default history filtering excludes it.

44 host cases =4 display+8 attention+9 reply gate+9 ordering/filter+14 decode, plus4 read-only boundaries. Missing required title/next are not repaired by labels. JSON Bool decoding is not last wave's APNs NSNumber bridge. No source backfill, identity service or native reason API is added.

<div role="region" aria-label="SYN-EFD-43 field, capability and derived-filter checks, horizontally scrollable" tabindex="0">

| ID | Scope | Synthetic input/mode | Host expectation/read-only boundary |
| --- | --- | --- | --- |
| F1 | Field display expressions | `{"status":null,"priority":null,"next":"","session":null,"window_status":null,"evidence":null}` | `{"status":"任务状态未提供","priority":"优先级待补","card_next":"下一步待补","detail_next":"下一步待补","session":"待补","window_status":"未提供","evidence":"待补"}` |
| F2 | Field display expressions | `{"status":" \n","priority":" ","next":" ","session":" ","window_status":" ","evidence":" "}` | `{"status":"任务状态未提供","priority":" ","card_next":"下一步待补","detail_next":" ","session":" ","window_status":" ","evidence":" "}` |
| F3 | Field display expressions | `{"status":"待补","priority":"优先级待补","next":"下一步待补","session":"待补","window_status":"未提供","evidence":"待补"}` | `{"status":"待补","priority":"优先级待补","card_next":"下一步待补","detail_next":"下一步待补","session":"待补","window_status":"未提供","evidence":"待补"}` |
| F4 | Field display expressions | `{"status":"进行中","priority":"","next":"SYNTHETIC_EXAMPLE: unknown owner/deadline","session":"","window_status":"","evidence":""}` | `{"status":"进行中","priority":"优先级待补","card_next":"SYNTHETIC_EXAMPLE: unknown owner/deadline","detail_next":"SYNTHETIC_EXAMPLE: unknown owner/deadline","session":"待补","window_status":"未提供","evidence":"待补"}` |
| A1 | Derived attention | `{"status":"等你决策","next":"","title":"synthetic"}` | `true` |
| A2 | Derived attention | `{"status":" 等你验收 \n","next":"","title":"synthetic"}` | `true` |
| A3 | Derived attention | `{"status":"进行中","next":"Alex please review","title":"synthetic"}` | `true` |
| A4 | Derived attention | `{"status":"进行中","next":"alex review","title":"synthetic"}` | `true` |
| A5 | Derived attention | `{"status":"进行中","next":"","title":"Alex in title only"}` | `false` |
| A6 | Derived attention | `{"status":null,"next":"","title":"synthetic"}` | `false` |
| A7 | Derived attention | `{"status":"已完成","next":"Alex","title":"synthetic"}` | `true` |
| A8 | Derived attention | `{"status":"进行中","next":"someone else","title":"synthetic"}` | `false` |
| G1 | UI reply gate expressions | `{"reply_supported":null,"status":"等你决策","item_id":"syn-id","source":"https://synthetic.invalid/radar.json"}` | `{"visible":true,"ui_enabled":false}` |
| G2 | UI reply gate expressions | `{"reply_supported":false,"status":"等你决策","item_id":"syn-id","source":"https://synthetic.invalid/radar.json"}` | `{"visible":true,"ui_enabled":false}` |
| G3 | UI reply gate expressions | `{"reply_supported":true,"status":"等你决策","item_id":"syn-id","source":"https://synthetic.invalid/radar.json"}` | `{"visible":true,"ui_enabled":true}` |
| G4 | UI reply gate expressions | `{"reply_supported":true,"status":"等你决策","item_id":"syn-id","source":""}` | `{"visible":true,"ui_enabled":false}` |
| G5 | UI reply gate expressions | `{"reply_supported":true,"status":" 等你决策 ","item_id":"syn-id","source":"https://synthetic.invalid/radar.json"}` | `{"visible":false,"ui_enabled":false}` |
| G6 | UI reply gate expressions | `{"reply_supported":true,"status":"等你决策","item_id":null,"source":"https://synthetic.invalid/radar.json"}` | `{"visible":false,"ui_enabled":false}` |
| G7 | UI reply gate expressions | `{"reply_supported":true,"status":"等你决策","item_id":"","source":"https://synthetic.invalid/radar.json"}` | `{"visible":true,"ui_enabled":true}` |
| G8 | UI reply gate expressions | `{"reply_supported":true,"status":"等你决策","item_id":"syn-id","source":"not a URL"}` | `{"visible":true,"ui_enabled":true}` |
| G9 | UI reply gate expressions | `{"reply_supported":true,"status":"等你决策","item_id":"syn-id","source":null}` | `{"visible":true,"ui_enabled":false}` |
| S1 | Ordering/filtering | `{"mode":"priority_rank"}` | `["zero","one","two","missing","unknown"]` |
| S2 | Ordering/filtering | `{"mode":"missing_time_stable"}` | `["older","missing","newer"]` |
| S3 | Ordering/filtering | `{"mode":"complete_time"}` | `["newer","older"]` |
| S4 | Ordering/filtering | `{"mode":"priority_off_missing_time"}` | `["older","missing","newer"]` |
| S5 | Ordering/filtering | `{"mode":"priority_exact"}` | `["exact"]` |
| S6 | Ordering/filtering | `{"mode":"attention_project_excludes"}` | `[]` |
| S7 | Ordering/filtering | `{"mode":"attention_alltasks"}` | `["waiting"]` |
| S8 | Ordering/filtering | `{"mode":"explicit_empty_tasks"}` | `[]` |
| S9 | Ordering/filtering | `{"mode":"legacy_fallback"}` | `["waiting"]` |
| D1 | Original decode | `{"mode":"normal"}` | `true` |
| D2 | Original decode | `{"mode":"missing_title"}` | `false` |
| D3 | Original decode | `{"mode":"null_title"}` | `false` |
| D4 | Original decode | `{"mode":"blank_title"}` | `false` |
| D5 | Original decode | `{"mode":"missing_next"}` | `false` |
| D6 | Original decode | `{"mode":"null_next"}` | `false` |
| D7 | Original decode | `{"mode":"empty_next"}` | `true` |
| D8 | Original decode | `{"mode":"missing_priority"}` | `true` |
| D9 | Original decode | `{"mode":"null_priority"}` | `true` |
| D10 | Original decode | `{"mode":"empty_priority"}` | `true` |
| D11 | Original decode | `{"mode":"reply_number"}` | `false` |
| D12 | Original decode | `{"mode":"reply_string"}` | `false` |
| D13 | Original decode | `{"mode":"reply_null"}` | `true` |
| D14 | Original decode | `{"mode":"duplicate_ids"}` | `false` |
| R1 | Read-only manual boundary | `{"review":"Placeholders never backfill source or define business state"}` | `"not_run"` |
| R2 | Read-only manual boundary | `{"review":"Rank fallback/stable missing time is not assigning P2/current time"}` | `"not_run"` |
| R3 | Read-only manual boundary | `{"review":"UI capability/visibility is not prepare or server authorization"}` | `"not_run"` |
| R4 | Read-only manual boundary | `{"review":"Derived attention is not current account/owner recognition"}` | `"not_run"` |

</div>

Pinned source: [Radar model](https://github.com/alexlee2046/yihu-ios/blob/521ca77e1cf5d827617ae8963c2fc4f6cc232b3f/Apps/Collie/CollieRadarModel.swift) · [UI expressions](https://github.com/alexlee2046/yihu-ios/blob/521ca77e1cf5d827617ae8963c2fc4f6cc232b3f/Apps/Collie/CollieRadarView.swift) · [reply follow-on boundaries](https://github.com/alexlee2046/yihu-ios/blob/521ca77e1cf5d827617ae8963c2fc4f6cc232b3f/Apps/Collie/CollieRadarReply.swift)


## 执行边界 / Execution boundaries

Whole original CollieRadarModel.swift is compiled verbatim (including definitions never instantiated for storage). No real UserDefaults/Keychain operations are called. UI expressions call original radarText/NSLocalizedString (source-key fallback on this host without App translation resources) and use tiny record wrappers; no SwiftUI rendering, App translation validation or private source/reply calls. Display labels are not source values; local UI expressions are not authorization or business receipts. Runtime fields remain not_run. Saved11/05 US0.1.0 store evidence is reused, not current-store/global/binary parity.
