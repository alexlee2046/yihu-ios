---
layout: ../../layouts/Wave3Guide.astro
title: "空字段与默认显示怎样核？别把“待补”占位写回笔记或Radar源"
description: "区分真实空值、界面占位、排序兜底和权限判定；缺必填字段不自动补名，显示相同不等于源值相同，不新增默认值修复器。"
lang: zh
---

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


<h2 id="first-answer">“待补”可能只是界面说明，不是来源已经提供的业务值</h2>

一呼的任务卡片会在部分字段为空时显示“任务状态未提供”“优先级待补”“下一步待补”等提示。这些显示分支不表示源码把原字段改成默认业务状态、优先级或下一步。校验时先区分原值与渲染结果，不能为了让界面完整而把未知回填成已确认事实；本文不提供默认值修复器或自动补全源数据。

## 与JSON类型校验的区别

JSON指南核缺失、null和类型；这里进一步核**通过读取后的占位、兜底排序与权限条件有没有被误当源内容**。它不重讲完整数据契约，不自动修改字段，也不把空字符串一律等同所有空白字符。

## 空字段、占位与默认处理表

<div role="region" aria-label="空字段与界面占位默认值表，可左右滚动" tabindex="0">

| 位置 | 当前消费者行为/边界 | 人工核查 | 不能回填/推断 |
| --- | --- | --- | --- |
| 必填身份/标题 | decode另核非空project/title等条件 | 原字段是否存在、类型与非空条件 | 自动“未命名任务”就可替代有效源 |
| status显示 | 任务卡片空白状态可显示未提供 | 显示说明与源status分开 | 未提供等于待办、完成或已批准 |
| priority显示 | nil/空串可显示优先级待补 | 真正源值与显示标签 | 把待补写成P2或自动默认优先级 |
| next显示 | 任务卡片可对去首尾空白后的空串显示待补 | 原文、具体控件与已知缺口 | 自动生成执行动作或负责人 |
| session/evidence等 | 部分缺项显示待补/未提供 | 源中是否真的有同样字样 | 占位证明负责会话/证据已存在 |
| 排序兜底 | 未知优先级有比较规则 | 排序结果不是源字段赋值 | 排在后面就代表来源设了低优先级 |
| reply_supported | 明确true才满足该能力条件 | 未知和显式false语义分开 | 按钮不可用就把原值统一写false |
| 空笔记原文 | handOff入口拒绝空transcript | 原文与界面提示分开 | 用提示文字冒充转写或自动消除缺口 |

</div>

不同控件是否去首尾空白按各处实现判断，并不统一；不要从一个卡片分支推广成所有字段的清洗规则。界面显示相近也不证明来源层相同。

## 占位与真实字符串的合成例子

```text
材料A：evidence为null，卡片用“待补”说明缺口。
材料B：evidence为字面字符串“待补”，来源真的写了这个文本。
核查：两者都不足以证明业务证据已提供，但来源值不同。
处理：保留区别，不把占位截图当原始字段，不自动改写真实数据。
```

这个例子不是完整Radar快照，也不调用实际解码。若要确认字段，应在已有权限范围核原材料；本页不新增原始数据查看器或让私有来源公开。

## 不用默认值扩大结论

人工整理时可以把“未知”作为说明，但须标明这是编辑标签，不是源字段已更新。来源身份、必填校验与回复能力失败时，不通过填当前时间、空数组或常见优先级来绕过实际条件。

“暂无文字”不等于会议没有发生，“没有匹配任务”不等于任务全部完成，“待补”也不等于后台会自动补齐。只记录实际材料与未知，不因占位或排序产生新业务判断、动作授权或重发资格。

## FAQ

<h3 id="faq-source">界面显示优先级待补，源里就保存了“待补”吗？</h3>

不一定。可能只是显示分支，需要核原字段；不能把截图标签当源数据值。

<h3 id="faq-required">缺标题可以补个未命名让快照通过吗？</h3>

不应擅自造值。当前消费者有非空身份/标题等要求，应回真实来源维护流程，不用默认名冒充有效原件。

<h3 id="faq-spaces">空串、空白字符和缺失在所有位置都相同吗？</h3>

不是。具体解析/控件的条件可能不同，本页不提供统一清洗或把所有空白自动归一的保证。

<h3 id="faq-false">按钮不可用是否证明reply_supported显式为false？</h3>

不能。未知能力、其他权限/来源条件也会影响可用性。原值和界面结论应分账，不自动回写false。

<h3 id="faq-priority">按默认顺序排后面就能填低优先级吗？</h3>

不能。兜底比较规则不是修改来源优先级，更不是业务紧急程度结论。

<h3 id="faq-notes">空笔记能把“暂无文字”当转写交接吗？</h3>

不应这样做。提示不是原文，既有入口与一次交接守卫不因填占位而取消；真实内容缺口须保留。

## 相关指南与源码

[JSON类型与空值](/guides/radar-json-null-validation/) · [摘要句子溯源](/guides/radar-summary-claim-provenance/) · [跨端显示范围](/guides/cross-device-field-presentation/) · [笔记一次交接](/guides/recording-notes-handoff/) · [开始](/start/) · [隐私](/privacy/)

依据：[任务卡片占位](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarView.swift)、[解码与排序](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift)、[笔记空原文守卫](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift)。
