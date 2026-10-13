#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  РОБОТ-ДРУГ"
echo "============================================"
echo ""

mkdir -p _unused/backup
TS=$(date +%Y%m%d_%H%M%S)
cp styles.css "_unused/backup/styles.css.$TS"
cp server.js "_unused/backup/server.js.$TS"
echo "✓ Бэкапы"
echo ""

# ============ 1. robot.js ============
echo "[1/5] Создаю robot.js"
cat > robot.js << 'ROBOTJSEOF'
(function(){
  if (window.__iomaRobot) return;
  window.__iomaRobot = true;

  // ---------- СОСТОЯНИЯ ----------
  var STATE = { IDLE:'idle', HAPPY:'happy', SAD:'sad', THINKING:'thinking' };

  // ---------- SVG РОБОТ ----------
  function robotSVG(){
    return ''
      + '<svg class="ioma-robot-svg" viewBox="0 0 80 96" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">'
      // антенна
      + '<line class="ant" x1="40" y1="14" x2="40" y2="4" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>'
      + '<circle class="ant-dot" cx="40" cy="4" r="3.5" fill="currentColor"/>'
      // голова
      + '<rect x="10" y="14" width="60" height="54" rx="8" fill="none" stroke="currentColor" stroke-width="2.2"/>'
      // глаза
      + '<circle class="eye left"  cx="28" cy="36" r="4.2" fill="currentColor"/>'
      + '<circle class="eye right" cx="52" cy="36" r="4.2" fill="currentColor"/>'
      // рот (меняется)
      + '<path class="mouth" d="M28 50 L52 50" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/>'
      // шея
      + '<line x1="40" y1="68" x2="40" y2="76" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>'
      // тело
      + '<rect x="24" y="76" width="32" height="14" rx="4" fill="none" stroke="currentColor" stroke-width="2.2"/>'
      // руки (маленькие точки по бокам тела)
      + '<circle cx="20" cy="83" r="2.5" fill="currentColor"/>'
      + '<circle cx="60" cy="83" r="2.5" fill="currentColor"/>'
      + '</svg>';
  }

  // ---------- СОЗДАНИЕ DOM ----------
  var root, bubble, bubbleText, bubbleClose, hideTimer, sayTimer;

  function build(){
    if (document.getElementById('iomaRobotRoot')) return;

    root = document.createElement('div');
    root.id = 'iomaRobotRoot';
    root.className = 'ioma-robot-root';
    root.setAttribute('aria-hidden', 'false');

    bubble = document.createElement('div');
    bubble.className = 'ioma-robot-bubble';
    bubble.innerHTML = ''
      + '<button class="ioma-robot-bubble-close" aria-label="Закрыть">×</button>'
      + '<div class="ioma-robot-bubble-text"></div>'
      + '<button class="ioma-robot-bubble-ask">Спросить учителя →</button>';
    bubbleText = bubble.querySelector('.ioma-robot-bubble-text');
    bubbleClose = bubble.querySelector('.ioma-robot-bubble-close');

    var avatar = document.createElement('button');
    avatar.className = 'ioma-robot-avatar';
    avatar.setAttribute('aria-label', 'Робот-помощник');
    avatar.innerHTML = robotSVG();

    root.appendChild(bubble);
    root.appendChild(avatar);
    document.body.appendChild(root);

    // ---------- События ----------
    avatar.addEventListener('click', function(){
      var b = bubble.classList.contains('show');
      if (b){ hideBubble(); }
      else { say(lastMessage || greetingForPage(), 8000); }
    });

    bubbleClose.addEventListener('click', function(e){
      e.stopPropagation();
      hideBubble();
    });

    bubble.querySelector('.ioma-robot-bubble-ask').addEventListener('click', function(e){
      e.stopPropagation();
      hideBubble();
      // Открываем AI Tutor (кнопка уже есть на странице)
      var fab = document.getElementById('assistFab');
      if (fab) fab.click();
    });
  }

  // ---------- СОСТОЯНИЕ ----------
  function setState(state){
    if (!root) return;
    root.setAttribute('data-state', state);
    var mouth = root.querySelector('.mouth');
    if (mouth){
      if (state === STATE.HAPPY){
        mouth.setAttribute('d', 'M28 48 Q40 56 52 48');
      } else if (state === STATE.SAD){
        mouth.setAttribute('d', 'M28 54 Q40 47 52 54');
      } else if (state === STATE.THINKING){
        mouth.setAttribute('d', 'M28 51 Q34 47 40 51 Q46 55 52 51');
      } else {
        mouth.setAttribute('d', 'M28 50 L52 50');
      }
    }
  }

  // ---------- СООБЩЕНИЕ ----------
  var lastMessage = '';
  function say(text, duration){
    if (!root || !text) return;
    lastMessage = text;
    if (bubbleText) bubbleText.textContent = text;
    bubble.classList.add('show');
    setState(STATE.HAPPY);
    clearTimeout(hideTimer);
    clearTimeout(sayTimer);
    if (duration){
      hideTimer = setTimeout(hideBubble, duration);
    } else {
      hideTimer = setTimeout(hideBubble, 7000);
    }
    // вернуть в idle через 4 секунды
    sayTimer = setTimeout(function(){ setState(STATE.IDLE); }, 4000);
  }

  function hideBubble(){
    if (!bubble) return;
    bubble.classList.remove('show');
  }

  window.robotSay = say;
  window.robotState = setState;

  // ---------- ПРИВЕТСТВИЕ ПО СТРАНИЦАМ ----------
  function greetingForPage(){
    var p = location.pathname;
    if (p === '/' || p === '/index.html') return 'Привет! Я помогу тебе учиться. Начнём с теста?';
    if (p === '/dashboard') return 'Рад видеть! Готов к новому уроку?';
    if (p === '/test') return 'Не переживай. Это диагностика, а не экзамен.';
    if (p === '/lesson') return 'Читай правило внимательно. Я подскажу, если ошибёшься.';
    if (p === '/listening') return 'Слушай медленно. Можешь переслушать несколько раз.';
    if (p === '/speaking') return 'Говори громко и не бойся ошибаться.';
    if (p === '/writing') return 'Пиши свободно. Я помогу с проверкой.';
    if (p === '/vocabulary') return 'Повторяй карточки каждый день. Так запоминается.';
    if (p === '/login' || p === '/register') return 'Заходи! Твой прогресс сохранится.';
    if (p === '/profile') return 'Вот твои успехи. Растёшь!';
    return 'Привет! Если нужна помощь — жми на меня.';
  }

  // ---------- РЕАКЦИЯ НА ОШИБКИ В УРОКАХ ----------
  function attachLessonWatcher(){
    if (location.pathname !== '/lesson') return;
    // Наблюдаем за появлением комментариев после ответа
    var mo = new MutationObserver(function(muts){
      muts.forEach(function(m){
        if (m.type !== 'attributes' || m.attributeName !== 'class') return;
        var el = m.target;
        if (!el.classList.contains('ex-comment')) return;
        if (!el.classList.contains('show')) return;
        var text = (el.textContent || '').trim();
        if (text.indexOf('✗') === 0 || text.indexOf('✕') === 0 || text.indexOf('Неверно') !== -1 || text.indexOf('Correct answer') !== -1){
          setState(STATE.SAD);
          say('Не спеши. Прочитай правило сверху — там есть ответ.', 6000);
        } else if (text.indexOf('✓') === 0 || text.indexOf('Правильно') !== -1 || text.indexOf('Correct') === 0){
          setState(STATE.HAPPY);
        }
      });
    });
    mo.observe(document.body, { attributes:true, subtree:true, attributeFilter:['class'] });
  }

  // ---------- ПОЯВЛЕНИЕ ----------
  function appear(){
    build();
    // Появление через 1.2 сек
    setTimeout(function(){
      if (!root) return;
      root.classList.add('in');
      // кивает
      setTimeout(function(){
        setState(STATE.HAPPY);
        setTimeout(function(){ setState(STATE.IDLE); }, 1800);
      }, 700);
      // Первое приветствие через 2.5 сек
      setTimeout(function(){
        say(greetingForPage(), 6500);
      }, 1800);
    }, 1200);
  }

  // ---------- INIT ----------
  function init(){
    if (document.readyState === 'loading'){
      document.addEventListener('DOMContentLoaded', function(){
        appear();
        attachLessonWatcher();
      });
    } else {
      appear();
      attachLessonWatcher();
    }
  }
  init();
})();
ROBOTJSEOF
echo "  ✓ robot.js готов ($(wc -l < robot.js) строк)"
echo ""

