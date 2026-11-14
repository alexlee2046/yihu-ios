---
layout: ../../layouts/Wave3Guide.astro
title: "外贸简报接入PM Radar前：JSON类型、空值与缺失字段核对"
description: "以通用PM Radar源码契约说明必填字符串、数组、可选null、tasks回退和来源时间；仅解释自有获准任务数据，不新增外贸数据源或导入转换器。"
lang: zh
---

<h2 id="first-answer">语法正确的JSON不一定能被Radar解码，更不代表业务数据完整</h2>

先确认文件来自有权使用的自有台账，再核JSON语法、模型字段类型、解码后的验证和业务含义。一呼使用现有PM Radar模型读取快照，不把任意外贸简报当作任务数据。缺字段、显式 `null`、空字符串和空数组不能混为一谈；本文的合成样例只帮助解释契约，不连接真实源、转换纪要或启用回复。

## 四层检查，不用“JSON有效”代替全部验收

1. **语法**：括号、引号和数据字面值能解析，只是第一层。
2. **模型类型**：必需字符串/数组及可选字段要符合Swift Codable声明；字符串数字或空对象不能随意代替原类型。
3. **解码后验证**：来源日期须能解析、大小不超过2 MiB；非空项目/标题、项目记录、标识与时间戳还有源码校验。
4. **业务范围**：数据源是否完整、是否旧缓存、筛选是否遮蔽任务、字段有没有权限与来源依据，需要另行核对。解析通过不等于信息真实、可写或最新。

## 字段、null与空集合对照

<div role="region" aria-label="Radar JSON字段与空值检查表，可左右滚动" tabindex="0">

| 字段位置 | 模型形态 | 缺失/null/空值的区别 | 核对建议 |
| --- | --- | --- | --- |
| date_str | 必需String，另需可解析来源时间 | 缺失或null不满足必需类型；空/无效日期不满足后续验证 | 使用来源最后成功读取时间，不填手机点刷新时间 |
| decisions | 必需Action数组 | []是已提供的空子集；缺失/null不是空数组 | 不把空待处理子集当完整台账无任务 |
| active/stale/cold | 三个必需Project数组 | []表示该集合为空；不能用projects数组替代三个键 | 合并projects是模型计算属性，不是导入替代键 |
| tasks | 可选Action数组 | 缺失或null会回退decisions；[]是明确提供的空全任务集合，不触发回退 | 区分旧源范围不完整与明确的空全量集合 |
| Action.project/title | 必需String并验证非空白 | null/缺失/数字不符合类型；空白值不满足验证 | project应对应来源项目标识，不靠名称猜测 |
| Action.next/url | 必需String | null/缺失不符合类型；字符串存在不等于动作有授权或链接可安全访问 | 不把字段可解码当成可执行命令或URL认证 |
| Action.status/id/priority/timestamp等 | 可选String或可选Double，按字段分别核类型 | 可选字段可缺失/null；错误类型不等于“未知” | 状态缺失保留未知；任务timestamp不是来源date_str |
| Project.name/path/timestamp/message | 必需String/String/Double/String | 项目名/路径另验证非空，timestamp须在源码有效数值范围 | 不把null时间替换为当前时刻，message不作写权限 |
| reply_supported/source_refreshing/source_refresh_failed | 可选Bool | 缺失/null不同于明确true；字符串true不是Bool | 可读、正在刷新与可写分别判断，不补默认能力 |

</div>

## 最小合成样例：可选null与必需数组

```json
{
  "date_str": "2026-10-18 09:00",
  "decisions": [],
  "active": [],
  "stale": [],
  "cold": [],
  "tasks": [
    {
      "id": "sample-check-1",
      "project": "sample",
      "status": null,
      "priority": null,
      "timestamp": null,
      "title": "核对合成简报字段，不执行",
      "next": "仅检查来源与类型，不发送回复",
      "url": "https://example.invalid/tasks/sample-check-1"
    }
  ],
  "reply_supported": false,
  "source_refreshing": false,
  "source_refresh_failed": false
}
```

固定日期是历史演示数据，不因本文发布而变新。所有链接使用保留的 `example.invalid`，没有可连接的服务。`tasks`里有记录不强制本例必须带项目活动记录；项目数组与任务集合表达不同信息。`status: null` 表示未提供状态，不把该任务推断为已完成或被阻塞。`reply_supported: false` 明确不宣称可写，但即使改成true也不产生服务端授权。

可以对照三个差异：`"tasks": null` 会回退待处理子集；`"tasks": []` 不回退；把 `"title"` 改成null或数字不是合法的“未知标题”。本页不提供修改真实台账的命令，也不把样例结构检查冒充已跑过Swift真机导入。

## 空值修复应回来源，不掩盖失败

不要把失败读取产生的空对象补成“全部完成”，也不要为了让页面有卡片而复制旧源改日期。源缺 `tasks` 时应明确范围不完整；源有 `tasks: []` 时仍要确认导出范围、权限与业务含义。额外未知键不替代模型需要的键，JSON语法工具也不会检查读写权限。

处理询盘或跟进数据时，继续使用团队已获准的导出流程。本文没有海关/市场情报接口、抓客户名单、自动发信、纪要转任务或通用JSON转换服务；字段中的文字不能被当作对Agent的执行指令。

## FAQ

<h3 id="faq-null-vs-empty">tasks缺失、null和[]为什么不相同？</h3>

可选数组缺失或null解码为未提供，当前模型回退 `decisions`；空数组表示明确提供空全任务集合。回退只保证旧格式可读，不证明范围完整。

<h3 id="faq-optional">可选字段可以填任意类型吗？</h3>

不可以。可选只允许未提供/null，并不取消原有String、Double或Bool类型约束；把数字写成字符串也不能据此称为合法未知值。

<h3 id="faq-time">时间未知可以用现在或0代替吗？</h3>

不要伪造来源时间。任务可选timestamp缺失/null与来源必需date_str不同；必需项目时间和日期应由来源提供，类型可解析仍不代表内容新鲜。

<h3 id="faq-projects">只有projects数组能替代active/stale/cold吗？</h3>

不能。`projects`是模型合并三数组的计算属性，不能让缺少必需导入数组的文件自动变正确。项目path与任务project的语义关联也要核对。

<h3 id="faq-validator">页面样例检查通过代表App接受导入吗？</h3>

不代表。页面和前端测试只核示例/说明，不能替代实际版本的Swift解码、文件边界、真机和来源权限验收。

<h3 id="faq-brief">纪要字段模板能直接当外贸Radar简报导入吗？</h3>

不能。人工编辑字段与现有Radar模型是两份契约；需已有且获准的导出流程，本页不新增转换、数据源或写授权。

## 相关指南与实现

[多项目Radar与Watch](/guides/multi-project-radar-watch/) · [弱网缓存排障](/guides/offline-workbench-handoff-troubleshooting/) · [纪要与简报编辑字段](/guides/meeting-notes-brief-fields/) · [多段笔记待办核对](/guides/multi-note-review-handoff/) · [开始](/start/) · [隐私](/privacy/)

依据：[Radar模型与decode校验](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift)、[源读取与缓存](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarStore.swift)、[README源与回复边界](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)。
