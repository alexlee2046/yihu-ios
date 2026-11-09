# SYN-TZR-52 · 时间口径与请求寿命 / Time meanings and request lifetime

SYNTHETIC_EXAMPLE · pending · not_run。从零合成，非真实源读取/新鲜度、时钟健康、设备采集/许可或送达回执。 / Synthetic from scratch, not actual source reads/freshness, clock health, capture/authority or delivery receipts.

[中文 JSON](/samples/p31-timezone-timestamp-review/preflight.zh.json) · [English JSON](/samples/p31-timezone-timestamp-review/preflight.en.json)

JSON为测试配方，不是App导入schema。先标事件和消费者，再核格式、纪元、时区及单位，不能凭数字新旧互相替代。 / JSON contains test recipes, not an app import schema. Identify event/consumer before format, epoch, timezone and units; newer-looking numbers do not replace other events.

<div role="region" aria-label="时间合成核对 / Synthetic time review" tabindex="0">

| ID | 检查 / Check | 合成预期 / Synthetic expectation |
| --- | --- | --- |
| D01 | 固定UTC+08 / Fixed UTC+08 | parse=true; 2026-10-18T01:00:00Z |
| D02 | 跨到UTC前日 / Previous UTC date | parse=true; 2026-10-17T16:30:00Z |
| D03 | 有效闰日 / Valid leap day | parse=true; 2024-02-28T16:00:00Z |
| D04 | 无效闰日 / Invalid leap day | parse=false; reject, no repair |
| D05 | ISO非原格式 / ISO is not source format | parse=false; reject, no repair |
| D06 | 偏移后缀不符 / Offset suffix differs | parse=false; reject, no repair |
| D07 | 非补零格式 / Non-padded format | parse=false; reject, no repair |
| D08 | 多出秒字段 / Extra seconds | parse=false; reject, no repair |
| D09 | 分钟越界 / Minute out of range | parse=false; reject, no repair |
| D10 | 24点回读不符 / Hour24 roundtrip differs | parse=false; reject, no repair |
| D11 | 首尾空白不补救 / No whitespace repair | parse=false; reject, no repair |
| D12 | 固定偏移非手机DST / Fixed offset not device DST | parse=true; 2026-03-07T18:30:00Z |
| W01 | 来源与封包不同 / Source versus packaging | Date JSON source=813978000; captured=813978060; reference2001 seconds |
| W02 | 跨日同一时刻 / Date boundary same instant | Date JSON source=813947400; captured=813947520; reference2001 seconds |
| W03 | 新封包不刷新来源 / New package not new source | Date JSON source=813978000; captured=814064400; reference2001 seconds |
| W04 | Unix零非Date零 / Unix zero is not Date zero | Date JSON source=-978307200; captured=813978000; reference2001 seconds |
| W05 | Date零在2001 / Date zero is2001 | Date JSON source=0; captured=813978000; reference2001 seconds |
| W06 | 未知来源不补封包 / Unknown source not package time | Date JSON source=unknown/omitted; captured=813978000; reference2001 seconds |
| S01 | 无请求 / No request | consume=[false]; pending=false |
| S02 | 即时一次消费 / Immediate one-time consume | consume=[true, false]; pending=false |
| S03 | 端点前1毫秒 / One ms before endpoint | consume=[true]; pending=false |
| S04 | 30秒含端点 / Inclusive30s endpoint | consume=[true]; pending=false |
| S05 | 超过端点失效 / After endpoint expires | consume=[false, false]; pending=false |
| S06 | 重复刷新不排N队 / Repeat refresh not N-queue | consume=[true, false]; pending=false |
| M01 | 先分事件口径 / Identify the event first | source成功读取、task更新、手机请求、Watch封包、文件编辑不是同一事件；不以now替源日期。 / Source read, task update, phone request, Watch packaging and file edit are distinct; never replace source time with now. |
| M02 | 显式偏移与格式 / Explicit offset and format | 原date_str固定Gregorian/POSIX UTC+08且回读相等，不随手机时区或DST；UTC显示不授权改写源为ISO。 / Original date_str uses fixed Gregorian/POSIX UTC+08 with exact roundtrip, not phone zone/DST; UTC display does not authorize ISO source rewrites. |
| M03 | 秒毫秒与Date纪元 / Seconds milliseconds and Date epoch | 任务Unix秒、JSONEncoder默认Date参考2001、ContinuousClock相对Duration分账，不凭位数除1000或互减。 / Task Unix seconds, default JSONEncoder Date reference2001 and ContinuousClock relative Duration differ; no digit-count /1000 repair or cross-domain subtraction. |
| M04 | 时效阈值非SLA / Freshness thresholds are not SLA | 24小时旧/超前5分钟只核源码，未跑isOutdated/isFutureDated/stale；不是刷新/响应或业务逾期承诺。 / 24h stale/>5m future are source-only here; isOutdated/isFutureDated/stale are not run, not refresh/response/business-deadline promises. |
| M05 | 请求消费非开麦 / Consumption is not capture | 30秒含端点只属原请求中心，Intent返回/Bool消费不证明前台、系统绑定、权限、实际开麦/填入/发送。 / Inclusive30s belongs to original request center; Intent return/Bool consume proves no foreground/system binding/permission/capture/insertion/send. |
| M06 | 保原件与停止 / Preserve originals and stop | 全部合成不访问来源，不填当前时间掩旧值、不改名/单位绕门；保未知和一次标记，目标可同步，未知不盲重试。 / Synthetic only, no source fetch/current-time masking/rename-or-unit bypass. Preserve unknowns/reservations; destinations may sync, no blind retry. |

