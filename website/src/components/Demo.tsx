import { useEffect, useId, useRef, useState } from 'react';
import samples from '../data/preview-samples.json';
import { trackPreviewEvent, type PreviewScenario, type BuyerScenario } from '../lib/preview-events';

interface Props {
  lang: 'zh' | 'en';
  initialScene?: PreviewScenario;
  initialVoiceSample?: 'web' | 'meeting';
}
export default function Demo({ lang, initialScene = 'voice', initialVoiceSample = 'web' }: Props) {
  const en = lang === 'en';
  const home = en ? '/en/' : '/';
  const data = samples[lang];
  const id = 'preview-' + useId().replace(/:/g, '');
  const [scene, setScene] = useState<PreviewScenario>(initialScene);
  const [voiceSample, setVoiceSample] = useState(initialVoiceSample);
  const [text, setText] = useState(data.voice[initialVoiceSample].draft);
  const [draft, setDraft] = useState('');
  const [reading, setReading] = useState(false);
  const [audioStatus, setAudioStatus] = useState('');
  const [answers, setAnswers] = useState({ device: '', playback: '', recording: '', phone: '' });
  const [audioAdvice, setAudioAdvice] = useState('');
  const [radarCase, setRadarCase] = useState<'inquiry' | 'market' | 'followup'>('inquiry');
  const [showJSON, setShowJSON] = useState(false);
  const utterance = useRef<SpeechSynthesisUtterance | null>(null);
  const generation = useRef(0);
  // Ephemeral deduplication only. Dropped interactions are never queued or replayed.
  const selected = useRef(new Set<BuyerScenario>());
  const completed = useRef(new Set<BuyerScenario>());
  const voice = data.voice[voiceSample];
  const snapshot = data.radar[radarCase];
  const task = snapshot.tasks[0];
  const cards = en ? [
    ['voice', 'Read & draft', 'Sample material → editable reply'],
    ['audio', 'Audio self-check', 'Four questions → a useful next step'],
    ['radar', 'Daily sales brief', 'Inquiry / market / follow-up samples'],
  ] as const : [
    ['voice', '网页朗读与草稿', '示例材料 → 可编辑回复'],
    ['audio', '蓝牙四步自检', '四个问题 → 一个排查方向'],
    ['radar', '外贸每日简报', '询盘 / 市场 / 跟进样例切换'],
  ] as const;
  const guide = { voice: voiceSample === 'meeting' ? 'recording-notes-handoff' : 'iphone-agent-voice-drafts', audio: 'bluetooth-audio-input-troubleshooting', radar: 'multi-project-radar-watch' }[scene];

  function intent(value: PreviewScenario, sample = voiceSample): BuyerScenario {
    const buyer = value === 'voice' && sample === 'meeting' ? 'notes' : value;
    if (!selected.current.has(buyer) && trackPreviewEvent('scenario_select', buyer, lang, 'select')) selected.current.add(buyer);
    return buyer;
  }
  function complete(value: PreviewScenario, action: 'insert' | 'self_check' | 'view_json' | 'view_readable') {
    const buyer = intent(value);
    if (!completed.current.has(buyer) && trackPreviewEvent('preview_complete', buyer, lang, action)) completed.current.add(buyer);
  }
  function stopReading(update = true) {
    generation.current++;
    if (utterance.current) {
      utterance.current.onend = null;
      utterance.current.onerror = null;
      utterance.current = null;
      try { window.speechSynthesis.cancel(); } catch { /* Text remains usable. */ }
    }
    if (update) { setReading(false); setAudioStatus(''); }
  }
  useEffect(() => {
    const hide = () => stopReading();
    const visibility = () => { if (document.hidden) hide(); };
    document.addEventListener('visibilitychange', visibility);
    window.addEventListener('pagehide', hide);
    return () => {
      document.removeEventListener('visibilitychange', visibility);
      window.removeEventListener('pagehide', hide);
      stopReading(false);
    };
  }, []);

  function readAloud() {
    intent('voice');
    stopReading();
    const fallback = en ? 'Browser read-aloud is unavailable. Read the sample and keep editing below.' : '浏览器朗读暂不可用，仍可直接阅读示例并编辑草稿。';
    if (!window.speechSynthesis || typeof window.SpeechSynthesisUtterance !== 'function') { setAudioStatus(fallback); return; }
    try {
      const token = ++generation.current;
      const value = new SpeechSynthesisUtterance(voice.material);
      value.lang = en ? 'en-US' : 'zh-CN';
      utterance.current = value;
      value.onend = () => {
        if (generation.current !== token || utterance.current !== value) return;
        utterance.current = null; setReading(false);
        setAudioStatus(en ? 'Read-aloud finished. The summary below is preset sample output.' : '朗读结束；下方摘要仍是预设样例结果。');
      };
      value.onerror = () => {
        if (generation.current !== token || utterance.current !== value) return;
        utterance.current = null; setReading(false); setAudioStatus(fallback);
      };
      setReading(true);
      window.speechSynthesis.speak(value);
    } catch { stopReading(); setAudioStatus(fallback); }
  }
  function chooseScene(value: PreviewScenario) {
    intent(value);
    if (scene !== value) { stopReading(); setScene(value); }
  }
  function checkAudio() {
    if (Object.values(answers).some(x => !x)) return;
    const advice = answers.playback === 'no'
      ? (en ? 'Start with volume and output. Once playback works, repeat the recording sample to check input separately.' : '先查音量与输出；能正常回放后，再单独试录来核对输入。')
      : answers.recording === 'yes'
      ? (en ? 'Your reported sample has sound. If the workspace still has no text, next check speech models and the intended editor.' : '你反馈这次样本有声音。若工作台仍没文字，下一步检查语音模型与目的输入框。')
      : answers.phone === 'yes'
      ? (en ? 'The phone comparison records sound. Check the intended device/app input and microphone permission, then repeat a short sample.' : '手机对照录音有声音。回到实际设备与App，核对可选输入和麦克风权限，再试录一句。')
      : answers.phone === 'no'
      ? (en ? 'Check the recording app’s mic permission, pause other capture and retry in the foreground with the phone microphone.' : '检查录音App的麦克风权限，暂停其他录音，在前台用手机自身麦克风重试。')
      : (en ? 'There is not enough information yet. Record on the phone in an app with permission, then compare the accessory.' : '这组信息还不足以判断。先在有权限的App用手机试录，再与外设对比。');
    setAudioAdvice(advice); complete('audio', 'self_check');
  }
  function radarView(json: boolean) {
    intent('radar');
    if (json !== showJSON) { setShowJSON(json); complete('radar', json ? 'view_json' : 'view_readable'); }
  }

  return <div id="interactive-preview" tabIndex={-1} className="demo scenario-preview" data-preview={scene}>
    <div className="demo-topline"><span>{en ? 'SAMPLE PREVIEW' : '场景预览 · 合成样例'}</span><span>{en ? 'No login or microphone needed' : '无需登录 · 无需麦克风'}</span></div>
    <div className="preview-scenes" role="group" aria-label={en ? 'Choose a preview' : '选择一个预览'}>
      {cards.map(([value, title, description], i) => <button type="button" key={value} id={`${id}-${value}`} aria-controls={`${id}-panel`} aria-pressed={scene === value} aria-keyshortcuts="ArrowLeft ArrowRight Home End" onClick={() => chooseScene(value)} onKeyDown={event => {
        const keys = ['ArrowLeft', 'ArrowRight', 'Home', 'End'];
        if (!keys.includes(event.key)) return;
        event.preventDefault();
        const buttons = event.currentTarget.parentElement?.querySelectorAll<HTMLButtonElement>('button');
        if (!buttons) return;
        const target = event.key === 'Home' ? 0 : event.key === 'End' ? buttons.length - 1 : (i + (event.key === 'ArrowRight' ? 1 : -1) + buttons.length) % buttons.length;
        buttons[target]?.focus();
      }}>
        <span className="preview-scene-title">0{i + 1} · {title}</span><span>{description}</span>
      </button>)}
    </div>
    <section id={`${id}-panel`} className="preview-panel" aria-labelledby={`${id}-${scene}`}>
      {scene === 'voice' && <>
        <div className="preview-toolbar"><label htmlFor={`${id}-sample`}>{en ? 'Sample material' : '选择合成材料'}</label><select id={`${id}-sample`} value={voiceSample} onChange={event => {
          const value = event.target.value as 'web' | 'meeting'; intent('voice', value); stopReading();
          setVoiceSample(value); setText(data.voice[value].draft); setDraft('');
        }}>{(['web', 'meeting'] as const).map(value => <option key={value} value={value}>{data.voice[value].title}</option>)}</select></div>
        <div className="preview-columns">
          <div><p className="preview-label">{en ? 'Sample source → preset summary' : '示例原文 → 预设摘要'}</p><p className="preview-material">{voice.material}</p>
            <div className="preview-actions"><button type="button" className="button preview-secondary" onClick={reading ? () => { stopReading(); setAudioStatus(en ? 'Read-aloud stopped.' : '朗读已停止。'); } : readAloud}>{reading ? (en ? 'Stop read-aloud' : '停止朗读') : (en ? 'Read sample aloud' : '朗读示例材料')}</button></div>
            <p className="preview-summary"><strong>{en ? 'Preset summary: ' : '预设摘要：'}</strong>{voice.summary}</p><p className="preview-status" role="status">{audioStatus}</p>
          </div>
          <div><label className="preview-label" htmlFor={`${id}-draft`}>{en ? 'Edit the sample draft' : '编辑示例草稿'}</label><textarea id={`${id}-draft`} value={text} maxLength={600} onChange={event => { setText(event.target.value); setDraft(''); }} />
            <div className="preview-actions"><button type="button" className="button button-primary" disabled={!text.trim()} onClick={() => { setDraft(text.trim()); complete('voice', 'insert'); }}>{en ? 'Place in sample draft' : '填入本页示例草稿'}</button><button type="button" className="button preview-secondary" onClick={() => { stopReading(); setText(voice.draft); setDraft(''); }}>{en ? 'Reset' : '重置'}</button></div>
            {draft && <p className="preview-draft">{draft}</p>}<p className="preview-status" role="status">{draft ? (en ? 'Placed in this sample draft. In the app, review before sending.' : '已填入本页示例草稿；实际使用时检查后再发送。') : (en ? 'Review the wording and destination before handing over real material.' : '交接真实材料前，先核对文字和目的地。')}</p>
          </div>
        </div>
      </>}
      {scene === 'audio' && <>
        <p className="preview-caption">{en ? 'Answer from your own observations. This page does not read devices or request permissions. Park before operating car audio.' : '按你的实际观察选择；网页不会读取设备或请求权限。车载操作请先停车。'}</p>
        <fieldset className="preview-checks"><legend>{en ? 'Four local self-check questions' : '四步本地自检问答'}</legend>
          {([
            ['device', en ? '1. Which device are you checking?' : '1. 想检查哪种设备？'],
            ['playback', en ? '2. Can you hear playback?' : '2. 回放能听见声音吗？'],
            ['recording', en ? '3. Does a short recording have sound?' : '3. 选定设备试录一句，有声音吗？'],
            ['phone', en ? '4. Does a comparison recording on the phone work?' : '4. 切回手机自身麦克风，对照录音正常吗？'],
          ] as const).map(([key, title]) => <div key={key}><label htmlFor={`${id}-${key}`}>{title}</label><select id={`${id}-${key}`} value={answers[key]} onChange={event => { intent('audio'); setAnswers(previous => ({ ...previous, [key]: event.target.value })); setAudioAdvice(''); }}>
            <option value="">{en ? 'Choose an answer' : '请选择'}</option>{(key === 'device' ? (en ? [['phone', 'iPhone'], ['headset', 'Bluetooth headset'], ['car', 'Parked-car audio']] : [['phone', 'iPhone'], ['headset', '蓝牙耳机'], ['car', '停车后的车载设备']]) : (en ? [['yes', 'Yes'], ['no', 'No'], ['unknown', 'Not sure yet']] : [['yes', '有 / 正常'], ['no', '没有 / 异常'], ['unknown', '还不确定']])).map(([value, label]) => <option key={value} value={value}>{label}</option>)}
          </select></div>)}
        </fieldset>
        <div className="preview-actions"><button type="button" className="button button-primary" disabled={Object.values(answers).some(x => !x)} onClick={checkAudio}>{en ? 'See a suggested next step' : '查看排查建议'}</button><span className="preview-caption">{Object.values(answers).filter(Boolean).length}/4</span></div>
        <p className="preview-status" role="status">{audioAdvice || (en ? 'Complete the four answers for a suggested check, not a hardware diagnosis.' : '完成四问后，根据你的答案给出排查建议，不作硬件诊断。')}</p>
      </>}
      {scene === 'radar' && <>
        <div className="preview-toolbar"><div role="group" aria-label={en ? 'Synthetic brief samples' : '切换合成简报'} className="preview-switches">{(en ? [['inquiry', 'Inquiry'], ['market', 'Market'], ['followup', 'Follow-up']] : [['inquiry', '询盘'], ['market', '市场'], ['followup', '跟进']]).map(([value, label]) => <button type="button" key={value} aria-pressed={radarCase === value} onClick={() => { intent('radar'); setRadarCase(value as typeof radarCase); }}>{label}</button>)}</div>
          <div role="group" aria-label={en ? 'Brief view' : '简报视图'} className="preview-switches"><button type="button" aria-pressed={!showJSON} onClick={() => radarView(false)}>{en ? 'Readable brief' : '可读简报'}</button><button type="button" aria-pressed={showJSON} onClick={() => radarView(true)}>JSON</button></div></div>
        <p className="preview-caption">{en ? 'Synthetic examples in the supported Radar shape. Your workflow supplies the actual data; these are not live leads or market facts.' : '按当前Radar结构制作的合成样例。真实数据由你的工作流提供；这里不是真实询盘或市场情报。'}</p>
        <p className="preview-summary" role="status">{(en ? {
          inquiry: 'Bring the missing specifications. Review quote scope and delivery time before replying.',
          market: 'Bring a dated source. Check the original material before changing a quote assumption.',
          followup: 'Bring the last contact note and open question. Continue in your own business tool after review.',
        } : {
          inquiry: '先补齐规格信息，报价范围与交期核过再回复。',
          market: '先准备带日期的来源，回看原资料后再决定是否调整报价依据。',
          followup: '先核上次联系记录与未解决的问题，复核后回自己的业务工具继续。',
        })[radarCase]}</p>
        {showJSON ? <pre className="preview-json" tabIndex={0} aria-label={en ? 'Sample Radar JSON' : '示例Radar JSON'}><code>{JSON.stringify(snapshot, null, 2)}</code></pre> : <dl className="preview-brief">
          {(en ? [['Task', task.title], ['Status / priority', 'Needs your decision · ' + task.priority], ['Next', task.next], ['Evidence', task.evidence], ['Sample time', snapshot.date_str]] : [['事项', task.title], ['状态 / 优先级', task.status + ' · ' + task.priority], ['下一步', task.next], ['依据', task.evidence], ['示例时间', snapshot.date_str]]).map(([label, value]) => <div key={label}><dt>{label}</dt><dd>{value}</dd></div>)}
        </dl>}
      </>}
      <div className="preview-footer"><p>{en ? 'Preset samples, not live AI processing. Store installation does not require self-signing. Bring your workspace and account; download the speech model when needed. Source guides and later capabilities are separate. Browser read-aloud uses the browser’s voice service.' : '合成材料与预设结果，不是真实AI处理。商店安装不需自行签名；使用需自有工作台与账号，语音模型按需下载。源码指南与后续能力另行区分；网页朗读依赖浏览器语音服务。'}</p><div><a href={`${home}guides/${guide}/`}>{en ? 'Explore this workflow' : '看这个场景怎么用'} →</a><a href={`${home}start/`} onClick={() => { const buyer = intent(scene); trackPreviewEvent('setup_click', buyer, lang, 'setup'); }}>{en ? 'See setup requirements' : '查看接入条件'} →</a></div></div>
    </section>
    <noscript>{en ? 'Enable JavaScript to switch previews or edit the sample. You can still read the scenario guides and setup instructions.' : '启用JavaScript以切换预览或编辑样例，也可直接阅读场景指南与接入步骤。'}</noscript>
  </div>;
}
