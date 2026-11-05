---
layout: ../../../layouts/Wave3Guide.astro
title: "Refused is not unavailable: inspect accepted/refused/unavailable bridge outcomes"
description: "Review protocol observation and native fallback. Only unavailable can continue guarded DOM adaptation; no blind retry, sender or new bridge service."
lang: en
---

<h2 id="syn-brg-39">SYN-BRG-39: host receipts, DOM results and business submission</h2>

SYNTHETIC_EXAMPLE: original Swift/JS with memory doubles, not live-page edits or sends.

[ZH: /samples/p18-host-bridge-outcomes/host-bridge-outcomes-preflight.zh.json](/samples/p18-host-bridge-outcomes/host-bridge-outcomes-preflight.zh.json) · [EN: /samples/p18-host-bridge-outcomes/host-bridge-outcomes-preflight.en.json](/samples/p18-host-bridge-outcomes/host-bridge-outcomes-preflight.en.json) · [Card: /samples/p18-host-bridge-outcomes/preflight-card.md](/samples/p18-host-bridge-outcomes/preflight-card.md)

<div role="region" aria-label="Synthetic host and DOM outcome branch table; horizontally scrollable" tabindex="0">

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

</div>

Refused/unknown/exception cannot be relabelled unavailable to bypass a host. Only explicit unavailable may enter guarded DOM fallback. accepted=true precedes preventDefault but proves only protocol acceptance. DOM false may coexist with changed value; D4 first false then same-request receipt true is not business submission. Preserve request/target/unknown side effects; do not blindly refill/resend. Focus, readonly policy exceptions or known markup grant no account/server authorization. Real WebKit/framework/frame compatibility/ASR/submission are not_run. Destination may save/sync/auto-process; no global all-data-local claim.

<h2 id="first-answer">refused differs from unavailable; accepted is not a backend handling receipt</h2>

collieBridgeScript checks origin/full pageURL/visibility and observes detail reads, accepted writes and event cancellation. It returns accepted/refused/unavailable. Native handling continues to guarded DOM only for explicit unavailable, not refusals, exceptions or arbitrary results. accepted is a protocol report, not sending or business completion.

## Different from origin, reservations and completion review

Origin concerns boundaries, reservations concern attempts, auditing concerns results. Here **optional page-bridge observation and permission to try the next adapter branch** matter. No event injection, fake bridge or global-page modification occurs.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Preconditions | Origin/pageURL/hidden etc. | Actual page/phase | Same title implies trust |
| accepted | Explicit accepted=true wins | Host report versus target content | Server received/executed/approved |
| Observed | Reads text/accepted or writes accepted | Protocol consumption | All site capabilities scanned |
| refused | Without accepted, observed/defaultPrevented etc. | Refusal/boundaries | Treat as absent and bypass |
| unavailable | No observed protocol handling | Only this permits next DOM attempt | No capability anywhere on the page |
| DOM continuation | allowed/adapter guards remain | Focus/draft/page/request | Unconditional writing/sending |
| Exception/unknown | Not automatically unavailable | Effects/unknowns retained | Definitely no write, safely replay |
| Receipt layers | Isolated Bool receipts differ from page bridge | Actual layer/outcome | Any non-Bool means sent |

</div>

## Synthetic bridge note

refused: stop rather than relabel unavailable to try another composer. accepted: report protocol acceptance, inspect actual content, and do not invent sent/executed. No real handoff ran.

The native path makes no submit call, but arbitrary site behavior is not certified. Protocol observation is not scanning, account identity or universal idempotency. Compatibility cannot justify fake bridges or changing locks/sending state.

## FAQ

<h3 id="faq-1">Can refused be treated as absent bridge?</h3>

No. Native refusal does not continue DOM fallback.

<h3 id="faq-2">Does unavailable prove no site capability?</h3>

No. It is this observed protocol outcome; later adaptation remains guarded.

<h3 id="faq-3">Does accepted prove business handling?</h3>

No. Acceptance, placement, sending, receipt and handling differ.

<h3 id="faq-4">Does preventDefault always override accepted?</h3>

No. accepted=true wins; otherwise cancellation can yield refused.

<h3 id="faq-5">Can exceptions trigger another composer/replay automatically?</h3>

Do not blindly downgrade/replay; retain unknown request/target state.

<h3 id="faq-6">Was a bridge configured/tested?</h3>

No. Fixed protocol review only, without page changes/services.

## Reading and source

[Page/origin](/en/guides/workbench-origin-page-boundaries/) · [One handoff](/en/guides/recording-notes-handoff/) · [Completion evidence](/en/guides/handoff-evidence-audit-checklist/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Three-state bridge](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieTextInsertion.swift) · [Insertion branches](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWebView.swift)
