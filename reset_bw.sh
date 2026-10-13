#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  СБРОС: чёрное и белое, минимализм"
echo "============================================"
echo ""

mkdir -p _unused/backup
TS=$(date +%Y%m%d_%H%M%S)
for f in styles.css particles.js interactions.js; do
  [ -f "$f" ] && cp "$f" "_unused/backup/$f.$TS"
done
echo "✓ Бэкапы"
echo ""

# ---------- 1. ЧИСТЫЙ styles.css ----------
echo "[1/5] Пишу чистый styles.css"
cat > styles.css << 'CSSEOF'
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500;600&display=swap');

*{box-sizing:border-box;margin:0;padding:0}

/* ============================================
   ПАЛИТРА: только чёрный, белый, два серых
   ============================================ */
:root{
  color-scheme:light;

  --sans:'Inter',-apple-system,BlinkMacSystemFont,system-ui,sans-serif;
  --mono:'JetBrains Mono','SF Mono',Menlo,monospace;

  --bg:#ffffff;
  --bg-2:#fafafa;
  --card:#ffffff;
  --card-2:#f5f5f5;
  --field:#ffffff;

  --text:#000000;
  --text-muted:#666666;
  --text-dim:#999999;

  --border:#e5e5e5;
  --border-2:#d4d4d4;
  --track:#e5e5e5;

  /* aliases для совместимости со страничным CSS */
  --gold:#000000;
  --gold-2:#000000;
  --gold-dim:#666666;
  --accent:#000000;
  --accent-2:#000000;
  --accent-soft:rgba(0,0,0,.05);
  --on-accent:#ffffff;

  --amber:#000000;
  --amber-2:#000000;
  --amber-dim:#666666;
  --ruby:#000000;
  --honey:#000000;
  --sage:#666666;

  --ok:#000000;
  --ok-soft:rgba(0,0,0,.06);
  --err:#000000;
  --err-soft:rgba(0,0,0,.06);
  --err-solid:#000000;

  --flame:#000000;
  --flame-2:#000000;
  --flame-soft:rgba(0,0,0,.05);

  --topbar-bg:rgba(255,255,255,.88);
  --overlay:rgba(255,255,255,.9);

  --shadow-sm:none;
  --shadow-md:none;
  --shadow-lg:none;
  --shadow-gold:none;

  --r-sm:0px;
  --r:0px;
  --r-lg:0px;
  --r-xl:0px;
  --r-pill:999px;

  --ease:cubic-bezier(.22,.61,.36,1);
  --ease-out:cubic-bezier(.16,1,.3,1);
  --t:200ms;

  /* shkala otstupov */
  --s1:4px; --s2:8px; --s3:12px; --s4:16px;
  --s5:24px; --s6:32px; --s7:48px; --s8:64px;
  --s9:96px; --s10:128px;
}

/* ТЁМНАЯ — инверсия */
html:not(.light){
  color-scheme:dark;
  --bg:#000000;
  --bg-2:#0a0a0a;
  --card:#000000;
  --card-2:#141414;
  --field:#0a0a0a;
  --text:#ffffff;
  --text-muted:#999999;
  --text-dim:#666666;
  --border:#1f1f1f;
  --border-2:#2a2a2a;
  --track:#1f1f1f;
  --gold:#ffffff;
  --gold-2:#ffffff;
  --gold-dim:#999999;
  --accent:#ffffff;
  --accent-2:#ffffff;
  --accent-soft:rgba(255,255,255,.08);
  --on-accent:#000000;
  --amber:#ffffff;
  --amber-2:#ffffff;
  --amber-dim:#999999;
  --ruby:#ffffff;
  --ok:#ffffff;
  --ok-soft:rgba(255,255,255,.08);
  --err:#ffffff;
  --err-soft:rgba(255,255,255,.08);
  --err-solid:#ffffff;
  --flame:#ffffff;
  --flame-2:#ffffff;
  --flame-soft:rgba(255,255,255,.06);
  --topbar-bg:rgba(0,0,0,.88);
  --overlay:rgba(0,0,0,.9);
}

html{scroll-behavior:smooth;-webkit-text-size-adjust:100%}

body{
  font-family:var(--sans);
  font-size:16px;
  line-height:1.6;
  font-weight:400;
  background:var(--bg);
  color:var(--text);
  min-height:100vh;
  -webkit-font-smoothing:antialiased;
  text-rendering:optimizeLegibility;
  overflow-x:hidden;
  letter-spacing:-.005em;
}

main,header,section,footer,.topbar{position:relative;z-index:2}

/* ============================================
   ТИПОГРАФИКА
   ============================================ */
h1,h2,h3,h4{
  font-family:var(--sans);
  font-weight:800;
  letter-spacing:-.04em;
  line-height:1;
  color:var(--text);
  text-transform:uppercase;
}

