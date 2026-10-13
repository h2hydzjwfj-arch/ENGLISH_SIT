#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  Шрифт печатной машинки + анимация печати"
echo "============================================"
echo ""

mkdir -p _unused/backup
cp styles.css "_unused/backup/styles.css.$(date +%Y%m%d_%H%M%S)"
echo "✓ Бэкап"
echo ""

# ============ 1. CSS: шрифт + анимация ============
echo "[1/2] Добавляю стили"

cat >> styles.css << 'CSSEOF'

/* ============================================
   ПЕЧАТНАЯ МАШИНКА — для полей где пишут текст
   ============================================ */
:root{
  --typewriter:'Courier New','American Typewriter','PT Mono','Consolas',monospace;
}

/* Все textarea где пишут длинные тексты */
#writingInput,
#wrtInput,
#lstAnswer,
textarea,
input[type=text].write-mode,
.essay-input,
.writing-input{
  font-family:var(--typewriter) !important;
  font-size:16px !important;
  line-height:1.75 !important;
  letter-spacing:.02em !important;
  font-weight:400 !important;
  color:var(--text) !important;
  background:var(--bg-2) !important;
  border:1px solid var(--border-2) !important;
  padding:20px 22px !important;
  caret-color:var(--text) !important;
  transition:border-color .2s var(--ease),background .2s var(--ease) !important;
}

/* Фокус */
#writingInput:focus,
#wrtInput:focus,
#lstAnswer:focus,
textarea:focus{
  border-color:var(--text) !important;
  background:var(--bg) !important;
  outline:none !important;
}

/* Placeholder — как подсказка на печатной машинке */
#writingInput::placeholder,
#wrtInput::placeholder,
#lstAnswer::placeholder,
textarea::placeholder{
  font-family:var(--typewriter) !important;
  font-style:italic !important;
  color:var(--text-dim) !important;
  letter-spacing:.01em !important;
}

/* ============================================
   Мигающий курсор на печатной машинке
   (визуальный псевдо-курсор в правом нижнем углу)
   ============================================ */
.ioma-typewriter-wrap{
  position:relative;
  display:block;
}
.ioma-typewriter-cursor{
  position:absolute;
  bottom:14px;
  right:20px;
  font-family:var(--typewriter);
  font-size:16px;
  color:var(--text);
  pointer-events:none;
  user-select:none;
  opacity:0;
  transition:opacity .2s ease;
  font-weight:400;
}
.ioma-typewriter-cursor.on{
  opacity:.5;
  animation:twBlink 1.1s step-end infinite;
}
.ioma-typewriter-cursor.on::before{
  content:"▍";
}
@keyframes twBlink{
  0%,50%{opacity:.5}
  51%,100%{opacity:.05}
}

/* ============================================
   Анимация печати placeholder (посимвольно)
   ============================================ */
.ioma-typewriter-typing{
  animation:twFadeIn .3s ease-out;
}
@keyframes twFadeIn{
  from{opacity:0}
  to{opacity:1}
}

/* Тонкий звуковой эффект: лёгкое дрожание при печати */
.ioma-typewriter-wrap.typing #writingInput,
.ioma-typewriter-wrap.typing #wrtInput,
.ioma-typewriter-wrap.typing #lstAnswer{
  animation:twShake .04s ease-in-out;
}
@keyframes twShake{
  0%,100%{transform:translate(0,0)}
  50%{transform:translate(.3px,-.3px)}
}

/* ============================================
   Счётчик "бумага" — сколько напечатал
   ============================================ */
.ioma-paper-counter{
  display:flex;
  justify-content:space-between;
  align-items:center;
  font-family:var(--typewriter);
  font-size:11.5px;
  letter-spacing:.06em;
  color:var(--text-muted);
  margin-top:10px;
  padding:6px 2px 0;
  border-top:1px dashed var(--border-2);
  text-transform:uppercase;
}
.ioma-paper-counter span:last-child{
  color:var(--text-dim);
}
CSSEOF
echo "  ✓ Стили добавлены"
echo ""

# ============ 2. JS: анимация печати placeholder + курсор ============
echo "[2/2] Добавляю animations.js — печатная машинка"

cat >> interactions.js << 'TWJSEOF'

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

  // Счётчик слов в стиле «сколько напечатано»
  function addCounter(textarea){
    if (!textarea || textarea.dataset.twCounter) return;
    textarea.dataset.twCounter = '1';

    // Ищем существующий счётчик рядом
    var meta = textarea.parentNode.querySelector('.wrt-meta, .writing-info');
    var counter;
    if (meta){
      // Используем существующий
      counter = meta;
      counter.classList.add('ioma-paper-counter');
    } else {
      counter = document.createElement('div');
      counter.className = 'ioma-paper-counter';
      textarea.parentNode.appendChild(counter);
    }

    function update(){
      var text = textarea.value || '';
      var words = text.trim().split(/\s+/).filter(Boolean).length;
      var chars = text.length;
      counter.innerHTML = '<span>' + words + ' слов · ' + chars + ' знаков</span><span>печатная машинка</span>';
    }
    textarea.addEventListener('input', update);
    update();
  }

  function initTypewriters(){
    Object.keys(PLACEHOLDERS).forEach(function(id){
      var el = document.getElementById(id);
      if (!el) return;
      typewriterPlaceholder(el, PLACEHOLDERS[id]);
      addCursor(el);
      addCounter(el);
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
        addCounter(el);
      }
    });
  });
  mo.observe(document.body, { childList:true, subtree:true });
})();
TWJSEOF
echo "  ✓ interactions.js дополнен"
echo ""

# ============ 3. Проверка ============
echo "[3/3] Перезапуск и проверка"
lsof -ti:12000 2>/dev/null | xargs kill -9 2>/dev/null
pkill -f "node server.js" 2>/dev/null
sleep 1
nohup node server.js > /tmp/ioma_server.log 2>&1 & disown
sleep 2

CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:12000/)
echo ""
if [ "$CODE" = "200" ]; then
  echo "✓ Сервер работает"
  echo ""
  echo "Что сделано:"
  echo "  • Шрифт Courier New в полях: writing, listening, test"
  echo "  • Placeholder печатается посимвольно, потом стирается и печатается снова"
  echo "  • Мигающий курсор ▍ справа внизу textarea при фокусе"
  echo "  • Лёгкая вибрация при печати (эффект пишущей машинки)"
  echo "  • Счётчик 'X слов · Y знаков' под полем — в стиле печатной машинки"
  echo ""
  echo "Обнови браузер Cmd+Shift+R"
  echo "Открой /writing или /listening — увидишь эффект"
else
  echo "⚠ Сервер: $CODE"
  tail -20 /tmp/ioma_server.log
fi
