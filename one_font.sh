#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  ОДИН ШРИФТ ВЕЗДЕ"
echo "============================================"
echo ""

mkdir -p _unused/backup
cp styles.css "_unused/backup/styles.css.$(date +%Y%m%d_%H%M%S)"
echo "✓ Бэкап"
echo ""

# ============ 1. Убиваем Cormorant и все серифы ============
echo "[1/3] Убираю все серифы и Cormorant"

# Удаляем @import с Google Fonts (если остался)
sed -i.bak "/@import url/d" styles.css
rm -f styles.css.bak

# Убираем все упоминания Cormorant, Georgia, serif
python3 << 'PYEOF'
import re
with open('styles.css','r') as f:
    css = f.read()

# Заменяем переменные шрифтов
css = re.sub(r"--serif:[^;]+;", "--serif:var(--sans);", css)
css = re.sub(r"--display:[^;]+;", "--display:var(--sans);", css)

# Убираем прямые упоминания Cormorant/Georgia/Times
css = css.replace("'Cormorant Garamond'", "inherit")
css = css.replace("Georgia, 'Times New Roman', serif", "inherit")
css = css.replace("Georgia", "inherit")

# Убираем font-style:italic, где он не нужен (везде кроме .ioma-affirm и похожих)
css = re.sub(r"font-style:\s*italic\s*!important;", "", css)
css = re.sub(r"font-style:\s*italic;", "", css)

with open('styles.css','w') as f:
    f.write(css)
print('  ✓ Серифы убраны, курсивы убраны')
PYEOF
echo ""

# ============ 2. Единая типографика ============
echo "[2/3] Единая типографика"
cat >> styles.css << 'CSSEOF'

/* ============================================
   ЕДИНАЯ ТИПОГРАФИКА
   Inter — везде.
   Courier New — только в полях для письма.
   ============================================ */

/* Все заголовки */
h1,h2,h3,h4,h5,h6{
  font-family:var(--sans) !important;
  font-weight:900 !important;
  letter-spacing:-.04em !important;
  line-height:1.05 !important;
  font-style:normal !important;
  text-transform:uppercase;
}

h1{font-size:clamp(38px,6vw,80px) !important;letter-spacing:-.05em !important}
h2{font-size:clamp(26px,3.6vw,44px) !important}
h3{font-size:22px !important;font-weight:800 !important;letter-spacing:-.02em !important}
h4{font-size:16px !important;font-weight:700 !important;letter-spacing:-.01em !important;text-transform:none !important}

/* Убираем курсивы отовсюду */
.eyebrow,.lede,.lh-eyebrow,.sh-eyebrow,.wh-eyebrow,.vh-eyebrow,.stage-eyebrow,
.lh-name,.result-name,.spk-prompt,.fb-better,.wr-corrected,.lo-text,
.lesson-rule h2,.method-item b,.footer span,.ioma-affirm,
.wr-overall .wr-lvl,.fb-overall-value{
  font-family:var(--sans) !important;
  font-style:normal !important;
}

/* Эти элементы — с сохранением мягкости, но тем же шрифтом */
.lede{
  font-size:17px !important;
  font-weight:400 !important;
  letter-spacing:-.005em !important;
  line-height:1.65 !important;
  text-transform:none !important;
  color:var(--text-muted) !important;
}

.lh-name,.result-name{
  font-size:18px !important;
  font-weight:400 !important;
  color:var(--text-muted) !important;
  text-transform:none !important;
}

.ioma-affirm{
  font-size:18px !important;
  font-weight:400 !important;
  letter-spacing:-.005em !important;
}

/* Eyebrow — тонкая метка UPPERCASE */
.eyebrow,.lh-eyebrow,.sh-eyebrow,.wh-eyebrow,.vh-eyebrow,.stage-eyebrow{
  font-family:var(--mono) !important;
  font-size:11px !important;
  font-weight:500 !important;
  letter-spacing:.22em !important;
  text-transform:uppercase !important;
  font-style:normal !important;
}

/* Task label — не курсив */
.wt-label,.st-label,.lo-label,.lesson-rule h2,.fb-section h4,.wr-section h4{
  font-family:var(--mono) !important;
  font-size:11.5px !important;
  font-weight:600 !important;
  letter-spacing:.16em !important;
  text-transform:uppercase !important;
  font-style:normal !important;
  color:var(--text) !important;
}

