#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  Грамматика → сразу в урок"
echo "============================================"
echo ""

mkdir -p _unused/backup
TS=$(date +%Y%m%d_%H%M%S)
cp dashboard.html "_unused/backup/dashboard.html.$TS"
cp dashboard.js "_unused/backup/dashboard.js.$TS"
echo "✓ Бэкапы"
echo ""

# ============ 1. Меняем ссылку в dashboard.html ============
echo "[1/4] Меняю ссылку на 'Только грамматика'"
# Ищем блок mode-card с href="/dashboard#curriculum" и заменяем на #goto-lesson
python3 << 'PYEOF'
import re
with open('dashboard.html','r') as f:
    html = f.read()

# Ищем mode-card с "Только грамматика"
patterns = [
    (r'href="/dashboard#curriculum"([^>]*>\s*<div class="mode-emoji">📖</div>)', r'href="/dashboard" data-goto-lesson\1'),
    (r'(<a[^>]*class="mode-card"[^>]*)href="/dashboard#curriculum"', r'\1href="#" data-goto-lesson'),
]

changed = False
for old, new in patterns:
    new_html = re.sub(old, new, html)
    if new_html != html:
        html = new_html
        changed = True
        break

if changed:
    with open('dashboard.html','w') as f:
        f.write(html)
    print('  ✓ Ссылка обновлена (data-goto-lesson)')
else:
    # Заменяем вручную через поиск блока "Только грамматика"
    if '/dashboard#curriculum' in html:
        html = html.replace('/dashboard#curriculum', '#')
        html = re.sub(
            r'(<a[^>]*class="mode-card"[^>]*)>\s*<div class="mode-emoji">📖</div>\s*<div class="mode-title">Только грамматика</div>',
            r'\1 data-goto-lesson> <div class="mode-emoji">📖</div> <div class="mode-title">Только грамматика</div>',
            html,
            flags=re.DOTALL
        )
        with open('dashboard.html','w') as f:
            f.write(html)
        print('  ✓ Ссылка обновлена (2-й метод)')
    else:
        print('  ⚠ Не нашёл блок "Только грамматика" — возможно, уже обновлён')
PYEOF
echo ""

# ============ 2. Обновляем dashboard.js ============
echo "[2/4] Добавляю логику перехода"
cat >> dashboard.js << 'JSEOF'

// ============================================
// Грамматика → сразу в нужный урок
// ============================================
(function(){
  function gotoLesson(e){
    var link = e.target.closest('[data-goto-lesson]');
    if (!link) return;
    e.preventDefault();

    // Пытаемся получить уровень и прогресс
    fetch('/api/me', { credentials:'same-origin' })
      .then(function(r){ return r.json(); })
      .then(function(d){
        if (!d || !d.ok){ location.href = '/lesson?id=a1-01&level=A1'; return; }
        var p = d.profile || {};
        var level = p.level || 'A1';
        var prog = p.unitProgress || {};

        fetch('/api/curriculum?level=' + level, { credentials:'same-origin' })
          .then(function(r){ return r.json(); })
          .then(function(cd){
            if (!cd || !cd.ok || !cd.units || !cd.units.length){
              location.href = '/lesson?id=a1-01&level=A1';
              return;
            }
            // Логика: первый незавершённый, иначе следующий после последнего, иначе первый
            var target = null;
            // 1. Незавершённые (best < 80) — берём первый
            for (var i = 0; i < cd.units.length; i++){
              var u = cd.units[i];
              var done = prog[u.id];
              if (!done || (done.best || 0) < 80){
                target = u;
                break;
              }
            }
            // 2. Всё пройдено — берём следующий уровень или первый юнит текущего
            if (!target) target = cd.units[0];
            location.href = '/lesson?id=' + target.id + '&level=' + level;
          })
          .catch(function(){ location.href = '/lesson?id=a1-01&level=A1'; });
      })
      .catch(function(){ location.href = '/lesson?id=a1-01&level=A1'; });
  }

  document.addEventListener('click', gotoLesson, true);
})();
JSEOF
echo "  ✓ Логика добавлена"
echo ""

# ============ 3. Обновляем кэш ============
echo "[3/4] Обновляю кэш"
for HTML in *.html; do
  [ -f "$HTML" ] || continue
  perl -i -pe "s/dashboard\.js\?v=\d+/dashboard.js?v=12/g" "$HTML"
done
echo "  ✓ Кэш обновлён"
echo ""

# ============ 4. Перезапуск сервера ============
echo "[4/4] Перезапускаю сервер"
lsof -ti:12000 2>/dev/null | xargs kill -9 2>/dev/null
pkill -f "node server.js" 2>/dev/null
sleep 1

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
  echo "  • Карточка 'Только грамматика' ведёт СРАЗУ в урок"
  echo "  • Логика:"
  echo "     1) первый незавершённый урок (best < 80%)"
  echo "     2) если все завершены — следующий юнит"
  echo "     3) если ничего не начато — первый юнит A1"
  echo ""
  echo "Обнови браузер Cmd+Shift+R"
  echo "Открой http://localhost:12000/dashboard"
  echo "Нажми 'Только грамматика' → сразу откроется урок"
else
  echo "  ⚠ Сервер: $CODE"
  cat /tmp/ioma_server.log
fi
