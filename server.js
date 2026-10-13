require('dotenv').config();
const express = require('express');
const cookieParser = require('cookie-parser');
const rateLimit = require('express-rate-limit');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');
const cefr = require('./lib/cefr');
const { CURRICULUM } = require('./lib/curriculum');
const { MATERIALS } = require('./lib/materials');
const { LISTENING, READING, WRITING_TASKS, SPEAKING_TOPICS } = require('./lib/media');
const { nextReview } = require('./lib/srs');

const app = express();
const PORT = process.env.PORT || 12000;
const ROOT = __dirname;
const PROGRESS_DIR = path.join(ROOT, 'data', 'progress');

app.use(express.json({ limit: '3mb' }));
app.use(cookieParser());
app.use(rateLimit({ windowMs: 15*60*1000, max: 500, standardHeaders: true, legacyHeaders: false }));

const STATIC = {
  '/': 'index.html', '/index.html': 'index.html',
  '/login': 'login.html',
  '/register': 'register.html',
  '/profile': 'profile.html',
  '/test': 'test.html', '/dashboard': 'dashboard.html',
  '/lesson': 'lesson.html', '/vocabulary': 'vocabulary.html',
  '/speaking': 'speaking.html', '/listening': 'listening.html', '/writing': 'writing.html',
  '/styles.css': 'styles.css', '/test.css': 'test.css',
  '/dashboard.css': 'dashboard.css', '/lesson.css': 'lesson.css',
  '/vocabulary.css': 'vocabulary.css', '/speaking.css': 'speaking.css',
  '/listening.css': 'listening.css', '/writing.css': 'writing.css',
  '/app.js': 'app.js',
  '/interactions.js': 'interactions.js',
  '/robot.js': 'robot.js',
  '/animations.js': 'animations.js', '/test.js': 'test.js',
  '/dashboard.js': 'dashboard.js', '/lesson.js': 'lesson.js',
  '/vocabulary.js': 'vocabulary.js', '/speaking.js': 'speaking.js',
  '/listening.js': 'listening.js', '/writing.js': 'writing.js',
  '/particles.js': 'particles.js',
  '/tts.js': 'tts.js',
};

Object.entries(STATIC).forEach(([route, file]) => {
  app.get(route, (req, res) => {
    const fp = path.join(ROOT, file);
    if (fs.existsSync(fp)) res.sendFile(fp);
    else res.status(404).send('Not found: ' + file);
  });
});

function readProfile(id){
  if (!id) return null;
  try { return JSON.parse(fs.readFileSync(path.join(PROGRESS_DIR, id + '.json'), 'utf8')); }
  catch(e){ return null; }
}
function writeProfile(id, data){
  fs.mkdirSync(PROGRESS_DIR, { recursive: true });
  fs.writeFileSync(path.join(PROGRESS_DIR, id + '.json'), JSON.stringify(data, null, 2), 'utf8');
}
const users = require('./lib/users');

function ensureProfile(req, res){
  const sessionId = req.cookies && req.cookies.session;
  if (sessionId){
    const u = users.findById(sessionId);
    if (u){
      let p = u.progress;
      if (!p || !p.id){
        p = { id: u.id, userId: u.id, createdAt: u.createdAt, name: u.name, email: u.email, level: null, testScores: null, testPercent: 0, progressToNext: 0, streak: 0, lastVisit: null, lastStreakDay: null, lessonsDone: 0, unitProgress: {}, vocabulary: [], achievements: [], history: [], lessonHistory: [] };
      }
      p.userId = u.id;
      p.name = u.name;
      p.email = u.email;
      return p;
    }
  }
  let id = req.cookies && req.cookies.profile;
  let p = id ? readProfile(id) : null;
  if (!p){
    id = 'g_' + crypto.randomBytes(8).toString('hex');
    res.cookie('profile', id, { httpOnly: true, sameSite: 'lax', maxAge: 365*24*3600*1000 });
    p = { id, userId: null, createdAt: Date.now(), level: null, testScores: null, testPercent: 0, progressToNext: 0, streak: 0, lastVisit: null, lastStreakDay: null, lessonsDone: 0, unitProgress: {}, vocabulary: [], achievements: [], history: [], lessonHistory: [] };
    writeProfile(id, p);
  }
  return p;
}

