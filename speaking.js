(function(){
  var btn = document.getElementById('themeToggle');
  try {
    var saved = localStorage.getItem('iomaeng_theme');
    if (saved === 'light') document.documentElement.classList.add('light');
    else if (saved === 'dark') document.documentElement.classList.remove('light');
    else document.documentElement.classList.add('light');
  } catch(e){}
  if (btn) btn.addEventListener('click', function(){
    var isLight = document.documentElement.classList.toggle('light');
    try { localStorage.setItem('iomaeng_theme', isLight ? 'light' : 'dark'); } catch(e){}
  });
  var TOPICS = null, currentTopic = null;
  function pick(){ if (!TOPICS || !TOPICS.length) return null; return TOPICS[Math.floor(Math.random() * TOPICS.length)]; }
  fetch('/api/speaking-topics').then(function(r){ return r.json(); }).then(function(d){
    if (d && d.ok && d.items){ TOPICS = d.items; setTopic(); }
  });
  function setTopic(){
    currentTopic = pick();
    if (!currentTopic) return;
    document.getElementById('spkPrompt').innerHTML = '<b>Тема:</b> ' + currentTopic.prompt;
  }
  var recognition = null, recording = false, timerInterval = null, startTime = 0, transcript = '';
  function toggleRecord(){
    var SR = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SR){ alert('Голосовой ввод не поддерживается'); return; }
    var btn = document.getElementById('spkBtn'), label = document.getElementById('spkLabel');
    if (recording){
      recording = false;
      if (recognition) recognition.stop();
      if (timerInterval) clearInterval(timerInterval);
      btn.classList.remove('recording');
      label.textContent = 'Говорить снова';
      return;
    }
    recognition = new SR();
    recognition.lang = 'en-US';
    recognition.continuous = true;
    recognition.interimResults = true;
    var final = transcript || '';
    recognition.onresult = function(e){
      var interim = '';
      for (var i = e.resultIndex; i < e.results.length; i++){
        var t = e.results[i][0].transcript;
        if (e.results[i].isFinal) final += t + ' ';
        else interim += t;
      }
      transcript = (final + interim).trim();
      document.getElementById('spkTranscript').hidden = false;
      document.getElementById('stText').textContent = transcript;
    };
    recognition.onend = function(){
      recording = false;
      btn.classList.remove('recording');
      if (timerInterval) clearInterval(timerInterval);
      label.textContent = transcript.length >= 20 ? 'Записать снова' : 'Говорить';
    };
    recognition.onerror = function(){ recording = false; btn.classList.remove('recording'); if (timerInterval) clearInterval(timerInterval); };
    recognition.start();
    recording = true;
    btn.classList.add('recording');
    label.textContent = 'Стоп';
    startTime = Date.now();
    var timerEl = document.getElementById('spkTimer');
    timerInterval = setInterval(function(){
      var s = Math.floor((Date.now() - startTime) / 1000);
      timerEl.textContent = String(Math.floor(s / 60)).padStart(2,'0') + ':' + String(s % 60).padStart(2,'0');
      if (s >= 90) toggleRecord();
    }, 300);
  }
  document.getElementById('spkBtn').addEventListener('click', toggleRecord);
  document.getElementById('newTopicBtn').addEventListener('click', function(){
    setTopic(); transcript = '';
    document.getElementById('spkTranscript').hidden = true;
    document.getElementById('spkFeedback').hidden = true;
    document.getElementById('spkTimer').textContent = '00:00';
  });
  document.getElementById('checkBtn').addEventListener('click', function(){
    if (transcript.length < 20){ alert('Слишком короткий ответ'); return; }
    var btn = this;
    btn.disabled = true;
    btn.textContent = 'AI думает...';
    fetch('/api/speaking/feedback', {
      method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin',
      body: JSON.stringify({ transcript: transcript, topic: currentTopic ? currentTopic.prompt : 'free' })
    })
      .then(function(r){ return r.json(); })
      .then(function(d){
        btn.disabled = false;
        btn.textContent = 'Проверить с AI';
        if (!d || !d.ok){ alert((d && d.error) || 'Ошибка'); return; }
        renderFeedback(d.result);
      })
      .catch(function(e){ btn.disabled = false; btn.textContent = 'Проверить с AI'; alert(e.message); });
  });
  function renderFeedback(r){
    var host = document.getElementById('spkFeedback');
    host.hidden = false;
    var overall = r.overall || '—';
    var fluency = (r.fluency && r.fluency.score) || 0;
    var vocab = (r.vocabulary && r.vocabulary.score) || 0;
    var grammar = (r.grammar && r.grammar.score) || 0;
    var html = '<div class="fb-overall"><div><div class="fb-overall-label">Overall Level</div></div><div class="fb-overall-value">' + overall + '</div></div>';
    html += '<div class="fb-criteria">' + crit('Fluency', fluency) + crit('Vocabulary', vocab) + crit('Grammar', grammar) + '</div>';
    if (r.highlights && r.highlights.length) html += '<div class="fb-section"><h4>Strengths</h4><ul>' + r.highlights.map(function(h){ return '<li>' + h + '</li>'; }).join('') + '</ul></div>';
    if (r.improvements && r.improvements.length) html += '<div class="fb-section"><h4>Improvements</h4><ul>' + r.improvements.map(function(h){ return '<li>' + h + '</li>'; }).join('') + '</ul></div>';
    if (r.better) html += '<div class="fb-section"><h4>Native version</h4><div class="fb-better">' + r.better + '</div></div>';
    if (r.nextSteps) html += '<div class="fb-section"><h4>Next step</h4><p style="font-size:14.5px;line-height:1.7;color:var(--text-muted)">' + r.nextSteps + '</p></div>';
    host.innerHTML = html;
    host.scrollIntoView({ behavior:'smooth', block:'start' });
  }
  function crit(name, score){
    return '<div class="fb-crit"><div class="fb-crit-name">' + name + '</div><div class="fb-crit-bar"><div class="fb-crit-fill" style="width:' + score + '%"></div></div><div class="fb-crit-score">' + score + '</div></div>';
  }
})();