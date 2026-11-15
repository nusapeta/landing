# Nusapeta landing page

The single page served at <https://nusapeta.web.id>. It explains the two Nusapeta
engines, links to the live demo, gives the compose quickstart, and states the
limits with measured numbers.

Static HTML, CSS, and one small script. No framework, no build step, no
third-party requests. The only server is nginx serving files from `site/`.

## Layout

```
site/            the published tree (index, 404, styles, app.js, assets)
deploy/          nginx config, security headers, compose file for the homelab
scripts/check.py static checks used by CI
PLAN.md          plan, palette rationale, verification table, rollback
```

## Run it locally

```bash
docker build -t nusapeta-lp:local .
docker run --rm -p 127.0.0.1:8097:8080 nusapeta-lp:local
```

Then open <http://127.0.0.1:8097/>. For a quick preview without a container:

```bash
python3 -m http.server 8097 --directory site
```

## Deploy

`deploy/compose.yml` runs the image as `nusapeta-lp` on the external
`1panel-network`, with no published ports, a read-only root filesystem, and all
capabilities dropped. A Cloudflare Tunnel container on the same network forwards
`https://nusapeta.web.id` to `http://nusapeta-lp:8080`.

```bash
docker compose -f deploy/compose.yml up -d --build
docker compose -f deploy/compose.yml ps
```

## Checks

`python3 scripts/check.py` verifies that every internal anchor resolves, every
local asset reference exists, and no em dash or en dash slipped into the copy.
CI builds the image, boots it, and asserts `/` is 200, `/healthz` is `ok`, a
missing path is 404, and the security and cache headers are present.

## Design notes

- Palette comes from the logo: navy `#1B3A5C`, teal `#1B7FA8`, deep teal
  `#0F5B7A`, orange `#F5A623`, muted `#5A6B7B`, surface `#F2F6F9`.
- Contrast, measured with a WCAG checker: navy on white 11.63:1, deep teal on
  white 7.51:1, deep teal on surface 6.91:1, navy on orange 5.74:1, muted on
  white 5.49:1, muted on surface 5.05:1, footer note on navy 6.19:1. Links use
  deep teal for that reason; orange is never used as text color.
- Headings use `ui-serif` (Georgia where available), body text uses the system
  sans stack. No webfonts, so no font request and no layout shift.
- Light theme only, because the supplied logo has a white background and its
  white pin half would disappear on a dark surface.
- The page works without JavaScript; the script only adds the copy button.

## Verification

Checked 2026-11-15 on the built image and on the deployed site:

| Check | Result |
|---|---|
| `/` | 200 with `Cache-Control: public, max-age=300` |
| `/healthz` | body `ok` |
| Missing path | 404 with the custom page |
| `X-Content-Type-Options`, `Referrer-Policy`, `X-Frame-Options`, `Permissions-Policy`, `Content-Security-Policy` | present |
| `/assets/logo-lockup.png` | 200, `Cache-Control: public, max-age=31536000, immutable` |
| `/styles.css?v=4` | 200, `Cache-Control: public, max-age=14400, must-revalidate` at the edge (origin sends 300) |
| Rendered text contrast | every visible text node passes AA at 1440 px and 375 px |
| Tap targets | brand 44 px, footer links 44 px, buttons and rows at least 44 px |
| Layout at 320, 375, 768, 1024, 1440 px | no horizontal overflow (`scrollWidth` equals `innerWidth`) |
| Copy button, success path | status reads `Commands copied to the clipboard.` |
| Copy button, denied clipboard | status reads `Copy failed. Select the commands above and copy them manually.` |
| Live site after deploy | `https://nusapeta.web.id/` returns 200 through the Cloudflare Tunnel |
| Live `/healthz` | body `ok` |
| Live missing path | 404 with the custom page |
| Container placement | `nusapeta-lp` on `1panel-network`, no published ports |

## License

Code and page copy: MIT, see `LICENSE`. The logo and the images derived from it
in `site/assets/` are brand assets, not covered by that license.
