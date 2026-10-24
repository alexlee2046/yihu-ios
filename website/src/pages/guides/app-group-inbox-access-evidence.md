---
layout: ../../layouts/Wave3Guide.astro
title: "共享收件箱不可访问就是网络坏了吗？AppGroup声明、签名与本机容器"
description: "核App/Extension的变量、YihuAppGroup键和运行时containerURL；代码匹配非签名/真机访问验收，本机共享不是公网API或网站身份隔离。"
lang: zh
indexable: false
---

<h2 id="first-answer">AppGroup本机容器、产物权限与网站网络/账户，是不同证据</h2>

App和Share Extension的Info.plist、entitlements引用YIHU_APP_GROUP；运行代码读取YihuAppGroup，再向系统请求containerURL。shared()未取到容器就返回nil。相同声明只能说明配置意图，不证明产物签名权限或真实设备可访问；本机共享不等公网上传或第三方账户授权。

## 与manifest可见点、文件保护和网站缓存的区别

manifest核批次发布，保护核写选项，网站缓存核origin；这里核**容器入口及声明/签名/运行三类证据**。不读真实容器，不注册AppGroup、不改配置或签名。

<div role="region" aria-label="源码边界核查表，可左右滚动" tabindex="0">

| 检查项 | 已核范围 | 人工复核 | 不应推断 |
| --- | --- | --- | --- |
| 变量声明 | YIHU_APP_GROUP用于两端配置 | 源码意图 | 发布签名已正确 |
| Bundle键 | YihuAppGroup供运行时读取 | 键名与构建变量分层 | 两个名字可互换 |
| entitlement | com.apple.security.application-groups | 最终签名另核 | plist相同就获系统授权 |
| 运行入口 | containerURL取不到则shared()==nil | 实际系统结果 | 唯一根因就是断网或模型损坏 |
| 示例fallback | 缺键有源码后备标识 | 非生产权限证据 | 示例ID能直接当生产配置 |
| 测试root | init(root:)可注入位置 | 测试代码与系统授权分开 | 本地构造root验证跨Extension权限 |
| 工作台边界 | 容器名不是网页账户/部门身份 | 目标页面权限另核 | 按每个origin自动独立收件箱 |
| 后续写入 | 访问、批次发布、文件保护另核 | 入口成功非全链完成 | 成功取容器就已安全交付 |

</div>

## 合成入口记录

若shared()为nil，只记录未得到容器入口，不直接诊断网络、模型或某一唯一签名故障。声明相同、测试目录可写、运行时可访问，各自不能替另一层证明。

本页不指导用任意目录绕过系统权限，也不把AppGroup注册当网页登录或新存储服务。未检查安装产物/签名或真机，不把源码配置宣称为已生效。

## FAQ

<h3 id="faq-1">共享收件箱不可访问一定是断网吗？</h3>

不能这样推，shared容器入口与网站网络是不同层。

<h3 id="faq-2">两个配置文件相同能证明签名正确吗？</h3>

不能，最终产物权限及运行结果仍需各自证据。

<h3 id="faq-3">YihuAppGroup和YIHU_APP_GROUP是同一种键吗？</h3>

不是，前者为Bundle读取键，后者为构建替换变量。

<h3 id="faq-4">测试能注入root就是系统授予共享权限吗？</h3>

不是，测试构造与系统AppGroup访问不是同一证据。

<h3 id="faq-5">容器是否天然按每个工作台网站隔离？</h3>

不能由这段共享容器入口推出，网页权限/存储边界另核。

<h3 id="faq-6">本文注册AppGroup或验证了签名吗？</h3>

没有，不改配置、第三方授权或签名，不做真机能力验收。

## 相关指南与源码

[批次发布](/guides/share-manifest-visibility-review/) · [保护选项](/guides/local-file-protection-scope/) · [网站缓存](/guides/source-switch-cache-isolation/) · [声明证据](/guides/privacy-declaration-evidence-scope/) · [开始](/start/) · [隐私](/privacy/)

[appGroup/shared/root](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/CollieShareInbox.swift) · [App Bundle键](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/Info.plist) · [Extension Bundle键](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Extensions/CollieShare/Info.plist) · [App声明](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/Collie.entitlements) · [Extension声明](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Extensions/CollieShare/CollieShare.entitlements)
