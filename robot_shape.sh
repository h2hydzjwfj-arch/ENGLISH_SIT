#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  РОБОТ v3 — самодостаточная фигура"
echo "============================================"
echo ""

mkdir -p _unused/backup
TS=$(date +%Y%m%d_%H%M%S)
cp robot.js "_unused/backup/robot.js.$TS"
cp styles.css "_unused/backup/styles.css.$TS"
echo "✓ Бэкапы"
echo ""

# ============ 1. Новый SVG: самодостаточная фигурка ============
echo "[1/3] Новый SVG робота — сам по себе, не в кнопке"
cat > robot.js << 'ROBOTJSEOF'
(function(){
  if (window.__iomaRobot) return;
  window.__iomaRobot = true;

  var STATE = { IDLE:'idle', HAPPY:'happy', SAD:'sad', THINKING:'thinking', CURIOUS:'curious' };

  // Самодостаточный SVG — фигура с тенью-основанием, без рамки
  function robotSVG(){
    return ''
      + '<svg class="ioma-robot-svg" viewBox="0 0 120 140" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">'
      // тень-основание (эллипс под ногами)
      + '<ellipse class="shadow" cx="60" cy="132" rx="28" ry="3.5" fill="currentColor" opacity=".12"/>'
      // антенна
      + '<line class="ant" x1="60" y1="32" x2="60" y2="14" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/>'
      + '<circle class="ant-dot" cx="60" cy="12" r="4" fill="currentColor"/>'
      // голова
      + '<rect x="20" y="32" width="80" height="62" rx="14" fill="none" stroke="currentColor" stroke-width="3"/>'
      // глаза
      + '<circle class="eye left"  cx="44" cy="58" r="5" fill="currentColor"/>'
      + '<circle class="eye right" cx="76" cy="58" r="5" fill="currentColor"/>'
      // рот
      + '<path class="mouth" d="M44 76 L76 76" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round"/>'
      // шея
      + '<line x1="60" y1="94" x2="60" y2="104" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"/>'
      // тело
      + '<rect x="36" y="104" width="48" height="22" rx="6" fill="none" stroke="currentColor" stroke-width="3"/>'
      // ручки (кружки по бокам)
      + '<circle class="arm left" cx="26" cy="115" r="4" fill="currentColor"/>'
      + '<circle class="arm right" cx="94" cy="115" r="4" fill="currentColor"/>'
      + '</svg>';
  }

  var root, bubble, bubbleText, bubbleClose, hideTimer, sayTimer, currentState = STATE.IDLE;

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
      + '<div class="ioma-robot-bubble-text"></div>';

    // Фигура — не кнопка, не в рамке. Просто div с SVG.
    var figure = document.createElement('div');
    figure.className = 'ioma-robot-figure';
    figure.setAttribute('aria-hidden', 'true');
    figure.innerHTML = robotSVG();

    root.appendChild(bubble);
    root.appendChild(figure);
    document.body.appendChild(root);
    bubbleText = bubble.querySelector('.ioma-robot-bubble-text');
    bubbleClose = bubble.querySelector('.ioma-robot-bubble-close');
    bubbleClose.addEventListener('click', function(e){
      e.stopPropagation();
      hideBubble();
      lastMessage = '';
    });
  }

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
    setState(state || STATE.IDLE);
    root.classList.add('in');
    root.setAttribute('aria-hidden', 'false');
  }

  function hide(){
    if (!root) return;
    hideBubble();
    root.classList.remove('in');
    root.setAttribute('aria-hidden', 'true');
  }

  var lastMessage = '';
  var AUTO_HIDE = 9000;

  function say(text, opts){
    if (!text) return;
    opts = opts || {};
    if (lastMessage === text && bubble.classList.contains('show')) return;
    lastMessage = text;
    show(opts.state || STATE.THINKING);
    if (bubbleText) bubbleText.textContent = text;
    clearTimeout(sayTimer);
    sayTimer = setTimeout(function(){ bubble.classList.add('show'); }, 420);
    clearTimeout(hideTimer);
    hideTimer = setTimeout(function(){
      hideBubble();
      setTimeout(hide, 800);
    }, opts.duration || AUTO_HIDE);
    setTimeout(function(){
      if (currentState === STATE.THINKING) setState(STATE.CURIOUS);
    }, 3000);
  }

  function hideBubble(){
    if (!bubble) return;
    bubble.classList.remove('show');
  }

  window.robotSay = say;
  window.robotState = setState;
  window.robotHide = hide;

  // ============ ТРИГГЕРЫ ============
  function initLessonWatcher(){
    if (location.pathname !== '/lesson') return;
    var mo = new MutationObserver(function(muts){
      muts.forEach(function(m){
        if (m.type !== 'attributes' || m.attributeName !== 'class') return;
        var el = m.target;
        if (!el.classList.contains('ex-comment')) return;
        if (!el.classList.contains('show')) return;
        var text = (el.textContent || '').trim();
        if (/✗|✕|Correct answer|Неверно/i.test(text)){
          setState(STATE.SAD);
          say('Не спеши. Прочитай правило сверху — там есть ответ.', { state:STATE.SAD, duration:7000 });
        } else if (/✓|Правильно|Correct/i.test(text)){
          setState(STATE.HAPPY);
        }
      });
    });
    mo.observe(document.body, { attributes:true, subtree:true, attributeFilter:['class'] });
  }

  function initTestWatcher(){
    if (location.pathname !== '/test') return;
    var result = document.querySelector('#stage-result');
    if (!result) return;
    var mo = new MutationObserver(function(){
      if (result.hidden === false){
        var lvl = document.getElementById('resultLevel');
        if (lvl && lvl.textContent.trim()){
          say('Твой уровень: ' + lvl.textContent.trim() + '. Идём в дашборд — я покажу с чего начать.', { state:STATE.HAPPY, duration:10000 });
        }
        mo.disconnect();
      }
    });
    mo.observe(result, { attributes:true, attributeFilter:['hidden'] });
  }

  function initVocabularyWatcher(){
    if (location.pathname !== '/vocabulary') return;
    setTimeout(function(){
      var due = document.getElementById('vsDue');
      if (!due) return;
      var n = parseInt(due.textContent, 10);
      if (n > 0) say('У тебя ' + n + ' слов к повторению. Не откладывай — 5 минут.', { state:STATE.CURIOUS });
    }, 1500);
  }

  function initListeningWatcher(){
    if (location.pathname !== '/listening') return;
    var result = document.getElementById('lstResult');
    if (!result) return;
    var mo = new MutationObserver(function(){
      if (result.hidden === false){
        var text = (result.textContent || '').toLowerCase();
        var m = text.match(/accuracy:\s*(\d+)%/);
        if (m){
          var pct = parseInt(m[1], 10);
          if (pct < 50) say('Слушай медленно. Прослушай ещё раз — станет понятнее.', { state:STATE.SAD, duration:8000 });
          else if (pct >= 80) say('Отличный слух! Ты услышал почти всё.', { state:STATE.HAPPY, duration:6000 });
        }
      }
    });
    mo.observe(result, { attributes:true, subtree:true, attributeFilter:['hidden','class'] });
  }

  function initWritingWatcher(){
    if (location.pathname !== '/writing') return;
    var result = document.getElementById('wrtResult');
    if (!result) return;
    var mo = new MutationObserver(function(){
      if (result.hidden === false){
        var score = result.querySelector('.wr-score-big');
        if (score){
          var n = parseInt(score.textContent, 10);
          if (n >= 80) say('Хороший текст! Уровень растёт.', { state:STATE.HAPPY, duration:7000 });
          else if (n < 60) say('Перечитай текст. Обрати внимание на связки и артикли.', { state:STATE.THINKING, duration:9000 });
        }
        mo.disconnect();
      }
    });
    mo.observe(result, { attributes:true, attributeFilter:['hidden'] });
  }

  function initSpeakingWatcher(){
    if (location.pathname !== '/speaking') return;
    var feedback = document.getElementById('spkFeedback');
    if (!feedback) return;
    var mo = new MutationObserver(function(){
      if (feedback.hidden === false){
        var overall = feedback.querySelector('.fb-overall-value');
        if (overall && overall.textContent.trim()){
          say('Уровень ' + overall.textContent.trim() + '. Говори каждый день — и беглость придёт.', { state:STATE.CURIOUS, duration:8000 });
        }
        mo.disconnect();
      }
    });
    mo.observe(feedback, { attributes:true, attributeFilter:['hidden'] });
  }

  function init(){
    build();
    initLessonWatcher();
    initTestWatcher();
    initVocabularyWatcher();
    initListeningWatcher();
    initWritingWatcher();
    initSpeakingWatcher();
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
ROBOTJSEOF
echo "  ✓ robot.js обновлён"
echo ""

# ============ 2. Стили: фигура без рамки ============
echo "[2/3] Обновляю стили — робот как фигура"
python3 << 'PYEOF'
import re
with open('styles.css','r') as f:
    css = f.read()
css = re.sub(r'/\* =+\s*РОБОТ-ДРУГ v2.*?(?=/\* =|$)', '', css, flags=re.DOTALL)
with open('styles.css','w') as f:
    f.write(css.rstrip() + '\n')
print('  ✓ Старые стили робота убраны')
PYEOF

cat >> styles.css << 'CSSEOF'

/* ============================================
   РОБОТ v3 — самодостаточная фигура
   ============================================ */
.ioma-robot-root{
  position:fixed;
  right:32px;
  bottom:32px;
  z-index:250;
  display:flex;
  flex-direction:column;
  align-items:flex-end;
  gap:18px;
  pointer-events:none;
  transition:transform .6s cubic-bezier(.16,1,.3,1),opacity .5s ease;
  transform:translateY(120%);
  opacity:0;
}
.ioma-robot-root.in{
  transform:translateY(0);
  opacity:1;
}
.ioma-robot-root > *{pointer-events:auto}

/* --- САМА ФИГУРА: без рамки, без фона, только контур --- */
.ioma-robot-figure{
  width:120px;
  height:140px;
  color:var(--text);
  padding:0;
  margin:0;
  display:flex;
  align-items:center;
  justify-content:center;
  background:none;
  border:none;
  /* лёгкая тень под самим персонажем */
  filter:drop-shadow(0 6px 14px rgba(0,0,0,.12));
  transition:transform .4s cubic-bezier(.16,1,.3,1),filter .4s;
  cursor:default;
  user-select:none;
}
html:not(.light) .ioma-robot-figure{
  filter:drop-shadow(0 8px 24px rgba(255,255,255,.06));
}
.ioma-robot-figure:hover{
  transform:translateY(-4px);
  filter:drop-shadow(0 12px 26px rgba(0,0,0,.2));
}

.ioma-robot-svg{
  width:100%;
  height:100%;
  color:currentColor;
  overflow:visible;
  display:block;
}

/* --- Антенна: качается как у живого --- */
.ioma-robot-svg .ant-dot{
  animation:antBounce 2.8s ease-in-out infinite;
  transform-origin:60px 32px;
}
@keyframes antBounce{
  0%,100%{transform:translateY(0)}
  50%{transform:translateY(-3px)}
}

/* --- Глаза мигают --- */
.ioma-robot-svg .eye{
  transform-origin:center;
  animation:eyeBlink 5s ease-in-out infinite;
}
.ioma-robot-svg .eye.right{animation-delay:.1s}
@keyframes eyeBlink{
  0%,92%,100%{transform:scaleY(1)}
  94%,96%{transform:scaleY(.12)}
}

/* --- Руки покачиваются --- */
.ioma-robot-svg .arm{
  transform-origin:center;
  animation:armSway 3.2s ease-in-out infinite;
}
.ioma-robot-svg .arm.right{animation-delay:.6s}
@keyframes armSway{
  0%,100%{transform:translateY(0)}
  50%{transform:translateY(-2px)}
}

/* --- Рот меняется плавно --- */
.ioma-robot-svg .mouth{transition:d .45s cubic-bezier(.22,.61,.36,1)}

/* --- Тень покачивается --- */
.ioma-robot-svg .shadow{
  transform-origin:60px 132px;
  animation:shadowPulse 3.2s ease-in-out infinite;
}
@keyframes shadowPulse{
  0%,100%{transform:scaleX(1);opacity:.12}
  50%{transform:scaleX(.92);opacity:.08}
}

/* --- THINKING (думает) --- */
.ioma-robot-root[data-state="thinking"] .ant-dot{animation:antBounce .7s ease-in-out infinite}
.ioma-robot-root[data-state="thinking"] .eye{animation:eyeBlink .9s ease-in-out infinite}
.ioma-robot-root[data-state="thinking"] .shadow{animation:shadowPulse 1.2s ease-in-out infinite}

/* --- SAD (ошибка) --- */
.ioma-robot-root[data-state="sad"] .ant-dot{transform:translateY(4px);animation:none}
.ioma-robot-root[data-state="sad"] .arm{animation:none;transform:translateY(2px)}

/* --- HAPPY (правильный ответ) --- */
.ioma-robot-root[data-state="happy"] .ioma-robot-figure{
  animation:robotHappy .75s ease-out;
}
@keyframes robotHappy{
  0%,100%{transform:translateY(0) rotate(0)}
  30%{transform:translateY(-8px) rotate(-3deg)}
  60%{transform:translateY(0) rotate(3deg)}
}

/* --- Пузырь --- */
.ioma-robot-bubble{
  position:relative;
  max-width:340px;
  background:var(--text);
  color:var(--bg);
  padding:20px 26px 20px 22px;
  opacity:0;
  transform:translateY(14px) scale(.95);
  transform-origin:bottom right;
  transition:all .4s cubic-bezier(.16,1,.3,1);
  pointer-events:none;
  /* скруглённый, но без острых углов */
  border-radius:14px;
}
.ioma-robot-bubble.show{opacity:1;transform:none;pointer-events:auto}
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
.ioma-robot-bubble-text{
  font-family:var(--sans);
  font-size:14px;
  line-height:1.6;
  font-weight:500;
  letter-spacing:-.005em;
  padding-right:16px;
}
.ioma-robot-bubble-close{
  position:absolute;
  top:6px;
  right:8px;
  width:26px;
  height:26px;
  background:transparent;
  border:none;
  color:var(--bg);
  font-size:20px;
  line-height:1;
  cursor:pointer;
  opacity:.55;
  transition:opacity .2s;
  padding:0;
}
.ioma-robot-bubble-close:hover{opacity:1}

/* --- Мобильные --- */
@media(max-width:820px){
  .ioma-robot-root{right:14px;bottom:14px;gap:12px}
  .ioma-robot-figure{width:90px;height:106px}
  .ioma-robot-bubble{max-width:260px;padding:16px 20px 14px 18px}
  .ioma-robot-bubble-text{font-size:13px}
}
CSSEOF
echo "  ✓ Стили обновлены"
echo ""

# ============ 3. Проверка ============
echo "[3/3] Проверяю"
lsof -ti:12000 | xargs kill -9 2>/dev/null
sleep 1

node server.js > /tmp/ioma_r3.log 2>&1 &
PID=$!
sleep 2

FAIL=0
for PAGE in / /dashboard /test /lesson /vocabulary /speaking /listening /writing; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$PAGE")
  [ "$CODE" != "200" ] && FAIL=$((FAIL+1))
done
for ASSET in /robot.js /styles.css; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$ASSET")
  [ "$CODE" != "200" ] && FAIL=$((FAIL+1))
done

kill $PID 2>/dev/null
wait $PID 2>/dev/null

echo ""
echo "============================================"
if [ $FAIL -eq 0 ]; then
  echo "  ✓ РОБОТ v3 ГОТОВ"
  echo "============================================"
  echo ""
  echo "Что изменилось:"
  echo "  • Робот больше НЕ в рамке — самодостаточная фигура"
  echo "  • Нет серого квадрата, нет кнопки"
  echo "  • Стоит на теневом основании (эллипс)"
  echo "  • Дышит, мигает, антенна качается, руки шевелятся"
  echo "  • При появлении — выезжает + подпрыгивает когда рад"
  echo "  • Hover — лёгкий подъём и мягкая тень"
  echo "  • На светлой и тёмной теме читается через drop-shadow"
  echo ""
  echo "Триггеры не менялись (урок/тест/слова/аудио/письмо/речь)"
  echo "Запуск: npm start"
else
  echo "  ⚠ ПРОБЛЕМ: $FAIL"
fi
echo "============================================"
