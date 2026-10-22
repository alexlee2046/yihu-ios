---
layout: ../../layouts/Wave3Guide.astro
title: "关闭通知就远端解绑了吗？本地停用、待注销与绑定轮换回报"
description: "核disable先本地关闭、尝试保留标记、unregister响应和轮换保存；disabled/超时非远端停推或零副本证明，不读Keychain或改变授权。"
lang: zh
indexable: false
---

<h2 id="first-answer">本地开关关闭，不等远端已注销或系统通知权限已撤回</h2>

disable先把本地启用决定设false，再尝试保留unregisterPending并请求原工作台注销；响应ok和绑定轮换保存仍需分别通过，否则可保留unbindPending。标记写入有可能失败，不能承诺必持久。超时不是远端未执行证明，关闭也不是立即全停推、注销网页登录或撤回系统通知权限。

## 与通知载荷、来源缓存和数据删除的区别

载荷核模型，缓存核来源隔离，删除核具体材料；这里核**本地通知决定与远端注销待定状态/回报**。不读取Keychain、绑定密钥或设备token，不发注销请求、不改开关。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 本地决定 | defaults先设false | 本地意愿与服务结果 | 远端立即已解绑 |
| 待定标记 | 尝试保留binding/unregisterPending | 写入成功另核 | 标记必持久/万能恢复 |
| 注销请求 | 原session的webRequest | 页面拥有认证，非自带后台 | 所有Agent服务都可注销 |
| 响应 | ok与实际超时/失败分开 | 响应窗口非效果时间 | 超时证明服务没做 |
| 轮换 | rotateUnregisteredBinding核旧installationId再存 | 旧/迟回报与新绑定分开 | 任意晚回报能覆盖新绑定 |
| pending状态 | unbindPending/旧registration仍需核 | 待注销不冒已清理 | 关开关就零副本或无提醒 |
| 保护边界 | Keychain按origin存本机绑定 | 不推广所有文件/网页token | 全App所有数据同保护或已删除 |
| 权限/账户 | 系统通知授权/网页登录另核 | 本机订阅决定非账户权限 | 自动退出网页或撤销审批权 |

</div>

## 合成解绑记录

开关本地false，注销未获确认，应记本地已停用、远端待核，不能写远端已完全停止。迟回报还要匹配原绑定并成功轮换保存，不能只看一次返回就认全链已清理。

客户端的未决提示和超时配置不构成实测停止期限/删除保证。排错不导出密钥或顾客内容。本文只核源码，不验证真实通知服务、账户注销、系统授权或设备。

## FAQ

<h3 id="faq-1">本地disabled就代表远端已注销吗？</h3>

不是，本地决定、请求回报和绑定轮换分别核。

<h3 id="faq-2">unregisterPending一定成功保存吗？</h3>

不能保证，调用尝试写入与实际持久化成功不同。

<h3 id="faq-3">超时代表远端没有处理吗？</h3>

不能据此断言未执行，后续仍按原待定状态核查。

<h3 id="faq-4">旧回报可以覆盖新绑定吗？</h3>

源码轮换先比原installationId，不把任意迟回报当新绑定结果。

<h3 id="faq-5">关通知是否退出网页/撤回系统权限？</h3>

不是这条本地订阅决定的同一操作，账户和系统授权分别核。

<h3 id="faq-6">本文读取密钥或真的解绑了吗？</h3>

没有，不读Keychain/凭据、不改设置、不发送第三方请求。

## 相关指南与源码

[通知模型](/guides/notification-payload-model-preflight/) · [来源分账](/guides/source-switch-cache-isolation/) · [删除范围](/guides/note-removal-retention-boundaries/) · [提醒导航](/guides/reminder-link-pending-origin-routing/) · [开始](/start/) · [隐私](/privacy/)

[disable/rotate/Keychain/页面认证边界](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieNativeNotifications.swift)
