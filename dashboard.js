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
  var NAMES = { A1:'Beginner', A2:'Elementary', B1:'Intermediate', B2:'Upper-Intermediate', C1:'Advanced', C2:'Proficiency' };
  fetch('/api/me', { credentials:'same-origin' })
    .then(function(r){ return r.json(); })
    .then(function(d){
      if (!d || !d.ok) return;
      var p = d.profile;
      document.getElementById('streakNum').textContent = p.streak || 0;
      if (p.level){
        document.getElementById('lhLevel').textContent = p.level;
        document.getElementById('lhName').textContent = NAMES[p.level] || '';
        document.getElementById('lhpPercent').textContent = (p.progressToNext || 0) + '%';
        setTimeout(function(){ document.getElementById('lhpFill').style.width = (p.progressToNext || 0) + '%'; }, 200);
        document.getElementById('lhpHint').textContent = 'Продолжайте заниматься — и уровень вырастет.';
        document.getElementById('lhTestBtn').textContent = 'Пройти тест заново';
      }
      document.getElementById('statLessons').textContent = p.lessonsDone || 0;
      document.getElementById('statWords').textContent = (p.vocabulary || []).length;
      document.getElementById('statStreak').textContent = p.streak || 0;
      document.getElementById('statScore').textContent = (p.testPercent || 0) + '%';
      var skills = document.getElementById('skillsGrid');
      if (p.testScores){
        var labels = { grammar:'Grammar', reading:'Reading', listening:'Listening', writing:'Writing', speaking:'Speaking' };
        skills.innerHTML = Object.keys(labels).map(function(k){
          var v = p.testScores[k] || 0;
          return '<div class="skill"><div class="skill-label">' + labels[k] + '</div><div class="skill-level">' + scoreToLevel(v) + '</div><div class="skill-bar"><div class="skill-fill" style="width:' + v + '%"></div></div></div>';
        }).join('');
      } else skills.innerHTML = '<div class="placeholder">Пройдите тест, чтобы увидеть профиль навыков</div>';
      loadCurriculum(p.level || 'A1', p.unitProgress || {});
    }).catch(function(e){ console.warn(e); });
  function scoreToLevel(p){
    if (p < 25) return 'A1'; if (p < 45) return 'A2'; if (p < 65) return 'B1';
    if (p < 80) return 'B2'; if (p < 92) return 'C1'; return 'C2';
  }
  function loadCurriculum(level, progress){
    fetch('/api/curriculum?level=' + level, { credentials:'same-origin' })
      .then(function(r){ return r.json(); })
      .then(function(d){
        if (!d || !d.ok) return;
        document.getElementById('cbBook').textContent = d.book || '';
        document.getElementById('unitsGrid').innerHTML = d.units.map(function(u, i){
          var done = progress[u.id];
          var status = done ? (done.best >= 80 ? '✓' : '◐') : '○';
          var progText = done ? ('Best: ' + done.best + '%') : 'Not started';
          return '<a class="unit" href="/lesson?id=' + u.id + '&level=' + level + '"><div class="unit-top"><span class="unit-id">Unit ' + (i + 1) + '</span><span class="unit-status">' + status + '</span></div><div class="unit-title">' + u.title + '</div><div class="unit-progress">' + progText + '</div></a>';
        }).join('');
      }).catch(function(e){ console.warn(e); });
  }
})();
// ============================================
// Плавный скролл к якорю #curriculum
// ============================================
(function(){
  function scrollToHash(){
    if (!location.hash) return;
    var id = location.hash.slice(1);
    var el = document.getElementById(id);
    if (!el) {
      console.warn('[anchor]', 'Не найден элемент #' + id);
      return;
    }
    setTimeout(function(){
      el.scrollIntoView({ behavior:'smooth', block:'start' });
    }, 400);
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', scrollToHash);
  } else {
    scrollToHash();
  }
  window.addEventListener('hashchange', scrollToHash);
})();

// ============================================
// Грамматика → сразу в нужный урок
// ============================================
(function(){
  function gotoLesson(e){
    var link = e.target.closest('[data-goto-lesson]');
    if (!link) return;
    e.preventDefault();

    // Пытаемся получить уровень и прогресс
    fetch('/api/me', { credentials:'same-origin' })
      .then(function(r){ return r.json(); })
      .then(function(d){
        if (!d || !d.ok){ location.href = '/lesson?id=a1-01&level=A1'; return; }
        var p = d.profile || {};
        var level = p.level || 'A1';
        var prog = p.unitProgress || {};

        fetch('/api/curriculum?level=' + level, { credentials:'same-origin' })
          .then(function(r){ return r.json(); })
          .then(function(cd){
            if (!cd || !cd.ok || !cd.units || !cd.units.length){
              location.href = '/lesson?id=a1-01&level=A1';
              return;
            }
            // Логика: первый незавершённый, иначе следующий после последнего, иначе первый
            var target = null;
            // 1. Незавершённые (best < 80) — берём первый
            for (var i = 0; i < cd.units.length; i++){
              var u = cd.units[i];
              var done = prog[u.id];
              if (!done || (done.best || 0) < 80){
                target = u;
                break;
              }
            }
            // 2. Всё пройдено — берём следующий уровень или первый юнит текущего
            if (!target) target = cd.units[0];
            location.href = '/lesson?id=' + target.id + '&level=' + level;
          })
          .catch(function(){ location.href = '/lesson?id=a1-01&level=A1'; });
      })
      .catch(function(){ location.href = '/lesson?id=a1-01&level=A1'; });
  }

  document.addEventListener('click', gotoLesson, true);
})();
