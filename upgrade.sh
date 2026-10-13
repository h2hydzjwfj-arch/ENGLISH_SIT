#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  АПГРЕЙД: анимации + светлая тема + TTS"
echo "============================================"
echo ""

mkdir -p _unused/backup
TS=$(date +%Y%m%d_%H%M%S)
cp styles.css "_unused/backup/styles.css.$TS"
cp particles.js "_unused/backup/particles.js.$TS"
cp server.js "_unused/backup/server.js.$TS"
echo "✓ Бэкапы созданы"
echo ""

# ============ 1. animations.js ============
echo "[1/6] Создаю animations.js"
cat > animations.js << 'ANIMEOF'
(function(){
  if (window.__iomaAnim) return;
  window.__iomaAnim = true;

  // ---------- TOAST ----------
  var toastBox = null;
  function ensureToastBox(){
    if (toastBox && document.body.contains(toastBox)) return toastBox;
    toastBox = document.createElement('div');
    toastBox.className = 'ioma-toast-box';
    document.body.appendChild(toastBox);
    return toastBox;
  }
  window.toast = function(msg, type){
    type = type || 'info';
    var box = ensureToastBox();
    var el = document.createElement('div');
    el.className = 'ioma-toast ioma-toast-' + type;
    el.innerHTML = '<span class="ioma-toast-icon">' +
      (type === 'success' ? '✦' : type === 'error' ? '✕' : '◉') +
      '</span><span>' + msg + '</span>';
    box.appendChild(el);
    requestAnimationFrame(function(){ el.classList.add('in'); });
    setTimeout(function(){
      el.classList.remove('in');
      setTimeout(function(){ el.remove(); }, 400);
    }, 3400);
  };

  // ---------- СКРОЛЛ-РЕВИЛ ----------
  var REVEAL_SEL = '.card,.feature-card,.method-item,.stat-card,.skill-card,.unit,.quick-card,.profile-hero,.section,.lesson-rule,.lesson-exercises,.lst-card,.spk-prompt,.spk-feedback,.wrt-task,.wrt-result,.question-card,.result-card,.auth-card,.hero h1,.hero .lede,.hero-actions,.hero-stats,.level-hero,.cb-head,.voc-stats,.vs-card';
  function initReveal(){
    var els = document.querySelectorAll(REVEAL_SEL);
    if (!('IntersectionObserver' in window)) {
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
    }, { threshold:0.08, rootMargin:'0px 0px -60px 0px' });
    els.forEach(function(el, i){
      if (el.classList.contains('ioma-reveal')) return;
      el.classList.add('ioma-reveal');
      el.style.transitionDelay = ((i % 6) * 60) + 'ms';
      io.observe(el);
    });
  }

  // ---------- RIPPLE НА КНОПКАХ ----------
  function initRipple(){
    document.addEventListener('click', function(e){
      var btn = e.target.closest('.btn-primary,.btn-ghost,.cta-mini,.lh-cta,.stage-btn,.q-option,.ex-opt,.opt,.lst-play,.lst-slow,.spk-btn,.cr-btn,.wt-new,.cr-show');
      if (!btn) return;
      var r = btn.getBoundingClientRect();
      var ripple = document.createElement('span');
      ripple.className = 'ioma-ripple';
      var size = Math.max(r.width, r.height) * 1.2;
      ripple.style.width = ripple.style.height = size + 'px';
      ripple.style.left = (e.clientX - r.left - size/2) + 'px';
      ripple.style.top = (e.clientY - r.top - size/2) + 'px';
      if (getComputedStyle(btn).position === 'static'){
        btn.style.position = 'relative';
      }
      btn.style.overflow = 'hidden';
      btn.appendChild(ripple);
      setTimeout(function(){ ripple.remove(); }, 650);
    }, true);
  }

  // ---------- CURSOR GLOW ----------
  function initCursorGlow(){
    if (window.matchMedia('(pointer: coarse)').matches) return;
    var glow = document.createElement('div');
    glow.className = 'ioma-cursor-glow';
    document.body.appendChild(glow);
    var tx = window.innerWidth/2, ty = window.innerHeight/2;
    var cx = tx, cy = ty;
    document.addEventListener('mousemove', function(e){
      tx = e.clientX; ty = e.clientY;
      glow.style.opacity = '1';
    });
    document.addEventListener('mouseleave', function(){ glow.style.opacity = '0'; });
    (function loop(){
      cx += (tx - cx) * 0.12;
      cy += (ty - cy) * 0.12;
      glow.style.transform = 'translate3d(' + (cx - 300) + 'px,' + (cy - 300) + 'px,0)';
      requestAnimationFrame(loop);
    })();
  }

  // ---------- HOVER-FOLLOW ----------
  function initHoverFollow(){
    if (window.matchMedia('(pointer: coarse)').matches) return;
    var cards = document.querySelectorAll('.card,.feature-card,.unit,.quick-card,.stat-card,.skill-card');
    cards.forEach(function(card){
      card.addEventListener('mousemove', function(e){
        var r = card.getBoundingClientRect();
        var x = ((e.clientX - r.left) / r.width - 0.5) * 6;
        var y = ((e.clientY - r.top) / r.height - 0.5) * -6;
        card.style.transform = 'perspective(900px) rotateY(' + x + 'deg) rotateX(' + y + 'deg) translateZ(4px)';
      });
      card.addEventListener('mouseleave', function(){
        card.style.transform = '';
      });
    });
  }

  // ---------- ПРОГРЕСС-БАРЫ ----------
  function initProgressBars(){
    setTimeout(function(){
      document.querySelectorAll('.bar-fill,.skill-fill,.lhp-fill,.mini-fill,.level-progress-fill,.pl-fill,.bar>div,.progress-bar>div').forEach(function(el){
        var w = el.style.width || '0%';
        el.style.width = '0%';
        requestAnimationFrame(function(){
          setTimeout(function(){ el.style.width = w; }, 60);
        });
      });
    }, 100);
  }

  // ---------- АФФИРМАЦИИ ----------
  var AFFIRM = [
    'Breathe. Learn. Become.',
    'Every word opens a new world.',
    'You are already fluent in the language of effort.',
    'One lesson today is a lifetime of fluency tomorrow.',
    'Speak, and the universe listens.',
    'Slow progress is still progress.',
    'The mind learns what the heart enjoys.',
    'You are the calm in every storm.',
    'Fluency begins with a single breath.',
    'Today, you choose growth.'
  ];
  function initAffirmation(){
    var path = location.pathname;
    if (path !== '/dashboard' && path !== '/profile') return;
    var hero = document.querySelector('.level-hero');
    if (!hero) return;
    var line = document.createElement('div');
    line.className = 'ioma-affirm';
    line.textContent = AFFIRM[Math.floor(Math.random() * AFFIRM.length)];
    hero.parentNode.insertBefore(line, hero);
  }

  // ---------- TTS КНОПКИ В УРОКАХ ----------
  function initTTSButtons(){
    // Кнопки только там где есть английский текст (примеры, вопросы)
    var targets = document.querySelectorAll('.ex-q, .q-sentence, .reading-text p, .lst-original .lo-text, .task-prompt, .spk-prompt');
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
        speakEnglish(el.textContent.trim(), btn);
      });
      el.appendChild(btn);
    });
  }

  function speakEnglish(text, btn){
    if (!text) return;
    var en = text.replace(/[^\x00-\x7F]/g, '').trim().slice(0, 1000);
    if (!en) en = text.slice(0, 1000);
    if (!en) return;

    if (btn && btn.classList.contains('playing')) {
      stopAll();
      return;
    }
    stopAll();
    if (btn) btn.classList.add('playing');

    // Edge TTS через сервер
    fetch('/api/tts', {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ text: en, lang:'en', gender: localStorage.getItem('ioma_gender') || 'female' })
    })
    .then(function(r){
      if (!r.ok) throw new Error('tts ' + r.status);
      return r.blob();
    })
    .then(function(blob){
      var url = URL.createObjectURL(blob);
      var audio = new Audio(url);
      window.__iomaCurrentAudio = { audio:audio, url:url, btn:btn };
      audio.onended = function(){
        if (btn) btn.classList.remove('playing');
        URL.revokeObjectURL(url);
        window.__iomaCurrentAudio = null;
      };
      audio.onerror = function(){ if (btn) btn.classList.remove('playing'); };
      audio.play();
    })
    .catch(function(){
      // Fallback
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
    if (window.__iomaCurrentAudio){
      try { window.__iomaCurrentAudio.audio.pause(); } catch(e){}
      try { URL.revokeObjectURL(window.__iomaCurrentAudio.url); } catch(e){}
      if (window.__iomaCurrentAudio.btn) window.__iomaCurrentAudio.btn.classList.remove('playing');
      window.__iomaCurrentAudio = null;
    }
    if ('speechSynthesis' in window) speechSynthesis.cancel();
  }
  window.iomaSpeakEnglish = speakEnglish;
  window.iomaStopAll = stopAll;

  // ---------- СКЕЛЕТОНЫ ----------
  function initSkeleton(){
    document.querySelectorAll('.placeholder').forEach(function(el){
      if (el.dataset.skeleton) return;
      el.dataset.skeleton = '1';
      if (/Загрузка|Loading/.test(el.textContent) || !el.textContent.trim()){
        el.innerHTML = '<div class="ioma-skel-line"></div><div class="ioma-skel-line" style="width:70%"></div><div class="ioma-skel-line" style="width:50%"></div>';
      }
    });
  }

  // ---------- ИНИЦИАЛИЗАЦИЯ ----------
  function init(){
    initReveal();
    initRipple();
    initCursorGlow();
    initHoverFollow();
    initProgressBars();
    initAffirmation();
    initTTSButtons();
    initSkeleton();
  }

  if (document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  // Если DOM меняется — переподключаем TTS
  var mo = new MutationObserver(function(){ initTTSButtons(); });
  mo.observe(document.body, { childList:true, subtree:true });
})();
ANIMEOF
echo "  ✓ animations.js готов ($(wc -l < animations.js) строк)"
echo ""

