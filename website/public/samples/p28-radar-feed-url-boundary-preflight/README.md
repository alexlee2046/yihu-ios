# SYN-RFU-49 · Radar源URL边界 / Radar feed URL boundaries

SYNTHETIC_EXAMPLE · pending · not_run。从零合成，非真实来源/身份、读取/写入许可、设备能力或远端回执。 / Synthetic from scratch, not real source identity, read/write authority, device capability or remote receipt.

[中文 JSON](/samples/p28-radar-feed-url-boundary-preflight/preflight.zh.json) · [English JSON](/samples/p28-radar-feed-url-boundary-preflight/preflight.en.json)

feed、evidence、origin是不同消费者。feed允许path但query/fragment须不存在；证据会拆指定分隔符并保留query/fragment；origin仅根路径并规范host/443。规则差异不是绕门或修复建议。 / Feed, evidence and origin are different consumers. Feeds allow paths but require absent query/fragment; evidence splits listed separators and retains query/fragment; origins allow root paths and normalize host/443. Differences are not bypass/repair advice.

<div role="region" aria-label="合成URL边界 / Synthetic URL boundaries" tabindex="0">

| ID | 检查 / Check | feed / evidence / origin（形态而非许可 / shape, not authority） |
| --- | --- | --- |
| U01 | 空串 / Empty | feed=false; evidence=0 candidate(s); origin=false |
| U02 | 空白 / Whitespace | feed=false; evidence=0 candidate(s); origin=false |
| U03 | 裸host / Bare host | feed=true; evidence=1 candidate(s); origin=true |
| U04 | 根斜线 / Root slash | feed=true; evidence=1 candidate(s); origin=true |
| U05 | 源可带path / Feed path allowed | feed=true; evidence=1 candidate(s); origin=false |
| U06 | 只去首尾空白 / Edge whitespace trim | feed=true; evidence=1 candidate(s); origin=false |
| U07 | query被源拒绝 / Feed rejects query | feed=false; evidence=1 candidate(s); origin=false |
| U08 | fragment被源拒绝 / Feed rejects fragment | feed=false; evidence=1 candidate(s); origin=false |
| U09 | 空query仍存在 / Empty query still present | feed=false; evidence=1 candidate(s); origin=false |
| U10 | 空fragment仍存在 / Empty fragment still present | feed=false; evidence=1 candidate(s); origin=false |
| U11 | HTTP拒绝 / Reject HTTP | feed=false; evidence=0 candidate(s); origin=false |
| U12 | 缺host / Missing host | feed=false; evidence=0 candidate(s); origin=false |
| U13 | 合成内嵌user拒绝 / Reject synthetic user info | feed=false; evidence=0 candidate(s); origin=false |
| U14 | 端口0 / Port zero | feed=false; evidence=0 candidate(s); origin=false |
| U15 | 端口越界 / Out-of-range port | feed=false; evidence=0 candidate(s); origin=false |
| U16 | 端口上界 / Port upper bound | feed=true; evidence=1 candidate(s); origin=true |
| U17 | 显式443 / Explicit 443 | feed=true; evidence=1 candidate(s); origin=true |
| U18 | host大小写归一不同 / Host normalization differs | feed=true; evidence=1 candidate(s); origin=true |
| U19 | 编码逗号path / Encoded comma path | feed=true; evidence=1 candidate(s); origin=false |
| U20 | 原逗号path与分词 / Comma path versus tokenization | feed=true; evidence=1 candidate(s); origin=false |
| U21 | 标签非源URL / Label is not feed URL | feed=false; evidence=0 candidate(s); origin=false |
| U22 | 单URL与分号拆项 / One URL versus semicolon tokens | feed=true; evidence=2 candidate(s); origin=false |
| U23 | 不是域白名单 / Not a domain allowlist | feed=true; evidence=1 candidate(s); origin=false |
| U24 | 编码字节在path / Encoded bytes in path | feed=true; evidence=1 candidate(s); origin=false |
| M01 | 形态不等身份 / Shape is not identity | 通过validate不证明TLS、来源身份、认证/读取/JSON或写权限，不把supportsWatchDrafts布尔当设备功能验收。 / validate proves neither TLS, identity, auth/read/JSON nor write authority; supportsWatchDrafts is not device acceptance. |
| M02 | 拒绝不自动修复 / Rejection is not auto-repair | query无论是否空/无害都不可自行删除认证条件来绕门；不改HTTP/端口、不公开私有来源。 / Never remove real authentication/query conditions to bypass a gate, even empty/assumed harmless; no HTTP/port rewrite or private-source publication. |
| M03 | origin不等feed / Origin is not feed | origin只允许空/root path并规范host/443；feed可有path但不认证，来源身份与账户存储另核。 / Origin allows empty/root paths and normalizes host/443; feeds allow paths without authenticating. Review source/account/storage separately. |
| M04 | 提醒有自己的门 / Reminders have their own gate | 提醒HTTPS/relay-host、origin验证、已保存来源不能由feed或证据准入互相授权；未知来源不新建服务器。 / Reminder HTTPS/relay-host, origin validation and saved origins are not authorized by feed/evidence admission; unknown origins never add a server. |
| M05 | pending不是送达 / Pending is not delivery | pending单槽、笔记/语音保护、connected后消费与导航/登录/业务回执分账，保留原文和未知副作用。 / Keep pending slot, note/speech guards, connected consumption and navigation/login/business receipt separate; retain originals and unknown effects. |
| M06 | 不请求示例 / Do not fetch examples | example.invalid、localhost与SYN只是合成字符串，不DNS/HTTP/注册，不收私有源URL或凭据，不盲重试。 / example.invalid, localhost and SYN are synthetic strings: no DNS/HTTP/registration, private-source URL/credential collection or blind retry. |

