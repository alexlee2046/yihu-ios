# SYN-LEAD-31 · 合成商机简报 / Synthetic opportunity brief

**本地候选材料 · 全部合成 · 不发送。Local candidate, entirely synthetic, do not send.**

这是一份12块织物色样的演练申请，不是12个客户或真实订单。已知只有“12块”；寄送地址、预算、采购时间和授权联系人都未知。先补事实，不报价、不发货、不写CRM或变更状态。

This is a fictional request for 12 fabric swatches, not 12 customers or a real order. Destination, budget, purchase window and authorized contact are unknown. Confirm facts first: no quote, shipment, CRM write or state change.

## 读预制JSON，不是让App采集商机 / Read preset JSON, not app lead capture

[中文源格式JSON](radar-brief.zh.json) · [English source-format JSON](radar-brief.en.json)

两文件是同一例的不同语言，不合并导入。每文件`tasks`两条、`decisions`同两条，不能相加成4；`active`一个合成项目。字段沿固定源码格式，`reply_supported:false`保留；example.invalid不是真实服务，不访问。这里只离线看资料，不要求安装版具备Radar/身份/笔记候选能力。

English variants retain raw Chinese protocol states and A's whitespace; only descriptive text is translated. 这不是漏翻，不改协议枚举或空白。Choose one language: two actions, not four; one synthetic active project, not a verified customer. `reply_supported:false` stays false. example.invalid is not a service to open. The JSON shape is source-derived; this offline review does not certify native Radar/identity/note-candidate features in the installed store edition.

| 核对 / Check | 已填参考答案 / Worked answer |
| --- | --- |
| A：`demo-decision`原状态`" 等你决策 "` | 注意力getter去空白后命中，但候选枚举按原状态精确匹配，不匹配。/ Attention trims and matches; exact raw candidate-state check does not. |
| B：`demo-acceptance`原状态`等你验收` | 注意力可命中；只有另满足合法源、快照、无本地回复、非空ID等前提才可能列候选，未实际执行。/ A conditional candidate only under separately met source/snapshot/no-record/ID checks, not observed here. |
| 纸面C：`进行中`且next有`Alex` | 公开源码固定字样可命中；不读取登录身份，也不授写权。/ The fixed code literal can match, without account resolution or authority. |
| 纸面D：只有title有Alex，next无，`进行中` | 不因标题名字而命中；漏项不证明没人需处理。/ A title name alone does not match; absence proves no global lack of work. |
| 全部结果 / All cases | 身份/权限未核；发送No-Go。不可改名字、去空白或把reply_supported置true来绕门。/ Identity/authority unverified, no sending; do not alter source fields to bypass checks. |

其他项目/状态/优先级/搜索条件仍会相交。固定Alex是公开代码条件，不是本包客户或负责人证据。源码保存也不等提交：target初始`eligible=false`、epoch/version空、`submitted=false`，原prepare/授权/确认仍需另核。本卡没有执行枚举/保存/发送。

候选枚举不额外证明reply_supported或快照新鲜，后续原prepare/时效/能力/确认仍需核。

Other filters still intersect. Enumeration does not additionally establish reply support or freshness; original prepare/freshness/capability/confirmation checks remain. The public literal is not customer/ownership evidence. A source-side local save still starts ineligible/unsubmitted and needs original prepare/authority/confirmation. No enumeration, save or submission was executed for this card.

固定`date_str=2026-10-31 12:00`按源码UTC+08:00理解，不是采购截止日或实时数据。它会自然变旧；不改日期洗新鲜，不忽略24小时旧数据/5分钟未来时界。

The fixed source time is not a purchase deadline or live data. It ages normally; do not roll it forward or bypass the 24-hour/5-minute source boundaries. source_refreshing/source_refresh_failed=false are preset synthetic fields, not observed refresh/health evidence. 两刷新字段为合成预设，不证明真实服务健康。

## 商店0.1.0只做另一件事：口述草稿 / Separate store path: dictate a draft

截至2026-10-31已核[US App Store id6819057500](https://apps.apple.com/us/app/yihu/id6819057500)为0.1.0、iOS18+。自有可信工作台/账号、获准空白练习草稿是前提；语音模型按需另下约950MB。商店安装不需Mac/签名，其他地区供应以实际商店为准。

US listing checked 2026-10-31: 0.1.0 / iOS18+. Bring your own trusted workspace/account and authorized empty training draft; optional speech model about 950MB. No Mac/self-signing for store installation. Availability follows the storefront.

[中文商店版上手](https://getyihu.com/start/#store-start) · [English store setup](https://getyihu.com/en/start/#store-start)

**中文可照读原话，理想草稿相同，不是自动摘要/改写：**
> 这份演练申请需要十二块色样。寄送地址、预算、采购时间和授权联系人尚未确认。请先确认这些信息；目前不承诺报价、发货或交期。

**English phrase and ideal verbatim draft, not an automatic summary/rewrite:**
> This practice request is for twelve swatches. The shipping destination, budget, purchase window and authorized contact are unconfirmed. Please confirm those details first; no quote, shipment or delivery date is promised.

人工参考：保留12块与4项未知，不能生成地址、真实联系人、报价或交期。另获准实际练习时安全停下、前台使用；模型/权限/语言/目的地或输入自动执行联动不明就停在离线材料。检查已有填入，不盲重插；终点仅未发送草稿，不按Send/Run，不后台常驻监听。App不代发不保证工作台不保存/同步/处理输入。

Worked review: preserve 12 and all four unknowns; invent no address, identity, quote or delivery promise. Only practice if separately authorized, stopped and in the foreground. Stop offline for uncertain models/permissions/language/destination/automation. Inspect before repeating insertion. Finish unsent: no Send/Run or continuous background listening. A destination may save/sync/process input.

**真实设备ASR/填入/身份/候选保存/发送均not_run。Real device ASR, insertion, identity, candidate saving and sending: not_run.** 不把源码格式演算冒商店二进制验收，不提供商机后台、账户认证或CRM适配服务。

源码依据（采集2026-10-31，固定M，不证明商店全功能）：[attention/model](https://github.com/alexlee2046/yihu-ios/blob/adb43b4d72c256a399e50d5e13f2e471abaa65fe/Apps/Collie/CollieRadarModel.swift#L30-L48) · [candidate/save](https://github.com/alexlee2046/yihu-ios/blob/adb43b4d72c256a399e50d5e13f2e471abaa65fe/Apps/Collie/CollieRadarStore.swift#L82-L130)。新写合成材料Apache-2.0；无真实客户、凭据、审批或效果背书。
