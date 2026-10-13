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
  var currentCard = null;
  function esc(s){ return String(s == null ? '' : s).replace(/[&<>"']/g, function(c){ return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]; }); }
  function load(){
    fetch('/api/vocabulary', { credentials:'same-origin' })
      .then(function(r){ return r.json(); })
      .then(function(d){
        if (!d || !d.ok) return;
        document.getElementById('vsTotal').textContent = d.all.length;
        document.getElementById('vsDue').textContent = d.dueCount;
        renderList(d.all);
        if (d.dueCount > 0){
          var due = d.all.filter(function(c){ return !c.due || c.due <= Date.now(); });
          currentCard = due[0];
          renderReview();
        } else {
          document.getElementById('reviewHost').innerHTML = '<div class="placeholder">✓ Все слова повторены. Добавьте новые или повторите позже.</div>';
        }
      });
  }
  function renderList(words){
    var host = document.getElementById('listHost');
    if (!words.length){ host.innerHTML = '<div class="placeholder">Словарь пуст</div>'; return; }
    host.innerHTML = words.map(function(w){
      var isDue = !w.due || w.due <= Date.now();
      var dueText = isDue ? 'Due now' : ('Next: ' + new Date(w.due).toLocaleDateString('ru-RU'));
      return '<div class="voc-item"><div><span class="vi-word">' + esc(w.word) + '</span><span class="vi-trans">' + esc(w.translation || '') + '</span></div><div class="vi-due' + (isDue ? ' ready' : '') + '">' + dueText + '</div></div>';
    }).join('');
  }
  function renderReview(){
    var host = document.getElementById('reviewHost');
    if (!currentCard){ host.innerHTML = '<div class="placeholder">Нет слов к повторению</div>'; return; }
    host.innerHTML = '<div class="card-review"><div class="cr-word">' + esc(currentCard.word) + '</div><div class="cr-trans hidden-trans" id="crTrans">' + esc(currentCard.translation || '(нет перевода)') + '</div><button class="cr-show" id="showTrans">Показать перевод</button><div class="cr-actions" id="crActions" style="display:none"><button class="cr-btn bad" data-q="1">Не помню</button><button class="cr-btn hard" data-q="3">Смутно</button><button class="cr-btn good" data-q="5">Помню</button></div></div>';
    document.getElementById('showTrans').addEventListener('click', function(){
      document.getElementById('crTrans').classList.remove('hidden-trans');
      this.style.display = 'none';
      document.getElementById('crActions').style.display = 'flex';
    });
    host.querySelectorAll('.cr-btn').forEach(function(b){
      b.addEventListener('click', function(){
        fetch('/api/vocabulary/review', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body: JSON.stringify({ word: currentCard.word, quality: Number(b.dataset.q) }) })
          .then(function(){ currentCard = null; load(); });
      });
    });
  }
  document.getElementById('addWordBtn').addEventListener('click', function(){
    var w = document.getElementById('wordInput').value.trim();
    var t = document.getElementById('transInput').value.trim();
    if (!w) return;
    fetch('/api/vocabulary/add', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body: JSON.stringify({ word: w, translation: t }) })
      .then(function(){ document.getElementById('wordInput').value = ''; document.getElementById('transInput').value = ''; load(); });
  });
  load();
})();