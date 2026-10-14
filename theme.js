/* iomaenglish — единая тема для всех страниц */
(function(){
  var BTN_ID = 'themeToggle';
  function init(){
    var btn = document.getElementById(BTN_ID);
    if (!btn) return;
    if (btn.dataset.themeInit) return;
    btn.dataset.themeInit = '1';
    btn.addEventListener('click', function(){
      var isLight = document.documentElement.classList.toggle('light');
      try { localStorage.setItem('iomaeng_theme', isLight ? 'light' : 'dark'); } catch(e){}
    });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
