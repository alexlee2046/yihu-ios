---
layout: ../../layouts/Wave3Guide.astro
title: "证据文本为什么没变可点链接？分隔、HTTPS与去重准入核对"
description: "按safeEvidenceURLs核分词、边界标点、HTTPS、无内嵌凭据与端口；形态筛选不是安全扫描、真实性认证或完整Markdown解析。"
lang: zh
---

## SYN-ELA-46 证据链接准入自检

SYNTHETIC_EXAMPLE · pending · not_run。形态准入不是安全、真实性、脱敏或访问授权。

[/samples/p25-evidence-link-admission-preflight/README.md](/samples/p25-evidence-link-admission-preflight/README.md) · [/samples/p25-evidence-link-admission-preflight/preflight.zh.json](/samples/p25-evidence-link-admission-preflight/preflight.zh.json) · [/samples/p25-evidence-link-admission-preflight/preflight.en.json](/samples/p25-evidence-link-admission-preflight/preflight.en.json)

<div role="region" aria-label="SYN-ELA-46" tabindex="0">

| ID | 检查项 | 不应推断 |
| --- | --- | --- |
| E01 | 空值 | 原文为空不等业务证据不存在。 |
| E02 | 空串 | 不补造证据或URL。 |
| E03 | 空白换行 | 空链接列表不是删除源记录指令。 |
| E04 | 独立HTTPS | 只证明形态准入，不是可信或获准访问。 |
| E05 | 边界标点 | 仅trim列出的边界字符，不是完整语法解析。 |
| E06 | 换行分项 | 保留首次顺序，不证明引用关系。 |
| E07 | 指定分隔符 | 分号逗号中文标点竖线拆词，不是全部引用语法。 |
| E08 | 相同串去重 | 按absoluteString去重，不代表内容去重。 |
| E09 | HTTP拒绝 | 拒绝形态不证明目的地不存在或恶意。 |
| E10 | 其他协议 | 不改写为HTTPS伪造准入。 |
| E11 | 缺host | 不补造主机名。 |
| E12 | 内嵌用户 | SYN-user是虚构占位；无user不等路径查询已脱敏。 |
| E13 | 端口0 | 端口门不是所有端点可用性检查。 |
| E14 | 超范围端口 | 不修写端口掩盖原文。 |
| E15 | 端口上界 | 形态准入不是端口安全认证或网络测试。 |
| E16 | 显式443 | 不宣称与省略端口的拼法语义全面归一。 |
| E17 | Markdown标签 | 此例不提取；不是完整Markdown解析器。 |
| E18 | 逗号切URL | 逗号切出前段，候选可能不等原意；保留原文人工核。 |
| E19 | 查询片段保留 | 全部虚构标记；筛选不脱敏、不授权公开路径查询片段。 |
| E20 | 句点不是trim字符 | 末尾句点仍在，不能假定自动纠正文案。 |
| E21 | 非域名白名单 | localhost也可过形态门；不打开、不绕内网授权。 |
| E22 | 编码逗号 | 不按解码后语义全面归一。 |
| E23 | 片段不同 | 不同absoluteString可并存，不证明不同内容或已读。 |
| E24 | 斜线拼法 | 不同串不自动语义合并，也不执行跳转解析。 |
| R01 | 证据链接与提醒解析不可互授准入 | 证据仅形态；提醒另核relay HTTPS/host，不是同一白名单。 |
| R02 | 待定槽不是打开回执 | handleTap设pendingURL，consume后清空，不是全量审计队列。 |
| R03 | 保留录文和笔记 | notesPresented、canCancel、delivering、canRetryDelivery及onWillSaveConnection门不能为导航绕过。 |
| R04 | 当前源连接 | connected后才消费，不证明登录/会话/内容可信或业务成功。 |
| R05 | 已保存与未知源 | 其他源须已保存；未知源消费丢弃，不新增服务器，不放宽权限。 |
| R06 | 目的地与原材料 | 不访问例子，不抹原文/副作用；目的地可保存同步处理，未知不盲重试。 |

</div>



<h2 id="first-answer">能点只代表通过当前形态筛选，不代表证据可信或已脱敏</h2>

Radar保留evidence文字，再从中筛选可点URL。当前解析按空白/换行与列出的分隔符拆项，去边界标点，只接纳HTTPS、非空host、无内嵌用户名密码及有效端口，再按absoluteString去重。它不是完整Markdown解析器、安全扫描或业务证据认证。

## 与引用溯源、异常证据二查的区别

溯源指南核句子依据、二查核真实性；这里先解释**为什么一段证据文字可能没有生成链接、哪些URL形态被接纳**。源码分隔符为分号、逗号、中文逗号/分号和竖线等；本页不访问示例链接、不改源数据。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 空值/空串 | 返回空链接列表 | 真实evidence与显示占位 | 任务没有任何证据 |
| 分词 | 空白/换行及指定标点 | 逗号可能切开合法URL文本 | 自动理解所有引用语法 |
| 边界标点 | 去两端括号/引号等 | 候选串实际结果 | 完整解析标签式Markdown |
| scheme/host | HTTPS且host非空 | 协议和实际目的地 | 安全域名白名单或权限已核 |
| 内嵌凭据 | user/password必须为空 | 不在URL放真实凭据 | 路径/查询里的敏感信息也自动消失 |
| 端口 | 显式端口限1…65535 | 形态与目标访问权限分开 | 所有端口服务已验证 |
| 去重 | 按absoluteString首次保留 | 不同拼法与实际引用关系 | 语义同址全面归一 |
| 结果 | 只输出可点候选 | 正文、证据质量与目的地 | 无风险/真实/已读或已处理 |

</div>

## 合成链接核查

单独的https://example.com/review可作为形态示意，不表示真实项目证据；带标签的Markdown链接不保证按完整语法展开。遇到未提取项，先核原文和分词，不删除证据或补造安全结论。

链接里的路径、查询和片段仍可能泄露信息，即使没有user/password。访问前遵守已有权限与目的地范围，不把解析器名称中的safe当恶意内容扫描或所有网络访问安全保证。

## FAQ

<h3 id="faq-1">没有可点链接是否表示没有证据？</h3>

不表示。原文可能不是符合该分词/URL规则的链接，须核原材料。

<h3 id="faq-2">Markdown标签链接一定提取吗？</h3>

不保证。这里不是完整Markdown解析器，不应假定所有嵌套标记都支持。

<h3 id="faq-3">HTTPS就证明可信和获准访问吗？</h3>

不是。这里只核形态；来源真伪、内容、身份与访问权限另核。

<h3 id="faq-4">无用户名密码是否已经脱敏？</h3>

不等于。路径/查询/片段仍可能含敏感信息，需人工核范围。

<h3 id="faq-5">去重会把所有等价地址合为一条吗？</h3>

不声明语义归一，只按absoluteString去重。

<h3 id="faq-6">本页是否打开过示例URL？</h3>

没有，未作网站安全或业务证据验收。

## 相关指南与源码

[证据二查](/guides/radar-evidence-second-check/) · [句子溯源](/guides/radar-summary-claim-provenance/) · [载体敏感层](/guides/carrier-redaction-archive-matrix/) · [开始](/start/) · [隐私](/privacy/)

[parseSafeEvidenceURLs](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift) · [链接展示](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarView.swift)
