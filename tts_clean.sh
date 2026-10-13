#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  TTS: убираю выбор голоса"
echo "============================================"
echo ""

mkdir -p _unused/backup
TS=$(date +%Y%m%d_%H%M%S)
[ -f "tts.js" ] && cp "tts.js" "_unused/backup/tts.js.$TS"
echo "✓ Бэкап"
echo ""

# ---------- 1. Перезаписываю tts.js ----------
echo "[1/3] Пишу чистый tts.js"
cat > tts.js << 'TTSJSEOF'
(function(){
  if (window.__iomaTTS2) return;
  window.__iomaTTS2 = true;

  var audio = null;
  var url = null;

  function stop(){
    if (audio){ try { audio.pause(); } catch(e){} audio = null; }
    if (url){ try { URL.revokeObjectURL(url); } catch(e){} url = null; }
    if ('speechSynthesis' in window) speechSynthesis.cancel();
    var btn = document.getElementById('iomaPlayBtn');
    if (btn){
      btn.textContent = 'Озвучить';
      btn.disabled = false;
      btn.classList.remove('ioma-playing');
    }
    var stopBtn = document.getElementById('iomaStopBtn');
    if (stopBtn) stopBtn.style.display = 'none';
  }

  async function speakText(text, lang){
    stop();
    if (!text || !text.trim()) return;
    var btn = document.getElementById('iomaPlayBtn');
    if (btn){ btn.textContent = 'Загрузка…'; btn.disabled = true; }
    lang = lang || (/[а-яА-Я]/.test(text) ? 'ru' : 'en');
    try {
      var r = await fetch('/api/tts', {
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body: JSON.stringify({ text: text.trim().slice(0,3500), lang: lang, gender: 'female' })
      });
      if (!r.ok) throw new Error('HTTP ' + r.status);
      var blob = await r.blob();
      url = URL.createObjectURL(blob);
      audio = new Audio(url);
      audio.onended = stop;
      audio.onerror = stop;
      await audio.play();
      if (btn){ btn.textContent = 'Стоп'; btn.disabled = false; btn.classList.add('ioma-playing'); }
    } catch(e){
      // Fallback на встроенный
      try {
        var u = new SpeechSynthesisUtterance(text);
        u.lang = lang === 'ru' ? 'ru-RU' : 'en-GB';
        u.onend = stop; u.onerror = stop;
        speechSynthesis.cancel();
        speechSynthesis.speak(u);
        if (btn){ btn.textContent = 'Стоп'; btn.disabled = false; btn.classList.add('ioma-playing'); }
      } catch(e2){
        if (btn){ btn.textContent = 'Озвучить'; btn.disabled = false; }
      }
    }
  }

  function speakPage(){
    var main = document.querySelector('main') || document.body;
    var clone = main.cloneNode(true);
    clone.querySelectorAll('.topbar,.footer,.assist-fab,.assist-overlay,script,style,.ioma-tts-btn,.ioma-tts-stop').forEach(function(el){ el.remove(); });
    var text = clone.textContent.replace(/\s+/g, ' ').trim().slice(0, 3500);
    if (!text) return;
    var lang = /[а-яА-Я]/.test(text) ? 'ru' : 'en';
    speakText(text, lang);
  }

  function buildUI(){
    var topbar = document.querySelector('.topbar-right');
    if (!topbar || document.getElementById('iomaPlayBtn')) return;

    var play = document.createElement('button');
    play.id = 'iomaPlayBtn';
    play.type = 'button';
    play.className = 'ioma-tts-btn';
    play.textContent = 'Озвучить';
    play.addEventListener('click', function(){
      if (play.classList.contains('ioma-playing')) stop();
      else speakPage();
    });

    topbar.insertBefore(play, topbar.firstChild);
  }

  function init(){ buildUI(); }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();

  document.addEventListener('visibilitychange', function(){ if (document.hidden) stop(); });
  window.addEventListener('beforeunload', stop);
  window.addEventListener('pagehide', stop);

  window.iomaTTS2 = { speak: speakPage, stop: stop };
})();
TTSJSEOF
echo "  ✓ tts.js готов"
echo ""

# ---------- 2. Добавляю стили ----------
echo "[2/3] Добавляю стили .ioma-tts-btn"
cat >> styles.css << 'CSSEOF'

/* ============================================
   TTS BUTTON в топбаре
   ============================================ */
.ioma-tts-btn{
  display:inline-flex;
  align-items:center;
  justify-content:center;
  background:transparent;
  border:1px solid var(--border-2);
  color:var(--text);
  padding:8px 14px;
  font-family:var(--sans);
  font-size:12px;
  font-weight:600;
  letter-spacing:.08em;
  text-transform:uppercase;
  cursor:pointer;
  transition:all .2s var(--ease);
  outline:none;
  margin-right:8px;
}
.ioma-tts-btn:hover{
  border-color:var(--text);
  background:var(--text);
  color:var(--bg);
}
.ioma-tts-btn:disabled{
  opacity:.5;
  cursor:wait;
}
.ioma-tts-btn.ioma-playing{
  background:var(--text);
  color:var(--bg);
  border-color:var(--text);
}
.ioma-tts-btn.ioma-playing::before{
  content:"";
  display:inline-block;
  width:8px;
  height:8px;
  background:var(--bg);
  border-radius:50%;
  margin-right:8px;
  animation:ttsPulse 1.2s ease-in-out infinite;
}
@keyframes ttsPulse{0%,100%{opacity:1}50%{opacity:.3}}

/* Убираем старые элементы если остались */
.ioma-gender-select,
.ioma-tts-stop,
#iomaGenderSelect,
#iomaStopBtn{
  display:none !important;
}
CSSEOF
echo "  ✓ Стили добавлены"
echo ""

# ---------- 3. Проверка ----------
echo "[3/3] Проверяю"
lsof -ti:12000 | xargs kill -9 2>/dev/null
sleep 1

node server.js > /tmp/ioma_tts.log 2>&1 &
PID=$!
sleep 2

FAIL=0
for PAGE in / /dashboard /test /lesson /vocabulary /speaking /listening /writing; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$PAGE")
  [ "$CODE" != "200" ] && echo "  ✗ $PAGE → $CODE" && FAIL=$((FAIL+1))
done
for ASSET in /tts.js /styles.css; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$ASSET")
  [ "$CODE" != "200" ] && echo "  ✗ $ASSET → $CODE" && FAIL=$((FAIL+1))
done

kill $PID 2>/dev/null
wait $PID 2>/dev/null

echo ""
echo "============================================"
if [ $FAIL -eq 0 ]; then
  echo "  ✓ ГОТОВО"
  echo "============================================"
  echo ""
  echo "Что изменилось:"
  echo "  • Убран выпадающий список выбора голоса"
  echo "  • Убрана кнопка Стоп (Стоп теперь — та же кнопка)"
  echo "  • Кнопка «ОЗВУЧИТЬ» в общем минималистичном стиле"
  echo "  • При воспроизведении кнопка становится «СТОП» с пульсирующей точкой"
  echo ""
  echo "Запуск: npm start"
else
  echo "  ⚠ ПРОБЛЕМ: $FAIL"
  echo "  Лог: /tmp/ioma_tts.log"
fi
echo "============================================"
