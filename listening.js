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
  var ITEMS = null, idx = 0, answer = '';
  fetch('/api/listening').then(function(r){ return r.json(); }).then(function(d){
    if (d && d.ok && d.items){ ITEMS = d.items; render(); }
  });
  var textarea = document.getElementById('lstAnswer');
  function render(){
    if (!ITEMS) return;
    var it = ITEMS[idx];
    document.getElementById('lstLevel').textContent = it.level;
    document.getElementById('lstCounter').textContent = (idx + 1) + ' / ' + ITEMS.length;
    document.getElementById('lstTitle').textContent = it.title;
    textarea.value = '';
    answer = '';
    document.getElementById('lstResult').hidden = true;
    document.getElementById('lstOriginal').hidden = true;
    document.getElementById('prevLst').disabled = idx === 0;
    document.getElementById('nextLst').disabled = idx === ITEMS.length - 1;
  }
  function speak(rate){
    if (!ITEMS) return;
    if (!('speechSynthesis' in window)){ alert('Синтез речи не поддерживается'); return; }
    var it = ITEMS[idx];
    var utt = new SpeechSynthesisUtterance(it.text);
    utt.lang = (it.accent === 'American') ? 'en-US' : 'en-GB';
    utt.rate = rate;
    var voices = speechSynthesis.getVoices();
    var target = voices.find(function(v){ return v.lang === utt.lang; }) || voices.find(function(v){ return v.lang && v.lang.indexOf('en') === 0; });
    if (target) utt.voice = target;
    speechSynthesis.cancel();
    speechSynthesis.speak(utt);
  }
  document.getElementById('playBtn').addEventListener('click', function(){ speak(0.95); });
  document.getElementById('slowBtn').addEventListener('click', function(){ speak(0.65); });
  document.getElementById('revealBtn').addEventListener('click', function(){
    if (!ITEMS) return;
    document.getElementById('loText').textContent = ITEMS[idx].text;
    document.getElementById('lstOriginal').hidden = false;
  });
  document.getElementById('checkLstBtn').addEventListener('click', function(){
    if (!ITEMS) return;
    answer = textarea.value.trim();
    if (answer.length < 10){ alert('Напишите хотя бы несколько слов'); return; }
    var orig = ITEMS[idx].text.toLowerCase().replace(/[^a-z0-9\s]/g, '').split(/\s+/).filter(Boolean);
    var user = answer.toLowerCase().replace(/[^a-z0-9\s]/g, '').split(/\s+/).filter(Boolean);
    var matched = user.filter(function(w){ return orig.indexOf(w) !== -1; }).length;
    var accuracy = Math.round((matched / Math.max(orig.length, 1)) * 100);
    var uniq = {}; user.forEach(function(w){ uniq[w] = 1; });
    var covers = Math.round((Object.keys(uniq).length / orig.length) * 100);
    var pct = Math.min(100, Math.round((accuracy + covers) / 2));
    var cls = pct >= 60 ? 'success' : 'warn';
    var msg = pct >= 80 ? 'Отличный результат! Вы услышали почти всё.' : pct >= 60 ? 'Хорошо! Некоторые слова пропущены.' : 'Потренируйтесь ещё — прослушайте медленно и снова.';
    var el = document.getElementById('lstResult');
    el.className = 'lst-result ' + cls;
    el.innerHTML = '<b>Accuracy: ' + pct + '%</b><br>' + msg;
    el.hidden = false;
    document.getElementById('loText').textContent = ITEMS[idx].text;
    document.getElementById('lstOriginal').hidden = false;
  });
  document.getElementById('prevLst').addEventListener('click', function(){ if (idx > 0){ idx--; render(); } });
  document.getElementById('nextLst').addEventListener('click', function(){ if (ITEMS && idx < ITEMS.length - 1){ idx++; render(); } });
  if ('speechSynthesis' in window){ speechSynthesis.getVoices(); speechSynthesis.onvoiceschanged = function(){ speechSynthesis.getVoices(); }; }
})();