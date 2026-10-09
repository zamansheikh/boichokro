#!/usr/bin/env python3
"""Compose Play Store screenshots: headline + framed device capture.
usage: make.py <lang> <raw_dir> <out_dir>
raw_dir holds 01.png..08.png (1080x2400 device captures)."""
import json, os, subprocess, sys, base64, pathlib
lang, raw, out = sys.argv[1], sys.argv[2], sys.argv[3]
here = pathlib.Path(__file__).parent
shots = json.load(open(here / 'shots.json'))
CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
os.makedirs(out, exist_ok=True)
logo = base64.b64encode(open(here / 'logo.png', 'rb').read()).decode()
for i, shot in enumerate(shots, 1):
    img = pathlib.Path(raw) / f'{i:02d}.png'
    if not img.exists():
        print('missing', img); continue
    data = base64.b64encode(open(img, 'rb').read()).decode()
    dark = shot.get('theme') == 'green'
    bar = shot.get('bar', '#F7F3EA')
    bar_fg = shot.get('barFg', '#1D2A26')
    bar_h = shot.get('barH', 78)
    html = f'''<!doctype html><html><head><meta charset="utf-8">
<link href="https://fonts.googleapis.com/css2?family=Noto+Serif+Bengali:wght@600;700&family=Hind+Siliguri:wght@400;500;600&display=swap" rel="stylesheet">
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
html,body{{width:1080px;height:1920px;overflow:hidden}}
body{{font-family:'Hind Siliguri',sans-serif;position:relative;
 background:{'linear-gradient(160deg,#1F5C4A 0%,#123B30 100%)' if dark else '#F7F3EA'};
 color:{'#FFFDF8' if dark else '#1D2A26'}}}
.rings{{position:absolute;left:50%;top:1180px;width:0;height:0}}
.rings i{{position:absolute;border-radius:50%;border:2px solid {'rgba(255,253,248,.08)' if dark else 'rgba(31,92,74,.08)'};transform:translate(-50%,-50%)}}
.brand{{position:absolute;top:64px;left:72px;display:flex;align-items:center;gap:14px;font-family:'Noto Serif Bengali',serif;font-weight:700;font-size:34px;
 color:{'#FFFDF8' if dark else '#1F5C4A'}}}
.brand span.dot{{width:56px;height:56px;border-radius:50%;background:#FFFDF8;overflow:hidden;display:block}}
.brand img{{width:56px;height:56px;transform:scale(1.55);display:block}}
.eyebrow{{position:absolute;top:176px;left:72px;right:72px;font-weight:600;font-size:28px;letter-spacing:{'0' if lang=='bn' else '3px'};text-transform:uppercase;
 color:{'#F0B062' if dark else '#B8690F'}}}
h1{{position:absolute;top:222px;left:72px;right:72px;font-family:'Noto Serif Bengali',serif;font-weight:700;font-size:{'76px' if lang=='bn' else '78px'};line-height:{'1.28' if lang=='bn' else '1.14'};letter-spacing:-.5px}}
p{{position:absolute;top:{'452px' if lang=='bn' else '432px'};left:72px;right:96px;font-size:34px;line-height:1.45;opacity:.82}}
.phone{{position:absolute;left:50%;top:620px;width:760px;transform:translateX(-50%);border-radius:74px;padding:16px;
 background:#101613;box-shadow:0 50px 90px rgba(18,40,32,.34),0 0 0 2px rgba(255,255,255,.08) inset}}
.screen{{position:relative;border-radius:60px;overflow:hidden;width:728px;height:1618px;background:#F7F3EA}}
.screen img{{width:728px;display:block}}
.status{{position:absolute;top:0;left:0;right:0;height:{bar_h}px;background:{bar};color:{bar_fg};display:flex;align-items:center;justify-content:space-between;padding:{10 if bar_h > 60 else 2}px 44px 0;font-weight:600;font-size:22px}}
.status .r{{display:flex;gap:9px;align-items:center}}
.status svg{{height:19px;fill:{bar_fg}}}
.cam{{position:absolute;top:{27 if bar_h > 60 else 16}px;left:50%;width:22px;height:22px;border-radius:50%;background:#101613;transform:translateX(-50%)}}
</style></head><body>
<div class="rings">{''.join(f'<i style="width:{r}px;height:{r}px"></i>' for r in (900,1160,1420,1680,1940))}</div>
<div class="brand"><span class="dot"><img src="data:image/png;base64,{logo}"></span>{'বইচক্র' if lang=='bn' else 'Boichokro'}</div>
<div class="eyebrow">{shot[lang]['eyebrow']}</div>
<h1>{shot[lang]['title']}</h1>
<p>{shot[lang]['body']}</p>
<div class="phone"><div class="screen"><img src="data:image/png;base64,{data}">
<div class="status"><span>9:30</span><span class="r">
<svg viewBox="0 0 24 18"><path d="M12 3C7.6 3 3.6 4.8.7 7.7l2.1 2.1C5.2 7.5 8.4 6 12 6s6.8 1.5 9.2 3.8l2.1-2.1C20.4 4.8 16.4 3 12 3zm0 6c-2.8 0-5.3 1.1-7.1 2.9l2.1 2.1C8.3 12.8 10 12 12 12s3.7.8 5 2l2.1-2.1C17.3 10.1 14.8 9 12 9zm0 6c-1.1 0-2.1.4-2.8 1.2L12 19l2.8-2.8C14.1 15.4 13.1 15 12 15z"/></svg>
<svg viewBox="0 0 22 18"><path d="M1 14h3v3H1zM6 11h3v6H6zM11 7h3v10h-3zM16 2h3v15h-3z"/></svg>
<svg viewBox="0 0 30 16"><rect x="1" y="2" width="24" height="12" rx="3.5"/><rect x="26.5" y="6" width="2.5" height="4" rx="1"/></svg>
</span></div><div class="cam"></div></div></div>
</body></html>'''
    page = here / f'_{lang}_{i:02d}.html'
    page.write_text(html, encoding='utf-8')
    target = pathlib.Path(out) / f"{i:02d}-{shot['slug']}.png"
    subprocess.run([CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars', '--force-device-scale-factor=1',
                    '--window-size=1080,1920', '--virtual-time-budget=6000', f'--screenshot={target}', page.as_uri()],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    page.unlink()
    print('wrote', target)
