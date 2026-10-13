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
    miniBtn.setAttribute('aria-label', 'ioma — помощник');
    miniBtn.innerHTML = robotMiniSVG();
    document.body.appendChild(miniBtn);

    // 2. Подсказка
    miniTip = document.createElement('div');
    miniTip.className = 'ioma-robot-mini-tip';
    miniTip.textContent = 'Привет, я ioma. Нажми если нужна помощь';
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
    // Авто-всплытие ОТКЛЮЧЕНО — робот молчит пока пользователь не кликнет иконку
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();

  // Публичные методы (для отладки)
  window.robotSay = function(text){ sayAuto(text); };
  window.robotOpen = openExpanded;
  window.robotClose = closeAll;
})();
