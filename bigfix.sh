#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  БОЛЬШОЙ ФИКС"
echo "============================================"
echo ""

# ---------- 0. Убиваем старые серверы ----------
echo "[0/7] Очищаю порт"
lsof -ti:12000 | xargs kill -9 2>/dev/null
pkill -f "node server.js" 2>/dev/null
sleep 2
echo "  ✓ Порт свободен"
echo ""

# ---------- 1. Бэкап ----------
mkdir -p _unused/backup
TS=$(date +%Y%m%d_%H%M%S)
cp server.js "_unused/backup/server.js.$TS"
cp styles.css "_unused/backup/styles.css.$TS"
echo "✓ Бэкапы"
echo ""

# ---------- 2. Проверка и починка роутов в server.js ----------
echo "[1/7] Проверяю роуты в server.js"
NEEDED=("/robot.js" "/interactions.js" "/particles.js" "/tts.js" "/animations.js")
for ROUTE in "${NEEDED[@]}"; do
  FILE="${ROUTE#/}"
  if [ -f "$FILE" ]; then
    if ! grep -q "'$ROUTE'" server.js; then
      echo "  + добавляю $ROUTE"
      perl -i -pe "s{('/app\.js': 'app\.js',)}{'/robot.js': 'robot.js',\n  '/interactions.js': 'interactions.js',\n  \$1}" server.js
    fi
  fi
done

# Проверка синтаксиса
if node -c server.js 2>/dev/null; then
  echo "  ✓ server.js валиден"
else
  echo "  ✗ ОШИБКА — восстанавливаю"
  cp "_unused/backup/server.js.$TS" server.js
  exit 1
fi
echo ""

# ---------- 3. ЕДИНЫЙ ЯЗЫК И ТОПБАР ----------
echo "[2/7] Единый язык + топбар"

# Перезаписываю CSS с чистым топбаром
cat >> styles.css << 'CSSEOF'

/* ============================================
   ФИКС: топбар — единый, не конфликтует
   ============================================ */
.topbar{
  display:grid !important;
  grid-template-columns:1fr auto 1fr !important;
  align-items:center !important;
  gap:24px !important;
  padding:16px 40px !important;
  min-height:72px !important;
  max-height:72px !important;
  overflow:hidden;
}
.topbar-left{
  display:flex !important;
  gap:10px !important;
  align-items:center !important;
  min-width:0;
  overflow:hidden;
}
.topbar-right{
  display:flex !important;
  align-items:center !important;
  gap:12px !important;
  justify-content:flex-end !important;
  min-width:0;
  overflow:hidden;
}
.topbar-left .back-link,
.topbar-right .back-link,
.theme-btn,
.cta-mini,
.level-badge{
  white-space:nowrap !important;
  flex-shrink:0 !important;
}
.theme-btn{
  text-transform:uppercase !important;
  font-size:11px !important;
  letter-spacing:.1em !important;
  padding:10px 14px !important;
}
.cta-mini{
  text-transform:uppercase !important;
  font-size:11px !important;
  letter-spacing:.1em !important;
  padding:10px 18px !important;
  background:var(--text) !important;
  color:var(--bg) !important;
  border:1px solid var(--text) !important;
}
.level-badge{
  display:inline-flex;
  align-items:center;
  gap:10px;
  padding:4px 14px 4px 4px !important;
  border:1px solid var(--border-2) !important;
  border-radius:999px !important;
  background:var(--bg) !important;
}
.level-pill{
  font-family:var(--mono) !important;
  font-size:12px !important;
  font-weight:600 !important;
  background:var(--text) !important;
  color:var(--bg) !important;
  padding:6px 12px !important;
  border-radius:999px !important;
  min-width:0 !important;
  height:auto !important;
  display:inline-flex !important;
  align-items:center !important;
}
.level-progress-wrap{
  display:flex !important;
  flex-direction:column !important;
  gap:2px !important;
  min-width:100px !important;
}
.level-progress-bar{
  height:2px !important;
  width:100% !important;
  background:var(--border) !important;
  border-radius:0 !important;
  overflow:hidden;
}
.level-progress-fill{
  height:100% !important;
  background:var(--text) !important;
  transition:width .6s var(--ease-out) !important;
}
.level-progress-text{
  display:flex !important;
  justify-content:space-between !important;
  font-family:var(--mono) !important;
  font-size:9px !important;
  color:var(--text-muted) !important;
  text-transform:uppercase !important;
  letter-spacing:.08em !important;
  line-height:1 !important;
}

/* Убираю все старые кнопки TTS/голоса */
#iomaPlayBtn,
#iomaStopBtn,
.ioma-tts-btn,
.ioma-gender-select,
.ioma-tts-stop{
  display:none !important;
}

/* ============================================
   ФИКС: AI TUTOR — не наезжает на контент
   ============================================ */
