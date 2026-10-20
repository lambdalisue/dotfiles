import importlib.util
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "migration", Path(__file__).parents[1] / "migrate-agent-state.py"
)
migration = importlib.util.module_from_spec(spec)
spec.loader.exec_module(migration)


class MigrationTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / "dotfiles"
        self.source.mkdir()
        self.target = self.root / ".agent"
        (self.source / "AGENTS.md").write_text("instructions")
        (self.source / "settings.json").write_text('{"applicationState": true}')
        (self.source / "sessions").mkdir()
        (self.source / "sessions" / "session").write_text("history")

    def migrate(self, **kwargs):
        migration.migrate(
            self.source, self.target, ["AGENTS.md", "skills/owned"], **kwargs
        )

    def test_preserves_state_inode_and_old_absolute_paths(self):
        self.target.symlink_to(self.source)
        inode = (self.source / "sessions" / "session").stat().st_ino
        self.migrate()
        self.assertFalse(self.target.is_symlink())
        self.assertEqual((self.target / "sessions" / "session").stat().st_ino, inode)
        self.assertEqual((self.source / "sessions" / "session").read_text(), "history")
        self.assertFalse((self.source / "AGENTS.md").is_symlink())
        self.assertEqual(
            (self.target / "settings.json").read_text(), '{"applicationState": true}'
        )
        self.migrate()

    def test_moves_downloaded_skills_but_keeps_owned_skills_in_dotfiles(self):
        skills = self.source / "skills"
        (skills / "owned").mkdir(parents=True)
        (skills / "downloaded").mkdir()
        (skills / "downloaded" / "SKILL.md").write_text("download")
        self.migrate()
        self.assertFalse((skills / "owned").is_symlink())
        self.assertEqual(
            (self.target / "skills/downloaded/SKILL.md").read_text(), "download"
        )

    def test_collision_is_reported_before_any_state_moves(self):
        self.target.mkdir()
        (self.target / "settings.json").write_text("existing")
        with self.assertRaisesRegex(ValueError, "both paths"):
            self.migrate()
        self.assertFalse((self.source / "sessions").is_symlink())

    def test_refuses_unrelated_symlink(self):
        other = self.root / "other"
        other.mkdir()
        self.target.symlink_to(other)
        with self.assertRaisesRegex(ValueError, "Unexpected"):
            self.migrate()

    def test_preserves_external_skill_symlinks_during_root_migration(self):
        external = self.root / "external-skill"
        external.mkdir()
        (self.source / "skills").mkdir()
        (self.source / "skills" / "external").symlink_to(external)
        self.target.symlink_to(self.source)
        self.migrate()
        self.assertEqual(
            (self.target / "skills/external").resolve(), external.resolve()
        )

    def test_relative_symlinks_keep_their_original_referent(self):
        external = self.root / "external"
        external.write_text("external")
        (self.source / "cache-link").symlink_to("../external")
        # Use a different parent so moving a relative link verbatim breaks it.
        self.target = self.root / "home" / ".agent"
        self.migrate()
        self.assertEqual((self.target / "cache-link").read_text(), "external")

    def test_dry_run_keeps_legacy_symlink_and_files(self):
        self.target.symlink_to(self.source)
        self.migrate(dry_run=True)
        self.assertTrue(self.target.is_symlink())
        self.assertFalse((self.source / "settings.json").is_symlink())


if __name__ == "__main__":
    unittest.main()
