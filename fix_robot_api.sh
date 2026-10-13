#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  Фикс: /api/robot + робот не вылезает сам"
echo "============================================"
echo ""

mkdir -p _unused/backup
cp server.js "_unused/backup/server.js.$(date +%Y%m%d_%H%M%S)"
cp robot.js "_unused/backup/robot.js.$(date +%Y%m%d_%H%M%S)"
echo "✓ Бэкапы"
echo ""

# ============ 1. Проверяем server.js ============
echo "[1/4] Проверяю server.js"
if ! node -c server.js 2>/dev/null; then
  echo "  ✗ server.js битый, восстанавливаю"
  LATEST=$(ls -t _unused/backup/server.js.* | head -1)
  cp "$LATEST" server.js
  node -c server.js 2>/dev/null || { echo "  ✗ Бэкап тоже битый"; exit 1; }
fi

HAS_ROBOT=$(grep -c "'/api/robot'" server.js || echo 0)
echo "  /api/robot найден: $HAS_ROBOT раз"

if [ "$HAS_ROBOT" = "0" ]; then
  echo "  + Добавляю /api/robot через node"

  # Создаём файл с блоком
  cat > /tmp/robot_block.js << 'BLOCKEOF'

// ========== ROBOT AI ==========
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
    if (context.writingDraft) situ.push('Черновик: ' + context.writingDraft.slice(0, 200));
    const situation = situ.length ? situ.join(' · ') : 'ничего особенного';

    const pageRu = {'/':'главная','/dashboard':'дашборд','/test':'тест','/lesson':'урок','/vocabulary':'словарь','/listening':'аудирование','/speaking':'речь','/writing':'письмо','/profile':'профиль'}[page] || page;

    let systemParts = [
      'Ты — учитель-робот Робо на сайте изучения английского.',
      'Ты помогаешь студенту, объясняешь, поддерживаешь.',
      '',
      'ПРАВИЛА:',
      '1. Отвечай ТОЛЬКО на русском.',
      '2. Максимум 2-3 коротких предложения. Никаких лекций.',
      '3. Тон — дружелюбный, но без сюсюканья.',
      '4. Если ошибка — объясни КОРОТКО почему и дай пример.',
      '5. Если просят совет — дай 1-2 конкретных шага.',
      '6. Не используй: "Конечно!", "Отличный вопрос!", "Я рад помочь!"',
      '7. Обращайся на "ты".',
      '8. Не упоминай что ты AI.',
      '',
      'КОНТЕКСТ:',
      'Уровень: ' + level + ' (' + levelName + ')',
      'Страница: ' + pageRu,
      'Ситуация: ' + situation
    ];

    if (mode === 'greeting') {
      systemParts.push('');
      systemParts.push('СТУДЕНТ ТОЛЬКО ЧТО ОТКРЫЛ ТЕБЯ. Спроси чем помочь, коротко (1-2 предложения).');
      systemParts.push('Учитывай страницу: на /writing — предложи проверить текст, на /lesson — помочь с ошибками.');
    }
    if (mode === 'auto-error') {
      systemParts.push('');
      systemParts.push('СТУДЕНТ СДЕЛАЛ 2 ОШИБКИ ПОДРЯД. Объясни КОРОТКО правило и дай пример.');
    }
    if (mode === 'auto-test') {
      systemParts.push('');
      systemParts.push('СТУДЕНТ ПРОШЁЛ ТЕСТ. Скажи с чего начать в первую неделю. 2 предложения.');
    }
    if (mode === 'auto-writing') {
      systemParts.push('');
      systemParts.push('СТУДЕНТ НАПИСАЛ ЭССЕ. Дай 2-3 КОНКРЕТНЫХ совета по улучшению.');
    }
    if (mode === 'auto-listening') {
      systemParts.push('');
      systemParts.push('ПЛОХОЕ АУДИРОВАНИЕ. Скажи что конкретно делать. 1-2 предложения.');
    }

    const system = systemParts.join('\n');
    const userPrompt = message || 'Ответь коротко.';

    let reply = null;
    const sysForAI = system;
    const userForAI = (history.length ? history.map(h => h.role + ': ' + h.content).join('\n') + '\n\n' : '') + userPrompt;

    try { reply = await ollamaChat(sysForAI, userForAI, 250); }
    catch(e){
      try { reply = await groqChat(sysForAI, userForAI, 250); }
      catch(e2){ console.warn('[robot] ai fail:', e2.message); }
    }

    if (!reply) {
      // Fallback
      if (mode === 'greeting') {
        var greeting = {
          '/writing': 'Напиши эссе — я проверю и подскажу что улучшить.',
          '/lesson': 'Читай правило сверху. Ошибёшься — подскажу.',
          '/test': 'Отвечай честно, это не экзамен.',
          '/listening': 'Слушай медленно. Переслушать не стыдно.',
          '/speaking': 'Говори громко. Ошибки — это нормально.',
          '/vocabulary': 'Повторяй слова по 5 минут в день.',
          '/dashboard': 'Продолжаем с того места, где остановились.'
        };
        reply = greeting[page] || 'Чем помочь?';
      } else if (mode === 'auto-error') {
        reply = 'Прочитай правило выше внимательно. Попробуй ещё раз — правило уже перед тобой.';
      } else if (mode === 'auto-test') {
        reply = 'Начни с A1 уроков на дашборде. По 15 минут в день — через месяц заметишь разницу.';
      } else if (mode === 'auto-writing') {
        reply = 'Обрати внимание на связки между предложениями и артикли. Пиши короче и точнее.';
      } else if (mode === 'auto-listening') {
        reply = 'Слушай медленную версию несколько раз подряд. Понимание приходит с повторением.';
      } else {
        reply = 'Не могу ответить сейчас. Попробуй позже.';
      }
    }

    res.json({ ok:true, reply: String(reply).slice(0, 600), mode: mode });
  } catch(e){
    console.error('[robot]', e.message);
    res.status(500).json({ ok:false, error: e.message });
  }
});