h1{font-size:clamp(40px,7vw,96px);font-weight:900;letter-spacing:-.05em}
h2{font-size:clamp(28px,4vw,48px);font-weight:800}
h3{font-size:22px;font-weight:700;letter-spacing:-.02em}
h4{font-size:16px;font-weight:700;letter-spacing:-.01em;text-transform:none}

p{font-size:16px;line-height:1.65;color:var(--text)}

a{color:inherit;text-decoration:none;transition:color var(--t) var(--ease),opacity var(--t)}

code,kbd,samp,.mono{font-family:var(--mono);font-size:.9em}

::selection{background:var(--text);color:var(--bg)}

:focus-visible{outline:2px solid var(--text);outline-offset:3px}

/* ============================================
   TOPBAR
   ============================================ */
.topbar{
  display:grid;
  grid-template-columns:1fr auto 1fr;
  align-items:center;
  gap:24px;
  padding:20px 40px;
  position:sticky;
  top:0;
  z-index:100;
  background:var(--topbar-bg);
  -webkit-backdrop-filter:blur(20px);
  backdrop-filter:blur(20px);
  border-bottom:1px solid var(--border);
}
.topbar-left{display:flex;gap:10px;align-items:center}
.topbar-right{display:flex;align-items:center;gap:12px;justify-content:flex-end}
.brand{
  font-family:var(--sans);
  font-size:22px;
  font-weight:900;
  letter-spacing:-.05em;
  line-height:1;
  text-transform:lowercase;
}
.brand b,.brand span:first-child{color:var(--text);font-weight:900}
.brand span{color:var(--text-muted);font-weight:500}
.back-link{
  color:var(--text-muted);
  font-size:13px;
  font-weight:500;
  text-transform:uppercase;
  letter-spacing:.06em;
  padding:8px 12px;
  display:inline-block;
  transition:color var(--t);
}
.back-link:hover{color:var(--text)}
.theme-btn{
  display:inline-flex;align-items:center;gap:8px;
  background:transparent;border:1px solid var(--border-2);
  color:var(--text-muted);
  padding:8px 12px;font-size:13px;font-weight:500;
  cursor:pointer;font-family:inherit;letter-spacing:.04em;
  text-transform:uppercase;
  transition:all var(--t);
}
.theme-btn:hover{border-color:var(--text);color:var(--text)}
.theme-btn svg{width:14px;height:14px;fill:none;stroke:currentColor;stroke-width:1.6;stroke-linecap:round;stroke-linejoin:round}
.theme-btn .icon-moon{display:none}
html:not(.light) .theme-btn .icon-sun{display:none}
html:not(.light) .theme-btn .icon-moon{display:inline}

/* ============================================
   КНОПКИ
   ============================================ */
.btn-primary,.btn-ghost,.cta-mini,.lh-cta,.stage-btn,.lst-play,.lst-slow,.spk-btn,.wt-new,.cr-show,.cr-btn,.assist-send,.play-btn,.record-btn{
  display:inline-flex;align-items:center;justify-content:center;gap:10px;
  font-family:var(--sans);font-weight:600;font-size:14px;
  letter-spacing:.02em;
  padding:14px 28px;
  border-radius:0;
  border:none;
  cursor:pointer;
  transition:all var(--t) var(--ease);
  text-decoration:none;
  text-transform:uppercase;
}
.btn-primary,.cta-mini,.lh-cta,.stage-btn,.lst-play,.spk-btn,.assist-send,.play-btn,.record-btn{
  background:var(--text);color:var(--bg);border:1px solid var(--text);
}
.btn-primary:hover,.cta-mini:hover,.lh-cta:hover,.stage-btn:hover,.lst-play:hover,.spk-btn:hover,.assist-send:hover,.play-btn:hover,.record-btn:hover{
  background:var(--bg);color:var(--text);
}
.btn-ghost,.lst-slow,.wt-new,.cr-show,.cr-btn{
  background:transparent;color:var(--text);border:1px solid var(--border-2);
}
.btn-ghost:hover,.lst-slow:hover,.wt-new:hover,.cr-show:hover{
  border-color:var(--text);background:var(--bg-2);
}
.btn-primary:disabled,.btn-ghost:disabled,.stage-btn:disabled,.lst-nav button:disabled,.play-btn:disabled,.record-btn:disabled{
  opacity:.3;cursor:not-allowed;transform:none;box-shadow:none;
}
.cta-mini{padding:10px 18px;font-size:12px}
.stage-btn{padding:16px 36px;font-size:14px}

/* ============================================
   КАРТОЧКИ
   ============================================ */
