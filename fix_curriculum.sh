#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  ФИКС: Только грамматика"
echo "============================================"
echo ""

mkdir -p _unused/backup
cp dashboard.html "_unused/backup/dashboard.html.$(date +%Y%m%d_%H%M%S)"
cp dashboard.js "_unused/backup/dashboard.js.$(date +%Y%m%d_%H%M%S)"

# 1. Проверяем, есть ли якорь #curriculum в dashboard.html
echo "[1/3] Проверяю якорь #curriculum"
if grep -q 'id="curriculum"' dashboard.html; then
  echo "  ✓ Якорь есть"
else
  echo "  + Добавляю якорь"
  # Ищем блок curriculum-block и добавляем id
  perl -i -pe 's{<section class="curriculum-block">}{<section class="curriculum-block" id="curriculum">}g' dashboard.html
  if grep -q 'id="curriculum"' dashboard.html; then
    echo "  ✓ Якорь добавлен"
  else
    echo "  ✗ Не нашёл блок curriculum-block в dashboard.html"
    echo "     Проверь вручную — там должна быть секция с классом curriculum-block"
  fi
fi
echo ""

# 2. Чиним ссылку в dashboard.html
echo "[2/3] Чиним ссылку 'Только грамматика'"
# В dashboard.html внутри mode-card ведёт href="/dashboard#curriculum"
if grep -q '/dashboard#curriculum' dashboard.html; then
  perl -i -pe "s{/dashboard#curriculum}{/dashboard#curriculum}g" dashboard.html
  echo "  ✓ Ссылка /dashboard#curriculum на месте"
else
  echo "  ⚠ Не нашёл ссылку /dashboard#curriculum — возможно, другой путь"
fi
echo ""

# 3. Плавный скролл к якорю при загрузке
echo "[3/3] Добавляю скролл к якорю при загрузке"
cat >> dashboard.js << 'JSEOF'

// ============================================
// Плавный скролл к якорю #curriculum
// ============================================
(function(){
  function scrollToHash(){
    if (!location.hash) return;
    var id = location.hash.slice(1);
    var el = document.getElementById(id);
    if (!el) {
      console.warn('[anchor]', 'Не найден элемент #' + id);
      return;
    }
    setTimeout(function(){
      el.scrollIntoView({ behavior:'smooth', block:'start' });
    }, 400);
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', scrollToHash);
  } else {
    scrollToHash();
  }
  window.addEventListener('hashchange', scrollToHash);
})();
JSEOF
echo "  ✓ Скролл добавлен"
echo ""

echo "============================================"
echo "  ГОТОВО"
echo "============================================"
echo ""
echo "Что сделано:"
echo "  • Проверен и при необходимости добавлен id='curriculum'"
echo "  • Добавлен плавный скролл к якорю при загрузке /dashboard"
echo ""
echo "Проверка:"
echo "  cd ~/Desktop/ENGLISH_SITE && npm start"
echo "  http://localhost:12000/dashboard#curriculum"
