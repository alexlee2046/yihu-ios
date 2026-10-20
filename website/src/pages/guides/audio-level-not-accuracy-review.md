---
layout: ../../layouts/Wave3Guide.astro
title: "音量条能证明什么？RMS电平不是识别概率、风噪评分或送达"
description: "核短语音与长笔记不同RMS缩放、裁剪及显示范围；电平不是校准分贝或内容真实性，不作实际录音、噪声与准确率测试。"
lang: zh
---

<h2 id="first-answer">电平有变化不等于说对了，条满也不是100%识别成功</h2>

短语音PCM管线从样本RMS缩放并限制到0至1，长笔记写入路径用另一缩放系数。它们是电平显示，不是识别置信度、声纹身份、风噪等级或送达回执。不同路径同一条长也不能直接比较音质；本页不新增声学评分或校准工具。

## 与无声排障、声纹和原话核对的区别

排障核哪里无声，声纹核便捷过滤范围，听核核实际内容；这里核**电平公式与UI显示最多能支持什么结论**。不采集真实音频或设置系统音量。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 短语音电平 | RMS乘2后限制范围 | 显示比例与原始样本 | 0.5就是50%识别概率 |
| 长笔记电平 | RMS乘12并上限1 | 不同路径缩放不同 | 同条长代表同音压/音质 |
| 上限裁剪 | 较大值可都显示满 | 信号与显示饱和区别 | 100%就每词正确 |
| 接近0 | 可能安静/尚无新样本等 | 实际状态、输入和错误 | 必定没权限/没录到任何内容 |
| 定时显示 | 读当前管线电平 | 显示时点与final分开 | 实时无延迟或全程已保存 |
| RMS度量 | 样本能量统计 | 未校准设备/环境 | 标准dB SPL或噪声认证 |
| 文字与身份 | ASR/声纹另有路径 | 实际结果和原文 | 有电平就识别/本人确认通过 |
| 交接证据 | 目标/回执仍另核 | 已保存与已送达分别看 | 电平截图代替业务完成 |

</div>

## 合成数值示意

用两个合成样本0.1与-0.1，RMS为0.1。短语音公式示意约0.2；长笔记缩放到1.2后裁剪为1。只是数学示意，不是麦克风实测、物理音压或路径对比成绩。

看到满条应继续核实际内容与错误，不从显示推导权限、模型就绪或目标选择。声音是敏感材料，公开检查不需要客户录音；本文未做设备、风噪或识别准确率验收。

## FAQ

<h3 id="faq-1">满条是否100%识别成功？</h3>

不是。它是电平显示裁剪，不是ASR置信度。

<h3 id="faq-2">两条路径同样长度可比较音质吗？</h3>

不能直接比，缩放不同且未校准声学量。

<h3 id="faq-3">零电平就能证明没授权吗？</h3>

不能单独证明，应核实际授权、路由、采集和错误。

<h3 id="faq-4">RMS是否标准分贝读数？</h3>

不是本文提供的校准dB SPL测量，不推标准声学认证。

<h3 id="faq-5">电平正常是否证明说话人正确或内容完整？</h3>

不证明。声纹、原词、保存和转写结果分别核。

<h3 id="faq-6">本文运行过噪声/麦克风测试吗？</h3>

没有。合成数学示意不冒设备或真实场景成绩。

## 相关指南与源码

[输入排障](/guides/bluetooth-audio-input-troubleshooting/) · [声纹范围](/guides/voiceprint-filter-not-authorization/) · [音文材料](/guides/note-audio-text-evidence-mapping/) · [预览与final](/guides/capture-buffer-pressure-checklist/) · [开始](/start/) · [隐私](/privacy/)

[短语音RMS](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/ColliePCMStream.swift) · [长笔记电平](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieNoteRecorder.swift) · [电平显示读取](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift)