</div>

## 原文与实际证据分账 / Preserve input and separate actual evidence

24例/语由原RadarModel整文件（feed/evidence/Workbench flag）与原CollieConnectionOrigin完整enum宿主执行；不改方法、不用同名假解析器。Foundation/CoreFoundation/Observation真实，origin enum独立隔离而不编译其SwiftUI设置类，不实例化UserDefaults/Keychain或任何源单例。 / 24 cases per language execute the whole original RadarModel (feed/evidence/Workbench flag) and whole original CollieConnectionOrigin enum. No modified method or fake parser. Foundation/CoreFoundation/Observation are real; the origin enum is isolated without its SwiftUI settings class. No UserDefaults/Keychain/source singleton is instantiated.

全部输入和完整预期在双JSON。U09/U10空query/fragment仍拒绝；U20/U22源可接纳一个带标点的path，而证据分词可能切段；U24编码字符是path而不是已获准认证条件。不要自动改写真实URL以制造通过。 / Full inputs/expectations are in both JSON files. U09/U10 reject even empty query/fragment; U20/U22 feeds may admit one punctuated path while evidence tokenization splits it; U24 encoded bytes are path, not authorized authentication. Never auto-rewrite real URLs to manufacture acceptance.

六人工边界不是提醒/导航运行例。DNS/HTTP/TLS/认证/读取/JSON/真实Watch/WKWebView/通知/账号/网络均not_run，supportsWatchDrafts只为原源码形态布尔，不等设备可用或写权。保留原文与已有许可，未知即停，不删认证条件、不放宽HTTPS、不用新公共服务代替私有源。目的地可保存同步处理，不承诺全数据不离机或全副本撤回。 / Six manual boundaries are not reminder/navigation executions. DNS/HTTP/TLS/auth/read/JSON/real Watch/WKWebView/notifications/accounts/network remain not_run. supportsWatchDrafts is a source shape flag, not device usability or write authority. Retain originals/authority, stop when unknown; never strip auth, weaken HTTPS or replace a private source with an unapproved public service. Destinations may save/sync/process; no all-on-device or universal recall claim.

Source: https://github.com/alexlee2046/yihu-ios/blob/7fa4ce027c66985f4bfde809e3261b0b349bbf15/Apps/Collie/CollieRadarModel.swift

[中文指南](/guides/radar-feed-url-boundary-preflight/) · [English guide](/en/guides/radar-feed-url-boundary-preflight/)
