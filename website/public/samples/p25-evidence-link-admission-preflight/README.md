# SYN-ELA-46 · 证据链接准入自检 / Evidence link admission preflight

SYNTHETIC_EXAMPLE · pending · not_run。全部从零合成，不是真实证据、访问授权、脱敏、安全扫描或已打开回执。 / Synthetic from scratch, not real evidence, access authority, redaction, scanning or an open receipt.

## 核对原则 / Review principle

可点仅代表当前字符串形态通过；原文保留，缺链接不等没证据。路径/查询/片段仍可能敏感，权限与最小披露另核，未知就停，不自动修改源记录或盲重试。 / Clickable means current string-shape admission only. Retain the original; no link does not mean no evidence. Paths/queries/fragments may remain sensitive. Review authority and minimal disclosure separately, stop when unknown, never automatically rewrite sources or blindly retry.

[中文 JSON](/samples/p25-evidence-link-admission-preflight/preflight.zh.json) · [English JSON](/samples/p25-evidence-link-admission-preflight/preflight.en.json)

<div role="region" aria-label="合成链接核对 / Synthetic link review" tabindex="0">

| ID | 检查 / Check | 边界 / Boundary |
| --- | --- | --- |
| E01 | 空值 / Null | 原文为空不等业务证据不存在。 / Null input does not prove absent business evidence. |
| E02 | 空串 / Empty string | 不补造证据或URL。 / Do not fabricate evidence or URLs. |
| E03 | 空白换行 / Whitespace | 空链接列表不是删除源记录指令。 / An empty list is not an instruction to delete source records. |
| E04 | 独立HTTPS / Standalone HTTPS | 只证明形态准入，不是可信或获准访问。 / Shape admission only, not trust or access authority. |
| E05 | 边界标点 / Edge punctuation | 仅trim列出的边界字符，不是完整语法解析。 / Only trims listed edge characters, not full grammar parsing. |
| E06 | 换行分项 / Newline tokens | 保留首次顺序，不证明引用关系。 / First-seen ordering is not a provenance relationship. |
| E07 | 指定分隔符 / Listed separators | 分号逗号中文标点竖线拆词，不是全部引用语法。 / Listed punctuation splits tokens; not all reference syntax. |
| E08 | 相同串去重 / Exact duplicate | 按absoluteString去重，不代表内容去重。 / absoluteString deduplication is not content deduplication. |
| E09 | HTTP拒绝 / Reject HTTP | 拒绝形态不证明目的地不存在或恶意。 / Rejection proves neither a missing nor malicious destination. |
| E10 | 其他协议 / Other scheme | 不改写为HTTPS伪造准入。 / Do not rewrite a scheme to fabricate admission. |
| E11 | 缺host / Missing host | 不补造主机名。 / Do not invent a host. |
| E12 | 内嵌用户 / Embedded user | SYN-user是虚构占位；无user不等路径查询已脱敏。 / SYN-user is synthetic; absent user info does not redact paths or queries. |
| E13 | 端口0 / Port zero | 端口门不是所有端点可用性检查。 / The port gate is not endpoint availability testing. |
| E14 | 超范围端口 / Out-of-range port | 不修写端口掩盖原文。 / Do not rewrite the port and conceal the original. |
| E15 | 端口上界 / Port upper bound | 形态准入不是端口安全认证或网络测试。 / Admission is not port security certification or a network test. |
| E16 | 显式443 / Explicit 443 | 不宣称与省略端口的拼法语义全面归一。 / Do not claim semantic normalization with omitted ports. |
| E17 | Markdown标签 / Labeled Markdown | 此例不提取；不是完整Markdown解析器。 / This case is not extracted; not a full Markdown parser. |
| E18 | 逗号切URL / Comma inside URL | 逗号切出前段，候选可能不等原意；保留原文人工核。 / Comma splits off a prefix that may differ from intent; retain the original for review. |
| E19 | 查询片段保留 / Query and fragment retained | 全部虚构标记；筛选不脱敏、不授权公开路径查询片段。 / All markers are synthetic; filtering neither redacts nor authorizes disclosure of paths, queries or fragments. |
| E20 | 句点不是trim字符 / Period is not trimmed | 末尾句点仍在，不能假定自动纠正文案。 / A final period remains; do not assume prose is automatically corrected. |
| E21 | 非域名白名单 / No domain allowlist | localhost也可过形态门；不打开、不绕内网授权。 / localhost may pass shape checks; no fetching or bypassing local-network authority. |
| E22 | 编码逗号 / Encoded comma | 不按解码后语义全面归一。 / No universal normalization of decoded semantics. |
| E23 | 片段不同 / Different fragments | 不同absoluteString可并存，不证明不同内容或已读。 / Different absoluteStrings may coexist; not proof of distinct contents or reading. |
| E24 | 斜线拼法 / Trailing slash spelling | 不同串不自动语义合并，也不执行跳转解析。 / Distinct strings are not automatically merged semantically; no redirects are resolved. |
| R01 | 证据链接与提醒解析不可互授准入 / Evidence and reminder parsers do not grant each other admission | 证据仅形态；提醒另核relay HTTPS/host，不是同一白名单。 / Evidence uses shape filtering; reminders separately check relay HTTPS/host, not the same allowlist. |
| R02 | 待定槽不是打开回执 / Pending slot is not an open receipt | handleTap设pendingURL，consume后清空，不是全量审计队列。 / handleTap sets pendingURL; consumption clears it, not a complete audit queue. |
| R03 | 保留录文和笔记 / Preserve speech and notes | notesPresented、canCancel、delivering、canRetryDelivery及onWillSaveConnection门不能为导航绕过。 / Do not bypass notesPresented, canCancel, delivering, canRetryDelivery or onWillSaveConnection for navigation. |
| R04 | 当前源连接 / Current-origin connection | connected后才消费，不证明登录/会话/内容可信或业务成功。 / Consume only once connected; not proof of login, session, trusted content or business success. |
| R05 | 已保存与未知源 / Saved versus unknown origin | 其他源须已保存；未知源消费丢弃，不新增服务器，不放宽权限。 / Other origins must be saved; consume/drop unknown origins without adding a server or widening authority. |
| R06 | 目的地与原材料 / Destination and originals | 不访问例子，不抹原文/副作用；目的地可保存同步处理，未知不盲重试。 / No fetching examples or erasing originals/effects; destinations may save/sync/process, no blind retry when unknown. |