# ============ 2. particles.js ============
echo "[2/6] Переписываю particles.js — neon пузырьки"
cat > particles.js << 'PARTEOF'
(function(){
  if (window.__iomaParticles) return;
  window.__iomaParticles = true;

  var canvas, ctx, dpr = 1, W = 0, H = 0, raf = null;
  var bubbles = [], sparks = [];
  var mouse = { x:-1000, y:-1000 };
  var reduce = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;

  function initCanvas(){
    if (canvas) return;
    canvas = document.createElement('canvas');
    canvas.id = 'iomaParticlesCanvas';
    canvas.style.cssText = 'position:fixed;top:0;left:0;width:100vw;height:100vh;pointer-events:none;z-index:0;opacity:0;transition:opacity 1.4s ease';
    canvas.setAttribute('aria-hidden', 'true');
    document.body.appendChild(canvas);
    ctx = canvas.getContext('2d');
    resize();
    window.addEventListener('resize', resize);
    window.addEventListener('mousemove', function(e){ mouse.x = e.clientX; mouse.y = e.clientY; });
  }

  function resize(){
    dpr = Math.max(1, Math.min(2, window.devicePixelRatio || 1));
    W = window.innerWidth; H = window.innerHeight;
    canvas.width = W * dpr; canvas.height = H * dpr;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    rebuild();
  }

  function isDark(){ return !document.documentElement.classList.contains('light'); }

  function pickColor(){
    var r = Math.random();
    if (r < 0.35) return [0, 229, 255];      // cyan
    if (r < 0.55) return [124, 58, 237];      // purple
    if (r < 0.72) return [217, 70, 239];      // magenta
    if (r < 0.88) return [52, 211, 153];      // jade
    return [245, 166, 35];                    // saffron
  }

  function rebuild(){
    bubbles = [];
    var n = Math.max(28, Math.min(70, Math.round(W * H / 32000)));
    for (var i = 0; i < n; i++){
      bubbles.push({
        x: Math.random() * W,
        y: H + Math.random() * H,
        r: 4 + Math.random() * 16,
        vy: 0.15 + Math.random() * 0.5,
        vx: (Math.random() - 0.5) * 0.25,
        phase: Math.random() * Math.PI * 2,
        speed: 0.008 + Math.random() * 0.02,
        alpha: 0.25 + Math.random() * 0.4,
        color: pickColor()
      });
    }
    sparks = [];
  }

  function draw(){
    if (!ctx) return;
    ctx.clearRect(0, 0, W, H);
    var dark = isDark();

    for (var i = 0; i < bubbles.length; i++){
      var b = bubbles[i];
      b.phase += b.speed;
      b.x += b.vx + Math.sin(b.phase) * 0.15;
      b.y -= b.vy;

      // mouse repel/attract
      var dx = b.x - mouse.x, dy = b.y - mouse.y;
      var dist = Math.sqrt(dx*dx + dy*dy);
      if (dist < 140){
        var force = (140 - dist) / 140;
        b.x += (dx / dist) * force * 1.2;
        b.y += (dy / dist) * force * 1.2;
      }

      if (b.y + b.r < -20){
        b.y = H + b.r + Math.random() * 60;
        b.x = Math.random() * W;
        b.color = pickColor();
      }
      if (b.x < -b.r) b.x = W + b.r;
      if (b.x > W + b.r) b.x = -b.r;

      var flick = 0.65 + 0.35 * Math.sin(b.phase * 1.4);
      var a = b.alpha * flick * (dark ? 1 : 0.5);
      var c = b.color;

      if (dark){
        var g = ctx.createRadialGradient(b.x, b.y, 0, b.x, b.y, b.r * 2.2);
        g.addColorStop(0, 'rgba(' + c[0] + ',' + c[1] + ',' + c[2] + ',' + a + ')');
        g.addColorStop(0.4, 'rgba(' + c[0] + ',' + c[1] + ',' + c[2] + ',' + (a * 0.35) + ')');
        g.addColorStop(1, 'rgba(' + c[0] + ',' + c[1] + ',' + c[2] + ',0)');
        ctx.fillStyle = g;
        ctx.beginPath(); ctx.arc(b.x, b.y, b.r * 2.2, 0, Math.PI * 2); ctx.fill();

        ctx.fillStyle = 'rgba(' + c[0] + ',' + c[1] + ',' + c[2] + ',' + (a * 1.4) + ')';
        ctx.beginPath(); ctx.arc(b.x, b.y, b.r * 0.35, 0, Math.PI * 2); ctx.fill();
      } else {
        var g2 = ctx.createRadialGradient(b.x, b.y, 0, b.x, b.y, b.r * 2);
        g2.addColorStop(0, 'rgba(' + c[0] + ',' + c[1] + ',' + c[2] + ',' + (a * 0.5) + ')');
        g2.addColorStop(1, 'rgba(' + c[0] + ',' + c[1] + ',' + c[2] + ',0)');
        ctx.fillStyle = g2;
        ctx.beginPath(); ctx.arc(b.x, b.y, b.r * 2, 0, Math.PI * 2); ctx.fill();
      }
    }

    raf = requestAnimationFrame(draw);
  }

  function drawStatic(){
    if (!ctx) return;
    ctx.clearRect(0, 0, W, H);
    var dark = isDark();
    bubbles.forEach(function(b){
      var c = b.color;
      var a = b.alpha * (dark ? 1 : 0.5);
      var g = ctx.createRadialGradient(b.x, b.y, 0, b.x, b.y, b.r * 2);
      g.addColorStop(0, 'rgba(' + c[0] + ',' + c[1] + ',' + c[2] + ',' + a + ')');
      g.addColorStop(1, 'rgba(' + c[0] + ',' + c[1] + ',' + c[2] + ',0)');
      ctx.fillStyle = g;
      ctx.beginPath(); ctx.arc(b.x, b.y, b.r * 2, 0, Math.PI * 2); ctx.fill();
    });
  }

  function tick(){
    if (!canvas) initCanvas();
    canvas.style.opacity = '1';
    if (reduce){ drawStatic(); return; }
    if (!raf) draw();
  }

  new MutationObserver(function(){
    if (reduce){ drawStatic(); }
  }).observe(document.documentElement, { attributes:true, attributeFilter:['class'] });

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', tick);
  else tick();
})();
PARTEOF
echo "  ✓ particles.js готов ($(wc -l < particles.js) строк)"
echo ""

