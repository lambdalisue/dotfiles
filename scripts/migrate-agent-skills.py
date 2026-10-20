"""Retire copied personal skills before Home Manager links shared sources."""

import json
import os
import shutil
import sys
from pathlib import Path


def migrate(source, roots, managed, retired, dry_run=False):
    source = Path(source)
    obsolete = []
    for root in map(Path, roots):
        if root.is_symlink():
            raise ValueError(f"Unexpected skill directory symlink: {root}")
        for name in sorted(set(managed) | set(retired)):
            entry = root / name
            if not os.path.lexists(entry):
                continue
            if (
                name in managed
                and entry.is_symlink()
                and entry.resolve() == (source / name).resolve()
            ):
                continue
            obsolete.append(entry)

    # Validate every discovery root before deleting anything. Only explicitly
    # managed or retired names are removed; unrelated installed skills survive.
    for entry in obsolete:
        print(f"{'Would remove' if dry_run else 'Removing'} {entry}")
        if dry_run:
            continue
        if entry.is_symlink() or not entry.is_dir():
            entry.unlink()
        else:
            shutil.rmtree(entry)


if __name__ == "__main__":
    migrate(
        **json.loads(Path(sys.argv[1]).read_text()),
        dry_run="--dry-run" in sys.argv[2:],
    )
