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
  var params = new URLSearchParams(location.search);
  var unitId = params.get('id');
  var level = params.get('level') || 'A1';
  var state = { answers:[], submitted:false, unit:null };
  function esc(s){ return String(s == null ? '' : s).replace(/[&<>"']/g, function(c){ return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]; }); }
  if (!unitId){ document.getElementById('lessonTitle').textContent = 'Lesson not found'; return; }
  fetch('/api/curriculum?level=' + level, { credentials:'same-origin' })
    .then(function(r){ return r.json(); })
    .then(function(d){
      if (!d || !d.ok){ document.getElementById('lessonTitle').textContent = 'Error'; return; }
      var unit = d.units.find(function(u){ return u.id === unitId; });
      if (!unit){ document.getElementById('lessonTitle').textContent = 'Not found'; return; }
      state.unit = unit;
      state.answers = unit.exercises.map(function(){ return null; });
      render(d.book, unit);
    }).catch(function(e){ console.warn(e); });
  function render(book, unit){
    document.getElementById('lessonEyebrow').textContent = 'Lesson · ' + unit.id.toUpperCase();
    document.getElementById('lessonTitle').textContent = unit.title;
    document.getElementById('lessonBook').textContent = book;
    document.getElementById('lessonGrammar').textContent = unit.grammar;
    renderExercises();
    updateProgress();
  }
  function renderExercises(){
    var host = document.getElementById('exerciseHost');
    var letters = ['A','B','C','D'];
    host.innerHTML = state.unit.exercises.map(function(ex, i){
      var selected = state.answers[i];
      return '<div class="exercise" data-i="' + i + '"><div class="ex-q">' + (i + 1) + '. ' + esc(ex.q) + '</div><div class="ex-options">'
        + ex.options.map(function(o, j){
          var cls = 'ex-opt';
          if (state.submitted){
            if (j === ex.correct) cls += ' correct';
            else if (j === selected) cls += ' wrong';
          } else if (selected === j) cls += ' selected';
          return '<button type="button" class="' + cls + '" data-q="' + i + '" data-o="' + j + '"' + (state.submitted ? ' disabled' : '') + '><span class="ex-letter">' + letters[j] + '</span><span>' + esc(o) + '</span></button>';
        }).join('')
        + '</div><div class="ex-comment" data-i="' + i + '"></div></div>';
    }).join('');
    host.querySelectorAll('.ex-opt').forEach(function(b){
      b.addEventListener('click', function(){
        if (state.submitted) return;
        state.answers[Number(b.dataset.q)] = Number(b.dataset.o);
        renderExercises();
        updateProgress();
      });
    });
    if (state.submitted){
      state.unit.exercises.forEach(function(ex, i){
        var box = document.querySelector('.ex-comment[data-i="' + i + '"]');
        if (box){
          var isRight = state.answers[i] === ex.correct;
          box.textContent = isRight ? '✓ Correct' : ('✗ Correct answer: ' + ex.options[ex.correct]);
          box.classList.add('show');
        }
      });
    }
  }
  function updateProgress(){
    var done = state.answers.filter(function(a){ return a != null; }).length;
    var total = state.unit ? state.unit.exercises.length : 0;
    var pct = total ? Math.round((done / total) * 100) : 0;
    document.getElementById('plFill').style.width = pct + '%';
    document.getElementById('plText').textContent = done + ' / ' + total;
    document.getElementById('nextBtn').disabled = done < total;
    document.getElementById('nextBtn').textContent = state.submitted ? 'Complete' : 'Проверить';
  }
  document.getElementById('nextBtn').addEventListener('click', function(){
    if (!state.submitted){
      state.submitted = true;
      var correct = state.unit.exercises.filter(function(ex, i){ return state.answers[i] === ex.correct; }).length;
      renderExercises();
      fetch('/api/lesson/complete', {
        method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin',
        body: JSON.stringify({ unitId: state.unit.id, correct: correct, total: state.unit.exercises.length })
      }).catch(function(){});
      updateProgress();
      var pct = Math.round((correct / state.unit.exercises.length) * 100);
      document.getElementById('lrScore').textContent = correct + ' из ' + state.unit.exercises.length + ' (' + pct + '%)';
      setTimeout(function(){ document.getElementById('lessonResult').hidden = false; }, 900);
    } else location.href = '/dashboard';
  });
  document.getElementById('backBtn').addEventListener('click', function(){ history.back(); });
  document.getElementById('againBtn').addEventListener('click', function(){ location.reload(); });
})();