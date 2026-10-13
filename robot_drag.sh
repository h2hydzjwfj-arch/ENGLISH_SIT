#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  Робот: центр, draggable, отвечает сразу"
echo "============================================"
echo ""

mkdir -p _unused/backup
cp robot.js "_unused/backup/robot.js.$(date +%Y%m%d_%H%M%S)"
cp styles.css "_unused/backup/styles.css.$(date +%Y%m%d_%H%M%S)"
cp writing.js "_unused/backup/writing.js.$(date +%Y%m%d_%H%M%S)"
echo "✓ Бэкапы"
echo ""

# ============ 1. CSS ============
echo "[1/4] Обновляю стили робота"
python3 << 'PYEOF'
import re
with open('styles.css','r') as f:
    css = f.read()

# Удаляем старый блок робота
css = re.sub(r'/\* =+\s*РОБОТ v3.*?(?=/\* =|$)', '', css, flags=re.DOTALL)
css = re.sub(r'/\* =+\s*РОБОТ-ДРУГ v2.*?(?=/\* =|$)', '', css, flags=re.DOTALL)
css = re.sub(r'/\* =+\s*РОБОТ-ДРУГ.*?(?=/\* =|$)', '', css, flags=re.DOTALL)

with open('styles.css','w') as f:
    f.write(css.rstrip() + '\n')
print('  ✓ Старые стили убраны')
PYEOF

cat >> styles.css << 'CSSEOF'

/* ============================================
   РОБОТ v5 — draggable, центр, отвечает сразу
   ============================================ */
.ioma-robot-root{
  position:fixed;
  z-index:250;
  display:flex;
  flex-direction:column;
  align-items:flex-end;
  gap:14px;
  pointer-events:none;
  transition:opacity .5s ease;
  opacity:0;
  /* Позиция по умолчанию — справа, по центру */
  right:5%;
  top:50%;
  transform:translateY(-50%);
  /* НЕ используем transform для позиции — она будет через left/top */
  max-width:calc(100vw - 40px);
}
.ioma-robot-root.in{opacity:1}

/* Когда позиция задана через JS — используем left/top */
.ioma-robot-root[data-positioned="true"]{
  right:auto !important;
  top:auto !important;
  transform:none !important;
}

.ioma-robot-root > *{
  pointer-events:auto;
}

/* --- ФИГУРА (перетаскиваемая) --- */
.ioma-robot-figure{
  width:110px;
  height:130px;
  color:var(--text);
  padding:0;
  margin:0;
  display:flex;
  align-items:center;
  justify-content:center;
  background:none;
  border:none;
  filter:drop-shadow(0 4px 12px rgba(0,0,0,.08));
  transition:filter .3s ease, transform .2s ease;
  cursor:grab;
  user-select:none;
  touch-action:none;
}
.ioma-robot-figure:active{cursor:grabbing}
.ioma-robot-figure:hover{
  filter:drop-shadow(0 8px 20px rgba(0,0,0,.15));
}
.ioma-robot-root.dragging .ioma-robot-figure{
  cursor:grabbing;
  filter:drop-shadow(0 12px 28px rgba(0,0,0,.25));
}
.ioma-robot-root.dragging{
  transition:none;
}

.ioma-robot-svg{
  width:100%;
  height:100%;
  color:currentColor;
  overflow:visible;
  display:block;
  pointer-events:none;
}

/* Пульсация во время drag */
.ioma-robot-root.dragging .ioma-robot-svg{
  animation:robotDrag 1.2s ease-in-out infinite;
}
@keyframes robotDrag{
  0%,100%{transform:scale(1)}
  50%{transform:scale(1.05)}
}

