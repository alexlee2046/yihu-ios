---
layout: ../../layouts/Wave3Guide.astro
title: "证据文本为什么没变可点链接？分隔、HTTPS与去重准入核对"
description: "按safeEvidenceURLs核分词、边界标点、HTTPS、无内嵌凭据与端口；形态筛选不是安全扫描、真实性认证或完整Markdown解析。"
lang: zh
---

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
