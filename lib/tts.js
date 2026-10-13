// lib/tts.js — Google Translate TTS (быстро) + Edge TTS (fallback)
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const CACHE_DIR = path.join(__dirname, '..', 'data', 'tts-cache');
try { fs.mkdirSync(CACHE_DIR, { recursive: true }); } catch(e){}

// Голоса для Edge (используются только если Google не сработает)
const EDGE_VOICES = {
  ru: { male: 'ru-RU-DmitryNeural', female: 'ru-RU-SvetlanaNeural' },
  en: { male: 'en-GB-RyanNeural',   female: 'en-GB-SoniaNeural' },
  us: { male: 'en-US-GuyNeural',    female: 'en-US-AriaNeural' },
  zh: { male: 'zh-CN-YunxiNeural',  female: 'zh-CN-XiaoxiaoNeural' },
  tr: { male: 'tr-TR-AhmetNeural',  female: 'tr-TR-EmelNeural' }
};

function pickEdgeVoice(lang, gender){
  const l = (lang || 'ru').toLowerCase().slice(0, 2);
  const g = (gender === 'male') ? 'male' : 'female';
  return (EDGE_VOICES[l] || EDGE_VOICES.ru)[g];
}

// ===== GOOGLE TRANSLATE TTS (быстро, качественно, без ключа) =====
async function googleSynthesize(text, lang){
  const l = (lang || 'ru').slice(0, 2);
  // Google ограничивает запрос ~200 символами — режем на куски
  const words = String(text || '').split(/\s+/);
  const chunks = [];
  let cur = '';
  for (const w of words){
    if ((cur + ' ' + w).trim().length > 180){
      if (cur) chunks.push(cur.trim());
      cur = w;
    } else {
      cur = (cur + ' ' + w).trim();
    }
  }
  if (cur) chunks.push(cur.trim());
  if (!chunks.length) throw new Error('empty text');

  const buffers = [];
  for (const ch of chunks.slice(0, 20)){
    const url = 'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=' + l + '&ttsspeed=0.95&q=' + encodeURIComponent(ch);
    const r = await fetch(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15',
        'Referer': 'https://translate.google.com/'
      },
      signal: AbortSignal.timeout(12000)
    });
    if (!r.ok) throw new Error('google ' + r.status);
    buffers.push(Buffer.from(await r.arrayBuffer()));
  }
  return Buffer.concat(buffers);
}

// ===== EDGE TTS (fallback, с жёстким таймаутом 12с) =====
async function edgeSynthesize(text, voice){
  const mod = await import('@travisvn/edge-tts');
  const EdgeTTS = mod.EdgeTTS || (mod.default && mod.default.EdgeTTS);
  if (!EdgeTTS) throw new Error('EdgeTTS not found');

  const tts = new EdgeTTS(text, voice, { rate: '+0%', volume: '+0%', pitch: '+0Hz' });

  // Гонка: синтез vs таймаут 12 секунд
  const timeout = new Promise((_, reject) =>
    setTimeout(() => reject(new Error('edge timeout 12s')), 12000)
  );
  const result = await Promise.race([tts.synthesize(), timeout]);
  const ab = await result.audio.arrayBuffer();
  return Buffer.from(ab);
}

// ===== ГЛАВНАЯ ФУНКЦИЯ =====
async function synthesize(text, lang, gender){
  const clean = String(text || '').trim().slice(0, 4000);
  if (!clean) throw new Error('empty text');

  const l = (lang || 'ru').toLowerCase().slice(0, 2);
  const g = (gender === 'male') ? 'male' : 'female';
  const cacheKey = crypto.createHash('md5').update('v3::' + l + '::' + g + '::' + clean).digest('hex');
  const file = path.join(CACHE_DIR, cacheKey + '.mp3');

  if (fs.existsSync(file)){
    return { buffer: fs.readFileSync(file), voice: l + '-' + g, cached: true, engine: 'cache' };
  }

  let buffer = null;
  let engine = 'google';

  // 1) Google TTS — быстрый
  try {
    buffer = await googleSynthesize(clean, l);
    console.log('[tts] google ok, ' + buffer.length + ' bytes');
  } catch(e){
    console.warn('[tts] google fail:', e.message);
  }

  // 2) Edge TTS — если Google упал
  if (!buffer){
    try {
      const voice = pickEdgeVoice(l, g);
      buffer = await edgeSynthesize(clean, voice);
      engine = 'edge';
      console.log('[tts] edge ok, ' + buffer.length + ' bytes');
    } catch(e){
      console.warn('[tts] edge fail:', e.message);
      throw new Error('Все TTS недоступны');
    }
  }

  try { fs.writeFileSync(file, buffer); } catch(e){}

  return { buffer, voice: l + '-' + g, cached: false, engine };
}

const VOICES = EDGE_VOICES;

module.exports = { synthesize, pickEdgeVoice, VOICES };
