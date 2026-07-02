#!/usr/bin/env python3
"""Build the Erlang Workshop 2026 code supplement archive."""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PACKAGE_NAME = ""
DEFAULT_OUTPUT = ROOT / "dist" / "ew2026-code-supplement.zip"

FILES = {
    "README_EW2026.md": "README.md",
    "README.md": "REPOSITORY_README.md",
    "docs/ew2026-validation.md": "docs/ew2026-validation.md",
    "src/semequiv.erl": "src/semequiv.erl",
    "src/EW2026Examples.erl": "src/EW2026Examples.erl",
    "scripts/build_ew2026_supplement.py": "scripts/build_ew2026_supplement.py",
}


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def archive_path(package_name: str, relative_path: str) -> str:
    if package_name:
        return f"{package_name}/{relative_path}".replace("\\", "/")
    return relative_path.replace("\\", "/")


def build_archive(output: Path, package_name: str) -> None:
    missing = [path for path in FILES if not (ROOT / path).is_file()]
    if missing:
        missing_list = "\n".join(f"  - {path}" for path in missing)
        raise SystemExit(f"Missing required supplement files:\n{missing_list}")

    output.parent.mkdir(parents=True, exist_ok=True)
    manifest_rows: list[tuple[str, int, str]] = []

    with ZipFile(output, "w", ZIP_DEFLATED) as archive:
        for source, target in sorted(FILES.items(), key=lambda item: item[1]):
            data = (ROOT / source).read_bytes()
            manifest_rows.append((sha256_bytes(data), len(data), target))
            archive.writestr(archive_path(package_name, target), data)

        manifest = [
            "Erlang Workshop 2026 code supplement manifest",
            "",
            "SHA-256                                                           Bytes  Path",
            "---------------------------------------------------------------- -----  ----",
        ]
        for digest, size, target in manifest_rows:
            manifest.append(f"{digest}  {size:5d}  {target}")
        manifest.append("")

        manifest_data = "\n".join(manifest).encode("utf-8")
        archive.writestr(archive_path(package_name, "MANIFEST.txt"), manifest_data)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Build the EW2026 code supplement zip archive."
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help=f"Output zip path. Default: {DEFAULT_OUTPUT}",
    )
    parser.add_argument(
        "--package-name",
        default=DEFAULT_PACKAGE_NAME,
        help="Optional top-level directory name inside the zip. Default: flat archive.",
    )
    args = parser.parse_args()

    build_archive(args.output, args.package_name)
    print(f"Wrote {args.output}")


if __name__ == "__main__":
    main()
