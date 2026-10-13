#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  Робот-помощник: иконка + выезд по делу"
echo "============================================"
echo ""

mkdir -p _unused/backup
cp robot.js "_unused/backup/robot.js.$(date +%Y%m%d_%H%M%S)"
cp styles.css "_unused/backup/styles.css.$(date +%Y%m%d_%H%M%S)"
echo "✓ Бэкапы"
echo ""

# ============ 1. Удаляем старые стили робота ============
echo "[1/4] Убираю старые стили робота"
python3 << 'PYEOF'
import re
with open('styles.css','r') as f:
    css = f.read()
css = re.sub(r'/\* =+\s*РОБОТ.*?(?=/\* =[^=]|$)', '', css, flags=re.DOTALL)
with open('styles.css','w') as f:
    f.write(css.rstrip() + '\n')
print('  ✓')
PYEOF

# ============ 2. Новые стили ============
echo "[2/4] Новые стили — иконка + выезд"
cat >> styles.css << 'CSSEOF'

/* ============================================
   РОБОТ-ПОМОЩНИК v6
   Всегда — маленькая иконка. По делу — выезжает.
   ============================================ */

/* --- МАЛЕНЬКАЯ ИКОНКА (всегда в углу) --- */
.ioma-robot-mini{
  position:fixed;
  right:20px;
  bottom:20px;
  z-index:250;
  width:52px;
  height:52px;
  background:var(--bg);
  border:1px solid var(--border-2);
  border-radius:50%;
  display:flex;
  align-items:center;
  justify-content:center;
  cursor:pointer;
  transition:all .25s cubic-bezier(.16,1,.3,1);
  box-shadow:0 4px 16px rgba(0,0,0,.08);
  overflow:hidden;
  padding:6px;
}
.ioma-robot-mini:hover{
  transform:translateY(-2px) scale(1.05);
  border-color:var(--text);
  box-shadow:0 8px 24px rgba(0,0,0,.15);
}
.ioma-robot-mini:active{transform:translateY(0) scale(.98)}
.ioma-robot-mini svg{
  width:100%;
  height:100%;
  color:var(--text);
}
/* Скрываем иконку, когда открыт большой робот */
.ioma-robot-mini.hidden{
  opacity:0;
  pointer-events:none;
  transform:scale(.8);
}

/* Пульс, когда есть непрочитанное сообщение */
.ioma-robot-mini.has-message::after{
  content:"";
  position:absolute;
  top:6px;
  right:6px;
  width:10px;
  height:10px;
  background:var(--text);
  border-radius:50%;
  animation:miniPulse 2s ease-in-out infinite;
}
@keyframes miniPulse{
  0%,100%{transform:scale(1);opacity:1}
  50%{transform:scale(1.3);opacity:.7}
}

/* --- БОЛЬШОЙ РОБОТ (выезжает когда есть что сказать) --- */
.ioma-robot-root{
  position:fixed;
  right:20px;
  bottom:20px;
  z-index:260;
  display:flex;
  flex-direction:column;
  align-items:flex-end;
  gap:12px;
  pointer-events:none;
  opacity:0;
  transform:translateY(20px) scale(.9);
  transition:opacity .35s cubic-bezier(.16,1,.3,1),transform .35s cubic-bezier(.16,1,.3,1);
  transform-origin:bottom right;
  max-width:calc(100vw - 40px);
}
.ioma-robot-root.in{
  opacity:1;
  transform:translateY(0) scale(1);
  pointer-events:auto;
}
.ioma-robot-root > *{pointer-events:auto}

/* --- ФИГУРА (не draggable, просто картинка) --- */
.ioma-robot-figure{
  width:64px;
  height:76px;
  color:var(--text);
  display:flex;
  align-items:center;
  justify-content:center;
  cursor:pointer;
  user-select:none;
  flex-shrink:0;
  background:var(--bg);
  border:1px solid var(--border-2);
  border-radius:50%;
  padding:8px;
  transition:all .2s ease;
}
.ioma-robot-figure:hover{
  border-color:var(--text);
  transform:translateY(-2px);
}

