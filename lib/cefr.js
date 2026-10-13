const LEVELS = [
  { code:'A1', name:'Beginner',           ru:'Начальный',      color:'#a8b3c4' },
  { code:'A2', name:'Elementary',         ru:'Элементарный',   color:'#7d9fc7' },
  { code:'B1', name:'Intermediate',       ru:'Средний',        color:'#4a8fc7' },
  { code:'B2', name:'Upper-Intermediate', ru:'Выше среднего',  color:'#2f6fa8' },
  { code:'C1', name:'Advanced',           ru:'Продвинутый',    color:'#c9a961' },
  { code:'C2', name:'Proficiency',        ru:'Свободный',      color:'#e8c878' }
];
function idx(c){ return LEVELS.findIndex(l => l.code === c); }
function next(c){ const i = idx(c); return (i >= 0 && i < LEVELS.length - 1) ? LEVELS[i+1] : null; }
function fromScore(p){
  if (p < 25) return 'A1'; if (p < 45) return 'A2'; if (p < 65) return 'B1';
  if (p < 80) return 'B2'; if (p < 92) return 'C1'; return 'C2';
}
function progressToNext(code, p){
  const ranges = { A1:[0,25], A2:[25,45], B1:[45,65], B2:[65,80], C1:[80,92], C2:[92,100] };
  const r = ranges[code] || [0,100];
  if (p <= r[0]) return 0;
  if (p >= r[1]) return 100;
  return Math.round(((p - r[0]) / (r[1] - r[0])) * 100);
}
module.exports = { LEVELS, idx, next, fromScore, progressToNext };