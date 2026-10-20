"""Move legacy agent state out of dotfiles without breaking absolute paths."""

import json
import os
import sys
from pathlib import Path


def migrate(source, target, managed, dry_run=False):
    source, target = Path(source), Path(target)
    managed = set(managed)
    if not source.is_dir():
        return
    if target.is_symlink():
        if target.resolve() != source.resolve():
            raise ValueError(f"Unexpected agent directory symlink: {target}")
    elif target.exists() and not target.is_dir():
        raise ValueError(f"Expected an agent directory: {target}")

    # Validate all collisions before moving anything. Old absolute paths can
    # still be embedded in plugin manifests and running application processes.
    def entries(directory, relative=Path()):
        for entry in directory.iterdir():
            path = relative / entry.name
            name = path.as_posix()
            destination = target / path
            if entry.name == ".gitignore" or name in managed:
                continue
            if any(item.startswith(name + "/") for item in managed):
                yield from entries(entry, path)
            elif entry.is_symlink() and os.readlink(entry) == str(destination):
                continue
            else:
                if not target.is_symlink() and os.path.lexists(destination):
                    raise ValueError(
                        f"Agent state exists at both paths: {entry}, {destination}"
                    )
                yield entry, destination

    moves = list(entries(source))
    if dry_run:
        print(f"Would migrate {len(moves)} state entries from {source} to {target}")
        return
    if target.is_symlink():
        target.unlink()
    target.mkdir(mode=0o700, parents=True, exist_ok=True)
    for entry, destination in moves:
        destination.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
        if entry.is_symlink() and not os.path.isabs(os.readlink(entry)):
            destination.symlink_to(entry.resolve())
            entry.unlink()
        else:
            entry.rename(destination)
        entry.symlink_to(destination, target_is_directory=destination.is_dir())


if __name__ == "__main__":
    for agent in json.loads(Path(sys.argv[1]).read_text()):
        migrate(**agent, dry_run="--dry-run" in sys.argv[2:])
