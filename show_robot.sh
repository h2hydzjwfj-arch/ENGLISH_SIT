#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  Убираю ИИ-ассистента + показываю робота"
echo "============================================"
echo ""

mkdir -p _unused/backup
TS=$(date +%Y%m%d_%H%M%S)
cp styles.css "_unused/backup/styles.css.$TS"
cp robot.js "_unused/backup/robot.js.$TS"
echo "✓ Бэкапы"
echo ""

# ---------- 1. Скрываю ИИ-ассистента ----------
echo "[1/4] Скрываю ИИ-ассистента (кнопку + окно)"
cat >> styles.css << 'CSSEOF'

/* ============================================
   УБИРАЮ ИИ-ассистента полностью
   ============================================ */
.assist-fab,
.assist-overlay,
#assistFab,
#assistOverlay{
  display:none !important;
  visibility:hidden !important;
  pointer-events:none !important;
}
CSSEOF
echo "  ✓ Скрыт в CSS"
echo ""

# ---------- 2. Разрешаю робота на дашборде ----------
echo "[2/4] Разрешаю робота на дашборде"
python3 << 'PYEOF'
with open('robot.js','r') as f:
    content = f.read()

# Обновляем список страниц где робот разрешён
if "SHOW_ONLY_ON" in content:
    import re
    content = re.sub(
        r"var SHOW_ONLY_ON = \[[^\]]*\];",
        "var SHOW_ONLY_ON = ['/', '/dashboard', '/lesson', '/test', '/vocabulary', '/listening', '/writing', '/speaking'];",
        content
    )
    with open('robot.js','w') as f:
        f.write(content)
    print('  ✓ Робот разрешён на /, /dashboard')
else:
    print('  ⚠ Блок SHOW_ONLY_ON не найден')
PYEOF
echo ""

# ---------- 3. Робот приветствует на дашборде ----------
echo "[3/4] Робот приветствует на всех страницах"
python3 << 'PYEOF'
with open('robot.js','r') as f:
    content = f.read()

# Добавляем приветствие при загрузке на любой разрешённой странице
if '__iomaRobotGreeting' not in content:
    marker = "  function init(){"
    greeting_code = """  // Приветствие при первом заходе на страницу
  var _greeted = false;
  function greetOnce(){
    if (_greeted) return;
    _greeted = true;
    setTimeout(function(){
      var p = location.pathname;
      var msg;
      if (p === '/' || p === '/index.html') msg = 'Привет! Я твой учитель-робот. Начнём с теста?';
      else if (p === '/dashboard') msg = 'Рад видеть! Продолжаем с того места, где остановились.';
      else if (p === '/lesson') msg = 'Читай правило внимательно. Я подскажу, если ошибешься.';
      else if (p === '/test') msg = 'Не переживай. Это диагностика, а не экзамен.';
      else if (p === '/vocabulary') msg = 'Повторяй карточки каждый день — так запоминается.';
      else if (p === '/listening') msg = 'Слушай медленно. Можешь переслушать.';
      else if (p === '/speaking') msg = 'Говори громко и не бойся ошибаться.';
      else if (p === '/writing') msg = 'Пиши свободно. Я помогу с проверкой.';
      else msg = 'Привет! Я здесь, если понадоблюсь.';
      say(msg, { state:'thinking', duration:9000 });
    }, 800);
  }

  function init(){"""
    content = content.replace(marker, greeting_code, 1)

    # Вызываем greetOnce в конце init
    old_init_end = """    initWritingWatcher();
    initSpeakingWatcher();
  }"""
    new_init_end = """    initWritingWatcher();
    initSpeakingWatcher();
    greetOnce();
  }"""
    content = content.replace(old_init_end, new_init_end)
    with open('robot.js','w') as f:
        f.write(content)
    print('  ✓ Приветствие добавлено')
else:
    print('  ✓ Уже добавлено')
PYEOF
echo ""

# ---------- 4. Перезапуск ----------
echo "[4/4] Перезапускаю сервер"
lsof -ti:12000 2>/dev/null | xargs kill -9 2>/dev/null
pkill -f "node server.js" 2>/dev/null
sleep 1

nohup node server.js > /tmp/ioma_server.log 2>&1 & disown
sleep 2

CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:12000/)
echo ""
echo "============================================"
if [ "$CODE" = "200" ]; then
  echo "  ✓ ГОТОВО — сервер работает"
  echo "============================================"
  echo ""
  echo "Что изменилось:"
  echo "  • ИИ-ассистент полностью скрыт (кнопка + окно)"
  echo "  • Робот разрешён на: /, /dashboard, /lesson,"
  echo "     /test, /vocabulary, /listening, /writing, /speaking"
  echo "  • Робот выезжает через 800 мс и говорит приветствие"
  echo "     для каждой страницы своё"
  echo ""
  echo "Открой http://localhost:12000/dashboard"
  echo "Cmd+Shift+R — робот появится через секунду"
else
  echo "  ⚠ Сервер: $CODE"
  cat /tmp/ioma_server.log
fi
