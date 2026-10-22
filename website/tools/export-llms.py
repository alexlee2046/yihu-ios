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

> Voice-first iPhone workspace for your own HTTPS Agent services. 在 iPhone 上口述草稿、整理录音笔记、检查音频输入，并查看自己的每日跟进简报。

Canonical site: https://getyihu.com/
Source: https://github.com/alexlee2046/yihu-ios
Full bilingual content: https://getyihu.com/llms-full.txt
Privacy: https://getyihu.com/privacy/ | https://getyihu.com/en/privacy/

## Start with a task / 从真实任务开始

- Voice drafts / iPhone语音AI草稿: /guides/iphone-agent-voice-drafts/ compares a voice-first workspace with mobile-browser copy and paste.
- Bluetooth / 蓝牙与停车后车载排障: /guides/bluetooth-audio-input-troubleshooting/ checks input, playback, a short sample and device switching. AirPods and other headset routes depend on device/system conditions.
- Voice notes and meeting action items / 录音与结构化待办: /guides/recording-notes-handoff/ retains the original and hands material to your chosen organizing tool.
- Foreign-trade daily brief / 外贸每日跟进: /guides/multi-project-radar-watch/ displays your own inquiry/task JSON, sources and next steps; Apple Watch can show paired-phone summaries.
- Offline / 弱网准备: /start/ explains setup and the difference between prepared local transcription and a remote workspace.
- FAQ / 选型与使用条件: the website is a source release requiring iOS 18+, signing, speech models and your own workspace. Review drafts before sending; the destination may save or sync them. Preview cards use samples, not live AI results.

## Reading index / 阅读索引

The index follows the sitemap's 174 indexable bilingual URLs. Six technical-reference routes remain accessible with noindex,follow and are not exported here. 中文根路径为/，英文为/en/。Descriptions explain workflows, not measured accuracy, background recording, radio range, delivery, search indexing or AI-citation guarantees. No App Store listing, hosted Agent/CRM service or inquiry collection is supplied.

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
