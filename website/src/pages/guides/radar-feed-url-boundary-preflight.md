---
layout: ../../layouts/Wave3Guide.astro
title: "Radar源URL为什么被拒？路径、查询和证据链接的不同边界"
description: "按CollieRadarFeed核HTTPS、host、凭据、端口与query/fragment；源可有path，但有效URL不等认证、读取或JSON模型验收。"
lang: zh
---

<h2 id="first-answer">证据链接能点，不代表同一地址能作为Radar源</h2>

CollieRadarFeed.validate允许源URL带路径，但要求HTTPS、非空host、无内嵌用户名密码、无query和fragment，显式端口在1至65535。证据URL另用parseSafeEvidenceURLs，规则不能互换。通过源形态校验仍不证明认证、可达、成功读取或快照有效，本页不新增源服务或凭据配置。

## 与证据URL准入和离线排障的分工

证据指南核可点候选，离线指南核失败状态；这里先核**配置为数据源的地址本身是否符合消费者边界**。不发网络请求、不输入真实凭据、不把有效URL当私有来源身份认证。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 首尾空白 | 先去首尾空白再解析 | 原配置与实际返回URL | 清洗所有内部字符 |
| 协议与host | HTTPS且host非空 | 实际来源身份另核 | 可信域白名单或TLS实测 |
| path | 源可有路径 | 路径是否实际提供源 | 浏览器可信origin规则直接代用 |
| 内嵌凭据 | user/password必须空 | 沿既有获准认证流程 | 把密码塞URL就能使用 |
| query/fragment | 必须都不存在 | 即使只是view=demo也不同 | 证据链接允许就源也允许 |
| 端口 | 显式1…65535 | 服务可达性与访问权限 | 所有端口和来源已测试 |
| 返回内容 | 形态校验不是JSON解码 | 真实模型/日期/大小/身份 | 任意网页地址都是快照源 |
| 失败处理 | 保持原守卫 | 错误类别和原来源配置 | 自动改HTTP/换服务/公开私有源 |

</div>

## 合成地址比较

https://example.com/radar.json只是带path的形态示意；加?view=demo或#part会触及当前源校验的query/fragment限制。示例未访问，不代表实际源存在。

不要为了通过校验删掉真实认证条件或改用未批准公开服务。形态、认证、读取和内容验收是四类证据；其中一项通过不补齐其余，也不产生回复写权。

## FAQ

<h3 id="faq-1">HTTPS链接可点就能当源吗？</h3>

不能。证据候选和源URL有不同消费者规则，尤其query/fragment。

<h3 id="faq-2">源必须只有域名不能有path吗？</h3>

不是。该校验允许path，但路径是否实际有效仍需获准读取证据。

<h3 id="faq-3">无敏感内容的query也允许吗？</h3>

当前校验要求query不存在，不能按内容无害自行放宽。

<h3 id="faq-4">通过validate是否证明认证成功？</h3>

不证明。没有发出请求，身份、权限与真实响应另核。

<h3 id="faq-5">地址失败能改HTTP绕过吗？</h3>

不应。按原错误和获准配置处理，不绕HTTPS边界。

<h3 id="faq-6">本页是否创建或访问了示例源？</h3>

没有，未注册服务、输入凭据或发网络请求。

## 相关指南与源码

[证据链接准入](/guides/evidence-link-admission-preflight/) · [离线与来源失败](/guides/offline-workbench-handoff-troubleshooting/) · [JSON消费者条件](/guides/radar-json-null-validation/) · [开始](/start/) · [隐私](/privacy/)

[CollieRadarFeed与证据URL校验](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift) · [来源与工作台边界](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)
