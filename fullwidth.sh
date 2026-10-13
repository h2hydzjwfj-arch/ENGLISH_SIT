#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  ПОЛНАЯ ШИРИНА + всё на одном экране"
echo "============================================"
echo ""

# Сначала — восстановить сервер если битый
if ! node -c server.js 2>/dev/null; then
  echo "[0/3] server.js битый — восстанавливаю из бэкапа"
  LATEST=$(ls -t _unused/backup/server.js.* 2>/dev/null | head -1)
  if [ -n "$LATEST" ]; then
    cp "$LATEST" server.js
    node -c server.js 2>/dev/null && echo "  ✓ Восстановлен"
  fi
else
  echo "[0/3] server.js валиден"
fi
echo ""

mkdir -p _unused/backup
cp styles.css "_unused/backup/styles.css.$(date +%Y%m%d_%H%M%S)"
echo "✓ Бэкап styles.css"
echo ""

# ============ 1. ГЛОБАЛЬНО: расширяем все оболочки ============
echo "[1/3] Расширяю все страницы на всю ширину"

cat >> styles.css << 'CSSEOF'

/* ============================================
   ПОЛНАЯ ШИРИНА — все страницы
   ============================================ */

/* Широкие контейнеры */
.dash-shell,
.voc-shell,
.spk-shell,
.lst-shell,
.wrt-shell,
.lesson-shell,
.test-shell,
.profile-shell{
  max-width:min(1680px, 96vw) !important;
  margin:0 auto !important;
  padding:24px clamp(24px, 4vw, 56px) 80px !important;
}

/* Hero — тоже шире */
.hero{
  max-width:min(1680px, 96vw) !important;
  padding:48px clamp(24px, 4vw, 56px) 60px !important;
}
.hero-copy{max-width:100% !important}
.hero h1{font-size:clamp(48px, 7vw, 120px) !important;line-height:1 !important;margin-bottom:20px !important}
.lede{font-size:17px !important;max-width:720px !important;margin-bottom:28px !important}

/* Features / Method */
.features,.method{
  max-width:min(1680px, 96vw) !important;
  padding:40px clamp(24px, 4vw, 56px) 80px !important;
}

/* ============================================
   WRITING — 2 колонки (Task слева, поле справа)
   ============================================ */
.wrt-shell{
  display:grid !important;
  grid-template-columns:minmax(340px, 1fr) minmax(500px, 1.4fr) !important;
  grid-template-areas:
    "head head"
    "task editor"
    "actions result" !important;
  gap:24px 32px !important;
  align-items:start !important;
}
.wrt-head{grid-area:head !important;margin-bottom:8px !important}
.wrt-head h1{font-size:clamp(36px, 5vw, 72px) !important;margin-bottom:10px !important}
.wrt-task{grid-area:task !important;margin-bottom:0 !important;padding:24px 26px !important}
.wrt-editor{grid-area:editor !important;margin-bottom:0 !important;display:flex !important;flex-direction:column !important}
#wrtInput{
  flex:1 !important;
  min-height:280px !important;
  width:100% !important;
}
.wrt-actions{grid-area:actions !important;margin-bottom:0 !important;padding:0 !important;display:flex !important;gap:16px !important;align-items:center !important}
.wrt-result{grid-area:result !important;margin-top:0 !important;max-height:60vh;overflow-y:auto}

/* ============================================
   LESSON — правило и упражнение рядом? Нет, но шире
   ============================================ */
.lesson-shell{
  max-width:min(1400px, 94vw) !important;
  padding:32px clamp(24px, 4vw, 56px) 100px !important;
}
.lesson-header{margin-bottom:20px !important}
.lesson-header h1{font-size:clamp(32px, 4vw, 56px) !important;margin-bottom:8px !important}
.lesson-rule{padding:20px 24px !important;margin-bottom:16px !important}
.lesson-rule p{font-size:15px !important;line-height:1.6 !important}
.lesson-exercises{padding:22px 24px !important}
.exercise{margin-bottom:18px !important;padding-bottom:16px !important}
.ex-q{font-size:16px !important;margin-bottom:10px !important}
.ex-options{display:grid !important;grid-template-columns:repeat(2, 1fr) !important;gap:8px !important}
.ex-opt{padding:10px 14px !important;font-size:13.5px !important}

