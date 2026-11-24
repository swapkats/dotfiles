---
name: pdf-reader
description: Read and comprehend PDF files, especially math lecture notes and academic papers. Use when the user asks to read, parse, analyze, or extract content from a PDF file.
---

# PDF Reader

Read and comprehend PDF files, especially math lecture notes and academic papers. Uses a hybrid text extraction + vision approach for maximum comprehension of equations, diagrams, and structured content.

## Setup

All scripts use a venv at `SKILL_DIR/.venv` with `pymupdf` installed. If the venv is missing, create it from `requirements.txt`:

```bash
python3 -m venv SKILL_DIR/.venv
SKILL_DIR/.venv/bin/pip install -r SKILL_DIR/requirements.txt
```

**Python command:** Always invoke scripts with:
```
SKILL_DIR/.venv/bin/python SKILL_DIR/scripts/<script>.py [args]
```

## Scripts

All scripts are in `SKILL_DIR/scripts/`.

| Script | Purpose | Key args |
|---|---|---|
| `pdf_info.py <path>` | Metadata + per-page analysis (page count, TOC, text density, math density, image count) | — |
| `pdf_extract.py <path> [--pages SPEC]` | Extract text by page | `--pages all\|1-5\|1,3,7\|3` |
| `pdf_render.py <path> [--pages SPEC] [--dpi N]` | Render pages to PNG images in `/tmp/pi-pdf-*/` | `--pages`, `--dpi` (default 150) |
| `pdf_search.py <path> <query> [--context N] [--literal]` | Search text content by regex or literal | `--context` lines (default 3), `--literal` flag |

Page specs: `all`, `1-5`, `1,3,7`, `3` (1-indexed, inclusive ranges).

## Strategy: How to Read a PDF

### Step 1: Always Triage First

Run `pdf_info.py` on every new PDF before doing anything else. This tells you:
- How many pages (determines strategy)
- Whether there's a TOC (enables structural navigation)
- Per-page math density and image count (identifies which pages need vision)
- Per-page text length (spots pages that are mostly diagrams/figures)

### Step 2: Pick a Strategy Based on Size and Content

#### Short PDFs (≤15 pages)
- Extract all text: `pdf_extract.py <path>`
- Render all pages: `pdf_render.py <path>`
- Read all rendered images with the `read` tool for full visual comprehension
- This gives complete understanding at reasonable token cost

#### Medium PDFs (15–60 pages)
- Extract all text first (cheap, gives structural overview)
- Check `pdf_info.py` output for pages with high `math_density` (>0.02) or `image_count` > 0 or low `text_length` (<100, likely diagram-only pages)
- Render only those math/diagram-heavy pages as images
- Read those images with `read` for equation and figure comprehension
- For the rest, text extraction is sufficient

#### Long PDFs (60+ pages)
- Extract text for a structural overview — focus on TOC and section headers
- Do NOT render all pages (too many tokens)
- For targeted questions: use `pdf_search.py` to find relevant pages, then render those
- For full comprehension: work section by section, summarizing as you go
- Warn the user about scope — offer to focus on specific sections

### Step 3: Targeted Lookups

When the user asks about something specific (e.g., "check theorem 3.2", "what's on page 7"):
1. `pdf_search.py <path> "theorem 3.2"` — find the page
2. `pdf_render.py <path> --pages <page>` — render just that page
3. `read` the image — see the actual theorem with proper math rendering
4. If context is needed, extract text from surrounding pages

### Step 4: Visual Reading Guidelines

When reading rendered page images:
- **150 DPI** (default) is good for most math and text
- **200 DPI** if equations are small, dense, or hard to read at 150
- **100 DPI** only for quick structural scanning (saves tokens)
- State equations explicitly in your response using LaTeX notation when discussing them
- Describe diagrams and figures in detail — the user may not be looking at the PDF simultaneously
- Note page numbers when referencing content so the user can find it

### Step 5: What to Watch For

- **Pages with low text_length but high image_count**: likely full-page diagrams or figures — always render these
- **Pages with high math_density**: equations that text extraction will mangle — always render these
- **Pages with decent text but zero math**: text extraction alone is fine, skip rendering
- **TOC entries**: use these to navigate structurally rather than reading linearly

## Common Patterns

### "Read this PDF" (full document)
```
1. pdf_info.py → assess size and content
2. Pick strategy (short/medium/long)
3. Extract text + selectively render
4. Provide summary with key findings
```

### "What does theorem X say?"
```
1. pdf_search.py → find the page
2. pdf_render.py → render that page (and maybe the next for proof continuation)
3. Read the image, state the theorem precisely
```

### "Explain the proof on page N"
```
1. pdf_render.py --pages N → render the page
2. Read the image for full visual comprehension
3. Also extract text from pages N-1 and N+1 for surrounding context
4. Walk through the proof step by step
```

### "Summarize this paper"
```
1. pdf_info.py → get TOC and page count
2. pdf_extract.py → full text extraction
3. Read abstract, intro, conclusion first (text is usually sufficient)
4. Render figures/theorem pages as needed for deeper understanding
5. Provide structured summary
```
