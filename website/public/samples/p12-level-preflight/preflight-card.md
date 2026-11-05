# SYN-LEVEL-35 · 双管线RMS显示缩放/裁剪与静止试音预检
# Two-pipeline RMS display scaling/clipping and stationary voice preflight

**全部合成输入；不是麦克风、风噪、声压或识别测试报告。All inputs synthetic; no microphone, wind-noise, sound-pressure or ASR test report.**

[中文JSON](level-preflight.zh.json) · [English JSON](level-preflight.en.json)

两文件是同一例的语言替代版，不是App可导入配置/实际音频。手工有限Float向量在[-1,1]内，没有采样率、麦克风灵敏度或声学校准；不外推NaN/Infinity行为。1e-6仅为Float数值断言容差，不是硬件/声压/识别准确度。

Choose one language variant, not an app import or recorded audio. Invented finite Float vectors carry no sample rate, microphone sensitivity or acoustic calibration. The1e-6 tolerance concerns numeric assertions only, not device/pressure/recognition accuracy; no NaN/Infinity contract is tested.

## 固定源码究竟计算什么 / What the source computes

- **短语音PCM**：空数组函数返回0；非空时`min(1,max(0,sqrt(sum(sample*sample)/count)*2))`。是当前样本块的显示值，不是全程音质、文字置信度或已经送达。
- **长笔记**：原append先核非空、文件/buffer，**成功写入后**才计算`rms=sqrt(reduce(sample*sample)/count)`并令`level=min(1,rms*12)`，同时增加frames。这里源码只有上限min，不替它新增一个下限max；有限有效输入的RMS本来非负。
- 两路缩放在未裁剪时相差6倍，裁剪后不是统一换算尺；不同采集路径/样本窗也不能当同一实际声学输入。

Short voice scales block RMS by2 and bounds the display to0–1. Note append scales by12 **only after a successful write**, with an upper min and frame update. Below clipping the gains differ sixfold; clipped values and different capture windows are not a common acoustic scale.

真正运行的是原短rms函数和原长append完整方法的隔离适配器；长路buffer、文件和state lock是**内存替身**，没有AVFoundation、真实写盘或并发锁验证。代码中的write failure是合成抛错，不能写成设备存储满实测。

The isolated adapter executes the original short function and entire note append method. Note buffer/file/lock dependencies are **memory spies**, not AVFoundation, storage or lock/concurrency tests. A simulated write error is not a disk-full device result.

## 已填14例参考 / Fourteen worked cases

除Q14外两路各接同一合成向量；Q12/Q13长路预设旧level/frames。下表值按数值容差核，不是0–100%识别概率。

Except Q14, each function receives the same invented vector. Q12/Q13 start with preset old note state. Values are numeric expectations, not recognition percentages.

| 例 / Case | 合成样本 / Synthetic samples | 短显示 / Short | 长显示 / Note | 已填结论 / Worked boundary |
| --- | --- | --- | --- | --- |
| Q1 | ±0.01 | 0.02 | 0.12 | 同输入缩放不同 / different gains |
| Q2 | [0.05,0.05,0.05,0.05] | 0.10 | 0.60 | DC常数也动条，不证明人声 / DC is not speech evidence |
| Q3 | ±0.10 | 0.20 | 1 | 长显示先裁剪 / note display clips first |
| Q4 | ±0.25 | 0.50 | 1 | 不是50% vs100%识别率 / not ASR probabilities |
| Q5 | ±0.50 | 1 | 1 | 短显示到上限 / short reaches its display ceiling |
| Q6 | ±1.00 | 1 | 1 | 与Q5同条，不代表同能量 / same bars, different energy |
| Q7 | [0.2,0.2,0.2,0.2] | 0.40 | 1 | 常数/DC / constant vector |
| Q8 | [0.2,-0.2,0.2,-0.2] | 0.40 | 1 | 与Q7同RMS，不证明同声音 / equal RMS, no audio equivalence |
| Q9 | [1,0,0,0] | 1 | 1 | 单脉冲也可满条 / impulse can fill display |
| Q10 | [0.25,0,0,0] | 0.25 | 1 | 能量按整个数组统计 / block mean matters |
| Q11 | [0,0,0,0] | 0 | 0 | 本例静零输入，不诊断真实权限/路由 / no real permission diagnosis |
| Q12 | []；长旧level=0.7、frames=10 | 0 | **保0.7/10** | 长append无新块不更新 / old note state retained |
| Q13 | ±0.10；长写入替身失败，旧level=0.6/frames=10 | 0.20 | **保0.6/10，failed=true** | 不从旧电平宣新写入成功 / old bar proves no new write |
| Q14 | 短±0.25；长±1/24 / different inputs | 0.50 | 0.50 | 同条长也可来自不同RMS / same bars, different RMS |