function persistProfile(p, res){
  try {
    if (p && p.userId){
      users.updateProgress(p.userId, p);
    } else if (p && p.id){
      writeProfile(p.id, p);
    }
  } catch(e){ console.warn('[persist]', e.message); }
}

app.get('/api/me', (req, res) => {
  const p = ensureProfile(req, res);
  const today = new Date().toISOString().slice(0,10);
  if (p.lastStreakDay !== today){
    const y = new Date(Date.now() - 86400000).toISOString().slice(0,10);
    if (p.lastStreakDay === y) p.streak = (p.streak || 0) + 1;
    else p.streak = 1;
    p.lastStreakDay = today;
  }
  p.lastVisit = Date.now();
  persistProfile(p, res);
  res.json({ ok: true, profile: p });
});

app.post('/api/test/submit', (req, res) => {
  const p = ensureProfile(req, res);
  const a = (req.body && req.body.answers) || {};
  const scores = { grammar:Number(a.grammar)||0, reading:Number(a.reading)||0, listening:Number(a.listening)||0, writing:Number(a.writing)||0, speaking:Number(a.speaking)||0 };
  const total = (scores.grammar + scores.reading + scores.listening + scores.writing + scores.speaking) / 5;
  const percent = Math.round(total);
  const level = cefr.fromScore(percent);
  const progress = cefr.progressToNext(level, percent);
  p.testScores = scores; p.testPercent = percent; p.level = level; p.progressToNext = progress; p.testTakenAt = Date.now();
  persistProfile(p, res);
  res.json({ ok: true, level, percent, progress, scores });
});

app.get('/api/curriculum', (req, res) => {
  const p = ensureProfile(req, res);
  const level = (req.query.level || p.level || 'A1').toUpperCase();
  const c = CURRICULUM[level];
  if (!c) return res.status(404).json({ ok:false });
  res.json({ ok:true, level, book:c.book, units:c.units });
});

app.get('/api/materials', (req, res) => {
  const p = ensureProfile(req, res);
  const level = (req.query.level || p.level || 'A1').toUpperCase();
  res.json({ ok:true, level, materials: MATERIALS[level] || MATERIALS.A1 });
});

app.post('/api/lesson/complete', (req, res) => {
  const p = ensureProfile(req, res);
  const { unitId, correct, total } = req.body || {};
  if (!unitId) return res.status(400).json({ ok:false });
  p.unitProgress = p.unitProgress || {};
  const prev = p.unitProgress[unitId] || { tries:0, correct:0, total:0, best:0 };
  const percent = Math.round(((Number(correct)||0) / (Number(total)||1)) * 100);
  prev.tries++; prev.correct += Number(correct)||0; prev.total += Number(total)||1;
  prev.best = Math.max(prev.best, percent); prev.lastAt = Date.now();
  p.unitProgress[unitId] = prev;
  p.lessonsDone = (p.lessonsDone || 0) + 1;
  if (percent >= 60 && p.testPercent != null){
    p.testPercent = Math.min(100, p.testPercent + 1);
    p.level = cefr.fromScore(p.testPercent);
    p.progressToNext = cefr.progressToNext(p.level, p.testPercent);
  }
  persistProfile(p, res);
  res.json({ ok:true, unit:prev, level:p.level });
});

app.get('/api/vocabulary', (req, res) => {
  const p = ensureProfile(req, res);
  const due = (p.vocabulary || []).filter(c => !c.due || c.due <= Date.now());
  res.json({ ok:true, all:p.vocabulary || [], dueCount:due.length });
});
app.post('/api/vocabulary/add', (req, res) => {
  const p = ensureProfile(req, res);
  const { word, translation } = req.body || {};
  if (!word) return res.status(400).json({ ok:false });
  p.vocabulary = p.vocabulary || [];
  p.vocabulary.push({ word:String(word).slice(0,100), translation:String(translation||'').slice(0,200), added:Date.now(), due:Date.now(), interval:0, ease:2.5, reps:0 });
  persistProfile(p, res);
  res.json({ ok:true, count:p.vocabulary.length });
});
app.post('/api/vocabulary/review', (req, res) => {
  const p = ensureProfile(req, res);
  const { word, quality } = req.body || {};
  const card = (p.vocabulary || []).find(c => c.word === word);
  if (!card) return res.status(404).json({ ok:false });
  Object.assign(card, nextReview(card, Number(quality)||3));
  card.lastReview = Date.now();
  persistProfile(p, res);
  res.json({ ok:true, card });
});