.card,.stage-card,.question-card,.reading-block,.listening-block,.writing-block,.speaking-block,.result-card,.level-hero,.unit,.quick-card,.lesson-rule,.lesson-exercises,.lr-card,.lst-card,.spk-feedback,.wrt-result,.wrt-task,.spk-prompt,.voc-item,.assist-window,.level-badge,.stat-card,.skill-card,.profile-card,.auth-card,.profile-hero,.method-item,.feature-card{
  background:var(--card);
  border:1px solid var(--border);
  border-radius:0;
  box-shadow:none;
  transition:border-color var(--t) var(--ease),background var(--t) var(--ease);
  position:relative;
}
.card:hover,.unit:hover,.quick-card:hover,.method-item:hover,.feature-card:hover{
  border-color:var(--text);
}

.rule,.task-prompt,.transcript-box,.spk-transcript,.lst-original,.ex-comment,.wr-crit,.wr-corrected,.fb-better,.rp-item,.q-sentence,.placeholder,.cb-book,.lh-book,.assist-body,.info-block{
  background:var(--bg-2);
  border:1px solid var(--border);
  border-radius:0;
}
.rule,.task-prompt,.spk-prompt,.lesson-rule,.wrt-task,.q-sentence,.lst-original,.wr-corrected,.fb-better,.ex-comment,.info-block{
  box-shadow:inset 4px 0 0 var(--text);
}

/* ============================================
   ФОРМЫ
   ============================================ */
input[type=text],input[type=email],input[type=password],input[type=tel],.va-row input,#writingInput,#wrtInput,.lst-input textarea,.assist-foot textarea,.auth-input,textarea{
  width:100%;
  background:var(--field);
  border:1px solid var(--border-2);
  border-radius:0;
  color:var(--text);
  padding:14px 16px;
  font-family:inherit;
  font-size:15px;
  line-height:1.5;
  outline:none;
  transition:border-color var(--t) var(--ease);
}
input::placeholder,textarea::placeholder{color:var(--text-dim)}
input:focus,textarea:focus{border-color:var(--text);box-shadow:none}

/* ============================================
   ОПЦИИ ОТВЕТОВ
   ============================================ */
.q-option,.ex-opt{
  display:flex;align-items:center;gap:14px;width:100%;
  padding:16px 20px;text-align:left;
  background:var(--card);color:var(--text);
  border:1px solid var(--border-2);border-radius:0;
  font-family:inherit;font-size:15px;line-height:1.5;
  cursor:pointer;transition:all var(--t) var(--ease);
  position:relative;
}
.q-option:hover,.ex-opt:hover{border-color:var(--text);background:var(--card-2)}
.q-option.selected,.ex-opt.selected{border-color:var(--text);background:var(--card-2)}
.ex-opt.correct{border-color:var(--text);background:var(--text);color:var(--bg)}
.ex-opt.wrong{border-color:var(--text);background:var(--bg);color:var(--text);text-decoration:line-through;text-decoration-color:var(--text)}
.q-option-letter,.ex-letter{
  width:28px;height:28px;flex-shrink:0;
  display:flex;align-items:center;justify-content:center;
  border:1px solid var(--border-2);border-radius:50%;
  font-family:var(--mono);font-size:12px;font-weight:500;
  color:var(--text-muted);transition:all var(--t);
}
.q-option.selected .q-option-letter,.ex-opt.selected .ex-letter{background:var(--text);border-color:var(--text);color:var(--bg)}
.ex-opt.correct .ex-letter{background:var(--bg);border-color:var(--bg);color:var(--text)}
.ex-opt.wrong .ex-letter{background:var(--text);border-color:var(--text);color:var(--bg)}

/* ============================================
   ПРОГРЕСС
   ============================================ */
.level-progress-bar,.mini-bar,.lhp-bar,.skill-bar,.pl-bar,.wr-crit-bar,.fb-crit-bar,.bar,.progress-bar{
  background:var(--track);border-radius:999px;overflow:hidden;position:relative;height:2px;
}
.level-progress-fill,.mini-fill,.lhp-fill,.skill-fill,.pl-fill,.wr-crit-fill,.fb-crit-fill,.bar-fill,.progress-bar>div,.bar>div{
  height:100%;background:var(--text);border-radius:inherit;
  transition:width 1s var(--ease-out);
}

/* ============================================
   LEVEL BADGE
   ============================================ */
.level-badge{
  display:inline-flex;align-items:center;gap:12px;
  padding:4px 12px 4px 4px;
  border-radius:999px;
  border:1px solid var(--border-2);
  cursor:pointer;text-decoration:none;color:inherit;
}
.level-pill{
  min-width:44px;height:32px;padding:0 10px;
  display:inline-flex;align-items:center;justify-content:center;
  background:var(--text);color:var(--bg);
  border-radius:999px;
  font-family:var(--mono);font-size:13px;font-weight:600;
  letter-spacing:.02em;
}
.level-progress-wrap{min-width:100px;display:flex;flex-direction:column;gap:5px}
.level-progress-bar{height:2px}
.level-progress-text{
  display:flex;justify-content:space-between;
  font-family:var(--mono);
  font-size:10px;color:var(--text-muted);
  font-weight:500;text-transform:uppercase;letter-spacing:.08em;
}