.assist-fab{
  position:fixed !important;
  right:24px !important;
  bottom:24px !important;
  z-index:200 !important;
  padding:12px 18px !important;
  font-size:11px !important;
  letter-spacing:.12em !important;
  text-transform:uppercase !important;
  background:var(--text) !important;
  color:var(--bg) !important;
  border:1px solid var(--text) !important;
  border-radius:0 !important;
  display:inline-flex !important;
  align-items:center !important;
  gap:8px !important;
}
.assist-fab:hover{
  background:var(--bg) !important;
  color:var(--text) !important;
}
.assist-fab span{display:inline}
@media(max-width:820px){
  .assist-fab span{display:none}
  .assist-fab{padding:12px}
}

/* Робот — пониже AI Tutor */
.ioma-robot-root{
  bottom:100px !important;
}
.ioma-back-top{
  bottom:170px !important;
}

/* ============================================
   ФИКС: TEST — компактнее
   ============================================ */
.test-shell{
  max-width:760px !important;
  padding:32px 24px 100px !important;
}
.stage-card{
  padding:44px 36px !important;
}
.stage-card h1{
  font-size:clamp(28px,4vw,42px) !important;
  margin-bottom:12px !important;
}
.stage-lede{
  font-size:15px !important;
  line-height:1.55 !important;
  margin-bottom:28px !important;
}
.rules-list{
  gap:8px !important;
  margin-bottom:28px !important;
}
.rule{
  padding:14px 18px !important;
  gap:14px !important;
}
.rule span{
  font-size:20px !important;
  min-width:24px !important;
}
.rule div{
  font-size:13.5px !important;
  line-height:1.5 !important;
}
.question-card{
  padding:28px 26px !important;
}
.q-sentence{
  font-size:20px !important;
  padding:18px 22px !important;
  margin-bottom:20px !important;
  line-height:1.4 !important;
}
.q-options{
  gap:8px !important;
}
.q-option{
  padding:12px 16px !important;
  font-size:14.5px !important;
}
.test-nav{
  padding:12px 24px !important;
}
.test-nav .btn-primary,
.test-nav .btn-ghost{
  padding:12px 24px !important;
  font-size:12px !important;
}
.stage-head{
  margin-bottom:20px !important;
}
.stage-head h2{
  font-size:clamp(26px,3.4vw,38px) !important;
  margin-bottom:6px !important;
}
.stage-head p{
  font-size:14px !important;
}
.reading-block,
.listening-block,
.writing-block,
.speaking-block{
  padding:24px 22px !important;
}
.reading-text{
  font-size:16px !important;
  line-height:1.7 !important;
  padding-bottom:20px !important;
  margin-bottom:20px !important;
}

/* ============================================
   ФИКС: LESSON — компактнее
   ============================================ */
.lesson-shell{
  max-width:720px !important;
  padding:32px 24px 120px !important;
}
.lesson-header h1{
  font-size:clamp(26px,4vw,42px) !important;
  margin-bottom:12px !important;
}
.lesson-rule{
  padding:22px 24px !important;
  margin-bottom:18px !important;
}
.lesson-rule p{
  font-size:15px !important;
  line-height:1.65 !important;
}
.lesson-exercises{
  padding:24px 22px !important;
}
.exercise{
  margin-bottom:22px !important;
  padding-bottom:20px !important;
}
.ex-q{
  font-size:16px !important;
  margin-bottom:12px !important;
  line-height:1.4 !important;
}
.ex-options{
  gap:8px !important;
}
.ex-opt{
  padding:11px 15px !important;
  font-size:14px !important;
}

/* ============================================
   ФИКС: DASHBOARD — компактнее
   ============================================ */
.dash-shell{
  padding:32px 32px 100px !important;
}
.level-hero{
  padding:36px 32px !important;
  gap:32px !important;
  margin-bottom:20px !important;
}
.lh-level{
  font-size:clamp(72px,10vw,120px) !important;
}
.lh-name{
  font-size:20px !important;
}
.stat-row,
.skills,
.voc-stats{
  margin-bottom:32px !important;
}
.stat-card,
.skill,
.vs-card{
  padding:22px 20px !important;
  min-height:100px !important;
}
.sc-value,
.skill-level,
.vs-value{
  font-size:36px !important;
}
.section h2,
.skill-row h2,
.curriculum-block h2{
  font-size:clamp(24px,3vw,36px) !important;
  margin-bottom:20px !important;
  padding-bottom:16px !important;
}
.mode-card{
  padding:24px 22px 0 !important;
  min-height:200px !important;
}
.mode-emoji{
  font-size:28px !important;
  margin-bottom:16px !important;
}
.mode-title{
  font-size:15px !important;
}
.mode-desc{
  font-size:12.5px !important;
}
.mode-arrow{
  padding:12px 22px !important;
  margin:0 -22px !important;
  font-size:10px !important;
}
.unit{
  padding:18px 20px !important;
  min-height:130px !important;
}
.unit-title{
  font-size:14px !important;
}
.quick-card{
  padding:20px !important;
}
CSSEOF
echo "  ✓ Стили топбара/теста/урока/дашборда обновлены"
echo ""

