#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  РЕДИЗАЙН: cyberpunk × ayurveda"
echo "============================================"

mkdir -p _unused/backup
cp styles.css "_unused/backup/styles.css.$(date +%Y%m%d_%H%M%S)" 2>/dev/null
echo "✓ Бэкап старого styles.css → _unused/backup/"
echo ""

cat > styles.css << 'CSSEOF'
@import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&family=Cormorant+Garamond:ital,wght@0,400;0,500;0,600;1,400;1,500&family=JetBrains+Mono:wght@400;500&display=swap');

*{box-sizing:border-box;margin:0;padding:0}

:root{
  color-scheme:dark;
  --sans:'Inter',-apple-system,BlinkMacSystemFont,system-ui,sans-serif;
  --display:'Space Grotesk','Inter',sans-serif;
  --serif:'Cormorant Garamond',Georgia,serif;
  --mono:'JetBrains Mono','SF Mono',monospace;

  --bg:#05060f; --bg-2:#0a0c18; --card:#0e1120; --card-2:#141830; --field:#0a0c18;
  --text:#eaeaf5; --text-muted:#9898b8; --text-dim:#5c5c78;
  --border:rgba(130,140,200,.08); --border-2:rgba(130,140,200,.16);
  --track:rgba(130,140,200,.1);

  --neon:#00e5ff; --neon-2:#7c3aed; --neon-3:#d946ef;
  --saffron:#f5a623; --jade:#34d399; --magenta:#d946ef;

  --gold:#00e5ff; --gold-2:#5eead4; --gold-dim:#0891b2;
  --accent:#00e5ff; --accent-2:#5eead4; --accent-soft:rgba(0,229,255,.12);
  --on-accent:#05060f;

  --ok:#34d399; --ok-soft:rgba(52,211,153,.12);
  --err:#f87171; --err-soft:rgba(248,113,113,.12); --err-solid:#f87171;
  --red:#f87171; --red-2:#fca5a5; --orange:#f5a623;

  --flame:linear-gradient(135deg,#00e5ff 0%,#7c3aed 100%);
  --flame-2:linear-gradient(135deg,#d946ef 0%,#00e5ff 100%);
  --flame-soft:linear-gradient(135deg,rgba(0,229,255,.14),rgba(124,58,237,.14));

  --topbar-bg:rgba(5,6,15,.72); --overlay:rgba(5,6,15,.88);
  --shadow-sm:0 1px 2px rgba(0,0,0,.5);
  --shadow-md:0 12px 40px -12px rgba(0,229,255,.15);
  --shadow-lg:0 32px 80px -24px rgba(0,0,0,.9);
  --shadow-gold:0 12px 40px -12px rgba(0,229,255,.4);
  --shadow-fire:0 16px 40px -12px rgba(0,229,255,.5);

  --r-sm:10px;--r:14px;--r-lg:20px;--r-xl:28px;--r-pill:999px;
  --ease:cubic-bezier(.22,.61,.36,1);
  --ease-out:cubic-bezier(.16,1,.3,1);
  --t:240ms;
}

html{scroll-behavior:smooth;-webkit-text-size-adjust:100%}

body{
  font-family:var(--sans);font-size:15px;line-height:1.6;font-weight:400;
  background:var(--bg);color:var(--text);min-height:100vh;
  -webkit-font-smoothing:antialiased;text-rendering:optimizeLegibility;
  overflow-x:hidden;position:relative;
}

body::before{
  content:"";position:fixed;inset:-20%;z-index:0;pointer-events:none;
  background:
    radial-gradient(circle at 15% 25%, rgba(0,229,255,.18) 0%, transparent 35%),
    radial-gradient(circle at 85% 15%, rgba(217,70,239,.14) 0%, transparent 40%),
    radial-gradient(circle at 75% 85%, rgba(124,58,237,.16) 0%, transparent 40%),
    radial-gradient(circle at 20% 80%, rgba(52,211,153,.10) 0%, transparent 35%);
  filter:blur(30px);animation:bubbleFloat 24s ease-in-out infinite;
}
body::after{
  content:"";position:fixed;inset:0;z-index:0;pointer-events:none;opacity:.35;
  background-image:
    linear-gradient(rgba(0,229,255,.04) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0,229,255,.04) 1px, transparent 1px);
  background-size:60px 60px;
  -webkit-mask-image:radial-gradient(ellipse at center, black 30%, transparent 80%);
  mask-image:radial-gradient(ellipse at center, black 30%, transparent 80%);
}
@keyframes bubbleFloat{0%,100%{transform:translate(0,0) scale(1)}33%{transform:translate(3%,-2%) scale(1.05)}66%{transform:translate(-2%,3%) scale(.98)}}
@keyframes rise{from{opacity:0;transform:translateY(12px)}to{opacity:1;transform:none}}
@keyframes fadeIn{from{opacity:0}to{opacity:1}}
@keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.6;transform:scale(.85)}}