/* ============================================
   HERO
   ============================================ */
.hero{
  position:relative;
  padding:120px 32px 100px;
  max-width:1280px;
  margin:0 auto;
  text-align:left;
}
.hero-copy{position:relative;z-index:2;max-width:1000px;margin:0 auto}
.eyebrow{
  display:inline-block;
  font-family:var(--mono);
  font-size:12px;font-weight:500;
  letter-spacing:.2em;
  color:var(--text-muted);
  text-transform:uppercase;
  margin-bottom:32px;
  padding:6px 0;
  border-top:1px solid var(--text);
  border-bottom:1px solid var(--text);
}
.hero h1{margin:0 0 32px}
.hero h1 .accent{
  font-style:normal;
  font-weight:300;
  text-transform:none;
  letter-spacing:-.02em;
  display:block;
  margin-top:8px;
  color:var(--text-muted);
  font-size:.55em;
}
.lede{
  font-size:18px;
  line-height:1.6;
  color:var(--text-muted);
  max-width:640px;
  margin:0 0 44px;
  font-weight:400;
}
.hero-actions{display:flex;gap:0;flex-wrap:wrap;margin-bottom:72px}
.hero-actions .btn-primary,.hero-actions .btn-ghost{margin-right:-1px}
.hero-stats{
  display:flex;gap:80px;flex-wrap:wrap;
  padding-top:44px;
  border-top:1px solid var(--border);
}
.stat b{
  display:block;
  font-family:var(--sans);
  font-size:64px;font-weight:900;
  line-height:1;margin-bottom:12px;
  letter-spacing:-.05em;
  color:var(--text);
}
.stat span{
  font-family:var(--mono);
  font-size:11px;color:var(--text-muted);
  line-height:1.5;font-weight:500;
  text-transform:uppercase;letter-spacing:.1em;
}

/* ============================================
   СЕКЦИИ
   ============================================ */
.features,.method{
  max-width:1280px;margin:0 auto;
  padding:60px 32px 120px;
}
.features h2,.method h2{margin:0 0 56px;text-align:left;padding-bottom:24px;border-bottom:1px solid var(--text)}
.features-grid{
  display:grid;grid-template-columns:repeat(auto-fill,minmax(320px,1fr));
  gap:0;border-top:1px solid var(--border);
}
.feature-card{
  position:relative;padding:40px 32px;
  overflow:hidden;
  border:none;border-bottom:1px solid var(--border);
  border-right:1px solid var(--border);
}
.feature-card:hover{background:var(--bg-2)}
.feature-num{
  font-family:var(--mono);
  font-size:11px;font-weight:500;
  color:var(--text-muted);
  letter-spacing:.2em;
  margin-bottom:24px;
}
.feature-card h3{margin:0 0 16px;font-size:20px;font-weight:800;text-transform:uppercase;letter-spacing:-.02em}
.feature-card p{margin:0;font-size:14.5px;line-height:1.7;color:var(--text-muted)}

.method-list{display:grid;gap:0;max-width:1000px;margin:0 auto;border-top:1px solid var(--border)}
.method-item{
  display:grid;grid-template-columns:220px 1fr;gap:32px;
  padding:32px 0;
  border:none;border-bottom:1px solid var(--border);
  background:transparent;
}
.method-item:hover{background:transparent;border-color:var(--border)}
.method-item b{
  font-family:var(--sans);font-size:14px;font-weight:800;
  color:var(--text);text-transform:uppercase;letter-spacing:.05em;
}
.method-item p{margin:0;font-size:15px;line-height:1.7;color:var(--text-muted)}

.footer{
  padding:48px 40px;
  border-top:1px solid var(--border);
  max-width:1280px;margin:0 auto;
  display:flex;justify-content:space-between;align-items:center;
  gap:20px;flex-wrap:wrap;
  font-family:var(--mono);
  color:var(--text-muted);font-size:12px;
  letter-spacing:.05em;text-transform:uppercase;
}

/* ============================================
   AI ASSIST
   ============================================ */
