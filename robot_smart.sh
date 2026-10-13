#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  Робот v4 — AI-помощник"
echo "============================================"
echo ""

mkdir -p _unused/backup
cp robot.js "_unused/backup/robot.js.$(date +%Y%m%d_%H%M%S)"
echo "✓ Бэкап"
echo ""

cat > robot.js << 'ROBOTJSEOF'
(function(){
  if (window.__iomaRobot) return;
  window.__iomaRobot = true;

  var STATE = { IDLE:'idle', HAPPY:'happy', SAD:'sad', THINKING:'thinking', CURIOUS:'curious' };

  // ============ КОНТЕКСТ ============
  var ctx = {
    page: location.pathname,
    level: null,
    lessonTitle: null,
    lastError: null,
    correctCount: 0,
    totalCount: 0,
    mistakesInRow: 0,
    idleSeconds: 0,
    testLevel: null,
    vocabDue: null,
    listeningAccuracy: null,
    writingScore: null,
    speakingLevel: null
  };
  var memory = [];        // история диалога
  var said = {};          // что уже говорили (антиповтор)
  var busy = false;

  // ============ SVG ============
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

  var root, bubble, bubbleText, bubbleClose, input, sendBtn, hideTimer, sayTimer, currentState = STATE.IDLE;

  // ============ DOM ============
  function build(){
    if (document.getElementById('iomaRobotRoot')) return;
    root = document.createElement('div');
    root.id = 'iomaRobotRoot';
    root.className = 'ioma-robot-root';
    root.setAttribute('aria-live', 'polite');
    root.setAttribute('aria-hidden', 'true');

    bubble = document.createElement('div');
    bubble.className = 'ioma-robot-bubble';
    bubble.setAttribute('role', 'status');
    bubble.innerHTML = ''
      + '<button class="ioma-robot-bubble-close" aria-label="Закрыть">×</button>'
      + '<div class="ioma-robot-bubble-text"></div>'
      + '<form class="ioma-robot-form">'
      +   '<input class="ioma-robot-input" type="text" placeholder="Спроси что угодно…" autocomplete="off" maxlength="200">'
      +   '<button class="ioma-robot-send" type="submit" aria-label="Отправить">→</button>'
      + '</form>';

    var figure = document.createElement('div');
    figure.className = 'ioma-robot-figure';
    figure.setAttribute('aria-hidden', 'true');
    figure.innerHTML = robotSVG();

    root.appendChild(bubble);
    root.appendChild(figure);
    document.body.appendChild(root);

    bubbleText = bubble.querySelector('.ioma-robot-bubble-text');
    bubbleClose = bubble.querySelector('.ioma-robot-bubble-close');
    input = bubble.querySelector('.ioma-robot-input');
    sendBtn = bubble.querySelector('.ioma-robot-send');
    var form = bubble.querySelector('.ioma-robot-form');

    bubbleClose.addEventListener('click', function(e){
      e.stopPropagation();
      hideBubble();
    });

    form.addEventListener('submit', function(e){
      e.preventDefault();
      var text = (input.value || '').trim();
      if (!text || busy) return;
      input.value = '';
      ask(text);
    });

    // Клик по роботу — открыть поле ввода
    figure.addEventListener('click', function(){
      if (bubble.classList.contains('show')){
        input.focus();
      } else {
        show();
        setTimeout(function(){ input.focus(); }, 300);
      }
    });
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

  // ============ ПОКАЗ СООБЩЕНИЯ ============
  function say(text, opts){
    if (!text || busy) return;
    opts = opts || {};
    // Антиповтор
    var key = text.slice(0, 40);
    if (said[key] && !opts.force) return;
    said[key] = true;

    show(opts.state || STATE.THINKING);
    if (bubbleText) bubbleText.textContent = text;

    clearTimeout(sayTimer);
    sayTimer = setTimeout(function(){ bubble.classList.add('show'); }, 350);

    if (!opts.sticky){
      clearTimeout(hideTimer);
      hideTimer = setTimeout(function(){
        hideBubble();
        setTimeout(hide, 700);
      }, opts.duration || 9000);
    }

    setTimeout(function(){
      if (currentState === STATE.THINKING) setState(STATE.CURIOUS);
    }, 3200);
  }

  function hideBubble(){ if (bubble) bubble.classList.remove('show'); }

  // ============ СПРОСИТЬ AI ============
  function ask(text){
    busy = true;
    show(STATE.THINKING);
    if (bubbleText) bubbleText.textContent = '…';
    bubble.classList.add('show');

    memory.push({ role:'user', content: text });

    fetch('/api/robot', {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ message: text, context: ctx, history: memory.slice(-6) })
    })
    .then(function(r){ return r.json(); })
    .then(function(d){
      busy = false;
      if (d && d.ok && d.reply){
        memory.push({ role:'assistant', content: d.reply });
        if (bubbleText) bubbleText.textContent = d.reply;
        setState(STATE.HAPPY);
        setTimeout(function(){ setState(STATE.CURIOUS); }, 2500);
      } else {
        if (bubbleText) bubbleText.textContent = 'Не получилось ответить. Попробуй ещё раз.';
        setState(STATE.SAD);
      }
    })
    .catch(function(){
      busy = false;
      if (bubbleText) bubbleText.textContent = 'Связь с учителем пропала. Попробуй позже.';
      setState(STATE.SAD);
    });
  }

  // ============ ПОГРУЗКА КОНТЕКСТА ============
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

  // ============ ТРИГГЕРЫ ПО СТРАНИЦАМ ============
  function triggerInitial(){
    setTimeout(function(){
      if (memory.length > 0) return; // уже говорили
      fetch('/api/robot', {
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body: JSON.stringify({ context: ctx })
      })
      .then(function(r){ return r.json(); })
      .then(function(d){
        if (d && d.ok && d.reply) say(d.reply, { duration:9000 });
      })
      .catch(function(){});
    }, 900);
  }

  // В уроке — следим за ошибками
  function watchLesson(){
    if (location.pathname !== '/lesson') return;

    // Заголовок урока
    var titleEl = document.getElementById('lessonTitle');
    if (titleEl){
      var check = setInterval(function(){
        if (titleEl.textContent && titleEl.textContent !== 'Loading...'){
          ctx.lessonTitle = titleEl.textContent;
          clearInterval(check);
        }
      }, 300);
    }

    // Комментарии после ответов
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
          if (ctx.mistakesInRow >= 2){
            ask2('Я ошибся дважды подряд в этом упражнении. Помоги понять, что я делаю не так. Ошибка: ' + ctx.lastError, { state:STATE.SAD });
          } else {
            ask2('Объясни коротко мою ошибку. ' + ctx.lastError, { state:STATE.SAD });
          }
        } else if (isRight){
          ctx.mistakesInRow = 0;
          ctx.correctCount = (ctx.correctCount || 0) + 1;
          setState(STATE.HAPPY);
        }
      });
    });
    mo.observe(document.body, { attributes:true, subtree:true, attributeFilter:['class'] });
  }

  // Универсальный запрос к AI с контекстом
  function ask2(message, opts){
    if (busy) return;
    opts = opts || {};
    busy = true;
    show(opts.state || STATE.THINKING);
    if (bubbleText) bubbleText.textContent = '…';
    bubble.classList.add('show');

    fetch('/api/robot', {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ message: message, context: ctx, history: memory.slice(-4) })
    })
    .then(function(r){ return r.json(); })
    .then(function(d){
      busy = false;
      if (d && d.ok && d.reply){
        if (bubbleText) bubbleText.textContent = d.reply;
        memory.push({ role:'user', content: message });
        memory.push({ role:'assistant', content: d.reply });
      }
    })
    .catch(function(){ busy = false; });
  }

  // Тест завершён
  function watchTest(){
    if (location.pathname !== '/test') return;
    var result = document.querySelector('#stage-result');
    if (!result) return;
    var mo = new MutationObserver(function(){
      if (result.hidden === false){
        var lvl = document.getElementById('resultLevel');
        if (lvl && lvl.textContent.trim()){
          ctx.testLevel = lvl.textContent.trim();
          ask2('Я только что прошёл тест. Мой уровень: ' + ctx.testLevel + '. Что дальше?', { state:STATE.HAPPY });
        }
        mo.disconnect();
      }
    });
    mo.observe(result, { attributes:true, attributeFilter:['hidden'] });
  }

  // Vocabulary
  function watchVocab(){
    if (location.pathname !== '/vocabulary') return;
    var due = document.getElementById('vsDue');
    if (!due) return;
    setTimeout(function(){
      var n = parseInt(due.textContent, 10) || 0;
      if (n > 0){
        ctx.vocabDue = n;
        ask2('У меня ' + n + ' слов к повторению. Стоит начать сейчас?', { state:STATE.CURIOUS });
      }
    }, 1200);
  }

  // Listening результат
  function watchListening(){
    if (location.pathname !== '/listening') return;
    var result = document.getElementById('lstResult');
    if (!result) return;
    var mo = new MutationObserver(function(){
      if (result.hidden === false){
        var m = (result.textContent || '').match(/accuracy:\s*(\d+)%/i);
        if (m){
          ctx.listeningAccuracy = parseInt(m[1], 10);
          if (ctx.listeningAccuracy < 50) ask2('Точность аудирования ' + ctx.listeningAccuracy + '%. Что мне делать?', { state:STATE.SAD });
          else if (ctx.listeningAccuracy >= 80) ask2('Аудирование ' + ctx.listeningAccuracy + '%. Хорошо получилось?', { state:STATE.HAPPY });
        }
      }
    });
    mo.observe(result, { attributes:true, subtree:true, attributeFilter:['hidden','class'] });
  }

  // Writing результат
  function watchWriting(){
    if (location.pathname !== '/writing') return;
    var result = document.getElementById('wrtResult');
    if (!result) return;
    var mo = new MutationObserver(function(){
      if (result.hidden === false){
        var score = result.querySelector('.wr-score-big');
        if (score){
          ctx.writingScore = parseInt(score.textContent, 10) || 0;
          ask2('Я написал текст, балл ' + ctx.writingScore + '/100. Как улучшить?', { state: ctx.writingScore >= 80 ? STATE.HAPPY : STATE.THINKING });
        }
        mo.disconnect();
      }
    });
    mo.observe(result, { attributes:true, attributeFilter:['hidden'] });
  }

  // Speaking
  function watchSpeaking(){
    if (location.pathname !== '/speaking') return;
    var fb = document.getElementById('spkFeedback');
    if (!fb) return;
    var mo = new MutationObserver(function(){
      if (fb.hidden === false){
        var overall = fb.querySelector('.fb-overall-value');
        if (overall && overall.textContent.trim()){
          ctx.speakingLevel = overall.textContent.trim();
          ask2('Я говорил на английском, уровень ' + ctx.speakingLevel + '. Дай совет по речи.', { state:STATE.CURIOUS });
        }
        mo.disconnect();
      }
    });
    mo.observe(fb, { attributes:true, attributeFilter:['hidden'] });
  }

  // Idle — 2 минуты без действий
  function watchIdle(){
    var last = Date.now();
    ['click','keydown','scroll','mousemove','touchstart'].forEach(function(evt){
      document.addEventListener(evt, function(){ last = Date.now(); }, { passive:true });
    });
    setInterval(function(){
      var idle = Math.floor((Date.now() - last) / 1000);
      ctx.idleSeconds = idle;
      if (idle >= 120 && idle < 200){
        ask2('Я 2 минуты не делаю ничего на странице. Дай короткий совет или мотивацию.', { state:STATE.CURIOUS });
        last = Date.now();
      }
    }, 30000);
  }

  // ============ INIT ============
  function init(){
    build();
    loadUserContext();
    triggerInitial();
    watchLesson();
    watchTest();
    watchVocab();
    watchListening();
    watchWriting();
    watchSpeaking();
    watchIdle();
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();

  window.robotSay = say;
  window.robotAsk = ask;
})();
ROBOTJSEOF
echo "  ✓ robot.js переписан"
echo ""

# Обновление кэша HTML
for HTML in *.html; do
  [ -f "$HTML" ] || continue
  perl -i -pe "s/robot\.js\?v=\d+/robot.js?v=5/g" "$HTML"
done
echo "✓ Кэш обновлён"
echo ""

# Перезапуск
lsof -ti:12000 2>/dev/null | xargs kill -9 2>/dev/null
pkill -f "node server.js" 2>/dev/null
sleep 1
nohup node server.js > /tmp/ioma_server.log 2>&1 & disown
sleep 2

CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:12000/)
echo ""
if [ "$CODE" = "200" ]; then
  echo "✓ Сервер работает"
else
  echo "⚠ Сервер: $CODE"
  cat /tmp/ioma_server.log
fi
