// lib/curriculum/index.js
// Собран автоматически. Данные уроков править в a1.json, a2.json, ..., c2.json.

function safeLoad(file, fallbackName) {
  try {
    return require(file);
  } catch (e) {
    console.warn('[curriculum] не удалось загрузить ' + file + ': ' + e.message);
    return { book: fallbackName || '', units: [] };
  }
}

const CURRICULUM = {
  A1: safeLoad('./a1.json', 'Essential Grammar in Use'),
  A2: safeLoad('./a2.json', 'Essential Grammar in Use'),
  B1: safeLoad('./b1.json', 'English Grammar in Use'),
  B2: safeLoad('./b2.json', 'English Grammar in Use'),
  C1: safeLoad('./c1.json', 'Advanced Grammar in Use'),
  C2: safeLoad('./c2.json', 'Advanced Grammar in Use')
};

module.exports = { CURRICULUM };
