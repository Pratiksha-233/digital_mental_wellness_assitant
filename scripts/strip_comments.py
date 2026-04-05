"""Repo utility: strip non-essential comments from source files.

Designed for one-time cleanup tasks. This is intentionally conservative:
- Preserves shebang/encoding lines.
- Preserves likely license/copyright headers.
- Preserves behavior/tooling-critical directives (e.g. noqa/type: ignore).

Supported languages:
- Python (.py) via tokenize
- C-like (.js/.ts/.dart/.css) via a basic lexer (strings-aware)
- HTML (.html/.htm) removes <!-- --> outside <script>/<style> content handling is best-effort.

NOTE: This is not a perfect parser for every edge-case (e.g. JS regex literals).
"""

from __future__ import annotations

import argparse
import os
import re
import sys
import io
import tokenize
from dataclasses import dataclass
from io import BytesIO
from pathlib import Path


EXCLUDE_DIR_NAMES = {
    "__pycache__",
    ".git",
    ".idea",
    ".vscode",
    ".dart_tool",
    "node_modules",
    "build",
    "dist",
    ".pytest_cache",
    ".mypy_cache",
}

DEFAULT_EXTS = {".py", ".dart", ".js", ".ts", ".html", ".htm", ".css"}


KEEP_LINE_PATTERNS = [

    re.compile(r"^\s*#\s*noqa\b", re.IGNORECASE),
    re.compile(r"^\s*#\s*type:\s*ignore\b", re.IGNORECASE),
    re.compile(r"^\s*#\s*pyright:\s*ignore\b", re.IGNORECASE),
    re.compile(r"^\s*#\s*pylint:\s*disable\b", re.IGNORECASE),
    re.compile(r"^\s*#\s*pragma:\s*no\s*cover\b", re.IGNORECASE),
    re.compile(r"^\s*#\s*fmt:\s*(off|on)\b", re.IGNORECASE),

    re.compile(r"^\s*//\s*ignore_for_file:\b"),
    re.compile(r"^\s*//\s*ignore:\b"),

    re.compile(r"^\s*//\s*eslint-disable\b"),
    re.compile(r"^\s*/\*\s*eslint-disable\b"),
    re.compile(r"^\s*//\s*@ts-ignore\b", re.IGNORECASE),
    re.compile(r"^\s*//\s*@ts-nocheck\b", re.IGNORECASE),
]

LICENSE_KEYWORDS = [
    "copyright",
    "licensed",
    "license",
    "spdx-",
    "mit license",
    "apache license",
    "gnu general public license",
]


@dataclass(frozen=True)
class Stats:
    files_changed: int = 0
    files_scanned: int = 0
    bytes_before: int = 0
    bytes_after: int = 0


def _has_license_header(text: str) -> bool:
    head = "\n".join(text.splitlines()[:40]).lower()
    return any(k in head for k in LICENSE_KEYWORDS)


def _preserve_header_region(lines: list[str]) -> int:
    """Return the number of leading lines to preserve untouched.

    Preserves:
    - shebang + encoding (first 2 lines)
    - contiguous initial comment/blank block if it contains license keywords
    """

    if not lines:
        return 0

    preserve = 0


    if lines[0].startswith("#!"):
        preserve = 1
    if len(lines) > 1 and re.match(r"^#.*coding[:=]", lines[1]):
        preserve = max(preserve, 2)



    block_end = 0
    for i, line in enumerate(lines[:80]):
        stripped = line.strip()
        if stripped == "" or stripped.startswith("#") or stripped.startswith("//") or stripped.startswith("/*") or stripped.startswith("*"):
            block_end = i + 1
            continue
        break

    if block_end:
        head_block = "\n".join(lines[:block_end]).lower()
        if any(k in head_block for k in LICENSE_KEYWORDS):
            preserve = max(preserve, block_end)

    return preserve


def _line_should_be_kept(line: str) -> bool:
    return any(p.search(line) for p in KEEP_LINE_PATTERNS)


def strip_python_comments(text: str) -> str:
    lines = text.splitlines(keepends=True)
    preserve_n = _preserve_header_region([l.rstrip("\n") for l in lines])

    preserved = "".join(lines[:preserve_n])
    body = "".join(lines[preserve_n:])

    if not body.strip():
        return text

    body_lines_noends = body.splitlines(keepends=False)

    try:
        token_iter = tokenize.generate_tokens(io.StringIO(body).readline)
        filtered: list[tokenize.TokenInfo] = []
        for tok in token_iter:
            if tok.type == tokenize.COMMENT:
                line_idx = tok.start[0] - 1
                full_line = body_lines_noends[line_idx] if 0 <= line_idx < len(body_lines_noends) else tok.line
                if _line_should_be_kept(full_line):
                    filtered.append(tok)

                continue
            filtered.append(tok)

        new_body = tokenize.untokenize(filtered)
    except (tokenize.TokenError, IndentationError, SyntaxError):

        return text

    new_body = re.sub(r"[ \t]+\n", "\n", new_body)
    return preserved + new_body


