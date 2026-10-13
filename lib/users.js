// lib/users.js — аккаунты пользователей
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const FILE = path.join(__dirname, '..', 'data', 'users.json');

function load(){
  try {
    if (!fs.existsSync(FILE)) return [];
    const arr = JSON.parse(fs.readFileSync(FILE, 'utf8'));
    return Array.isArray(arr) ? arr : [];
  } catch(e){ console.error('[users] load:', e.message); return []; }
}
function save(list){
  fs.mkdirSync(path.dirname(FILE), { recursive: true });
  const tmp = FILE + '.tmp';
  fs.writeFileSync(tmp, JSON.stringify(list, null, 2), 'utf8');
  fs.renameSync(tmp, FILE);
}
function hashPassword(pw){
  const salt = crypto.randomBytes(16);
  const N = 16384, r = 8, p = 1;
  const hash = crypto.scryptSync(String(pw), salt, 32, { N, r, p, maxmem: 64*1024*1024 });
  return ['scrypt', N, r, p, salt.toString('hex'), hash.toString('hex')].join('$');
}
function verifyPassword(pw, stored){
  if (!stored || typeof stored !== 'string') return false;
  const parts = stored.split('$');
  if (parts.length !== 6 || parts[0] !== 'scrypt') return false;
  try {
    const N = Number(parts[1]), r = Number(parts[2]), p = Number(parts[3]);
    const salt = Buffer.from(parts[4], 'hex');
    const expected = Buffer.from(parts[5], 'hex');
    const actual = crypto.scryptSync(String(pw), salt, expected.length, { N, r, p, maxmem: 64*1024*1024 });
    return crypto.timingSafeEqual(actual, expected);
  } catch(e){ return false; }
}
function findByEmail(email){
  const e = String(email || '').trim().toLowerCase();
  if (!e) return null;
  return load().find(u => String(u.email || '').toLowerCase() === e) || null;
}
function findById(id){
  if (!id) return null;
  return load().find(u => String(u.id) === String(id)) || null;
}
function createUser({ email, name, password }){
  const e = String(email || '').trim().toLowerCase();
  const n = String(name || '').trim();
  if (!e) throw new Error('email required');
  if (!password || String(password).length < 6) throw new Error('password too short (min 6)');
  if (findByEmail(e)) throw new Error('email already exists');
  const list = load();
  const user = {
    id: 'u_' + Date.now().toString(36) + '_' + crypto.randomBytes(3).toString('hex'),
    email: e,
    name: n || e.split('@')[0],
    passHash: hashPassword(password),
    createdAt: Date.now(),
    progress: null
  };
  list.push(user);
  save(list);
  return user;
}
function verifyUser(email, password){
  const u = findByEmail(email);
  if (!u) return null;
  if (!verifyPassword(password, u.passHash)) return null;
  return u;
}
function updateProgress(userId, progress){
  const list = load();
  const idx = list.findIndex(u => String(u.id) === String(userId));
  if (idx < 0) return false;
  list[idx].progress = progress;
  list[idx].updatedAt = Date.now();
  save(list);
  return true;
}
function changePassword(userId, newPassword){
  if (!newPassword || newPassword.length < 6) return false;
  const list = load();
  const idx = list.findIndex(u => String(u.id) === String(userId));
  if (idx < 0) return false;
  list[idx].passHash = hashPassword(newPassword);
  save(list);
  return true;
}
module.exports = { load, save, findByEmail, findById, createUser, verifyUser, updateProgress, changePassword, hashPassword, verifyPassword };