# ============ 3. styles.css — дописываем ============
echo "[3/6] Дописываю анимации и светлую тему в styles.css"
cat >> styles.css << 'CSSADD'

/* ==================== АНИМАЦИИ ==================== */
.ioma-reveal{opacity:0;transform:translateY(24px);transition:opacity .8s cubic-bezier(.16,1,.3,1),transform .8s cubic-bezier(.16,1,.3,1)}
.ioma-reveal.ioma-in{opacity:1;transform:none}

/* Ripple */
.ioma-ripple{position:absolute;border-radius:50%;pointer-events:none;background:radial-gradient(circle,rgba(255,255,255,.55) 0%,rgba(255,255,255,.15) 40%,transparent 70%);transform:scale(0);animation:iomaRipple .65s cubic-bezier(.22,.61,.36,1) forwards;mix-blend-mode:overlay}
@keyframes iomaRipple{to{transform:scale(2.2);opacity:0}}

/* Cursor glow */
.ioma-cursor-glow{position:fixed;top:0;left:0;width:600px;height:600px;pointer-events:none;z-index:1;opacity:0;transition:opacity .6s ease;background:radial-gradient(circle at center,rgba(0,229,255,.12) 0%,rgba(124,58,237,.08) 30%,transparent 60%);filter:blur(40px);will-change:transform}
html.light .ioma-cursor-glow{background:radial-gradient(circle at center,rgba(0,229,255,.16) 0%,rgba(124,58,237,.1) 30%,transparent 60%)}

