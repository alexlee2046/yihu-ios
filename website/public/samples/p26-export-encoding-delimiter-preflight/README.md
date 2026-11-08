# SYN-ECD-47 · 编码与分隔符自检 / Encoding and delimiter preflight

SYNTHETIC_EXAMPLE · pending · not_run。全部从零合成，不是真实正文、原件编码、导入、权限或送达证明。 / Synthetic from scratch, not real bodies, original encoding, import, authority or delivery evidence.

先核载体与消费者：UTF-8 Markdown、内部manifest、Radar快照互不替代。字符不等字节，词表拆项不是JSON/CSV转换。 / Identify carrier and consumer: UTF-8 Markdown, internal manifests and Radar snapshots are not interchangeable. Characters differ from bytes; vocabulary splitting is not JSON/CSV conversion.

[中文 JSON](/samples/p26-export-encoding-delimiter-preflight/preflight.zh.json) · [English JSON](/samples/p26-export-encoding-delimiter-preflight/preflight.en.json)

<div role="region" aria-label="编码合成核对 / Synthetic encoding review" tabindex="0">

| ID | 检查 / Check | 合成预期 / Synthetic expectation |
| --- | --- | --- |
| T01 | 中文混合 / CJK mixed | Swift Character 3; UTF-8 bytes 7. |
| T02 | 组合字符 / Combining character | Swift Character 1; UTF-8 bytes 3. |
| T03 | 预组字符 / Precomposed character | Swift Character 1; UTF-8 bytes 2. |
| T04 | 组合emoji / Joined emoji | Swift Character 1; UTF-8 bytes 25. |
| T05 | 真实换行 / Actual newline | Swift Character 11; UTF-8 bytes 11. |
| T06 | 字面反斜线n / Literal backslash-n | Swift Character 12; UTF-8 bytes 12. |
| T07 | 引号逗号反斜线 / Quotes comma backslash | Swift Character 9; UTF-8 bytes 9. |
| T08 | CRLF / CRLF | Swift Character 3; UTF-8 bytes 4. |
| T09 | 3000字符 / 3000 characters | Swift Character 3000; UTF-8 bytes 9000. |
| T10 | 3001字符 / 3001 characters | Swift Character 3001; UTF-8 bytes 9003. |
| D01 | 完整最小模型 / Complete minimal model | Original Radar decode: true; utf8. |
| D02 | 字符串分隔与转义 / String delimiters and escaping | Original Radar decode: true; utf8. |
| D03 | 片段非快照 / Fragment is not snapshot | Original Radar decode: false; utf8. |
| D04 | 日期类型错误 / Wrong date type | Original Radar decode: false; utf8. |
| D05 | 无效日期 / Invalid calendar date | Original Radar decode: false; utf8. |
| D06 | JSON裸换行 / Unescaped JSON newline | Original Radar decode: false; raw_unescaped_newline. |
| D07 | 消费者编码实测 / Consumer-specific encoding observation | Original Radar decode: true; utf16le_bom. |
| D08 | 模型字节上限 / Model byte bound | Original Radar decode: false; oversize. |
| C01 | 内部manifest往返 / Internal manifest roundtrip | batch_roundtrip: true; only owned synthetic data. |
| C02 | manifest非Radar / Manifest is not Radar | batch_as_radar: false; only owned synthetic data. |
| C03 | Radar非manifest / Radar is not manifest | radar_as_batch: false; only owned synthetic data. |
| C04 | items类型错误 / Wrong items type | wrong_items_type: false; only owned synthetic data. |
| H01 | 一次标记持久保留 / Durable reservation | normal: true; only owned synthetic data. |
| H02 | 不重置已尝试 / Do not reset attempted | already_attempted: false; only owned synthetic data. |
| H03 | 空录文不交接 / No empty-text reservation | empty: false; only owned synthetic data. |
| H04 | 写失败不冒成功 / Write failure is not success | write_failure: false; only owned synthetic data. |
| M01 | 长笔记分支只核源码 / Long-note branch is source-reviewed | handOff按body.count<=3000走文本，否则写带标题和换行的UTF-8 Markdown；宿主不运行Store.handOff，不新增CSV或通用转码器。 / handOff uses body.count<=3000 for text, otherwise UTF-8 Markdown with heading/newlines. Host does not run Store.handOff; no CSV or universal transcoder. |
| M02 | 分隔规则分账 / Separate delimiter contracts | 词表拆项不是JSON/CSV语法，逗号可属于字符串数据；不拆真实正文，不改字段/时间或修复原件。 / Vocabulary splitting is not JSON/CSV grammar; commas may be string data. Do not split real bodies, rewrite fields/dates or repair originals. |
| M03 | PCM流结束非文本编码 / PCM end is not text encoding | noDataNow保块间状态，finish才endOfStream、最多16次可早停；不是字符/字节/时长或语义断句，不跑音频转换。 / noDataNow preserves block state; finish uses endOfStream, up to 16 calls with early exits. Not characters/bytes/duration/semantic segmentation; no audio conversion run. |
| M04 | 保留原件与交接状态 / Preserve originals and handoff state | 显示正常/文件写出/尾部有输出不证明原件完整、导入或远端完成；改编码/文件名不抹标记、不授重发权，未知即停。 / Readable display/file write/tail output does not prove completeness, import or remote completion. Re-encoding/renaming never resets reservations or grants resend authority; stop when unknown. |

</div>

## 范围与停止 / Scope and stopping

26例/语：10 Foundation字符串/UTF-8临时往返、8原Radar解码、4原内部批次消费者检查、4原Note持久标记；另4人工源码边界不是运行例。原模型/共享清单/Note整文件编译，未运行Store.handOff、真实收件箱、音频、PCM转换、ASR、设备、网页或网络。 / 26 cases per language: 10 Foundation string/temporary UTF-8 roundtrips, 8 original Radar decodes, 4 original batch-consumer checks, 4 original Note reservations; four manual source boundaries are not executions. Whole original model/inbox/Note files compile; no Store.handOff, real inbox, audio, PCM conversion, ASR, device, page or network execution.

T02/T03显示可等价而字节不同，不能用String相等替代字节/SHA检查。D07仅观察本机Foundation接受带BOM UTF16，不新增转码器，不把所有JSON输入宣称只接受UTF-8。 / T02/T03 may display equivalently while bytes differ; String equality is not byte/SHA equality. D07 observes local Foundation accepting BOM UTF16 only, not a new transcoder or a claim all JSON accepts only UTF-8.

原引用、真实编码/消费者验收、许可与远端回执均null。保原件/缺口与已尝试标记；不盲删字节/引号、不补当前时间、不改文件名绕门、不因显示异常重发。目的地可保存同步处理，删除一份不证明全部撤回。 / Original references, actual encoding/consumer acceptance, authority and remote receipts remain null. Preserve originals/gaps/reservations; no blind byte/quote removal, filling current time, rename bypass or resend after display errors. Destinations may save/sync/process; deletion of one copy is not universal recall.

Source: https://github.com/alexlee2046/yihu-ios/blob/5d2944b2444fd345407fd37d082393074a4f3db6/Apps/Collie/CollieVoiceNotes.swift

[中文指南](/guides/export-encoding-delimiter-preflight/) · [English guide](/en/guides/export-encoding-delimiter-preflight/)
