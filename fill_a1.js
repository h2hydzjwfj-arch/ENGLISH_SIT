// fill_a1.js — наполняет lib/curriculum/a1.json 10 юнитами
const fs = require('fs');
const path = require('path');

const A1 = {
  book: "Essential Grammar in Use · Raymond Murphy · Cambridge",
  units: [
    {
      id: "a1-01",
      title: "To be: am / is / are",
      grammar: "Глагол to be (am/is/are) = «быть, являться». В русском мы часто его опускаем, в английском он обязателен. I am — я есть, you are — ты/вы есть, he/she/it is — он/она/оно есть, we/you/they are — мы/вы/они есть. Сокращения: I'm, he's, she's, it's, we're, you're, they're.",
      exercises: [
        { q: "I ___ a student.", options: ["am", "is", "are", "be"], correct: 0 },
        { q: "She ___ my sister.", options: ["am", "is", "are", "be"], correct: 1 },
        { q: "They ___ at home.", options: ["am", "is", "are", "be"], correct: 2 },
        { q: "It ___ cold today.", options: ["am", "is", "are", "be"], correct: 1 },
        { q: "We ___ from Russia.", options: ["am", "is", "are", "be"], correct: 2 },
        { q: "He ___ a doctor.", options: ["am", "is", "are", "be"], correct: 1 }
      ]
    },
    {
      id: "a1-02",
      title: "To be: вопросы и отрицания",
      grammar: "Отрицание: am/is/are + not = am not / isn't / aren't. Вопрос: am/is/are выходит в начало. Are you ready? — Yes, I am. / No, I'm not. Is she a teacher? — Yes, she is. / No, she isn't.",
      exercises: [
        { q: "___ you ready?", options: ["Am", "Is", "Are", "Be"], correct: 2 },
        { q: "She ___ not tired.", options: ["am", "is", "are", "be"], correct: 1 },
        { q: "___ he a teacher?", options: ["Am", "Is", "Are", "Be"], correct: 1 },
        { q: "They ___ not from England.", options: ["am", "is", "are", "be"], correct: 2 },
        { q: "I ___ not hungry.", options: ["am", "is", "are", "be"], correct: 0 },
        { q: "___ it a good idea?", options: ["Am", "Is", "Are", "Be"], correct: 1 }
      ]
    },
    {
      id: "a1-03",
      title: "Personal pronouns",
      grammar: "Личные местоимения: I (я), you (ты/вы), he (он), she (она), it (оно/неодушевлённое), we (мы), they (они). Они заменяют существительные: Tom is tall → He is tall. The book is new → It is new.",
      exercises: [
        { q: "Tom is my friend. ___ is tall.", options: ["He", "She", "It", "They"], correct: 0 },
        { q: "My mum is a doctor. ___ works in a hospital.", options: ["He", "She", "It", "They"], correct: 1 },
        { q: "The book is on the table. ___ is new.", options: ["He", "She", "It", "They"], correct: 2 },
        { q: "Anna and I are friends. ___ go to school together.", options: ["He", "She", "It", "We"], correct: 3 },
        { q: "My parents live in Moscow. ___ are retired.", options: ["He", "She", "It", "They"], correct: 3 },
        { q: "You and Tom are late. ___ should hurry.", options: ["He", "She", "It", "You"], correct: 3 }
      ]
    },
    {
      id: "a1-04",
      title: "This / That / These / Those",
      grammar: "Указательные местоимения. This — это (близко, один). That — то (далеко, один). These — эти (близко, много). Those — те (далеко, много). This book (близко). Those books (далеко).",
      exercises: [
        { q: "___ is my pen. (близко)", options: ["This", "That", "These", "Those"], correct: 0 },
        { q: "___ is your bag. (далеко)", options: ["This", "That", "These", "Those"], correct: 1 },
        { q: "___ are my books. (близко, много)", options: ["This", "That", "These", "Those"], correct: 2 },
        { q: "___ are his friends. (далеко, много)", options: ["This", "That", "These", "Those"], correct: 3 },
        { q: "___ shoes are new. (близко, много)", options: ["This", "That", "These", "Those"], correct: 2 },
        { q: "___ house is big. (далеко)", options: ["This", "That", "These", "Those"], correct: 1 }
      ]
    },
    {
      id: "a1-05",
      title: "A / An — неопределённый артикль",
      grammar: "A / an = «один из многих», ставим перед существительным в единственном числе, когда упоминаем его впервые. A + согласный звук: a book, a car, a university. An + гласный звук: an apple, an egg, an hour (h не читается).",
      exercises: [
        { q: "I have ___ book.", options: ["a", "an", "the", "—"], correct: 0 },
        { q: "She has ___ umbrella.", options: ["a", "an", "the", "—"], correct: 1 },
        { q: "He is ___ doctor.", options: ["a", "an", "the", "—"], correct: 0 },
        { q: "It is ___ old house.", options: ["a", "an", "the", "—"], correct: 1 },
        { q: "I need ___ pen.", options: ["a", "an", "the", "—"], correct: 0 },
        { q: "She is ___ engineer.", options: ["a", "an", "the", "—"], correct: 1 }
      ]
    },
    {
      id: "a1-06",
      title: "Plural: множественное число",
      grammar: "Обычно +s: book → books, car → cars. После -s, -sh, -ch, -x, -o: +es: box → boxes, watch → watches. Согласная + y: -y → -ies: city → cities. Исключения: man → men, woman → women, child → children, foot → feet, tooth → teeth, mouse → mice.",
      exercises: [
        { q: "I have two ___ .", options: ["book", "books", "bookes", "bookies"], correct: 1 },
        { q: "There are three ___ in the box.", options: ["watchs", "watches", "watch", "watchies"], correct: 1 },
        { q: "She has two ___ .", options: ["childs", "child", "children", "childrens"], correct: 2 },
        { q: "There are many ___ in the city.", options: ["citys", "cities", "city", "cityes"], correct: 1 },
        { q: "My ___ hurt.", options: ["foots", "feet", "footes", "foot"], correct: 1 },
        { q: "I see three ___ .", options: ["man", "mans", "men", "mens"], correct: 2 }
      ]
    },
    {
      id: "a1-07",
      title: "Have got / Has got",
      grammar: "Have got = have (в британском английском). I have got a car = I have a car. Have got: I/you/we/they. Has got: he/she/it. Отрицание: haven't got / hasn't got. Вопрос: Have you got...? / Has she got...?",
      exercises: [
        { q: "I ___ got a new phone.", options: ["have", "has", "am", "is"], correct: 0 },
        { q: "She ___ got two brothers.", options: ["have", "has", "am", "is"], correct: 1 },
        { q: "___ you got a minute?", options: ["Have", "Has", "Do", "Are"], correct: 0 },
        { q: "He ___ got a car.", options: ["have", "has", "am", "is"], correct: 1 },
        { q: "We haven't ___ a dog.", options: ["got", "get", "gotten", "getting"], correct: 0 },
        { q: "They ___ got a big house.", options: ["have", "has", "am", "is"], correct: 0 }
      ]
    },
    {
      id: "a1-08",
      title: "There is / There are",
      grammar: "Конструкция для описания наличия: there is + ед. число, there are + мн. число. There is a cat on the sofa. There are two books on the table. Отрицание: There isn't / There aren't. Вопрос: Is there...? / Are there...?",
      exercises: [
        { q: "___ a cat on the sofa.", options: ["There is", "There are", "It is", "They are"], correct: 0 },
        { q: "___ two books on the table.", options: ["There is", "There are", "It is", "They are"], correct: 1 },
        { q: "___ any milk in the fridge?", options: ["Is there", "Are there", "It is", "They are"], correct: 0 },
        { q: "___ some apples in the bag.", options: ["There is", "There are", "It is", "They are"], correct: 1 },
        { q: "___ a park near my house.", options: ["There is", "There are", "It is", "They are"], correct: 0 },
        { q: "___ many people in the city.", options: ["There is", "There are", "It is", "They are"], correct: 1 }
      ]
    },
    {
      id: "a1-09",
      title: "Can / Can't — умение и разрешение",
      grammar: "Модальный глагол can: способность (I can swim), разрешение (Can I come in?), просьба (Can you help me?). После can глагол БЕЗ to. Отрицание: cannot / can't. Вопрос: Can you...? — Yes, I can. / No, I can't.",
      exercises: [
        { q: "I ___ swim very well.", options: ["can", "cans", "can to", "am can"], correct: 0 },
        { q: "She ___ speak German.", options: ["cannot to", "cannot", "not can", "no can"], correct: 1 },
        { q: "___ you help me?", options: ["Can", "Do", "Are", "Is"], correct: 0 },
        { q: "They ___ come tomorrow.", options: ["can to", "cans", "can", "caning"], correct: 2 },
        { q: "I ___ drive a car.", options: ["can", "cans", "can to", "am can"], correct: 0 },
        { q: "___ I open the window?", options: ["Can", "Do", "Am", "Is"], correct: 0 }
      ]
    },
    {
      id: "a1-10",
      title: "Numbers 1–100",
      grammar: "Numbers 1–10: one, two, three, four, five, six, seven, eight, nine, ten. 11–20: eleven, twelve, thirteen, fourteen, fifteen, sixteen, seventeen, eighteen, nineteen, twenty. Десятки: thirty, forty, fifty, sixty, seventy, eighty, ninety, one hundred. 21 = twenty-one, 35 = thirty-five.",
      exercises: [
        { q: "___ = 3", options: ["one", "two", "three", "four"], correct: 2 },
        { q: "___ = 12", options: ["twenty", "twelve", "ten", "two"], correct: 1 },
        { q: "___ = 40", options: ["four", "fourteen", "forty", "fourty"], correct: 2 },
        { q: "___ = 21", options: ["twenty one", "twenty-one", "two-one", "twentyone"], correct: 1 },
        { q: "___ = 100", options: ["ten", "one hundred", "thousand", "hundred"], correct: 1 },
        { q: "___ = 15", options: ["fifty", "five", "fifteen", "fiveteen"], correct: 2 }
      ]
    }
  ]
};

// --- Бэкап старого a1.json ---
const dir = path.join(__dirname, 'lib', 'curriculum');
const target = path.join(dir, 'a1.json');
const backup = path.join(__dirname, '_unused', 'a1.json.old');

if (fs.existsSync(target)) {
  fs.mkdirSync(path.dirname(backup), { recursive: true });
  fs.copyFileSync(target, backup);
  console.log('✓ Бэкап старого a1.json → _unused/a1.json.old');
}

// --- Записываем новый ---
fs.writeFileSync(target, JSON.stringify(A1, null, 2), 'utf8');
const lines = fs.readFileSync(target, 'utf8').split('\n').length;
console.log('✓ Создан a1.json: ' + A1.units.length + ' юнитов, ' + lines + ' строк');
A1.units.forEach((u, i) => console.log('  ' + (i+1) + '. ' + u.title + ' (' + u.exercises.length + ' упражнений)'));