/* Антенна / глаза / руки / рот — как раньше */
.ioma-robot-svg .ant-dot{animation:antBounce 2.8s ease-in-out infinite;transform-origin:60px 32px}
@keyframes antBounce{0%,100%{transform:translateY(0)}50%{transform:translateY(-3px)}}
.ioma-robot-svg .eye{transform-origin:center;animation:eyeBlink 5s ease-in-out infinite}
.ioma-robot-svg .eye.right{animation-delay:.1s}
@keyframes eyeBlink{0%,92%,100%{transform:scaleY(1)}94%,96%{transform:scaleY(.12)}}
.ioma-robot-svg .arm{transform-origin:center;animation:armSway 3.2s ease-in-out infinite}
.ioma-robot-svg .arm.right{animation-delay:.6s}
@keyframes armSway{0%,100%{transform:translateY(0)}50%{transform:translateY(-2px)}}
.ioma-robot-svg .mouth{transition:d .45s cubic-bezier(.22,.61,.36,1)}
.ioma-robot-svg .shadow{transform-origin:60px 132px;animation:shadowPulse 3.2s ease-in-out infinite}
@keyframes shadowPulse{0%,100%{transform:scaleX(1);opacity:.12}50%{transform:scaleX(.92);opacity:.08}}

.ioma-robot-root[data-state="thinking"] .ant-dot{animation:antBounce .7s ease-in-out infinite}
.ioma-robot-root[data-state="thinking"] .eye{animation:eyeBlink .9s ease-in-out infinite}
.ioma-robot-root[data-state="sad"] .ant-dot{transform:translateY(4px);animation:none}
.ioma-robot-root[data-state="sad"] .arm{animation:none;transform:translateY(2px)}
.ioma-robot-root[data-state="happy"] .ioma-robot-figure{animation:robotHappy .75s ease-out}
@keyframes robotHappy{0%,100%{transform:translateY(0) rotate(0)}30%{transform:translateY(-8px) rotate(-3deg)}60%{transform:translateY(0) rotate(3deg)}}

/* --- ПУЗЫРЬ --- */
.ioma-robot-bubble{
  position:relative;
  max-width:340px;
  background:var(--text);
  color:var(--bg);
  padding:18px 22px;
  border-radius:14px;
  opacity:0;
  transform:translateY(10px) scale(.95);
  transform-origin:bottom right;
  transition:all .35s cubic-bezier(.16,1,.3,1);
  pointer-events:none;
}
.ioma-robot-bubble.show{opacity:1;transform:none;pointer-events:auto}

/* Слева от bubble, если робот справа */
.ioma-robot-root[data-side="right"] .ioma-robot-bubble{transform-origin:bottom right}
.ioma-robot-root[data-side="left"] .ioma-robot-bubble{
  transform-origin:bottom left;
  order:2;
}
.ioma-robot-root[data-side="left"] .ioma-robot-figure{order:1}
.ioma-robot-root[data-side="left"]{align-items:flex-start}

.ioma-robot-bubble::after{
  content:"";
  position:absolute;
  right:44px;
  bottom:-7px;
  width:14px;
  height:14px;
  background:var(--text);
  transform:rotate(45deg);
  border-radius:0 0 3px 0;
}
.ioma-robot-root[data-side="left"] .ioma-robot-bubble::after{
  right:auto;
  left:44px;
  border-radius:0 0 0 3px;
}

.ioma-robot-bubble-text{
  font-family:var(--sans);
  font-size:13.5px;
  line-height:1.55;
  font-weight:500;
  padding-right:16px;
}
.ioma-robot-bubble-close{
  position:absolute;
  top:4px;
  right:6px;
  width:24px;height:24px;
  background:transparent;border:none;
  color:var(--bg);
  font-size:18px;line-height:1;
  cursor:pointer;opacity:.5;
  transition:opacity .2s;padding:0;
}
.ioma-robot-bubble-close:hover{opacity:1}

/* Форма ввода в bubble */
.ioma-robot-form{
  display:flex;
  gap:6px;
  margin-top:12px;
  padding-top:12px;
  border-top:1px solid rgba(0,0,0,.15);
}
.ioma-robot-input{
  flex:1;
  background:transparent;
  border:none;
  border-bottom:1px solid rgba(0,0,0,.2);
  color:var(--bg);
  font-family:var(--sans);
  font-size:13px;
  padding:6px 0;
  outline:none;
}
.ioma-robot-input::placeholder{color:rgba(0,0,0,.45)}
.ioma-robot-input:focus{border-bottom-color:var(--bg)}
.ioma-robot-send{
  background:transparent;
  border:none;
  color:var(--bg);
  font-size:16px;
  cursor:pointer;
  padding:0 4px;
  opacity:.7;
  transition:opacity .2s;
}
.ioma-robot-send:hover{opacity:1}