/* Toast */
.ioma-toast-box{position:fixed;bottom:24px;left:50%;transform:translateX(-50%);z-index:9999;display:flex;flex-direction:column;gap:10px;pointer-events:none;max-width:90vw}
.ioma-toast{display:flex;align-items:center;gap:12px;padding:14px 22px;border-radius:var(--r-pill);font-size:14px;font-weight:500;background:linear-gradient(180deg,rgba(20,24,44,.92) 0%,rgba(14,17,32,.92) 100%);border:1px solid var(--border-2);-webkit-backdrop-filter:blur(20px);backdrop-filter:blur(20px);box-shadow:0 20px 48px -16px rgba(0,229,255,.5),inset 0 1px 0 rgba(255,255,255,.06);opacity:0;transform:translateY(20px) scale(.95);transition:all .4s cubic-bezier(.16,1,.3,1);pointer-events:auto;color:var(--text)}
.ioma-toast.in{opacity:1;transform:none}
.ioma-toast-icon{display:inline-flex;align-items:center;justify-content:center;width:22px;height:22px;border-radius:50%;font-size:12px;background:var(--flame);color:var(--on-accent)}
.ioma-toast-success{border-color:rgba(52,211,153,.4)}
.ioma-toast-success .ioma-toast-icon{background:linear-gradient(135deg,#34d399,#5eead4)}
.ioma-toast-error{border-color:rgba(248,113,113,.4)}
.ioma-toast-error .ioma-toast-icon{background:linear-gradient(135deg,#f87171,#fca5a5)}
html.light .ioma-toast{background:linear-gradient(180deg,rgba(255,255,255,.95) 0%,rgba(248,247,244,.95) 100%);box-shadow:0 20px 48px -16px rgba(0,0,0,.2),inset 0 1px 0 rgba(255,255,255,.8)}

/* Affirmation */
.ioma-affirm{text-align:center;font-family:var(--serif);font-style:italic;font-size:22px;color:var(--text-muted);padding:0 20px 28px;letter-spacing:.01em;animation:iomaFadeUp 1s cubic-bezier(.16,1,.3,1) both}
.ioma-affirm::before,.ioma-affirm::after{content:"✦";color:var(--neon);margin:0 12px;font-style:normal;font-size:14px;opacity:.7}
@keyframes iomaFadeUp{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:none}}

/* TTS inline button */
.ioma-tts-target{position:relative;padding-right:44px !important}
.ioma-tts-btn-inline{position:absolute;right:10px;top:50%;transform:translateY(-50%);width:30px;height:30px;display:inline-flex;align-items:center;justify-content:center;background:rgba(0,229,255,.08);border:1px solid rgba(0,229,255,.28);color:var(--neon);border-radius:50%;cursor:pointer;transition:all .25s cubic-bezier(.16,1,.3,1);padding:0}
.ioma-tts-btn-inline:hover{background:var(--flame);color:var(--on-accent);border-color:transparent;transform:translateY(-50%) scale(1.1);box-shadow:0 0 24px -4px rgba(0,229,255,.8)}
.ioma-tts-btn-inline.playing{background:var(--flame);color:var(--on-accent);border-color:transparent;animation:iomaPulse 1.2s ease-in-out infinite}
@keyframes iomaPulse{0%,100%{box-shadow:0 0 0 0 rgba(0,229,255,.5)}50%{box-shadow:0 0 0 10px rgba(0,229,255,0)}}
html.light .ioma-tts-btn-inline{background:rgba(0,150,200,.08);border-color:rgba(0,150,200,.3);color:#0891b2}

/* Skeleton */
.ioma-skel-line{height:14px;margin:8px 0;border-radius:8px;background:linear-gradient(90deg,rgba(130,140,200,.08) 0%,rgba(130,140,200,.18) 50%,rgba(130,140,200,.08) 100%);background-size:200% 100%;animation:iomaSkel 1.6s ease-in-out infinite}
@keyframes iomaSkel{0%{background-position:200% 0}100%{background-position:-200% 0}}

/* Плавные прогресс-бары */
.level-progress-fill,.mini-fill,.lhp-fill,.skill-fill,.pl-fill,.wr-crit-fill,.fb-crit-fill,.bar-fill,.bar>div,.progress-bar>div{transition:width 1.2s cubic-bezier(.16,1,.3,1)}

/* Пульсация бренда */
@keyframes iomaBrandGlow{0%,100%{filter:drop-shadow(0 0 0 rgba(0,229,255,0))}50%{filter:drop-shadow(0 0 12px rgba(0,229,255,.5))}}
.brand{animation:iomaBrandGlow 5s ease-in-out infinite}

/* Появление страниц */
@keyframes iomaPageIn{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:none}}
main{animation:iomaPageIn .6s cubic-bezier(.16,1,.3,1) both}

/* ==================== СВЕТЛАЯ ТЕМА ==================== */
html.light{
  color-scheme:light;
  --bg:#f5f4f0; --bg-2:#eceae4; --card:#ffffff; --card-2:#f8f6f1; --field:#f2f0ea;
  --text:#141822; --text-muted:#565a6e; --text-dim:#8e93a8;
  --border:rgba(20,24,34,.08); --border-2:rgba(20,24,34,.14);
  --track:rgba(20,24,34,.08);
  --neon:#0891b2; --neon-2:#6d28d9; --neon-3:#a21caf;
  --gold:#0891b2; --gold-2:#14b8a6; --gold-dim:#155e75;
  --accent:#0891b2; --accent-2:#14b8a6; --accent-soft:rgba(8,145,178,.1);
  --on-accent:#ffffff;
  --topbar-bg:rgba(245,244,240,.8); --overlay:rgba(20,24,34,.4);
  --flame:linear-gradient(135deg,#0891b2 0%,#6d28d9 100%);
  --flame-2:linear-gradient(135deg,#a21caf 0%,#0891b2 100%);
  --flame-soft:linear-gradient(135deg,rgba(8,145,178,.1),rgba(109,40,217,.1));
  --shadow-md:0 12px 40px -14px rgba(20,24,34,.15);
  --shadow-lg:0 32px 80px -28px rgba(20,24,34,.2);
  --shadow-gold:0 12px 40px -14px rgba(8,145,178,.3);
}
html.light body::before{
  background:
    radial-gradient(circle at 15% 25%, rgba(8,145,178,.12) 0%, transparent 35%),
    radial-gradient(circle at 85% 15%, rgba(162,28,175,.08) 0%, transparent 40%),
    radial-gradient(circle at 75% 85%, rgba(109,40,217,.1) 0%, transparent 40%),
    radial-gradient(circle at 20% 80%, rgba(20,184,166,.08) 0%, transparent 35%);
}
html.light body::after{
  background-image:
    linear-gradient(rgba(8,145,178,.05) 1px, transparent 1px),
    linear-gradient(90deg, rgba(8,145,178,.05) 1px, transparent 1px);
}
html.light .card,html.light .feature-card,html.light .method-item,html.light .unit,html.light .quick-card,html.light .stat-card,html.light .skill-card,html.light .stage-card,html.light .question-card,html.light .reading-block,html.light .listening-block,html.light .writing-block,html.light .speaking-block,html.light .result-card,html.light .level-hero,html.light .lesson-rule,html.light .lesson-exercises,html.light .lr-card,html.light .lst-card,html.light .spk-feedback,html.light .wrt-result,html.light .wrt-task,html.light .spk-prompt,html.light .voc-item,html.light .assist-window,html.light .level-badge,html.light .profile-hero,html.light .auth-card{
  background:linear-gradient(180deg,rgba(255,255,255,.95) 0%,rgba(250,249,245,.9) 100%);
  box-shadow:0 1px 2px rgba(20,24,34,.04),inset 0 1px 0 rgba(255,255,255,.8);
}
html.light .card:hover{border-color:rgba(8,145,178,.35);box-shadow:0 20px 48px -20px rgba(8,145,178,.25)}
html.light .q-option,html.light .ex-opt{background:rgba(242,240,234,.6)}
html.light .q-option:hover,html.light .ex-opt:hover{background:rgba(8,145,178,.06)}
html.light .topbar{background:var(--topbar-bg)}
html.light .btn-ghost{color:var(--text);border-color:var(--border-2)}
html.light .btn-ghost:hover{border-color:var(--neon);color:var(--neon)}
CSSADD
echo "  ✓ styles.css обновлён ($(wc -l < styles.css) строк)"
echo ""

# ============ 4. server.js — роут animations.js ============
echo "[4/6] Добавляю роут /animations.js в server.js"
if ! grep -q "'/animations.js': 'animations.js'" server.js; then
  # Вставляем строку после '/app.js'
  sed -i.tmp "s|'/app.js': 'app.js',|'/app.js': 'app.js',\n  '/animations.js': 'animations.js',|" server.js
  rm -f server.js.tmp
  echo "  ✓ Роут добавлен"
else
  echo "  ✓ Роут уже есть"
fi

# Проверка синтаксиса
if node -c server.js 2>/dev/null; then
  echo "  ✓ server.js валиден"
else
  echo "  ✗ ОШИБКА — восстанавливаю"
  cp "_unused/backup/server.js.$TS" server.js
  exit 1
fi
echo ""

# ============ 5. Подключаю animations.js в HTML ============
echo "[5/6] Подключаю animations.js во все HTML"
COUNT=0
for HTML in *.html; do
  [ -f "$HTML" ] || continue
  if grep -q 'animations.js' "$HTML"; then
    continue
  fi
  # Вставляем перед </body>
  sed -i.tmp "s|</body>|<script src=\"/animations.js?v=1\" defer></script>\n</body>|" "$HTML"
  rm -f "$HTML.tmp"
  COUNT=$((COUNT+1))
  echo "  → $HTML"
done
echo "  ✓ Обновлено: $COUNT"
echo ""

# ============ 6. Проверка ============
echo "[6/6] Проверяю проект"
node server.js > /tmp/ioma_upgrade.log 2>&1 &
PID=$!
sleep 2

FAIL=0
for PAGE in / /dashboard /test /lesson /login /vocabulary /speaking /listening /writing; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$PAGE")
  [ "$CODE" != "200" ] && echo "  ✗ $PAGE → $CODE" && FAIL=$((FAIL+1))
done

for ASSET in /animations.js /particles.js /styles.css; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$ASSET")
  [ "$CODE" != "200" ] && echo "  ✗ $ASSET → $CODE" && FAIL=$((FAIL+1))
done

kill $PID 2>/dev/null
wait $PID 2>/dev/null

echo ""
echo "============================================"
if [ $FAIL -eq 0 ]; then
  echo "  ✓ ВСЁ РАБОТАЕТ"
else
  echo "  ⚠ ПРОБЛЕМ: $FAIL"
  echo "  Лог: /tmp/ioma_upgrade.log"
fi
echo "============================================"
echo ""
echo "Что появилось:"
echo "  • Neon пузырьки на фоне (реагируют на курсор)"
echo "  • Скролл-ревил: карточки появляются плавно"
echo "  • Ripple на всех кнопках"
echo "  • Cursor glow — свет за курсором"
echo "  • Hover-follow: карточки слегка наклоняются"
echo "  • Toast-уведомления (window.toast('Текст', 'success'))"
echo "  • Аффирмации на дашборде"
echo "  • TTS 🔊 рядом с английскими примерами в уроках"
echo "  • Skeleton-загрузка"
echo "  • Полная светлая тема"
echo ""
echo "Запуск: npm start"
echo "Откат:  cp _unused/backup/styles.css.$TS styles.css"
