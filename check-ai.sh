#!/bin/bash
cd "$(dirname "$0")"

echo "════════════════════════════════════════════"
echo "  ПРОВЕРКА AI-ПРОВАЙДЕРОВ"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "════════════════════════════════════════════"
echo ""

# ============ 1. ПЕРЕМЕННЫЕ В .env ============
echo "── 1. Переменные в .env ──"
if [ ! -f ".env" ]; then
  echo "✗ Файл .env не найден"
  exit 1
fi

for KEY in GROQ_API_KEY GEMINI_API_KEY OPENROUTER_API_KEY OLLAMA_URL OLLAMA_MODEL; do
  VAL=$(grep "^$KEY=" .env | cut -d'=' -f2-)
  if [ -z "$VAL" ]; then
    echo "  ✗ $KEY — НЕ ЗАДАН"
  else
    # Маскируем: показываем только первые и последние 4 символа
    LEN=${#VAL}
    if [ "$LEN" -gt 12 ]; then
      MASKED="${VAL:0:8}...${VAL: -4}"
    else
      MASKED="$VAL"
    fi
    echo "  ✓ $KEY = $MASKED  (длина: $LEN)"
  fi
done
echo ""

# ============ 2. ЧТО ИСПОЛЬЗУЕТ server.js ============
echo "── 2. Что читает server.js ──"
for KEY in GROQ_API_KEY GEMINI_API_KEY OPENROUTER_API_KEY OLLAMA_URL OLLAMA_MODEL DEEPSEEK_API_KEY; do
  COUNT=$(grep -c "$KEY" server.js 2>/dev/null)
  if [ "$COUNT" -gt 0 ]; then
    echo "  ✓ $KEY — используется ($COUNT раз)"
  else
    echo "  · $KEY — не используется"
  fi
done
echo ""

# ============ 3. РЕАЛЬНЫЙ ТЕСТ GROQ ============
echo "── 3. Тест Groq ──"
GROQ_KEY=$(grep "^GROQ_API_KEY=" .env | cut -d'=' -f2-)
if [ -z "$GROQ_KEY" ]; then
  echo "  ⊘ Пропущено — нет ключа"
else
  RESPONSE=$(curl -s -X POST "https://api.groq.com/openai/v1/chat/completions" \
    -H "Authorization: Bearer $GROQ_KEY" \
    -H "Content-Type: application/json" \
    -d '{"model":"llama-3.3-70b-versatile","messages":[{"role":"user","content":"Say only: OK"}],"max_tokens":5}' \
    --max-time 15 2>&1)
  if echo "$RESPONSE" | grep -q '"content"'; then
    ANSWER=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['choices'][0]['message']['content'])" 2>/dev/null)
    echo "  ✓ Groq работает. Ответ: $ANSWER"
  elif echo "$RESPONSE" | grep -q '"error"'; then
    ERR=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['error']['message'])" 2>/dev/null)
    echo "  ✗ Groq ошибка: $ERR"
  else
    echo "  ✗ Groq не ответил"
    echo "  Ответ: ${RESPONSE:0:200}"
  fi
fi
echo ""

# ============ 4. РЕАЛЬНЫЙ ТЕСТ GEMINI ============
echo "── 4. Тест Gemini ──"
GEM_KEY=$(grep "^GEMINI_API_KEY=" .env | cut -d'=' -f2-)
if [ -z "$GEM_KEY" ]; then
  echo "  ⊘ Пропущено — нет ключа"
else
  RESPONSE=$(curl -s -X POST \
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEM_KEY" \
    -H "Content-Type: application/json" \
    -d '{"contents":[{"parts":[{"text":"Say only: OK"}]}]}' \
    --max-time 15 2>&1)
  if echo "$RESPONSE" | grep -q '"text"'; then
    ANSWER=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['candidates'][0]['content']['parts'][0]['text'])" 2>/dev/null)
    echo "  ✓ Gemini работает. Ответ: $ANSWER"
  elif echo "$RESPONSE" | grep -q '"error"'; then
    ERR=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['error']['message'])" 2>/dev/null)
    echo "  ✗ Gemini ошибка: $ERR"
  else
    echo "  ✗ Gemini не ответил"
    echo "  Ответ: ${RESPONSE:0:200}"
  fi
fi
echo ""

# ============ 5. ТЕСТ OLLAMA (локально) ============
echo "── 5. Тест Ollama (локально) ──"
OLLAMA_URL=$(grep "^OLLAMA_URL=" .env | cut -d'=' -f2-)
OLLAMA_URL=${OLLAMA_URL:-http://localhost:11434}
if curl -s --max-time 3 "$OLLAMA_URL/api/tags" > /dev/null 2>&1; then
  echo "  ✓ Ollama работает на $OLLAMA_URL"
  MODELS=$(curl -s "$OLLAMA_URL/api/tags" | python3 -c "import sys,json; d=json.load(sys.stdin); [print('     - '+m['name']) for m in d.get('models',[])]" 2>/dev/null)
  echo "$MODELS"
else
  echo "  ✗ Ollama не отвечает на $OLLAMA_URL (ноутбук выключен или сервис не запущен)"
fi
echo ""

# ============ 6. ТЕСТ ЧЕРЕЗ САМ СЕРВЕР ============
echo "── 6. Тест через локальный сервер ──"
CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:12000/ 2>/dev/null)
if [ "$CODE" != "200" ]; then
  echo "  ⚠ Сервер не запущен (код: $CODE). Запускаю..."
  lsof -ti:12000 2>/dev/null | xargs kill -9 2>/dev/null
  pkill -f "node server.js" 2>/dev/null
  sleep 1
  nohup node server.js > /tmp/ioma_check.log 2>&1 & disown
  sleep 4
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:12000/ 2>/dev/null)
fi

if [ "$CODE" = "200" ]; then
  echo "  ✓ Сервер работает"
  echo ""
  echo "  Тест /api/assist (AI-ассистент):"
  RESPONSE=$(curl -s -X POST http://localhost:12000/api/assist \
    -H "Content-Type: application/json" \
    -d '{"question":"Скажи только: работает"}' \
    --max-time 30 2>&1)
  if echo "$RESPONSE" | grep -q '"reply"'; then
    REPLY=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['reply'][:100])" 2>/dev/null)
    echo "  ✓ AI отвечает: $REPLY"
  else
    echo "  ✗ AI не отвечает"
    echo "  Ответ: ${RESPONSE:0:300}"
  fi
else
  echo "  ✗ Сервер не запустился"
  tail -10 /tmp/ioma_check.log
fi
echo ""

echo "════════════════════════════════════════════"
echo "  ИТОГ"
echo "════════════════════════════════════════════"
echo ""
echo "Что означают результаты:"
echo "  ✓ работает     — провайдер доступен и отвечает"
echo "  ✗ ошибка       — ключ неверный или лимит исчерпан"
echo "  ⊘ пропущено    — ключа нет в .env"
echo ""
echo "Если Groq/Gemini работают, а сайт всё равно"
echo "даёт один и тот же ответ — проблема в robot.js."
echo ""