async function ollamaChat(system, user, maxTokens){
  const url = (process.env.OLLAMA_URL || 'http://localhost:11434') + '/api/chat';
  const r = await fetch(url, {
    method: 'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ model: process.env.OLLAMA_MODEL || 'qwen2.5:7b', messages:[{role:'system',content:system},{role:'user',content:user}], stream:false, options:{ temperature:0.5, num_predict:maxTokens||700, num_ctx:8192 } }),
    signal: AbortSignal.timeout(60000)
  });
  if (!r.ok) throw new Error('Ollama ' + r.status);
  const d = await r.json();
  return String((d && d.message && d.message.content) || '').trim();
}
async function groqChat(system, user, maxTokens){
  const key = process.env.GROQ_API_KEY;
  if (!key) throw new Error('no groq');
  const r = await fetch('https://api.groq.com/openai/v1/chat/completions', {
    method:'POST', headers:{'Authorization':'Bearer '+key,'Content-Type':'application/json'},
    body: JSON.stringify({ model:'llama-3.3-70b-versatile', messages:[{role:'system',content:system},{role:'user',content:user}], max_tokens:maxTokens||700, temperature:0.5 }),
    signal: AbortSignal.timeout(30000)
  });
  if (!r.ok) throw new Error('Groq ' + r.status);
  const d = await r.json();
  return String(d.choices && d.choices[0] && d.choices[0].message && d.choices[0].message.content || '').trim();
}
async function aiText(system, user, maxTokens){
  try { return await ollamaChat(system, user, maxTokens); } catch(e){ console.warn('[ai] ollama:', e.message); }
  try { return await groqChat(system, user, maxTokens); } catch(e){ console.warn('[ai] groq:', e.message); }
  throw new Error('AI недоступен');
}

app.post('/api/writing/check', async (req, res) => {
  try {
    const { text, task, level } = req.body || {};
    if (!text || text.trim().length < 20) return res.status(400).json({ ok:false });
    const p = ensureProfile(req, res);
    const lv = level || p.level || 'B1';
    const system = 'You are a Cambridge examiner. Evaluate this essay at level ' + lv + '. Return ONLY valid JSON (no markdown): {"overall":"<A1..C2>","score":<0-100>,"criteria":{"task":{"score":<0-100>,"comment":"<in Russian>"},"coherence":{"score":<0-100>,"comment":"<in Russian>"},"vocabulary":{"score":<0-100>,"comment":"<in Russian>"},"grammar":{"score":<0-100>,"comment":"<in Russian>"}},"strengths":["<in Russian>"],"improvements":["<in Russian>"],"corrected":"<corrected English version if many errors>"}';
    const user = 'Task: ' + (task||'free topic') + '\\n\\nStudent text:\\n' + text;
    const raw = await aiText(system, user, 1200);
    let data; try { const m = raw.match(/\\{[\\s\\S]*\\}/); data = JSON.parse(m ? m[0] : raw); }
    catch(e){ data = { overall:lv, score:70, criteria:{}, strengths:[], improvements:['AI вернул нестандартный формат'], corrected:'' }; }
    res.json({ ok:true, result:data });
  } catch(e){ res.status(502).json({ ok:false, error:e.message }); }
});