main,header,section,footer,.topbar{position:relative;z-index:1}

h1,h2,h3,h4,.serif{font-family:var(--display);font-weight:600;letter-spacing:-.03em;line-height:1.05;color:var(--text)}
h1{font-size:clamp(40px,6vw,80px)}
h2{font-size:clamp(28px,3.8vw,48px)}
h3{font-size:20px}

a{color:inherit;text-decoration:none}
::selection{background:var(--accent-soft);color:var(--text)}
:focus-visible{outline:2px solid var(--neon);outline-offset:3px;border-radius:var(--r-sm)}

.topbar{display:grid;grid-template-columns:1fr auto 1fr;align-items:center;gap:24px;padding:18px 40px;position:sticky;top:0;z-index:100;background:var(--topbar-bg);-webkit-backdrop-filter:blur(24px) saturate(1.6);backdrop-filter:blur(24px) saturate(1.6);border-bottom:1px solid var(--border)}
.topbar-left{display:flex;gap:10px;align-items:center}
.topbar-right{display:flex;align-items:center;gap:12px;justify-content:flex-end}
.brand{font-family:var(--display);font-size:22px;font-weight:700;letter-spacing:-.04em;line-height:1;text-align:center}
.brand b,.brand span:first-child{background:var(--flame);-webkit-background-clip:text;background-clip:text;color:transparent}
.brand span{color:var(--text)}
.back-link{color:var(--text-muted);font-size:13.5px;font-weight:500;padding:8px 14px;border-radius:var(--r-sm);display:inline-block;transition:all var(--t) var(--ease);border:1px solid transparent}
.back-link:hover{color:var(--neon);border-color:var(--border-2);background:rgba(0,229,255,.04)}
.theme-btn{display:inline-flex;align-items:center;gap:8px;background:transparent;border:1px solid var(--border-2);color:var(--text-muted);padding:9px 14px;border-radius:var(--r-sm);font-size:13px;font-weight:500;cursor:pointer;transition:all var(--t);font-family:inherit}
.theme-btn:hover{border-color:var(--neon);color:var(--neon);background:rgba(0,229,255,.04);box-shadow:0 0 24px -8px rgba(0,229,255,.5)}
.theme-btn svg{width:15px;height:15px;fill:none;stroke:currentColor;stroke-width:1.7;stroke-linecap:round;stroke-linejoin:round}

.btn-primary,.btn-ghost,.cta-mini,.lh-cta,.stage-btn{display:inline-flex;align-items:center;justify-content:center;gap:10px;font-family:var(--sans);font-weight:600;font-size:14.5px;letter-spacing:-.005em;padding:14px 28px;border-radius:var(--r-pill);border:none;cursor:pointer;transition:all var(--t) var(--ease);text-decoration:none;position:relative}
.btn-primary,.cta-mini,.lh-cta{background:var(--flame);background-size:200% 200%;color:var(--on-accent);box-shadow:0 8px 32px -12px rgba(0,229,255,.6),inset 0 0 0 1px rgba(255,255,255,.1)}
.btn-primary:hover,.cta-mini:hover,.lh-cta:hover{transform:translateY(-2px);box-shadow:0 16px 48px -12px rgba(0,229,255,.8),inset 0 0 0 1px rgba(255,255,255,.2);background-position:100% 50%}
.btn-ghost{background:transparent;color:var(--text);border:1px solid var(--border-2)}
.btn-ghost:hover{border-color:var(--neon);color:var(--neon);background:rgba(0,229,255,.04);transform:translateY(-2px)}
.btn-primary:disabled,.btn-ghost:disabled,.stage-btn:disabled{opacity:.4;cursor:not-allowed;transform:none;box-shadow:none}
.cta-mini{padding:10px 20px;font-size:13px}
.stage-btn{padding:16px 36px;font-size:15px}

