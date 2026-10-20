---
layout: ../../../layouts/Wave3Guide.astro
title: "Does disabling notifications unregister remotely? Local choice, pending removal and binding rotation"
description: "Review local false, attempted pending persistence, unregister acknowledgement and rotation. Disabled/timeout is not stopped remote delivery or deletion; no Keychain/authority change runs."
lang: en
---

<h2 id="first-answer">A local off switch is not completed remote unregister or revoked system permission</h2>

disable sets local enablement false before attempting to retain unregisterPending and requesting the old workbench to unregister. Response ok and binding-rotation persistence must still pass; otherwise unbindPending can remain. Marker writes can fail and are not guaranteed durable. Timeout does not prove no remote execution; off does not establish immediate global silence, web logout or revoked system notification permission.

## Different from payloads, source caches and deletion

Payloads concern models, caches concern origins, deletion concerns material. Here **local notification choice versus pending remote unregister/receipts** matters. No Keychain/secret/device token was read or unregister/settings request performed.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Local choice | defaults false first | Intent versus service outcome | Remote removal complete |
| Pending marker | Attempt binding/unregisterPending retention | Actual write success | Guaranteed durability/recovery |
| Request | Old-session webRequest | Page owns authentication | All Agent servers supported |
| Response | ok/timeout/failure separately | Response window versus effects | Timeout proves no processing |
| Rotation | rotateUnregisteredBinding checks installationId then saves | Old/late versus new bindings | Any late reply overwrites new state |
| Pending state | unbindPending/registration need review | Pending versus cleaned | Zero copies/no reminders |
| Protection | Origin-scoped Keychain binding | Not all files/web tokens | All data uniformly protected/deleted |
| Accounts | System permission/web login separately | Subscription versus account authority | Automatic logout/approval revocation |

</div>

## Synthetic unregister note

Local false without confirmed unregister means local off and remote uncertain, not fully stopped. Late responses still require original binding match and successful rotated save; one return does not certify end-to-end cleanup.

Client notices/timeouts are not measured stop deadlines/deletion guarantees. Do not export secrets/customer material. No actual service/account/system/device acceptance ran.

## FAQ

<h3 id="faq-1">Does local disabled prove remote unregister?</h3>

No. Choice, request receipt and rotation differ.

<h3 id="faq-2">Is unregisterPending always persisted?</h3>

No. Attempting a write differs from successful durability.

<h3 id="faq-3">Does timeout prove no remote processing?</h3>

No. Keep original uncertainty for authorized follow-up.

<h3 id="faq-4">Can old replies overwrite new bindings?</h3>

Rotation checks the original installationId instead of accepting arbitrary late replies.

<h3 id="faq-5">Does off log out web/revoke system permission?</h3>

These are separate operations, not this local subscription choice.

<h3 id="faq-6">Were secrets read or unregister executed?</h3>

No. No Keychain/credentials/settings/third-party request operation ran.

## Reading and source

[Notification model](/en/guides/notification-payload-model-preflight/) · [Source separation](/en/guides/source-switch-cache-isolation/) · [Deletion scope](/en/guides/note-removal-retention-boundaries/) · [Reminder routing](/en/guides/reminder-link-pending-origin-routing/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Disable/rotation/Keychain/auth scope](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieNativeNotifications.swift)