</div>

## 原函数宿主与真实系统分账 / Original host versus live systems

24例/语：12原Radar日期解析/decode、6原Watch Date编码/原decode、6原ShortcutCenter请求寿命。整原Radar/Watch文件+带原注解的完整原ShortcutCenter类编译一次，类外加Foundation/Observation imports，原方法不改。新实例不访问shared，MainActor.assumeIsolated只调用原内存方法，注入ContinuousClock相对时点、无sleep/真实系统意图。 / 24 cases per language:12 original Radar date/decode,6 original Watch Date encoding/decode,6 original ShortcutCenter lifetime. Whole original Radar/Watch files+whole annotated original ShortcutCenter compile once with external imports only. No shared access; MainActor.assumeIsolated calls original memory methods with injected ContinuousClock relative instants, no sleep/system Intent.

两语言各在TZ=UTC与TZ=America/Los_Angeles运行，逐例结果须全字节一致；是每语24独立用例各跑两环境，不冒48个不同用例。固定历史日期不变新，Watch源日期与封包分别保持，nil不补封包时间。 / Both languages run in TZ=UTC and TZ=America/Los_Angeles with byte-identical results:24 unique cases per language in two environments, not48 different cases. Fixed historical dates are not fresh; retain Watch source/package separately without replacing nil.

6人工边界不算执行例；原isOutdated/isFutureDated/Watch.stale仅核阈值源码，不调用实时getter。真实源、缓存、UI、Siri/Action Button/AppIntent、权限/麦克风、Watch配对/网络/目标发送全not_run。保原文、单位、缺口和一次标记，不填now掩警告，不自动时区转换/时钟修复或调度；目标可保存同步处理，未知不盲重试，不承诺全副本撤回/全数据不离机。 / Six manual boundaries are not executions; original live freshness getters are source-reviewed only. Real feeds/cache/UI/Siri/Action Button/AppIntent/authority/microphone/Watch pairing/network/send remain not_run. Preserve originals/units/gaps/reservations, no now-filled warnings, automatic timezone/clock repair/scheduling; destinations may save/sync/process, no blind retry/universal recall/all-on-device promise.

Source: https://github.com/alexlee2046/yihu-ios/blob/470909f8398e102fed599e37126def258cec82af/Apps/Collie/CollieRadarModel.swift

[中文指南](/guides/timezone-timestamp-review/) · [English guide](/en/guides/timezone-timestamp-review/)
