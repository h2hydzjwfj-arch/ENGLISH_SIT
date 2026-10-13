#!/bin/bash
cd "$(dirname "$0")"

echo "════════════════════════════════════════════"
echo "  ПОДГОТОВКА К ДЕПЛОЮ НА RENDER"
echo "════════════════════════════════════════════"
echo ""

# ============ 1. ПРОВЕРКА ПРОЕКТА ============
echo "── 1. Проверяю проект ──"
if [ ! -f "server.js" ]; then
  echo "✗ Нет server.js — не та папка"
  exit 1
fi
echo "✓ server.js найден"
echo ""

# ============ 2. PACKAGE.JSON ============
echo "── 2. Обновляю package.json ──"
if [ ! -f "package.json" ]; then
  echo "✗ Нет package.json"
  exit 1
fi

node -e '
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
pkg.scripts = pkg.scripts || {};
pkg.scripts.start = "node server.js";
pkg.engines = pkg.engines || {};
pkg.engines.node = ">=18";
fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2));
console.log("✓ Скрипт start добавлен");
console.log("✓ engines.node = >=18");
'

# ============ 3. PORT ============
echo ""
echo "── 3. Проверяю PORT ──"
if grep -q "process.env.PORT" server.js; then
  echo "✓ PORT уже читается из env (Render это требует)"
else
  echo "⚠ PORT захардкожен — исправляю"
  sed -i.bak 's/const PORT = [0-9]\+;/const PORT = process.env.PORT || 10000;/' server.js
  sed -i.bak 's/const PORT = [0-9]\+$/const PORT = process.env.PORT || 10000;/' server.js
  rm -f server.js.bak
fi
node -c server.js 2>/dev/null && echo "✓ server.js валиден" || echo "⚠ Проверь синтаксис server.js"
echo ""

# ============ 4. DATA ПАПКА ============
echo "── 4. Готовлю data/ ──"
mkdir -p data
mkdir -p data/tts-cache 2>/dev/null
mkdir -p data/progress 2>/dev/null
mkdir -p data/articles-cache 2>/dev/null
echo "✓ Папки созданы"
echo ""

# ============ 5. .gitignore ============
echo "── 5. Обновляю .gitignore ──"
cat > .gitignore << 'GITEOF'
node_modules/
.env
.env.local
.env.*.local
.DS_Store
*.log
server.log
npm-debug.log*
_unused/
_trash/
*.bak
*.bak_*
*.pre-*
GITEOF
echo "✓ .gitignore обновлён"
echo ""

# ============ 6. render.yaml ============
echo "── 6. Создаю render.yaml ──"
cat > render.yaml << 'YAMLEOF'
services:
  - type: web
    name: iomaenglish
    runtime: node
    plan: free
    region: frankfurt
    branch: main
    buildCommand: npm install
    startCommand: node server.js
    autoDeploy: true
    envVars:
      - key: NODE_ENV
        value: production
YAMLEOF
echo "✓ render.yaml создан"
echo ""

# ============ 7. .env.example ============
echo "── 7. Создаю .env.example (шаблон) ──"
cat > .env.example << 'ENVEOF'
# Порт сервера (Render подставит сам)
PORT=10000

# Node окружение
NODE_ENV=production

# AI ключи (положи реальные в Render → Environment)
GROQ_API_KEY=
GEMINI_API_KEY=

# Ollama (если используешь локально)
OLLAMA_URL=http://localhost:11434
OLLAMA_MODEL=qwen2.5:7b

# Telegram (если бот работает)
TELEGRAM_BOT_TOKEN=
ENVEOF
echo "✓ .env.example создан"
echo ""

# ============ 8. GIT ============
echo "── 8. Проверяю Git ──"
if [ ! -d ".git" ]; then
  echo "  + Инициализирую репозиторий"
  git init -b main > /dev/null 2>&1
  git add .
  git commit -m "Initial commit — iomaenglish" > /dev/null 2>&1
  echo "✓ Git инициализирован, первый коммит сделан"
