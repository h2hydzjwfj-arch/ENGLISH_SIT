(function(){
  if (window.__iomaInteractions) return;
  window.__iomaInteractions = true;

  // ---------- PAGE TRANSITIONS ----------
  function initPageTransitions(){
    document.addEventListener('click', function(e){
      var a = e.target.closest('a[href]');
      if (!a) return;
      var href = a.getAttribute('href');
      if (!href || href.charAt(0) !== '/' || href.charAt(0) === '#' || a.target === '_blank') return;
      if (e.ctrlKey || e.metaKey || e.shiftKey) return;
      e.preventDefault();
      document.documentElement.classList.add('page-leaving');
      setTimeout(function(){ location.href = href; }, 200);
    });
    requestAnimationFrame(function(){
      document.documentElement.classList.add('page-ready');
    });
    window.addEventListener('pageshow', function(e){
      if (e.persisted){
        document.documentElement.classList.remove('page-leaving');
        document.documentElement.classList.add('page-ready');
      }
    });
  }

  // ---------- ПЛАВНЫЙ СКРОЛЛ ПО ЯКОРЯМ ----------
  function initSmoothAnchors(){
    document.querySelectorAll('a[href^="#"]').forEach(function(a){
      a.addEventListener('click', function(e){
        var id = a.getAttribute('href').slice(1);
        if (!id) return;
        var el = document.getElementById(id);
        if (!el) return;
        e.preventDefault();
        el.scrollIntoView({ behavior:'smooth', block:'start' });
      });
    });
  }

  // ---------- BACK TO TOP ----------
  function initBackToTop(){
    var btn = document.createElement('button');
    btn.className = 'ioma-back-top';
    btn.setAttribute('aria-label', 'Наверх');
    btn.innerHTML = '<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 19V5M5 12l7-7 7 7"/></svg>';
    btn.addEventListener('click', function(){
      window.scrollTo({ top:0, behavior:'smooth' });
    });
    document.body.appendChild(btn);
    function check(){
      if (window.scrollY > 400) btn.classList.add('show');
      else btn.classList.remove('show');
    }
    window.addEventListener('scroll', check, { passive:true });
    check();
  }

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
    var box = ensureBox();
    var el = document.createElement('div');
    el.className = 'ioma-toast ioma-toast-' + (type || 'info');
    el.innerHTML = '<span class="ioma-toast-icon">' +
      (type === 'success' ? '✓' : type === 'error' ? '✕' : '·') +
      '</span><span>' + msg + '</span>';
    box.appendChild(el);
    requestAnimationFrame(function(){ el.classList.add('in'); });
    setTimeout(function(){
      el.classList.remove('in');
      setTimeout(function(){ el.remove(); }, 350);
    }, 3000);
  };

  // ---------- СКРОЛЛ-РЕВИЛ ----------
  var REVEAL_SEL = '.card,.feature-card,.method-item,.stat-card,.skill-card,.unit,.quick-card,.profile-hero,.lesson-rule,.lesson-exercises,.lst-card,.spk-prompt,.spk-feedback,.wrt-task,.wrt-result,.question-card,.result-card,.auth-card,.hero h1,.hero .lede,.hero-actions,.hero-stats,.level-hero,.cb-head';
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
    }, { threshold:0.08, rootMargin:'0px 0px -40px 0px' });
    els.forEach(function(el, i){
      if (el.classList.contains('ioma-reveal')) return;
      el.classList.add('ioma-reveal');
      el.style.transitionDelay = ((i % 5) * 50) + 'ms';
      io.observe(el);
    });
  }

  // ---------- TTS ----------
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
      btn.innerHTML = '<svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 5L6 9H2v6h4l5 4V5zM15.5 8.5a5 5 0 0 1 0 7M19 5a9 9 0 0 1 0 14"/></svg>';
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
    initPageTransitions();
    initSmoothAnchors();
    initBackToTop();
    initReveal();
    initTTSButtons();
    initSkeleton();
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();

  var mo = new MutationObserver(function(){ initTTSButtons(); });
  mo.observe(document.body, { childList:true, subtree:true });
})();

