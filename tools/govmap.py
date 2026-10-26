#!/usr/bin/env python3
"""Generate the NXGDAI-GovMap elements-table visual from the catalogue.

    python3 tools/govmap.py --validate     # check catalog/govmap.yaml covers the catalogue (no browser; CI runs this)
    python3 tools/govmap.py --html PATH    # write the visual as a standalone HTML page
    python3 tools/govmap.py                # render docs/NXGDAI-GovMap.png (needs Playwright + Chromium)

Every number on the visual is computed here from catalog/frameworks.yaml,
catalog/controls.yaml and vendors/*/mapping.yaml; catalog/govmap.yaml holds
only symbols, short labels, scopes and the family layout.
"""
from __future__ import annotations

import argparse
import datetime as dt
import html
import sys
import tempfile
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
CAT = ROOT / "catalog"
OUT_PNG = ROOT / "docs" / "NXGDAI-GovMap.png"

W, H = 2400, 1030
X0, PITCH_X, PITCH_Y, TW, TH = 65, 120, 138, 110, 128
ROWS = [104 + i * PITCH_Y for i in range(5)]           # five tile rows
LAW_X = [X0 + c * PITCH_X for c in range(4)]
CTRL_X = [545 + c * PITCH_X for c in range(11)]
STD_X = [1865 + c * PITCH_X for c in range(4)]
BG, INK, MUTED, SUB, RULE = "#0d1520", "#0d1520", "#8494a7", "#c3cdd9", "#22314a"
AMBER, CTRL_BG, CTRL_EDGE, WHITE, VENDOR_BG = "#f4b740", "#162131", "#283950", "#f6f8fb", "#e6ecf3"
FONT = "'Liberation Sans', Arial, Helvetica, sans-serif"


def load(name: str):
    return yaml.safe_load((CAT / name).read_text(encoding="utf-8"))


frameworks_doc = load("frameworks.yaml")
frameworks = {f["id"]: f for f in frameworks_doc["frameworks"]}
controls = {c["id"]: c for c in load("controls.yaml")["controls"]}
layout = load("govmap.yaml")
vendors = {p.parent.name: yaml.safe_load(p.read_text(encoding="utf-8")) for p in sorted((ROOT / "vendors").glob("*/mapping.yaml"))}
COUNTRIES = len(list((CAT / "jurisdictions").glob("*.yaml"))) - 1  # EU is a shared layer, not a country
SECTORS = len(load("sectors.yaml")["sectors"])


def validate() -> list[str]:
    errs = []
    tiles = layout["frameworks"]
    if set(tiles) != set(frameworks):
        missing, extra = set(frameworks) - set(tiles), set(tiles) - set(frameworks)
        if missing:
            errs.append(f"govmap.yaml: no tile for frameworks {sorted(missing)}")
        if extra:
            errs.append(f"govmap.yaml: tiles for unknown frameworks {sorted(extra)}")
    if set(layout["controls"]) != set(controls):
        errs.append("govmap.yaml: controls must list every AIG control exactly once")
    if set(layout["vendors"]) != set(vendors):
        errs.append(f"govmap.yaml: vendors must list every pack in vendors/ ({sorted(vendors)})")
    symbols = [t["symbol"] for t in tiles.values()] + [c["symbol"] for c in layout["controls"].values()] + [v["symbol"] for v in layout["vendors"].values()]
    dupes = sorted({s for s in symbols if symbols.count(s) > 1})
    if dupes:
        errs.append(f"govmap.yaml: duplicate symbols {dupes}")
    for fid, t in tiles.items():
        if t.get("family") not in layout["families"]:
            errs.append(f"govmap.yaml: {fid} has unknown family {t.get('family')}")
    used = set(layout["law_block"]["families"]) | set(layout["standards_block"]["families"])
    if used != set(layout["families"]):
        errs.append("govmap.yaml: every family must sit in exactly one block")
    for block in ("law_block", "standards_block"):
        try:
            place(block)
        except ValueError as e:
            errs.append(str(e))
    return errs