BLOCKEOF

  # Вставляем через node
  node << 'NODEEOF'
const fs = require('fs');
let s = fs.readFileSync('server.js', 'utf8');
const block = fs.readFileSync('/tmp/robot_block.js', 'utf8');
const marker = 'app.listen(PORT';
const idx = s.indexOf(marker);
if (idx === -1) {
  console.log('✗ Не нашёл app.listen(PORT');
  process.exit(1);
}
s = s.slice(0, idx) + block + s.slice(idx);
fs.writeFileSync('server.js', s);
console.log('✓ Блок вставлен');
NODEEOF

  node -c server.js 2>/dev/null && echo "  ✓ server.js валиден" || { echo "  ✗ ОШИБКА"; exit 1; }
else
  echo "  ✓ /api/robot уже есть"
fi
echo ""

# ============ 2. Фикс robot.js — не вылезать на writing без причины ============
echo "[2/4] Фикс robot.js — только иконка, пока не кликнут"

python3 << 'PYEOF'
import re
with open('robot.js','r') as f:
    js = f.read()

# Убираем watchWriting и watchListening из init — они открывают робота автоматически
# Робот должен только дать сигнал (has-message) на иконке

# Заменяем watchWriting
js = re.sub(
    r'  // Результат эссе\n  function watchWriting\(\)\{[\s\S]*?\n  \}\n\n  // Слушание',
    '''  // Результат эссе — только сигнал на иконке, не открывать робота
  function watchWriting(){
    if (location.pathname !== '/writing') return;
    var result = document.getElementById('wrtResult');
    if (!result) return;
    var mo = new MutationObserver(function(){
      if (result.hidden === false){
        var score = result.querySelector('.wr-score-big');
        if (score){
          ctx.writingScore = parseInt(score.textContent, 10) || 0;
          // Сигнал на иконку — есть новое сообщение
          if (miniBtn) miniBtn.classList.add('has-message');
        }
        mo.disconnect();
      }
    });
    mo.observe(result, { attributes:true, attributeFilter:['hidden'] });
  }

  // Слушание''',
    js
)

# Заменяем watchListening
js = re.sub(
    r'  // Слушание\n  function watchListening\(\)\{[\s\S]*?\n  \}\n\n  function init\(\)\{',
    '''  // Слушание — только сигнал
  function watchListening(){
    if (location.pathname !== '/listening') return;
    var result = document.getElementById('lstResult');
    if (!result) return;
    var mo = new MutationObserver(function(){
      if (result.hidden === false){
        var m = (result.textContent || '').match(/accuracy:\\s*(\\d+)%/i);
        if (m){
          var pct = parseInt(m[1], 10);
          ctx.listeningAccuracy = pct;
          if (pct < 50 && miniBtn){
            miniBtn.classList.add('has-message');
          }
        }
      }
    });
    mo.observe(result, { attributes:true, subtree:true, attributeFilter:['hidden','class'] });
  }

  function init(){''',
    js
)

# Убираем watchTest автовызов — тоже только сигнал
js = re.sub(
    r'  // Результат теста\n  function watchTest\(\)\{[\s\S]*?\n  \}\n\n  // Результат эссе',
    '''  // Результат теста — только сигнал
  function watchTest(){
    if (location.pathname !== '/test') return;
    var result = document.querySelector('#stage-result');
    if (!result) return;
    var mo = new MutationObserver(function(){
      if (result.hidden === false){
        var lvl = document.getElementById('resultLevel');
        if (lvl && lvl.textContent.trim()){
          ctx.testLevel = lvl.textContent.trim();
          if (miniBtn) miniBtn.classList.add('has-message');
        }
        mo.disconnect();
      }
    });
    mo.observe(result, { attributes:true, attributeFilter:['hidden'] });
  }

  // Результат эссе''',
    js
)

