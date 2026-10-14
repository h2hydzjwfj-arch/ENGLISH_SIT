(function () {
  if (window.__heroPanel) return;
  window.__heroPanel = true;

  var PHRASES = [
    { level: 'A1', text: 'She is a teacher. I am a student.' },
    { level: 'A2', text: 'I went to London last year.' },
    { level: 'B1', text: 'If I had more time, I would travel.' },
    { level: 'B1', text: 'I have been learning English for 3 years.' },
    { level: 'B2', text: 'The report was written by the manager.' },
    { level: 'B2', text: 'He said he had already finished.' },
    { level: 'C1', text: 'Hardly had he arrived when it started raining.' },
    { level: 'C1', text: 'No sooner had she left than the phone rang.' },
    { level: 'C2', text: 'The more you practise, the more fluent you become.' },
    { level: 'C2', text: 'Were I in your position, I would reconsider.' }
  ];

  function init() {
    var textEl = document.getElementById('heroPhraseText');
    var prefixEl = document.querySelector('.hero-panel-prefix');
    var fills = document.querySelectorAll('.hero-panel-skill-fill');
    if (!textEl || !prefixEl) return;

    // Фразы: печатаем, ждём, стираем, следующая
    var idx = 0;
    var charIdx = 0;
    var phase = 'typing'; // typing | waiting | erasing

    function tick() {
      var p = PHRASES[idx];
      if (phase === 'typing') {
        charIdx++;
        textEl.textContent = p.text.slice(0, charIdx) + '\u2588';
        if (charIdx >= p.text.length) {
          phase = 'waiting';
          textEl.textContent = p.text + '\u2588';
          setTimeout(tick, 2600);
          return;
        }
        setTimeout(tick, 38 + Math.random() * 42);
      } else if (phase === 'waiting') {
        phase = 'erasing';
        setTimeout(tick, 100);
      } else {
        charIdx -= 3;
        if (charIdx <= 0) {
          charIdx = 0;
          idx = (idx + 1) % PHRASES.length;
          prefixEl.textContent = 'Grammar · ' + PHRASES[idx].level;
          phase = 'typing';
          textEl.textContent = '';
          setTimeout(tick, 320);
          return;
        }
        textEl.textContent = p.text.slice(0, charIdx) + '\u2588';
        setTimeout(tick, 16);
      }
    }

    // Уровень первой фразы
    prefixEl.textContent = 'Grammar · ' + PHRASES[0].level;
    setTimeout(tick, 500);

    // Полоски: заполняем, держим, сбрасываем
    function animateBars() {
      fills.forEach(function (f, i) {
        setTimeout(function () {
          f.style.width = f.dataset.w;
        }, i * 140);
      });
      setTimeout(function () {
        fills.forEach(function (f) {
          f.style.transition = 'width 0.5s ease';
          f.style.width = '0';
        });
        setTimeout(function () {
          fills.forEach(function (f) {
            f.style.transition = 'width 1.4s cubic-bezier(0.16, 1, 0.3, 1)';
          });
          animateBars();
        }, 700);
      }, 5000);
    }
    setTimeout(animateBars, 400);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