.ioma-robot-svg{
  width:100%;
  height:100%;
  color:currentColor;
  overflow:visible;
  display:block;
  pointer-events:none;
}

/* Анимации внутри SVG */
.ioma-robot-svg .ant-dot{animation:antBounce 2.8s ease-in-out infinite;transform-origin:60px 32px}
@keyframes antBounce{0%,100%{transform:translateY(0)}50%{transform:translateY(-3px)}}
.ioma-robot-svg .eye{transform-origin:center;animation:eyeBlink 5s ease-in-out infinite}
.ioma-robot-svg .eye.right{animation-delay:.1s}
@keyframes eyeBlink{0%,92%,100%{transform:scaleY(1)}94%,96%{transform:scaleY(.12)}}
.ioma-robot-svg .mouth{transition:d .4s cubic-bezier(.22,.61,.36,1)}
.ioma-robot-svg .shadow{transform-origin:60px 132px;animation:shadowPulse 3.2s ease-in-out infinite}
@keyframes shadowPulse{0%,100%{transform:scaleX(1);opacity:.12}50%{transform:scaleX(.92);opacity:.08}}

.ioma-robot-root[data-state="thinking"] .ant-dot{animation:antBounce .7s ease-in-out infinite}
.ioma-robot-root[data-state="thinking"] .eye{animation:eyeBlink .9s ease-in-out infinite}
.ioma-robot-root[data-state="sad"] .ant-dot{transform:translateY(4px);animation:none}
.ioma-robot-root[data-state="happy"] .ioma-robot-figure{animation:robotHappy .7s ease-out}
@keyframes robotHappy{0%,100%{transform:translateY(0) rotate(0)}30%{transform:translateY(-6px) rotate(-3deg)}60%{transform:translateY(0) rotate(3deg)}}

/* --- ПУЗЫРЬ с речью --- */
.ioma-robot-bubble{
  position:relative;
  width:320px;
  max-width:calc(100vw - 60px);
  background:var(--text);
  color:var(--bg);
  padding:16px 20px 14px;
  border-radius:14px;
  opacity:0;
  transform:translateY(10px) scale(.96);
  transform-origin:bottom right;
  transition:all .3s cubic-bezier(.16,1,.3,1);
  pointer-events:none;
  box-shadow:0 12px 32px rgba(0,0,0,.2);
}
.ioma-robot-bubble.show{
  opacity:1;
  transform:none;
  pointer-events:auto;
}
.ioma-robot-bubble::after{
  content:"";
  position:absolute;
  right:32px;
  bottom:-7px;
  width:14px;
  height:14px;
  background:var(--text);
  transform:rotate(45deg);
  border-radius:0 0 3px 0;
}
.ioma-robot-bubble-text{
  font-family:var(--sans);
  font-size:13.5px;
  line-height:1.55;
  font-weight:500;
  padding-right:18px;
  word-wrap:break-word;
}
.ioma-robot-bubble-close{
  position:absolute;
  top:2px;
  right:4px;
  width:24px;height:24px;
  background:transparent;border:none;
  color:var(--bg);
  font-size:18px;line-height:1;
  cursor:pointer;opacity:.5;
  transition:opacity .2s;padding:0;
}
.ioma-robot-bubble-close:hover{opacity:1}

/* --- ФОРМА ввода --- */
.ioma-robot-form{
  display:none;
  gap:6px;
  margin-top:10px;
  padding-top:10px;
  border-top:1px solid rgba(0,0,0,.15);
}
.ioma-robot-bubble.expanded .ioma-robot-form{
  display:flex;
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
  min-width:0;
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
  flex-shrink:0;
}
.ioma-robot-send:hover{opacity:1}

