#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  API для робота"
echo "============================================"
echo ""

mkdir -p _unused/backup
cp server.js "_unused/backup/server.js.$(date +%Y%m%d_%H%M%S)"
echo "✓ Бэкап"
echo ""

# Проверяем, есть ли уже endpoint
if grep -q "'/api/robot'" server.js; then
  echo "  ✓ Endpoint уже есть"
else
  echo "[1/2] Добавляю /api/robot в server.js"
  # Вставляем перед строкой app.listen
  perl -i -pe "s{(app\.listen\(PORT)}{// ========== ROBOT AI ==========
app.post('/api/robot', async function(req, res){
  try {
    const b = req.body || {};
    const context = b.context || {};
    const message = String(b.message || '').slice(0, 500);
    const history = Array.isArray(b.history) ? b.history.slice(-6) : [];

    const page = context.page || '/';
    const level = context.level || 'A2';
    const levelName = {A1:'Beginner',A2:'Elementary',B1:'Intermediate',B2:'Upper-Intermediate',C1:'Advanced',C2:'Proficiency'}[level] || level;

    let situ = [];
    if (context.lessonTitle) situ.push('Урок: \"' + context.lessonTitle + '\"');
    if (context.lastError) situ.push('Последняя ошибка: ' + context.lastError);
    if (context.correctCount != null && context.totalCount) situ.push('Правильных ответов: ' + context.correctCount + '/' + context.totalCount);
    if (context.mistakesInRow) situ.push('Ошибок подряд: ' + context.mistakesInRow);
    if (context.idleSeconds) situ.push('Не активен ' + context.idleSeconds + ' сек');
    if (context.testLevel) situ.push('Уровень после теста: ' + context.testLevel);
    if (context.vocabDue) situ.push('Слов к повторению: ' + context.vocabDue);
    if (context.listeningAccuracy != null) situ.push('Точность аудирования: ' + context.listeningAccuracy + '%');
    if (context.writingScore != null) situ.push('Балл за эссе: ' + context.writingScore);
    if (context.speakingLevel) situ.push('Уровень речи: ' + context.speakingLevel);
    const situation = situ.length ? situ.join(' · ') : 'ничего особенного';

    const pageRu = {'/':'главная','/dashboard':'дашборд','/test':'тест','/lesson':'урок','/vocabulary':'словарь','/listening':'аудирование','/speaking':'речь','/writing':'письмо','/profile':'профиль'}[page] || page;

    const system = [
      'Ты — добрый учитель-робот по имени Робо на сайте изучения английского iomaenglish.',
      'Ты помогаешь студенту, поддерживаешь его, даёшь короткие полезные советы.',
      '',
      'ПРАВИЛА:',
      '1. Отвечай ТОЛЬКО на русском.',
      '2. Максимум 2-3 коротких предложения. Никаких длинных лекций.',
      '3. Тон — дружелюбный, спокойный, поддерживающий. Без сюсюканья и восторгов.',
      '4. Если студент задал вопрос — ответь по существу.',
      '5. Если ошибка — объясни КОРОТКО почему, дай пример.',
      '6. Если хвалишь — хвали конкретно за что.',
      '7. Если ситуация неясна — предложи помощь без навязывания.',
      '8. Никогда не используй фразы типа \"Конечно!\", \"Отличный вопрос!\", \"Я рад помочь!\" — это раздражает.',
      '9. Обращайся на \"ты\", неформально.',
      '10. Не упоминай что ты AI или языковая модель.',
      '',
      'КОНТЕКСТ СТУДЕНТА:',
      'Уровень: ' + level + ' (' + levelName + ')',
      'Страница: ' + pageRu,
      'Ситуация: ' + situation
    ].join('\\n');

    let userPrompt;
    if (message) {
      userPrompt = message;
    } else {
      userPrompt = 'Что сказать студенту прямо сейчас? Ситуация: ' + situation + '. Дай короткий уместный комментарий.';
    }

    let messages = [{role:'system', content:system}];
    history.forEach(function(h){
      if (h.role && h.content){
        messages.push({role: h.role === 'user' ? 'user' : 'assistant', content: String(h.content).slice(0, 400)});
      }
    });
    messages.push({role:'user', content:userPrompt});

    // Используем существующий aiText
    let reply = null;
    try {
      // ollamaChat / groqChat определены выше
      const sys2 = system;
      const user2 = (history.length ? history.map(h => h.role + ': ' + h.content).join('\\n') + '\\n\\n' : '') + userPrompt;
      try { reply = await ollamaChat(sys2, user2, 200); }
      catch(e){ reply = await groqChat(sys2, user2, 200); }
    } catch(e){
      console.warn('[robot] ai fail:', e.message);
    }

    if (!reply) {
      // Локальный fallback — на случай, если AI недоступен
      const fallback = {
        '/': 'Пройди тест — и я подберу программу под тебя.',
        '/dashboard': 'Выбери урок ниже — и начнём.',
        '/lesson': 'Читай правило сверху. Если ошибёшься — подскажу.',
        '/test': 'Отвечай честно, не бойся ошибок.',
        '/vocabulary': 'Повтори слова — 5 минут в день хватит.',
        '/listening': 'Слушай медленно. Переслушать не стыдно.',
        '/speaking': 'Говори громко. Ошибки — это нормально.',
        '/writing': 'Пиши как думаешь. Я проверю.',
        '/profile': 'Растёшь. Продолжай.'
      };
      reply = fallback[page] || 'Я здесь. Что нужно?';
    }

    res.json({ ok:true, reply: String(reply).slice(0, 500) });
  } catch(e){
    console.error('[robot]', e.message);
    res.status(500).json({ ok:false, error: e.message });
  }
});

\$1}" server.js

  if node -c server.js 2>/dev/null; then
    echo "  ✓ server.js валиден"
  else
    echo "  ✗ ОШИБКА — восстанавливаю"
    cp "_unused/backup/server.js."* server.js
    exit 1
  fi
fi
echo ""

# Перезапуск
echo "[2/2] Перезапускаю сервер"
lsof -ti:12000 2>/dev/null | xargs kill -9 2>/dev/null
pkill -f "node server.js" 2>/dev/null
sleep 1
nohup node server.js > /tmp/ioma_server.log 2>&1 & disown
sleep 2

CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:12000/)
echo ""
if [ "$CODE" = "200" ]; then
  echo "✓ Сервер работает"
  echo ""
  # Тест API
  echo "Тест API робота:"
  curl -s -X POST http://localhost:12000/api/robot \
    -H "Content-Type: application/json" \
    -d '{"message":"Привет, что делаешь?","context":{"page":"/dashboard","level":"A2"}}' | head -c 200
  echo ""
else
  echo "⚠ Сервер: $CODE"
fi