/* Плашка «перетащи меня» */
.ioma-robot-hint{
  position:absolute;
  bottom:-24px;
  left:50%;
  transform:translateX(-50%);
  font-family:var(--mono);
  font-size:9px;
  letter-spacing:.12em;
  text-transform:uppercase;
  color:var(--text-dim);
  white-space:nowrap;
  opacity:0;
  transition:opacity .3s;
  pointer-events:none;
}
.ioma-robot-figure:hover + .ioma-robot-hint,
.ioma-robot-root:hover .ioma-robot-hint{
  opacity:.8;
}

/* Мобильные */
@media(max-width:820px){
  .ioma-robot-figure{width:82px;height:98px}
  .ioma-robot-bubble{max-width:260px;padding:14px 18px}
  .ioma-robot-bubble-text{font-size:12.5px}
  .ioma-robot-root{right:14px !important;top:auto !important;bottom:60px !important;transform:none !important}
}
CSSEOF
echo "  ✓ Стили готовы"
echo ""

# ============ 2. robot.js — draggable + умные приветствия ============
echo "[2/4] Пишу нового robot.js — draggable + умный"

cat > robot.js << 'ROBOTEOF'
(function(){
  if (window.__iomaRobot) return;
  window.__iomaRobot = true;

  var STATE = { IDLE:'idle', HAPPY:'happy', SAD:'sad', THINKING:'thinking', CURIOUS:'curious' };

  var ctx = {
    page: location.pathname,
    level: null,
    lessonTitle: null,
    lastError: null,
    correctCount: 0,
    mistakesInRow: 0,
    idleSeconds: 0,
    testLevel: null,
    vocabDue: null,
    listeningAccuracy: null,
    writingScore: null,
    speakingLevel: null,
    writingDraft: null,
    pageText: null
  };
  var memory = [];
  var busy = false;

  function robotSVG(){
    return ''
      + '<svg class="ioma-robot-svg" viewBox="0 0 120 140" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">'
      + '<ellipse class="shadow" cx="60" cy="132" rx="28" ry="3.5" fill="currentColor" opacity=".12"/>'
      + '<line class="ant" x1="60" y1="32" x2="60" y2="14" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/>'
      + '<circle class="ant-dot" cx="60" cy="12" r="4" fill="currentColor"/>'
      + '<rect x="20" y="32" width="80" height="62" rx="14" fill="none" stroke="currentColor" stroke-width="3"/>'
      + '<circle class="eye left"  cx="44" cy="58" r="5" fill="currentColor"/>'
      + '<circle class="eye right" cx="76" cy="58" r="5" fill="currentColor"/>'
      + '<path class="mouth" d="M44 76 L76 76" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round"/>'
      + '<line x1="60" y1="94" x2="60" y2="104" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"/>'
      + '<rect x="36" y="104" width="48" height="22" rx="6" fill="none" stroke="currentColor" stroke-width="3"/>'
      + '<circle class="arm left" cx="26" cy="115" r="4" fill="currentColor"/>'
      + '<circle class="arm right" cx="94" cy="115" r="4" fill="currentColor"/>'
      + '</svg>';
  }

  var root, bubble, bubbleText, bubbleClose, input, figure, hideTimer, currentState = STATE.IDLE;

  // ============ ПОЗИЦИЯ ============
  var POS_KEY = 'ioma_robot_pos_v1';
  function loadPosition(){
    try {
      var raw = localStorage.getItem(POS_KEY);
      if (!raw) return null;
      var p = JSON.parse(raw);
      if (typeof p.x !== 'number' || typeof p.y !== 'number') return null;
      return p;
    } catch(e){ return null; }
  }
  function savePosition(x, y, side){
    try { localStorage.setItem(POS_KEY, JSON.stringify({ x:x, y:y, side:side })); } catch(e){}
  }

  function applyPosition(){
    var saved = loadPosition();
    if (!saved) {
      // По умолчанию — справа по центру
      root.setAttribute('data-side', 'right');
      return;
    }
    var w = window.innerWidth;
    var h = window.innerHeight;
    var x = Math.max(8, Math.min(saved.x, w - 130));
    var y = Math.max(8, Math.min(saved.y, h - 150));
    root.style.left = x + 'px';
    root.style.top = y + 'px';
    root.style.right = 'auto';
    root.style.transform = 'none';
    root.setAttribute('data-positioned', 'true');
    root.setAttribute('data-side', saved.side || (x < w / 2 ? 'left' : 'right'));
  }

  // ============ DRAG ============
  var drag = { active:false, startX:0, startY:0, startLeft:0, startTop:0, moved:false };

  function initDrag(){
    figure.addEventListener('pointerdown', function(e){
      if (e.button !== 0) return;
      // Игнорируем клики по форме ввода
      if (e.target.closest('.ioma-robot-form')) return;

      var rect = root.getBoundingClientRect();
      drag.active = true;
      drag.moved = false;
      drag.startX = e.clientX;
      drag.startY = e.clientY;
      drag.startLeft = rect.left;
      drag.startTop = rect.top;
      root.classList.add('dragging');
      figure.setPointerCapture(e.pointerId);
    });

    document.addEventListener('pointermove', function(e){
      if (!drag.active) return;
      var dx = e.clientX - drag.startX;
      var dy = e.clientY - drag.startY;
      if (Math.abs(dx) > 4 || Math.abs(dy) > 4) drag.moved = true;

      var w = window.innerWidth;
      var h = window.innerHeight;
      var newX = Math.max(8, Math.min(drag.startLeft + dx, w - 130));
      var newY = Math.max(8, Math.min(drag.startTop + dy, h - 150));

      root.style.left = newX + 'px';
      root.style.top = newY + 'px';
      root.style.right = 'auto';
      root.style.transform = 'none';
      root.setAttribute('data-positioned', 'true');
      root.setAttribute('data-side', newX < w / 2 ? 'left' : 'right');
    });

    document.addEventListener('pointerup', function(e){
      if (!drag.active) return;
      drag.active = false;
      root.classList.remove('dragging');
      try { figure.releasePointerCapture(e.pointerId); } catch(err){}
      // Сохраняем
      var rect = root.getBoundingClientRect();
      var side = rect.left < window.innerWidth / 2 ? 'left' : 'right';
      savePosition(rect.left, rect.top, side);
    });
  }

  // ============ DOM ============
  function build(){
    if (document.getElementById('iomaRobotRoot')) return;
    root = document.createElement('div');
    root.id = 'iomaRobotRoot';
    root.className = 'ioma-robot-root';
    root.setAttribute('aria-live', 'polite');
    root.setAttribute('aria-hidden', 'true');
    root.setAttribute('data-side', 'right');

    bubble = document.createElement('div');
    bubble.className = 'ioma-robot-bubble';
    bubble.setAttribute('role', 'status');
    bubble.innerHTML = ''
      + '<button class="ioma-robot-bubble-close" aria-label="Закрыть">×</button>'
      + '<div class="ioma-robot-bubble-text"></div>'
      + '<form class="ioma-robot-form">'
      +   '<input class="ioma-robot-input" type="text" placeholder="Спроси что-нибудь…" autocomplete="off" maxlength="200">'
      +   '<button class="ioma-robot-send" type="submit" aria-label="Отправить">→</button>'
      + '</form>';

    figure = document.createElement('div');
    figure.className = 'ioma-robot-figure';
    figure.setAttribute('aria-hidden', 'true');
    figure.innerHTML = robotSVG();

    var hint = document.createElement('div');
    hint.className = 'ioma-robot-hint';
    hint.textContent = '✥ перетащи меня';

    root.appendChild(bubble);
    root.appendChild(figure);
    root.appendChild(hint);
    document.body.appendChild(root);

    bubbleText = bubble.querySelector('.ioma-robot-bubble-text');
    bubbleClose = bubble.querySelector('.ioma-robot-bubble-close');
    input = bubble.querySelector('.ioma-robot-input');
    var form = bubble.querySelector('.ioma-robot-form');

    bubbleClose.addEventListener('click', function(e){
      e.stopPropagation();
      hideBubble();
      lastMessage = '';
    });

    form.addEventListener('submit', function(e){
      e.preventDefault();
      var text = (input.value || '').trim();
      if (!text || busy) return;
      input.value = '';
      ask(text);
    });

    // Клик по фигуре (если не тащили) — открыть поле ввода
    figure.addEventListener('click', function(e){
      if (drag.moved) return;
      if (bubble.classList.contains('show')) input.focus();
      else { show(); setTimeout(function(){ input.focus(); }, 300); }
    });

    applyPosition();
    initDrag();
  }

  // ============ СОСТОЯНИЯ ============
  function setState(state){
    if (!root) return;
    currentState = state;
    root.setAttribute('data-state', state);
    var mouth = root.querySelector('.mouth');
    if (!mouth) return;
    if (state === STATE.HAPPY) mouth.setAttribute('d', 'M44 72 Q60 84 76 72');
    else if (state === STATE.SAD) mouth.setAttribute('d', 'M44 82 Q60 71 76 82');
    else if (state === STATE.THINKING) mouth.setAttribute('d', 'M44 78 Q52 72 60 78 Q68 84 76 78');
    else if (state === STATE.CURIOUS) mouth.setAttribute('d', 'M46 76 Q60 82 74 76');
    else mouth.setAttribute('d', 'M44 76 L76 76');
  }

  function show(state){
    if (!root) return;
    setState(state || STATE.THINKING);
    root.classList.add('in');
    root.setAttribute('aria-hidden', 'false');
  }
  function hide(){
    if (!root) return;
    hideBubble();
    root.classList.remove('in');
    root.setAttribute('aria-hidden', 'true');
  }
  function hideBubble(){ if (bubble) bubble.classList.remove('show'); }

  var lastMessage = '';
  function say(text, opts){
    if (!text) return;
    opts = opts || {};
    if (lastMessage === text && bubble.classList.contains('show')) return;
    lastMessage = text;
    show(opts.state || STATE.THINKING);
    if (bubbleText) bubbleText.textContent = text;
    setTimeout(function(){ bubble.classList.add('show'); }, 300);
    if (!opts.sticky){
      clearTimeout(hideTimer);
      hideTimer = setTimeout(function(){
        hideBubble();
        setTimeout(hide, 600);
      }, opts.duration || 9000);
    }
  }

  // ============ КОНТЕКСТ ============
  function loadUserContext(){
    fetch('/api/me', { credentials:'same-origin' })
      .then(function(r){ return r.json(); })
      .then(function(d){
        if (!d || !d.ok || !d.profile) return;
        var p = d.profile;
        ctx.level = p.level || 'A2';
        if (p.vocabulary) ctx.vocabDue = p.vocabulary.filter(function(c){ return !c.due || c.due <= Date.now(); }).length;
      })
      .catch(function(){});
  }

  function captureWritingDraft(){
    if (location.pathname !== '/writing') return;
    setInterval(function(){
      var ta = document.getElementById('wrtInput');
      if (ta && ta.value.trim().length > 20){
        ctx.writingDraft = ta.value.trim().slice(0, 500);
      }
    }, 5000);
  }

  // ============ AI ============
  function ask(message, opts){
    if (busy) return;
    opts = opts || {};
    busy = true;
    show(opts.state || STATE.THINKING);
    if (bubbleText) bubbleText.textContent = '…';
    bubble.classList.add('show');

    if (message) memory.push({ role:'user', content: message });

    fetch('/api/robot', {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify({
        message: message || '',
        context: ctx,
        history: memory.slice(-6),
        mode: opts.mode || 'reply'
      })
    })
    .then(function(r){ return r.json(); })
    .then(function(d){
      busy = false;
      if (d && d.ok && d.reply){
        if (bubbleText) bubbleText.textContent = d.reply;
        memory.push({ role:'assistant', content: d.reply });
        setState(STATE.HAPPY);
        setTimeout(function(){ setState(STATE.CURIOUS); }, 2500);
        if (opts.duration){
          clearTimeout(hideTimer);
          hideTimer = setTimeout(function(){ hideBubble(); setTimeout(hide, 600); }, opts.duration);
        }
      } else {
        if (bubbleText) bubbleText.textContent = 'Не получилось ответить. Попробуй ещё.';
        setState(STATE.SAD);
      }
    })
    .catch(function(){
      busy = false;
      if (bubbleText) bubbleText.textContent = 'Связь пропала. Попробуй позже.';
      setState(STATE.SAD);
    });
  }

  // ============ ПРИВЕТСТВИЕ — АКТИВНОЕ, ПО ДЕЛУ ============
  function proactiveGreeting(){
    setTimeout(function(){
      if (memory.length > 0) return;
      ask('', { mode: 'greeting', state: STATE.CURIOUS, duration: 12000 });
    }, 900);
  }

  // ============ ТРИГГЕРЫ ============
  function watchLesson(){
    if (location.pathname !== '/lesson') return;
    var titleEl = document.getElementById('lessonTitle');
    if (titleEl){
      var check = setInterval(function(){
        if (titleEl.textContent && titleEl.textContent !== 'Loading...'){
          ctx.lessonTitle = titleEl.textContent;
          clearInterval(check);
        }
      }, 300);
    }
    var mo = new MutationObserver(function(muts){
      muts.forEach(function(m){
        if (m.type !== 'attributes' || m.attributeName !== 'class') return;
        var el = m.target;
        if (!el.classList.contains('ex-comment')) return;
        if (!el.classList.contains('show')) return;
        var text = (el.textContent || '').trim();
        var isWrong = /✗|✕|Correct answer|Неверно/i.test(text);
        var isRight = /✓|Правильно|Correct/i.test(text);
        if (isWrong){
          ctx.mistakesInRow = (ctx.mistakesInRow || 0) + 1;
          ctx.lastError = text.slice(0, 150);
          ask('Объясни коротко мою ошибку и как в следующий раз правильно. ' + ctx.lastError, {
            state: STATE.SAD, duration: 12000
          });
        } else if (isRight){
          ctx.mistakesInRow = 0;
          ctx.correctCount = (ctx.correctCount || 0) + 1;
          setState(STATE.HAPPY);
        }
      });
    });
    mo.observe(document.body, { attributes:true, subtree:true, attributeFilter:['class'] });
  }

  function watchTest(){
    if (location.pathname !== '/test') return;
    var result = document.querySelector('#stage-result');
    if (!result) return;
    var mo = new MutationObserver(function(){
      if (result.hidden === false){
        var lvl = document.getElementById('resultLevel');
        if (lvl && lvl.textContent.trim()){
          ctx.testLevel = lvl.textContent.trim();
          ask('Я прошёл тест. Уровень ' + ctx.testLevel + '. Скажи конкретно с чего начать.', { state:STATE.HAPPY, duration:14000 });
        }
        mo.disconnect();
      }
    });
    mo.observe(result, { attributes:true, attributeFilter:['hidden'] });
  }

  function watchListening(){
    if (location.pathname !== '/listening') return;
    var result = document.getElementById('lstResult');
    if (!result) return;
    var mo = new MutationObserver(function(){
      if (result.hidden === false){
        var m = (result.textContent || '').match(/accuracy:\s*(\d+)%/i);
        if (m){
          ctx.listeningAccuracy = parseInt(m[1], 10);
          ask('Аудирование ' + ctx.listeningAccuracy + '%. Скажи конкретно что мне делать чтобы улучшить.', {
            state: ctx.listeningAccuracy >= 80 ? STATE.HAPPY : STATE.SAD, duration: 12000
          });
        }
      }
    });
    mo.observe(result, { attributes:true, subtree:true, attributeFilter:['hidden','class'] });
  }

  function watchWriting(){
    if (location.pathname !== '/writing') return;
    var result = document.getElementById('wrtResult');
    if (!result) return;
    var mo = new MutationObserver(function(){
      if (result.hidden === false){
        var score = result.querySelector('.wr-score-big');
        if (score){
          ctx.writingScore = parseInt(score.textContent, 10) || 0;
          ask('Я написал текст, балл ' + ctx.writingScore + '/100. Дай 2-3 конкретных совета для улучшения.', { state:STATE.THINKING, duration:14000 });
        }
        mo.disconnect();
      }
    });
    mo.observe(result, { attributes:true, attributeFilter:['hidden'] });
  }

  function watchSpeaking(){
    if (location.pathname !== '/speaking') return;
    var fb = document.getElementById('spkFeedback');
    if (!fb) return;
    var mo = new MutationObserver(function(){
      if (fb.hidden === false){
        var overall = fb.querySelector('.fb-overall-value');
        if (overall && overall.textContent.trim()){
          ctx.speakingLevel = overall.textContent.trim();
          ask('Я говорил, уровень ' + ctx.speakingLevel + '. Один конкретный совет по речи.', { state:STATE.CURIOUS, duration:12000 });
        }
        mo.disconnect();
      }
    });
    mo.observe(fb, { attributes:true, attributeFilter:['hidden'] });
  }

  function watchIdle(){
    var last = Date.now();
    ['click','keydown','scroll','mousemove','touchstart'].forEach(function(evt){
      document.addEventListener(evt, function(){ last = Date.now(); }, { passive:true });
    });
    setInterval(function(){
      var idle = Math.floor((Date.now() - last) / 1000);
      ctx.idleSeconds = idle;
      if (idle >= 120 && idle < 200){
        ask('Я не делаю ничего уже 2 минуты. Дай короткий совет или предложи вернуться к учёбе.', { state:STATE.CURIOUS, duration:10000 });
        last = Date.now();
      }
    }, 30000);
  }

  function init(){
    build();
    loadUserContext();
    captureWritingDraft();
    proactiveGreeting();
    watchLesson();
    watchTest();
    watchListening();
    watchWriting();
    watchSpeaking();
    watchIdle();
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();

  window.robotSay = say;
  window.robotAsk = ask;
  window.robotReset = function(){
    try { localStorage.removeItem(POS_KEY); } catch(e){}
    location.reload();
  };
})();
ROBOTEOF
echo "  ✓ robot.js обновлён"
echo ""

# ============ 3. Убираем «Минимум 80 символов» из writing.html ============
echo "[3/4] Убираю 'Минимум 80 символов'"
python3 << 'PYEOF'
import re
with open('writing.html','r') as f:
    html = f.read()

# Заменяем блок с "Минимум 80 символов" и добавляем span для цели
html = re.sub(
    r'<div class="wrt-meta"><span id="wrtCount">[^<]*</span><span>[^<]*</span></div>',
    '<div class="wrt-meta"><span id="wrtCount">0 слов · 0 знаков</span></div>',
    html
)

with open('writing.html','w') as f:
    f.write(html)
print('  ✓ Изменено')
PYEOF
echo ""

# ============ 4. Перезапуск ============
echo "[4/4] Перезапуск"
lsof -ti:12000 2>/dev/null | xargs kill -9 2>/dev/null
pkill -f "node server.js" 2>/dev/null
sleep 1
nohup node server.js > /tmp/ioma_server.log 2>&1 & disown
sleep 3

CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:12000/)
echo ""
echo "============================================"
if [ "$CODE" = "200" ]; then
  echo "  ✓ ГОТОВО"
  echo "============================================"
  echo ""
  echo "Что изменилось:"
  echo "  • Робот теперь справа по центру (не внизу)"
  echo "  • Робота можно перетащить мышкой в любое место"
  echo "  • Позиция запоминается (правая/левая сторона)"
  echo "  • Робот сам говорит по делу при заходе на страницу:"
  echo "      — на writing: разбор того что написал"
  echo "      — на lesson: разбор ошибок"
  echo "      — на дашборде: куда идти дальше"
  echo "  • Убрано «Минимум 80 символов» из счётчика"
  echo "  • Убран дубликат счётчика"
  echo ""
  echo "Reset позиции: window.robotReset() в Console"
  echo ""
  echo "Cmd+Shift+R"
else
  echo "  ⚠ Сервер: $CODE"
  tail -15 /tmp/ioma_server.log
fi