# ============ 2. Стили ============
echo "[2/5] Добавляю стили робота"
cat >> styles.css << 'CSSEOF'

/* ============================================
   РОБОТ-ДРУГ
   ============================================ */
.ioma-robot-root{
  position:fixed;
  right:28px;
  bottom:28px;
  z-index:250;
  pointer-events:none;
  display:flex;
  flex-direction:column;
  align-items:flex-end;
  gap:14px;
}
.ioma-robot-root > *{pointer-events:auto}

/* --- Аватар --- */
.ioma-robot-avatar{
  width:76px;
  height:92px;
  background:var(--bg);
  border:1px solid var(--border-2);
  color:var(--text);
  padding:8px;
  cursor:pointer;
  display:flex;
  align-items:center;
  justify-content:center;
  transition:all .3s var(--ease);
  transform:translateY(140%);
  opacity:0;
  border-radius:0;
}
.ioma-robot-root.in .ioma-robot-avatar{
  transform:translateY(0);
  opacity:1;
  animation:robotEntrance .9s cubic-bezier(.16,1,.3,1) both;
}
.ioma-robot-avatar:hover{
  border-color:var(--text);
  background:var(--bg-2);
}
.ioma-robot-avatar:active{transform:translateY(2px)}

@keyframes robotEntrance{
  0%{transform:translateY(120%) scale(.9);opacity:0}
  60%{transform:translateY(-6%) scale(1.02);opacity:1}
  80%{transform:translateY(2%) scale(.99)}
  100%{transform:translateY(0) scale(1)}
}

