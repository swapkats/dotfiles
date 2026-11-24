#!/usr/bin/env python3
"""Render PDF pages to PNG images for visual inspection."""

import sys
import os
import hashlib
import argparse
import pymupdf


def parse_pages(spec: str, total: int) -> list[int]:
    """Parse page spec like 'all', '1-5', '1,3,7', '3' into 0-indexed list."""
    if spec.strip().lower() == "all":
        return list(range(total))

    pages = set()
    for part in spec.split(","):
        part = part.strip()
        if "-" in part:
            start, end = part.split("-", 1)
            start = max(1, int(start))
            end = min(total, int(end))
            pages.update(range(start - 1, end))
        else:
            p = int(part) - 1
            if 0 <= p < total:
                pages.add(p)
    return sorted(pages)


def render(path: str, page_spec: str = "all", dpi: int = 150) -> list[str]:
    doc = pymupdf.open(path)
    pages = parse_pages(page_spec, len(doc))

    # Create output directory based on file hash for caching
    file_hash = hashlib.md5(os.path.abspath(path).encode()).hexdigest()[:10]
    out_dir = os.path.join("/tmp", f"pi-pdf-{file_hash}")
    os.makedirs(out_dir, exist_ok=True)

    zoom = dpi / 72.0
    mat = pymupdf.Matrix(zoom, zoom)

    output_paths = []
    for i in pages:
        page = doc[i]
        pix = page.get_pixmap(matrix=mat)
        out_path = os.path.join(out_dir, f"page_{i + 1:04d}.png")
        pix.save(out_path)
        output_paths.append(out_path)
        print(f"Page {i + 1} -> {out_path}")

    doc.close()
    return output_paths


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Render PDF pages to PNG")
    parser.add_argument("path", help="Path to PDF file")
    parser.add_argument("--pages", default="all", help="Page range: 'all', '1-5', '1,3,7', '3'")
    parser.add_argument("--dpi", type=int, default=150, help="Render resolution (default: 150)")
    args = parser.parse_args()

    render(args.path, args.pages, args.dpi)
