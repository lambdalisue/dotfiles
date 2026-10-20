import importlib.util
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "skill_migration", Path(__file__).parents[1] / "migrate-agent-skills.py"
)
migration = importlib.util.module_from_spec(spec)
spec.loader.exec_module(migration)


class SkillMigrationTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name).resolve()
        self.root = self.home / ".agents/skills"
        self.root.mkdir(parents=True)
        self.source = self.home / "dotfiles/home/agents/skills"
        (self.source / "pr-create").mkdir(parents=True)

    def migrate(self, **kwargs):
        migration.migrate(
            self.source, [self.root], ["pr-create"], ["git-commit"], **kwargs
        )

    def skill(self, name):
        path = self.root / name
        path.mkdir()
        (path / "SKILL.md").write_text(name)
        return path

    def test_removes_stale_and_retired_skills_but_preserves_external_skills(self):
        self.skill("pr-create")
        self.skill("git-commit")
        external = self.skill("external")
        self.migrate()
        self.assertFalse((self.root / "pr-create").exists())
        self.assertFalse((self.root / "git-commit").exists())
        self.assertTrue(external.exists())
        # Home Manager installs the shared link after migration.
        (self.root / "pr-create").symlink_to(self.source / "pr-create")
        self.migrate()
        self.assertEqual((self.root / "pr-create").resolve(), self.source / "pr-create")

    def test_dry_run_changes_nothing(self):
        original = self.skill("pr-create")
        self.migrate(dry_run=True)
        self.assertTrue(original.exists())

    def test_validates_all_roots_before_removing_anything(self):
        original = self.skill("pr-create")
        other = self.home / ".codex/skills"
        other.parent.mkdir()
        other.symlink_to(self.source)
        with self.assertRaisesRegex(ValueError, "symlink"):
            migration.migrate(
                self.source, [self.root, other], ["pr-create"], ["git-commit"]
            )
        self.assertTrue(original.exists())

    def test_removing_legacy_symlink_preserves_its_target(self):
        external = self.skill("external")
        (self.root / "pr-create").symlink_to("external")
        self.migrate()
        self.assertFalse((self.root / "pr-create").is_symlink())
        self.assertTrue(external.exists())

    def test_codex_system_skills_are_preserved(self):
        self.root = self.home / ".codex/skills"
        self.root.mkdir(parents=True)
        system = self.skill(".system")
        self.skill("git-commit")
        self.migrate()
        self.assertTrue(system.exists())
        self.assertFalse((self.root / "git-commit").exists())
