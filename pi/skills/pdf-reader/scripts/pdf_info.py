#!/usr/bin/env python3
"""PDF metadata and per-page analysis. Always run this first to triage a PDF."""

import sys
import json
import pymupdf


def analyze(path: str) -> dict:
    doc = pymupdf.open(path)
    meta = doc.metadata or {}

    pages = []
    for i, page in enumerate(doc):
        text = page.get_text()
        text_len = len(text)
        images = page.get_images(full=True)

        # Estimate math density: ratio of unicode math-range chars to total chars
        math_chars = sum(
            1 for c in text
            if ('\u2200' <= c <= '\u22FF')    # Mathematical Operators
            or ('\u2100' <= c <= '\u214F')     # Letterlike Symbols
            or ('\u2190' <= c <= '\u21FF')     # Arrows
            or ('\u27C0' <= c <= '\u27EF')     # Misc Mathematical Symbols-A
            or ('\u2980' <= c <= '\u29FF')     # Misc Mathematical Symbols-B
            or ('\u2A00' <= c <= '\u2AFF')     # Supplemental Mathematical Operators
            or ('\u0370' <= c <= '\u03FF')     # Greek
            or ('\u1D400' <= c <= '\u1D7FF')   # Mathematical Alphanumeric Symbols
            or c in '∫∑∏√∂∇∞≈≠≤≥±×÷∈∉⊂⊃∪∩∧∨¬∀∃∅'
        )
        math_density = math_chars / max(text_len, 1)

        pages.append({
            "page": i + 1,
            "text_length": text_len,
            "image_count": len(images),
            "math_density": round(math_density, 4),
        })

    # Try to extract TOC
    toc = doc.get_toc()
    toc_entries = [
        {"level": level, "title": title, "page": page_num}
        for level, title, page_num in toc
    ]

    result = {
        "file": path,
        "page_count": len(doc),
        "title": meta.get("title", ""),
        "author": meta.get("author", ""),
        "subject": meta.get("subject", ""),
        "toc": toc_entries,
        "pages": pages,
    }

    doc.close()
    return result


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: pdf_info.py <path>", file=sys.stderr)
        sys.exit(1)

    result = analyze(sys.argv[1])
    print(json.dumps(result, indent=2))
