#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  TTS только там, где нужно"
echo "============================================"
echo ""

mkdir -p _unused/backup
TS=$(date +%Y%m%d_%H%M%S)
[ -f "tts.js" ] && cp "tts.js" "_unused/backup/tts.js.$TS"
echo "✓ Бэкап"
echo ""

# ---------- 1. tts.js — пустой (глобальная кнопка не нужна) ----------
echo "[1/3] Отключаю глобальную кнопку"
cat > tts.js << 'TTSJSEOF'
(function(){
  // Глобальная кнопка "Озвучить" убрана.
  // Озвучка работает только через inline-кнопки 🔊 рядом с английским текстом.
  // Их создаёт interactions.js на страницах:
  //   /lesson, /listening, /test
  window.__iomaTTS2 = { disabled: true };
})();
TTSJSEOF
echo "  ✓ tts.js отключён"
echo ""

# ---------- 2. Стили: убираю кнопку из топбара если осталась ----------
echo "[2/3] Убираю стили глобальной кнопки"
cat >> styles.css << 'CSSEOF'

/* ============================================
   УБИРАЮ глобальную кнопку озвучки из топбара
   ============================================ */
.ioma-tts-btn,
#iomaPlayBtn,
#iomaStopBtn,
.ioma-gender-select,
.ioma-tts-stop,
#iomaGenderSelect{
  display:none !important;
}
CSSEOF
echo "  ✓ Стили обновлены"
echo ""

# ---------- 3. Проверка ----------
echo "[3/3] Проверяю"
lsof -ti:12000 | xargs kill -9 2>/dev/null
sleep 1

node server.js > /tmp/ioma_targeted.log 2>&1 &
PID=$!
sleep 2

FAIL=0
for PAGE in / /dashboard /test /lesson /listening /vocabulary; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$PAGE")
  [ "$CODE" != "200" ] && echo "  ✗ $PAGE → $CODE" && FAIL=$((FAIL+1))
done
for ASSET in /tts.js /interactions.js /styles.css; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$ASSET")
  [ "$CODE" != "200" ] && echo "  ✗ $ASSET → $CODE" && FAIL=$((FAIL+1))
done

kill $PID 2>/dev/null
wait $PID 2>/dev/null

echo ""
echo "============================================"
if [ $FAIL -eq 0 ]; then
  echo "  ✓ ГОТОВО"
  echo "============================================"
  echo ""
  echo "Теперь 🔊-кнопки появляются только:"
  echo "  • /lesson — рядом с английскими примерами в упражнениях"
  echo "  • /listening — рядом с текстом аудирования"
  echo "  • /test — рядом с вопросами теста"
  echo ""
  echo "На дашборде, главной, профиле — никаких кнопок озвучки."
  echo ""
  echo "Запуск: npm start"
else
  echo "  ⚠ ПРОБЛЕМ: $FAIL"
fi
echo "============================================"
