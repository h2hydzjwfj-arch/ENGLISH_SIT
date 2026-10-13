#!/bin/bash
# Универсальная обёртка: убить старый сервер, запустить новый, проверить
cd "$(dirname "$0")"

# Убиваем всё что висит на порту
lsof -ti:12000 2>/dev/null | xargs kill -9 2>/dev/null
pkill -f "node server.js" 2>/dev/null
sleep 1

# Запускаем сервер
node server.js > /tmp/ioma_run.log 2>&1 &
SERVER_PID=$!

# Ждём старта (максимум 5 сек)
for i in 1 2 3 4 5 6 7 8 9 10; do
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:12000/ 2>/dev/null | grep -q "200"; then
    break
  fi
  sleep 0.5
done

# Проверяем что сервер жив
if ! curl -s -o /dev/null -w "%{http_code}" http://localhost:12000/ 2>/dev/null | grep -q "200"; then
  echo "✗ Сервер не запустился"
  cat /tmp/ioma_run.log
  exit 1
fi

echo "✓ Сервер запущен (PID $SERVER_PID)"
echo "  http://localhost:12000"

# Оставляем сервер работающим в фоне
disown $SERVER_PID 2>/dev/null
