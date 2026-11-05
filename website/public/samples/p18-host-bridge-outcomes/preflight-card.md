# SYN-BRG-39 — 宿主桥/DOM结果与提交边界 / Host bridge outcomes

**SYNTHETIC_EXAMPLE**，不是App导入格式、客户正文、真实网页操作或业务回执。Fixed main@b4a162d0544d6241bbc60e7949af28f0b1a7a932 / tree1e75a6af4778fb52abe7db27fe5fa78dddfaf936. Source merge is not proof of store-binary parity.

## 先分三层 / Separate three layers

1. **原生Swift流程**：已有receipt若转Bool则即返回；异常停。仅桥字符串unavailable可到DOM，accepted返回true，refused/未知/异常停止；每次下一层仍受allowed/页面/请求条件。Fake WK answers test original branch decisions, not WK type marshaling/content-world isolation or real async navigation race.
2. **页面桥协议**：origin/pageURL/hidden失败=>refused；读取text/accepted或设置accepted被观测，未accepted且observed/defaultPrevented=>refused；无人处理=>unavailable。只有literal true设置接纳，且accepted优先于preventDefault。Unavailable is a protocol observation, not a whole-site capability/security scan.
3. **DOM编辑/回执**：原脚本只尝试正常编辑/受守卫setter+input，值/连接/页面在下一tick核；框架可拒绝。DOM值/协议接纳不证明目标保存/服务器收到或业务完成；目的站可能有自己的保存/同步/自动处理，本包不验证它们。

## 实际执行 / Actual execution

原CollieTextInsertion整个enum（用Swift真正产出三个JS字符串）、insertTranscript/isTrusted/trustedOrigin/effectivePort逐字进Foundation宿主；WKUserScript/WKContentWorld/webView脚本响应为替身，19原生分支例/语。协议13例与DOM16例/语执行**原Swift产出的JavaScript**，Node vm只放合成事件/元素/焦点/execCommand/setter/input/timer，不开浏览器/注入真实网页/改全局真实桥，不录音，不访问网络。4业务边界只读。源指纹测试把冻结JS绑到实际原Swift完整enum/方法，变化需复核，不用重写一份桥逻辑冒原实现。

Native19 + bridge13 + DOM16 cases/language, not a48-profile native test. Fake DOM is intentionally small: no real CSS/layout/selection/React/Vue/contenteditable matrix, WebKit engine or iframe/shadow certification. Timers use Node next tick, not device scheduling guarantees. Script file-upload functions are merely defined, not invoked; no submit, keyboard activation or file upload is executed. Source user script remains forMainFrameOnly=true.

- **N1–N6/N18–N19**: web/allowed/trust/expected page/request/prepared page gates stop before next stage; scripted guard changes are not real race coverage.
- **N7–N17**: cached Bool true/false and errors short-circuit; only unavailable allowsDOM; unknown/refused/throws/string-truthiness are not success/fallback.
- **B1–B13**: absent vs observed reads, literal true vsfalse/string/number, preventDefault and accepted precedence; synthetic synchronous dispatch only, no browser exception semantics claim.
- **D1–D3**: Latin boundary adds one space, CJK doesn't; execCommand or unchanged-value native setter path. **D4**: synthetic execCommand mutates expected value but reports false, first call returnsfalse; same-request receipt thentrue. False does not prove no write, do not blindly retry/new-ID.
- **D5–D12**: rejected controlled edit, ordinary readonly vs explicit keyboard-policy canInsert, password/unknown Collie/hidden/page drift/focus redirect remain distinct; no attributes unlocked or unrelated frame selected.
- **D13/D14**: same ID/text can reuse receipt once; changed text on same ID refuses, not duplicate insertion. **D15**: selection API throw after setter can still acknowledge exact value. **D16**: disconnected field after setter =>false with changed value; not certified real framework behavior or delivery.

## 全部双语工作表 / Complete bilingual worksheet