.card,.stage-card,.question-card,.reading-block,.listening-block,.writing-block,.speaking-block,.result-card,.level-hero,.unit,.quick-card,.lesson-rule,.lesson-exercises,.lr-card,.lst-card,.spk-feedback,.wrt-result,.wrt-task,.spk-prompt,.voc-item,.assist-window,.level-badge,.stat-card,.skill-card,.profile-card,.auth-card,.profile-hero{background:linear-gradient(180deg,rgba(20,24,44,.7) 0%,rgba(14,17,32,.7) 100%);border:1px solid var(--border-2);border-radius:var(--r-lg);box-shadow:inset 0 1px 0 rgba(255,255,255,.04);-webkit-backdrop-filter:blur(20px) saturate(1.4);backdrop-filter:blur(20px) saturate(1.4);transition:border-color var(--t) var(--ease),transform var(--t) var(--ease),box-shadow var(--t) var(--ease)}
.card:hover{border-color:rgba(0,229,255,.4);box-shadow:0 20px 48px -20px rgba(0,229,255,.5),inset 0 1px 0 rgba(255,255,255,.08);transform:translateY(-2px)}

input[type=text],input[type=email],input[type=password],input[type=tel],.va-row input,#writingInput,#wrtInput,.lst-input textarea,.assist-foot textarea,.auth-input,textarea{width:100%;background:var(--field);border:1px solid var(--border-2);border-radius:var(--r);color:var(--text);padding:14px 16px;font-family:inherit;font-size:15px;line-height:1.5;outline:none;transition:all var(--t) var(--ease);resize:vertical}
input::placeholder,textarea::placeholder{color:var(--text-dim)}
input:focus,textarea:focus{border-color:var(--neon);background:var(--card);box-shadow:0 0 0 3px rgba(0,229,255,.15),0 0 32px -8px rgba(0,229,255,.4)}

.level-progress-bar,.mini-bar,.lhp-bar,.skill-bar,.pl-bar,.wr-crit-bar,.fb-crit-bar,.bar,.progress-bar,.cr-bar{background:var(--track);border-radius:var(--r-pill);overflow:hidden;position:relative}
.level-progress-fill,.mini-fill,.lhp-fill,.skill-fill,.pl-fill,.wr-crit-fill,.fb-crit-fill,.bar-fill,.progress-bar>div{height:100%;background:var(--flame);background-size:200% 100%;border-radius:inherit;transition:width .8s var(--ease-out);box-shadow:0 0 16px -2px rgba(0,229,255,.6)}

