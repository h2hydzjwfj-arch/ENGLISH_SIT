(function(){
  if (window.__iomaRobot) return;
  window.__iomaRobot = true;

  var STATE = { IDLE:'idle', HAPPY:'happy', SAD:'sad', THINKING:'thinking', CURIOUS:'curious' };

  var ctx = {
    page: location.pathname,
    level: null,
    lessonTitle: null,
    lastError: null,
    testLevel: null,
    vocabDue: null,
    listeningAccuracy: null,
    writingScore: null,
    speakingLevel: null
  };
  var memory = [];
  var busy = false;
  var expanded = false;

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

  var miniBtn, miniTip, root, bubble, bubbleText, bubbleClose, input, figure;
  var hideTimer, tipTimer;

  function build(){
    if (document.getElementById('iomaRobotMini')) return;

    // 1. Мини-иконка
    miniBtn = document.createElement('button');
    miniBtn.id = 'iomaRobotMini';
    miniBtn.className = 'ioma-robot-mini';
    miniBtn.setAttribute('aria-label', 'ioma — помощник');
    miniBtn.innerHTML = ''
      + '<svg viewBox="0 0 80 80" xmlns="http://www.w3.org/2000/svg" style="width:100%;height:100%">'
      + '<line x1="40" y1="14" x2="40" y2="4" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>'
      + '<circle cx="40" cy="4" r="3.5" fill="currentColor"/>'
      + '<rect x="12" y="14" width="56" height="48" rx="12" fill="none" stroke="currentColor" stroke-width="2.5"/>'
      + '<circle cx="30" cy="36" r="4" fill="currentColor"/>'
      + '<circle cx="50" cy="36" r="4" fill="currentColor"/>'
      + '<path d="M30 50 Q40 56 50 50" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>'
      + '</svg>';
    document.body.appendChild(miniBtn);

    // 2. Подсказка
    miniTip = document.createElement('div');
    miniTip.className = 'ioma-robot-mini-tip';
    miniTip.textContent = 'Спроси меня 👋';
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
      +   '<input class="ioma-robot-input" type="text" placeholder="Спроси что-нибудь…" autocomplete="off" maxlength="300">'
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
    miniBtn.addEventListener('click', function(){
      miniBtn.classList.add('hidden');
      miniBtn.classList.remove('has-message');
      hideTip();
      openExpanded();
    });

    bubbleClose.addEventListener('click', function(e){
      e.stopPropagation();
      closeAll();
    });

    figure.addEventListener('click', function(){
      if (!expanded) openExpanded();
      else input.focus();
    });

    form.addEventListener('submit', function(e){
      e.preventDefault();
      var text = (input.value || '').trim();
      if (!text) return;
      if (busy) return;
      input.value = '';
      sendQuestion(text);
    });

    document.addEventListener('click', function(e){
      if (!root.classList.contains('in')) return;
      if (root.contains(e.target)) return;
      if (e.target === miniBtn) return;
      if (!expanded) closeAll();
    });

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
    bubble.classList.add('show');
    // Сразу фокус на поле ввода
    setTimeout(function(){ input.focus(); }, 300);
  }

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
    if (expanded && miniBtn) miniBtn.classList.add('hidden');
  }

  // ============ ОТПРАВКА ВОПРОСА ============
  function sendQuestion(text){
    busy = true;
    show(STATE.THINKING);
    if (bubbleText) bubbleText.textContent = '…';
    bubble.classList.add('show');

    memory.push({ role:'user', content: text });

    fetch('/api/robot', {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify({
        message: text,
        context: ctx,
        history: memory.slice(-6),
        mode: 'reply'
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

  // ============ ТРИГГЕРЫ (только сигналы на иконку) ============
  function watchLesson(){
    if (location.pathname !== '/lesson') return;
    var mo = new MutationObserver(function(muts){
      muts.forEach(function(m){
        if (m.type !== 'attributes' || m.attributeName !== 'class') return;
        var el = m.target;
        if (!el.classList.contains('ex-comment')) return;
        if (!el.classList.contains('show')) return;
        var text = (el.textContent || '').trim();
        if (/✗|✕|Correct answer|Неверно/i.test(text)){
          ctx.lastError = text.slice(0, 150);
          if (miniBtn) miniBtn.classList.add('has-message');
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
          if (miniBtn) miniBtn.classList.add('has-message');
        }
        mo.disconnect();
      }
    });
    mo.observe(result, { attributes:true, attributeFilter:['hidden'] });
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
          if (miniBtn) miniBtn.classList.add('has-message');
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
          var pct = parseInt(m[1], 10);
          ctx.listeningAccuracy = pct;
          if (pct < 50 && miniBtn) miniBtn.classList.add('has-message');
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

  window.robotOpen = openExpanded;
  window.robotClose = closeAll;
})();
