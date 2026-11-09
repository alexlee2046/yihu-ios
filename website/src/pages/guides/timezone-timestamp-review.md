---
layout: ../../layouts/Wave3Guide.astro
title: "跨时区简报时间怎样核对？来源日期、Unix任务时间与载体时间分账"
description: "按现有UTC+08 date_str格式区分来源读取、任务更新时间、手机请求和Watch封包；提供人工跨日核对，不新增时区转换器或刷新SLA。"
lang: zh
---

## SYN-TZR-52 时间口径/请求寿命自检

SYNTHETIC_EXAMPLE · pending · not_run。日期、事件、纪元与有效窗口分账。

[/samples/p31-timezone-timestamp-review/README.md](/samples/p31-timezone-timestamp-review/README.md) · [/samples/p31-timezone-timestamp-review/preflight.zh.json](/samples/p31-timezone-timestamp-review/preflight.zh.json) · [/samples/p31-timezone-timestamp-review/preflight.en.json](/samples/p31-timezone-timestamp-review/preflight.en.json)

<div role="region" aria-label="SYN-TZR-52" tabindex="0">

| ID | 检查 | 预期/边界 |
| --- | --- | --- |
| D01 | 固定UTC+08 | parse=true; 2026-10-18T01:00:00Z |
| D02 | 跨到UTC前日 | parse=true; 2026-10-17T16:30:00Z |
| D03 | 有效闰日 | parse=true; 2024-02-28T16:00:00Z |
| D04 | 无效闰日 | parse=false; reject, no repair |
| D05 | ISO非原格式 | parse=false; reject, no repair |
| D06 | 偏移后缀不符 | parse=false; reject, no repair |
| D07 | 非补零格式 | parse=false; reject, no repair |
| D08 | 多出秒字段 | parse=false; reject, no repair |
| D09 | 分钟越界 | parse=false; reject, no repair |
| D10 | 24点回读不符 | parse=false; reject, no repair |
| D11 | 首尾空白不补救 | parse=false; reject, no repair |
| D12 | 固定偏移非手机DST | parse=true; 2026-03-07T18:30:00Z |
| W01 | 来源与封包不同 | Date JSON source=813978000; captured=813978060; reference2001 seconds |
| W02 | 跨日同一时刻 | Date JSON source=813947400; captured=813947520; reference2001 seconds |
| W03 | 新封包不刷新来源 | Date JSON source=813978000; captured=814064400; reference2001 seconds |
| W04 | Unix零非Date零 | Date JSON source=-978307200; captured=813978000; reference2001 seconds |
| W05 | Date零在2001 | Date JSON source=0; captured=813978000; reference2001 seconds |
| W06 | 未知来源不补封包 | Date JSON source=unknown/omitted; captured=813978000; reference2001 seconds |
| S01 | 无请求 | consume=[false]; pending=false |
| S02 | 即时一次消费 | consume=[true, false]; pending=false |
| S03 | 端点前1毫秒 | consume=[true]; pending=false |
| S04 | 30秒含端点 | consume=[true]; pending=false |
| S05 | 超过端点失效 | consume=[false, false]; pending=false |
| S06 | 重复刷新不排N队 | consume=[true, false]; pending=false |
| M01 | 先分事件口径 | source成功读取、task更新、手机请求、Watch封包、文件编辑不是同一事件；不以now替源日期。 |
| M02 | 显式偏移与格式 | 原date_str固定Gregorian/POSIX UTC+08且回读相等，不随手机时区或DST；UTC显示不授权改写源为ISO。 |
| M03 | 秒毫秒与Date纪元 | 任务Unix秒、JSONEncoder默认Date参考2001、ContinuousClock相对Duration分账，不凭位数除1000或互减。 |
| M04 | 时效阈值非SLA | 24小时旧/超前5分钟只核源码，未跑isOutdated/isFutureDated/stale；不是刷新/响应或业务逾期承诺。 |
| M05 | 请求消费非开麦 | 30秒含端点只属原请求中心，Intent返回/Bool消费不证明前台、系统绑定、权限、实际开麦/填入/发送。 |
| M06 | 保原件与停止 | 全部合成不访问来源，不填当前时间掩旧值、不改名/单位绕门；保未知和一次标记，目标可同步，未知不盲重试。 |

</div>



<h2 id="first-answer">先问这个时间描述哪件事，再比较时区、单位与先后</h2>

一呼当前Radar把 `date_str` 按固定 `yyyy-MM-dd HH:mm`、UTC+08:00解析，来源最后成功读取时间不能用手机请求、缓存命中或文件修改时间替换。任务 `timestamp` 是另外的可选Unix时间字段；Watch的 `sourceDate` 与 `capturedAt` 又有各自含义。跨时区核对应先分事件与契约，不把所有“时间”都当同一种数字。

## 与缓存排障、批次比较的分工