/* ============================================
   TEST — шире и компактнее
   ============================================ */
.test-shell{
  max-width:min(1100px, 92vw) !important;
  padding:32px clamp(24px, 4vw, 56px) 100px !important;
}
.stage-card{padding:40px 48px !important}
.stage-card h1{font-size:clamp(30px, 4vw, 52px) !important;margin-bottom:14px !important}
.stage-lede{font-size:15px !important;line-height:1.55 !important;margin-bottom:24px !important;max-width:100% !important}
.rules-list{
  display:grid !important;
  grid-template-columns:repeat(3, 1fr) !important;
  gap:12px !important;
  margin-bottom:28px !important;
  max-width:100% !important;
}
.rule{padding:14px 16px !important;gap:10px !important;flex-direction:column !important;align-items:flex-start !important}
.rule div{font-size:13px !important;line-height:1.5 !important}
.rule span{font-size:18px !important}
.question-card{padding:26px 28px !important}
.q-options{display:grid !important;grid-template-columns:repeat(2, 1fr) !important;gap:8px !important}
.q-option{padding:12px 16px !important;font-size:14px !important}
.q-sentence{font-size:20px !important;padding:16px 20px !important;margin-bottom:18px !important}

/* Reading — текст слева, вопросы справа */
.reading-block{
  display:grid !important;
  grid-template-columns:1.2fr 1fr !important;
  gap:32px !important;
  padding:24px 28px !important;
}
.reading-text{
  font-size:15px !important;
  line-height:1.7 !important;
  padding:0 !important;
  margin:0 !important;
  border-bottom:none !important;
  border-right:1px solid var(--border) !important;
  padding-right:28px !important;
}
.reading-questions{gap:16px !important}
.rq{padding-bottom:14px !important;margin-bottom:14px !important}
.rq-options{grid-template-columns:1fr !important}

/* ============================================
   VOCABULARY / SPEAKING / LISTENING — шире
   ============================================ */
.voc-shell,.spk-shell,.lst-shell{
  max-width:min(1400px, 94vw) !important;
}
.voc-head h1,.spk-head h1,.lst-head h1{
  font-size:clamp(32px, 4.5vw, 64px) !important;
  margin-bottom:8px !important;
}
.voc-head p,.spk-head p,.lst-head p{
  font-size:15px !important;line-height:1.6 !important;max-width:720px !important;
}

/* Vocabulary — 3 колонки */
.voc-shell{
  display:grid !important;
  grid-template-columns:1fr 1fr !important;
  grid-template-areas:
    "head head"
    "stats add"
    "review list" !important;
  gap:24px 28px !important;
  align-items:start !important;
}
.voc-head{grid-area:head !important;margin-bottom:0 !important}
.voc-stats{grid-area:stats !important;margin-bottom:0 !important}
.voc-add{grid-area:add !important;margin-bottom:0 !important}
.voc-review{grid-area:review !important;margin-bottom:0 !important}
.voc-list{grid-area:list !important;margin-bottom:0 !important;max-height:60vh;overflow-y:auto}

/* Listening */
.lst-card{
  display:grid !important;
  grid-template-columns:1fr 1fr !important;
  gap:24px 32px !important;
  padding:28px 32px !important;
}
.lst-card > .lst-meta,
.lst-card > .lst-title,
.lst-card > .lst-controls,
.lst-card > .lst-nav{
  grid-column:1 / -1 !important;
}
.lst-title{font-size:28px !important;margin-bottom:14px !important}
.lst-controls{margin-bottom:20px !important;justify-content:flex-start !important}
.lst-input{grid-column:1 !important}
.lst-original,.lst-result{grid-column:2 !important}
.lst-nav{margin-top:14px !important}

/* Speaking — широко, по центру */
.spk-shell{
  max-width:min(1000px, 92vw) !important;
}
.spk-prompt{font-size:20px !important;padding:24px 28px !important;margin-bottom:24px !important}

/* ============================================
   DASHBOARD — используем всю ширину
   ============================================ */
.dash-shell{
  max-width:min(1680px, 96vw) !important;
  padding:24px clamp(24px, 4vw, 56px) 80px !important;
}
.level-hero{
  padding:32px 40px !important;
  margin-bottom:20px !important;
  gap:40px !important;
}
.lh-level{font-size:clamp(64px, 9vw, 140px) !important}