app.post('/api/speaking/feedback', async (req, res) => {
  try {
    const { transcript, topic, level } = req.body || {};
    if (!transcript || transcript.trim().length < 10) return res.status(400).json({ ok:false });
    const p = ensureProfile(req, res);
    const lv = level || p.level || 'B1';
    const system = 'You are an English speaking tutor. Student level: ' + lv + '. Evaluate fluency, vocabulary, grammar. Return ONLY valid JSON: {"overall":"<A1..C2>","fluency":{"score":<0-100>,"comment":"<in Russian>"},"vocabulary":{"score":<0-100>,"comment":"<in Russian>"},"grammar":{"score":<0-100>,"comment":"<in Russian>"},"highlights":["<in Russian>"],"improvements":["<in Russian>"],"nextSteps":"<recommendation in Russian>","better":"<native-like version in English>"}';
    const user = 'Topic: ' + (topic||'free') + '\\n\\nTranscript:\\n' + transcript;
    const raw = await aiText(system, user, 900);
    let data; try { const m = raw.match(/\\{[\\s\\S]*\\}/); data = JSON.parse(m ? m[0] : raw); }
    catch(e){ data = { overall:lv, fluency:{score:70}, highlights:[], improvements:['AI вернул нестандартный формат'] }; }
    res.json({ ok:true, result:data });
  } catch(e){ res.status(502).json({ ok:false, error:e.message }); }
});

app.post('/api/assist', async (req, res) => {
  try {
    const { question, history, level } = req.body || {};
    if (!question || !question.trim()) return res.status(400).json({ ok:false });
    const p = ensureProfile(req, res);
    const lv = level || p.level || 'B1';
    const system = 'Ты — элитный персональный репетитор английского языка. Уровень студента: ' + lv + '. Ты работаешь с состоятельными клиентами, поэтому твой стиль — безупречный, дружелюбный, но без сюсюканья. Отвечай ТОЛЬКО на русском, коротко (2-5 предложений). Примеры на английском с переводом. Если просят объяснить грамматику — дай правило и 2-3 примера. Если перевод — переведи и поясни нюансы. Если не знаешь — скажи честно.';
    let userPrompt = question;
    if (Array.isArray(history) && history.length){
      const last = history.slice(-4).map(h => (h.role==='user'?'Студент: ':'Репетитор: ')+h.content).join('\\n');
      userPrompt = 'Контекст:\\n' + last + '\\n\\nНовый вопрос: ' + question;
    }
    const reply = await aiText(system, userPrompt, 600);
    if (!reply || reply.length < 5) return res.status(502).json({ ok:false });
    res.json({ ok:true, reply, level:lv });
  } catch(e){ res.status(502).json({ ok:false, error:'AI недоступен' }); }
});

// Медиатека
app.get('/api/listening', (req, res) => res.json({ ok:true, items: LISTENING }));
app.get('/api/reading', (req, res) => res.json({ ok:true, items: READING }));
app.get('/api/writing-tasks', (req, res) => res.json({ ok:true, items: WRITING_TASKS }));
app.get('/api/speaking-topics', (req, res) => res.json({ ok:true, items: SPEAKING_TOPICS }));


app.post('/api/auth/register', function(req, res){
  try {
    const b = req.body || {};
    if (!b.email || !b.password) return res.status(400).json({ ok:false, error:'email и пароль обязательны' });
    if (String(b.password).length < 6) return res.status(400).json({ ok:false, error:'пароль минимум 6 символов' });
    let u;
    try { u = users.createUser({ email: b.email, name: b.name, password: b.password }); }
    catch(e){
      if (/already exists/.test(e.message)) return res.status(409).json({ ok:false, error:'Такой email уже зарегистрирован' });
      return res.status(400).json({ ok:false, error: e.message });
    }
    const guestId = req.cookies && req.cookies.profile;
    if (guestId){
      const gp = readProfile(guestId);
      if (gp && gp.testPercent){
        gp.id = u.id; gp.userId = u.id; gp.name = u.name; gp.email = u.email;
        users.updateProgress(u.id, gp);
      }
    }
    res.cookie('session', u.id, { httpOnly: true, sameSite: 'lax', maxAge: 30*24*3600*1000 });
    res.json({ ok:true, user:{ id:u.id, email:u.email, name:u.name } });
  } catch(e){ res.status(500).json({ ok:false, error: e.message }); }
});

