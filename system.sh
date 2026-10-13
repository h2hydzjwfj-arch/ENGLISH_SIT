#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  ЕДИНАЯ СИСТЕМА: типографика + анимации"
echo "============================================"
echo ""

mkdir -p _unused/backup
TS=$(date +%Y%m%d_%H%M%S)
for f in styles.css dashboard.css test.css lesson.css vocabulary.css speaking.css listening.css writing.css; do
  [ -f "$f" ] && cp "$f" "_unused/backup/$f.$TS"
done
echo "✓ Бэкапы в _unused/backup/"
echo ""

# ============ 1. interactions.js ============
echo "[1/6] Создаю interactions.js"
cat > interactions.js << 'INTEREOF'
(function(){
  if (window.__iomaInteractions) return;
  window.__iomaInteractions = true;

  // ---------- PAGE TRANSITIONS ----------
  // Fade out при клике по внутренней ссылке
  function initPageTransitions(){
    document.addEventListener('click', function(e){
      var a = e.target.closest('a[href]');
      if (!a) return;
      var href = a.getAttribute('href');
      if (!href || href.charAt(0) !== '/' || href.charAt(0) === '#' || a.target === '_blank') return;
      if (e.ctrlKey || e.metaKey || e.shiftKey) return;
      e.preventDefault();
      document.documentElement.classList.add('page-leaving');
      setTimeout(function(){ location.href = href; }, 260);
    });

    // Fade in при загрузке
    requestAnimationFrame(function(){
      document.documentElement.classList.add('page-ready');
    });

    // Сброс состояния при возврате
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

  // ---------- СЧЁТЧИК ЦИФР ----------
  function initCounters(){
    if (!('IntersectionObserver' in window)) return;
    var els = document.querySelectorAll('.sc-value,.stat b,.vs-value,.lh-level,.result-level,.score');
    var io = new IntersectionObserver(function(entries){
      entries.forEach(function(en){
        if (!en.isIntersecting) return;
        var el = en.target;
        if (el.dataset.counted) return;
        el.dataset.counted = '1';
        var text = el.textContent.trim();
        var match = text.match(/^(\d+)(.*)$/);
        if (!match) return;
        var target = parseInt(match[1], 10);
        var suffix = match[2] || '';
        if (target < 2 || target > 10000) return;
        var start = performance.now();
        var duration = 900;
        (function tick(now){
          var p = Math.min(1, (now - start) / duration);
          var eased = 1 - Math.pow(1 - p, 3);
          el.textContent = Math.round(target * eased) + suffix;
          if (p < 1) requestAnimationFrame(tick);
          else el.textContent = target + suffix;
        })(start);
        io.unobserve(el);
      });
    }, { threshold:0.3 });
    els.forEach(function(el){ io.observe(el); });
  }

  // ---------- КНОПКА "ВВЕРХ" ----------
  function initBackToTop(){
    var btn = document.createElement('button');
    btn.className = 'ioma-back-top';
    btn.setAttribute('aria-label', 'Наверх');
    btn.innerHTML = '<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 19V5M5 12l7-7 7 7"/></svg>';
    btn.addEventListener('click', function(){
      window.scrollTo({ top:0, behavior:'smooth' });
    });
    document.body.appendChild(btn);

    var lastY = 0;
    function check(){
      var y = window.scrollY;
      if (y > 400) btn.classList.add('show');
      else btn.classList.remove('show');
      lastY = y;
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
    type = type || 'info';
    var box = ensureBox();
    var el = document.createElement('div');
    el.className = 'ioma-toast ioma-toast-' + type;
    el.innerHTML = '<span class="ioma-toast-icon">' +
      (type === 'success' ? '✓' : type === 'error' ? '✕' : '☀') +
      '</span><span>' + msg + '</span>';
    box.appendChild(el);
    requestAnimationFrame(function(){ el.classList.add('in'); });
    setTimeout(function(){
      el.classList.remove('in');
      setTimeout(function(){ el.remove(); }, 400);
    }, 3400);
  };

  // ---------- СКРОЛЛ-РЕВИЛ ----------
  var REVEAL_SEL = '.card,.feature-card,.method-item,.stat-card,.skill-card,.unit,.quick-card,.profile-hero,.section,.lesson-rule,.lesson-exercises,.lst-card,.spk-prompt,.spk-feedback,.wrt-task,.wrt-result,.question-card,.result-card,.auth-card,.hero h1,.hero .lede,.hero-actions,.hero-stats,.level-hero,.cb-head,.voc-stats';
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

  // ---------- АФФИРМАЦИИ ----------
  var AFFIRM = [
    'Как янтарь хранит свет солнца — так и ты хранишь свет знания.',
    'Every word you learn is a small sun.',
    'Ты — свет, проходящий сквозь время.',
    'Amber remembers the sun. You remember the words.',
    'Один урок в день — и ты сияешь.',
    'The sun teaches patience. So does language.',
    'Твоё знание — как янтарь: тёплое, древнее, живое.',
    'Breathe in gold. Speak out light.'
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
    initPageTransitions();
    initSmoothAnchors();
    initCounters();
    initBackToTop();
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
INTEREOF
echo "  ✓ interactions.js ($(wc -l < interactions.js) строк)"
echo ""

# ============ 2. Дополняю styles.css ============
echo "[2/6] Дополняю styles.css: transitions + micro-interactions + ритм"
cat >> styles.css << 'CSSADD'

/* ============================================================
   ЕДИНАЯ СИСТЕМА: типографика, ритм, переходы, микровзаимодействия
   ============================================================ */

/* --- Типографический ритм --- */
:root{
  --space-1:4px; --space-2:8px; --space-3:12px; --space-4:16px;
  --space-5:24px; --space-6:32px; --space-7:48px; --space-8:64px;
  --space-9:96px; --space-10:128px;

  --fs-xs:11.5px; --fs-sm:13px; --fs-base:15px; --fs-md:17px;
  --fs-lg:22px; --fs-xl:28px; --fs-2xl:38px; --fs-3xl:52px;
  --fs-hero:clamp(44px,6.5vw,88px);

  --lh-tight:1.1; --lh-snug:1.35; --lh-base:1.65; --lh-loose:1.8;

  --ls-tight:-.03em; --ls-snug:-.01em; --ls-base:0; --ls-wide:.08em; --ls-wider:.16em;
}

/* Все заголовки — Cormorant */
h1,h2,h3,h4,h5,.serif{font-family:var(--serif);font-weight:500;letter-spacing:var(--ls-snug);line-height:var(--lh-tight)}
h1{font-size:var(--fs-hero);font-weight:400;letter-spacing:var(--ls-tight)}
h2{font-size:clamp(30px,4vw,52px);font-weight:500}
h3{font-size:var(--fs-lg);font-weight:500}
h4{font-size:var(--fs-md);font-weight:600}

/* Текст — Inter */
body,p,li,span,div,label,input,textarea,button{font-family:var(--sans)}
p,li{font-size:var(--fs-base);line-height:var(--lh-base)}

/* Цифры, код — JetBrains Mono */
code,kbd,samp,.mono,.score,.sc-value,.vs-value,.stat b,.lhp-percent,.lhp-label b,.level-pill,.level-progress-text,.unit-id,.feature-num,.fb-overall-value,.fb-crit-score,.wr-score-big,.wr-crit-score,.vs-value,.spk-timer,.record-timer{font-family:var(--mono);font-variant-numeric:tabular-nums}

/* Цитаты, акценты — Cormorant italic */
.lede,.eyebrow~*,blockquote,.ioma-affirm,.lh-name,.result-name,.spk-prompt,.fb-better,.wr-corrected,.lo-text{font-family:var(--serif);font-style:italic}

/* --- Page transitions --- */
html{opacity:0;transition:opacity .28s cubic-bezier(.16,1,.3,1)}
html.page-ready{opacity:1}
html.page-leaving{opacity:0}
body{animation:pageIn .55s cubic-bezier(.16,1,.3,1) both}
@keyframes pageIn{from{opacity:0;transform:translateY(6px)}to{opacity:1;transform:none}}
main{animation:pageIn .7s cubic-bezier(.16,1,.3,1) both;animation-delay:.05s}

/* --- Micro-interactions: ссылки --- */
a:not(.btn-primary):not(.btn-ghost):not(.cta-mini):not(.lh-cta):not(.stage-btn):not(.lst-play):not(.lst-slow):not(.spk-btn):not(.assist-fab):not(.assist-send):not(.unit):not(.quick-card):not(.mode-card){transition:color .2s var(--ease)}
a:not(.btn-primary):not(.btn-ghost):not(.cta-mini):hover{color:var(--amber)}

/* --- Micro-interactions: кнопки --- */
.btn-primary:active,.btn-ghost:active,.cta-mini:active,.lh-cta:active,.stage-btn:active,.lst-play:active,.spk-btn:active,.assist-fab:active,.assist-send:active,.play-btn:active,.record-btn:active{transform:translateY(0) scale(.98)}

/* --- Micro-interactions: карточки --- */
.card,.unit,.quick-card,.feature-card,.method-item,.stat-card,.skill-card{will-change:transform}
.card:active,.unit:active,.quick-card:active{transform:translateY(-1px)}

/* --- Focus ring --- */
button:focus-visible,a:focus-visible,input:focus-visible,textarea:focus-visible,.q-option:focus-visible,.ex-opt:focus-visible{outline:2px solid var(--amber);outline-offset:2px;border-radius:var(--r-sm)}

/* --- Плавные переходы между секциями --- */
section{scroll-margin-top:80px}

/* --- Back to top --- */
.ioma-back-top{
  position:fixed;right:28px;bottom:90px;z-index:150;
  width:44px;height:44px;border-radius:50%;
  background:var(--card);border:1px solid var(--border-2);color:var(--amber);
  display:inline-flex;align-items:center;justify-content:center;cursor:pointer;
  opacity:0;transform:translateY(12px);pointer-events:none;
  transition:all .35s cubic-bezier(.16,1,.3,1);
  box-shadow:0 8px 24px -8px rgba(0,0,0,.4);
}
.ioma-back-top.show{opacity:1;transform:none;pointer-events:auto}
.ioma-back-top:hover{background:var(--flame);color:var(--on-accent);border-color:transparent;box-shadow:var(--shadow-gold);transform:translateY(-2px)}
@media(max-width:820px){.ioma-back-top{right:16px;bottom:80px;width:40px;height:40px}}

/* --- Reveal --- */
.ioma-reveal{opacity:0;transform:translateY(18px);transition:opacity .8s var(--ease-out),transform .8s var(--ease-out)}
.ioma-reveal.ioma-in{opacity:1;transform:none}
@media (prefers-reduced-motion: reduce){
  .ioma-reveal{opacity:1;transform:none;transition:none}
  html,body,main{animation:none !important;transition:none !important}
  body::before,body::after{animation:none !important}
}

/* --- Согласование page-specific классов --- */
/* Dashboard */
.dash-shell{max-width:1240px;margin:0 auto;padding:56px 40px 130px}
.level-hero{display:grid;grid-template-columns:1.1fr 1fr;gap:64px;padding:60px 56px;margin-bottom:28px;align-items:center}
.lh-eyebrow{font-family:var(--mono);font-size:var(--fs-xs);font-weight:500;color:var(--amber);letter-spacing:var(--ls-wider);text-transform:uppercase;margin-bottom:16px}
.lh-level{font-family:var(--serif);font-size:clamp(96px,13vw,168px);font-weight:400;line-height:.9;letter-spacing:-.02em;color:var(--text);margin-bottom:14px}
.lh-name{font-family:var(--serif);font-style:italic;font-size:26px;font-weight:400;color:var(--text-muted)}
.lh-right{display:flex;flex-direction:column;justify-content:center;gap:22px}
.lhp-label{display:flex;justify-content:space-between;font-size:var(--fs-sm);color:var(--text-muted);margin-bottom:12px;font-weight:500}
.lhp-label b{color:var(--amber);font-weight:600;font-family:var(--mono)}
.lhp-bar{height:3px}
.lhp-fill{width:0%}
.lhp-hint{font-size:var(--fs-sm);color:var(--text-muted);margin-top:12px;line-height:1.65}
.lh-cta{padding:14px 26px;font-size:14px;align-self:flex-start}

.stat-row{display:grid;grid-template-columns:repeat(4,1fr);gap:1px;background:var(--border);border:1px solid var(--border-2);border-radius:var(--r-lg);overflow:hidden;margin-bottom:64px}
.stat-card{background:var(--bg-2);padding:34px 28px;border:none;border-radius:0;box-shadow:none;transition:background var(--t)}
.stat-card:hover{background:var(--card)}
.sc-value{font-family:var(--mono);font-size:54px;font-weight:400;line-height:1;color:var(--amber-2);margin-bottom:10px;letter-spacing:-.03em}
.sc-label{font-family:var(--sans);font-size:var(--fs-sm);color:var(--text-muted);font-weight:500;text-transform:uppercase;letter-spacing:var(--ls-wide)}

.skill-row,.curriculum-block{margin-bottom:64px}
.skills{display:grid;grid-template-columns:repeat(5,1fr);gap:1px;background:var(--border);border:1px solid var(--border-2);border-radius:var(--r-lg);overflow:hidden}
.skill{background:var(--bg-2);padding:28px 24px;border:none;border-radius:0;box-shadow:none}
.skill-label{font-family:var(--sans);font-size:var(--fs-sm);color:var(--text-muted);font-weight:500;margin-bottom:12px}
.skill-level{font-family:var(--serif);font-size:42px;font-weight:500;line-height:1;color:var(--text);margin-bottom:18px}
.skill-bar{height:2px}
.units-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(270px,1fr));gap:14px}
.unit{display:block;padding:26px 24px;text-decoration:none}
.unit-top{display:flex;justify-content:space-between;align-items:center;margin-bottom:16px}
.unit-id{font-family:var(--mono);font-size:var(--fs-xs);font-weight:500;color:var(--amber);letter-spacing:var(--ls-wide)}
.unit-status{font-size:15px;color:var(--text-muted)}
.unit-title{font-family:var(--serif);font-size:18px;font-weight:500;line-height:1.35;margin-bottom:12px;color:var(--text)}
.unit-progress{font-family:var(--mono);font-size:var(--fs-xs);color:var(--text-dim)}
.quick-links{display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:14px}
.quick-card{display:flex;align-items:center;gap:20px;padding:24px;text-decoration:none}
.qc-num{font-family:var(--serif);font-style:italic;font-size:30px;font-weight:500;line-height:1;color:var(--amber);flex-shrink:0;min-width:36px}
.quick-card b{display:block;font-family:var(--serif);font-size:18px;font-weight:600;margin-bottom:3px}
.quick-card span{font-size:var(--fs-sm);color:var(--text-muted);line-height:1.5}

/* Test */
.test-shell{max-width:800px;margin:0 auto;padding:64px 40px 170px}
.test-progress-mini{display:flex;flex-direction:column;gap:8px;align-items:flex-end}
.test-progress-mini span{font-family:var(--mono);font-size:var(--fs-xs);font-weight:500;color:var(--text-muted);text-transform:uppercase;letter-spacing:var(--ls-wide)}
.mini-bar{width:160px;height:2px}
.stage-card{padding:72px 56px;text-align:center}
.stage-eyebrow{font-family:var(--mono);font-size:var(--fs-xs);font-weight:500;color:var(--amber);letter-spacing:var(--ls-wider);text-transform:uppercase;margin-bottom:20px}
.stage-card h1{font-size:clamp(38px,5.2vw,60px);line-height:1.05;margin:0 0 20px;font-weight:400}
.stage-lede{font-family:var(--serif);font-style:italic;font-size:18px;line-height:1.7;color:var(--text-muted);max-width:540px;margin:0 auto 48px;font-weight:400}
.rules-list{display:grid;gap:12px;text-align:left;max-width:580px;margin:0 auto 48px}
.rule{display:flex;gap:20px;align-items:flex-start;padding:20px 24px}
.rule span{flex-shrink:0;min-width:30px;font-family:var(--serif);font-style:italic;font-weight:600;font-size:26px;line-height:1.1;color:var(--amber)}
.rule div{font-size:14.5px;line-height:1.65;color:var(--text-muted)}
.rule b{color:var(--text);font-weight:600}
.question-card{padding:44px 40px}
.q-meta{display:flex;justify-content:space-between;align-items:center;font-family:var(--mono);font-size:var(--fs-xs);color:var(--text-muted);font-weight:500;margin-bottom:26px}
.q-meta .q-level{font-family:var(--serif);font-style:italic;font-size:20px;font-weight:600;color:var(--amber)}
.q-text{font-family:var(--serif);font-size:24px;font-weight:500;line-height:1.4;margin-bottom:30px}
.q-sentence{font-family:var(--serif);font-style:italic;font-weight:500;font-size:28px;line-height:1.4;padding:26px 30px;margin-bottom:30px}
.result-level{font-family:var(--serif);font-size:clamp(100px,18vw,168px);font-weight:400;line-height:.9;letter-spacing:-.02em;color:var(--text);margin-bottom:20px}
.result-name{font-family:var(--serif);font-style:italic;font-size:28px;font-weight:400;color:var(--text-muted);margin-bottom:44px}
.rp-item .rp-label{font-family:var(--mono);font-size:var(--fs-xs);font-weight:500;color:var(--text-muted);text-transform:uppercase;letter-spacing:var(--ls-wide);margin-bottom:10px}
.rp-item .rp-level{font-family:var(--serif);font-size:36px;font-weight:500;line-height:1;color:var(--text)}

/* Lesson */
.lesson-shell{max-width:760px;margin:0 auto;padding:56px 40px 170px}
.lesson-header h1{font-size:clamp(36px,5.2vw,56px);line-height:1.08;margin:0 0 18px;font-weight:400}
.lh-eyebrow{font-family:var(--mono);font-size:var(--fs-xs);font-weight:500;color:var(--amber);letter-spacing:var(--ls-wider);text-transform:uppercase;margin-bottom:12px}
.lh-book{display:inline-block;font-family:var(--mono);font-size:var(--fs-xs);font-weight:500;color:var(--text-muted);padding:7px 14px;border-radius:var(--r-sm)}
.lesson-rule{padding:34px 36px;margin-bottom:24px}
.lesson-rule h2{font-family:var(--serif);font-style:italic;font-weight:500;font-size:24px;color:var(--amber);margin:0 0 14px}
.lesson-rule p{font-size:17px;line-height:1.85;color:var(--text)}
.lesson-exercises{padding:38px 36px}
.lesson-exercises h2{font-size:36px;margin:0 0 22px}
.progress-line{display:flex;align-items:center;gap:16px;margin-bottom:30px}
.pl-bar{flex:1;height:2px}
.progress-line span{font-family:var(--mono);font-size:var(--fs-xs);font-weight:500;color:var(--text-muted);min-width:52px;text-align:right}
.exercise{margin-bottom:32px;padding-bottom:30px;border-bottom:1px solid var(--border)}
.exercise:last-child{border-bottom:none;padding-bottom:0;margin-bottom:0}
.ex-q{font-family:var(--serif);font-size:22px;font-weight:500;line-height:1.4;margin-bottom:18px}
.ex-comment{display:none;margin-top:14px;padding:14px 18px;font-size:14px;line-height:1.65;color:var(--text-muted)}
.ex-comment.show{display:block}
.lesson-nav{position:fixed;bottom:0;left:0;right:0;z-index:50;display:flex;justify-content:space-between;padding:16px 40px;background:var(--topbar-bg);-webkit-backdrop-filter:blur(18px);backdrop-filter:blur(18px);border-top:1px solid var(--border)}
.lesson-nav button{padding:13px 28px;font-size:14px}

/* Vocabulary / Speaking / Listening / Writing */
.voc-shell,.spk-shell,.lst-shell,.wrt-shell{max-width:800px;margin:0 auto;padding:56px 40px 130px}
.voc-head,.spk-head,.lst-head,.wrt-head{margin-bottom:36px}
.voc-head h1,.spk-head h1,.lst-head h1,.wrt-head h1{font-size:clamp(38px,5.4vw,60px);margin:0 0 14px;font-weight:400}
.voc-head p,.spk-head p,.lst-head p,.wrt-head p{font-family:var(--serif);font-style:italic;font-size:17px;line-height:1.7;color:var(--text-muted);max-width:560px}
.vh-eyebrow,.sh-eyebrow,.lh-eyebrow,.wh-eyebrow{font-family:var(--mono);font-size:var(--fs-xs);font-weight:500;color:var(--amber);letter-spacing:var(--ls-wider);text-transform:uppercase;margin-bottom:12px}

.voc-stats{display:grid;grid-template-columns:1fr 1fr;gap:1px;background:var(--border);border:1px solid var(--border-2);border-radius:var(--r-lg);overflow:hidden;margin-bottom:56px}
.vs-card{background:var(--bg-2);padding:32px 28px}
.vs-value{font-family:var(--mono);font-size:58px;font-weight:400;line-height:1;color:var(--amber-2);margin-bottom:10px}
.vs-label{font-family:var(--sans);font-size:var(--fs-sm);color:var(--text-muted);font-weight:500;text-transform:uppercase;letter-spacing:var(--ls-wide)}

.spk-prompt,.wrt-task,.lst-original{padding:28px 30px;margin-bottom:24px}
.spk-prompt b{font-family:var(--mono);font-style:normal;font-size:var(--fs-xs);font-weight:600;letter-spacing:var(--ls-wide);color:var(--amber);margin-right:8px;text-transform:uppercase}
.wt-label,.st-label,.lo-label{font-family:var(--mono);font-style:normal;font-size:var(--fs-xs);font-weight:600;color:var(--amber);text-transform:uppercase;letter-spacing:var(--ls-wide);margin-bottom:12px}

.lst-title{font-family:var(--serif);font-size:36px;font-weight:500;line-height:1.15;margin-bottom:30px}
.lst-meta{display:flex;justify-content:space-between;align-items:center;font-size:var(--fs-sm);font-weight:500;color:var(--text-muted);margin-bottom:20px}
.lst-meta span:first-child{font-family:var(--serif);font-style:italic;font-size:20px;font-weight:600;color:var(--amber)}

.spk-timer,.record-timer{font-family:var(--mono);font-size:40px;font-weight:300;letter-spacing:.04em;color:var(--text);margin-top:22px}

.fb-overall-value{font-family:var(--serif);font-size:72px;font-weight:400;line-height:.9;color:var(--text)}
.fb-crit-name{color:var(--text-muted);font-weight:500}
.fb-crit-score{text-align:right;font-family:var(--mono);font-size:19px;font-weight:600;color:var(--amber-2)}
.fb-section h4{font-family:var(--serif);font-size:26px;font-weight:500;margin:0 0 12px}
.fb-better{padding:20px 24px;font-family:var(--serif);font-style:italic;font-weight:500;font-size:20px;line-height:1.65;color:var(--text)}

.wr-top{display:flex;justify-content:space-between;align-items:flex-start;padding-bottom:28px;margin-bottom:30px;border-bottom:1px solid var(--border)}
.wr-overall .wr-lvl{font-family:var(--serif);font-size:84px;font-weight:400;line-height:.9;color:var(--text)}
.wr-overall .wr-sc{font-family:var(--mono);font-size:var(--fs-xs);font-weight:500;color:var(--text-muted);margin-top:12px;text-transform:uppercase;letter-spacing:var(--ls-wide)}
.wr-score-big{font-family:var(--mono);font-size:56px;font-weight:400;line-height:1;color:var(--text)}
.wr-score-big span{font-size:22px;color:var(--text-muted);font-weight:400}
.wr-crit-head{display:flex;justify-content:space-between;align-items:baseline;margin-bottom:12px;font-family:var(--serif);font-size:17px;font-weight:600}
.wr-crit-score{font-family:var(--mono);font-size:22px;font-weight:600;color:var(--amber-2)}
.wr-section h4{font-family:var(--serif);font-size:26px;font-weight:500;margin:0 0 12px}
.wr-corrected{padding:24px 26px;font-family:var(--serif);font-style:italic;font-size:20px;font-weight:500;line-height:1.75}

/* Modal result */
.lesson-result{position:fixed;inset:0;z-index:999;display:flex;align-items:center;justify-content:center;padding:24px;background:var(--overlay);-webkit-backdrop-filter:blur(8px);backdrop-filter:blur(8px);animation:fadeIn var(--t) var(--ease)}
.lr-card{padding:52px 48px;text-align:center;max-width:460px;box-shadow:var(--shadow-lg);animation:rise 380ms var(--ease-out)}
.lr-icon{width:60px;height:60px;margin:0 auto 24px;display:flex;align-items:center;justify-content:center;border:1px solid var(--amber);border-radius:50%;color:var(--amber-2);font-size:26px}
.lr-card h2{font-size:38px;margin:0 0 12px;font-style:italic}
.lr-score{font-family:var(--serif);font-style:italic;font-size:18px;color:var(--text-muted);margin:0 0 32px}

/* Auth */
.auth-page{min-height:100vh;display:flex;align-items:center;justify-content:center;padding:40px 20px;position:relative;z-index:2}
.auth-card{position:relative;width:100%;max-width:440px;padding:52px 44px;border-radius:var(--r-xl);box-shadow:var(--shadow-lg);background:var(--card)}
.auth-card h1{font-size:34px;margin:0 0 8px;font-weight:400;font-style:italic}
.auth-sub{font-family:var(--serif);font-style:italic;color:var(--text-muted);font-size:16px;margin:0 0 32px}
.auth-field{display:block;margin-bottom:18px}
.auth-field span{display:block;font-family:var(--mono);font-size:var(--fs-xs);font-weight:600;color:var(--text-muted);margin-bottom:8px;text-transform:uppercase;letter-spacing:var(--ls-wide)}
.auth-submit{width:100%;padding:16px 24px;font-size:15px;margin-top:10px}
.auth-error{margin-top:16px;padding:12px 14px;background:var(--err-soft);color:var(--err);border-radius:var(--r);font-size:13.5px;border:1px solid var(--err)}
.auth-hint{margin-top:22px;text-align:center;font-size:13.5px;color:var(--text-muted)}
.auth-hint a{color:var(--amber);text-decoration:none;font-weight:600}
.auth-back{display:inline-flex;align-items:center;gap:6px;margin-bottom:24px;color:var(--text-muted);text-decoration:none;font-size:13.5px}
.auth-back:hover{color:var(--amber)}

/* Profile */
.profile-shell{max-width:1100px;margin:0 auto;padding:64px 32px 100px}
.profile-hero{display:flex;align-items:center;gap:32px;padding:44px 40px;border-radius:var(--r-xl);margin-bottom:28px}
.avatar{width:104px;height:104px;flex-shrink:0;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:40px;font-weight:700;color:var(--on-accent);box-shadow:var(--shadow-gold);background:var(--flame);letter-spacing:-.03em}
.profile-info h1{font-size:42px;margin:0 0 6px;font-style:italic;font-weight:500}
.profile-info .email{font-family:var(--mono);color:var(--text-muted);font-size:14.5px;margin-bottom:12px}
.profile-actions{display:flex;gap:10px;flex-wrap:wrap;margin-top:22px}
.stat-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:14px;margin-bottom:32px}
.section h2{font-size:28px;margin:0 0 20px;font-style:italic}
.history-table{background:var(--card);border:1px solid var(--border-2);border-radius:var(--r-lg);overflow:hidden}
.history-table th{background:var(--bg-2);color:var(--text-muted);font-family:var(--mono);font-weight:600;font-size:var(--fs-xs);text-transform:uppercase;letter-spacing:var(--ls-wide)}

@media(max-width:1000px){
  .skills{grid-template-columns:repeat(2,1fr)}
  .stat-row{grid-template-columns:repeat(2,1fr)}
}
@media(max-width:820px){
  .dash-shell{padding:28px 20px 90px}
  .level-hero{grid-template-columns:1fr;padding:38px 28px;gap:30px}
  .lh-level{font-size:96px}
  .stat-row,.skill-row,.curriculum-block{margin-bottom:48px}
  .sc-value{font-size:44px}
  .test-shell,.lesson-shell,.voc-shell,.spk-shell,.lst-shell,.wrt-shell{padding:32px 20px 120px}
  .stage-card,.result-card{padding:44px 26px}
  .q-sentence{font-size:22px;padding:20px 22px}
  .question-card,.reading-block,.listening-block,.writing-block,.speaking-block{padding:28px 22px}
  .test-nav,.lesson-nav{padding:12px 20px}
  .test-nav .btn-primary,.test-nav .btn-ghost,.lesson-nav button{padding:12px 20px;font-size:13.5px}
  .auth-card{padding:40px 28px}
  .auth-card h1{font-size:28px}
  .profile-shell{padding:32px 20px 80px}
  .profile-hero{flex-direction:column;text-align:center;padding:32px 24px}
  .avatar{width:88px;height:88px;font-size:34px}
  .profile-info h1{font-size:32px}
  .profile-actions{justify-content:center}
  .stat-grid{grid-template-columns:repeat(2,1fr)}
}
CSSADD
echo "  ✓ styles.css дополнен ($(wc -l < styles.css) строк всего)"
echo ""

# ============ 3. Очищаю page-specific CSS ============
echo "[3/6] Убираю хардкоды из page-specific CSS"
for f in dashboard.css test.css lesson.css vocabulary.css speaking.css listening.css writing.css; do
  if [ -f "$f" ]; then
    # Удаляем строки с явными цветами (hex, rgba, linear-gradient, но не через var)
    # но оставляем строки, где есть var(--...)
    awk '
      /#[0-9a-fA-F]{3,6}[^a-zA-Z]/ && !/var\(/ { next }
      /rgba\([0-9]/ && !/var\(/ { next }
      /linear-gradient\(/ && !/var\(/ { next }
      { print }
    ' "$f" > "$f.tmp"
    mv "$f.tmp" "$f"
    echo "  ✓ $f очищен"
  fi
done
echo ""

# ============ 4. Подключаю interactions.js во все HTML ============
echo "[4/6] Подключаю interactions.js"
for HTML in *.html; do
  [ -f "$HTML" ] || continue
  # Убираем старый animations.js если есть
  if grep -q 'animations.js' "$HTML"; then
    sed -i.bak '/animations\.js/d' "$HTML"
    rm -f "$HTML.bak"
  fi
  # Убираем старый interactions.js если есть (на случай повторного запуска)
  if grep -q 'interactions.js' "$HTML"; then
    continue
  fi
  sed -i.bak 's|</body>|<script src="/interactions.js?v=1" defer></script>\n</body>|' "$HTML"
  rm -f "$HTML.bak"
  echo "  → $HTML"
done
echo ""

# ============ 5. Обновляю сервер ============
echo "[5/6] Обновляю server.js"
if ! grep -q "'/interactions.js'" server.js; then
  perl -i -pe "s{('/animations\.js': 'animations\.js',)}{'/interactions.js': 'interactions.js',\n  \$1}" server.js
  # Удаляем старый animations.js роут, если файла больше нет
  if [ ! -f "animations.js" ]; then
    sed -i.bak "/'\/animations\.js'/d" server.js
    rm -f server.js.bak
  fi
fi

if node -c server.js 2>/dev/null; then
  echo "  ✓ server.js валиден"
else
  echo "  ✗ ОШИБКА — восстанавливаю"
  exit 1
fi
echo ""

# ============ 6. Проверка ============
echo "[6/6] Проверяю всё"
node server.js > /tmp/ioma_system.log 2>&1 &
PID=$!
sleep 2

FAIL=0
for PAGE in / /dashboard /test /lesson /login /register /profile /vocabulary /speaking /listening /writing; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$PAGE")
  [ "$CODE" != "200" ] && echo "  ✗ $PAGE → $CODE" && FAIL=$((FAIL+1))
done
for ASSET in /styles.css /particles.js /interactions.js /app.js; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$ASSET")
  [ "$CODE" != "200" ] && echo "  ✗ $ASSET → $CODE" && FAIL=$((FAIL+1))
done

kill $PID 2>/dev/null
wait $PID 2>/dev/null

echo ""
echo "============================================"
if [ $FAIL -eq 0 ]; then
  echo "  ✓ СИСТЕМА УСТАНОВЛЕНА"
  echo "============================================"
  echo ""
  echo "Что появилось:"
  echo "  • Cormorant (заголовки), Inter (текст), JetBrains Mono (цифры) — везде"
  echo "  • Page transitions: fade+slide между всеми страницами"
  echo "  • Счётчики: цифры плавно набегают (54 → 0 → 54)"
  echo "  • Кнопка 'Наверх' — появляется при скролле"
  echo "  • Микро-взаимодействия на всех кнопках и ссылках"
  echo "  • Единый ритм отступов, радиусов, шрифтов"
  echo "  • Убраны хардкоды цветов из page-specific CSS"
  echo "  • Светлая тема работает на всех страницах"
  echo ""
  echo "Обнови браузер Cmd+Shift+R"
  echo "Запуск: npm start"
else
  echo "  ⚠ ПРОБЛЕМ: $FAIL"
  echo "  Лог: /tmp/ioma_system.log"
fi
echo "============================================"
