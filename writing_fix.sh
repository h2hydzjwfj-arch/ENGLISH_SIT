#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  Writing: один счётчик, цель по уровню, на весь экран"
echo "============================================"
echo ""

mkdir -p _unused/backup
cp styles.css "_unused/backup/styles.css.$(date +%Y%m%d_%H%M%S)"
[ -f "writing.js" ] && cp writing.js "_unused/backup/writing.js.$(date +%Y%m%d_%H%M%S)"
echo "✓ Бэкапы"
echo ""

# ============ 1. Убираем дублирующие элементы ============
echo "[1/4] Убираю дублирование счётчиков"

cat >> styles.css << 'CSSEOF'

/* ============================================
   WRITING — фикс: один счётчик, без «печатной машинки»
   ============================================ */

/* Убираем мой лишний счётчик (он дублировал существующий) */
.ioma-paper-counter{
  display:none !important;
}

/* Существующий счётчик в HTML — делаем нормальным */
.wrt-meta{
  display:flex !important;
  justify-content:space-between !important;
  align-items:center !important;
  font-family:var(--sans) !important;
  font-size:12px !important;
  color:var(--text-muted) !important;
  margin-top:10px !important;
  padding-top:10px !important;
  border-top:1px solid var(--border) !important;
  text-transform:none !important;
  letter-spacing:0 !important;
  font-weight:500 !important;
}

/* Иконка и стиль «цель» */
.wrt-meta .wrt-goal{
  font-family:var(--mono) !important;
  font-size:11px !important;
  letter-spacing:.06em !important;
  color:var(--text-muted) !important;
  transition:color .2s ease !important;
}
.wrt-meta .wrt-goal.reached{
  color:var(--text) !important;
}
.wrt-meta .wrt-goal.reached::before{
  content:"✓ " !important;
  margin-right:4px;
}

/* ============================================
   WRITING — на весь экран без скролла
   ============================================ */

/* Убираем лишние отступы сверху */
.wrt-shell{
  max-width:min(1680px, 96vw) !important;
  height:calc(100vh - 72px) !important;
  min-height:600px !important;
  padding:20px clamp(24px, 4vw, 56px) 20px !important;
  display:grid !important;
  grid-template-columns:minmax(320px, 380px) 1fr !important;
  grid-template-rows:auto 1fr !important;
  grid-template-areas:
    "head head"
    "left right" !important;
  gap:14px 28px !important;
  overflow:hidden !important;
  box-sizing:border-box !important;
}

.wrt-head{
  grid-area:head !important;
  margin-bottom:0 !important;
  padding-bottom:14px !important;
  border-bottom:1px solid var(--border) !important;
}
.wrt-head h1{
  font-size:clamp(28px, 3vw, 44px) !important;
  margin-bottom:4px !important;
  line-height:1.1 !important;
}
.wrt-head p{
  font-size:13.5px !important;
  line-height:1.5 !important;
  color:var(--text-muted) !important;
  margin:0 !important;
  max-width:100% !important;
}

/* Левая колонка — Task */
.wrt-task{
  grid-area:left !important;
  margin:0 !important;
  padding:20px 22px !important;
  overflow-y:auto !important;
  max-height:100% !important;
}

/* Правая колонка — редактор */
.wrt-editor{
  grid-area:right !important;
  margin:0 !important;
  display:flex !important;
  flex-direction:column !important;
  min-height:0 !important;
}

#wrtInput{
  flex:1 !important;
  min-height:0 !important;
  height:auto !important;
  resize:none !important;
  width:100% !important;
  padding:20px 22px !important;
  font-family:'Courier New','American Typewriter',monospace !important;
  font-size:15.5px !important;
  line-height:1.75 !important;
  border:1px solid var(--border-2) !important;
  background:var(--bg-2) !important;
  color:var(--text) !important;
  outline:none !important;
  transition:border-color .2s ease !important;
}
#wrtInput:focus{
  border-color:var(--text) !important;
}

/* Кнопка «Проверить» и подсказка — под textarea */
.wrt-actions{
  grid-column:2 !important;
  display:flex !important;
  align-items:center !important;
  gap:16px !important;
  margin-top:12px !important;
  margin-bottom:0 !important;
}
.wrt-hint{
  font-family:var(--sans) !important;
  font-style:normal !important;
  font-size:12px !important;
  color:var(--text-muted) !important;
  letter-spacing:0 !important;
}

/* Результат — раскрывается под всем, но со внутренним скроллом */
.wrt-result{
  position:fixed !important;
  top:72px !important;
  left:0 !important;
  right:0 !important;
  bottom:0 !important;
  z-index:200 !important;
  background:var(--bg) !important;
  overflow-y:auto !important;
  padding:32px clamp(24px, 4vw, 56px) 80px !important;
  margin:0 !important;
  animation:rise .3s ease !important;
}

/* Внутри результата — снова ограничим ширину для читаемости */
.wrt-result > *{
  max-width:1000px !important;
  margin-left:auto !important;
  margin-right:auto !important;
}

/* Кнопка закрытия результата (добавим через JS) */
.wrt-result-close{
  position:fixed !important;
  top:84px !important;
  right:24px !important;
  z-index:210 !important;
  width:40px !important;
  height:40px !important;
  background:var(--bg) !important;
  border:1px solid var(--border-2) !important;
  color:var(--text) !important;
  cursor:pointer !important;
  font-size:20px !important;
  line-height:1 !important;
  transition:all .2s ease !important;
}
.wrt-result-close:hover{
  background:var(--text) !important;
  color:var(--bg) !important;
}