/* Mode grid — 3 колонки на широком, 2 на среднем */
.mode-grid{
  grid-template-columns:repeat(auto-fill, minmax(260px, 1fr)) !important;
}
.mode-card{min-height:180px !important;padding:22px 24px 0 !important}

/* Stat row — 4 в линию на всю ширину */
.stat-row{margin-bottom:32px !important}

/* Units grid — больше в ряд */
.units-grid{
  grid-template-columns:repeat(auto-fill, minmax(240px, 1fr)) !important;
}

/* Quick links — 4 в ряд */
.quick-links{
  grid-template-columns:repeat(4, 1fr) !important;
}

/* ============================================
   PROFILE — на всю ширину
   ============================================ */
.profile-shell{
  max-width:min(1400px, 94vw) !important;
  padding:32px clamp(24px, 4vw, 56px) 80px !important;
}
.profile-hero{padding:32px 36px !important;margin-bottom:24px !important}
.stat-grid{grid-template-columns:repeat(4, 1fr) !important;gap:12px !important}
.skill-grid{grid-template-columns:repeat(5, 1fr) !important;gap:12px !important}

/* ============================================
   Прочие ужимания
   ============================================ */
.section{margin-bottom:32px !important}
.section h2{margin-bottom:20px !important;padding-bottom:14px !important}

/* Уменьшаем вертикальные отступы у карточек */
.card{padding:22px 24px !important}
.feature-card{padding:28px 26px !important}
.method-item{padding:20px 24px !important;grid-template-columns:180px 1fr !important;gap:24px !important}

/* ============================================
   Мобильные — откат к 1 колонке
   ============================================ */
@media (max-width:1024px){
  .wrt-shell,
  .voc-shell,
  .lst-card,
  .reading-block{
    grid-template-columns:1fr !important;
    grid-template-areas:
      "head"
      "task"
      "editor"
      "actions"
      "result" !important;
  }
  .lst-card > *{grid-column:1 !important}
  .lst-input,.lst-original,.lst-result{grid-column:1 !important}
  .reading-text{border-right:none !important;border-bottom:1px solid var(--border) !important;padding-right:0 !important;padding-bottom:20px !important;margin-bottom:20px !important}
  .voc-shell{
    grid-template-areas:
      "head"
      "stats"
      "add"
      "review"
      "list" !important;
  }
  .q-options,.ex-options,.rules-list{
    grid-template-columns:1fr !important;
  }
  .quick-links{grid-template-columns:repeat(2, 1fr) !important}
  .stat-grid,.skill-grid{grid-template-columns:repeat(2, 1fr) !important}
}

@media (max-width:640px){
  .dash-shell,.voc-shell,.spk-shell,.lst-shell,.wrt-shell,.lesson-shell,.test-shell,.profile-shell{
    padding:16px 18px 80px !important;
  }
  .quick-links,.stat-grid,.skill-grid{grid-template-columns:1fr !important}
}
CSSEOF
echo "  ✓ Стили добавлены"
echo ""

# ============ 2. Проверка ============
echo "[2/3] Проверяю"
lsof -ti:12000 2>/dev/null | xargs kill -9 2>/dev/null
pkill -f "node server.js" 2>/dev/null
sleep 1
nohup node server.js > /tmp/ioma_server.log 2>&1 & disown
sleep 3

CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:12000/)
echo ""
echo "[3/3] Итог"
echo "============================================"
if [ "$CODE" = "200" ]; then
  echo "  ✓ Сервер работает"
  echo "============================================"
  echo ""
  echo "Что изменилось:"
  echo "  • Все страницы на всю ширину (max 1680px вместо 760-880)"
  echo "  • Writing: 2 колонки — Task слева, поле справа"
  echo "  • Vocabulary: 2 колонки — статистика и словарь рядом"
  echo "  • Reading: 2 колонки — текст слева, вопросы справа"
  echo "  • Listening: 2 колонки — плеер и ответ рядом"
  echo "  • Test: правила в 3 колонки, ответы в 2 колонки"
  echo "  • Dashboard: юниты шире (больше в ряд)"
  echo "  • Мобильные — откат к 1 колонке автоматически"
  echo ""
  echo "Cmd+Shift+R и смотри /writing"
else
  echo "  ⚠ Сервер: $CODE"
  tail -15 /tmp/ioma_server.log
fi
