#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  Робот теперь зовётся IOMA"
echo "============================================"
echo ""

mkdir -p _unused/backup
cp lib/robot.js "_unused/backup/lib_robot.js.$(date +%Y%m%d_%H%M%S)"
cp robot.js "_unused/backup/robot.js.$(date +%Y%m%d_%H%M%S)"
echo "✓ Бэкапы"
echo ""

# ============ 1. lib/robot.js — имя в промпте ============
echo "[1/3] Обновляю имя в lib/robot.js"
python3 << 'PYEOF'
with open('lib/robot.js','r') as f:
    content = f.read()

# Меняем в system-промпте
content = content.replace(
    "Ты — учитель-робот Робо на сайте изучения английского.",
    "Ты — ioma, дружелюбный помощник-робот на сайте изучения английского iomaenglish."
)

# Добавляем правило про имя
content = content.replace(
    "'7. Не упоминай что ты AI.',",
    "'7. Не упоминай что ты AI.',\n        '8. Тебя зовут ioma. Если спросят имя — отвечай \"ioma\".',"
)

# Обновляем нумерацию правил
content = content.replace(
    "'8. Обращайся на \"ты\".',\n        '7.",
    "'9. Обращайся на \"ты\".',\n        '7."
)

# Fallback-сообщения могут начинаться с "Я ioma, ..."
# Обновляем приветствие в fallback — добавим имя
content = content.replace(
    "'/writing': 'Напиши эссе — я проверю и подскажу что улучшить.',",
    "'/writing': 'Привет, я ioma. Напиши эссе — проверю и подскажу.',"
)
content = content.replace(
    "'/lesson': 'Читай правило сверху. Ошибёшься — подскажу.',",
    "'/lesson': 'Я ioma. Читай правило сверху — если ошибёшься, подскажу.',"
)
content = content.replace(
    "'/test': 'Отвечай честно, это не экзамен.',",
    "'/test': 'Привет, я ioma. Отвечай честно — это не экзамен.',"
)
content = content.replace(
    "'/listening': 'Слушай медленно. Переслушать не стыдно.',",
    "'/listening': 'Я ioma. Слушай медленно — переслушать не стыдно.',"
)
content = content.replace(
    "'/speaking': 'Говори громко. Ошибки — это нормально.',",
    "'/speaking': 'Я ioma. Говори громко — ошибки это нормально.',"
)
content = content.replace(
    "'/dashboard': 'Продолжаем с того места, где остановились.'",
    "'/dashboard': 'Я ioma. Продолжаем с того места, где остановились.'"
)
content = content.replace(
    "'auto-error': 'Прочитай правило выше внимательно. Попробуй ещё раз.',",
    "'auto-error': 'Я ioma. Прочитай правило выше — там есть ответ.',"
)
content = content.replace(
    "'auto-test': 'Начни с A1 уроков. По 15 минут в день — через месяц заметишь разницу.',",
    "'auto-test': 'Я ioma. Начни с A1 уроков — по 15 минут в день, и через месяц увидишь результат.',"
)
content = content.replace(
    "'auto-writing': 'Обрати внимание на связки и артикли. Пиши короче.',",
    "'auto-writing': 'Я ioma. Обрати внимание на связки и артикли — пиши короче.',"
)
content = content.replace(
    "'auto-listening': 'Слушай медленную версию несколько раз.'",
    "'auto-listening': 'Я ioma. Слушай медленную версию несколько раз — помогает.'"
)
content = content.replace(
    "reply = fallback.greeting[page] || 'Чем помочь?';",
    "reply = fallback.greeting[page] || 'Привет, я ioma. Чем помочь?';"
)
content = content.replace(
    "else reply = fallback[mode] || 'Чем помочь?';",
    "else reply = fallback[mode] || 'Привет, я ioma. Чем помочь?';"
)

# Лог
content = content.replace(
    "console.log('[robot] /api/robot endpoint registered');",
    "console.log('[robot] ioma (/api/robot) endpoint registered');"
)

with open('lib/robot.js','w') as f:
    f.write(content)
print('  ✓ Имя в промпте и fallback обновлено')
PYEOF
echo ""

# ============ 2. robot.js — aria-label и tip ============
echo "[2/3] Обновляю robot.js"
python3 << 'PYEOF'
with open('robot.js','r') as f:
    content = f.read()

# aria-label для мини-иконки
content = content.replace(
    "miniBtn.setAttribute('aria-label', 'Помощник');",
    "miniBtn.setAttribute('aria-label', 'ioma — помощник');"
)

# Подсказка
content = content.replace(
    "miniTip.textContent = 'Нужна помощь? Нажми';",
    "miniTip.textContent = 'Привет, я ioma. Нажми если нужна помощь';"
)

with open('robot.js','w') as f:
    f.write(content)
print('  ✓ robot.js обновлён')
PYEOF
echo ""

# ============ 3. Проверка + перезапуск ============
echo "[3/3] Проверка + перезапуск"

node -c lib/robot.js 2>/dev/null && echo "  ✓ lib/robot.js валиден" || { echo "  ✗ ОШИБКА в lib/robot.js"; node -c lib/robot.js 2>&1 | head -5; exit 1; }
node -c robot.js 2>/dev/null && echo "  ✓ robot.js валиден" || { echo "  ✗ ОШИБКА в robot.js"; exit 1; }

lsof -ti:12000 2>/dev/null | xargs kill -9 2>/dev/null
pkill -f "node server.js" 2>/dev/null
sleep 1
nohup node server.js > /tmp/ioma_server.log 2>&1 & disown
sleep 3

echo ""
echo "=== Лог ==="
tail -5 /tmp/ioma_server.log
echo ""
echo "=== Тест greeting ==="
curl -s -X POST http://localhost:12000/api/robot \
  -H "Content-Type: application/json" \
  -d '{"mode":"greeting","context":{"page":"/dashboard","level":"A2"}}' | head -c 300
echo ""
echo ""

CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:12000/)
echo "============================================"
if [ "$CODE" = "200" ]; then
  echo "  ✓ ГОТОВО"
  echo "============================================"
  echo ""
  echo "Робота теперь зовут IOMA"
  echo ""
  echo "Что обновлено:"
  echo "  • В системном промпте: 'Ты — ioma, помощник-робот'"
  echo "  • Правило: 'Тебя зовут ioma. Если спросят имя — отвечай ioma.'"
  echo "  • Все fallback-сообщения начинаются с 'Я ioma...'"
  echo "  • Мини-иконка: aria-label 'ioma — помощник'"
  echo "  • Подсказка: 'Привет, я ioma. Нажми если нужна помощь'"
  echo ""
  echo "Cmd+Shift+R"
  echo "Кликни иконку → спроси 'как тебя зовут?' → ответит 'ioma'"
else
  echo "  ⚠ Сервер: $CODE"
fi