.assist-fab{
  position:fixed;right:24px;bottom:24px;z-index:200;
  display:inline-flex;align-items:center;gap:10px;
  background:var(--text);color:var(--bg);
  border:1px solid var(--text);
  border-radius:0;
  padding:14px 22px;
  font-size:13px;font-weight:700;
  letter-spacing:.05em;text-transform:uppercase;
  cursor:pointer;
  font-family:inherit;
  transition:all var(--t);
}
.assist-fab:hover{background:var(--bg);color:var(--text)}
.assist-overlay{
  position:fixed;inset:0;z-index:999;
  display:flex;align-items:stretch;justify-content:center;
  padding:20px;background:var(--overlay);
  -webkit-backdrop-filter:blur(12px);backdrop-filter:blur(12px);
}
.assist-overlay[hidden]{display:none}
.assist-window{
  width:100%;max-width:800px;
  display:flex;flex-direction:column;overflow:hidden;
  border:1px solid var(--text);border-radius:0;
  background:var(--bg);
}
.assist-head{padding:20px 24px;border-bottom:1px solid var(--border);display:flex;align-items:center;gap:14px}
.assist-head h2{font-size:16px;margin:0;text-transform:uppercase;letter-spacing:.02em}
.assist-head .sub{font-family:var(--mono);font-size:11px;color:var(--text-muted);margin-top:2px;letter-spacing:.05em}
.assist-head .orb{
  width:36px;height:36px;flex-shrink:0;
  display:flex;align-items:center;justify-content:center;
  background:var(--text);color:var(--bg);border-radius:50%;
}
.assist-close{
  width:32px;height:32px;margin-left:auto;
  background:transparent;border:1px solid var(--border-2);
  border-radius:0;font-size:20px;line-height:1;
  color:var(--text-muted);cursor:pointer;
  transition:all var(--t);
}
.assist-close:hover{color:var(--text);border-color:var(--text)}
.assist-body{flex:1;overflow-y:auto;padding:24px;min-height:300px;max-height:60vh;background:var(--bg-2)}
.assist-msg{margin-bottom:16px;max-width:82%}
.assist-msg.user{margin-left:auto}
.assist-msg .bubble{padding:12px 16px;font-size:14px;line-height:1.6;white-space:pre-wrap;border:1px solid var(--border)}
.assist-msg.user .bubble{background:var(--text);color:var(--bg);border-color:var(--text)}
.assist-msg.ai .bubble{background:var(--bg);color:var(--text)}
.assist-msg.error .bubble{border:1px solid var(--text);font-style:italic}
.assist-empty{text-align:center;padding:48px 20px;color:var(--text-muted)}
.assist-empty h3{color:var(--text);font-size:24px;margin-bottom:10px;text-transform:uppercase;letter-spacing:-.03em}
.assist-empty p{font-size:14px;line-height:1.6}
.assist-empty .sugg{display:flex;flex-wrap:wrap;gap:8px;justify-content:center;margin-top:24px}
.assist-empty .sugg button{
  background:transparent;border:1px solid var(--border-2);
  border-radius:0;padding:10px 16px;
  font-size:12px;color:var(--text-muted);
  cursor:pointer;transition:all var(--t);
  font-family:inherit;letter-spacing:.02em;
}
.assist-empty .sugg button:hover{border-color:var(--text);color:var(--text)}
.assist-foot{padding:14px;border-top:1px solid var(--border);display:flex;gap:10px;align-items:flex-end}
.assist-foot textarea{flex:1;resize:none;max-height:120px;line-height:1.5;padding:12px 14px}
.assist-send{width:44px;height:44px;flex-shrink:0;padding:0}

.hidden,[hidden]{display:none !important}
.placeholder{
  padding:36px;text-align:center;
  color:var(--text-muted);
  font-family:var(--mono);
  font-size:12px;letter-spacing:.05em;text-transform:uppercase;
}

/* ============================================
   АНИМАЦИИ — только простые
   ============================================ */
.ioma-reveal{
  opacity:0;transform:translateY(12px);
  transition:opacity .6s var(--ease-out),transform .6s var(--ease-out);
}
.ioma-reveal.ioma-in{opacity:1;transform:none}

/* page transitions */
html{opacity:0;transition:opacity .2s var(--ease)}
html.page-ready{opacity:1}
html.page-leaving{opacity:0}

@media (prefers-reduced-motion: reduce){
  .ioma-reveal{opacity:1;transform:none;transition:none}
  html{opacity:1 !important;transition:none !important}
}

/* ============================================
   TTS INLINE
   ============================================ */
.ioma-tts-target{position:relative;padding-right:46px}
.ioma-tts-btn-inline{
  position:absolute;right:12px;top:50%;transform:translateY(-50%);
  width:28px;height:28px;
  display:inline-flex;align-items:center;justify-content:center;
  background:transparent;border:1px solid var(--border-2);
  color:var(--text-muted);border-radius:50%;
  cursor:pointer;transition:all var(--t);
  padding:0;opacity:.6;
}
.ioma-tts-target:hover .ioma-tts-btn-inline{opacity:1}
.ioma-tts-btn-inline:hover{background:var(--text);color:var(--bg);border-color:var(--text)}
.ioma-tts-btn-inline.playing{background:var(--text);color:var(--bg);border-color:var(--text);opacity:1}

/* ============================================
   TOAST
   ============================================ */