def place(block: str) -> list[tuple[str, int, int]]:
    """(framework id, column, row) for one block, column by column."""
    spec = layout[block]
    starts, ends = spec["start_rows"], spec["end_rows"]
    out, col = [], 0
    for fam in spec["families"]:
        members = [fid for fid, t in layout["frameworks"].items() if t["family"] == fam]
        if col >= len(starts):
            raise ValueError(f"govmap.yaml: {block} needs more than {len(starts)} columns")
        row = starts[col]
        for fid in members:
            if row > ends[col]:
                col += 1
                if col >= len(starts):
                    raise ValueError(f"govmap.yaml: {block} needs more than {len(starts)} columns")
                row = starts[col]
            out.append((fid, col, row))
            row += 1
        col += 1
    return out


def status_marker(f: dict) -> str:
    if f.get("baseline") or f["status"] == "voluntary":
        return "voluntary"
    if f["status"] == "in-force":
        return "in-force"
    if f["status"] in ("in-force-phased", "phased"):
        return "phasing"
    return "proposed"


def marker_svg(kind: str, colour: str, size: int = 12) -> str:
    r = size / 2 - 1.2
    c = size / 2
    if kind == "in-force":
        body = f'<circle cx="{c}" cy="{c}" r="{r + 0.6}" fill="{colour}"/>'
    elif kind == "phasing":
        body = (f'<circle cx="{c}" cy="{c}" r="{r}" fill="none" stroke="{colour}" stroke-width="1.8"/>'
                f'<path d="M{c} {c - r} A{r} {r} 0 0 1 {c} {c + r} Z" fill="{colour}"/>')
    elif kind == "voluntary":
        body = f'<circle cx="{c}" cy="{c}" r="{r}" fill="none" stroke="{colour}" stroke-width="1.8"/>'
    else:
        body = f'<circle cx="{c}" cy="{c}" r="{r}" fill="none" stroke="{colour}" stroke-width="1.6" stroke-dasharray="2 2"/>'
    return f'<svg width="{size}" height="{size}" viewBox="0 0 {size} {size}" aria-hidden="true">{body}</svg>'


def esc(s) -> str:
    return html.escape(str(s))


def label_html(s: str) -> str:
    """Escape a tile label; a newline in govmap.yaml becomes a line break."""
    return "<br>".join(esc(part) for part in str(s).split("\n"))


WORDS = {2: "two", 3: "three", 4: "four", 5: "five", 6: "six", 7: "seven", 8: "eight", 9: "nine", 10: "ten",
         11: "eleven", 12: "twelve"}


def fw_links(fid: str) -> int:
    return sum(fid in c["mappings"] for c in controls.values())


def tile(x, y, w, h, bg, ink, num, links, symbol, label, foot_left="", marker="", sym_size=44, label_size=10.5, border="", num_colour=None, label_top=None):
    num_colour = num_colour or ink
    label_top = label_top if label_top is not None else round(h * 0.6)
    return (
        f'<div class="t" style="left:{x}px;top:{y}px;width:{w}px;height:{h}px;background:{bg};color:{ink};{border}">'
        f'<span class="n" style="color:{num_colour}">{esc(num)}</span>'
        f'<span class="l" style="color:{num_colour}">{esc(links)}</span>'
        f'<span class="s" style="font-size:{sym_size}px;top:{round(h * 0.12)}px">{esc(symbol)}</span>'
        f'<span class="lab" style="font-size:{label_size}px;top:{label_top}px">{label}</span>'
        f'<span class="sc">{esc(foot_left)}</span>'
        f'<span class="mk">{marker}</span>'
        "</div>"
    )


