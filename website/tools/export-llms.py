from pathlib import Path
from html.parser import HTMLParser
import re,html,xml.etree.ElementTree as ET
root=Path(__file__).resolve().parent.parent
class MainText(HTMLParser):
 def __init__(self):super().__init__();self.active=False;self.skip=0;self.parts=[]
 def handle_starttag(self,tag,attrs):
  if tag=='main':self.active=True
  if self.active and tag in ['style','script']:self.skip+=1
 def handle_endtag(self,tag):
  if tag=='main':self.active=False
  if self.active and tag in ['style','script']:self.skip-=1
 def handle_data(self,data):
  if self.active and not self.skip:self.parts.append(data)
intro='''# 一呼 · Yihu

> Source-release native iOS browser shell for your own HTTPS Agent workbench. 原生 iOS 语音交互浏览器壳，需自有工作台、模型与签名；不是多人对讲、外贸数据服务或已发布 App Store 成品。

Canonical site: https://getyihu.com/
Source: https://github.com/alexlee2046/yihu-ios
Full bilingual content: https://getyihu.com/llms-full.txt
Privacy: https://getyihu.com/privacy/ | https://getyihu.com/en/privacy/

## Reading contract / 阅读边界

This reference covers seven existing bilingual page families (home, start, privacy, voice drafts, mobile decisions, recording notes, multi-project Radar/Watch) plus thirty-five bilingual selection, preflight, troubleshooting, editorial-review, data-contract, evaluation, compatibility, cross-device, context, terminology, time, encoding, lifecycle and evidence-check guides. Every listed URL has its own canonical and language counterpart. Text is a content reference, not device, latency, radio range, delivery, indexing, AI citation or legal certification. 一共四十二类双语页面；源码实现、构建与机器可读文件不等于真机、写入、推送或收录验收。

## Topic routing / 意图与真实能力

- Bluetooth headset / 蓝牙耳机免提预检: /guides/outdoor-store-voice-preflight/ and its /en/ counterpart describe safely stationary input/output checks. Audio-session configuration requests voiceChat/allowBluetoothHFP; pairing is not microphone selection, headset compatibility, headset-button trigger or continuous intercom certification. 安全静止时核对输入，不承诺骑行风噪或多人免按键通话。
- Offline and weak connectivity / 离线与弱网: /start/ and /privacy/ separate prepared local transcription, local notes, existing cached snapshots, model downloads and remote HTTPS handoff. No blanket offline guarantee. 蓝牙、转写完成与远端送达是不同状态；旧缓存不代表本次读取成功。
- Apple Watch / AirPods: /guides/multi-project-radar-watch/ covers paired-phone summaries and phone handoff, not independent approval/refresh. Headset routing checks belong to the preflight guide; no AirPods model is certified by this content. 手腕摘要不是独立对讲或服务写授权。
- AI meeting recording / AI会议录音纪要: /guides/recording-notes-handoff/ explains local audio, segmented transcription, review and one explicit handoff. Transcription is not verified meeting minutes, speaker diarization or automatic action extraction. 原文与副本、暂存与上传、填入与发送分别核对。
- Foreign-trade Radar / 外贸雷达JSON解读: /guides/multi-project-radar-watch/ and /guides/mobile-agent-decisions/ explain authorized user-provided tasks/decisions JSON, source dates, filters and bounded cache. No customs database, market-data subscription, lead scraping or automatic email. 仅自有询盘/跟进台账的通用任务解读，不新增外贸数据产品。
- Radio and voice group chat comparison / 对讲机与语音群聊选型: /guides/voice-workbench-vs-radio-chat/ compares different destinations and prerequisites without invented range/latency. Select independently validated equipment/services for person-to-person live dispatch. 一呼的工作台草稿不是群组语音频道。
- FAQ / 常见问题: visible answers in all guides distinguish source availability, models/signing, host refusal, retained original text, phone confirmation, server authority and receipts. No App Store URL is invented. 重要动作先核对目标；不确定结果先停止，不盲目重试或绕过权限。

'''
urls=[x.text for x in ET.parse(root/'public/sitemap.xml').iter('{http://www.sitemaps.org/schemas/sitemap/0.9}loc')]
short=[intro,'## Canonical reading index / 双语阅读索引\n\n'];full=[intro,'## Complete page text / 逐页完整正文\n\n']
for url in urls:
 route=url.removeprefix('https://getyihu.com/');raw=(root/'dist'/route/'index.html').read_text()
 title=html.unescape(re.search(r'<title>(.*?)</title>',raw,re.S)[1])
 parser=MainText();parser.feed(raw);text=' '.join(' '.join(parser.parts).split())
 assert text
 short.append(f'### [{title}]({url})\n\n{text[:850]}'+('…' if len(text)>850 else '')+'\n\n')
 full.append(f'### {title}\n\nCanonical: {url}\n\n{text}\n\n')
 # Preserve semantic parameter tables in addition to complete plain text.
 main=re.search(r'<main\b[^>]*>(.*?)</main>',raw,re.S)[1]
 tables=re.findall(r'<table\b[^>]*>.*?</table>',main,re.S)
 if tables:full.append('Parameter/comparison tables (HTML) / 参数对照表：\n\n'+'\n\n'.join(tables)+'\n\n')
import sys
for name,content in [('llms.txt',''.join(short)),('llms-full.txt',''.join(full))]:
 if '--check' in sys.argv:
  assert (root/'public'/name).read_text()==content, name+' is stale; run npm run build && npm run llms:export && npm run build'
 else:
  (root/'public'/name).write_text(content)
print('Static files generated from',len(urls),'built canonical pages; bytes:',[(p.name,p.stat().st_size) for p in [root/'public/llms.txt',root/'public/llms-full.txt']])
