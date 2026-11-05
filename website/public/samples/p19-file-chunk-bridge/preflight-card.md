# SYN-CHK-40 — 文件分片/上传回执与收件箱证据 / Chunk bridge preflight

**SYNTHETIC_EXAMPLE**，不是App导入协议、客户附件、真实共享容器/配对日志或服务完成回执。Fixed actual-M631bb2f6744ffbe573f18a39829c9a72c8d17226 / treec6b0fa38020ff30f7f907269f02698842a55621d. Source VM or host tests cannot certify AppStore review, installed-binary parity or remote API acceptance.

## 证据阶梯 / Evidence ladder

原始文件可读 → base64块被helper接纳 → JS parts组成File → 页面文件input接纳并触发input/change → 网站自行上传/服务处理 → 业务完成，**不是一个回执**。768KiB=786432原始字节，base64编码/JS parts/File额外开销，不宣全端恒定内存、网络吞吐、断点续传或远端落盘。

AppGroup配置意图、签名entitlement、runtime containerURL、目录/manifest可见、JSON Codable解析、文件存在/内容验证、业务导入也分别取证。`pending()`读取/解码失败会跳过，返回[]可能是空目录或不可读路径，不能由[]唯一诊断网络/权限故障。合法manifest可指缺payload，也可被update成空items而仍解码；**解析成功本身仍非成功导入**。

## 实际执行与替身 / Executed and not executed

- 每语16个原attachFiles/trust分支，WK响应为显式替身，不执行真实WK/上传页面。begin的Bool回报原生未检查（只等调用成功），chunk Bool逐块检查；不要发明begin=false必立即中断。原路径按isTrusted核origin，不等文字插入的完整page/request守卫；N13同origin换path仅核原生分支，不保证真实导航后helper仍存在。
- 每语5个原base64Chunk读文件例，Foundation FileHandle/Task.detached/offset/base64真实，仅用自建临时合成文件（最大约1.5MiB），比对重组字节：0/1/786432/786433/1572881。不是读客户文件、恒定内存、服务端hash或resume验证。
- 每语11个完整原CollieShareInbox在`init(root:)`自建临时目录执行，真实Foundation/UTType/原save/pending/update：孤文件、坏JSON、坏schema、缺payload、copy不move、空save回滚、内联文字、重名、排序、空items、缺root。**不调用shared()，不访问真实AppGroup或改entitlement**；只在本测试新建目录内触发原回滚，未清共享依赖/客户/生产数据。
- 每语17个原Swift产出JS的Node vm例。File/DataTransfer/input是最小合成对象，atob为Node实现，只核原helper分支/提供字节，不是browser FilePicker/Blob/框架/远端上传认证。没有上传/submit API，假控件仅记录input/change；第三方网站可能自动处理这些事件，不能泛化全站无副作用。

## 不捏造传输校验 / No invented integrity protocol

正常示例重组字节比对由测试端完成，**源helper没有chunk序号、累计长度/校验和或服务端ack协议**。重复块、乱序、缺块、同ID重begin覆盖都可产生“attached但内容不同/更短”；这不是宣真实传输出了故障，而是说明attached不足以证明完整性，不能改ID/整批盲重发。C14缺一个请求ID可filter后只附现有文件子集，也不能把附了一个当全批齐。

`collieNativeAttachFiles`先取出并删除incoming IDs，之后才找控件；no-input/single-only时暂存可能已消耗，不是自动重试缓存。重复attach同ID可failed；discard只清JS helper，不撤服务器副本。accept/extension/MIME检查是控件选择条件，不是内容安全检查或任意类型兼容；空file亦可交页面，不等服务接收。

## 全双语工作表 / Complete bilingual worksheet

