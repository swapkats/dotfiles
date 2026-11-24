#!/usr/bin/env python3
"""Extract text from PDF pages. Supports page ranges."""

import sys
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


def extract(path: str, page_spec: str = "all") -> None:
    doc = pymupdf.open(path)
    pages = parse_pages(page_spec, len(doc))

    for i in pages:
        page = doc[i]
        text = page.get_text()
        print(f"--- Page {i + 1} ---")
        print(text)

    doc.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract text from PDF")
    parser.add_argument("path", help="Path to PDF file")
    parser.add_argument("--pages", default="all", help="Page range: 'all', '1-5', '1,3,7', '3'")
    args = parser.parse_args()

    extract(args.path, args.pages)
