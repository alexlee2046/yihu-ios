---
layout: ../../../layouts/Wave3Guide.astro
title: "App Group inbox: local evidence vs upload | Yihu"
description: "Reference only: container and manifest access are not upload receipts. US store 0.1.0 and Apache-2.0 source are available; source scope is not a store-feature promise."
lang: en
indexable: false
---

<h2 id="first-answer">Local App Group access, signed authority and website network/accounts are separate evidence</h2>

App and Share Extension Info.plist/entitlements reference YIHU_APP_GROUP. Runtime reads YihuAppGroup and asks the system for containerURL; shared() returns nil without it. Matching declarations establish intent, not signed entitlement or real-device access. Local sharing is not public upload or third-party account authority.

## Different from manifest visibility, file protection and site caches

Manifests check publication, protection checks writes, caches check origins. Here **container entry and declaration/signing/runtime evidence** matter. No real container, registration, configuration or signing operation is accessed.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Variable | YIHU_APP_GROUP on both sides | Source intent | Release signing correct |
| Bundle key | YihuAppGroup at runtime | Key versus build variable | Names interchangeable |
| Entitlement | com.apple.security.application-groups | Final signature separately | Matching plist grants authority |
| Runtime entry | No containerURL means shared()==nil | Actual system result | Only cause offline/broken model |
| Fallback | Source default identifier if key absent | Not production entitlement | Example ID is production setup |
| Test root | init(root:) injects location | Test versus system grant | Injected root validates Extension access |
| Workbench scope | Container name is not site/account identity | Destination permissions | One automatic inbox per origin |
| Later writes | Access/publication/protection differ | Entry versus end-to-end | Container success guarantees safe handoff |

</div>

## Synthetic entry note

shared()==nil establishes no obtained container entry, not a unique network/model/signing diagnosis. Matching declarations, writable test roots and runtime access cannot replace each other's evidence.

Do not bypass system authority through arbitrary directories or call App Group registration website login/new storage service. No installed artifact/signature/device was checked; source configuration is not proven effective setup.

## FAQ

<h3 id="faq-1">Does inaccessible inbox mean offline?</h3>

No. System container entry and website networking differ.

<h3 id="faq-2">Do matching files prove valid signing?</h3>

No. Final entitlement/runtime evidence remain separate.

<h3 id="faq-3">Are YihuAppGroup and YIHU_APP_GROUP interchangeable keys?</h3>

No. The Bundle key differs from the build substitution variable.

<h3 id="faq-4">Does injected root prove system shared access?</h3>

No. Test construction differs from App Group authority.

<h3 id="faq-5">Is every workbench origin automatically isolated here?</h3>

Not from this shared-container entry; site/storage permissions need separate review.

<h3 id="faq-6">Was an App Group registered or signature verified?</h3>

No. No configuration/third-party grant/signing/device operation ran.

## Reading and source

[Batch publication](/en/guides/share-manifest-visibility-review/) · [Protection](/en/guides/local-file-protection-scope/) · [Site caches](/en/guides/source-switch-cache-isolation/) · [Declaration evidence](/en/guides/privacy-declaration-evidence-scope/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Group/container/root](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/CollieShareInbox.swift) · [App key](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/Info.plist) · [Extension key](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Extensions/CollieShare/Info.plist) · [App declaration](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/Collie.entitlements) · [Extension declaration](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Extensions/CollieShare/CollieShare.entitlements)