/* --- Подсказка «нажми» при первом запуске --- */
.ioma-robot-mini-tip{
  position:fixed;
  right:80px;
  bottom:26px;
  z-index:249;
  background:var(--text);
  color:var(--bg);
  font-family:var(--sans);
  font-size:12px;
  font-weight:500;
  padding:8px 14px;
  border-radius:12px;
  white-space:nowrap;
  opacity:0;
  transform:translateX(8px);
  transition:all .4s cubic-bezier(.16,1,.3,1);
  pointer-events:none;
}
.ioma-robot-mini-tip.show{opacity:1;transform:translateX(0)}
.ioma-robot-mini-tip::after{
  content:"";
  position:absolute;
  right:-6px;
  top:50%;
  width:12px;
  height:12px;
  background:var(--text);
  transform:translateY(-50%) rotate(45deg);
  border-radius:0 3px 0 0;
}

/* Мобильные */
@media(max-width:820px){
  .ioma-robot-mini{right:14px;bottom:14px;width:46px;height:46px;padding:5px}
  .ioma-robot-root{right:14px;bottom:14px;gap:8px}
  .ioma-robot-figure{width:54px;height:64px;padding:6px}
  .ioma-robot-bubble{width:calc(100vw - 100px);padding:14px 16px 12px}
  .ioma-robot-bubble-text{font-size:12.5px}
  .ioma-robot-mini-tip{right:70px;bottom:20px;font-size:11px;padding:6px 10px}
}
CSSEOF
echo "  ✓ Стили готовы"
echo ""

