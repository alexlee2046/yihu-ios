---
layout: ../../../layouts/Wave3Guide.astro
title: "Daily inquiry & market brief for export sales, on iPhone"
description: "Review your existing inquiry tasks, source material and next steps from a supported JSON brief. Includes a synthetic export-sales example."
lang: en
preview: radar
---

<h2 id="first-answer">Start with a useful next step</h2>

Start the day with what needs your decision or follow-up, then inspect its source and next step. Yihu reads your structured brief; your existing business workflow provides the customer and market material.

## Three inputs, three useful next steps

<div role="region" aria-label="Daily sales brief" tabindex="0">

| Your existing material | What the brief says | Next step |
|---|---|---|
| Incomplete inquiry | Specifications and quote scope need confirmation. | List questions, review, then reply. |
| Changed market material | Show its source and update time. | Check the original before changing a quote. |
| Unfinished follow-up | Identify the current blocker and what to prepare. | Continue in your business tool. |

</div>

## A synthetic brief in the current format

This illustrates structure, not actual leads or market intelligence. Task project matches project path. A complete snapshot also carries decisions and active/stale/cold collections.

```json
{"date_str":"2026-10-22 09:00:00","tasks":[{"id":"sample-inquiry","project":"export-demo","title":"Missing inquiry specifications","status":"等你决策","priority":"P1","next":"Confirm missing parameters before drafting a reply","url":"https://example.com/brief","evidence":"Synthetic material for preview"}],"decisions":[],"active":[{"name":"Export follow-up","path":"export-demo","timestamp":1792630800,"message":"Synthetic, not live material"}],"stale":[],"cold":[]}
```

Prepare the supported shape using your existing workflow, then connect a compatible source or supported file export. Authenticated material uses the existing file-export path; web login and brief access have separate setup.

## How it fits your sales tools

Yihu makes tasks and workspace handoff accessible on iPhone. Your email, CRM and documents still supply data and handle actual follow-up. Yihu does not automatically connect those accounts or supply a lead database/collection service. Check original material when its freshness is unclear.

A paired Apple Watch can show phone summaries and prompt you to return to the phone. Confirm important decisions in the phone and original business workflow.

## FAQ

<h3 id="faq-source">Will it collect customer inquiries automatically?</h3>

Your business workflow supplies the data. Yihu reads a prepared source rather than providing email/CRM integration or market data.

<h3 id="faq-json">Must I build a new backend?</h3>

First check whether an existing tool can provide compatible JSON or a supported file export. Yihu is the client; see setup requirements.

<h3 id="faq-fresh">Does a displayed task prove current information?</h3>

Review source time and read status. Check stale or failed material in the original business system before deciding.

<h3 id="faq-send">Does reading the brief reply to customers?</h3>

No. Choose and review the next step first; actual replies depend on your original tools and configured workspace capabilities.

## Continue

[Voice drafts](/en/guides/iphone-agent-voice-drafts/) · [Audio checks](/en/guides/bluetooth-audio-input-troubleshooting/) · [Voice notes](/en/guides/recording-notes-handoff/) · [Daily brief](/en/guides/multi-project-radar-watch/) · [Setup](/en/start/) · [Privacy](/en/privacy/)

<details><summary>Implementation references</summary>

[Frozen implementation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift) · [README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)

</details>
