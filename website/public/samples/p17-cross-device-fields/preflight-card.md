# SYN-XDEV-38 — 跨端字段/占位/裁剪 / Cross-device field preflight

**SYNTHETIC_EXAMPLE** · 不是App导入JSON、真实台账、配对日志、设备回执或客户正文。Fixed#59@e592f63af7061072d6683f89423b3abf2fee2a7c / tree a278454faf98bab436d238b5433047ef804c33a7. Source availability is not installed-store-binary parity.

## 第一核查 / First check

先核载体/来源/事项身份与集合，再核sourceDate/读取失败/原字段，不用capturedAt代新源读取。手机allTasks是tasks??decisions：显式空tasks不回退，缺tasks才回退；Watch只取精确“等你决策/等你验收”且有非空id事项。Phone attention can trim status or match Alex while Watch exact-status subset excludes it. Nil/empty IDs are skipped; source does not trim whitespace ID. None of these identifiers/fingerprints is account authentication or service write permission.

**字段前缀裁剪不一定设置truncated。** 原publish按Swift Character取title160/project80/next600；只有超过200行或总JSON字节继续删尾会设truncated。单项161/81/601原文被裁，但truncated仍可false。UTF8字节可远大于Character数，扩展字形/组合字符边界按Swift prefix处理；不能把屏幕短句当完整条件/否定，回手机核原字段。The shared decoder does not enforce those producer per-field prefixes: a161-character title can decode if all other gates fit. Producer clipping, decoder constraints and screen line wrapping are separate.

## 执行范围 / Execution scope

每语11个原publish内存例、11个共享codec例、4个展示表达式例，4载体边界只读。原publish/sourceToken/taskToken、Action/allTasks/generatedAt、完整YihuWatchSnapshot及手机/Watch next与priority条件表达式逐字编译，Foundation/CryptoKit/JSONEncoder/Decoder宿主真实；store/workbench/WCSession是内存替身，无WatchConnectivity激活、配对/传送/刷新或SwiftUI执行。指纹只对固定synthetic.invalid/合成事项计算，不输出真实源地址/客户正文/内部标记，不授新授权。

26 source-fragment cases/language compile once. Memory sink success is not device receipt. Phone radarText is a test key-echo stub, so expected“下一步待补”is the source key/condition, not verified English localization or actual rendered pixels. Priority-visible means the extracted !isEmpty predicate, not visual evidence. Real device clock/stale-edge races, line wrapping/layout and fresh source reads were not tested.

- **P1/P4/P5/P6/P7**: cross-carrier subset/fallback and raw nonempty ID differ; fewer visible rows is not source deletion or completion.
- **P2/P3**: per-field Character clipping can leave truncated=false; not a full-text completeness receipt.
- **P8/P9**: prefix200 then trim-to50000 bytes;200 is not guaranteed and bytes can prune earlier. Retained prefix order does not mean business deletion of the omitted tail.
- **P10/P11**: new capturedAt with absent sourceDate/read failure is not refreshed source. No fixed-clock86400/-300 edge acceptance claim.
- **D1–D11**: exact50000 bytes succeeds using valid trailing JSON whitespace;50001 rejected,200 bounded short rows vs201 rejected, duplicate IDs/invalid UUID/uppercase token/missing required next/invalid status reject. These are constructed host bytes, not received device payloads or authorization proof.
- **F1–F4**: next empty string=>placeholder, whitespace-only next stays whitespace; optional priority nil or empty=>empty/hide predicate, whitespace priority predicate true. Missing required next is not the same as empty. Display placeholders do not invent or write back source data.

## 完整双语工作表 / Full bilingual worksheet

