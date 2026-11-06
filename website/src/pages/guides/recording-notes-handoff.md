---
layout: ../../layouts/Wave3Guide.astro
title: "把录音整理成行动项：原文、结论与下一步放在一起"
description: "SYN-REC-41 synthetic / non-clinical preflight: /samples/p20-recording-notes-handoff/preflight.zh.json · /samples/p20-recording-notes-handoff/preflight.en.json. 从iPhone录音笔记到可跟进的结构化待办，展示一份合成会后笔记，并比较纯转写与行动项工作流。"
lang: zh
preview: voice
voiceSample: meeting
---

<h2 id="syn-rec-41">SYN-REC-41：录音纪要交接与时间核对边界</h2>

SYNTHETIC_EXAMPLE，时间表是外部人工工作表，非原生逐词时间戳；排除诊断/医嘱决策，不冒自动医疗过滤。

[ZH: /samples/p20-recording-notes-handoff/preflight.zh.json](/samples/p20-recording-notes-handoff/preflight.zh.json) · [EN: /samples/p20-recording-notes-handoff/preflight.en.json](/samples/p20-recording-notes-handoff/preflight.en.json) · [Card: /samples/p20-recording-notes-handoff/preflight-card.md](/samples/p20-recording-notes-handoff/preflight-card.md)

