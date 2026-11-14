---
layout: ../../layouts/Wave3Guide.astro
title: "笔记和Radar简报导出前：编码、换行、引号与分隔符核对"
description: "区分UTF-8 Markdown、共享收件箱清单和源JSON，检查字符/字节与字符串转义；词表分隔规则不是CSV或JSON转换协议，不新增转码器。"
lang: zh
---

<h2 id="first-answer">先确认导出载体和消费者，不能把所有逗号都当作字段分隔</h2>

一呼较长笔记的现有暂存路径写UTF-8 Markdown；共享收件箱也有自己的内部JSON清单，而Radar读另一套快照模型。三者不能因“都是文字文件”而互换。编码、换行、引号转义、字符数和字段契约须分别核对；本文不提供CSV导出、转码器或自动修复真实文件功能。

## 与术语解析、JSON类型和改版评审的分工

术语前检解释词表按哪些符号拆项，JSON类型检查关注字段形态，改版评审关注契约变化。这里核的是**已经选定载体中的文字怎样序列化与被读取**，不是改变术语含义、模型设置或来源字段。

## 编码与分隔检查表

<div role="region" aria-label="导出编码与分隔符核对表，可左右滚动" tabindex="0">

| 对象 | 已核实现/语义 | 应核对的边界 | 不应推断 |
| --- | --- | --- | --- |
| 笔记短文字 | 当前按transcript的Swift Character计数决定文字/附件路径 | 3000门槛不是UTF-8字节或录音时长 | 汉字、组合字符都按单字节计算 |
| 较长笔记附件 | 现有路径写Markdown，encoding为utf8 | 文件正文、标题、换行与实际消费者 | 任意文件都是同编码，或有CSV/通用转码支持 |
| 收件箱manifest | JSONEncoder编码内部共享批次 | 内部清单不是Radar快照契约 | 改名.json就能导入Radar |
| 源Radar JSON | 按实际消费者JSONDecoder与模型读取 | 语法、类型、大小、日期和身份分别核 | 本文宣称所有输入只接受一种编码或自动纠错 |
| 逗号/分号 | 在JSON字符串内可以只是数据 | 引号内外语义，不能套词表拆项规则 | 逗号必然代表新的任务或字段 |
| 换行/引号 | JSON字符串须遵守转义语法 | \n、双引号和反斜线的实际内容 | 把字面反斜线n和换行混为同一字节序列 |
| Unicode文字 | 字符、UTF-8字节与语言语义不同 | 先核实际编码与保留原文 | 看起来相同就证明字节完全相同 |
| 文件名/副本 | 扩展名、保存时间和正文契约分开 | 目的地与已有交接状态 | 换后缀/文件名可以绕过一次交接或权限 |

</div>

## 一个JSON字符串语法片段

下例只示意字符串，**不是完整Radar快照**，缺少真实导入所需的其他模型字段，也不是App生成的样例输出。

```json
{
  "title": "Sample, A",
  "next": "Line1\nLine2"
}
```

解析后逗号仍属于title，转义换行属于next内容。若想保留字面上的反斜线和n，序列化方式又不同；不要用简单的“按逗号切开”处理JSON。词表解析会拆某些标点，不意味着导出正文也适用该规则。

合成文本“样例A”由三个简单字符组成，UTF-8为七字节；这个例子说明计数不同，不提供通用字符计数器，更不能把JavaScript字符串长度直接当Swift Character门槛。

## 导出前后的保留检查

先用不含真实数据的样例确认目标工具按什么类型读取，再核原文与已读回内容，不为修复显示异常重写真实来源。不要在不了解编码/消费者时直接删字节、去掉引号或把错误字段补为当前时间。

字符显示正常只证明可见结果，不证明来源身份、模型校验或送达；文件写出也只是本地/暂存阶段。笔记原有交接标记、目标许可与不确定停止边界不变，修订编码或改文件名不授予重发权。

## FAQ

<h3 id="faq-markdown">一呼长笔记导出就是CSV吗？</h3>

不是。引用的现有路径写UTF-8 Markdown，并通过已有收件箱暂存；本文不新增CSV导出或字段转换。

<h3 id="faq-manifest">收件箱manifest.json可以当Radar任务源吗？</h3>

不能。内部批次清单和Radar快照有不同模型，扩展名相同不等于契约相同。

<h3 id="faq-comma">JSON里的逗号都能按词表规则拆吗？</h3>

不能。引号内可能是数据，JSON有自己的语法；词表分隔规则不属于JSON/CSV通用解析器。

<h3 id="faq-count">3000字门槛是不是3000个UTF-8字节？</h3>

不是。当前笔记门槛用Swift Character计数，不能与编码字节、Unicode标量或录音时长混用。

<h3 id="faq-encoding">中文显示异常时可以随便重编码再交接吗？</h3>

不要盲目修复。先核来源编码、目标契约和原结果，保留原文；改编码不抹去已尝试交接或重复风险。

<h3 id="faq-fixture">语法片段能证明实际App导入通过吗？</h3>

不能。这里只核字符串示意，不替代完整模型、实际版本解码、权限和设备验收。

## 相关指南与源码

[术语分隔与长度](/guides/multilingual-terms-preflight/) · [JSON类型/空值](/guides/radar-json-null-validation/) · [格式改版](/guides/brief-format-change-compatibility/) · [笔记一次交接](/guides/recording-notes-handoff/) · [开始](/start/) · [隐私](/privacy/)

依据：[笔记Markdown写出与门槛](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift)、[内部共享清单](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/CollieShareInbox.swift)、[Radar模型](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift)。