### zh

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| P1 | 完整tasks与Watch待处理子集不同 | {'item_count': 1, 'truncated': False, 'phone_all_count': 3} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P2 | 字段前缀已裁剪，truncated仍可false | {'item_count': 1, 'title_characters': 160, 'project_characters': 80, 'next_characters': 600, 'truncated': False} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P3 | 扩展字形前缀不等UTF8字节 | {'item_count': 1, 'title_characters': 160, 'project_characters': 80, 'next_characters': 600, 'title_utf8_greater_than_characters': True, 'truncated': False} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P4 | 显式空tasks不回退decisions | {'item_count': 0, 'phone_all_count': 0} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P5 | 缺tasks旧源回退decisions | {'item_count': 1, 'phone_all_count': 1} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P6 | trim或提及Alex可手机命中但不进Watch精确状态 | {'item_count': 0, 'phone_attention_count': 2} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P7 | nil和空id跳过，空白id不等空 | {'item_count': 1, 'first_task': ' '} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P8 | 201原事项并不保证200全传 | {'within_200_items': True, 'truncated': True} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P9 | 未到200也会因50000字节裁尾 | {'item_count_less_than_input': True, 'truncated': True, 'first_task': 'syn-0'} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P10 | 新封包时间不补缺失来源时间 | {'item_count': 1, 'source_date_missing': True, 'stale': True} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P11 | 仍有缓存显示但读取失败过期 | {'item_count': 1, 'read_failed': True, 'stale': True} | Fake store/workbench/WCSession sink; no paired-device transfer |
| D1 | normal | shared codec accepted=True | Host JSON codec only; not a received device packet |
| D2 | bytes_exact | shared codec accepted=True | Host JSON codec only; not a received device packet |
| D3 | bytes_over | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D4 | rows200 | shared codec accepted=True | Host JSON codec only; not a received device packet |
| D5 | rows201 | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D6 | duplicate | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D7 | invalid_uuid | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D8 | uppercase_token | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D9 | missing_next | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D10 | long_title | shared codec accepted=True | Host JSON codec only; not a received device packet |
| D11 | invalid_status | shared codec accepted=False | Host JSON codec only; not a received device packet |
| F1 | next=''; priority=None | label='下一步待补'; priority predicate=False | Extracted expressions, not pixels/localization/full SwiftUI |
| F2 | next=' '; priority=' ' | label=' '; priority predicate=True | Extracted expressions, not pixels/localization/full SwiftUI |
| F3 | next='SYNTHETIC_EXAMPLE: pending verification'; priority='P1' | label='SYNTHETIC_EXAMPLE: pending verification'; priority predicate=True | Extracted expressions, not pixels/localization/full SwiftUI |
| F4 | next=''; priority='' | label='下一步待补'; priority predicate=False | Extracted expressions, not pixels/localization/full SwiftUI |
| B1 | 网页草稿/文字附件非台账镜像且不附原音频 | source/manual review; runtime not_run | No carrier sync, auth or business delivery receipt |
| B2 | queued/ready非phone草稿/网页填入/发送回执 | source/manual review; runtime not_run | No carrier sync, auth or business delivery receipt |
| B3 | 本地指纹与canDraft标记不取代认证授权 | source/manual review; runtime not_run | No carrier sync, auth or business delivery receipt |
| B4 | 屏幕行数/字体布局与真实配对未执行 | source/manual review; runtime not_run | No carrier sync, auth or business delivery receipt |