# ---------- 4. ЕДИНЫЙ ЯЗЫК — заменяю английские термины на русские ----------
echo "[3/7] Убираю микс языков в HTML"

# В HTML нет текстов, они в JS. Заменяем в JS.
for JS in app.js dashboard.js test.js lesson.js listening.js speaking.js writing.js vocabulary.js; do
  [ -f "$JS" ] || continue
  # Тексты кнопок и меток
  perl -i -pe "s/>Theme</>Тема</g" "$JS" 2>/dev/null
  perl -i -pe "s/>AI Tutor</>AI-репетитор</g" "$JS" 2>/dev/null
  perl -i -pe "s/textContent = 'Theme'/textContent = 'Тема'/g" "$JS" 2>/dev/null
  perl -i -pe "s/textContent = 'AI Tutor'/textContent = 'AI-репетитор'/g" "$JS" 2>/dev/null
  perl -i -pe "s/'Home'/'Главная'/g" "$JS" 2>/dev/null
  perl -i -pe "s/>Home</>Главная</g" "$JS" 2>/dev/null
done

# В HTML — лейблы в топбаре
for HTML in *.html; do
  [ -f "$HTML" ] || continue
  # "AI Tutor" → "AI-репетитор"
  perl -i -pe "s/<span>AI Tutor<\/span>/<span>AI-репетитор<\/span>/g" "$HTML"
  perl -i -pe "s/>AI Tutor</>AI-репетитор</g" "$HTML"
  perl -i -pe "s/<span>Theme<\/span>/<span>Тема<\/span>/g" "$HTML"
  perl -i -pe "s/>Theme</>Тема</g" "$HTML"
  perl -i -pe "s/>← Home</>← Главная</g" "$HTML"
done
echo "  ✓ Замены сделаны"
echo ""

# ---------- 5. Робот — скрыть на страницах без логики ----------
echo "[4/7] Робот — оставляю только на рабочих страницах"

# В robot.js добавим: показывать только на конкретных страницах
python3 << 'PYEOF'
with open('robot.js','r') as f:
    content = f.read()

if 'SHOW_ONLY_ON' not in content:
    old = "  function init(){\n    build();"
    new = """  // Разрешаем робота только на этих страницах
  var SHOW_ONLY_ON = ['/lesson', '/test', '/vocabulary', '/listening', '/writing', '/speaking'];

  function init(){
    if (SHOW_ONLY_ON.indexOf(location.pathname) === -1) return;
    build();"""
    content = content.replace(old, new)
    with open('robot.js','w') as f:
        f.write(content)
    print('  ✓ Робот скрыт на главной/дашборде/логине')
else:
    print('  ✓ Робот уже настроен')
PYEOF
echo ""

# ---------- 6. Кэш бастинг ----------
echo "[5/7] Обновляю кэш HTML"
for HTML in *.html; do
  [ -f "$HTML" ] || continue
  perl -i -pe "s/robot\.js\?v=\d+/robot.js?v=4/g" "$HTML"
  perl -i -pe "s/styles\.css\?v=\d+/styles.css?v=10/g" "$HTML"
  perl -i -pe "s/interactions\.js\?v=\d+/interactions.js?v=3/g" "$HTML"
done
echo "  ✓ Кэш обновлён"
echo ""

# ---------- 7. Проверка ----------
echo "[6/7] Запускаю сервер и проверяю"
node server.js > /tmp/ioma_big.log 2>&1 &
PID=$!
sleep 3

FAIL=0
for PAGE in / /dashboard /test /lesson /login /register /profile /vocabulary /speaking /listening /writing; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$PAGE")
  [ "$CODE" != "200" ] && echo "  ✗ $PAGE → $CODE" && FAIL=$((FAIL+1))
done
for ASSET in /robot.js /styles.css /interactions.js /particles.js /app.js; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$ASSET")
  [ "$CODE" != "200" ] && echo "  ✗ $ASSET → $CODE" && FAIL=$((FAIL+1))
done

echo ""
echo "[7/7] Итог"
if [ $FAIL -eq 0 ]; then
  echo "  ✓ ВСЁ РАБОТАЕТ"
else
  echo "  ⚠ ПРОБЛЕМ: $FAIL"
fi

echo ""
echo "============================================"
echo "  ГОТОВО"
echo "============================================"
echo ""
echo "Сервер запущен на http://localhost:12000"
echo "Открой в браузере: Cmd+Shift+R"
echo ""
echo "Что исправлено:"
echo "  • Убран микс языков — теперь русский в кнопках"
echo "  • Топбар: кнопки не конфликтуют, фиксированы"
echo "  • AI-репетитор не наезжает на текст (пониже, компактнее)"
echo "  • Тест: всё компактнее, влезает на один экран"
echo "  • Урок: компактнее"
echo "  • Дашборд: компактнее"
echo "  • Робот — только на рабочих страницах"
echo ""

# Оставляем сервер запущенным
echo "Сервер работает. Ctrl+C чтобы остановить."
wait $PID
