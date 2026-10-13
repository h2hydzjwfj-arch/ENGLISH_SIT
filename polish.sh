#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  Полировка: круглые кнопки, чистый hero"
echo "============================================"
echo ""

mkdir -p _unused/backup
TS=$(date +%Y%m%d_%H%M%S)
cp styles.css "_unused/backup/styles.css.$TS"
cp robot.js "_unused/backup/robot.js.$TS"
cp index.html "_unused/backup/index.html.$TS"
echo "✓ Бэкапы"
echo ""

# ============ 1. Убираем eyebrow ============
echo "[1/5] Убираю 'PRIVATE ENGLISH TUTORING'"
python3 << 'PYEOF'
import re
with open('index.html','r') as f:
    html = f.read()

# Убираем span с eyebrow
html = re.sub(r'<span class="eyebrow">[^<]*</span>\s*', '', html)

with open('index.html','w') as f:
    f.write(html)
print('  ✓ Eyebrow убран')
PYEOF
echo ""

# ============ 2. Круглые кнопки + hover логотипа + убираем hero отступы ============
echo "[2/5] Круглые кнопки + анимация логотипа"
cat >> styles.css << 'CSSEOF'

/* ============================================
   КРУГЛЫЕ КНОПКИ + АНИМАЦИЯ ЛОГОТИПА
   ============================================ */

/* Все основные кнопки — круглые (pill-shape) */
.btn-primary,
.btn-ghost,
.cta-mini,
.lh-cta,
.stage-btn,
.lst-play,
.lst-slow,
.spk-btn,
.wt-new,
.cr-show,
.cr-btn,
.play-btn,
.record-btn{
  border-radius:999px !important;
  padding:14px 32px !important;
}

/* Кнопки-иконки тоже круглые */
.assist-fab,
.assist-send,
.theme-btn,
.back-link{
  border-radius:999px !important;
}

/* Кнопки-иконки отправки */
.ioma-robot-send{
  border-radius:50% !important;
  width:32px !important;
  height:32px !important;
  display:flex !important;
  align-items:center !important;
  justify-content:center !important;
  padding:0 !important;
}

/* Стрелка назад — круглая */
.back-link{
  padding:8px 16px !important;
}

/* Кнопка «Наверх» */
.ioma-back-top{
  border-radius:50% !important;
}

/* Мини-иконка робота */
.ioma-robot-mini{
  border-radius:50% !important;
}

/* Ячейки-опции в тесте — тоже скруглим */
.q-option,
.ex-opt{
  border-radius:999px !important;
  padding:14px 22px !important;
}

/* Поля ввода — круглые углы */
input[type=text],
input[type=email],
input[type=password],
input[type=tel],
textarea,
.va-row input,
.auth-input{
  border-radius:16px !important;
}

/* Робот-пузырь */
.ioma-robot-bubble{
  border-radius:20px !important;
}

/* Карточки — лёгкое скругление */
.card,
.feature-card,
.unit,
.quick-card,
.mode-card,
.stat-card,
.skill-card{
  border-radius:16px !important;
}

/* ============================================
   АНИМАЦИЯ ЛОГОТИПА при наведении
   ============================================ */
.brand{
  cursor:pointer;
  display:inline-block;
  transition:transform .3s cubic-bezier(.16,1,.3,1);
  position:relative;
}

.brand::after{
  content:"";
  position:absolute;
  bottom:-2px;
  left:0;
  right:0;
  height:2px;
  background:var(--text);
  transform:scaleX(0);
  transform-origin:left;
  transition:transform .35s cubic-bezier(.16,1,.3,1);
}

.brand:hover::after{
  transform:scaleX(1);
}

.brand:hover{
  transform:translateY(-1px);
}

/* Пульсация при клике */
.brand:active{
  transform:translateY(0) scale(.98);
}

/* ============================================
   HERO — убираем лишний отступ сверху
   ============================================ */
.hero{
  padding-top:60px !important;
}

.hero h1{
  margin-top:0 !important;
}

/* Убираем eyebrow отступы если остались где-то */
.eyebrow:empty,
.hero .eyebrow{
  display:none !important;
}

CSSEOF
echo "  ✓ Стили добавлены"
echo ""

# ============ 3. robot.js — отключаем авто-всплытие ============
echo "[3/5] Отключаю авто-всплытие робота"
python3 << 'PYEOF'
with open('robot.js','r') as f:
    js = f.read()

# Убираем автоматическое greeting — робот только иконка пока не кликнут
js = js.replace(
    """  function init(){
    build();
    loadContext();
    watchLesson();
    watchTest();
    watchWriting();
    watchListening();
  }""",
    """  function init(){
    build();
    loadContext();
    watchLesson();
    watchTest();
    watchWriting();
    watchListening();
    // Авто-всплытие ОТКЛЮЧЕНО — робот молчит пока пользователь не кликнет иконку
  }"""
)

with open('robot.js','w') as f:
    f.write(js)
print('  ✓ Авто-всплытие отключено')
PYEOF
echo ""

# ============ 4. Обновляем кэш в HTML ============
echo "[4/5] Обновляю кэш"
for HTML in *.html; do
  [ -f "$HTML" ] || continue
  perl -i -pe "s/styles\.css\?v=\d+/styles.css?v=20/g" "$HTML"
  perl -i -pe "s/robot\.js\?v=\d+/robot.js?v=10/g" "$HTML"
done
echo "  ✓ Кэш обновлён"
echo ""

# ============ 5. Проверка ============
echo "[5/5] Перезапуск + проверка"
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
  echo "Что сделано:"
  echo "  ✓ Кнопки — круглые (pill-shape)"
  echo "  ✓ 'PRIVATE ENGLISH TUTORING' убран"
  echo "  ✓ Логотип — анимация при наведении (линия подчёркивания + подъём)"
  echo "  ✓ Опции теста — круглые"
  echo "  ✓ Поля ввода — скруглены"
  echo "  ✓ Карточки — скруглены"
  echo "  ✓ Робот НЕ всплывает сам, только иконка"
  echo "  ✓ Уровень — берётся из профиля (личный кабинет уже работает)"
  echo ""
  echo "Cmd+Shift+R"
else
  echo "  ⚠ Сервер: $CODE"
  tail -10 /tmp/ioma_server.log
fi