def strip_c_like_comments(text: str) -> str:
    lines = text.splitlines(keepends=True)
    preserve_n = _preserve_header_region([l.rstrip("\n") for l in lines])

    preserved = "".join(lines[:preserve_n])
    body = "".join(lines[preserve_n:])

    if not body:
        return text


    kept_line_numbers: set[int] = set()
    for i, line in enumerate(body.splitlines(keepends=False), start=1):
        if _line_should_be_kept(line):
            kept_line_numbers.add(i)

    out: list[str] = []
    i = 0
    line_no = 1
    in_block_comment = False
    in_string: str | None = None
    escape = False

    while i < len(body):
        ch = body[i]

        if ch == "\n":
            out.append(ch)
            i += 1
            line_no += 1
            escape = False
            continue

        if line_no in kept_line_numbers:

            line_end = body.find("\n", i)
            if line_end == -1:
                out.append(body[i:])
                break
            out.append(body[i : line_end + 1])
            i = line_end + 1
            line_no += 1
            escape = False
            in_block_comment = False
            in_string = None
            continue

        if in_block_comment:
            if ch == "*" and i + 1 < len(body) and body[i + 1] == "/":
                in_block_comment = False
                i += 2
            else:
                i += 1
            continue

        if in_string:
            out.append(ch)
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == in_string:
                in_string = None
            i += 1
            continue


        if ch in ("'", '"', "`"):
            in_string = ch
            out.append(ch)
            i += 1
            continue


        if ch == "/" and i + 1 < len(body) and body[i + 1] == "/":



            if out and out[-1] not in ("\n", " ", "\t"):
                out.append(" ")

            j = body.find("\n", i)
            if j == -1:
                break
            i = j
            continue


        if ch == "/" and i + 1 < len(body) and body[i + 1] == "*":
            in_block_comment = True
            i += 2
            continue

        out.append(ch)
        i += 1

    new_body = "".join(out)
    new_body = re.sub(r"[ \t]+\n", "\n", new_body)
    return preserved + new_body


_HTML_COMMENT_RE = re.compile(r"<!--([\s\S]*?)-->")


def strip_html_comments(text: str) -> str:
    lines = text.splitlines(keepends=True)
    preserve_n = _preserve_header_region([l.rstrip("\n") for l in lines])
    preserved = "".join(lines[:preserve_n])
    body = "".join(lines[preserve_n:])


    new_body = _HTML_COMMENT_RE.sub("", body)
    new_body = re.sub(r"[ \t]+\n", "\n", new_body)
    return preserved + new_body


def strip_comments_for_file(path: Path) -> tuple[bool, str | None]:
    try:
        original = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:

        return False, "non-utf8"

    ext = path.suffix.lower()
    if ext == ".py":
        updated = strip_python_comments(original)
    elif ext in {".js", ".ts", ".dart", ".css"}:
        updated = strip_c_like_comments(original)
    elif ext in {".html", ".htm"}:
        updated = strip_html_comments(original)
    else:
        return False, "unsupported"

    if updated != original:
        path.write_text(updated, encoding="utf-8", newline="")
        return True, None

    return False, None


def should_exclude(path: Path) -> bool:
    parts = {p for p in path.parts if p}
    if EXCLUDE_DIR_NAMES & parts:
        return True


    path_str = str(path).replace("\\", "/").lower()
    if "/frontend/build/" in path_str or "/digital_mental_wellness_assitant/frontend/build/" in path_str:
        return True

    return False


def iter_target_files(root: Path, exts: set[str]) -> list[Path]:
    files: list[Path] = []
    for p in root.rglob("*"):
        if p.is_dir():
            continue
        if should_exclude(p):
            continue
        if p.suffix.lower() in exts:
            files.append(p)
    return files


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default=".")
    parser.add_argument("--ext", action="append", default=[])
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args(argv)

    root = Path(args.root).resolve()
    exts = DEFAULT_EXTS if not args.ext else {e if e.startswith(".") else f".{e}" for e in args.ext}

    files = iter_target_files(root, exts)

    changed = 0
    scanned = 0
    bytes_before = 0
    bytes_after = 0
    skipped: dict[str, int] = {}

    for f in files:
        scanned += 1
        try:
            before = f.read_bytes()
        except OSError:
            skipped["read_error"] = skipped.get("read_error", 0) + 1
            continue
        bytes_before += len(before)

        if args.dry_run:
            continue

        did_change, reason = strip_comments_for_file(f)
        if reason:
            skipped[reason] = skipped.get(reason, 0) + 1
        if did_change:
            changed += 1
            try:
                bytes_after += len(f.read_bytes())
            except OSError:
                pass
        else:
            bytes_after += len(before)

    print(f"Scanned: {scanned} files")
    if args.dry_run:
        print("Dry-run: no files modified")
    else:
        print(f"Changed: {changed} files")
        print(f"Bytes: {bytes_before} -> {bytes_after}")
    if skipped:
        print("Skipped:")
        for k, v in sorted(skipped.items()):
            print(f"  {k}: {v}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