.ioma-toast-box{
  position:fixed;bottom:24px;left:50%;transform:translateX(-50%);
  z-index:9999;display:flex;flex-direction:column;gap:8px;
  pointer-events:none;max-width:90vw;
}
.ioma-toast{
  display:flex;align-items:center;gap:12px;
  padding:14px 20px;
  background:var(--text);color:var(--bg);
  border:1px solid var(--text);
  font-size:13px;font-weight:500;
  letter-spacing:.02em;
  opacity:0;transform:translateY(10px);
  transition:all .35s var(--ease-out);
  pointer-events:auto;
}
.ioma-toast.in{opacity:1;transform:none}
.ioma-toast-icon{display:inline-flex;align-items:center;justify-content:center;width:18px;height:18px;font-size:11px}

/* ============================================
   SKELETON
   ============================================ */
.ioma-skel-line{
  height:12px;margin:8px 0;
  background:var(--border);
  animation:iomaSkel 1.6s ease-in-out infinite;
}
@keyframes iomaSkel{0%,100%{opacity:.4}50%{opacity:.9}}

/* ============================================
   BACK TO TOP
   ============================================ */
.ioma-back-top{
  position:fixed;right:24px;bottom:84px;z-index:150;
  width:44px;height:44px;
  background:var(--bg);border:1px solid var(--border-2);
  color:var(--text);border-radius:0;
  display:inline-flex;align-items:center;justify-content:center;
  cursor:pointer;opacity:0;transform:translateY(8px);
  pointer-events:none;
  transition:all .3s var(--ease-out);
}
.ioma-back-top.show{opacity:1;transform:none;pointer-events:auto}
.ioma-back-top:hover{background:var(--text);color:var(--bg);border-color:var(--text)}

/* ============================================
   ПЕРЕОПРЕДЕЛЕНИЕ СТАРЫХ ЦВЕТОВ/ЭФФЕКТОВ
   ============================================ */
body::before,body::after{display:none !important}
#iomaParticlesCanvas{display:none !important}
.ioma-cursor-glow,.ioma-ripple{display:none !important}

/* ============================================
   MEDIA
   ============================================ */
@media(max-width:820px){
  .topbar{grid-template-columns:auto 1fr auto;padding:14px 20px;gap:10px}
  .brand{font-size:18px}
  .theme-btn span{display:none}
  .level-badge{padding:3px 10px 3px 3px}
  .level-pill{min-width:38px;height:28px;font-size:12px}
  .level-progress-wrap{display:none}
  .hero{padding:80px 20px 60px}
  .hero h1{font-size:clamp(36px,10vw,56px)}
  .hero-stats{gap:40px;padding-top:32px}
  .stat b{font-size:44px}
  .features,.method{padding:40px 20px 80px}
  .features h2,.method h2{margin-bottom:36px}
  .features-grid{grid-template-columns:1fr}
  .feature-card{border-right:none}
  .method-item{grid-template-columns:1fr;gap:8px;padding:24px 0}
  .footer{padding:32px 20px;flex-direction:column;text-align:left;align-items:flex-start}
  .assist-fab{right:16px;bottom:16px;padding:12px 16px;font-size:12px}
  .ioma-back-top{right:16px;bottom:72px;width:40px;height:40px}
  .assist-overlay{padding:0}
  .assist-window{border:none;max-width:none;height:100vh}
}
CSSEOF
echo "  ✓ styles.css ($(wc -l < styles.css) строк)"
echo ""

# ---------- 2. particles.js — отключаем ----------
echo "[2/5] Отключаю particles.js"
cat > particles.js << 'PARTEOF'
(function(){
  // Отключено в режиме минимализма B&W
  if (window.__iomaParticles) return;
  window.__iomaParticles = true;
})();
PARTEOF
echo "  ✓ particles.js отключён"
echo ""