### en

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| P1 | Full phone tasks differ from Watch pending subset | {'item_count': 1, 'truncated': False, 'phone_all_count': 3} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P2 | Field prefixes clipped while truncated flag remains false | {'item_count': 1, 'title_characters': 160, 'project_characters': 80, 'next_characters': 600, 'truncated': False} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P3 | Extended-grapheme prefix is not UTF8 bytes | {'item_count': 1, 'title_characters': 160, 'project_characters': 80, 'next_characters': 600, 'title_utf8_greater_than_characters': True, 'truncated': False} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P4 | Explicit empty tasks does not fall back to decisions | {'item_count': 0, 'phone_all_count': 0} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P5 | Missing legacy tasks falls back to decisions | {'item_count': 1, 'phone_all_count': 1} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P6 | Trim/mention attention differs from exact Watch status | {'item_count': 0, 'phone_attention_count': 2} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P7 | Nil/empty IDs skipped; whitespace ID is not empty | {'item_count': 1, 'first_task': ' '} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P8 | 201 source rows do not guarantee200 transmitted | {'within_200_items': True, 'truncated': True} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P9 | Byte budget trims before200 and preserves prefix order | {'item_count_less_than_input': True, 'truncated': True, 'first_task': 'syn-0'} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P10 | New capturedAt cannot fill missing sourceDate | {'item_count': 1, 'source_date_missing': True, 'stale': True} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P11 | Cached display with read failure is stale | {'item_count': 1, 'read_failed': True, 'stale': True} | Fake store/workbench/WCSession sink; no paired-device transfer |
| D1 | normal | shared codec accepted=True | Host JSON codec only; not a received device packet |
| D2 | bytes_exact | shared codec accepted=True | Host JSON codec only; not a received device packet |
| D3 | bytes_over | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D4 | rows200 | shared codec accepted=True | Host JSON codec only; not a received device packet |
| D5 | rows201 | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D6 | duplicate | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D7 | invalid_uuid | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D8 | uppercase_token | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D9 | missing_next | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D10 | long_title | shared codec accepted=True | Host JSON codec only; not a received device packet |
| D11 | invalid_status | shared codec accepted=False | Host JSON codec only; not a received device packet |
| F1 | next=''; priority=None | label='下一步待补'; priority predicate=False | Extracted expressions, not pixels/localization/full SwiftUI |
| F2 | next=' '; priority=' ' | label=' '; priority predicate=True | Extracted expressions, not pixels/localization/full SwiftUI |
| F3 | next='SYNTHETIC_EXAMPLE: pending verification'; priority='P1' | label='SYNTHETIC_EXAMPLE: pending verification'; priority predicate=True | Extracted expressions, not pixels/localization/full SwiftUI |
| F4 | next=''; priority='' | label='下一步待补'; priority predicate=False | Extracted expressions, not pixels/localization/full SwiftUI |
| B1 | Web draft/text attachment is not ledger mirror or original audio | source/manual review; runtime not_run | No carrier sync, auth or business delivery receipt |
| B2 | queued/ready is not phone draft/web insertion/send receipt | source/manual review; runtime not_run | No carrier sync, auth or business delivery receipt |
| B3 | Local fingerprints/canDraft do not replace authentication/authorization | source/manual review; runtime not_run | No carrier sync, auth or business delivery receipt |
| B4 | Screen line wrapping/layout and real pairing not executed | source/manual review; runtime not_run | No carrier sync, auth or business delivery receipt |

## 交接和No-Go / Handoff and No-Go

网页草稿/文字附件不是手机全台账镜像，也不因此附带原音频或双向更新回源；本包不实现/验证同步。queued可接纳/缓存确认，ready为有界结果缓存，不是phone回复草稿已存、网页已填或服务提交回执。canDraft与本地指纹仍不能取代原目标/忙态/前台/手机确认/服务授权。No actual Watch voice, draft-save, upload or send request is executed.

Unknown identity, stale/cache/read failure, clipping/placeholder mistaken for original facts or uncertain prior side effects => No-Go: preserve source and failure, return to phone for complete evidence, do not synthesize missing fields, silently “repair” or blindly refill/resend. Destination may save/sync/auto-process; App not auto-sending is not a guarantee all data stays local.

US商店沿11/05官方保存观察0.1.0/id6819057500/iOS18+，非本轮最新/全球供应。商店安装无需Mac/Xcode/自签名，自己的可信HTTPS工作台/账号、可选模型约950MB、麦克风/配对权限与实际安装版本另核。https://apps.apple.com/us/app/yihu/id6819057500

Pairing/WatchConnectivity delivery/refresh, SwiftUI layout/localization/line wrapping, device clock edges, voice/ASR, phone draft save, web insertion, attachment upload/sync, service send/authorization, hardware latency/SLA: **not_run**. No always-on relay or guaranteed full-field synchronization/recovery.

Only active cross-device pair links this pack; retired watch-voice pair stays false without downloads/Store cards or own sitemap/LLM section. Source canonical getyihu.com unchanged, dispatch yihu.st is not migration permission. No production/IndexNow/Google API calls or external submission here.
