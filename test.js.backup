(function(){
  'use strict';
  var GRAMMAR = [
    { level:'A1', sentence:'She ___ a teacher.', options:['is','are','am','be'], correct:0 },
    { level:'A2', sentence:'I ___ to London last year.', options:['go','went','gone','going'], correct:1 },
    { level:'B1', sentence:'If I ___ more time, I would travel.', options:['have','had','will have','having'], correct:1 },
    { level:'B2', sentence:'The report ___ by the manager yesterday.', options:['wrote','was written','has written','is writing'], correct:1 },
    { level:'C1', sentence:'Hardly ___ the meeting when the fire alarm went off.', options:['we had started','had we started','we started','did we start'], correct:1 }
  ];
  var READING = {
    text: '<p>Sarah moved to Berlin three years ago to work for a tech startup. At first, she struggled with the language barrier. But she was determined. Every morning, she spent thirty minutes listening to German podcasts, and every evening she wrote in a journal in German.</p><p>After a year, Sarah could hold a conversation about everyday topics. After two years, she was leading meetings in German. Her colleagues were impressed.</p><p>Today, Sarah teaches English part-time and writes a blog about language learning. Her advice to beginners? "Be patient with yourself. Progress feels slow at first, but one day you will realise you are thinking in the language without translating in your head."</p>',
    questions: [
      { q:'Why did Sarah move to Berlin?', options:['To study','To work for a startup','To teach English','To learn German'], correct:1 },
      { q:'What did she do every morning?', options:['Wrote a journal','Listened to podcasts','Led meetings','Read books'], correct:1 },
      { q:'What is her main advice?', options:['Move to another country','Be patient with yourself','Hire a tutor','Study only grammar'], correct:1 }
    ]
  };
  var LISTENING = {
    audio: ['Good morning, this is your captain speaking.','We are currently experiencing some turbulence.','Please fasten your seatbelts and remain seated.','The cabin crew will be coming through shortly.','We expect to land in approximately twenty minutes.','Thank you for your patience.'],
    question: 'What should passengers do right now?',
    options: ['Go to the bathroom','Fasten their seatbelts','Order food','Talk to the crew'],
    correct: 1
  };
  var WRITING_PROMPT = 'Опишите на английском <b>свой обычный день</b>. Что вы делаете утром, днём и вечером? Минимум 80 символов.';
  var SPEAKING_PROMPT = 'Расскажите 30-60 секунд на английском: <b>что вы делаете в свободное время и почему вам это нравится</b>.';

  var state = { section:'welcome', grammarIdx:0, grammarAnswers:[], readingAnswers:[null,null,null], listeningAnswer:null, writingText:'', speakingTranscript:'', audioPlayed:false };
  var SECTIONS = ['welcome','grammar','reading','listening','writing','speaking','result'];

  function $(s){ return document.querySelector(s); }
  function $$(s){ return document.querySelectorAll(s); }
  function esc(s){ return String(s == null ? '' : s).replace(/[&<>"']/g, function(c){ return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]; }); }

  function updateMiniBar(){
    var idx = SECTIONS.indexOf(state.section);
    var realSections = SECTIONS.length - 2;
    var realIdx = Math.max(0, Math.min(realSections, idx - 1));
    var percent = state.section === 'welcome' ? 0 : state.section === 'result' ? 100 : Math.round((realIdx / realSections) * 100);
    $('#miniFill').style.width = percent + '%';
    var labels = { welcome:'Начало', grammar:'Grammar', reading:'Reading', listening:'Listening', writing:'Writing', speaking:'Speaking', result:'Готово' };
    $('#sectionLabel').textContent = labels[state.section] || '';
  }
  function show(section){
    state.section = section;
    $$('.test-stage').forEach(function(el){ el.hidden = true; });
    var target = document.getElementById('stage-' + section);
    if (target) target.hidden = false;
    updateMiniBar();
    window.scrollTo({ top:0, behavior:'smooth' });
    updateNav();
    if (section === 'grammar') renderGrammar();
    if (section === 'reading') renderReading();
    if (section === 'listening') renderListening();
    if (section === 'writing') renderWriting();
    if (section === 'speaking') renderSpeaking();
  }
  function updateNav(){
    var nav = $('#testNav'), back = $('#backBtn'), next = $('#nextBtn'), s = state.section;
    if (s === 'welcome' || s === 'result'){ nav.hidden = true; return; }
    nav.hidden = false;
    back.disabled = (s === 'grammar' && state.grammarIdx === 0);
    next.disabled = !sectionReady(s);
    if (s === 'speaking') next.textContent = 'Получить результат →';
    else if (s === 'grammar') next.textContent = (state.grammarIdx < GRAMMAR.length - 1) ? 'Следующий вопрос →' : 'К Reading →';
    else next.textContent = 'Далее →';
  }
  function sectionReady(s){
    if (s === 'grammar') return state.grammarAnswers[state.grammarIdx] != null;
    if (s === 'reading') return state.readingAnswers.every(function(a){ return a != null; });
    if (s === 'listening') return state.listeningAnswer != null;
    if (s === 'writing') return state.writingText.trim().length >= 80;
    if (s === 'speaking') return state.speakingTranscript.trim().length >= 20;
    return false;
  }
  function renderGrammar(){
    var card = $('#grammarCard');
    var q = GRAMMAR[state.grammarIdx];
    var selected = state.grammarAnswers[state.grammarIdx];
    var letters = ['A','B','C','D'];
    card.innerHTML = ''
      + '<div class="q-meta"><span>Вопрос ' + (state.grammarIdx + 1) + ' из ' + GRAMMAR.length + '</span><span class="q-level">' + q.level + '</span></div>'
      + '<div class="q-sentence">' + esc(q.sentence) + '</div>'
      + '<div class="q-options">'
      + q.options.map(function(opt, i){
        return '<button type="button" class="q-option' + (selected === i ? ' selected' : '') + '" data-i="' + i + '"><span class="q-option-letter">' + letters[i] + '</span><span>' + esc(opt) + '</span></button>';
      }).join('')
      + '</div>';
    card.querySelectorAll('.q-option').forEach(function(btn){
      btn.addEventListener('click', function(){
        state.grammarAnswers[state.grammarIdx] = Number(btn.getAttribute('data-i'));
        renderGrammar();
        updateNav();
      });
    });
    updateNav();
  }
  function renderReading(){
    $('#readingText').innerHTML = READING.text;
    var wrap = $('#readingQuestions');
    var letters = ['A','B','C','D'];
    wrap.innerHTML = READING.questions.map(function(q, qi){
      return '<div class="rq" data-q="' + qi + '"><div class="rq-label">Вопрос ' + (qi + 1) + '</div><div class="rq-question">' + esc(q.q) + '</div><div class="rq-options">'
        + q.options.map(function(opt, i){
          return '<button type="button" class="q-option' + (state.readingAnswers[qi] === i ? ' selected' : '') + '" data-i="' + i + '"><span class="q-option-letter">' + letters[i] + '</span><span>' + esc(opt) + '</span></button>';
        }).join('')
        + '</div></div>';
    }).join('');
    wrap.querySelectorAll('.rq').forEach(function(el, qi){
      el.querySelectorAll('.q-option').forEach(function(btn){
        btn.addEventListener('click', function(){
          state.readingAnswers[qi] = Number(btn.getAttribute('data-i'));
          renderReading();
          updateNav();
        });
      });
    });
  }
  function renderListening(){
    var letters = ['A','B','C','D'];
    var wrap = $('#listeningQuestion');
    wrap.innerHTML = '<div class="q-text">' + esc(LISTENING.question) + '</div><div class="q-options">'
      + LISTENING.options.map(function(opt, i){
        return '<button type="button" class="q-option' + (state.listeningAnswer === i ? ' selected' : '') + '" data-i="' + i + '"><span class="q-option-letter">' + letters[i] + '</span><span>' + esc(opt) + '</span></button>';
      }).join('')
      + '</div>';
    wrap.querySelectorAll('.q-option').forEach(function(btn){
      btn.addEventListener('click', function(){
        state.listeningAnswer = Number(btn.getAttribute('data-i'));
        renderListening();
        updateNav();
      });
    });
  }
  function playAudio(){
    var btn = $('#playBtn'), status = $('#audioStatus');
    if (state.audioPlayed){ status.textContent = 'Аудио уже воспроизведено'; return; }
    if (!('speechSynthesis' in window)){ status.textContent = 'Синтез речи не поддерживается'; return; }
    var text = LISTENING.audio.join(' ');
    var utt = new SpeechSynthesisUtterance(text);
    utt.lang = 'en-GB';
    utt.rate = 0.9;
    var voices = speechSynthesis.getVoices();
    var gb = voices.find(function(v){ return v.lang === 'en-GB'; }) || voices.find(function(v){ return v.lang && v.lang.indexOf('en') === 0; });
    if (gb) utt.voice = gb;
    btn.classList.add('playing');
    btn.disabled = true;
    status.textContent = 'Играет...';
    state.audioPlayed = true;
    utt.onend = function(){ btn.classList.remove('playing'); btn.disabled = false; status.textContent = 'Прослушано. Выберите ответ.'; };
    utt.onerror = function(){ btn.classList.remove('playing'); btn.disabled = false; status.textContent = 'Ошибка воспроизведения'; };
    speechSynthesis.cancel();
    speechSynthesis.speak(utt);
  }
  function renderWriting(){
    $('#writingPrompt').innerHTML = WRITING_PROMPT;
    var ta = $('#writingInput');
    ta.value = state.writingText;
    updateWritingCount();
    ta.oninput = function(){ state.writingText = ta.value; updateWritingCount(); updateNav(); };
  }
  function updateWritingCount(){ $('#writingCount').textContent = state.writingText.length + ' символов'; }
  var recognition = null, recording = false, recordTimer = null, recordStart = 0;
  function renderSpeaking(){
    $('#speakingPrompt').innerHTML = SPEAKING_PROMPT;
    var tb = $('#transcriptBox');
    if (state.speakingTranscript){ tb.hidden = false; $('#transcriptText').textContent = state.speakingTranscript; }
    else tb.hidden = true;
  }
  function toggleRecord(){
    var btn = $('#recordBtn'), label = $('#recordLabel');
    var SR = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SR){ alert('Голосовой ввод не поддерживается в этом браузере'); return; }
    if (recording){
      recording = false;
      if (recognition) recognition.stop();
      if (recordTimer) clearInterval(recordTimer);
      btn.classList.remove('recording');
      label.textContent = 'Говорить снова';
      return;
    }
    recognition = new SR();
    recognition.lang = 'en-US';
    recognition.continuous = true;
    recognition.interimResults = true;
    var final = state.speakingTranscript || '';
    recognition.onresult = function(e){
      var interim = '';
      for (var i = e.resultIndex; i < e.results.length; i++){
        var t = e.results[i][0].transcript;
        if (e.results[i].isFinal) final += t + ' ';
        else interim += t;
      }
      state.speakingTranscript = (final + interim).trim();
      $('#transcriptBox').hidden = false;
      $('#transcriptText').textContent = state.speakingTranscript;
      updateNav();
    };
    recognition.onerror = function(){ recording = false; btn.classList.remove('recording'); label.textContent = 'Говорить снова'; if (recordTimer) clearInterval(recordTimer); };
    recognition.onend = function(){ recording = false; btn.classList.remove('recording'); if (recordTimer) clearInterval(recordTimer); label.textContent = state.speakingTranscript.length >= 20 ? 'Записать снова' : 'Говорить'; };
    recognition.start();
    recording = true;
    btn.classList.add('recording');
    label.textContent = 'Стоп';
    recordStart = Date.now();
    var timerEl = $('#recordTimer');
    recordTimer = setInterval(function(){
      var s = Math.floor((Date.now() - recordStart) / 1000);
      timerEl.textContent = String(Math.floor(s / 60)).padStart(2,'0') + ':' + String(s % 60).padStart(2,'0');
      if (s >= 90) toggleRecord();
    }, 300);
  }
  function calcScores(){
    var gCorrect = state.grammarAnswers.filter(function(a, i){ return a === GRAMMAR[i].correct; }).length;
    var gPercent = Math.round((gCorrect / GRAMMAR.length) * 100);
    var rCorrect = state.readingAnswers.filter(function(a, i){ return a === READING.questions[i].correct; }).length;
    var rPercent = Math.round((rCorrect / READING.questions.length) * 100);
    var lPercent = state.listeningAnswer === LISTENING.correct ? 100 : 0;
    var wLen = state.writingText.trim().length;
    var wWords = state.writingText.trim().split(/\s+/).filter(Boolean).length;
    var wPercent = Math.min(100, Math.round((wLen / 200) * 60) + (wWords >= 30 ? 40 : 0));
    var sLen = state.speakingTranscript.trim().length;
    var sPercent = Math.min(100, Math.round((sLen / 150) * 100));
    return { gPercent:gPercent, rPercent:rPercent, lPercent:lPercent, wPercent:wPercent, sPercent:sPercent };
  }
  function scoreToLevel(p){
    if (p < 25) return 'A1';
    if (p < 45) return 'A2';
    if (p < 65) return 'B1';
    if (p < 80) return 'B2';
    if (p < 92) return 'C1';
    return 'C2';
  }
  function renderResult(){
    var s = calcScores();
    var overall = Math.round((s.gPercent + s.rPercent + s.lPercent + s.wPercent + s.sPercent) / 5);
    var level = scoreToLevel(overall);
    var names = { A1:'Beginner', A2:'Elementary', B1:'Intermediate', B2:'Upper-Intermediate', C1:'Advanced', C2:'Proficiency' };
    $('#resultLevel').textContent = level;
    $('#resultName').textContent = names[level];
    var profile = [
      { label:'Grammar', level:scoreToLevel(s.gPercent) },
      { label:'Reading', level:scoreToLevel(s.rPercent) },
      { label:'Listening', level:scoreToLevel(s.lPercent) },
      { label:'Writing', level:scoreToLevel(s.wPercent) },
      { label:'Speaking', level:scoreToLevel(s.sPercent) }
    ];
    $('#resultProfile').innerHTML = profile.map(function(p){
      return '<div class="rp-item"><div class="rp-label">' + p.label + '</div><div class="rp-level">' + p.level + '</div></div>';
    }).join('');
    var strengths = profile.filter(function(p){ return p.level > level; }).map(function(p){ return p.label; });
    var weaknesses = profile.filter(function(p){ return p.level < level; }).map(function(p){ return p.label; });
    var summary = '';
    if (strengths.length) summary += '💪 Сильные стороны: <b>' + strengths.join(', ') + '</b>. ';
    if (weaknesses.length) summary += '📈 Стоит подтянуть: <b>' + weaknesses.join(', ') + '</b>. ';
    summary += 'Программа обучения будет адаптирована под ваш профиль.';
    $('#resultSummary').innerHTML = summary;
    fetch('/api/test/submit', {
      method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin',
      body: JSON.stringify({ answers: { grammar:s.gPercent, reading:s.rPercent, listening:s.lPercent, writing:s.wPercent, speaking:s.sPercent } })
    }).catch(function(){});
  }
  function next(){
    var s = state.section;
    if (s === 'grammar'){
      if (state.grammarIdx < GRAMMAR.length - 1){ state.grammarIdx++; renderGrammar(); }
      else show('reading');
      return;
    }
    if (s === 'reading') return show('listening');
    if (s === 'listening') return show('writing');
    if (s === 'writing') return show('speaking');
    if (s === 'speaking'){ renderResult(); return show('result'); }
  }
  function back(){
    var s = state.section;
    if (s === 'grammar'){ if (state.grammarIdx > 0){ state.grammarIdx--; renderGrammar(); } else show('welcome'); return; }
    if (s === 'reading') return show('grammar');
    if (s === 'listening') return show('reading');
    if (s === 'writing') return show('listening');
    if (s === 'speaking') return show('writing');
  }
  function init(){
    $('#startTest').addEventListener('click', function(){ show('grammar'); });
    $('#nextBtn').addEventListener('click', next);
    $('#backBtn').addEventListener('click', back);
    $('#playBtn').addEventListener('click', playAudio);
    $('#recordBtn').addEventListener('click', toggleRecord);
    $('#restartBtn').addEventListener('click', function(){ location.reload(); });
    if ('speechSynthesis' in window){ speechSynthesis.getVoices(); speechSynthesis.onvoiceschanged = function(){ speechSynthesis.getVoices(); }; }
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();