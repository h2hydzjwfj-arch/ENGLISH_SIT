(function(){
  if (window.__iomaAnim) return;
  window.__iomaAnim = true;

  // ---------- TOAST ----------
  var toastBox = null;
  function ensureBox(){
    if (toastBox && document.body.contains(toastBox)) return toastBox;
    toastBox = document.createElement('div');
    toastBox.className = 'ioma-toast-box';
    document.body.appendChild(toastBox);
    return toastBox;
  }
  window.toast = function(msg, type){
    type = type || 'info';
    var box = ensureBox();
    var el = document.createElement('div');
    el.className = 'ioma-toast ioma-toast-' + type;
    el.innerHTML = '<span class="ioma-toast-icon">' +
      (type === 'success' ? '✓' : type === 'error' ? '✕' : '❋') +
      '</span><span>' + msg + '</span>';
    box.appendChild(el);
    requestAnimationFrame(function(){ el.classList.add('in'); });
    setTimeout(function(){
      el.classList.remove('in');
      setTimeout(function(){ el.remove(); }, 400);
    }, 3400);
  };

  // ---------- СКРОЛЛ-РЕВИЛ ----------
  var REVEAL_SEL = '.card,.feature-card,.method-item,.stat-card,.skill-card,.unit,.quick-card,.profile-hero,.section,.lesson-rule,.lesson-exercises,.lst-card,.spk-prompt,.spk-feedback,.wrt-task,.wrt-result,.question-card,.result-card,.auth-card,.hero h1,.hero .lede,.hero-actions,.hero-stats,.level-hero,.cb-head';
  function initReveal(){
    var els = document.querySelectorAll(REVEAL_SEL);
    if (!('IntersectionObserver' in window)){
      els.forEach(function(e){ e.classList.add('ioma-in'); });
      return;
    }
    var io = new IntersectionObserver(function(entries){
      entries.forEach(function(en){
        if (en.isIntersecting){
          en.target.classList.add('ioma-in');
          io.unobserve(en.target);
        }
      });
    }, { threshold:0.08, rootMargin:'0px 0px -50px 0px' });
    els.forEach(function(el, i){
      if (el.classList.contains('ioma-reveal')) return;
      el.classList.add('ioma-reveal');
      el.style.transitionDelay = ((i % 5) * 70) + 'ms';
      io.observe(el);
    });
  }

  // ---------- TTS INLINE (только где нужно) ----------
  function shouldHaveTTS(){
    var p = location.pathname;
    return p === '/lesson' || p === '/listening' || p === '/test';
  }
  function initTTSButtons(){
    if (!shouldHaveTTS()) return;
    var targets = document.querySelectorAll('.ex-q, .q-sentence, .q-text, .lst-original .lo-text, .task-prompt');
    if (!targets.length) return;
    targets.forEach(function(el){
      if (el.dataset.ttsReady) return;
      el.dataset.ttsReady = '1';
      el.classList.add('ioma-tts-target');
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'ioma-tts-btn-inline';
      btn.setAttribute('aria-label', 'Озвучить');
      btn.innerHTML = '<svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 5L6 9H2v6h4l5 4V5zM15.5 8.5a5 5 0 0 1 0 7M19 5a9 9 0 0 1 0 14"/></svg>';
      btn.addEventListener('click', function(e){
        e.preventDefault();
        e.stopPropagation();
        speakEnglish(el.textContent.replace(/\s+/g,' ').trim(), btn);
      });
      el.appendChild(btn);
    });
  }
  function speakEnglish(text, btn){
    if (!text) return;
    var en = text.replace(/[^\x00-\x7F]/g, '').replace(/\s+/g,' ').trim().slice(0, 1000);
    if (!en || en.length < 3) en = text.slice(0, 1000);
    if (!en) return;
    if (btn && btn.classList.contains('playing')){ stopAll(); return; }
    stopAll();
    if (btn) btn.classList.add('playing');

    fetch('/api/tts', {
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ text: en, lang:'en', gender: localStorage.getItem('ioma_gender') || 'female' })
    })
    .then(function(r){ if (!r.ok) throw new Error(); return r.blob(); })
    .then(function(blob){
      var url = URL.createObjectURL(blob);
      var audio = new Audio(url);
      window.__iomaAudio = { audio: audio, url: url, btn: btn };
      audio.onended = function(){ if (btn) btn.classList.remove('playing'); URL.revokeObjectURL(url); window.__iomaAudio = null; };
      audio.onerror = function(){ if (btn) btn.classList.remove('playing'); };
      audio.play();
    })
    .catch(function(){
      if ('speechSynthesis' in window){
        var u = new SpeechSynthesisUtterance(en);
        u.lang = 'en-GB';
        u.onend = function(){ if (btn) btn.classList.remove('playing'); };
        speechSynthesis.cancel();
        speechSynthesis.speak(u);
      } else if (btn) btn.classList.remove('playing');
    });
  }
  function stopAll(){
    if (window.__iomaAudio){
      try { window.__iomaAudio.audio.pause(); } catch(e){}
      try { URL.revokeObjectURL(window.__iomaAudio.url); } catch(e){}
      if (window.__iomaAudio.btn) window.__iomaAudio.btn.classList.remove('playing');
      window.__iomaAudio = null;
    }
    if ('speechSynthesis' in window) speechSynthesis.cancel();
  }
  window.iomaSpeakEnglish = speakEnglish;
  window.iomaStopAll = stopAll;

  // ---------- АФФИРМАЦИИ (только dashboard) ----------
  var AFFIRM = [
    'Breathe. Learn. Become.',
    'Every word opens a new world.',
    'Slow progress is still progress.',
    'The mind learns what the heart enjoys.',
    'Fluency begins with a single breath.',
    'Today, you choose growth.'
  ];
  function initAffirmation(){
    if (location.pathname !== '/dashboard') return;
    var hero = document.querySelector('.level-hero');
    if (!hero || hero.dataset.affirm) return;
    hero.dataset.affirm = '1';
    var line = document.createElement('div');
    line.className = 'ioma-affirm';
    line.textContent = AFFIRM[Math.floor(Math.random() * AFFIRM.length)];
    hero.parentNode.insertBefore(line, hero);
  }

  // ---------- SKELETON ----------
  function initSkeleton(){
    document.querySelectorAll('.placeholder').forEach(function(el){
      if (el.dataset.skeleton) return;
      el.dataset.skeleton = '1';
      if (/Загрузка|Loading/.test(el.textContent) || !el.textContent.trim()){
        el.innerHTML = '<div class="ioma-skel-line"></div><div class="ioma-skel-line" style="width:70%"></div><div class="ioma-skel-line" style="width:50%"></div>';
      }
    });
  }

  function init(){
    initReveal();
    initTTSButtons();
    initAffirmation();
    initSkeleton();
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();

  var mo = new MutationObserver(function(){ initTTSButtons(); });
  mo.observe(document.body, { childList:true, subtree:true });
})();