def build_html() -> str:
    asof = dt.date.fromisoformat(str(frameworks_doc["asOf"]))
    fams = layout["families"]
    t = layout["text"]
    nums: dict[str, int] = {}
    parts: list[str] = []

    law = place("law_block")
    std = place("standards_block")
    for i, (fid, _, _) in enumerate(law + std, 1):
        nums[fid] = i

    def fw_tile(fid, x, y):
        f, meta = frameworks[fid], layout["frameworks"][fid]
        return tile(x, y, TW, TH, fams[meta["family"]]["colour"], INK, nums[fid], fw_links(fid), meta["symbol"],
                    label_html(meta["label"]), meta["scope"], marker_svg(status_marker(f), INK))

    for fid, col, row in law:
        parts.append(fw_tile(fid, LAW_X[col], ROWS[row]))
    for fid, col, row in std:
        parts.append(fw_tile(fid, STD_X[col], ROWS[row]))

    # Controls: two rows of eleven under the title.
    for i, (cid, meta) in enumerate(layout["controls"].items()):
        x, y = CTRL_X[i % 11], ROWS[2 + i // 11]
        parts.append(tile(x, y, TW, TH, CTRL_BG, WHITE, cid[-2:], len(controls[cid]["mappings"]), meta["symbol"],
                          label_html(meta["label"]), border=f"box-shadow:inset 0 0 0 1.5px {CTRL_EDGE};", num_colour=AMBER, label_top=76))

    # Vendor packs: fifth row, under the controls.
    for i, (vid, meta) in enumerate(layout["vendors"].items()):
        n = len(vendors[vid].get("implements", []))
        label = "<br>".join(esc(line) for line in meta["lines"])
        parts.append(tile(CTRL_X[i], ROWS[4], TW, TH, VENDOR_BG, INK, "", n, meta["symbol"], label, label_top=76))
    vx = CTRL_X[8]
    parts.append(
        f'<div class="blk" style="left:{vx}px;top:{ROWS[4] + 2}px;width:{CTRL_X[10] + TW - vx}px">'
        f'<div class="h">{esc(t["vendors_heading"])}</div>'
        f'<div class="p">{esc(t["vendors_body"].format(vendors_word=WORDS.get(len(vendors), len(vendors))))}</div></div>'
    )

    # Section labels and title.
    parts.append(f'<div class="sec" style="left:{LAW_X[0]}px;top:70px">LAW &amp; REGULATION</div>')
    parts.append(f'<div class="sec" style="left:{STD_X[0]}px;top:70px">STANDARDS &amp; FRAMEWORKS</div>')
    parts.append(f'<div class="eyebrow" style="left:{CTRL_X[0]}px;top:105px">{esc(t["eyebrow"].format(asof=asof.strftime("%-d %b %Y").upper()))}</div>')
    parts.append(f'<div class="title" style="left:{CTRL_X[0] - 3}px;top:128px"><span style="color:{AMBER}">{esc(t["title_accent"])}</span>{esc(t["title_rest"])}</div>')
    parts.append(f'<div class="subtitle" style="left:{CTRL_X[0]}px;top:254px;width:930px">'
                 f'{esc(t["subtitle"].format(frameworks=len(frameworks), controls=len(controls), vendors=len(vendors)))}</div>')
    parts.append(f'<div class="strip" style="left:{CTRL_X[0]}px;top:346px">'
                 f'{esc(t["controls_strip"].format(controls=len(controls), last=max(controls)[-2:]))}</div>')

    # Key tile: the EU AI Act drawn large with labelled parts.
    kx, ky, kw, kh = CTRL_X[9] + 30, ROWS[0], 161, 178
    eu = "eu-ai-act"
    parts.append(tile(kx, ky, kw, kh, fams[layout["frameworks"][eu]["family"]]["colour"], INK, nums[eu], fw_links(eu),
                      layout["frameworks"][eu]["symbol"], label_html(layout["frameworks"][eu]["label"]),
                      layout["frameworks"][eu]["scope"], marker_svg(status_marker(frameworks[eu]), INK, 15),
                      sym_size=66, label_size=17, label_top=108).replace('class="t"', 'class="t key"'))
    for label, yy in (("element no.", 12), ("symbol", 58), ("short name", 116), ("scope · status", 158)):
        reach = 92 if label == "symbol" else 44   # the symbol's leader runs into the tile to point at the letters
        parts.append(f'<div class="kl" style="left:{kx - 212}px;top:{ky + yy - 9}px">{label}</div>'
                     f'<div class="kr" style="left:{kx - 54}px;top:{ky + yy}px;width:{reach}px"></div>')
    parts.append(f'<div class="kr" style="left:{kx + kw - 4}px;top:{ky + 12}px;width:26px"></div>'
                 f'<div class="kl" style="left:{kx + kw + 28}px;top:{ky + 3}px;width:60px;text-align:left">links</div>')

    # Coverage.
    codes = " · ".join(p.stem.upper() for p in sorted((CAT / "jurisdictions").glob("*.yaml"), key=lambda p: ["br", "cl", "ar", "pt", "es", "us", "au", "nz", "jp", "sg", "eu"].index(p.stem)) if p.stem != "eu")
    parts.append(
        f'<div class="blk" style="left:{X0}px;top:812px;width:820px">'
        f'<div class="h">{esc(t["coverage_heading"])}</div>'
        f'<div class="p">{esc(t["coverage_line"].format(countries=COUNTRIES, sectors=SECTORS, profiles=COUNTRIES * SECTORS))}</div>'
        f'<div class="codes">{esc(codes)}</div>'
        f'<div class="p">{" · ".join(esc(s) for s in t["sectors"])}</div></div>'
    )

    # Legend.
    items = [(f["name"], f["colour"], "") for f in fams.values()] + [("Unified controls", CTRL_BG, f"box-shadow:inset 0 0 0 1.5px {CTRL_EDGE};"), ("Vendor packs", VENDOR_BG, "")]
    lx = 1010
    for i, (name, colour, extra) in enumerate(items):
        x = lx + (i % 4) * 335
        y = 812 + (i // 4) * 36
        parts.append(f'<div class="lg" style="left:{x}px;top:{y}px"><i style="background:{colour};{extra}"></i>{esc(name)}</div>')
    kinds = sorted({status_marker(f) for f in frameworks.values()}, key=["in-force", "phasing", "voluntary", "proposed"].index)
    words = {"in-force": "in force", "phasing": "phasing in", "voluntary": "voluntary", "proposed": "proposed"}
    marks = "".join(f'<span class="mkl">{marker_svg(k, "#e8edf3", 13)} {words[k]}</span>' for k in kinds)
    parts.append(f'<div class="lgt" style="left:{lx}px;top:890px">{marks}</div>')
    parts.append(f'<div class="note" style="left:{lx}px;top:920px;width:{W - X0 - lx}px">{esc(t["scopes"])}</div>')
    parts.append(f'<div class="note" style="left:{lx}px;top:944px;width:{W - X0 - lx}px">{esc(t["links"])}</div>')

    parts.append(f'<div class="rule" style="left:{X0}px;top:982px;width:{W - 2 * X0}px"></div>')
    parts.append(f'<div class="foot" style="left:{X0}px;top:996px">{esc(t["footer_left"])}</div>')
    parts.append(f'<div class="foot" style="right:{X0}px;top:996px;text-align:right">{esc(t["footer_right"])}</div>')

    css = f"""
*{{box-sizing:border-box;margin:0;padding:0}}
html,body{{width:{W}px;height:{H}px;background:{BG};font-family:{FONT};-webkit-font-smoothing:antialiased}}
#map{{position:relative;width:{W}px;height:{H}px;background:{BG};overflow:hidden}}
#map>div{{position:absolute}}
.t{{border-radius:6px;font-weight:700}}
.t .n{{position:absolute;left:8px;top:7px;font-size:12px}}
.t .l{{position:absolute;right:8px;top:7px;font-size:12px}}
.t .s{{position:absolute;left:0;right:0;text-align:center;line-height:1;letter-spacing:-0.5px}}
.t .lab{{position:absolute;left:5px;right:5px;text-align:center;line-height:1.18}}
.t .sc{{position:absolute;left:8px;bottom:6px;font-size:10.5px}}
.t .mk{{position:absolute;right:7px;bottom:6px;line-height:0}}
.key{{border-radius:9px}}
.key .n,.key .l{{font-size:17px;top:9px}}
.key .n{{left:12px}} .key .l{{right:12px}}
.key .sc{{font-size:15px;left:12px;bottom:9px}}
.key .mk{{right:10px;bottom:9px}}
.kl{{width:150px;text-align:right;color:{MUTED};font-size:14px}}
.kr{{height:1px;background:#5b6b80}}
.sec{{color:{MUTED};font-size:13px;font-weight:700;letter-spacing:0.4px}}
.eyebrow{{color:{AMBER};font-size:16px;font-weight:700;letter-spacing:0.2px;word-spacing:2px}}
.title{{color:{WHITE};font-size:99px;font-weight:700;letter-spacing:-1px;line-height:1.05}}
.subtitle{{color:{SUB};font-size:23px;line-height:1.38}}
.strip{{color:{AMBER};font-size:13.5px;font-weight:700}}
.blk .h{{color:{WHITE};font-size:16px;font-weight:700;margin-bottom:10px}}
.blk .p{{color:{MUTED};font-size:16px;line-height:1.55}}
.blk .codes{{color:{WHITE};font-size:16px;font-weight:700;margin:6px 0 8px;word-spacing:3px}}
.lg{{color:#e8edf3;font-size:16px;font-weight:700;display:flex;align-items:center;gap:9px;white-space:nowrap}}
.lg i{{display:inline-block;width:18px;height:18px;border-radius:3px}}
.lgt{{color:#e8edf3;font-size:15px;display:flex;gap:26px}}
.mkl{{display:inline-flex;align-items:center;gap:7px}}
.note{{color:{MUTED};font-size:14px;line-height:1.3}}
.rule{{height:1px;background:{RULE}}}
.foot{{color:{MUTED};font-size:13px}}
"""
    return (f'<!doctype html><html lang="en"><head><meta charset="utf-8"><title>NXGDAI-GovMap</title>'
            f"<style>{css}</style></head><body><div id=\"map\">{''.join(parts)}</div></body></html>")


def render(html_text: str, out: Path) -> None:
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        sys.exit("Playwright is not installed: pip install playwright && playwright install chromium (or use --html).")
    with tempfile.TemporaryDirectory() as tmp:
        page_path = Path(tmp) / "govmap.html"
        page_path.write_text(html_text, encoding="utf-8")
        with sync_playwright() as p:
            browser = p.chromium.launch()
            page = browser.new_page(viewport={"width": W, "height": H}, device_scale_factor=1)
            page.goto(page_path.as_uri())
            page.wait_for_timeout(300)
            page.locator("#map").screenshot(path=str(out))
            browser.close()


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--validate", action="store_true", help="only check the layout file against the catalogue")
    ap.add_argument("--html", type=Path, help="write the HTML page to this path instead of rendering a PNG")
    ap.add_argument("--out", type=Path, default=OUT_PNG, help=f"PNG path (default {OUT_PNG.relative_to(ROOT)})")
    args = ap.parse_args()

    errs = validate()
    if errs:
        print("GovMap layout validation FAILED:", file=sys.stderr)
        for e in errs:
            print(f"  - {e}", file=sys.stderr)
        sys.exit(1)
    if args.validate:
        print(f"GovMap layout OK: {len(frameworks)} frameworks, {len(controls)} controls, {len(vendors)} vendor packs.")
        return
    page = build_html()
    if args.html:
        args.html.write_text(page, encoding="utf-8")
        print(f"Wrote {args.html}")
        return
    render(page, args.out)
    print(f"Rendered {args.out.relative_to(ROOT) if args.out.is_relative_to(ROOT) else args.out} "
          f"({len(frameworks)} frameworks, {len(controls)} controls, {len(vendors)} vendor packs, as of {frameworks_doc['asOf']}).")


if __name__ == "__main__":
    main()
