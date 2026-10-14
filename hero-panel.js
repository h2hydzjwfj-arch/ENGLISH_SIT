(function () {
  if (window.__heroPaper) return;
  window.__heroPaper = true;

  // Предложения с ошибками и исправлениями
  var SENTENCES = [
    { before: 'She ',    wrong: 'go',           after: ' to school every day.',  right: 'goes' },
    { before: 'I have ', wrong: 'saw',          after: ' this film before.',     right: 'seen' },
    { before: 'If I ',   wrong: 'was',          after: ' you, I would go.',      right: 'were' },
    { before: 'He ',     wrong: "don't",        after: ' like coffee.',          right: "doesn't" },
    { before: 'They ',   wrong: 'was',          after: ' at home yesterday.',    right: 'were' },
    { before: 'She said she ', wrong: 'will',   after: ' come later.',           right: 'would' },
    { before: 'The book was ', wrong: 'wrote',  after: ' by Hemingway.',         right: 'written' },
    { before: 'I ',      wrong: 'am living',    after: ' here since 2020.',      right: 'have been living' }
  ];

  function init() {
    var sentence = document.getElementById('paperSentence');
    var check = document.getElementById('paperCheck');
    if (!sentence) return;

    var idx = 0;

    function render(item) {
      return ''
        + '<span class="paper-before">' + item.before + '</span>'
        + '<span class="paper-wrong">'
        +   '<span class="paper-correction">' + item.right + '</span>'
        +   item.wrong
        + '</span>'
        + '<span class="paper-after">' + item.after + '</span>';
    }

    function play() {
      var item = SENTENCES[idx];
      sentence.classList.remove('fade-out');
      sentence.innerHTML = render(item);
      if (check) check.classList.remove('on');

      var wrong = sentence.querySelector('.paper-wrong');

      // 1. Предложение появляется, ждём 1.6 сек
      setTimeout(function () {
        // 2. Красная линия зачёркивания
        if (wrong) wrong.classList.add('struck');

        // 3. Красная поправка появляется
        setTimeout(function () {
          if (wrong) wrong.classList.add('corrected');

          // 4. Галочка "checked by teacher" внизу
          setTimeout(function () {
            if (check) check.classList.add('on');

            // 5. Пауза 2.2 сек, потом fade-out и следующее
            setTimeout(function () {
              sentence.classList.add('fade-out');
              if (check) check.classList.remove('on');
              setTimeout(function () {
                idx = (idx + 1) % SENTENCES.length;
                play();
              }, 500);
            }, 2200);
          }, 250);
        }, 500);
      }, 1600);
    }

    // Старт через 600 мс после загрузки
    setTimeout(play, 600);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