/* Большие числа — моно */
.stat b,.sc-value,.vs-value,.lh-level,.result-level,.skill-level,
.fb-overall-value,.wr-score-big,.wr-overall .wr-lvl,.fb-crit-score,.wr-crit-score{
  font-family:var(--mono) !important;
  font-weight:600 !important;
  letter-spacing:-.02em !important;
  font-style:normal !important;
}

/* ============================================
   ПЕЧАТНАЯ МАШИНКА — только в полях для письма
   ============================================ */
#writingInput,
#wrtInput,
#lstAnswer{
  font-family:'Courier New','American Typewriter',monospace !important;
  font-size:16px !important;
  line-height:1.75 !important;
  letter-spacing:.01em !important;
  font-weight:400 !important;
  text-transform:none !important;
}

#writingInput::placeholder,
#wrtInput::placeholder,
#lstAnswer::placeholder{
  font-family:'Courier New','American Typewriter',monospace !important;
  font-style:italic !important;
  font-weight:400 !important;
  color:var(--text-dim) !important;
  text-transform:none !important;
}

/* Прочие textarea — Inter (не машинка) */
input[type=text],
input[type=email],
input[type=password],
input[type=tel],
.va-row input,
.assist-foot textarea,
.auth-input{
  font-family:var(--sans) !important;
  text-transform:none !important;
}

/* ============================================
   Все кнопки — Inter, UPPERCASE, тонкие
   ============================================ */
.btn-primary,.btn-ghost,.cta-mini,.lh-cta,.stage-btn,
.lst-play,.lst-slow,.spk-btn,.wt-new,.cr-show,.cr-btn,
.assist-send,.play-btn,.record-btn{
  font-family:var(--sans) !important;
  font-weight:700 !important;
  letter-spacing:.06em !important;
  text-transform:uppercase !important;
  font-size:12px !important;
  font-style:normal !important;
}

/* ============================================
   Маленькие метки — моно UPPERCASE
   ============================================ */
.feature-num,.unit-id,.unit-progress,.q-meta,
.sc-label,.skill-label,.vs-label,.mode-arrow,
.qc-num,.back-link,.level-progress-text,
.test-progress-mini span,.wrt-meta,.writing-info{
  font-family:var(--mono) !important;
  font-style:normal !important;
  font-weight:500 !important;
  letter-spacing:.1em !important;
  text-transform:uppercase !important;
}

/* ============================================
   Мелкие правки конкретных блоков
   ============================================ */

/* Task — единый стиль, без курсива и без особого размера */
.wt-text{
  font-family:var(--sans) !important;
  font-size:15.5px !important;
  line-height:1.7 !important;
  font-style:normal !important;
  text-transform:none !important;
}

/* Заголовок страницы */
.wrt-head h1,
.voc-head h1,
.spk-head h1,
.lst-head h1,
.lesson-header h1,
.test-shell h1{
  font-family:var(--sans) !important;
  font-weight:900 !important;
  letter-spacing:-.05em !important;
  text-transform:uppercase !important;
  font-style:normal !important;
}

/* Подзаголовок страницы */
.wrt-head p,
.voc-head p,
.spk-head p,
.lst-head p{
  font-family:var(--sans) !important;
  font-size:15px !important;
  font-weight:400 !important;
  letter-spacing:-.005em !important;
  text-transform:none !important;
  font-style:normal !important;
  color:var(--text-muted) !important;
  line-height:1.6 !important;
}
CSSEOF
echo "  ✓ Единая типографика установлена"
echo ""

# ============ 3. Перезапуск ============
echo "[3/3] Перезапуск"
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
  echo "Что стало:"
  echo "  • Только 2 шрифта: Inter (везде) + Courier New (в полях)"
  echo "  • Все заголовки — Inter Black UPPERCASE"
  echo "  • Все курсивы убраны"
  echo "  • Cormorant / Georgia / Times — удалены"
  echo "  • Кнопки — Inter UPPERCASE, тонкие"
  echo "  • Метки (Unit 1, Task, Writing Lab) — моно"
  echo "  • Печатная машинка ТОЛЬКО в textarea для письма"
  echo ""
  echo "Cmd+Shift+R и смотри"
else
  echo "⚠ Сервер: $CODE"
  tail -10 /tmp/ioma_server.log
fi