// ============================================
// ПЕЧАТНАЯ МАШИНКА — оживляем поля письма
// ============================================
(function(){
  var PLACEHOLDERS = {
    'writingInput': 'Начните печатать… Слова выходят сами, если не думать о правилах.',
    'wrtInput': 'Начните печатать… Не бойтесь ошибок — я проверю.',
    'lstAnswer': 'Что вы услышали? Напишите, как расслышали.',
    'assistInput': 'Спросите учителя…'
  };

  function typewriterPlaceholder(el, text){
    if (!el) return;
    if (el.dataset.twInit) return;
    el.dataset.twInit = '1';

    var idx = 0;
    var typing = false;
    var originalPlaceholder = el.getAttribute('placeholder') || text;

    function tick(){
      if (document.activeElement === el || el.value.length > 0) return;
      if (idx <= text.length){
        el.setAttribute('placeholder', text.slice(0, idx));
        idx++;
        setTimeout(tick, 40 + Math.random() * 50);
      } else {
        // Пауза, потом стереть и заново
        setTimeout(function(){
          if (document.activeElement === el) return;
          idx = 0;
          var erase = setInterval(function(){
            if (document.activeElement === el || el.value.length > 0){
              clearInterval(erase);
              el.setAttribute('placeholder', originalPlaceholder);
              return;
            }
            if (idx <= 0){
              clearInterval(erase);
              setTimeout(tick, 800);
              return;
            }
            idx--;
            el.setAttribute('placeholder', text.slice(0, idx));
          }, 20);
        }, 2400);
      }
    }

    // Не печатать на пустом placeholder — только когда пользователь ещё не начал
    el.addEventListener('focus', function(){
      el.setAttribute('placeholder', originalPlaceholder);
    });

    // Начинаем через 1.5 сек после загрузки
    setTimeout(tick, 1500 + Math.random() * 800);
  }

  // Курсор-▍ в углу textarea
  function addCursor(textarea){
    if (!textarea || textarea.dataset.twCursor) return;
    textarea.dataset.twCursor = '1';

    var wrap = textarea.parentNode;
    if (!wrap.classList.contains('ioma-typewriter-wrap')){
      var wrapper = document.createElement('div');
      wrapper.className = 'ioma-typewriter-wrap';
      wrap.insertBefore(wrapper, textarea);
      wrapper.appendChild(textarea);
      wrap = wrapper;
    }

    var cursor = document.createElement('span');
    cursor.className = 'ioma-typewriter-cursor';
    wrap.appendChild(cursor);

    textarea.addEventListener('focus', function(){ cursor.classList.add('on'); });
    textarea.addEventListener('blur', function(){ cursor.classList.remove('on'); });
    textarea.addEventListener('input', function(){
      cursor.classList.add('on');
      wrap.classList.add('typing');
      setTimeout(function(){ wrap.classList.remove('typing'); }, 60);
    });
  }


  function initTypewriters(){
    Object.keys(PLACEHOLDERS).forEach(function(id){
      var el = document.getElementById(id);
      if (!el) return;
      typewriterPlaceholder(el, PLACEHOLDERS[id]);
      addCursor(el);
    });
    // Все остальные textarea — только шрифт, без анимации
    document.querySelectorAll('textarea').forEach(function(ta){
      if (PLACEHOLDERS[ta.id]) return;
      ta.style.fontFamily = "'Courier New','American Typewriter',monospace";
    });
  }

  if (document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', initTypewriters);
  } else {
    initTypewriters();
  }

  // На случай, если textarea появится позже (SPA)
  var mo = new MutationObserver(function(){
    Object.keys(PLACEHOLDERS).forEach(function(id){
      var el = document.getElementById(id);
      if (el && !el.dataset.twInit){
        typewriterPlaceholder(el, PLACEHOLDERS[id]);
        addCursor(el);
      }
    });
  });
  mo.observe(document.body, { childList:true, subtree:true });
})();
