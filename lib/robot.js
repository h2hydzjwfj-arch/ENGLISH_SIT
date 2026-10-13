// lib/robot.js — endpoint /api/robot
module.exports = function(app, ollamaChat, groqChat){
  app.post('/api/robot', async function(req, res){
    try {
      const b = req.body || {};
      const context = b.context || {};
      const message = String(b.message || '').slice(0, 500);
      const history = Array.isArray(b.history) ? b.history.slice(-6) : [];
      const mode = String(b.mode || 'reply');

      const page = context.page || '/';
      const level = context.level || 'A2';
      const levelName = {A1:'Beginner',A2:'Elementary',B1:'Intermediate',B2:'Upper-Intermediate',C1:'Advanced',C2:'Proficiency'}[level] || level;

      let situ = [];
      if (context.lessonTitle) situ.push('Урок: "' + context.lessonTitle + '"');
      if (context.lastError) situ.push('Последняя ошибка: ' + context.lastError);
      if (context.mistakesInRow) situ.push('Ошибок подряд: ' + context.mistakesInRow);
      if (context.testLevel) situ.push('Уровень после теста: ' + context.testLevel);
      if (context.vocabDue) situ.push('Слов к повторению: ' + context.vocabDue);
      if (context.listeningAccuracy != null) situ.push('Аудирование: ' + context.listeningAccuracy + '%');
      if (context.writingScore != null) situ.push('Балл эссе: ' + context.writingScore);
      if (context.speakingLevel) situ.push('Уровень речи: ' + context.speakingLevel);
      const situation = situ.length ? situ.join(' · ') : 'ничего особенного';

      const pageRu = {'/':'главная','/dashboard':'дашборд','/test':'тест','/lesson':'урок','/vocabulary':'словарь','/listening':'аудирование','/speaking':'речь','/writing':'письмо','/profile':'профиль'}[page] || page;

      let system = [
        'Ты — ioma, дружелюбный помощник-робот на сайте изучения английского iomaenglish.',
        'ПРАВИЛА:',
        '1. Отвечай ТОЛЬКО на русском.',
        '2. Максимум 2-3 коротких предложения. Никаких лекций.',
        '3. Тон — дружелюбный, но без сюсюканья.',
        '4. Если ошибка — объясни КОРОТКО почему и дай пример.',
        '5. Не используй: "Конечно!", "Отличный вопрос!", "Я рад помочь!"',
        '6. Обращайся на "ты".',
        '7. Не упоминай что ты AI.',
        '8. Тебя зовут ioma. Если спросят имя — отвечай "ioma".',
        '',
        'Уровень студента: ' + level + ' (' + levelName + ')',
        'Страница: ' + pageRu,
        'Ситуация: ' + situation
      ].join('\n');

      if (mode === 'greeting') {
        system += '\n\nСТУДЕНТ ТОЛЬКО ЧТО ОТКРЫЛ ТЕБЯ. Спроси чем помочь, коротко (1-2 предложения).';
      }
      if (mode === 'auto-error') {
        system += '\n\nСТУДЕНТ СДЕЛАЛ 2 ОШИБКИ ПОДРЯД. Объясни КОРОТКО правило и дай пример.';
      }
      if (mode === 'auto-test') {
        system += '\n\nСТУДЕНТ ПРОШЁЛ ТЕСТ. Скажи с чего начать в первую неделю. 2 предложения.';
      }
      if (mode === 'auto-writing') {
        system += '\n\nСТУДЕНТ НАПИСАЛ ЭССЕ. Дай 2-3 КОНКРЕТНЫХ совета.';
      }
      if (mode === 'auto-listening') {
        system += '\n\nПЛОХОЕ АУДИРОВАНИЕ. Скажи что конкретно делать. 1-2 предложения.';
      }

      const userPrompt = message || 'Ответь коротко.';
      let reply = null;

      try {
        reply = await ollamaChat(system, userPrompt, 250);
      } catch(e){
        try { reply = await groqChat(system, userPrompt, 250); }
        catch(e2){ console.warn('[robot] ai fail:', e2.message); }
      }

      if (!reply) {
        const fallback = {
          greeting: {
            '/writing': 'Привет, я ioma. Напиши эссе — проверю и подскажу.',
            '/lesson': 'Я ioma. Читай правило сверху — если ошибёшься, подскажу.',
            '/test': 'Привет, я ioma. Отвечай честно — это не экзамен.',
            '/listening': 'Я ioma. Слушай медленно — переслушать не стыдно.',
            '/speaking': 'Я ioma. Говори громко — ошибки это нормально.',
            '/dashboard': 'Я ioma. Продолжаем с того места, где остановились.'
          },
          'auto-error': 'Я ioma. Прочитай правило выше — там есть ответ.',
          'auto-test': 'Я ioma. Начни с A1 уроков — по 15 минут в день, и через месяц увидишь результат.',
          'auto-writing': 'Я ioma. Обрати внимание на связки и артикли — пиши короче.',
          'auto-listening': 'Я ioma. Слушай медленную версию несколько раз — помогает.'
        };
        if (mode === 'greeting') reply = fallback.greeting[page] || 'Привет, я ioma. Чем помочь?';
        else reply = fallback[mode] || 'Привет, я ioma. Чем помочь?';
      }

      res.json({ ok:true, reply: String(reply).slice(0, 600), mode: mode });
    } catch(e){
      console.error('[robot]', e.message);
      res.status(500).json({ ok:false, error: e.message });
    }
  });
  console.log('[robot] ioma (/api/robot) endpoint registered');
};