<div role="region" aria-label="合成录音纪要/分段/交接/医疗排除核对表，可左右滚动" tabindex="0">

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| S1 | short;frames=16000;final=False | keep=16000 frames, synthetic seconds=1.0 | Synthetic array energy only, not word timestamps/ASR accuracy |
| S2 | final_full;frames=448000;final=True | keep=448000 frames, synthetic seconds=28.0 | Synthetic array energy only, not word timestamps/ASR accuracy |
| S3 | zeros;frames=448000;final=False | keep=320800 frames, synthetic seconds=20.05 | Synthetic array energy only, not word timestamps/ASR accuracy |
| S4 | quiet25;frames=448000;final=False | keep=400800 frames, synthetic seconds=25.05 | Synthetic array energy only, not word timestamps/ASR accuracy |
| S5 | quiet_last;frames=448000;final=False | keep=447200 frames, synthetic seconds=27.95 | Synthetic array energy only, not word timestamps/ASR accuracy |
| S6 | equal_energy;frames=448000;final=False | keep=320800 frames, synthetic seconds=20.05 | Synthetic array energy only, not word timestamps/ASR accuracy |
| S7 | quiet_before_search;frames=448000;final=False | keep=320800 frames, synthetic seconds=20.05 | Synthetic array energy only, not word timestamps/ASR accuracy |
| S8 | empty;frames=0;final=False | keep=0 frames, synthetic seconds=0.0 | Synthetic array energy only, not word timestamps/ASR accuracy |
| J1 | ''+'Hello' | 'Hello' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| J2 | 'Plan'+'B' | 'Plan B' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| J3 | 'Owner'+'已确认' | 'Owner已确认' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| J4 | '待定'+'Next' | '待定Next' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| J5 | 'Note.'+'Next' | 'Note.Next' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| J6 | 'alpha '+'beta' | 'alpha beta' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| J7 | 'é'+'x' | 'éx' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| J8 | 'hi'+'' | 'hi' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| H1 | short | {'success': True, 'reserved': True, 'save_calls': 1, 'material': 'text'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H2 | exact3000 | {'success': True, 'reserved': True, 'save_calls': 1, 'material': 'text'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H3 | over3000 | {'success': True, 'reserved': True, 'save_calls': 1, 'material': 'markdown'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H4 | attempted | {'success': False, 'reserved': True, 'save_calls': 0, 'material': 'none'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H5 | inbox_fail | {'success': False, 'reserved': True, 'save_calls': 1, 'material': 'none'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H6 | no_inbox | {'success': False, 'reserved': False, 'save_calls': 0, 'material': 'none'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H7 | pending | {'success': False, 'reserved': False, 'save_calls': 0, 'material': 'none'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H8 | empty | {'success': False, 'reserved': False, 'save_calls': 0, 'material': 'none'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H9 | reserve_write_fail | {'success': False, 'reserved': False, 'save_calls': 0, 'material': 'none'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H10 | whitespace | {'success': True, 'reserved': True, 'save_calls': 1, 'material': 'text'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H11 | unicode3000 | {'success': True, 'reserved': True, 'save_calls': 1, 'material': 'text'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| L1 | [{'start_frame': 0, 'end_frame': 336800, 'review_text': 'SYNTHETIC_EXAMPLE: 场地验收仍待复核。', 'speaker': 'unknown'}, {'start_frame': 336800, 'end_frame': 768000, 'review_text': '负责人和截止日期未确认，不得对外写成承诺。', 'speaker': 'unknown'}] | structurally_contiguous_not_verified_alignment | Independent manual review ledger, not native exported/aligned timestamps |
| L2 | [{'start_frame': 0, 'end_frame': 16000}, {'start_frame': 18000, 'end_frame': 32000}] | review_gap | Independent manual review ledger, not native exported/aligned timestamps |
| L3 | [{'start_frame': 0, 'end_frame': 16000}, {'start_frame': 15000, 'end_frame': 32000}] | review_overlap | Independent manual review ledger, not native exported/aligned timestamps |
| L4 | [{'start_frame': 16000, 'end_frame': 0}] | reject_interval | Independent manual review ledger, not native exported/aligned timestamps |
| L5 | [{'start_frame': -1, 'end_frame': 16000}] | reject_interval | Independent manual review ledger, not native exported/aligned timestamps |
| E1 | ordinary_meeting_minutes | human_fact_review_only | Explicit sample category only; no App clinical filter or medical inference |
| E2 | diagnosis_request | excluded_medical_decision | Explicit sample category only; no App clinical filter or medical inference |
| E3 | prescription_or_treatment_order | excluded_medical_decision | Explicit sample category only; no App clinical filter or medical inference |
| E4 | uncertain_clinical_inference_from_transcript | excluded_medical_decision | Explicit sample category only; no App clinical filter or medical inference |

</div>

原模型持久化平面transcript与16k帧checkpoint，不保存本包逐段时间/说话人标签；低能量切点不是词边界/准确率保证。会议纪要是整理提示，非本机已生成纪要；负责人/日期/否定与提议须回原文复核，缺的待确认。医学诊断、处方/治疗医嘱或临床推断不在本样本用途内，应交合格专业人员按适当流程处理，不生成/执行医疗决策。源方法并未因本卡新增自动医疗内容过滤。原交接先持久reserve，3000 Character以内文本、超过则Markdown，仅导出文字不附原录音；下游失败仍可能保已尝试标记，不自动重试/转存。商店版无需Mac/自签名；真实录音/ASR对齐/诊疗/目的地写入发送全not_run，目的地可存/同步/自动处理。

<h2 id="first-answer">先找到一个有用的下一步</h2>

先保留原录音与转写，再把材料交给你选择的工作台或工具整理。把“已确认的事”“要跟进的事”“还要问的问题”分开，下一次打开手机就知道先做什么。

## 一份会后笔记，可以更容易接着做

以下为合成示例，不含真实会议或客户资料：

<div role="region" aria-label="从录文到行动项" tabindex="0">

| 材料 | 示例 | 如何使用 |
|---|---|---|
| 原录文 | “规格资料还不齐，先确认报价需要哪些参数，交期等核过再回复。” | 保留原话，回来检查数字和条件。 |
| 结论 | 报价前先补齐规格资料。 | 与原文核对后再使用。 |
| 待办 | 列出缺失参数，交给对应同事确认。 | 负责人和时间未提供时写“待确认”。 |
| 待确认项 | 交期、最终报价范围。 | 资料齐后再答复，不从摘要补出承诺。 |

</div>

<h2 id="compare">转文字工具，还是录文→行动项工作流？</h2>

<div role="region" aria-label="录音笔记工具选型" tabindex="0">

| 你的任务 | 更合适的起点 | 需要多做的一步 |
|---|---|---|
| 只要保存录音并得到文字 | 独立录音/转录工具 | 核对文字、存储与分享设置。 |
| 要整理讨论结论和待办 | 原录文加整理工具 | 对照原文确认负责人、时间、提议与结论。 |
| 已有Agent网页工作台，要在手机继续处理 | 一呼录音笔记加你的工作台 | 准备模型与接入条件，选择交接方式并检查结果。 |

</div>

## 用一呼接续

1. 在iPhone录音，保留本地音频和分段转写。
2. 核对人名、数字与前后语境。
3. 选择整理提示及交接目的地；较长文本可通过已有Markdown材料路径带入。
4. 在所选工作台/工具查看整理结果，再决定下一步。

“会议纪要”是整理提示，不是本机已经生成的完整纪要。开始前请征得参与者所需的录音同意，并准备语音模型和自己的工作台。

<h2 id="same-task">拿同一段录音，比较最后能不能接着做</h2>

用上方合成录文作共同输入。核对的是能否找到下一步和原文依据，而不是生成的段落看起来多流畅。

<div role="region" aria-label="纯转写与行动项工作流比较" tabindex="0">

| 核对项 | 只要转写 | 录文→行动项工作流 |
|---|---|---|
| 期望结果 | 可查的文字与对应录音。 | 结论、行动项、待确认问题，与原文放在一起。 |
| 多做哪一步 | 修订需要使用的识别文字。 | 分清提议与结论，核人名、数字、负责人和时间。 |
| 信息缺失 | 标出听不清的词。 | 负责人和截止时间待确认，不猜一个人选或日期。 |
| 资料处理 | 看所选工具的保存与导出设置。 | 同时了解录音工具与整理目的地，只带入需要的材料。 |
| 一呼的位置 | 轻量转录工具可能已经满足需求。 | 本地笔记接续已有Agent工作台，先准备模型与签名。 |

</div>

这份样例复核后的下一步可以是“列出缺少的规格参数，负责人和时间待确认”。保留原文，并在再次交接前核目的地已有草稿。[使用会后笔记模板](/guides/meeting-notes-brief-fields/)。

## FAQ

<h3 id="faq-tool">只有转写需求，需要配置工作台吗？</h3>

独立录音或转录工具可能更省步骤；一呼更适合本来就有网页Agent工作台、想继续整理和跟进的人。

<h3 id="faq-action">负责人和截止时间能自动补出来吗？</h3>

先以原文为准，缺的标待确认。整理工具生成的结果仍应核对，尤其报价、交期和对外承诺。

<h3 id="faq-material">交接的是录音还是文字？</h3>

现有笔记交接使用文字或Markdown全文材料。音频与文字在本地保留，按你选择的出口分别检查交接内容。

<h3 id="faq-original">整理后为什么还留原文？</h3>

方便发现识别差异、回看上下文，并区分讨论提议与真正结论。

## 接着看

[语音草稿](/guides/iphone-agent-voice-drafts/) · [音频排障](/guides/bluetooth-audio-input-troubleshooting/) · [录音笔记](/guides/recording-notes-handoff/) · [每日简报](/guides/multi-project-radar-watch/) · [接入条件](/start/) · [隐私](/privacy/)

<details><summary>实现参考</summary>

[冻结实现](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift) · [README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)

</details>