Q12短函数返回0不代表实际App“没有新块时条必清零”；整条采集管线/定时UI未运行。Q13两路是独立函数输入，不是同一真实设备同时录出两个结果。显示上限裁剪也**不证明原始麦克风信号发生削波**。

Q12's empty short-function result does not mean the live UI clears without a new block; the full pipeline/UI was not run. Q13 is not simultaneous device recording. **Display saturation does not prove physical microphone clipping.**

## 买方已填判断 / Worked buyer decision

- **满条不是Go。** 先核实际输入/权限/模型/目的地与原词，不能用电平截图替代final或送达；不追求“大声录到满条”。/ A full bar grants no Go; inspect readiness, text and destination instead of chasing the ceiling.
- **零/旧条不能单独诊断。** 可以是本例的零块、没有新更新或失败路径，真实原因须另核，不自动重录、补词或重发。/ Zero or retained bars are not a diagnosis; no automatic recapture, missing-word generation or resend.
- **RMS不是标准dB SPL。** 无麦克风/设备/距离/声学校准，不换算标准声压、风噪评分、听力安全等级或识别准确率。/ No calibrated pressure, noise, hearing-safety or accuracy inference.
- **场景只作安全取样背景。** 户外停稳，门店避开热源/车辆/通道/服务区并取得录音同意；需要即时联络用已有通信方式。本包不做真实风噪对比、提高音量或扰动设备来复现。/ Be stationary, clear of hazards/service areas and obtain consent; use existing communications for urgent contact. No induced noise or device perturbation is performed.

## 独立商店版短句 / Separate store-edition phrase

本包0.1.0范围沿用**11/05已保存的官方美区lookup证据**，不是本轮成功刷新“最新商店版本”的声明：[Yihu id6819057500](https://apps.apple.com/us/app/yihu/id6819057500)，该证据为0.1.0、iOS18+。商店安装**无需Mac/Xcode/自行签名**；源码构建说明是另一条路径。需自有可信工作台/账号、必要权限及模型，可选语音模型约950MB，地区供应以实际商店为准。

Store0.1.0 scope uses the saved official US observation from11/05, not a fresh P12 latest-version confirmation. **No Mac/Xcode/self-signing for store installation**; source building is separate. Bring your own trusted workspace/account, permission/models; optional speech model about950MB. Regional availability follows the storefront. Source formulas do not certify store-binary parity or prove absence.

[中文商店段](https://getyihu.com/start/#store-start) · [English setup](https://getyihu.com/en/start/#store-start)

**可照读中文，理想逐字文本相同，不是已测ASR：**
> 样本三十五。先核对四号标签，不发送，也不覆盖原稿。

**English phrase and ideal verbatim text, not observed ASR:**
> Sample thirty-five. Check label four first; do not send or overwrite the original.

只有另获准且模型/权限/实际输入/目标不会自动执行都已核时，前台使用新空白未发送练习草稿，核35、4和两个否定。已有填入先查看，不盲重插、不按Send/Run、不后台常驻监听；工作台仍可能保存/同步/处理输入。缺证据可继续读本卡，不拿条长补证。

Only separately authorized foreground practice after readiness and destination checks. Review35,4 and both negations; inspect before repeating insertion. No Send/Run or continuous background listening. Destinations may save/sync/process input. Missing evidence is not supplied by bar height; offline use remains available.

**真机麦克风、风噪、标准dB SPL、识别准确率、真实笔记写盘、UI刷新、ASR/填入/发送均not_run。** 没有硬件/声学认证、客户测试或安装转化成绩。

**Device microphone, wind-noise, standard dB SPL, speech accuracy, note storage, UI refresh, ASR/insertion/sending: all not_run.** No hardware/acoustic certification, user test or conversion result.

## 固定源证 / Fixed source references

基底`a8df2f68e9cd22d520e044ca68356e43d48f5152`，不是本窗已发布新资产的证明：
- [短PCM电平/rms](https://github.com/alexlee2046/yihu-ios/blob/a8df2f68e9cd22d520e044ca68356e43d48f5152/Apps/Collie/ColliePCMStream.swift#L318-L431)
- [长笔记写成功后更新电平](https://github.com/alexlee2046/yihu-ios/blob/a8df2f68e9cd22d520e044ca68356e43d48f5152/Apps/Collie/CollieNoteRecorder.swift#L70-L86)
- [中文户外/门店静止试音](https://getyihu.com/guides/outdoor-store-voice-preflight/) · [English stationary trial guide](https://getyihu.com/en/guides/outdoor-store-voice-preflight/)

新写合成材料Apache-2.0；既有源码保原许可。无真实录音、客户正文、设备UID或凭据，不创建声学/识别评分或诊断后台。
