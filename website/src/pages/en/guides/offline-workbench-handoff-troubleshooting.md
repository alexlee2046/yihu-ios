---
layout: ../../../layouts/Wave3Guide.astro
title: "Text is ready but the page will not open? Continue in three steps"
description: "Keep the original. Inspect local audio/text first, then check the web connection separately. Resume after confirming the network and destination, rather than repeating the handoff to test it."
lang: en
---

<h2 id="first-answer">Start with one useful check</h2>

Keep the original. Inspect local audio/text first, then check the web connection separately. Resume after confirming the network and destination, rather than repeating the handoff to test it.

## Try this order

1. Keep the original audio/text and inspect completion or interruption. Models should be downloaded, verified and usable.
2. Check the correct trusted HTTPS workspace and login on your phone, preserving security settings.
3. Inspect the destination for an existing draft. For uncertain actions, check the same request record before continuing.

<div role="region" aria-label="Choose your next step" tabindex="0">

| Your situation | What to do | Before continuing |
|---|---|---|
| Local text, unavailable page | Retain the transcript. | Check phone connectivity, HTTPS and service login. |
| An item in the share tray | Review the text/Markdown version. | Confirm later upload and sending in the destination service. |
| Radar cards remain after a refresh failure | Check source time and read status. | Treat old material as needing review, not as a new update. |
| A confirmed reply timed out | Keep the same request record. | Check the original service rather than blindly sending a new request. |

</div>

## FAQ

<h3 id="faq-step-1">Is the whole workflow offline?</h3>

Prepared models and local notes have local paths; model downloads, web pages and service actions have their own connectivity requirements.

<h3 id="faq-step-2">Why does a logged-in page not unlock the brief source?</h3>

Native reads and web sessions are separate. Prepare authenticated material through the supported file-export path, keeping credentials out of URLs.

<h3 id="faq-step-3">What if filtering shows zero items?</h3>

Check project, state, search and the source's supplied scope before concluding that there are no tasks.

<h3 id="faq-step-4">Should I retry immediately when the network returns?</h3>

Inspect the original destination and the same request result first, avoiding duplicate copies or business actions.

## Continue with your task

[Voice drafts](/en/guides/iphone-agent-voice-drafts/) · [Audio input checks](/en/guides/bluetooth-audio-input-troubleshooting/) · [Voice notes](/en/guides/recording-notes-handoff/) · [Daily brief](/en/guides/multi-project-radar-watch/) · [Setup](/en/start/) · [Privacy](/en/privacy/)

<details><summary>Implementation reference</summary>

[README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md) · [Frozen implementation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarStore.swift)

</details>