# ============ 3. robot.js ============
echo "[3/4] Пишу robot.js — иконка + выезд по делу"
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
    writingDraft: null
  };
  var memory = [];
  var busy = false;
  var expanded = false; // открыт ли пузырь с полем ввода

  // Разные размеры SVG для иконки и для полного робота
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

  // Упрощённый SVG — только голова для мини-иконки
  function robotMiniSVG(){
    return ''
      + '<svg viewBox="0 0 80 80" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" style="width:100%;height:100%">'
      + '<line x1="40" y1="14" x2="40" y2="4" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>'
      + '<circle cx="40" cy="4" r="3.5" fill="currentColor"/>'
      + '<rect x="12" y="14" width="56" height="48" rx="12" fill="none" stroke="currentColor" stroke-width="2.5"/>'
      + '<circle cx="30" cy="36" r="4" fill="currentColor"/>'
      + '<circle cx="50" cy="36" r="4" fill="currentColor"/>'
      + '<path d="M30 50 Q40 56 50 50" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>'
      + '</svg>';
  }

  var miniBtn, miniTip, root, bubble, bubbleText, bubbleClose, input, figure;
  var hideTimer, tipTimer;

  // ============ ПОСТРОЕНИЕ ============
  function build(){
    if (document.getElementById('iomaRobotMini')) return;

    // 1. Мини-иконка
    miniBtn = document.createElement('button');
    miniBtn.id = 'iomaRobotMini';
    miniBtn.className = 'ioma-robot-mini';
    miniBtn.setAttribute('aria-label', 'Помощник');
    miniBtn.innerHTML = robotMiniSVG();
    document.body.appendChild(miniBtn);

    // 2. Подсказка
    miniTip = document.createElement('div');
    miniTip.className = 'ioma-robot-mini-tip';
    miniTip.textContent = 'Нужна помощь? Нажми';
    document.body.appendChild(miniTip);

    // 3. Большой робот
    root = document.createElement('div');
    root.id = 'iomaRobotRoot';
    root.className = 'ioma-robot-root';
    root.setAttribute('aria-hidden', 'true');

    bubble = document.createElement('div');
    bubble.className = 'ioma-robot-bubble';
    bubble.innerHTML = ''
      + '<button class="ioma-robot-bubble-close" aria-label="Закрыть">×</button>'
      + '<div class="ioma-robot-bubble-text"></div>'
      + '<form class="ioma-robot-form">'
      +   '<input class="ioma-robot-input" type="text" placeholder="Спроси что-нибудь…" autocomplete="off" maxlength="200">'
      +   '<button class="ioma-robot-send" type="submit" aria-label="Отправить">→</button>'
      + '</form>';

    figure = document.createElement('div');
    figure.className = 'ioma-robot-figure';
    figure.innerHTML = robotSVG();

    root.appendChild(bubble);
    root.appendChild(figure);
    document.body.appendChild(root);

    bubbleText = bubble.querySelector('.ioma-robot-bubble-text');
    bubbleClose = bubble.querySelector('.ioma-robot-bubble-close');
    input = bubble.querySelector('.ioma-robot-input');
    var form = bubble.querySelector('.ioma-robot-form');

    // ============ СОБЫТИЯ ============
    // Клик на мини-иконку — открыть большого
    miniBtn.addEventListener('click', function(){
      miniBtn.classList.add('hidden');
      miniBtn.classList.remove('has-message');
      hideTip();
      openExpanded();
    });

    // Закрыть
    bubbleClose.addEventListener('click', function(e){
      e.stopPropagation();
      closeAll();
    });

    // Клик на фигуру — развернуть поле ввода
    figure.addEventListener('click', function(){
      if (!expanded) openExpanded();
      else input.focus();
    });

    // Отправка вопроса
    form.addEventListener('submit', function(e){
      e.preventDefault();
      var text = (input.value || '').trim();
      if (!text || busy) return;
      input.value = '';
      ask(text, { sticky:true });
    });

    // Клик вне робота — закрыть, если не expanded
    document.addEventListener('click', function(e){
      if (!root.classList.contains('in')) return;
      if (root.contains(e.target)) return;
      if (e.target === miniBtn) return;
      if (!expanded) closeAll();
    });

    // Показать подсказку через 3 сек, если пользователь не открыл робота
    tipTimer = setTimeout(function(){
      if (!expanded){
        miniTip.classList.add('show');
        setTimeout(hideTip, 6000);
      }
    }, 3000);
  }

  function hideTip(){
    if (miniTip) miniTip.classList.remove('show');
  }

  function closeAll(){
    expanded = false;
    if (bubble){
      bubble.classList.remove('show', 'expanded');
    }
    if (root){
      root.classList.remove('in');
      root.setAttribute('aria-hidden', 'true');
    }
    if (miniBtn){
      miniBtn.classList.remove('hidden');
    }
    clearTimeout(hideTimer);
  }

  function openExpanded(){
    expanded = true;
    bubble.classList.add('expanded');
    show(STATE.CURIOUS);

    // Если ещё не говорили — попросить приветствие
    if (memory.length === 0){
      ask('', { mode:'greeting', sticky:true });
    } else {
      // Показать поле ввода
      bubble.classList.add('show');
      setTimeout(function(){ input.focus(); }, 400);
    }
  }

  // ============ СОСТОЯНИЕ ============
  function setState(state){
    if (!root) return;
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
    // Если открыт expanded — мини-иконку скрыть
    if (expanded && miniBtn) miniBtn.classList.add('hidden');
  }

  // Показать сообщение автоматически (не от пользователя)
  function sayAuto(text, duration){
    if (!text) return;
    // Скрываем мини-иконку
    if (miniBtn) miniBtn.classList.add('hidden');
    show(STATE.CURIOUS);
    if (bubbleText) bubbleText.textContent = text;
    setTimeout(function(){ bubble.classList.add('show'); }, 200);

    clearTimeout(hideTimer);
    hideTimer = setTimeout(function(){
      bubble.classList.remove('show');
      setTimeout(function(){
        if (!expanded) closeAll();
      }, 500);
    }, duration || 10000);
  }

  // ============ AI ============
  function ask(message, opts){
    if (busy) return;
    opts = opts || {};
    busy = true;
    if (opts.mode !== 'greeting') show(STATE.THINKING);
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

        // Если это автоматическое сообщение (не expanded) — скрыть через 10 сек
        if (!expanded){
          clearTimeout(hideTimer);
          hideTimer = setTimeout(function(){
            bubble.classList.remove('show');
            setTimeout(closeAll, 500);
          }, 10000);
        }
      } else {
        if (bubbleText) bubbleText.textContent = 'Не получилось ответить.';
        setState(STATE.SAD);
      }
    })
    .catch(function(){
      busy = false;
      if (bubbleText) bubbleText.textContent = 'Связь пропала.';
      setState(STATE.SAD);
    });
  }

  // ============ КОНТЕКСТ ============
  function loadContext(){
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

  // ============ ТРИГГЕРЫ ============
  // Только там, где действительно нужен — урок, тест, письмо, аудирование, речь
  function shouldAutoShow(){
    var p = location.pathname;
    return p === '/lesson' || p === '/test' || p === '/writing' ||
           p === '/listening' || p === '/speaking';
  }

  // Реакция на ошибку в уроке
  function watchLesson(){
    if (location.pathname !== '/lesson') return;
    var titleEl = document.getElementById('lessonTitle');
    if (titleEl){
      var c = setInterval(function(){
        if (titleEl.textContent && titleEl.textContent !== 'Loading...'){
          ctx.lessonTitle = titleEl.textContent;
          clearInterval(c);
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
        if (/✗|✕|Correct answer|Неверно/i.test(text)){
          ctx.mistakesInRow = (ctx.mistakesInRow || 0) + 1;
          ctx.lastError = text.slice(0, 150);
          // Только если 2 ошибки подряд — робот сам приходит
          if (ctx.mistakesInRow >= 2){
            var msg = 'Ошибка: ' + ctx.lastError;
            // Автоматически — открываем и говорим
            expanded = false;
            if (miniBtn) miniBtn.classList.add('hidden');
            show(STATE.SAD);
            if (bubbleText) bubbleText.textContent = '…';
            bubble.classList.add('show');
            fetch('/api/robot', {
              method:'POST',
              headers:{'Content-Type':'application/json'},
              body: JSON.stringify({ message: 'Объясни коротко мою ошибку и подскажи как правильно. ' + msg, context: ctx, history: [], mode:'auto-error' })
            })
            .then(function(r){ return r.json(); })
            .then(function(d){
              if (d && d.ok && d.reply){
                if (bubbleText) bubbleText.textContent = d.reply;
                memory.push({ role:'user', content: msg });
                memory.push({ role:'assistant', content: d.reply });
                setTimeout(function(){
                  bubble.classList.remove('show');
                  setTimeout(closeAll, 500);
                }, 12000);
              } else closeAll();
            })
            .catch(closeAll);
          }
        } else if (/✓|Правильно|Correct/i.test(text)){
          ctx.mistakesInRow = 0;
        }
      });
    });
    mo.observe(document.body, { attributes:true, subtree:true, attributeFilter:['class'] });
  }

  // Результат теста
  function watchTest(){
    if (location.pathname !== '/test') return;
    var result = document.querySelector('#stage-result');
    if (!result) return;
    var mo = new MutationObserver(function(){
      if (result.hidden === false){
        var lvl = document.getElementById('resultLevel');
        if (lvl && lvl.textContent.trim()){
          ctx.testLevel = lvl.textContent.trim();
          var msg = 'Студент прошёл тест, уровень ' + ctx.testLevel + '. Скажи конкретно с чего начать и что делать в первую неделю.';
          if (miniBtn) miniBtn.classList.add('hidden');
          show(STATE.HAPPY);
          if (bubbleText) bubbleText.textContent = '…';
          bubble.classList.add('show');
          fetch('/api/robot', {
            method:'POST',
            headers:{'Content-Type':'application/json'},
            body: JSON.stringify({ message: msg, context: ctx, history: [], mode:'auto-test' })
          })
          .then(function(r){ return r.json(); })
          .then(function(d){
            if (d && d.ok && d.reply){
              if (bubbleText) bubbleText.textContent = d.reply;
              setTimeout(function(){
                bubble.classList.remove('show');
                setTimeout(closeAll, 500);
              }, 15000);
            } else closeAll();
          })
          .catch(closeAll);
        }
        mo.disconnect();
      }
    });
    mo.observe(result, { attributes:true, attributeFilter:['hidden'] });
  }

  // Результат эссе
  function watchWriting(){
    if (location.pathname !== '/writing') return;
    var result = document.getElementById('wrtResult');
    if (!result) return;
    var mo = new MutationObserver(function(){
      if (result.hidden === false){
        var score = result.querySelector('.wr-score-big');
        if (score){
          ctx.writingScore = parseInt(score.textContent, 10) || 0;
          var msg = 'Студент написал эссе, балл ' + ctx.writingScore + '/100. Дай 2-3 конкретных совета как улучшить.';
          if (miniBtn) miniBtn.classList.add('hidden');
          show(STATE.THINKING);
          if (bubbleText) bubbleText.textContent = '…';
          bubble.classList.add('show');
          fetch('/api/robot', {
            method:'POST',
            headers:{'Content-Type':'application/json'},
            body: JSON.stringify({ message: msg, context: ctx, history: [], mode:'auto-writing' })
          })
          .then(function(r){ return r.json(); })
          .then(function(d){
            if (d && d.ok && d.reply){
              if (bubbleText) bubbleText.textContent = d.reply;
              setTimeout(function(){
                bubble.classList.remove('show');
                setTimeout(closeAll, 500);
              }, 14000);
            } else closeAll();
          })
          .catch(closeAll);
        }
        mo.disconnect();
      }
    });
    mo.observe(result, { attributes:true, attributeFilter:['hidden'] });
  }

  // Слушание
  function watchListening(){
    if (location.pathname !== '/listening') return;
    var result = document.getElementById('lstResult');
    if (!result) return;
    var mo = new MutationObserver(function(){
      if (result.hidden === false){
        var m = (result.textContent || '').match(/accuracy:\s*(\d+)%/i);
        if (m){
          var pct = parseInt(m[1], 10);
          if (pct < 50){
            ctx.listeningAccuracy = pct;
            var msg = 'Аудирование ' + pct + '%. Скажи конкретно что делать чтобы улучшить.';
            if (miniBtn) miniBtn.classList.add('hidden');
            show(STATE.SAD);
            if (bubbleText) bubbleText.textContent = '…';
            bubble.classList.add('show');
            fetch('/api/robot', {
              method:'POST',
              headers:{'Content-Type':'application/json'},
              body: JSON.stringify({ message: msg, context: ctx, history: [], mode:'auto-listening' })
            })
            .then(function(r){ return r.json(); })
            .then(function(d){
              if (d && d.ok && d.reply){
                if (bubbleText) bubbleText.textContent = d.reply;
                setTimeout(function(){
                  bubble.classList.remove('show');
                  setTimeout(closeAll, 500);
                }, 12000);
              } else closeAll();
            })
            .catch(closeAll);
          }
        }
      }
    });
    mo.observe(result, { attributes:true, subtree:true, attributeFilter:['hidden','class'] });
  }

  function init(){
    build();
    loadContext();
    watchLesson();
    watchTest();
    watchWriting();
    watchListening();
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();

  // Публичные методы (для отладки)
  window.robotSay = function(text){ sayAuto(text); };
  window.robotOpen = openExpanded;
  window.robotClose = closeAll;
})();
ROBOTEOF
echo "  ✓ robot.js готов"
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
  echo "Как теперь работает робот:"
  echo ""
  echo "  1. Маленькая иконка в правом нижнем углу (52×52) — всегда"
  echo "     • Кликни → раскроется поле «Спроси что-нибудь»"
  echo "     • Через 3 сек рядом появится подсказка «Нужна помощь?»"
  echo "     • Подсказка исчезнет через 6 сек"
  echo ""
  echo "  2. Большой робот выезжает ТОЛЬКО когда есть что сказать:"
  echo "     • 2 ошибки подряд в уроке → объяснит"
  echo "     • Прошёл тест → что делать дальше"
  echo "     • Написал эссе → советы по улучшению"
  echo "     • Плохое аудирование → что делать"
  echo ""
  echo "  3. НЕ висит постоянно, НЕ мешает, drag убран"
  echo "     После выезда: говорит, замолкает через 10-15 сек, сворачивается"
  echo ""
  echo "Cmd+Shift+R"
else
  echo "  ⚠ Сервер: $CODE"
  tail -15 /tmp/ioma_server.log
fi
