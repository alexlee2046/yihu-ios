import { useEffect, useRef, useState } from 'react';

type Phase = 'idle' | 'playing' | 'editing' | 'inserted';
interface Props { lang: 'zh' | 'en' }
export default function Demo({ lang }: Props) {
  const en = lang === 'en';
  const sample = en ? 'Help me organize today’s project updates.' : '帮我整理今天的项目进展。';
  const [phase, setPhase] = useState<Phase>('idle');
  const [text, setText] = useState('');
  const [draft, setDraft] = useState('');
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState('');
  const audio = useRef<HTMLAudioElement>(null);
  const editor = useRef<HTMLTextAreaElement>(null);
  const generation = useRef(0);

  useEffect(() => () => { generation.current++; audio.current?.pause(); }, []);

  function finish() {
    setText(sample);
    setProgress(1);
    setPhase('editing');
  }

  async function play() {
    const current = ++generation.current;
    setError(''); setText(''); setDraft(''); setProgress(0); setPhase('playing');
    try {
      if (!audio.current) throw new Error('Audio unavailable');
      audio.current.currentTime = 0;
      await audio.current.play();
    } catch {
      if (current !== generation.current) return;
      setError(en ? 'Audio could not play. You can still edit the sample below.' : '示例音频暂时无法播放，你仍可编辑下方示例文字。');
      finish();
    }
  }

  function stop() {
    generation.current++;
    audio.current?.pause();
    setPhase('idle'); setText(''); setProgress(0); setError('');
  }

  function reset() {
    stop(); setDraft('');
  }

  return <div className="demo" data-phase={phase}>
    <audio ref={audio} src={`/audio/demo-${lang}.m4a`} preload="none" onEnded={finish}
      onError={() => { if (phase === 'playing') { setError(en ? 'Audio unavailable; sample text is ready.' : '音频暂不可用，示例文字已准备好。'); finish(); } }}
      onTimeUpdate={() => {
        const player = audio.current;
        if (!player || !Number.isFinite(player.duration) || phase !== 'playing') return;
        const value = Math.min(player.currentTime / player.duration, 1);
        setProgress(value); setText(sample.slice(0, Math.ceil(value * sample.length)));
      }} />
    <div className="demo-topline"><span>{en ? 'INTERACTIVE DEMO' : '交互演示'}</span><span>{en ? 'Sample content · no microphone access' : '示例内容 · 无需麦克风'}</span></div>
    <ol className="demo-steps" aria-label={en ? 'Demo steps' : '演示步骤'}>
      {(en ? ['Listen', 'Review', 'Insert'] : ['听见', '校对', '填入']).map((label, i) => <li key={label} aria-current={(phase === 'idle' || phase === 'playing' ? 0 : phase === 'editing' ? 1 : 2) === i ? 'step' : undefined}><span>0{i + 1}</span>{label}</li>)}
    </ol>
    <div className="demo-body">
      <div className="transcript-panel">
        <div className="recorder-line"><img src="/icons/microphone.svg" width="24" height="24" alt="" /><span>{en ? 'A thought, out loud.' : '把想法，说出来。'}</span></div>
        <div className="audio-progress"><progress value={progress} max="1" aria-label={en ? 'Example playback progress' : '示例播放进度'} /></div>
        <label htmlFor="transcript">{en ? 'Review and edit the transcript' : '校对并编辑转写文字'}</label>
        <textarea id="transcript" ref={editor} value={text} disabled={phase === 'idle' || phase === 'playing' || phase === 'inserted'} maxLength={600} placeholder={en ? 'Play the sample to see words appear here.' : '播放示例，看一句话变成文字。'} onChange={e => setText(e.target.value)} />
        <div className="demo-actions">
          {(phase === 'idle' || phase === 'playing') && <button type="button" className="button button-primary" onClick={phase === 'playing' ? stop : play}><img src={`/icons/${phase === 'playing' ? 'stop' : 'play'}.svg`} width="18" height="18" alt="" />{phase === 'playing' ? (en ? 'Stop playback' : '停止播放') : (en ? 'Play sample' : '播放示例')}</button>}
          {phase === 'editing' && <button type="button" className="button button-primary" disabled={!text.trim()} onClick={() => { setDraft(text.trim()); setPhase('inserted'); }}>{en ? 'Insert into draft' : '填入草稿'}<img src="/icons/arrow-right.svg" width="20" height="20" alt="" /></button>}
          {phase === 'inserted' && <button type="button" className="button button-primary" onClick={reset}>{en ? 'Try again' : '再体验一次'}</button>}
          {phase === 'editing' && <button type="button" className="text-button" onClick={play}>{en ? 'Replay sample' : '重新播放'}</button>}
        </div>
        <p className="demo-error" role="alert">{error}</p>
      </div>
      <div className="workbench-panel">
        <div className="workbench-title"><img src="/icons/browser.svg" width="22" height="22" alt="" /><span>{en ? 'My workbench' : '我的工作台'}</span><span className="sample-label">{en ? 'Demo' : '示例'}</span></div>
        <div className="workbench-draft" aria-live="polite"><span className="field-label">{en ? 'Draft' : '草稿'}</span><p className={draft ? 'draft-content' : 'draft-empty'}>{draft || (en ? 'Your reviewed words will appear here.' : '校对后的文字，会出现在这里。')}</p></div>
        <p className="draft-note" role="status">{phase === 'inserted' ? (en ? 'Inserted into this demo only. Nothing was sent.' : '已填入本页演示草稿，未发送任何内容。') : (en ? 'You decide what to send, and when.' : '发送之前，由你确认。')}</p>
      </div>
    </div>
    <noscript>{en ? 'Enable JavaScript to try the demo. Yihu transcribes speech into a draft for you to review before sending.' : '启用 JavaScript 即可体验。实际 App 会将语音转写为草稿，由你检查后决定发送。'}</noscript>
  </div>;
}