### zh

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| N1 | no_web; scripted answers=[] | {'accepted': False, 'call_roles': []} | Original Swift + fake WebKit replies, not real content worlds |
| N2 | blocked; scripted answers=[] | {'accepted': False, 'call_roles': []} | Original Swift + fake WebKit replies, not real content worlds |
| N3 | untrusted; scripted answers=[] | {'accepted': False, 'call_roles': []} | Original Swift + fake WebKit replies, not real content worlds |
| N4 | wrong_page; scripted answers=[] | {'accepted': False, 'call_roles': []} | Original Swift + fake WebKit replies, not real content worlds |
| N5 | wrong_request; scripted answers=[] | {'accepted': False, 'call_roles': []} | Original Swift + fake WebKit replies, not real content worlds |
| N6 | moved_prepared; scripted answers=[] | {'accepted': False, 'call_roles': []} | Original Swift + fake WebKit replies, not real content worlds |
| N7 | normal; scripted answers=['true'] | {'accepted': True, 'call_roles': ['receipt']} | Original Swift + fake WebKit replies, not real content worlds |
| N8 | normal; scripted answers=['false'] | {'accepted': False, 'call_roles': ['receipt']} | Original Swift + fake WebKit replies, not real content worlds |
| N9 | normal; scripted answers=['throw'] | {'accepted': False, 'call_roles': ['receipt']} | Original Swift + fake WebKit replies, not real content worlds |
| N10 | normal; scripted answers=['null', 'accepted'] | {'accepted': True, 'call_roles': ['receipt', 'bridge']} | Original Swift + fake WebKit replies, not real content worlds |
| N11 | normal; scripted answers=['null', 'refused'] | {'accepted': False, 'call_roles': ['receipt', 'bridge']} | Original Swift + fake WebKit replies, not real content worlds |
| N12 | normal; scripted answers=['null', 'unavailable', 'true'] | {'accepted': True, 'call_roles': ['receipt', 'bridge', 'dom']} | Original Swift + fake WebKit replies, not real content worlds |
| N13 | normal; scripted answers=['null', 'unknown'] | {'accepted': False, 'call_roles': ['receipt', 'bridge']} | Original Swift + fake WebKit replies, not real content worlds |
| N14 | normal; scripted answers=['null', 'throw'] | {'accepted': False, 'call_roles': ['receipt', 'bridge']} | Original Swift + fake WebKit replies, not real content worlds |
| N15 | normal; scripted answers=['null', 'unavailable', 'false'] | {'accepted': False, 'call_roles': ['receipt', 'bridge', 'dom']} | Original Swift + fake WebKit replies, not real content worlds |
| N16 | normal; scripted answers=['null', 'unavailable', 'string_true'] | {'accepted': False, 'call_roles': ['receipt', 'bridge', 'dom']} | Original Swift + fake WebKit replies, not real content worlds |
| N17 | normal; scripted answers=['null', 'unavailable', 'throw'] | {'accepted': False, 'call_roles': ['receipt', 'bridge', 'dom']} | Original Swift + fake WebKit replies, not real content worlds |
| N18 | block_after_receipt; scripted answers=['null'] | {'accepted': False, 'call_roles': ['receipt']} | Original Swift + fake WebKit replies, not real content worlds |
| N19 | block_after_bridge; scripted answers=['null', 'unavailable'] | {'accepted': False, 'call_roles': ['receipt', 'bridge']} | Original Swift + fake WebKit replies, not real content worlds |
| B1 | absent | unavailable | Original emitted JS + synthetic synchronous event objects |
| B2 | read_text | refused | Original emitted JS + synthetic synchronous event objects |
| B3 | read_accepted | refused | Original emitted JS + synthetic synchronous event objects |
| B4 | accept_true | accepted | Original emitted JS + synthetic synchronous event objects |
| B5 | accept_false | refused | Original emitted JS + synthetic synchronous event objects |
| B6 | accept_string | refused | Original emitted JS + synthetic synchronous event objects |
| B7 | prevent | refused | Original emitted JS + synthetic synchronous event objects |
| B8 | accept_and_prevent | accepted | Original emitted JS + synthetic synchronous event objects |
| B9 | hidden | refused | Original emitted JS + synthetic synchronous event objects |
| B10 | wrong_origin | refused | Original emitted JS + synthetic synchronous event objects |
| B11 | wrong_page | refused | Original emitted JS + synthetic synchronous event objects |
| B12 | accept_number | refused | Original emitted JS + synthetic synchronous event objects |
| B13 | accept_then_refuse | refused | Original emitted JS + synthetic synchronous event objects |
| D1 | exec_success | {'accepted': True, 'value': 'alpha beta', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D2 | cjk | {'accepted': True, 'value': '你好世界', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D3 | setter_fallback | {'accepted': True, 'value': 'alpha beta', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D4 | mutated_but_false | {'accepted': False, 'value': 'alpha beta', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D5 | framework_reject | {'accepted': False, 'value': 'alpha', 'receipt': False} | Synthetic element/execCommand/framework models, not browser compatibility |
| D6 | readonly | {'accepted': False, 'value': 'alpha', 'receipt': None} | Synthetic element/execCommand/framework models, not browser compatibility |
| D7 | readonly_policy | {'accepted': True, 'value': 'alpha beta', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D8 | password | {'accepted': False, 'value': 'alpha', 'receipt': None} | Synthetic element/execCommand/framework models, not browser compatibility |
| D9 | collie_unknown | {'accepted': False, 'value': 'alpha', 'receipt': None} | Synthetic element/execCommand/framework models, not browser compatibility |
| D10 | hidden | {'accepted': False, 'value': 'alpha', 'receipt': None} | Synthetic element/execCommand/framework models, not browser compatibility |
| D11 | moved_page | {'accepted': False, 'value': 'alpha', 'receipt': None} | Synthetic element/execCommand/framework models, not browser compatibility |
| D12 | focus_redirect | {'accepted': False, 'value': 'alpha', 'receipt': None} | Synthetic element/execCommand/framework models, not browser compatibility |
| D13 | same_id | {'accepted': True, 'value': 'alpha beta', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D14 | different_text | {'accepted': True, 'value': 'alpha beta', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D15 | email_selection_throw | {'accepted': True, 'value': 'alpha beta', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D16 | disconnect_after_setter | {'accepted': False, 'value': 'alpha beta', 'receipt': False} | Synthetic element/execCommand/framework models, not browser compatibility |
| R1 | DOM/桥接接纳不是服务提交 | source/manual boundary, runtime not_run | No authentication, persistence or business submission receipt |
| R2 | false/异常也可能已改变值，不盲重放 | source/manual boundary, runtime not_run | No authentication, persistence or business submission receipt |
| R3 | 焦点/适配类型不等授权/所有iframe或shadow兼容 | source/manual boundary, runtime not_run | No authentication, persistence or business submission receipt |
| R4 | 目的地保存/同步/自动处理另核 | source/manual boundary, runtime not_run | No authentication, persistence or business submission receipt |

### en

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| N1 | no_web; scripted answers=[] | {'accepted': False, 'call_roles': []} | Original Swift + fake WebKit replies, not real content worlds |
| N2 | blocked; scripted answers=[] | {'accepted': False, 'call_roles': []} | Original Swift + fake WebKit replies, not real content worlds |
| N3 | untrusted; scripted answers=[] | {'accepted': False, 'call_roles': []} | Original Swift + fake WebKit replies, not real content worlds |
| N4 | wrong_page; scripted answers=[] | {'accepted': False, 'call_roles': []} | Original Swift + fake WebKit replies, not real content worlds |
| N5 | wrong_request; scripted answers=[] | {'accepted': False, 'call_roles': []} | Original Swift + fake WebKit replies, not real content worlds |
| N6 | moved_prepared; scripted answers=[] | {'accepted': False, 'call_roles': []} | Original Swift + fake WebKit replies, not real content worlds |
| N7 | normal; scripted answers=['true'] | {'accepted': True, 'call_roles': ['receipt']} | Original Swift + fake WebKit replies, not real content worlds |
| N8 | normal; scripted answers=['false'] | {'accepted': False, 'call_roles': ['receipt']} | Original Swift + fake WebKit replies, not real content worlds |
| N9 | normal; scripted answers=['throw'] | {'accepted': False, 'call_roles': ['receipt']} | Original Swift + fake WebKit replies, not real content worlds |
| N10 | normal; scripted answers=['null', 'accepted'] | {'accepted': True, 'call_roles': ['receipt', 'bridge']} | Original Swift + fake WebKit replies, not real content worlds |
| N11 | normal; scripted answers=['null', 'refused'] | {'accepted': False, 'call_roles': ['receipt', 'bridge']} | Original Swift + fake WebKit replies, not real content worlds |
| N12 | normal; scripted answers=['null', 'unavailable', 'true'] | {'accepted': True, 'call_roles': ['receipt', 'bridge', 'dom']} | Original Swift + fake WebKit replies, not real content worlds |
| N13 | normal; scripted answers=['null', 'unknown'] | {'accepted': False, 'call_roles': ['receipt', 'bridge']} | Original Swift + fake WebKit replies, not real content worlds |
| N14 | normal; scripted answers=['null', 'throw'] | {'accepted': False, 'call_roles': ['receipt', 'bridge']} | Original Swift + fake WebKit replies, not real content worlds |
| N15 | normal; scripted answers=['null', 'unavailable', 'false'] | {'accepted': False, 'call_roles': ['receipt', 'bridge', 'dom']} | Original Swift + fake WebKit replies, not real content worlds |
| N16 | normal; scripted answers=['null', 'unavailable', 'string_true'] | {'accepted': False, 'call_roles': ['receipt', 'bridge', 'dom']} | Original Swift + fake WebKit replies, not real content worlds |
| N17 | normal; scripted answers=['null', 'unavailable', 'throw'] | {'accepted': False, 'call_roles': ['receipt', 'bridge', 'dom']} | Original Swift + fake WebKit replies, not real content worlds |
| N18 | block_after_receipt; scripted answers=['null'] | {'accepted': False, 'call_roles': ['receipt']} | Original Swift + fake WebKit replies, not real content worlds |
| N19 | block_after_bridge; scripted answers=['null', 'unavailable'] | {'accepted': False, 'call_roles': ['receipt', 'bridge']} | Original Swift + fake WebKit replies, not real content worlds |
| B1 | absent | unavailable | Original emitted JS + synthetic synchronous event objects |
| B2 | read_text | refused | Original emitted JS + synthetic synchronous event objects |
| B3 | read_accepted | refused | Original emitted JS + synthetic synchronous event objects |
| B4 | accept_true | accepted | Original emitted JS + synthetic synchronous event objects |
| B5 | accept_false | refused | Original emitted JS + synthetic synchronous event objects |
| B6 | accept_string | refused | Original emitted JS + synthetic synchronous event objects |
| B7 | prevent | refused | Original emitted JS + synthetic synchronous event objects |
| B8 | accept_and_prevent | accepted | Original emitted JS + synthetic synchronous event objects |
| B9 | hidden | refused | Original emitted JS + synthetic synchronous event objects |
| B10 | wrong_origin | refused | Original emitted JS + synthetic synchronous event objects |
| B11 | wrong_page | refused | Original emitted JS + synthetic synchronous event objects |
| B12 | accept_number | refused | Original emitted JS + synthetic synchronous event objects |
| B13 | accept_then_refuse | refused | Original emitted JS + synthetic synchronous event objects |
| D1 | exec_success | {'accepted': True, 'value': 'alpha beta', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D2 | cjk | {'accepted': True, 'value': '你好世界', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D3 | setter_fallback | {'accepted': True, 'value': 'alpha beta', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D4 | mutated_but_false | {'accepted': False, 'value': 'alpha beta', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D5 | framework_reject | {'accepted': False, 'value': 'alpha', 'receipt': False} | Synthetic element/execCommand/framework models, not browser compatibility |
| D6 | readonly | {'accepted': False, 'value': 'alpha', 'receipt': None} | Synthetic element/execCommand/framework models, not browser compatibility |
| D7 | readonly_policy | {'accepted': True, 'value': 'alpha beta', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D8 | password | {'accepted': False, 'value': 'alpha', 'receipt': None} | Synthetic element/execCommand/framework models, not browser compatibility |
| D9 | collie_unknown | {'accepted': False, 'value': 'alpha', 'receipt': None} | Synthetic element/execCommand/framework models, not browser compatibility |
| D10 | hidden | {'accepted': False, 'value': 'alpha', 'receipt': None} | Synthetic element/execCommand/framework models, not browser compatibility |
| D11 | moved_page | {'accepted': False, 'value': 'alpha', 'receipt': None} | Synthetic element/execCommand/framework models, not browser compatibility |
| D12 | focus_redirect | {'accepted': False, 'value': 'alpha', 'receipt': None} | Synthetic element/execCommand/framework models, not browser compatibility |
| D13 | same_id | {'accepted': True, 'value': 'alpha beta', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D14 | different_text | {'accepted': True, 'value': 'alpha beta', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D15 | email_selection_throw | {'accepted': True, 'value': 'alpha beta', 'receipt': True} | Synthetic element/execCommand/framework models, not browser compatibility |
| D16 | disconnect_after_setter | {'accepted': False, 'value': 'alpha beta', 'receipt': False} | Synthetic element/execCommand/framework models, not browser compatibility |
| R1 | DOM/bridge acceptance is not service submission | source/manual boundary, runtime not_run | No authentication, persistence or business submission receipt |
| R2 | False/error can coexist with changed value; no blind replay | source/manual boundary, runtime not_run | No authentication, persistence or business submission receipt |
| R3 | Focus/type does not authorize writes or certify all iframe/shadow layouts | source/manual boundary, runtime not_run | No authentication, persistence or business submission receipt |
| R4 | Destination save/sync/auto-processing requires separate evidence | source/manual boundary, runtime not_run | No authentication, persistence or business submission receipt |

## No-Go、隐私和未测 / Stop criteria and limits

Refused/unknown/error、page/request/allowed变化、实际目标或旧副作用未知=>保原回执、原ID和目标内容，不把refused改写unavailable，不借通用输入框绕锁，不造新ID重放，不把false洗成绝无改动。即使accepted/DOM true，也只记录这层证据，另核真正草稿/业务/服务回执与用户确认。

US官方商店保存观察沿11/05的0.1.0/id6819057500/iOS18+，非本轮查最新或全球供应；商店安装不需Mac/Xcode/自签名。自己的可信HTTPS工作台/账号、可选模型约950MB、权限/实际安装版另核，目的地可能保存/同步/自动处理。https://apps.apple.com/us/app/yihu/id6819057500

Real WKWebView/content worlds, device keyboard/focus/selection, React/Vue/controlled-input compatibility, live host bridge, iframe/shadow, server submission/ack, ASR/mic, account/write authorization, destination sync/storage and hardware SLA: **not_run**. No new host adapter/service/auto-send or global security/synchronization guarantee.

Active host pair alone links samples. Retired focused-editable pair stays false/no samples/Store card/own LLM or sitemap entry. Source canonical getyihu.com retained, dispatch yihu.st not domain migration authority. No production/IndexNow/Google API re-pull or external posting here.
