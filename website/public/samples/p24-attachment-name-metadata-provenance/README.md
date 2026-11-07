# SYN-ANM-45 · 附件名称与元数据来源 / Attachment name and metadata provenance

SYNTHETIC_EXAMPLE · pending · not_run. 从零合成，非真实附件、原件映射、版本批准、跨进程权限或远端回执。 Synthetic from scratch, not real attachment, original mapping, revision approval, cross-process authority or remote receipt.

名称编号不是业务版本；MIME来自扩展名，大小不是hash。测试root不证明App Group权限，manifest可见不证明文件齐全或已交付。 / A suffix is not a revision; MIME comes from extensions and size is not a hash. Test roots do not prove App Group authority; manifest visibility does not prove complete files or delivery.

[中文 JSON](/samples/p24-attachment-name-metadata-provenance/preflight.zh.json) · [English JSON](/samples/p24-attachment-name-metadata-provenance/preflight.en.json)

<div role="region" aria-label="附件元数据合成核对 / Synthetic attachment metadata review" tabindex="0">

| ID | 核对 / Check | 合成观察 / Synthetic observation | 边界 / Boundary |
| --- | --- | --- | --- |
| C01 | 批次局部命名 / Batch-local naming | sample.txt → sample.txt；新批次可重用。 / sample.txt stays sample.txt; a fresh batch may reuse it. | 不是全账户去重。 / Not account-wide deduplication. |
| C02 | 大小写冲突 / Case collision | sample.txt 后 SAMPLE.TXT → SAMPLE 2.TXT。 / After sample.txt, SAMPLE.TXT becomes SAMPLE 2.TXT. | 不合并内容；2不是业务版本。 / No content merge; 2 is not a business revision. |
| C03 | 已有编号占位 / Occupied suffix | report.txt/report 2.txt占用时 → report 3.txt。 / Occupied report.txt/report 2.txt yields report 3.txt. | 不是批准顺序。 / Not approval order. |
| C04 | 空名称后备 / Empty-name fallback | 空名 → file，再次空名 → file 2。 / Empty name becomes file, then file 2. | 非原件身份恢复。 / Not recovery of original identity. |
| C05 | 斜线替换 / Slash replacement | a/b.txt → a_b.txt。 / a/b.txt becomes a_b.txt. | 不是任意路径安全认证或恶意软件扫描。 / Not arbitrary-path security certification or malware scanning. |
| C06 | 多段扩展名 / Multiple suffixes | a.tar.gz冲突 → a.tar 2.gz。 / Conflicting a.tar.gz becomes a.tar 2.gz. | 不解包、不验证格式。 / No unpacking or format verification. |
| C07 | 扩展名类型 / Extension-derived type | 合成sample.txt推断text/plain。 / Synthetic sample.txt infers text/plain. | MIME不是内容嗅探、信任或脱敏证明。 / MIME is not content sniffing, trust or redaction. |
| C08 | 同大小异内容 / Equal size, different contents | alpha与bravo各5字节。 / alpha and bravo are each 5 bytes. | 大小相同不是相同SHA或真实性。 / Equal size is not equal SHA or authenticity. |
| C09 | 缺失来源大小 / Missing-source size | byteCount读取不到大小可回0。 / byteCount may return 0 when size cannot be read. | 0不证明真实空文件或复制成功。 / 0 does not prove an empty file or successful copy. |
| C10 | 目录统计 / Directory estimate | 受控目录两份5字节文件合计10。 / Two controlled 5-byte files total 10 in a directory. | 非全链内存、冻结快照或完整性承诺。 / Not total memory, a frozen snapshot or integrity guarantee. |
| C11 | 暂存预算 / Staging budget | 文件测量累计门200MiB=209715200字节。 / Measured file accumulation gate is 200 MiB = 209715200 bytes. | 不是全部文字URL限制或网页上传额度。 / Not a combined text/URL bound or website upload allowance. |
| C12 | 复制与原引用 / Copy and original reference | save复制而非移动文件；合成原文件仍在。 / save copies rather than moves; synthetic original remains. | 没有自动记录原路径/内容hash/批准版本；外部对应表另核。 / No automatic original-path/content-hash/approved-version ledger; review the external mapping separately. |
| C13 | manifest最后写 / Manifest written last | 先复制文件，最后原子写manifest。 / Copy files first; atomically write manifest last. | 不是跨进程锁、所有文件事务或真实Extension取证。 / Not a cross-process lock, whole-file transaction or real Extension evidence. |
| C14 | pending解析边界 / pending decode boundary | 坏JSON被跳过；合法manifest即使缺副本也可返回。 / Bad JSON is skipped; a valid manifest may return even with a missing copy. | 可见不等文件齐全、已导入或已交付。 / Visibility does not prove files complete, import or delivery. |
| C15 | App Group三层证据 / Three App Group evidence layers | 源码声明、最终签名、系统containerURL分别留证。 / Record source declaration, final signature and system containerURL separately. | 测试root可写不等系统共享权限；nil非唯一网络故障。 / Writable test root is not system authority; nil is not a unique network diagnosis. |
| C16 | 目的地与副本 / Destination and copies | 按获准原引用核版本与必要副本，未知即停。 / Review revisions and necessary copies against authorized originals; stop when unknown. | 填入/attached非远端完成；目的地可保存同步处理，discard非服务器撤回。 / Insertion/attached is not remote completion; destination may save/sync/process; discard is not server revocation. |

</div>

## 人工对应表 / Manual provenance worksheet

原引用、实际业务版本、实际内容SHA256、签名权限、系统容器结果与远端回执全部未知/null，不能用示例回填真实台账。batch/item UUID区分本地条目，不代替来源链或账户身份。 / Original reference, actual revision, actual content SHA256, signed authority, system access and remote receipt remain unknown/null; never fill a real ledger with synthetic values. Batch/item UUIDs distinguish local items, not provenance or account identity.

仅在既有获准流程核原件与副本，未知就停；不上传附件、不收集私人正文、不改名伪装、不盲重试。原件/暂存/页面/服务/备份副本分账，删除一份不证明全部删除。目标可保存、同步或自动处理。 / Review originals and copies only within existing authority; stop when unknown. No attachment upload, private text collection, disguised format or blind retry. Original/staging/page/service/backup copies differ; deleting one does not prove erasure everywhere. Destinations may save, sync or process.

## 验证范围 / Verification scope

原Shared/CollieShareInbox.swift宿主测试只在自建临时目录：12命名+5大小/常量+9复制/解析检查。无真实App Group、签名、Extension并发、UI、网页上传或网络测试，不是商店二进制同版证明。 / Original Shared/CollieShareInbox.swift host checks only in an owned temporary root: 12 naming + 5 size/constant + 9 copy/decode checks. No real App Group, signing, Extension concurrency, UI, website upload or network execution; no store-binary parity claim.

Source: https://github.com/alexlee2046/yihu-ios/blob/f9d7303ff7b0622a6d52324dd99d69fe1f5205d7/Shared/CollieShareInbox.swift

[中文指南](/guides/attachment-name-metadata-provenance/) · [English guide](/en/guides/attachment-name-metadata-provenance/)
