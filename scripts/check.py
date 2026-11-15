#!/usr/bin/env python3
"""Checks that do not need a browser: anchors, asset paths, copy hygiene."""

from __future__ import annotations

import html.parser
import re
import sys
from pathlib import Path

SITE = Path(__file__).resolve().parent.parent / "site"
PAGES = ["index.html", "404.html"]
BANNED = {"\u2014": "em dash", "\u2013": "en dash"}
SKIP_BINARY = {".png", ".jpg", ".jpeg", ".ico"}

errors: list[str] = []


class Collector(html.parser.HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.ids: set[str] = set()
        self.refs: list[str] = []
        self.lang: str | None = None
        self.h1 = 0
        self.titles: list[str] = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if "id" in attrs:
            self.ids.add(attrs["id"])
        for key in ("href", "src"):
            value = attrs.get(key)
            if value:
                self.refs.append(value)
        if tag == "html":
            self.lang = attrs.get("lang")
        if tag == "h1":
            self.h1 += 1

    def handle_data(self, data):
        if self.lasttag == "title":
            self.titles.append(data.strip())


def check_page(name: str) -> None:
    path = SITE / name
    if not path.is_file():
        errors.append(f"{name}: missing")
        return
    collector = Collector()
    collector.feed(path.read_text(encoding="utf-8"))
    if collector.lang != "en":
        errors.append(f"{name}: html lang is {collector.lang!r}, expected 'en'")
    if not any(collector.titles):
        errors.append(f"{name}: empty <title>")
    if name == "index.html" and collector.h1 != 1:
        errors.append(f"{name}: expected exactly one <h1>, found {collector.h1}")
    for ref in collector.refs:
        if ref.startswith("#"):
            target = ref[1:]
            if target and target not in collector.ids:
                errors.append(f"{name}: anchor {ref} has no target")
            continue
        if ref.startswith(("http://", "https://", "mailto:")):
            continue
        target = SITE / ref.split("?", 1)[0].lstrip("/")
        if not target.exists():
            errors.append(f"{name}: local reference {ref} does not exist")


def check_copy() -> None:
    for path in SITE.rglob("*"):
        if not path.is_file() or path.suffix.lower() in SKIP_BINARY:
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        for char, label in BANNED.items():
            if char in text:
                errors.append(f"{path.relative_to(SITE)}: contains an {label}")
        if re.search(r"\bTODO\b", text):
            errors.append(f"{path.relative_to(SITE)}: contains TODO")


def main() -> int:
    for page in PAGES:
        check_page(page)
    check_copy()
    if errors:
        print("\n".join(errors))
        return 1
    print(f"checked {len(PAGES)} pages, no broken anchors or missing assets")
    return 0


if __name__ == "__main__":
    sys.exit(main())
