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

  fetch('/api/me', { credentials: 'same-origin' })
    .then(function(r){ return r.json(); })
    .then(function(d){
      if (!d || !d.ok || !d.profile) return;
      var p = d.profile;
      if (p.level){
        var badge = document.getElementById('levelBadge');
        if (badge) badge.hidden = false;
        var codeEl = document.getElementById('levelCode'); if (codeEl) codeEl.textContent = p.level;
        var names = { A1:'Beginner', A2:'Elementary', B1:'Intermediate', B2:'Upper-Intermediate', C1:'Advanced', C2:'Proficiency' };
        var lblEl = document.getElementById('levelLabel'); if (lblEl) lblEl.textContent = names[p.level] || '';
        var pctEl = document.getElementById('levelPercent'); if (pctEl) pctEl.textContent = (p.progressToNext || 0) + '%';
        setTimeout(function(){ var f = document.getElementById('levelFill'); if (f) f.style.width = (p.progressToNext || 0) + '%'; }, 200);
        var btnTest = document.getElementById('takeTestBtn');
        if (btnTest){ btnTest.textContent = 'Продолжить'; btnTest.href = '/dashboard'; }
      }
    }).catch(function(){});

  // AI-репетитор
  var overlay = document.getElementById('assistOverlay');
  if (!overlay) return;
  var body = document.getElementById('assistBody');
  var input = document.getElementById('assistInput');
  var sendBtn = document.getElementById('assistSend');
  var history = [];

  function emptyState(){
    body.innerHTML = ''
      + '<div class="assist-empty">'
      + '<h3>Your private tutor</h3>'
      + '<p>Задайте любой вопрос по английскому — грамматика, лексика, нюансы, перевод.</p>'
      + '<div class="sugg">'
      + '<button data-q="Разница между Past Simple и Present Perfect">Past Simple vs Present Perfect</button>'
      + '<button data-q="Объясни артикли a, an, the с примерами">Артикли</button>'
      + '<button data-q="Что такое phrasal verbs и как их учить?">Phrasal verbs</button>'
      + '<button data-q="Пассивный залог — правила и примеры">Passive Voice</button>'
      + '</div></div>';
    body.querySelectorAll('.sugg button').forEach(function(b){
      b.addEventListener('click', function(){ input.value = b.getAttribute('data-q'); send(); });
    });
  }
  function addMsg(text, kind){
    var empty = body.querySelector('.assist-empty'); if (empty) empty.remove();
    var div = document.createElement('div');
    div.className = 'assist-msg ' + kind;
    div.innerHTML = '<div class="bubble"></div>';
    div.querySelector('.bubble').textContent = text;
    body.appendChild(div); body.scrollTop = body.scrollHeight;
  }
  function addTyping(){
    var empty = body.querySelector('.assist-empty'); if (empty) empty.remove();
    var div = document.createElement('div');
    div.className = 'assist-msg ai';
    div.innerHTML = '<div class="bubble"><div class="dots"><span></span><span></span><span></span></div></div>';
    body.appendChild(div); body.scrollTop = body.scrollHeight; return div;
  }
  function send(){
    var text = String(input.value || '').trim();
    if (!text) return;
    addMsg(text, 'user'); history.push({ role:'user', content:text });
    input.value = ''; sendBtn.disabled = true;
    var typing = addTyping();
    fetch('/api/assist', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body: JSON.stringify({ question:text, history:history.slice(-6) }) })
      .then(function(r){ return r.json(); })
      .then(function(d){
        typing.remove(); sendBtn.disabled = false;
        if (d && d.ok && d.reply){ addMsg(d.reply, 'ai'); history.push({ role:'assistant', content:d.reply }); }
        else { addMsg((d && d.error) || 'Не удалось получить ответ', 'error'); }
      })
      .catch(function(e){ typing.remove(); sendBtn.disabled = false; addMsg('Ошибка соединения', 'error'); });
  }
  function openAssist(){ overlay.hidden = false; if (!body.children.length) emptyState(); setTimeout(function(){ input.focus(); }, 80); }
  function closeAssist(){ overlay.hidden = true; }
  var fab = document.getElementById('assistFab'); if (fab) fab.addEventListener('click', openAssist);
  var cb = document.getElementById('assistClose'); if (cb) cb.addEventListener('click', closeAssist);
  overlay.addEventListener('click', function(e){ if (e.target === overlay) closeAssist(); });
  if (sendBtn) sendBtn.addEventListener('click', send);
  if (input){
    input.addEventListener('keydown', function(e){ if (e.key === 'Enter' && !e.shiftKey){ e.preventDefault(); send(); } });
    input.addEventListener('input', function(){ input.style.height = 'auto'; input.style.height = Math.min(input.scrollHeight, 130) + 'px'; });
  }
  document.addEventListener('keydown', function(e){ if (e.key === 'Escape') closeAssist(); });
})();