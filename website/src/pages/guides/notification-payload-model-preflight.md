---
layout: ../../layouts/Wave3Guide.astro
title: "通知负载源码能证明什么？事件模型不等于推送已上线"
description: "核Radar事件模型的精确键、版本、UUID与eventKey形状；类型存在不证明订阅、送达、导航或写入能力，不新增推送服务。"
lang: zh
---

<h2 id="syn-ntf-42">SYN-NTF-42：载荷模型、受守卫跳转与送达边界</h2>

SYNTHETIC_EXAMPLE，原解析/路由在内存替身核查，不是真实APNs/Keychain/设备送达。

[ZH: /samples/p21-notification-payload-model/preflight.zh.json](/samples/p21-notification-payload-model/preflight.zh.json) · [EN: /samples/p21-notification-payload-model/preflight.en.json](/samples/p21-notification-payload-model/preflight.en.json) · [Card: /samples/p21-notification-payload-model/preflight-card.md](/samples/p21-notification-payload-model/preflight-card.md)

<div role="region" aria-label="合成通知载荷/路由/送达边界表，可左右滚动" tabindex="0">

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| A1 | {'version': 1, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | yihuRadar model accepted=True | Host model only, not active subscription/APNs/auth |
| A2 | {'version': True, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A3 | {'version': '1', 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A4 | {'version': 2, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A5 | {'version': 1.0, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | yihuRadar model accepted=True | Host model only, not active subscription/APNs/auth |
| A6 | {'version': 1, 'subscriptionId': 'invalid', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A7 | {'version': 1, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A8 | {'version': 1, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A9 | {'version': 1, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A10 | {'version': 1, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'url': 'https://synthetic.invalid'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A11 | {'version': 1, 'subscriptionId': '11111111-1111-1111-1111-111111111111'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A12 | {'version': 1, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': ''} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| P1 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': '/tasks/42'} | collie payload accepted=True | Separate schema; parse is not trusted route or delivery |
| P2 | {'version': True, 'registrationId': 'synthetic-registration', 'path': '/tasks/42'} | collie payload accepted=True | Separate schema; parse is not trusted route or delivery |
| P3 | {'version': '1', 'registrationId': 'synthetic-registration', 'path': '/tasks/42'} | collie payload accepted=False | Separate schema; parse is not trusted route or delivery |
| P4 | {'version': 1, 'registrationId': '', 'path': '/tasks/42'} | collie payload accepted=False | Separate schema; parse is not trusted route or delivery |
| P5 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': ''} | collie payload accepted=True | Separate schema; parse is not trusted route or delivery |
| P6 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': 'https://other.invalid/x'} | collie payload accepted=True | Separate schema; parse is not trusted route or delivery |
| P7 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': '/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | collie payload accepted=True | Separate schema; parse is not trusted route or delivery |
| P8 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': '/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | collie payload accepted=False | Separate schema; parse is not trusted route or delivery |
| P9 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': '/界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界'} | collie payload accepted=True | Separate schema; parse is not trusted route or delivery |
| P10 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': '/界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界'} | collie payload accepted=False | Separate schema; parse is not trusted route or delivery |
| P11 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': '/tasks/42', 'extra': 'synthetic'} | collie payload accepted=True | Separate schema; parse is not trusted route or delivery |
| P12 | {'version': 2, 'registrationId': 'synthetic-registration', 'path': '/tasks/42'} | collie payload accepted=False | Separate schema; parse is not trusted route or delivery |
| R1 | origin=https://alpha.invalid; path='/' | original route resolve=True | Foundation URL only, no server decode/browser security certification |
| R2 | origin=https://alpha.invalid; path='/tasks/42?from=push#check' | original route resolve=True | Foundation URL only, no server decode/browser security certification |
| R3 | origin=https://alpha.invalid; path='relative' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R4 | origin=https://alpha.invalid; path='https://other.invalid/x' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R5 | origin=https://alpha.invalid; path='//other.invalid/x' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R6 | origin=https://alpha.invalid; path='/../x' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R7 | origin=https://alpha.invalid; path='/%2e%2e/x' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R8 | origin=https://alpha.invalid; path='/%2f%2fevil.invalid' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R9 | origin=https://alpha.invalid; path='/a\\b' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R10 | origin=https://alpha.invalid; path='/a%5cb' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R11 | origin=https://alpha.invalid; path='/bad%ZZ' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R12 | origin=https://alpha.invalid; path='/a\nb' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R13 | origin=https://alpha.invalid; path='' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R14 | origin=https://alpha.invalid; path='/%252e%252e/x' | original route resolve=True | Foundation URL only, no server decode/browser security certification |
| R15 | origin=http://alpha.invalid; path='/tasks/42' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| Q1 | normal | {'open_calls': 1, 'pending': False, 'callbacks': 1, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q2 | loading | {'open_calls': 0, 'pending': True, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q3 | age299999 | {'open_calls': 1, 'pending': False, 'callbacks': 1, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q4 | age300000 | {'open_calls': 0, 'pending': False, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q5 | no_active | {'open_calls': 0, 'pending': True, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q6 | unregistered | {'open_calls': 0, 'pending': False, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q7 | blocked | {'open_calls': 0, 'pending': False, 'callbacks': 0, 'blocks': 1, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q8 | open_false | {'open_calls': 1, 'pending': False, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q9 | other_no_switch | {'open_calls': 0, 'pending': False, 'callbacks': 0, 'blocks': 1, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q10 | switch_loading | {'open_calls': 0, 'pending': True, 'callbacks': 0, 'blocks': 0, 'switches': 1} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q11 | switch_ready | {'open_calls': 1, 'pending': False, 'callbacks': 1, 'blocks': 0, 'switches': 1} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q12 | ambiguous | {'open_calls': 0, 'pending': False, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q13 | active_wins | {'open_calls': 1, 'pending': False, 'callbacks': 1, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q14 | disabled | {'open_calls': 0, 'pending': False, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q15 | invalid_route | {'open_calls': 0, 'pending': False, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q16 | no_web | {'open_calls': 0, 'pending': True, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| E1 | 解析/本地导航尝试不等APNs送达/用户看见 | source/manual boundary; runtime not_run | No remote unregister/delivery, credentials or business authorization |
| E2 | yihuRadar与collie两协议不能互套键/类型门 | source/manual boundary; runtime not_run | No remote unregister/delivery, credentials or business authorization |
| E3 | 本地停用/待注销不等远端解绑或系统撤权 | source/manual boundary; runtime not_run | No remote unregister/delivery, credentials or business authorization |
| E4 | 合成registration形状不等凭据/服务写授权 | source/manual boundary; runtime not_run | No remote unregister/delivery, credentials or business authorization |

</div>

原段yihuRadar事件与原生collie通知不是一套协议：前者精确内层键/UUID/64小写hex且排Bool；后者registrationId/path与2048 UTF8字节门不自动套前者规则。宿主Foundation数值桥接行为非JSON词法/所有APNs封送保证。模型接纳仍须本地启用绑定、同源route和导航/加载/300秒待处理门；onOpen回调不证用户看见/服务处理。关闭/待注销/超时也不证远端已停推或系统撤权。真实权限、Keychain、APNs、UI/远端回执全not_run，不取真实设备token/私有源，不盲重放；目的地可存/同步/自动处理。

<h2 id="first-answer">只验出事件形状，不等于验过端到端通知或动作授权</h2>

当前源码的CollieRadarNotificationEvent解析yihuRadar负载，约束version、subscriptionId与eventKey。它表示不透明事件意图，不是任意URL或写命令。仅看到这个模型，不能宣布订阅/推送/点击导航已完整接入或线上送达；本页不新建推送基础设施。

## 与来源兼容和手机确认的区别

这里核**源码里一个输入模型能够支持多大结论**，而不是请求系统通知权限、测试APNs或批准业务动作。注释要求本地注册订阅与新鲜私有源读取后再导航；这些要求仍要在实际调用链另找证据，不能由结构体自动证明。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 外层负载 | 读取yihuRadar字典 | 实际调用者与入口是否接入 | 所有通知都走此模型 |
| 键集合 | 精确version/subscriptionId/eventKey | 额外键也不自动视为兼容 | 任意扩展字段都接受 |
| version | 整数1，并排除布尔类型 | 类型与版本分别核 | true可代替版本1 |
| subscriptionId | 需可解析UUID | 实际订阅是否本地已注册另核 | UUID形状正确就证明有订阅 |
| eventKey | 64个小写十六进制字符 | 形状不代替来源关联 | 证明密码学签名或真实事件 |
| 后续导航 | 注释要求注册与新鲜源读取 | 实际实现/测试证据和权限 | 模型解析成功就已打开任务 |
| 写入/执行 | 模型不是写命令 | 原确认/写权与回执 | 点击即同意或自动执行 |
| 线上验收 | 本页只核固定源码 | 部署、权限、设备与送达另验 | 推送已上线或延迟保证 |

</div>

## 合成审查结论

已知：固定源码有事件形状检查。未证：实际注册、投递、点击解析调用与目标导航。结论：只报模型检查，不把未证调用链补成已完成。

不要为验证模型而注册第三方服务、填真实设备token或公开私有源。即使未来端到端测试通过，事件意图也不自动授权写操作或证明业务完成。

## FAQ

<h3 id="faq-1">结构体存在是否说明推送已部署？</h3>

不是。模型、调用链、部署和真机送达是不同证据层级。

<h3 id="faq-2">version为true可当1吗？</h3>

当前模型明确排除布尔，不能以数值外观代替类型要求。

<h3 id="faq-3">eventKey像hash是否等于签名？</h3>

不是。64个小写十六进制是形状条件，不独立证明签名、真实性或授权。

<h3 id="faq-4">有效UUID就代表实际订阅吗？</h3>

不代表。注册关系与身份仍须实际调用链核对。

<h3 id="faq-5">点通知是否同意执行？</h3>

不能这样推断。不透明事件不是写命令，原权限和确认门继续。

<h3 id="faq-6">本文是否运行APNs或真机？</h3>

没有。只核固定源码，不宣称设备送达、导航或线上延迟验收。

## 相关指南与源码

[契约兼容](/guides/brief-format-change-compatibility/) · [确认范围](/guides/multi-role-approval-receipt-checklist/) · [目标与上下文](/guides/follow-up-context-preflight/) · [开始](/start/) · [隐私](/privacy/)

[事件模型与注释](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift) · [源码发布与产品边界](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)