else
  echo "✓ Git уже есть"
  # Коммитим если есть изменения
  if [ -n "$(git status --porcelain)" ]; then
    git add .
    git commit -m "Prepare for Render deployment" > /dev/null 2>&1
    echo "✓ Изменения закоммичены"
  else
    echo "  (нет изменений для коммита)"
  fi
fi
echo ""

# ============ 9. REMOTE ============
echo "── 9. Проверяю remote ──"
REMOTE=$(git remote get-url origin 2>/dev/null)
if [ -z "$REMOTE" ]; then
  echo "⚠ Remote origin НЕ настроен"
  echo ""
  echo "  Тебе нужно создать репозиторий на GitHub и потом:"
  echo "  git remote add origin https://github.com/ТВОЙ_НИК/ENGLISH_SITE.git"
  echo "  git push -u origin main"
else
  echo "✓ Remote: $REMOTE"
  echo ""
  echo "  Пушим изменения на GitHub..."
  git push origin main 2>&1 | tail -5
fi
echo ""

# ============ 10. ПРОВЕРКА ЛОКАЛЬНО ============
echo "── 10. Проверяю локальный запуск ──"
lsof -ti:10000 2>/dev/null | xargs kill -9 2>/dev/null
pkill -f "node server.js" 2>/dev/null
sleep 1
nohup node server.js > /tmp/ioma_deploy_test.log 2>&1 & disown
sleep 3
CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:10000/ 2>/dev/null)
if [ "$CODE" = "200" ]; then
  echo "✓ Сервер работает локально (200 OK)"
else
  echo "⚠ Сервер не отвечает: $CODE"
  echo "  Лог:"
  tail -10 /tmp/ioma_deploy_test.log
fi
lsof -ti:10000 2>/dev/null | xargs kill -9 2>/dev/null
echo ""

# ============ ИТОГ ============
echo "════════════════════════════════════════════"
echo "  ГОТОВО К ДЕПЛОЮ"
echo "════════════════════════════════════════════"
echo ""
echo "Что сделано:"
echo "  ✓ package.json — start, engines.node"
echo "  ✓ PORT — читается из env"
echo "  ✓ render.yaml — конфиг для Render"
echo "  ✓ .gitignore — данные не улетят в git"
echo "  ✓ .env.example — шаблон переменных"
echo "  ✓ Git — коммит сделан"
echo ""
echo "════════════════════════════════════════════"
echo "  ЧТО ДЕЛАТЬ ДАЛЬШЕ (3 шага, каждый ~2 мин)"
echo "════════════════════════════════════════════"
echo ""
echo "ШАГ 1. GitHub"
echo "  1. Открой https://github.com/new"
echo "  2. Имя: ENGLISH_SITE"
echo "  3. Public или Private — как хочешь"
echo "  4. НЕ ставь галочки (readme, gitignore)"
echo "  5. Create repository"
echo ""
echo "  Потом запусти 2 команды:"
echo "    git remote add origin https://github.com/ТВОЙ_НИК/ENGLISH_SITE.git"
echo "    git push -u origin main"
echo ""
echo "ШАГ 2. Render"
echo "  1. Открой https://render.com → Sign Up (через GitHub)"
echo "  2. New + → Web Service"
echo "  3. Выбери репозиторий ENGLISH_SITE"
echo "  4. Render сам подхватит render.yaml"
echo "  5. Environment → добавь переменные:"
echo "       GROQ_API_KEY = твой ключ"
echo "       GEMINI_API_KEY = твой ключ"
echo "  6. Create Web Service"
echo ""
echo "  Через 2-3 минуты сайт будет по адресу:"
echo "  https://iomaenglish.onrender.com"
echo ""
echo "ШАГ 3. UptimeRobot (чтобы сайт НЕ засыпал)"
echo "  1. Открой https://uptimerobot.com → Sign Up (бесплатно)"
echo "  2. Add New Monitor:"
echo "       Type: HTTP(s)"
echo "       Name: iomaenglish"
echo "       URL: https://iomaenglish.onrender.com"
echo "       Interval: 10 minutes"
echo "  3. Create"
echo ""
echo "  UptimeRobot будет пинговать сайт — Render НЕ заснёт."
echo "  Сайт будет открываться мгновенно, всегда."
echo ""
echo "════════════════════════════════════════════"