app.post('/api/auth/login', function(req, res){
  try {
    const b = req.body || {};
    if (!b.email || !b.password) return res.status(400).json({ ok:false, error:'email и пароль обязательны' });
    const u = users.verifyUser(b.email, b.password);
    if (!u) return res.status(401).json({ ok:false, error:'Неверный email или пароль' });
    const guestId = req.cookies && req.cookies.profile;
    if (guestId){
      const gp = readProfile(guestId);
      if (gp && gp.testPercent && (!u.progress || !u.progress.testPercent)){
        gp.id = u.id; gp.userId = u.id; gp.name = u.name; gp.email = u.email;
        users.updateProgress(u.id, gp);
      }
    }
    res.cookie('session', u.id, { httpOnly: true, sameSite: 'lax', maxAge: 30*24*3600*1000 });
    res.json({ ok:true, user:{ id:u.id, email:u.email, name:u.name } });
  } catch(e){ res.status(500).json({ ok:false, error: e.message }); }
});

app.post('/api/auth/logout', function(req, res){
  res.clearCookie('session', { path:'/' });
  res.json({ ok:true });
});

app.get('/api/auth/me', function(req, res){
  const id = req.cookies && req.cookies.session;
  if (!id) return res.json({ ok:true, user:null });
  const u = users.findById(id);
  if (!u) return res.json({ ok:true, user:null });
  res.json({ ok:true, user:{ id:u.id, email:u.email, name:u.name, createdAt:u.createdAt } });
});

app.get('/api/profile', function(req, res){
  const p = ensureProfile(req, res);
  persistProfile(p, res);
  const user = p.userId ? users.findById(p.userId) : null;
  res.json({ ok:true, profile: p, user: user ? { id:user.id, email:user.email, name:user.name, createdAt:user.createdAt } : null });
});

app.post('/api/profile/password', function(req, res){
  const id = req.cookies && req.cookies.session;
  if (!id) return res.status(401).json({ ok:false, error:'Не авторизован' });
  const b = req.body || {};
  const u = users.findById(id);
  if (!u) return res.status(401).json({ ok:false });
  if (!users.verifyPassword(b.current, u.passHash)) return res.status(401).json({ ok:false, error:'Текущий пароль неверен' });
  if (!b.next || String(b.next).length < 6) return res.status(400).json({ ok:false, error:'Новый пароль минимум 6 символов' });
  users.changePassword(id, b.next);
  res.json({ ok:true });
});


// ========== TTS (Microsoft Edge) ==========
let ttsLib = null;
try {
  ttsLib = require('./lib/tts');
  console.log('[tts] lib loaded, voices:', Object.keys(ttsLib.VOICES).join(','));
} catch(e){ console.warn('[tts] load fail:', e.message); }

app.post('/api/tts', async function(req, res){
  try {
    if (!ttsLib) return res.status(503).json({ ok:false, error:'TTS not loaded' });
    const b = req.body || {};
    const text = String(b.text || '').trim();
    const lang = String(b.lang || 'ru').toLowerCase().slice(0,2);
    const gender = (b.gender === 'male') ? 'male' : 'female';
    if (!text) return res.status(400).json({ ok:false, error:'text required' });
    const { buffer, voice, cached } = await ttsLib.synthesize(text, lang, gender);
    res.set('Content-Type', 'audio/mpeg');
    res.set('Cache-Control', 'public, max-age=86400');
    res.set('X-TTS-Voice', voice);
    res.set('X-TTS-Cached', cached ? '1' : '0');
    res.send(buffer);
  } catch(e){
    console.warn('[tts]', e.message);
    res.status(502).json({ ok:false, error: e.message });
  }
});

app.get('/api/tts/voices', function(req, res){
  try { res.json({ ok:true, voices: require('./lib/tts').VOICES }); }
  catch(e){ res.status(503).json({ ok:false }); }
});

// Robot AI endpoint
require('./lib/robot')(app, ollamaChat, groqChat);

app.listen(PORT, () => console.log('iomaenglish listening on ' + PORT));
