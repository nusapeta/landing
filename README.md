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
- Light theme only, on purpose: the demo's only tile source is light, so a dark
  surface would need a second tile set or an inverted filter. The logo's white
  pin half is an additional reason to keep light surfaces.
- The hero shows four car routes measured from the live demo on 2026-11-16
  (Monas to Kota Tua, Jatinegara, Kemang, Grogol), simplified with
  Douglas-Peucker at 0.00045 degrees and inlined as SVG. Inline, not `<img>`,
  because only an inline element can be animated by the stylesheet.
- Those routes are drawn once on load, 900 ms with a 80/200/320/440 ms stagger,
  inside `@media (prefers-reduced-motion: no-preference)`. No loops, no scroll
  effects.
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
| `/styles.css?v=5` | 200, `Cache-Control: public, max-age=14400, must-revalidate` at the edge (origin sends 300) |
| Rendered text contrast | every visible text node passes AA at 1440 px and 375 px |
| Tap targets | brand 44 px, footer links 44 px, buttons and rows at least 44 px |
| Layout at 320, 375, 768, 1024, 1440 px | no horizontal overflow (`scrollWidth` equals `innerWidth`) |
| Copy button, success path | status reads `Commands copied to the clipboard.` |
| Copy button, denied clipboard | status reads `Copy failed. Select the commands above and copy them manually.` |
| Live site after deploy | `https://nusapeta.web.id/` returns 200 through the Cloudflare Tunnel |
| Live `/healthz` | body `ok` |
| Live missing path | 404 with the custom page |
| Container placement | `nusapeta-lp` on `1panel-network`, no published ports |

Checked again 2026-11-16 after the map revamp, on the deployed site:

| Check | Result |
|---|---|
| Hero geometry | 4 `path.hero-route`, rendered lengths 287/510/669/285 px, stroke `#f5a623` |
| Route motion | `animation-name: hero-route-draw`, `0.9s`, stagger 80/200/320/440 ms, `stroke-dashoffset` back to 0 after 1.4 s |
| Text contrast, whole page | 95 text nodes, 0 below AA; lowest 5.05:1 (muted on surface) |
| Layout at 320, 375, 768, 1024, 1440 px | no horizontal overflow; hero map 288/343/380/394/435 px wide |
| Hero fold | section ends at 843 px at 1440x900, so the map card is visible without scrolling |
| Tab order | 16 stops, every stop has `outline: solid 2px rgb(27, 58, 92)` |
| Footer headings | one `h2` ("Repositories and paperwork") plus two `h3` labels |
| Demo counterpart | route core carries `pathLength="1"` and `route-core-draw`; pins read 1 and 2; tile filter `saturate(0.55) contrast(1.04) brightness(1.02)` |

## Artifact and RSS measurement

`scripts/measure-artifacts.sh ../routeid` reproduces the island table on the
page. It reads the files produced by `make islands` in `nusapeta/route`, then
runs a local `nusa-serve` on `java.graph` and samples `/proc/<pid>/status`.

Measured 2026-11-18 16:31 UTC on Linux 7.2.15-1-omarchy x86_64, route commit
`843c493`, graph `java.graph` built 2026-11-12T09:22:10Z:

| State | VmRSS | RssAnon |
|---|---|---|
| 30 s idle | 15,072 kB | 6,724 kB |
| after 200 sequential `/route` requests | 26,572 kB | 11,388 kB |

Java, Sumatra, and Nusa Tenggara have v5 graphs with counts listed on the
page. Maluku on this machine is a stale v4 file that the current extractor
rejects. Kalimantan, Sulawesi, and Papua have no graph file here, so the page
shows them as unbuilt instead of inventing sizes. `python3 scripts/check.py`
passes with the new section and anchor.

## Sprint section, checked 2026-11-19

The `#sprint` section lists the endpoints added by the 18 to 19 November
branch work. Every number in it was re-measured against binaries built from
those branches, not copied from the PR text.

| Check | Result |
|---|---|
| `scripts/check.py` | 2 pages, no broken anchors, no missing assets, no em or en dash |
| Section anchor | `#sprint` resolves from the nav item `Changes` |
| Rows | 9, one per endpoint or parameter group |
| Layout at 320, 375, 768, 1024, 1440 px | no horizontal overflow; nav wraps at 560 px and below |
| Mobile table | `thead` visually hidden, each cell labelled Added / Measured here |
| Public demo, new paths | `/matrix`, `/isochrone`, `/nearest` return 404; `/route` returns 200 |
| `/matrix`, Monas to three targets | 45 ms, 133,244 expansions, 10,784 / 3,975 / 6,292 m |
| `/isochrone`, Monas 5 minutes | 21.06 km², 2 features, grid 250 m, 23,095 nodes, 11 ms |
| `/nearest`, Monas | 311 m, three candidates, 4 ms |
| `avoid=toll`, Monas to Depok | 30,839 m / 1,740.6 s free, 31,103 m / 2,260.8 s avoiding toll |
| `via`, one waypoint | 31,951 m / 1,956.8 s, 2 legs, 936 points |
| `alt=3` | 0 alternatives on six Jakarta pairs, no error |
| Ferry, Bakauheni to Merak | 29,784 m / 5,340.3 s, 27,596 m ferry, `has_ferry` true |
| `/place/suggest` | `q=monas` with bias returns five records, `q=mo` returns 400 |
| `/place/admin/reverse` | Monas resolves to Gambir with `ambiguous: false` on a rebuilt 386 MB index; the 142 MB index answers 501 `no_admin_polygons` |

The `/place/admin/reverse` row names both states: the handler exists on its
branch, the shipped 142 MB `places.idx` was written without admin polygons and
answers 501, and an index rebuilt from the same 19 November PBF with the
branch builder (386 MB) answers with the administrative chain.

## License

Code and page copy: MIT, see `LICENSE`. The logo and the images derived from it
in `site/assets/` are brand assets, not covered by that license.