.ioma-robot-svg{
  width:100%;
  height:100%;
  color:var(--text);
  overflow:visible;
}

/* Антенна — качается */
.ioma-robot-svg .ant-dot{
  transform-origin:40px 14px;
  animation:antBounce 2.8s ease-in-out infinite;
}
@keyframes antBounce{
  0%,100%{transform:translateY(0)}
  50%{transform:translateY(-2px)}
}

/* Глаза мигают */
.ioma-robot-svg .eye{
  transform-origin:center;
  animation:eyeBlink 5s ease-in-out infinite;
}
.ioma-robot-svg .eye.right{animation-delay:.08s}
@keyframes eyeBlink{
  0%,92%,100%{transform:scaleY(1)}
  94%,96%{transform:scaleY(.15)}
}

/* Рот — плавная смена */
.ioma-robot-svg .mouth{
  transition:d .4s var(--ease);
}

/* Состояние THINKING */
.ioma-robot-root[data-state="thinking"] .ioma-robot-svg .ant-dot{
  animation:antBounce .7s ease-in-out infinite;
}
.ioma-robot-root[data-state="thinking"] .ioma-robot-svg .eye{
  animation:eyeBlink .8s ease-in-out infinite;
}

/* Состояние SAD — антенна опущена */
.ioma-robot-root[data-state="sad"] .ioma-robot-svg .ant-dot{
  transform:translateY(3px);
  animation:none;
}

/* Состояние HAPPY — быстрый bounce */
.ioma-robot-root[data-state="happy"] .ioma-robot-avatar{
  animation:robotNod .6s ease-out;
}
@keyframes robotNod{
  0%,100%{transform:translateY(0)}
  40%{transform:translateY(-4px)}
}

/* --- Bubble (подсказка) --- */
.ioma-robot-bubble{
  position:relative;
  max-width:320px;
  background:var(--text);
  color:var(--bg);
  padding:20px 22px 18px;
  opacity:0;
  transform:translateY(14px) scale(.96);
  transform-origin:bottom right;
  transition:all .35s cubic-bezier(.16,1,.3,1);
  pointer-events:none;
  border:1px solid var(--text);
}
.ioma-robot-bubble.show{
  opacity:1;
  transform:none;
  pointer-events:auto;
}
.ioma-robot-bubble::after{
  content:"";
  position:absolute;
  right:28px;
  bottom:-8px;
  width:14px;
  height:14px;
  background:var(--text);
  transform:rotate(45deg);
  border-right:1px solid var(--text);
  border-bottom:1px solid var(--text);
}
.ioma-robot-bubble-text{
  font-family:var(--sans);
  font-size:14px;
  line-height:1.55;
  font-weight:500;
  padding-right:22px;
  letter-spacing:-.005em;
}
.ioma-robot-bubble-close{
  position:absolute;
  top:8px;
  right:10px;
  width:24px;
  height:24px;
  background:transparent;
  border:none;
  color:var(--bg);
  font-size:20px;
  line-height:1;
  cursor:pointer;
  opacity:.6;
  transition:opacity .2s;
  padding:0;
}
.ioma-robot-bubble-close:hover{opacity:1}
.ioma-robot-bubble-ask{
  display:inline-block;
  margin-top:14px;
  padding:8px 0;
  background:transparent;
  border:none;
  border-bottom:1px solid var(--bg);
  color:var(--bg);
  font-family:var(--mono);
  font-size:11px;
  font-weight:600;
  letter-spacing:.1em;
  text-transform:uppercase;
  cursor:pointer;
  transition:all .2s;
}
.ioma-robot-bubble-ask:hover{
  letter-spacing:.14em;
}

