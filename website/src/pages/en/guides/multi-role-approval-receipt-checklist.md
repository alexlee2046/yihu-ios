---
layout: ../../../layouts/Wave3Guide.astro
title: "Multi-role handoff: content approval, phone confirmation and recipient feedback differ"
description: "Manually separate transcript review, approval, operation and receipt identities/scopes. No workflow engine, electronic signature, organizational permissions or proxy authorization."
lang: en
---

<h2 id="first-answer">Multiple participants do not combine into authority; each confirmation has its own scope</h2>

A note/brief can involve a transcriber, reviewer, operator and recipient. One person's seen/approved does not replace another's permission, phone confirmation or feedback. Yihu is a workbench shell/source presentation, not a multi-role approval or electronic-signature engine. This manual checklist creates no organization roles, delegation or server permissions.

## Different from ownership and completion review

Ownership concerns responsibility; handoff review concerns completed-action evidence. Here **one role's confirmation must not substitute for another's, and version/action scopes must match**. A responsibility table is not authority, and reported speech is not a fabricated receipt.

## Role-specific confirmation checklist

<div role="region" aria-label="Multi-role approval/phone/recipient boundaries, scroll horizontally" tabindex="0">

| Editorial role/confirmation | Establishes only | Still review | Does not replace |
| --- | --- | --- | --- |
| Transcript reviewer | Reviewed original/corrections for a stated version | Gaps, originals and omissions | Approval, recipient consent or actual sending |
| Content reviewer | Specified fields/version within review scope | Attachment, destination and conditions | Server writes or phone operation confirmation |
| Approving decision-maker | Particular action allowed by existing process | Identity evidence, scope and revision applicability | All future actions, delegation or proxy signatures |
| Note handoff operator | Actual choice at existing preview/staging/handoff entry | Text, reservation, target and result | Recipient reading or business completion |
| Radar phone confirmer | Current target/confirmation in native reply flow | Fresh source, capability, eligible/epoch and original guards | Workflow approval, another identity or server completion |
| Recipient feedback | Exactly what authentic feedback states | Original request/reply and explicit references | Unlinked hearsay, automatic read status or full handling |
| Archive maintainer | Materials retained within existing permission | Minimization, readers and retention rules | Approving or retroactively authorizing the action |
| Unconfirmed role | Unknown remains unknown | Explicit evidence in original authorized channel | Checking every role because someone else approved |

</div>

These are editorial roles, not organization-permission settings. Note staging and native Radar reply are different entry points; one confirmation mechanism is not universal, cryptographic signing or legal receipt.

## Synthetic confirmation record

```text
Content: Sample draft A, with a synthetic attachment description.
Review: Role A checked body only; attachment/destination unchecked.
Operation authority: Unknown, not inferred from approved prose.
Recipient confirmation: Unknown, not inferred from staged.
Next: Keep separate gaps; no proxy boxes, sending or fabricated receipts.
```

Manual approval_reference, content_scope, actor_role, recipient_confirmation and remaining_unknowns are checklist labels, not JSON imports, authorization parameters or a native approval API. Public examples use no real names, contact details, private tasks or tokens.

## Feedback association is not read/handled status

Source reply history links later updates to replies through explicit references. A history entry or mention alone does not establish a person's reading, consent or completion. Even a valid association needs actual feedback/scope review, not a universal receipt certificate.

Version/destination changes can exceed prior confirmation. Recheck through the existing process instead of copying approved to new material. Reservations, target guards and uncertain-stop rules remain; another signature-like string does not erase effects or provision permissions.

## FAQ

<h3 id="faq-team">Does Yihu include multi-level approval/organization role assignment?</h3>

No such feature is asserted. These are editorial roles/checklists, not provisioned workflows, permissions or delegation.

<h3 id="faq-content">Does content approval authorize sending by default?</h3>

No. Version, attachments, destination, actual operation authority and guards remain separate from prose approval.

<h3 id="faq-proxy">Can someone saying sign for me replace phone confirmation?</h3>

Do not bypass identity/capability/confirmation from hearsay. Existing processes must establish any delegation; no proxy feature is added.

<h3 id="faq-history">Does feedback history prove recipient read and handled everything?</h3>

No. Verify explicit references and actual contents. Association is not automatic reading, completion or every role's receipt.

<h3 id="faq-revision">Can old approval carry over after text/attachment changes?</h3>

Only explicit scope can answer. Recheck out-of-scope changes rather than copying prior approval for convenience.

<h3 id="faq-signature">Does checking every box create electronic signing/legal receipt?</h3>

No guarantee follows. No signing/certification mechanism is added; real identity, permissions, receipts and applicable rules remain.

## Reading and source

[Ownership/archive](/en/guides/department-minutes-ownership-archive/) · [Completion review](/en/guides/handoff-evidence-audit-checklist/) · [Fallback authority](/en/guides/degraded-handoff-go-no-go/) · [Change-material retention](/en/guides/batch-change-record-retention/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [native reply confirmation guards](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift), [explicit history association](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift), [note handoff](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift).
