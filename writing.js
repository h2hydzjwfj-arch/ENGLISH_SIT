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
  var TASKS = null, currentTask = null;
  fetch('/api/writing-tasks').then(function(r){ return r.json(); }).then(function(d){
    if (d && d.ok && d.items){ TASKS = d.items; pickTask(); }
  });
  function pickTask(){
    if (!TASKS || !TASKS.length) return;
    currentTask = TASKS[Math.floor(Math.random() * TASKS.length)];
    document.getElementById('wtText').innerHTML = currentTask.text;
    document.getElementById('wrtResult').hidden = true;
  }
  document.getElementById('newTaskBtn').addEventListener('click', pickTask);
  var ta = document.getElementById('wrtInput');
  var counter = document.getElementById('wrtCount');
  var checkBtn = document.getElementById('checkWritingBtn');
  var resultEl = document.getElementById('wrtResult');
  // Цель по словам в зависимости от уровня (Cambridge / IELTS)
  var WORD_GOALS = {
    'A1': 30, 'A2': 50, 'B1': 100,
    'B2': 150, 'C1': 220, 'C2': 250
  };
  var currentGoal = 100; // по умолчанию B1

  function updateMeta(){
    var text = ta.value || '';
    var len = text.length;
    var words = text.trim().split(/\s+/).filter(Boolean).length;
    var goal = currentGoal;
    var reached = words >= goal;
    counter.innerHTML = words + ' слов · ' + len + ' знаков';
    // Ищем или создаём span с целью
    var goalEl = counter.parentNode.querySelector('.wrt-goal');
    if (!goalEl){
      goalEl = document.createElement('span');
      goalEl.className = 'wrt-goal';
      counter.parentNode.appendChild(goalEl);
    }
    goalEl.classList.toggle('reached', reached);
    goalEl.textContent = reached ? 'Цель достигнута' : ('Цель: ' + goal + ' слов');
    checkBtn.disabled = words < 20; // минимум 20 слов для проверки
  }

  // Получаем уровень пользователя и обновляем цель
  fetch('/api/me', { credentials:'same-origin' })
    .then(function(r){ return r.json(); })
    .then(function(d){
      if (d && d.ok && d.profile && d.profile.level){
        var lvl = d.profile.level;
        if (WORD_GOALS[lvl]) currentGoal = WORD_GOALS[lvl];
        updateMeta();
      }
    })
    .catch(function(){});

  ta.addEventListener('input', updateMeta);
  updateMeta();
  checkBtn.addEventListener('click', function(){
    var text = ta.value.trim();
    if (text.length < 80){ alert('Слишком короткий текст'); return; }
    checkBtn.disabled = true;
    checkBtn.textContent = 'AI проверяет...';
    fetch('/api/writing/check', {
      method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin',
      body: JSON.stringify({ text: text, task: currentTask ? currentTask.text : 'free', level: currentTask ? currentTask.level : 'B1' })
    })
      .then(function(r){ return r.json(); })
      .then(function(d){
        checkBtn.disabled = false;
        checkBtn.textContent = 'Проверить с AI';
        if (!d || !d.ok){ alert((d && d.error) || 'Ошибка'); return; }
        renderResult(d.result);
      })
      .catch(function(e){ checkBtn.disabled = false; checkBtn.textContent = 'Проверить с AI'; alert(e.message); });
  });
  function renderResult(r){
    resultEl.hidden = false;
    var score = r.score || 0;
    var html = '<div class="wr-top"><div class="wr-overall"><div class="wr-lvl">' + (r.overall || '—') + '</div><div class="wr-sc">Overall level</div></div><div class="wr-score-big">' + score + '<span>/100</span></div></div>';
    if (r.criteria){
      var labels = { task:'Task Achievement', coherence:'Coherence & Cohesion', vocabulary:'Lexical Resource', grammar:'Grammatical Range' };
      html += '<div class="wr-criteria">';
      Object.keys(labels).forEach(function(k){
        var c = r.criteria[k]; if (!c) return;
        html += '<div class="wr-crit"><div class="wr-crit-head"><span>' + labels[k] + '</span><span class="wr-crit-score">' + (c.score || 0) + '</span></div><div class="wr-crit-bar"><div class="wr-crit-fill" style="width:' + (c.score || 0) + '%"></div></div><div class="wr-crit-comment">' + (c.comment || '') + '</div></div>';
      });
      html += '</div>';
    }
    if (r.strengths && r.strengths.length) html += '<div class="wr-section"><h4>Strengths</h4><ul>' + r.strengths.map(function(s){ return '<li>' + s + '</li>'; }).join('') + '</ul></div>';
    if (r.improvements && r.improvements.length) html += '<div class="wr-section"><h4>Improvements</h4><ul>' + r.improvements.map(function(s){ return '<li>' + s + '</li>'; }).join('') + '</ul></div>';
    if (r.corrected) html += '<div class="wr-section"><h4>Corrected version</h4><div class="wr-corrected">' + r.corrected + '</div></div>';
    resultEl.innerHTML = html;
    resultEl.scrollIntoView({ behavior:'smooth', block:'start' });
  }
})();