缓存指南定位旧数据和读取失败，批次比较核两份数据是否可比；这里专门检查**不同口径的日期时间如何被错误比较**。本页不实现自动时区转换、时钟修正、预约调度或跨时区同步，也不写回真实来源时间。

## 时间字段口径表

<div role="region" aria-label="日期时间与时区单位核对表，可左右滚动" tabindex="0">

| 时间/位置 | 当前含义或契约 | 应核对什么 | 不能替代什么 |
| --- | --- | --- | --- |
| date_str | 来源最后成功读取；固定UTC+08格式 | 完整字符串、来源与实际读取状态 | 手机点刷新或导出文件保存时间 |
| 任务timestamp | 可选Double，Unix任务更新时间 | 来源提供的单位、缺失/null与排序范围 | 整份源读取时间、批准/处理时间 |
| 手机请求时间 | 发起读取的本地事件 | 是否成功拿到新源，而非仅缓存 | 来源已更新或任务已变更 |
| Watch sourceDate | 手机摘要对应来源时间 | 来源范围、失败与裁剪信息 | 手表封包或独立刷新时间 |
| Watch capturedAt | 摘要封包时间 | 与sourceDate分别看待 | 最新业务状态或最新源读取 |
| 文件/编辑时间 | 保存、复制、整理文档的事件 | 是否只是副本或人工编辑 | 原业务事件或来源身份 |
| Unix秒与毫秒 | 不同数值单位，不可混用 | 按生产者/消费者契约核单位 | 仅凭位数猜测后自动改值 |
| 其他时区呈现 | 对同一时刻的人工显示 | 明确偏移、跨日与适用规则 | 把本地时区直接写回date_str |

</div>

Watch日期是该载体的Date编码契约，不能把随手看到的底层序列化数字直接与任务Unix字段相减。必须先核双方格式/单位；本页不提供通用时间字段识别器。

## 两个固定历史示例

```text
示例A：2026-10-18 09:00（按当前date_str契约为UTC+08）
同一时刻的UTC显示：2026-10-18 01:00 UTC

示例B：2026-10-18 00:30（UTC+08）
同一时刻的UTC显示：2026-10-17 16:30 UTC，日期跨到前一天
```

这是明确偏移下的人工示意，不是真实来源或当前新鲜数据。不要因为文中给出UTC显示，就把 `Z`、偏移或ISO分隔符直接加回 `date_str`；当前严格格式与回读校验不等于任意ISO8601接受器。

## 检查顺序

先给每个时间标明事件：源读取、任务更新、请求、封包还是文件编辑。再确认来源身份与范围，随后核格式、时区/偏移和单位。如果出现排序矛盾，先看缺失值、优先级与来源顺序规则，不把它自动解释成时钟错误或任务状态改变。

当前源码把超过24小时的来源标旧，超前超过5分钟提示时钟问题；它们是来源时效判断，不是响应时间、刷新频率、服务SLA或业务逾期判定。未知日期应保持未知/失败，不能填“现在”让警告消失。任何修正应回原来源维护流程，不绕过解析或写授权。

## FAQ

<h3 id="faq-phone-zone">手机在另一个时区，date_str会改按手机时区解析吗？</h3>

当前模型使用固定UTC+08解析，不应按手机所在地反推。实际显示与来源语义仍须分开核对。

<h3 id="faq-iso">给date_str加Z或+08:00会更标准吗？</h3>

不能因此假定当前消费者接受。它有固定格式与严格回读检查，改源格式属于兼容性变更，需另核目标版本。

<h3 id="faq-unit">13位数字可以自动除1000当Unix秒吗？</h3>

不应靠位数自动修源。先核生产者契约与实际字段，错误单位可能无效或表示完全不同时间；本页不提供自动强转。

<h3 id="faq-refresh">刚刷新或刚封包为什么还显示旧来源？</h3>

请求/封包与源成功读取不同，缓存可继续显示旧值；不能把新请求时间冒充来源更新。

<h3 id="faq-threshold">24小时和5分钟是刷新SLA吗？</h3>

不是。它们是当前来源旧值/未来时钟判断阈值，不承诺服务按某周期更新或任务必须何时处理。

<h3 id="faq-unknown">时间缺失时填当前时间能帮助比较吗？</h3>

会伪造含义，不应这样做。保留未知及缺口，回来源确认；否则会把旧数据或编辑副本误当新事实。

## 相关指南与源码

[JSON类型与空值](/guides/radar-json-null-validation/) · [批次比较](/guides/radar-snapshot-batch-comparison/) · [跨端呈现](/guides/cross-device-field-presentation/) · [改版兼容](/guides/brief-format-change-compatibility/) · [开始](/start/) · [隐私](/privacy/)

依据：[来源日期解析、时效与排序](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift)、[Watch日期模型](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/YihuWatchSnapshot.swift)。
