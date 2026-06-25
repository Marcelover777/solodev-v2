# Fonte do banner

`banner.html` é a **fonte determinística** do banner do Forger (o original do Crucible não tinha fonte — só os binários). Tema: forja incandescente (combina com "Forger"). `window.setFrame(t)`, `t∈[0,1)`, dá um loop perfeito.

Gera `../banner.png` (estático, nítido @2x) e `../banner.gif` (animado, 26 frames). Precisa de **Chrome** + **ffmpeg** (ferramentas externas — o plugin em si é zero-dep; isto é só build de asset).

## Como regenerar

```bash
# 1. Render via headless Chrome (ou qualquer runner de puppeteer-core):
#    - PNG: viewport 1280x400 @deviceScaleFactor 2, setFrame(0.30), screenshot
#    - 26 frames @1x: para f em 0..25 → setFrame(f/26) → screenshot frames/f###.png

# 2. PNG: a própria screenshot @2x (2560x800) já é o banner.png.

# 3. GIF (palette de qualidade, escala 1100 como o original):
ffmpeg -y -framerate 12 -i frames/f%03d.png \
  -vf "scale=1100:-1:flags=lanczos,palettegen=max_colors=128:stats_mode=diff" palette.png
ffmpeg -y -framerate 12 -i frames/f%03d.png -i palette.png \
  -lavfi "scale=1100:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=sierra2_4a:diff_mode=rectangle" \
  -loop 0 ../banner.gif
```

Para um rebrand futuro: edite o `.title`, o `.eyebrow` (contagem de skills), as `.pill` e a linha `.repo` no `banner.html`, e rode de novo.