/* Мобильные — назад в колонку */
@media (max-width:1024px){
  .wrt-shell{
    height:auto !important;
    grid-template-columns:1fr !important;
    grid-template-areas:
      "head"
      "left"
      "right" !important;
    overflow:visible !important;
  }
  #wrtInput{
    min-height:280px !important;
  }
  .wrt-result{
    position:static !important;
    padding:20px !important;
  }
}

/* Скрываем старое поле «минимум 80 символов» если осталось */
.wrt-meta span:last-child:not(.wrt-goal){
  display:none !important;
}
CSSEOF
echo "  ✓ Стили добавлены"
echo ""

# ============ 2. Убираем счётчик-дубликат из interactions.js ============
echo "[2/4] Убираю мой лишний счётчик из interactions.js"
python3 << 'PYEOF'
with open('interactions.js','r') as f:
    js = f.read()

# Удаляем блок addCounter целиком
import re

# Удаляем функцию addCounter
js = re.sub(
    r'  // Счётчик слов в стиле «сколько напечатано»\n  function addCounter\(textarea\)\{[\s\S]*?\n  \}\n',
    '',
    js
)

# Убираем вызов addCounter(el)
js = js.replace('      addCursor(el);\n      addCounter(el);', '      addCursor(el);')
js = js.replace('        addCursor(el);\n        addCounter(el);', '        addCursor(el);')

with open('interactions.js','w') as f:
    f.write(js)

print('  ✓ Дубликат убран')
PYEOF
echo ""

# ============ 3. writing.js — цель по уровню ============
echo "[3/4] Обновляю writing.js — цель по уровню вместо «80 символов»"
python3 << 'PYEOF'
with open('writing.js','r') as f:
    js = f.read()

# Меняем блок счётчика
old_block = """  ta.addEventListener('input', function(){
    var len = ta.value.length;
    var words = ta.value.trim().split(/\\s+/).filter(Boolean).length;
    counter.textContent = len + ' символов · ' + words + ' слов';
    checkBtn.disabled = len < 80;
  });"""

new_block = """  // Цель по словам в зависимости от уровня (Cambridge / IELTS)
  var WORD_GOALS = {
    'A1': 30, 'A2': 50, 'B1': 100,
    'B2': 150, 'C1': 220, 'C2': 250
  };
  var currentGoal = 100; // по умолчанию B1

  function updateMeta(){
    var text = ta.value || '';
    var len = text.length;
    var words = text.trim().split(/\\s+/).filter(Boolean).length;
    var goal = currentGoal;
    var reached = words >= goal;
    counter.innerHTML = words + ' слов · ' + len + ' знаков';
    // Ищем или создаём span с целью
    var goalEl = counter.parentNode.querySelector('.wrt-goal');
    if (!goalEl){
      goalEl = document.createElement('span');
      goalEl.className = 'wrt-goal';
      counter.parentNode.appendChild(goalEl);
    }
    goalEl.classList.toggle('reached', reached);
    goalEl.textContent = reached ? 'Цель достигнута' : ('Цель: ' + goal + ' слов');
    checkBtn.disabled = words < 20; // минимум 20 слов для проверки
  }

  // Получаем уровень пользователя и обновляем цель
  fetch('/api/me', { credentials:'same-origin' })
    .then(function(r){ return r.json(); })
    .then(function(d){
      if (d && d.ok && d.profile && d.profile.level){
        var lvl = d.profile.level;
        if (WORD_GOALS[lvl]) currentGoal = WORD_GOALS[lvl];
        updateMeta();
      }
    })
    .catch(function(){});

  ta.addEventListener('input', updateMeta);
  updateMeta();"""

if old_block in js:
    js = js.replace(old_block, new_block)
    print('  ✓ Цель по уровню добавлена')
else:
    print('  ⚠ Блок не найден — ищу похожий')
    # Попробуем найти более гибко
    import re
    js = re.sub(
        r'  ta\.addEventListener\(.input., function\(\)\{[\s\S]*?\}\);\n  updateWritingCount\(\);',
        new_block,
        js
    )
    if 'WORD_GOALS' in js:
        print('  ✓ Заменено альтернативно')

with open('writing.js','w') as f:
    f.write(js)
PYEOF
echo ""

# ============ 4. Проверка ============
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
  echo "Что исправлено:"
  echo "  • Убран дубликат счётчика (был второй мой)"
  echo "  • Убрана надпись «ПЕЧАТНАЯ МАШИНКА»"
  echo "  • Убрано «Минимум 80 символов»"
  echo "  • Цель по словам по уровням Cambridge/IELTS:"
  echo "      A1=30, A2=50, B1=100, B2=150, C1=220, C2=250"
  echo "  • Показывается «Цель: N слов» или «✓ Цель достигнута»"
  echo "  • Кнопка «Проверить» включается с 20 слов"
  echo "  • Страница на весь экран (100vh), без скролла"
  echo "  • Textarea растягивается на всю доступную высоту"
  echo "  • Результат открывается на весь экран + кнопка × закрыть"
  echo ""
  echo "Cmd+Shift+R и открой /writing"
else
  echo "  ⚠ Сервер: $CODE"
  tail -15 /tmp/ioma_server.log
fi