.q-option,.ex-opt{display:flex;align-items:center;gap:14px;width:100%;padding:15px 18px;text-align:left;background:rgba(20,24,44,.4);color:var(--text);border:1px solid var(--border-2);border-radius:var(--r);font-family:inherit;font-size:15px;line-height:1.5;cursor:pointer;transition:all var(--t) var(--ease);position:relative}
.q-option:hover,.ex-opt:hover{border-color:rgba(0,229,255,.5);background:rgba(0,229,255,.04);transform:translateX(3px);box-shadow:0 0 24px -10px rgba(0,229,255,.5)}
.q-option.selected,.ex-opt.selected{border-color:var(--neon);background:rgba(0,229,255,.08);box-shadow:0 0 0 3px rgba(0,229,255,.15),0 0 32px -8px rgba(0,229,255,.5)}
.ex-opt.correct{border-color:var(--ok);background:rgba(52,211,153,.1);box-shadow:0 0 24px -8px rgba(52,211,153,.6)}
.ex-opt.wrong{border-color:var(--err);background:rgba(248,113,113,.1)}
.q-option-letter,.ex-letter{width:30px;height:30px;flex-shrink:0;display:flex;align-items:center;justify-content:center;border:1px solid var(--border-2);border-radius:50%;font-family:var(--mono);font-size:12px;font-weight:500;color:var(--text-muted);transition:all var(--t)}
.q-option.selected .q-option-letter,.ex-opt.selected .ex-letter{background:var(--flame);border-color:transparent;color:var(--on-accent)}
.ex-opt.correct .ex-letter{background:var(--ok);border-color:var(--ok);color:var(--on-accent)}
.ex-opt.wrong .ex-letter{background:var(--err);border-color:var(--err);color:#fff}

.level-badge{display:inline-flex;align-items:center;gap:10px;padding:6px 14px 6px 6px;border-radius:var(--r-pill);cursor:pointer;text-decoration:none;color:inherit}
.level-pill{min-width:52px;height:38px;padding:0 12px;display:inline-flex;align-items:center;justify-content:center;background:var(--flame);border-radius:var(--r-pill);font-family:var(--mono);font-size:15px;font-weight:600;color:var(--on-accent);letter-spacing:.02em;box-shadow:0 0 24px -8px rgba(0,229,255,.7)}
.level-progress-wrap{min-width:120px;display:flex;flex-direction:column;gap:5px}
.level-progress-bar{height:3px}
.level-progress-text{display:flex;justify-content:space-between;font-size:11px;color:var(--text-muted);font-weight:500;text-transform:uppercase;letter-spacing:.08em}

.hero{position:relative;padding:120px 32px 100px;max-width:1280px;margin:0 auto;overflow:hidden;text-align:center}
.hero-copy{position:relative;z-index:2;max-width:940px;margin:0 auto}
.eyebrow{display:inline-flex;align-items:center;gap:8px;font-size:11.5px;font-weight:600;letter-spacing:.22em;color:var(--neon);text-transform:uppercase;margin-bottom:28px;padding:8px 16px;background:rgba(0,229,255,.06);border-radius:var(--r-pill);border:1px solid rgba(0,229,255,.25);box-shadow:0 0 24px -8px rgba(0,229,255,.6)}
.eyebrow::before{content:"";width:6px;height:6px;background:var(--neon);border-radius:50%;box-shadow:0 0 12px var(--neon);animation:pulse 2s ease-in-out infinite}
.hero h1{margin:0 0 32px}
.hero h1 .accent{font-family:var(--serif);font-style:italic;font-weight:500;background:linear-gradient(135deg,#00e5ff 0%,#d946ef 50%,#7c3aed 100%);background-size:200% 200%;-webkit-background-clip:text;background-clip:text;color:transparent;animation:bubbleFloat 12s ease-in-out infinite}
.lede{font-size:18px;line-height:1.65;color:var(--text-muted);max-width:640px;margin:0 auto 44px;font-weight:300}
.hero-actions{display:flex;gap:14px;flex-wrap:wrap;margin-bottom:72px;justify-content:center}
.hero-stats{display:flex;gap:80px;flex-wrap:wrap;padding-top:44px;border-top:1px solid var(--border);justify-content:center}
.stat b{display:block;font-family:var(--serif);font-size:52px;font-weight:500;line-height:1;margin-bottom:12px;letter-spacing:-.03em;background:linear-gradient(135deg,#00e5ff 0%,#5eead4 100%);-webkit-background-clip:text;background-clip:text;color:transparent}
.stat span{font-size:12px;color:var(--text-muted);line-height:1.5;font-weight:500;text-transform:uppercase;letter-spacing:.1em}

.features,.method{max-width:1280px;margin:0 auto;padding:60px 32px 120px;position:relative;z-index:1}
.features h2,.method h2{margin:0 0 56px;text-align:center}
.features-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(320px,1fr));gap:20px}
.feature-card{position:relative;padding:36px 32px;border-radius:var(--r-lg);overflow:hidden;transition:all .4s var(--ease-out);background:linear-gradient(180deg,rgba(20,24,44,.7) 0%,rgba(14,17,32,.7) 100%);border:1px solid var(--border-2);-webkit-backdrop-filter:blur(20px);backdrop-filter:blur(20px)}
.feature-card::before{content:"";position:absolute;top:0;left:0;right:0;height:2px;background:var(--flame);opacity:.8}
.feature-card:hover{transform:translateY(-4px);border-color:rgba(0,229,255,.4);box-shadow:0 24px 60px -24px rgba(0,229,255,.6),inset 0 1px 0 rgba(255,255,255,.06)}
.feature-num{font-family:var(--mono);font-size:11px;font-weight:500;color:var(--neon);letter-spacing:.16em;margin-bottom:20px;opacity:.85}
.feature-card h3{margin:0 0 14px;font-size:22px}
.feature-card p{margin:0;font-size:14.5px;line-height:1.7;color:var(--text-muted)}

.method-list{display:grid;gap:12px;max-width:1000px;margin:0 auto}
.method-item{display:grid;grid-template-columns:220px 1fr;gap:32px;padding:28px 32px;border-radius:var(--r-lg);transition:all var(--t);background:linear-gradient(180deg,rgba(20,24,44,.7) 0%,rgba(14,17,32,.7) 100%);border:1px solid var(--border-2);-webkit-backdrop-filter:blur(20px);backdrop-filter:blur(20px)}
.method-item:hover{border-color:rgba(0,229,255,.35);transform:translateX(4px);box-shadow:0 16px 40px -20px rgba(0,229,255,.5)}
.method-item b{font-family:var(--display);font-size:16px;font-weight:600;background:var(--flame);-webkit-background-clip:text;background-clip:text;color:transparent}
.method-item p{margin:0;font-size:15px;line-height:1.7;color:var(--text-muted)}

.footer{padding:48px 32px;border-top:1px solid var(--border);max-width:1280px;margin:0 auto;display:flex;justify-content:space-between;align-items:center;gap:20px;flex-wrap:wrap;color:var(--text-muted);font-size:13.5px;position:relative;z-index:1}

.assist-fab{position:fixed;right:28px;bottom:28px;z-index:200;display:inline-flex;align-items:center;gap:10px;background:var(--flame);background-size:200% 100%;color:var(--on-accent);border:none;border-radius:var(--r-pill);padding:15px 24px;font-size:14px;font-weight:600;cursor:pointer;box-shadow:0 16px 40px -12px rgba(0,229,255,.7),inset 0 0 0 1px rgba(255,255,255,.15);transition:all var(--t);animation:bubbleFloat 8s ease-in-out infinite;font-family:inherit}
.assist-fab:hover{transform:translateY(-3px) scale(1.04);box-shadow:0 24px 60px -12px rgba(0,229,255,.9)}
.assist-overlay{position:fixed;inset:0;z-index:999;display:flex;align-items:stretch;justify-content:center;padding:20px;background:var(--overlay);-webkit-backdrop-filter:blur(16px);backdrop-filter:blur(16px);animation:fadeIn var(--t)}
.assist-overlay[hidden]{display:none}
.assist-window{width:100%;max-width:880px;display:flex;flex-direction:column;overflow:hidden;box-shadow:var(--shadow-lg);animation:rise 300ms var(--ease-out);border-radius:var(--r-xl)}
.assist-head{padding:22px 28px;border-bottom:1px solid var(--border);display:flex;align-items:center;gap:14px}
.assist-head h2{font-size:19px;margin:0}
.assist-head .sub{font-size:12.5px;color:var(--text-muted);margin-top:2px}
.assist-head .orb{width:42px;height:42px;flex-shrink:0;display:flex;align-items:center;justify-content:center;background:var(--flame);border-radius:var(--r);color:var(--on-accent);box-shadow:0 0 28px -8px rgba(0,229,255,.8)}
.assist-close{width:36px;height:36px;margin-left:auto;background:transparent;border:none;border-radius:var(--r-sm);font-size:22px;line-height:1;color:var(--text-muted);cursor:pointer;transition:all var(--t)}
.assist-close:hover{color:var(--neon);background:rgba(0,229,255,.06)}
.assist-body{flex:1;overflow-y:auto;padding:26px 30px;min-height:300px;max-height:62vh;background:rgba(5,6,15,.5)}
.assist-msg{margin-bottom:16px;max-width:82%;animation:rise 260ms var(--ease-out)}
.assist-msg.user{margin-left:auto}
.assist-msg .bubble{padding:12px 16px;font-size:14.5px;line-height:1.6;white-space:pre-wrap;border-radius:var(--r-lg)}
.assist-msg.user .bubble{background:var(--flame);color:var(--on-accent);border-bottom-right-radius:6px;box-shadow:0 8px 24px -10px rgba(0,229,255,.6)}
.assist-msg.ai .bubble{background:rgba(20,24,44,.7);border:1px solid var(--border-2);color:var(--text);border-bottom-left-radius:6px}
.assist-msg.error .bubble{background:var(--err-soft);color:var(--err);border:1px solid var(--err)}
.assist-empty{text-align:center;padding:48px 20px;color:var(--text-muted)}
.assist-empty h3{color:var(--text);font-size:24px;margin-bottom:10px;font-family:var(--display)}
.assist-empty p{font-size:14.5px;line-height:1.6}
.assist-empty .sugg{display:flex;flex-wrap:wrap;gap:8px;justify-content:center;margin-top:26px}
.assist-empty .sugg button{background:transparent;border:1px solid var(--border-2);border-radius:var(--r-pill);padding:10px 16px;font-size:13px;color:var(--text-muted);cursor:pointer;transition:all var(--t);font-family:inherit}
.assist-empty .sugg button:hover{border-color:var(--neon);color:var(--neon);box-shadow:0 0 24px -8px rgba(0,229,255,.5);transform:translateY(-2px)}
.assist-foot{padding:14px 18px 16px;border-top:1px solid var(--border);display:flex;gap:10px;align-items:flex-end}
.assist-foot textarea{flex:1;resize:none;max-height:120px;line-height:1.5;padding:12px 15px}
.assist-send{width:44px;height:44px;flex-shrink:0;display:flex;align-items:center;justify-content:center;background:var(--flame);color:var(--on-accent);border:none;border-radius:var(--r-sm);cursor:pointer;transition:all var(--t);box-shadow:0 8px 24px -10px rgba(0,229,255,.7)}
.assist-send:hover{transform:translateY(-2px);box-shadow:0 16px 32px -10px rgba(0,229,255,.9)}
.assist-send:disabled{opacity:.4;cursor:not-allowed;transform:none}

.hidden,[hidden]{display:none !important}
.placeholder{padding:32px;text-align:center;color:var(--text-muted);font-size:14px;background:rgba(20,24,44,.35);border:1px dashed var(--border-2);border-radius:var(--r)}

@media(max-width:820px){
  .topbar{grid-template-columns:auto 1fr auto;padding:14px 20px;gap:10px}
  .brand{font-size:19px}
  .theme-btn span{display:none}
  .level-badge{padding:4px 10px 4px 4px}
  .level-pill{min-width:44px;height:34px;font-size:13px}
  .level-progress-wrap{display:none}
  .hero{padding:80px 20px 60px}
  .hero-stats{gap:36px;padding-top:32px}
  .stat b{font-size:36px}
  .features,.method{padding:40px 20px 70px}
  .features h2,.method h2{margin-bottom:36px}
  .features-grid{grid-template-columns:1fr;gap:16px}
  .method-item{grid-template-columns:1fr;gap:8px;padding:24px 26px}
  .footer{padding:32px 20px;flex-direction:column;text-align:center}
  .assist-fab{right:16px;bottom:16px;padding:13px 18px;font-size:13px}
  .assist-overlay{padding:0}
  .assist-window{border-radius:0;max-width:none;height:100vh;border-width:0}
}
CSSEOF

LINES=$(wc -l < styles.css | tr -d ' ')
echo "✓ styles.css обновлён: $LINES строк"
echo ""

echo "Проверка:"
node server.js > /tmp/ioma_redesign.log 2>&1 &
PID=$!
sleep 2
FAIL=0
for PAGE in / /dashboard /test /lesson /login /vocabulary /speaking /listening /writing; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:12000$PAGE")
  [ "$CODE" != "200" ] && FAIL=$((FAIL+1))
done
kill $PID 2>/dev/null
wait $PID 2>/dev/null

if [ $FAIL -eq 0 ]; then
  echo "  ✓ Все страницы отвечают"
else
  echo "  ⚠ Проблем: $FAIL"
fi
echo ""
echo "============================================"
echo "  ✓ ГОТОВО"
echo "============================================"
echo ""
echo "Откат: cp _unused/backup/styles.css.* styles.css"
echo "Запуск: npm start"
