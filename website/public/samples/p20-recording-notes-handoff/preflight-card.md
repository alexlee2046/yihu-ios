# SYN-REC-41 — 录音纪要交接、外部时间核对与医疗排除

**SYNTHETIC_EXAMPLE** · Recording-note handoff, external timeline and medical exclusions. Not real audio/customer/patient data, App import protocol or delivery/clinical receipt. Fixed actual-M6e8dc35d713b418e2d8e6b256e887cb9a237f104 / tree1ae994ef9e4a2e3ba83252929bf45c6f8278eee4. Installing/merging source does not establish store-binary feature parity.

## 先分原生事实与外部工作表 / Native facts vs review worksheet

原CollieVoiceNote只存平面transcript、transcribedFrames(16kHz已转帧checkpoint)等，不存本包逐段/逐词时间戳、说话人/诊断标签。外部L1–L5手工描述起止帧并作frame/16000算术核对，**不是原生导出、真实ASR对齐、采集绝对时钟或说话人证据**。L1的连续帧范围只表示给定合成区间无结构缺口，不证明文字对音频已验证。保原音频/原文另核，不补造医疗/人名/负责人或截止时间。

Source cuts at low-energy100ms bins near the last8s of each28s window, not speech/word recognition. Equal energy selects the first minimum20.05s; quiet-before-search does not move the search. Final/short window is kept whole. These rules do not certify no word splitting or recognizer accuracy. Join only inserts a space between ASCII Latin/digit endpoints, not punctuation, timestamps or speaker labels.

## 诊断/医嘱排除是本卡人工边界 / Medical exclusions are manual scope

E1普通会议仅人工事实复核；E2诊断请求、E3处方/治疗医嘱、E4由录文推临床结论，均排除在本样本用途外。**不生成/执行诊断、用药或治疗决策**；这类工作应由合格专业人员在适当授权/核验流程处理。本包没有患者记录或可操作治疗建议，也不把技术diagnostic日志误作医疗诊断。

The explicit category labels are supplied synthetic review metadata, not an NLP classifier or new automatic medical-content filter in Yihu. Source generic meeting-minutes prompts do not establish clinical safety/accuracy. Do not turn uncertainty, a proposal or quoted medical words into a confirmed instruction. Medical/clinical execution is not_run, regardless of source handoff success.

## 原代码执行范围 / Original-source execution

每语8 cutPoint+8 join+11 reservation/handoff例，完整原CollieNoteSegmenter/CollieVoiceNote及Store reserveHandOff/handOff逐字编译。Foundation数组/JSON原子meta写入和Markdown临时文件真实，但仅本测试拥有目录；inbox为捕获材料/抛错的替身。FileManager facade把该原方法的temporaryDirectory限定到每例独立测试root，defer删除也只允许该前缀，不碰系统共享临时文件/客户/生产资料。未跑真实录音/AVAudioFile逐段ASR、AppGroup、SwiftUI或目的地写入。

- **S1–S8**: source28s/16k/max448000 frame,20–28s search,1600-frame bins, cut at midpoint. Minimum energy is not clinical/speech meaning.
- **J1–J8**: exact original join, e.g. Note.+Next=>Note.Next; no missing punctuation “repair” or new claims.
- **H1–H3/H11**: original transcript Character count<=3000 text, above3000 one Markdown full transcript plus instruction, no original audio attachment.3000 combined graphemes can have6000 scalars; thresholds are not byte/token/seconds. Source UI direct/Radar guards use their own counts; no real UI executed here.
- **H4/H5/H9**: existing attempted rejects; inbox failure after durable reserve leaves attempted true even though staging failed, no automatic retry/alternate handoff. Metadata write failure leaves in-memory marker false. Reservation is not a delivered/processed receipt, nor backend exactly-once proof.
- **H6–H8/H10**: nil inbox/undone/empty fail distinct; whitespace is nonempty and may pass source gate, not proof of useful/accurate minutes. Transcript stays readable/unchanged.

The “meeting minutes” option is an instruction sent with text, not an already generated local summary. Source minute prompts must not be claimed as proof of Agent execution, confirmed facts or clinical approval. Owners/dates absent => pending; preserve proposals, negations and unresolved conditions.

## 完整双语工作表 / Complete bilingual worksheet

### zh

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

### en

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

## 交接、Watch、商店和No-Go / Handoff, Watch and limits

Watch open queued≠phone shown/fresh source/server completion. Frontmost routing and sourceToken/current task/UI gates are separate; open does not inherit all voice/draft taskToken rules. This pack only reads that branch, no Watch message/navigation is executed and no approval/medical authority granted.

Missing source/alignment, uncertain speaker/owner/date, diagnosis/medical-order request, prior attempted handoff or uncertain target effects=>stop blind regeneration/refill/resend. Native frame checkpoint is not a certified timestamp ledger. Saved reservation/inbox stage is not webpage/Agent/business receipt. Destination may save/sync/auto-process; not auto-sending is not a guarantee all data stays local.

US商店沿11/05保存观察0.1.0/id6819057500/iOS18+，非当前最新/全球供应或源码同版；商店安装无需Mac/Xcode/自签名。原页提到签名应区分源码开发条件，自己的可信HTTPS工作台/账号、模型约950MB可选与许可另核。https://apps.apple.com/us/app/yihu/id6819057500

Real mic/lockscreen continuity, AV ASR/word alignment, speaker identity, generated minutes/Agent output, diagnosis/prescription/treatment, actual AppGroup/web handoff/Watch UI/server send/sync/hardware SLA: **not_run**. No diagnosis, medical-order generation, automatic clinical filter or measured accuracy claim.

Only3 public resources on active recording-note pair; retired Watch-open pair stays false/no sample/Store card/own LLM or sitemap entry. Source canonical getyihu.com unchanged, yihu.st not migration authority. No Google re-pull, live website interactions, production/index write or external posting.