### zh

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| N1 | no_web | {'result': 'failed', 'roles': []} | Original Swift + fake WK replies; not server upload |
| N2 | untrusted | {'result': 'failed', 'roles': []} | Original Swift + fake WK replies; not server upload |
| N3 | normal | {'result': 'attached', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N4 | no_input | {'result': 'noUploadControl', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N5 | single_only | {'result': 'oneAtATime', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N6 | unknown | {'result': 'failed', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N7 | chunk_false | {'result': 'failed', 'roles': ['begin', 'chunk', 'discard']} | Original Swift + fake WK replies; not server upload |
| N8 | chunk_throw | {'result': 'failed', 'roles': ['begin', 'chunk', 'discard']} | Original Swift + fake WK replies; not server upload |
| N9 | begin_throw | {'result': 'failed', 'roles': ['begin', 'discard']} | Original Swift + fake WK replies; not server upload |
| N10 | begin_false | {'result': 'attached', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N11 | attach_throw | {'result': 'failed', 'roles': ['begin', 'chunk', 'attach', 'discard']} | Original Swift + fake WK replies; not server upload |
| N12 | origin_drift | {'result': 'failed', 'roles': ['begin', 'chunk', 'discard']} | Original Swift + fake WK replies; not server upload |
| N13 | same_origin_path_drift | {'result': 'attached', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N14 | empty_file | {'result': 'attached', 'roles': ['begin', 'attach']} | Original Swift + fake WK replies; not server upload |
| N15 | empty_files | {'result': 'failed', 'roles': ['attach']} | Original Swift + fake WK replies; not server upload |
| N16 | two_chunks | {'result': 'attached', 'roles': ['begin', 'chunk', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| F1 | synthetic file bytes=0 | actual source raw chunks=[]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F2 | synthetic file bytes=1 | actual source raw chunks=[1]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F3 | synthetic file bytes=786432 | actual source raw chunks=[786432]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F4 | synthetic file bytes=786433 | actual source raw chunks=[786432, 1]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F5 | synthetic file bytes=1572881 | actual source raw chunks=[786432, 786432, 17]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| C1 | normal | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C2 | binary_split | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C3 | unknown_chunk | false | Original emitted JS with synthetic File/DataTransfer/input |
| C4 | duplicate | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C5 | reordered | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C6 | missing_chunk | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C7 | invalid_base64 | throws | Original emitted JS with synthetic File/DataTransfer/input |
| C8 | discard | false | Original emitted JS with synthetic File/DataTransfer/input |
| C9 | rebegin | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C10 | no_input | no-input | Original emitted JS with synthetic File/DataTransfer/input |
| C11 | single_only | single-only | Original emitted JS with synthetic File/DataTransfer/input |
| C12 | type_mismatch | no-input | Original emitted JS with synthetic File/DataTransfer/input |
| C13 | multiple | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C14 | partial_ids | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C15 | empty_file | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C16 | repeat_attach | failed | Original emitted JS with synthetic File/DataTransfer/input |
| C17 | empty_mime | attached | Original emitted JS with synthetic File/DataTransfer/input |
| I1 | orphan_file | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I2 | corrupt_json | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I3 | invalid_schema | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I4 | missing_payload | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I5 | save_copy | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I6 | empty_save_rollback | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I7 | inline_text | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I8 | duplicate_names | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I9 | oldest_first | pending decoded batches=2 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I10 | update_empty_items | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I11 | missing_root | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| R1 | AppGroup入口/声明/签名/解析分别留证 | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |
| R2 | attached不等远端上传或业务发送 | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |
| R3 | 分片无序号/校验和/断点续传保证 | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |
| R4 | 清JS暂存/移出批次不等撤回服务副本 | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |

### en

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| N1 | no_web | {'result': 'failed', 'roles': []} | Original Swift + fake WK replies; not server upload |
| N2 | untrusted | {'result': 'failed', 'roles': []} | Original Swift + fake WK replies; not server upload |
| N3 | normal | {'result': 'attached', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N4 | no_input | {'result': 'noUploadControl', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N5 | single_only | {'result': 'oneAtATime', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N6 | unknown | {'result': 'failed', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N7 | chunk_false | {'result': 'failed', 'roles': ['begin', 'chunk', 'discard']} | Original Swift + fake WK replies; not server upload |
| N8 | chunk_throw | {'result': 'failed', 'roles': ['begin', 'chunk', 'discard']} | Original Swift + fake WK replies; not server upload |
| N9 | begin_throw | {'result': 'failed', 'roles': ['begin', 'discard']} | Original Swift + fake WK replies; not server upload |
| N10 | begin_false | {'result': 'attached', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N11 | attach_throw | {'result': 'failed', 'roles': ['begin', 'chunk', 'attach', 'discard']} | Original Swift + fake WK replies; not server upload |
| N12 | origin_drift | {'result': 'failed', 'roles': ['begin', 'chunk', 'discard']} | Original Swift + fake WK replies; not server upload |
| N13 | same_origin_path_drift | {'result': 'attached', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N14 | empty_file | {'result': 'attached', 'roles': ['begin', 'attach']} | Original Swift + fake WK replies; not server upload |
| N15 | empty_files | {'result': 'failed', 'roles': ['attach']} | Original Swift + fake WK replies; not server upload |
| N16 | two_chunks | {'result': 'attached', 'roles': ['begin', 'chunk', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| F1 | synthetic file bytes=0 | actual source raw chunks=[]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F2 | synthetic file bytes=1 | actual source raw chunks=[1]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F3 | synthetic file bytes=786432 | actual source raw chunks=[786432]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F4 | synthetic file bytes=786433 | actual source raw chunks=[786432, 1]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F5 | synthetic file bytes=1572881 | actual source raw chunks=[786432, 786432, 17]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| C1 | normal | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C2 | binary_split | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C3 | unknown_chunk | false | Original emitted JS with synthetic File/DataTransfer/input |
| C4 | duplicate | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C5 | reordered | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C6 | missing_chunk | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C7 | invalid_base64 | throws | Original emitted JS with synthetic File/DataTransfer/input |
| C8 | discard | false | Original emitted JS with synthetic File/DataTransfer/input |
| C9 | rebegin | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C10 | no_input | no-input | Original emitted JS with synthetic File/DataTransfer/input |
| C11 | single_only | single-only | Original emitted JS with synthetic File/DataTransfer/input |
| C12 | type_mismatch | no-input | Original emitted JS with synthetic File/DataTransfer/input |
| C13 | multiple | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C14 | partial_ids | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C15 | empty_file | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C16 | repeat_attach | failed | Original emitted JS with synthetic File/DataTransfer/input |
| C17 | empty_mime | attached | Original emitted JS with synthetic File/DataTransfer/input |
| I1 | orphan_file | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I2 | corrupt_json | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I3 | invalid_schema | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I4 | missing_payload | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I5 | save_copy | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I6 | empty_save_rollback | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I7 | inline_text | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I8 | duplicate_names | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I9 | oldest_first | pending decoded batches=2 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I10 | update_empty_items | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I11 | missing_root | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| R1 | AppGroup access/declarations/signature/parse need separate evidence | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |
| R2 | attached is not remote upload or business send | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |
| R3 | Chunks have no sequence/checksum/resume guarantee | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |
| R4 | Discard/staging removal is not remote revocation | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |

## No-Go、商店与隐私 / Limits and stop criteria

Only chunk true/attached, missing requested IDs/parts, parsed manifest without payload/import receipt, or unknown prior effects => stop at the known layer; preserve original batch/request/stage and unknowns, check target and independent page/server result, no blind refill/resend or extension renaming to bypass accept.

200MiB is local staged-file budget in source, not a web/remote capacity guarantee; no200MiB stress file allocated here. Root injection does not grant AppGroup registration/signature/cross-extension rights; Bundle key YihuAppGroup, build variable YIHU_APP_GROUP and system entitlement remain distinct source concepts, not signed-artifact evidence.

官方US商店沿11/05保存观察0.1.0/id6819057500/iOS18+，非本轮最新/全球供应/审核或同版证明。商店无需Mac/Xcode/自签名；自己的可信HTTPS工作台/账号、可选模型约950MB、权限/目的地另核，目的地可能存/同步/自动处理。https://apps.apple.com/us/app/yihu/id6819057500

Real AppGroup/container/signature/cross-extension, WK/page controls, remote upload/completion/hash/resume, AppStore review, customer-file import, destination storage/sync, account authorization/business send and hardware memory/latency/SLA: **not_run**.

Only3 public resources on active file-chunk pair, retired AppGroup pair stays false/no downloads/Store card/own sitemap or LLM entry. Source canonical getyihu.com unchanged; dispatch yihu.st not migration authorization. No Google re-pull, production/index action or marketing submission.
