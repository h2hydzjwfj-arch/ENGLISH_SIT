#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  Убираю Google Fonts → системные шрифты"
echo "============================================"
echo ""

mkdir -p _unused/backup
TS=$(date +%Y%m%d_%H%M%S)
cp styles.css "_unused/backup/styles.css.$TS"
echo "✓ Бэкап"
echo ""

# ---------- 1. Убираю @import с Google Fonts ----------
echo "[1/3] Убираю @import Google Fonts"
# Удаляем первую строку с @import url
sed -i.bak "/@import url('https:\/\/fonts.googleapis.com/d" styles.css
rm -f styles.css.bak

# ---------- 2. Заменяю шрифты на системные ----------
echo "[2/3] Заменяю на системные шрифты"
# Заменяем --sans, --serif, --mono
perl -i -pe "s{--sans:'Inter',-apple-system,BlinkMacSystemFont,system-ui,sans-serif;}{--sans:-apple-system,BlinkMacSystemFont,'Segoe UI','Helvetica Neue',Arial,sans-serif;}g" styles.css
perl -i -pe "s{--serif:'Cormorant Garamond',Georgia,serif;}{--serif:Georgia,'Times New Roman',serif;}g" styles.css
perl -i -pe "s{--mono:'JetBrains Mono','SF Mono',Menlo,monospace;}{--mono:'SF Mono',Menlo,Monaco,Consolas,'Courier New',monospace;}g" styles.css

echo "  ✓ Шрифты заменены"
echo ""

# ---------- 3. Проверка ----------
echo "[3/3] Перезапускаю сервер"

# Убиваем старый
lsof -ti:12000 2>/dev/null | xargs kill -9 2>/dev/null
pkill -f "node server.js" 2>/dev/null
sleep 1

# Запускаем в фоне
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
  echo "  • Убран @import Google Fonts (2 внешних запроса)"
  echo "  • Системные шрифты: SF Pro / Segoe UI / Helvetica"
  echo "  • Моно: SF Mono / Menlo / Consolas"
  echo "  • Сериф: Georgia / Times New Roman"
  echo ""
  echo "Открой http://localhost:12000/dashboard"
  echo "Cmd+Shift+R для сброса кэша"
else
  echo "  ⚠ Сервер: $CODE"
  cat /tmp/ioma_server.log
fi