/* --- Мобильные --- */
@media(max-width:820px){
  .ioma-robot-root{
    right:16px;
    bottom:16px;
    gap:10px;
  }
  .ioma-robot-avatar{
    width:64px;
    height:78px;
    padding:6px;
  }
  .ioma-robot-bubble{
    max-width:260px;
    padding:16px 18px 14px;
  }
  .ioma-robot-bubble-text{font-size:13px}
}

/* Убедимся, что робот не мешает другим элементам */
@media(max-width:820px){
  .ioma-back-top{bottom:110px}
}
CSSEOF
echo "  ✓ Стили добавлены"
echo ""

# ============ 3. Роут в server.js ============
echo "[3/5] Добавляю роут /robot.js"
if ! grep -q "'/robot.js'" server.js; then
  awk '
    /\/interactions\.js.*interactions\.js/ && !done {
      print
      print "  '\''/robot.js'\'': '\''robot.js'\'',"
      done = 1
      next
    }
    { print }
  ' server.js > server.js.new && mv server.js.new server.js
fi
if node -c server.js 2>/dev/null; then
  echo "  ✓ server.js валиден"
else
  echo "  ✗ ОШИБКА"
  exit 1
fi
echo ""

# ============ 4. Подключение в HTML ============
echo "[4/5] Подключаю robot.js во все HTML"
for HTML in *.html; do
  [ -f "$HTML" ] || continue
  if grep -q 'robot.js' "$HTML"; then continue; fi
  sed -i.bak 's|</body>|<script src="/robot.js?v=1" defer></script>\n</body>|' "$HTML"
  rm -f "$HTML.bak"
  echo "  → $HTML"
done
echo ""

# ============ 5. Проверка ============
echo "[5/5] Проверяю"
lsof -ti:12000 | xargs kill -9 2>/dev/null
sleep 1

node server.js > /tmp/ioma_robot.log 2>&1 &
PID=$!
sleep 2

FAIL=0
for PAGE in / /dashboard /test /lesson /login /register /profile /vocabulary /speaking /listening /writing; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$PAGE")
  [ "$CODE" != "200" ] && echo "  ✗ $PAGE → $CODE" && FAIL=$((FAIL+1))
done
for ASSET in /robot.js /styles.css /interactions.js; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$ASSET")
  [ "$CODE" != "200" ] && echo "  ✗ $ASSET → $CODE" && FAIL=$((FAIL+1))
done

kill $PID 2>/dev/null
wait $PID 2>/dev/null

echo ""
echo "============================================"
if [ $FAIL -eq 0 ]; then
  echo "  ✓ РОБОТ ГОТОВ"
  echo "============================================"
  echo ""
  echo "Что появилось:"
  echo "  • Геометричный SVG-робот в правом нижнем углу"
  echo "  • Появление через 1.2 сек — выезжает снизу с кивком"
  echo "  • Мигает глазами, антенна качается"
  echo "  • Через 1.8 сек появляется приветствие (пузырь)"
  echo "  • Клик на робота — повторить текущую подсказку"
  echo "  • Клик на × — закрыть пузырь"
  echo "  • Кнопка 'Спросить учителя →' открывает AI Tutor"
  echo "  • В уроках: реагирует на ответы"
  echo "     — правильный: улыбается"
  echo "     — неправильный: грустит + подсказка 'Прочитай правило сверху'"
  echo ""
  echo "Запуск: npm start"
else
  echo "  ⚠ ПРОБЛЕМ: $FAIL"
  echo "  Лог: /tmp/ioma_robot.log"
fi
echo "============================================"