# ---------- 3. interactions.js — минимализм ----------
echo "[3/5] Пишу минималистичный interactions.js"
cat > interactions.js << 'INTEREOF'
(function(){
  if (window.__iomaInteractions) return;
  window.__iomaInteractions = true;

  // ---------- PAGE TRANSITIONS ----------
  function initPageTransitions(){
    document.addEventListener('click', function(e){
      var a = e.target.closest('a[href]');
      if (!a) return;
      var href = a.getAttribute('href');
      if (!href || href.charAt(0) !== '/' || href.charAt(0) === '#' || a.target === '_blank') return;
      if (e.ctrlKey || e.metaKey || e.shiftKey) return;
      e.preventDefault();
      document.documentElement.classList.add('page-leaving');
      setTimeout(function(){ location.href = href; }, 200);
    });
    requestAnimationFrame(function(){
      document.documentElement.classList.add('page-ready');
    });
    window.addEventListener('pageshow', function(e){
      if (e.persisted){
        document.documentElement.classList.remove('page-leaving');
        document.documentElement.classList.add('page-ready');
      }
    });
  }

  // ---------- ПЛАВНЫЙ СКРОЛЛ ПО ЯКОРЯМ ----------
  function initSmoothAnchors(){
    document.querySelectorAll('a[href^="#"]').forEach(function(a){
      a.addEventListener('click', function(e){
        var id = a.getAttribute('href').slice(1);
        if (!id) return;
        var el = document.getElementById(id);
        if (!el) return;
        e.preventDefault();
        el.scrollIntoView({ behavior:'smooth', block:'start' });
      });
    });
  }

  // ---------- BACK TO TOP ----------
  function initBackToTop(){
    var btn = document.createElement('button');
    btn.className = 'ioma-back-top';
    btn.setAttribute('aria-label', 'Наверх');
    btn.innerHTML = '<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 19V5M5 12l7-7 7 7"/></svg>';
    btn.addEventListener('click', function(){
      window.scrollTo({ top:0, behavior:'smooth' });
    });
    document.body.appendChild(btn);
    function check(){
      if (window.scrollY > 400) btn.classList.add('show');
      else btn.classList.remove('show');
    }
    window.addEventListener('scroll', check, { passive:true });
    check();
  }

  // ---------- TOAST ----------
  var toastBox = null;
  function ensureBox(){
    if (toastBox && document.body.contains(toastBox)) return toastBox;
    toastBox = document.createElement('div');
    toastBox.className = 'ioma-toast-box';
    document.body.appendChild(toastBox);
    return toastBox;
  }
  window.toast = function(msg, type){
    var box = ensureBox();
    var el = document.createElement('div');
    el.className = 'ioma-toast ioma-toast-' + (type || 'info');
    el.innerHTML = '<span class="ioma-toast-icon">' +
      (type === 'success' ? '✓' : type === 'error' ? '✕' : '·') +
      '</span><span>' + msg + '</span>';
    box.appendChild(el);
    requestAnimationFrame(function(){ el.classList.add('in'); });
    setTimeout(function(){
      el.classList.remove('in');
      setTimeout(function(){ el.remove(); }, 350);
    }, 3000);
  };

  // ---------- СКРОЛЛ-РЕВИЛ ----------
  var REVEAL_SEL = '.card,.feature-card,.method-item,.stat-card,.skill-card,.unit,.quick-card,.profile-hero,.lesson-rule,.lesson-exercises,.lst-card,.spk-prompt,.spk-feedback,.wrt-task,.wrt-result,.question-card,.result-card,.auth-card,.hero h1,.hero .lede,.hero-actions,.hero-stats,.level-hero,.cb-head';
  function initReveal(){
    var els = document.querySelectorAll(REVEAL_SEL);
    if (!('IntersectionObserver' in window)){
      els.forEach(function(e){ e.classList.add('ioma-in'); });
      return;
    }
    var io = new IntersectionObserver(function(entries){
      entries.forEach(function(en){
        if (en.isIntersecting){
          en.target.classList.add('ioma-in');
          io.unobserve(en.target);
        }
      });
    }, { threshold:0.08, rootMargin:'0px 0px -40px 0px' });
    els.forEach(function(el, i){
      if (el.classList.contains('ioma-reveal')) return;
      el.classList.add('ioma-reveal');
      el.style.transitionDelay = ((i % 5) * 50) + 'ms';
      io.observe(el);
    });
  }

  // ---------- TTS ----------
  function shouldHaveTTS(){
    var p = location.pathname;
    return p === '/lesson' || p === '/listening' || p === '/test';
  }
  function initTTSButtons(){
    if (!shouldHaveTTS()) return;
    var targets = document.querySelectorAll('.ex-q, .q-sentence, .q-text, .lst-original .lo-text, .task-prompt');
    if (!targets.length) return;
    targets.forEach(function(el){
      if (el.dataset.ttsReady) return;
      el.dataset.ttsReady = '1';
      el.classList.add('ioma-tts-target');
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'ioma-tts-btn-inline';
      btn.setAttribute('aria-label', 'Озвучить');
      btn.innerHTML = '<svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 5L6 9H2v6h4l5 4V5zM15.5 8.5a5 5 0 0 1 0 7M19 5a9 9 0 0 1 0 14"/></svg>';
      btn.addEventListener('click', function(e){
        e.preventDefault();
        e.stopPropagation();
        speakEnglish(el.textContent.replace(/\s+/g,' ').trim(), btn);
      });
      el.appendChild(btn);
    });
  }
  function speakEnglish(text, btn){
    if (!text) return;
    var en = text.replace(/[^\x00-\x7F]/g, '').replace(/\s+/g,' ').trim().slice(0, 1000);
    if (!en || en.length < 3) en = text.slice(0, 1000);
    if (!en) return;
    if (btn && btn.classList.contains('playing')){ stopAll(); return; }
    stopAll();
    if (btn) btn.classList.add('playing');
    fetch('/api/tts', {
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ text: en, lang:'en', gender: localStorage.getItem('ioma_gender') || 'female' })
    })
    .then(function(r){ if (!r.ok) throw new Error(); return r.blob(); })
    .then(function(blob){
      var url = URL.createObjectURL(blob);
      var audio = new Audio(url);
      window.__iomaAudio = { audio: audio, url: url, btn: btn };
      audio.onended = function(){ if (btn) btn.classList.remove('playing'); URL.revokeObjectURL(url); window.__iomaAudio = null; };
      audio.onerror = function(){ if (btn) btn.classList.remove('playing'); };
      audio.play();
    })
    .catch(function(){
      if ('speechSynthesis' in window){
        var u = new SpeechSynthesisUtterance(en);
        u.lang = 'en-GB';
        u.onend = function(){ if (btn) btn.classList.remove('playing'); };
        speechSynthesis.cancel();
        speechSynthesis.speak(u);
      } else if (btn) btn.classList.remove('playing');
    });
  }
  function stopAll(){
    if (window.__iomaAudio){
      try { window.__iomaAudio.audio.pause(); } catch(e){}
      try { URL.revokeObjectURL(window.__iomaAudio.url); } catch(e){}
      if (window.__iomaAudio.btn) window.__iomaAudio.btn.classList.remove('playing');
      window.__iomaAudio = null;
    }
    if ('speechSynthesis' in window) speechSynthesis.cancel();
  }
  window.iomaSpeakEnglish = speakEnglish;
  window.iomaStopAll = stopAll;

  // ---------- SKELETON ----------
  function initSkeleton(){
    document.querySelectorAll('.placeholder').forEach(function(el){
      if (el.dataset.skeleton) return;
      el.dataset.skeleton = '1';
      if (/Загрузка|Loading/.test(el.textContent) || !el.textContent.trim()){
        el.innerHTML = '<div class="ioma-skel-line"></div><div class="ioma-skel-line" style="width:70%"></div><div class="ioma-skel-line" style="width:50%"></div>';
      }
    });
  }

  function init(){
    initPageTransitions();
    initSmoothAnchors();
    initBackToTop();
    initReveal();
    initTTSButtons();
    initSkeleton();
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();

  var mo = new MutationObserver(function(){ initTTSButtons(); });
  mo.observe(document.body, { childList:true, subtree:true });
})();
INTEREOF
echo "  ✓ interactions.js ($(wc -l < interactions.js) строк)"
echo ""