</div>

## 双语输入/预期与证据分账 / Bilingual inputs, expectations and separate evidence

逐例输入与完整expected_absolute_strings见双JSON。24例/语由原整文件模型宿主执行，不使用重写解析器；6例/语提醒路由为人工源码核对，不宣称运行UI。 / Full input and expected_absolute_strings appear in both JSON files. 24 cases per language run against the whole original model file, not a rewritten parser. Six reminder-routing reviews per language are manual source reviews, not UI executions.

全部原始真实性/访问/公开授权/脱敏复核/远端回执为null。example.invalid、localhost与SYN标记只作字符串，不作DNS、HTTP或页面访问；不放入真实凭据/顾客正文。 / Authenticity, access/disclosure authority, redaction review and remote receipt remain null. example.invalid, localhost and SYN markers are strings only: no DNS, HTTP or page visits; no real credentials or customer text.

证据候选、提醒HTTPS/relay host、pending槽、语音/笔记保护、origin准入、connected、导航/登录和业务回执分账，不将一条解析器的规则套到所有入口。任意HTTPS不是可信白名单。 / Evidence candidates, reminder HTTPS/relay host, pending slot, speech/note guards, origins, connected, navigation/login and business receipt remain separate. Never copy one parser’s rules to every entry; arbitrary HTTPS is not a trusted allowlist.

真实通知/APNs/设备/WKWebView/账户/网络/第三方安全/业务验收全not_run。目的地可保存同步自动处理，不宣称全部数据不离机或已删除。 / Real notification/APNs/device/WKWebView/accounts/network/third-party security/business acceptance remain not_run. Destinations may save/sync/process; no all-on-device or deletion guarantee.

Source: https://github.com/alexlee2046/yihu-ios/blob/f0661014f9e8127c0be0aa0d4df8d8b92f16a63c/Apps/Collie/CollieRadarModel.swift

[中文指南](/guides/evidence-link-admission-preflight/) · [English guide](/en/guides/evidence-link-admission-preflight/)