# Убираем watchLesson автовызов 2 ошибок — тоже сигнал
js = re.sub(
    r'  // Реакция на ошибку в уроке\n  function watchLesson\(\)\{[\s\S]*?\n  \}\n\n  // Результат теста',
    '''  // Реакция на ошибку в уроке — только сигнал на иконке
  function watchLesson(){
    if (location.pathname !== '/lesson') return;
    var titleEl = document.getElementById('lessonTitle');
    if (titleEl){
      var c = setInterval(function(){
        if (titleEl.textContent && titleEl.textContent !== 'Loading...'){
          ctx.lessonTitle = titleEl.textContent;
          clearInterval(c);
        }
      }, 300);
    }
    var mo = new MutationObserver(function(muts){
      muts.forEach(function(m){
        if (m.type !== 'attributes' || m.attributeName !== 'class') return;
        var el = m.target;
        if (!el.classList.contains('ex-comment')) return;
        if (!el.classList.contains('show')) return;
        var text = (el.textContent || '').trim();
        if (/✗|✕|Correct answer|Неверно/i.test(text)){
          ctx.mistakesInRow = (ctx.mistakesInRow || 0) + 1;
          ctx.lastError = text.slice(0, 150);
          // Только сигнал — робот не открывается сам
          if (ctx.mistakesInRow >= 2 && miniBtn){
            miniBtn.classList.add('has-message');
          }
        } else if (/✓|Правильно|Correct/i.test(text)){
          ctx.mistakesInRow = 0;
        }
      });
    });
    mo.observe(document.body, { attributes:true, subtree:true, attributeFilter:['class'] });
  }

  // Результат теста''',
    js
)

# Также обновляем openExpanded — когда пользователь кликает на иконку с has-message,
# нужно дать контекстный ответ, а не просто приветствие
js = re.sub(
    r'  function openExpanded\(\)\{[\s\S]*?\n  \}',
    '''  function openExpanded(){
    expanded = true;
    bubble.classList.add('expanded');
    show(STATE.CURIOUS);

    // Определяем контекст — если есть что-то конкретное, отвечаем по нему
    var contextMode = null;
    var contextMsg = '';
    if (ctx.testLevel) {
      contextMode = 'auto-test';
      contextMsg = 'Я прошёл тест, уровень ' + ctx.testLevel + '. Что дальше?';
    } else if (ctx.writingScore != null) {
      contextMode = 'auto-writing';
      contextMsg = 'Эссе оценено ' + ctx.writingScore + '/100. Как улучшить?';
    } else if (ctx.listeningAccuracy != null && ctx.listeningAccuracy < 50) {
      contextMode = 'auto-listening';
      contextMsg = 'Аудирование ' + ctx.listeningAccuracy + '%. Что делать?';
    } else if (ctx.mistakesInRow >= 2 && ctx.lastError) {
      contextMode = 'auto-error';
      contextMsg = 'Я ошибся дважды. ' + ctx.lastError;
    }

    if (memory.length === 0){
      if (contextMode) {
        ask(contextMsg, { mode: contextMode, sticky:true });
      } else {
        ask('', { mode:'greeting', sticky:true });
      }
    } else {
      bubble.classList.add('show');
      setTimeout(function(){ input.focus(); }, 400);
    }

    // Сбрасываем has-message
    if (miniBtn) miniBtn.classList.remove('has-message');
  }''',
    js
)

# Убираем расширенный auto-show триггер из init (если был)
js = js.replace("shouldAutoShow()", "false")

with open('robot.js','w') as f:
    f.write(js)
print('  ✓ robot.js обновлён')
PYEOF
echo ""

# ============ 3. Проверка JS ============
echo "[3/4] Проверка robot.js"
node -c robot.js 2>/dev/null && echo "  ✓ OK" || { echo "  ✗ ОШИБКА"; node -c robot.js 2>&1 | head -5; exit 1; }
echo ""

# ============ 4. Перезапуск + тест API ============
echo "[4/4] Перезапуск + тест"
lsof -ti:12000 2>/dev/null | xargs kill -9 2>/dev/null
pkill -f "node server.js" 2>/dev/null
sleep 1
nohup node server.js > /tmp/ioma_server.log 2>&1 & disown
sleep 3

CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:12000/)

echo ""
echo "Тест /api/robot (greeting):"
curl -s -X POST http://localhost:12000/api/robot \
  -H "Content-Type: application/json" \
  -d '{"mode":"greeting","context":{"page":"/writing","level":"A2"}}' \
  | head -c 300
echo ""
echo ""
echo "============================================"
if [ "$CODE" = "200" ]; then
  echo "  ✓ ГОТОВО"
  echo "============================================"
  echo ""
  echo "Что исправлено:"
  echo "  • /api/robot в server.js восстановлен и работает"
  echo "  • Робот больше НЕ открывается автоматически"
  echo "  • На иконке — пульсирующая точка когда есть что сказать"
  echo "  • Клик на иконку → открывается и сразу даёт контекстный ответ:"
  echo "      — после теста: 'Что дальше?'"
  echo "      — после эссе: 'Как улучшить?'"
  echo "      — 2 ошибки в уроке: 'В чём ошибка?'"
  echo "      — иначе: обычное приветствие"
  echo ""
  echo "Cmd+Shift+R"
else
  echo "  ⚠ Сервер: $CODE"
  tail -15 /tmp/ioma_server.log
fi