# ---------- 4. Дефолт — светлая тема ----------
echo "[4/5] Делаю светлую тему по умолчанию"
for f in *.js; do
  [ -f "$f" ] || continue
  perl -i -pe "s/else if \(matchMedia\('\(prefers-color-scheme: light\)'\)\.matches\) document\.documentElement\.classList\.add\('light'\);/else document.documentElement.classList.add('light');/g" "$f"
done
for f in *.html; do
  [ -f "$f" ] || continue
  perl -i -pe "s/else if \(matchMedia\('\(prefers-color-scheme: light\)'\)\.matches\) document\.documentElement\.classList\.add\('light'\);/else document.documentElement.classList.add('light');/g" "$f"
done
echo "  ✓ Тема: светлая по умолчанию"
echo ""

# ---------- 5. Проверка ----------
echo "[5/5] Проверяю"
lsof -ti:12000 | xargs kill -9 2>/dev/null
sleep 1

node server.js > /tmp/ioma_bw.log 2>&1 &
PID=$!
sleep 2

FAIL=0
for PAGE in / /dashboard /test /lesson /login /register /profile /vocabulary /speaking /listening /writing; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$PAGE")
  [ "$CODE" != "200" ] && echo "  ✗ $PAGE → $CODE" && FAIL=$((FAIL+1))
done
for ASSET in /styles.css /particles.js /interactions.js /app.js; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$ASSET")
  [ "$CODE" != "200" ] && echo "  ✗ $ASSET → $CODE" && FAIL=$((FAIL+1))
done

kill $PID 2>/dev/null
wait $PID 2>/dev/null

echo ""
echo "============================================"
if [ $FAIL -eq 0 ]; then
  echo "  ✓ МИНИМАЛИЗМ УСТАНОВЛЕН"
  echo "============================================"
  echo ""
  echo "Что теперь:"
  echo "  • Только чёрное и белое. Никакого цвета."
  echo "  • Заголовки — Inter Black, UPPERCASE, тугой трекинг"
  echo "  • Никаких градиентов, теней, свечения"
  echo "  • Острые углы (радиус 0), тонкие линии 1px"
  echo "  • Hover: инверсия или жирная граница"
  echo "  • Светлая тема по умолчанию"
  echo "  • Частицы и эффекты отключены"
  echo ""
  echo "Обнови браузер Cmd+Shift+R"
  echo "Запуск: npm start"
else
  echo "  ⚠ ПРОБЛЕМ: $FAIL"
  echo "  Лог: /tmp/ioma_bw.log"
fi
echo "============================================"
