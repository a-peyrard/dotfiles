"""
Tests for dotfiles-bundle

Run with: uv run pytest tests/test_dotfiles_bundle.py -v
"""

import json
import sys
import tarfile
import tempfile
import types
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional

import pytest

# Add the script to path for importing
SCRIPT_PATH = Path(__file__).parent.parent / "src" / "dotfiles-bundle"


def load_dotfiles_bundle():
    """Load the dotfiles-bundle script as a proper module."""
    # Create a module object
    module = types.ModuleType("dotfiles_bundle")
    module.__file__ = str(SCRIPT_PATH)

    # Register it in sys.modules so dataclass can find it
    sys.modules["dotfiles_bundle"] = module

    # Read the script
    with open(SCRIPT_PATH) as f:
        code = f.read()

    # Replace the main guard to prevent execution
    code = code.replace('if __name__ == "__main__":', "if False:")

    # Execute in the module's namespace
    exec(compile(code, SCRIPT_PATH, "exec"), module.__dict__)

    return module


# Load the module
dotfiles_bundle = load_dotfiles_bundle()

# Extract classes and functions from the module
glob_match = dotfiles_bundle.glob_match
deep_merge = dotfiles_bundle.deep_merge
format_size = dotfiles_bundle.format_size
BundleConfig = dotfiles_bundle.BundleConfig
BundleResolver = dotfiles_bundle.BundleResolver
FileResolver = dotfiles_bundle.FileResolver
OverrideManager = dotfiles_bundle.OverrideManager
PackageBuilder = dotfiles_bundle.PackageBuilder
ResolvedFile = dotfiles_bundle.ResolvedFile


# ============================================================================
# Fixtures
# ============================================================================


@dataclass
class MockDotfilesRepo:
    """Represents a mock dotfiles repository structure for testing."""

    root: Path
    bundles_dir: Path
    links_dir: Path
    links_in_depth_dir: Path
    util_dir: Path
    home_dir: Path

    def create_file(self, relative_path: str, content: str = "") -> Path:
        """Create a file in the links directory."""
        file_path = self.links_dir / relative_path
        file_path.parent.mkdir(parents=True, exist_ok=True)
        file_path.write_text(content)
        return file_path

    def create_in_depth_file(self, relative_path: str, content: str = "") -> Path:
        """Create a file in the links-in-depth directory."""
        file_path = self.links_in_depth_dir / relative_path
        file_path.parent.mkdir(parents=True, exist_ok=True)
        file_path.write_text(content)
        return file_path

    def create_bundle(self, name: str, content: str) -> Path:
        """Create a bundle directory with bundle.toml file."""
        bundle_dir = self.bundles_dir / name
        bundle_dir.mkdir(parents=True, exist_ok=True)
        bundle_path = bundle_dir / "bundle.toml"
        bundle_path.write_text(content)
        return bundle_path

    def create_override(self, bundle_name: str, relative_path: str, content: str) -> Path:
        """Create an override file for a bundle (directly in bundle directory)."""
        override_path = self.bundles_dir / bundle_name / relative_path
        override_path.parent.mkdir(parents=True, exist_ok=True)
        override_path.write_text(content)
        return override_path

    def create_runtime_file(self, relative_path: str, content: str = "") -> Path:
        """Create a file in the mock home directory (for runtime files)."""
        file_path = self.home_dir / relative_path
        file_path.parent.mkdir(parents=True, exist_ok=True)
        file_path.write_text(content)
        return file_path

    def create_util(self) -> None:
        """Create minimal util directory structure."""
        common_sh = self.util_dir / "common.sh"
        common_sh.parent.mkdir(parents=True, exist_ok=True)
        common_sh.write_text("# Common utilities\n")

        detect_os = self.util_dir / "detect_os.sh"
        detect_os.write_text("# OS detection\n")


@pytest.fixture
def mock_repo(tmp_path: Path) -> MockDotfilesRepo:
    """Create a mock dotfiles repository structure."""
    repo = MockDotfilesRepo(
        root=tmp_path,
        bundles_dir=tmp_path / "bundles",
        links_dir=tmp_path / "links",
        links_in_depth_dir=tmp_path / "links-in-depth",
        util_dir=tmp_path / "util",
        home_dir=tmp_path / "home",
    )

    # Create directories
    repo.bundles_dir.mkdir(parents=True)
    repo.links_dir.mkdir(parents=True)
    repo.links_in_depth_dir.mkdir(parents=True)
    repo.util_dir.mkdir(parents=True)
    repo.home_dir.mkdir(parents=True)

    return repo


# ============================================================================
# Pure Function Tests: glob_match
# ============================================================================


class TestGlobMatch:
    """Tests for the glob_match function."""

    @pytest.mark.parametrize(
        "pattern,path,expected",
        [
            # Simple file patterns
            (".zshrc", ".zshrc", True),
            (".zshrc", ".bashrc", False),
            # Wildcard patterns
            ("*.txt", "file.txt", True),
            ("*.txt", "file.md", False),
            (".bin/*", ".bin/script.sh", True),
            (".bin/*", ".config/file", False),
            # Directory patterns (ending with /)
            (".config/", ".config", True),
            (".config/", ".config/nvim/init.lua", True),
            (".config/", ".other/file", False),
            # Double wildcard patterns
            ("**/.git/", ".git", True),
            ("**/.git/", "foo/.git", True),
            ("**/.git/", "foo/bar/.git", True),
            ("**/.git/", "foo/.gitignore", False),
        ],
    )
    def test_glob_match_should_match_patterns_correctly(
        self, pattern: str, path: str, expected: bool
    ):
        # GIVEN
        # Pattern and path from parametrize

        # WHEN
        result = glob_match(pattern, path)

        # THEN
        assert result == expected, f"glob_match({pattern!r}, {path!r}) should be {expected}"

    def test_glob_match_should_handle_complex_directory_pattern(self):
        # GIVEN
        pattern = ".env.d/common/"
        paths_that_should_match = [
            ".env.d/common",
            ".env.d/common/10_autojump.env",
            ".env.d/common/subdir/file.env",
        ]
        paths_that_should_not_match = [
            ".env.d/macos/file.env",
            ".env.d/commonfile",
        ]

        # WHEN/THEN
        for path in paths_that_should_match:
            assert glob_match(pattern, path), f"{path} should match {pattern}"

        for path in paths_that_should_not_match:
            assert not glob_match(pattern, path), f"{path} should not match {pattern}"


# ============================================================================
# Pure Function Tests: deep_merge
# ============================================================================


class TestDeepMerge:
    """Tests for the deep_merge function."""

    def test_deep_merge_should_merge_flat_dicts(self):
        # GIVEN
        base = {"a": 1, "b": 2}
        override = {"b": 3, "c": 4}

        # WHEN
        result = deep_merge(base, override)

        # THEN
        assert result == {"a": 1, "b": 3, "c": 4}

    def test_deep_merge_should_recursively_merge_nested_dicts(self):
        # GIVEN
        base = {
            "user": {"name": "John", "email": "john@example.com"},
            "settings": {"theme": "dark"},
        }
        override = {
            "user": {"email": "john@work.com"},
            "settings": {"font": "monospace"},
        }

        # WHEN
        result = deep_merge(base, override)

        # THEN
        assert result == {
            "user": {"name": "John", "email": "john@work.com"},
            "settings": {"theme": "dark", "font": "monospace"},
        }

    def test_deep_merge_should_replace_non_dict_values(self):
        # GIVEN
        base = {"items": [1, 2, 3], "count": 5}
        override = {"items": [4, 5], "count": 10}

        # WHEN
        result = deep_merge(base, override)

        # THEN
        assert result == {"items": [4, 5], "count": 10}

    def test_deep_merge_should_not_mutate_original_dicts(self):
        # GIVEN
        base = {"a": {"b": 1}}
        override = {"a": {"c": 2}}
        original_base = {"a": {"b": 1}}

        # WHEN
        result = deep_merge(base, override)

        # THEN
        assert base == original_base, "Original base dict should not be mutated"
        assert result is not base, "Result should be a new dict"


# ============================================================================
# Pure Function Tests: format_size
# ============================================================================


class TestFormatSize:
    """Tests for the format_size function."""

    @pytest.mark.parametrize(
        "size,expected",
        [
            (0, "0.0B"),
            (500, "500.0B"),
            (1024, "1.0KB"),
            (1536, "1.5KB"),
            (1048576, "1.0MB"),
            (1073741824, "1.0GB"),
        ],
    )
    def test_format_size_should_format_correctly(self, size: int, expected: str):
        # GIVEN
        # Size from parametrize

        # WHEN
        result = format_size(size)

        # THEN
        assert result == expected


# ============================================================================
# Integration Tests: BundleResolver
# ============================================================================


class TestBundleResolver:
    """Tests for bundle resolution with inheritance."""

    def test_bundle_resolver_should_parse_simple_bundle(self, mock_repo: MockDotfilesRepo):
        # GIVEN
        mock_repo.create_bundle(
            "simple",
            """
[bundle]
name = "simple"
description = "A simple bundle"
target = "linux"

[files]
include = [".zshrc", ".gitconfig"]
exclude = [".bin/"]

[packages]
install = ["git", "vim"]
""",
        )
        resolver = BundleResolver(mock_repo.bundles_dir)

        # WHEN
        config = resolver.resolve("simple")

        # THEN
        assert config.name == "simple"
        assert config.description == "A simple bundle"
        assert config.target == "linux"
        assert config.files_include == [".zshrc", ".gitconfig"]
        assert config.files_exclude == [".bin/"]
        assert config.packages_install == ["git", "vim"]

    def test_bundle_resolver_should_resolve_inheritance(self, mock_repo: MockDotfilesRepo):
        # GIVEN
        mock_repo.create_bundle(
            "base",
            """
[bundle]
name = "base"
description = "Base bundle"
target = "any"

[files]
include = [".zshrc", ".gitconfig"]

[packages]
install = ["git", "vim"]
""",
        )
        mock_repo.create_bundle(
            "server",
            """
[bundle]
name = "server"
extends = "base"
description = "Server bundle"
target = "linux"

[files]
include = [".vimrc"]
exclude = [".bin/"]

[packages]
install = ["tmux"]
""",
        )
        resolver = BundleResolver(mock_repo.bundles_dir)

        # WHEN
        config = resolver.resolve("server")

        # THEN
        assert config.name == "server"
        assert config.description == "Server bundle"
        assert config.target == "linux"
        assert config.files_include == [".zshrc", ".gitconfig", ".vimrc"]
        assert config.files_exclude == [".bin/"]
        assert config.packages_install == ["git", "vim", "tmux"]

    def test_bundle_resolver_should_list_all_bundles(self, mock_repo: MockDotfilesRepo):
        # GIVEN
        mock_repo.create_bundle("bundle1", '[bundle]\nname = "bundle1"')
        mock_repo.create_bundle("bundle2", '[bundle]\nname = "bundle2"')
        mock_repo.create_bundle("bundle3", '[bundle]\nname = "bundle3"')
        resolver = BundleResolver(mock_repo.bundles_dir)

        # WHEN
        bundles = resolver.list_bundles()

        # THEN
        names = [b.name for b in bundles]
        assert sorted(names) == ["bundle1", "bundle2", "bundle3"]


# ============================================================================
# Integration Tests: FileResolver
# ============================================================================


class TestFileResolver:
    """Tests for file resolution with patterns."""

    def test_file_resolver_should_resolve_exact_file(self, mock_repo: MockDotfilesRepo):
        # GIVEN
        mock_repo.create_file(".zshrc", "# zshrc content")
        mock_repo.create_file(".gitconfig", "# gitconfig content")
        config = BundleConfig(
            name="test",
            files_include=[".zshrc"],
        )
        resolver = FileResolver(
            links_dir=mock_repo.links_dir,
            links_in_depth_dir=mock_repo.links_in_depth_dir,
            home_dir=mock_repo.home_dir,
        )

        # WHEN
        files = resolver.resolve_bundle(config)

        # THEN
        paths = [f.relative_path for f in files]
        assert ".zshrc" in paths
        assert ".gitconfig" not in paths

    def test_file_resolver_should_resolve_directory_pattern(self, mock_repo: MockDotfilesRepo):
        # GIVEN
        mock_repo.create_file(".env.d/common/10_autojump.env", "# autojump")
        mock_repo.create_file(".env.d/common/20_fzf.env", "# fzf")
        mock_repo.create_file(".env.d/macos/30_brew.env", "# brew")
        config = BundleConfig(
            name="test",
            files_include=[".env.d/common/"],
        )
        resolver = FileResolver(
            links_dir=mock_repo.links_dir,
            links_in_depth_dir=mock_repo.links_in_depth_dir,
            home_dir=mock_repo.home_dir,
        )

        # WHEN
        files = resolver.resolve_bundle(config)

        # THEN
        paths = [f.relative_path for f in files]
        assert ".env.d/common/10_autojump.env" in paths
        assert ".env.d/common/20_fzf.env" in paths
        assert ".env.d/macos/30_brew.env" not in paths

    def test_file_resolver_should_apply_exclude_patterns(self, mock_repo: MockDotfilesRepo):
        # GIVEN
        mock_repo.create_file(".bin/script1.sh", "# script 1")
        mock_repo.create_file(".bin/script2.sh", "# script 2")
        mock_repo.create_file(".bin/toggle-app.sh", "# toggle")
        config = BundleConfig(
            name="test",
            files_include=[".bin/"],
            files_exclude=[".bin/toggle-*.sh"],
        )
        resolver = FileResolver(
            links_dir=mock_repo.links_dir,
            links_in_depth_dir=mock_repo.links_in_depth_dir,
            home_dir=mock_repo.home_dir,
        )

        # WHEN
        files = resolver.resolve_bundle(config)

        # THEN
        paths = [f.relative_path for f in files]
        assert ".bin/script1.sh" in paths
        assert ".bin/script2.sh" in paths
        assert ".bin/toggle-app.sh" not in paths

    def test_file_resolver_should_resolve_glob_pattern(self, mock_repo: MockDotfilesRepo):
        # GIVEN
        mock_repo.create_file(".bin/git-status.sh", "# git status")
        mock_repo.create_file(".bin/git-diff.sh", "# git diff")
        mock_repo.create_file(".bin/other.sh", "# other")
        config = BundleConfig(
            name="test",
            files_include=[".bin/git-*.sh"],
        )
        resolver = FileResolver(
            links_dir=mock_repo.links_dir,
            links_in_depth_dir=mock_repo.links_in_depth_dir,
            home_dir=mock_repo.home_dir,
        )

        # WHEN
        files = resolver.resolve_bundle(config)

        # THEN
        paths = [f.relative_path for f in files]
        assert ".bin/git-status.sh" in paths
        assert ".bin/git-diff.sh" in paths
        assert ".bin/other.sh" not in paths

    def test_file_resolver_should_include_platform_specific_files(
        self, mock_repo: MockDotfilesRepo
    ):
        # GIVEN - platform files are now just regular includes
        mock_repo.create_file(".zshrc", "# zshrc")
        mock_repo.create_file(".aerospace.toml", "# aerospace")
        mock_repo.create_file(".env.d/linux/30_apt.env", "# apt")
        config = BundleConfig(
            name="test",
            target="linux",
            files_include=[".zshrc", ".env.d/linux/"],
        )
        resolver = FileResolver(
            links_dir=mock_repo.links_dir,
            links_in_depth_dir=mock_repo.links_in_depth_dir,
            home_dir=mock_repo.home_dir,
        )

        # WHEN
        files = resolver.resolve_bundle(config)

        # THEN
        paths = [f.relative_path for f in files]
        assert ".zshrc" in paths
        assert ".env.d/linux/30_apt.env" in paths
        assert ".aerospace.toml" not in paths  # Not included because not in files_include

    def test_file_resolver_should_merge_links_and_links_in_depth(
        self, mock_repo: MockDotfilesRepo
    ):
        # GIVEN
        mock_repo.create_file(".config/nvim/init.lua", "# nvim init from links")
        mock_repo.create_in_depth_file(".config/starship.toml", "# starship from in-depth")
        config = BundleConfig(
            name="test",
            files_include=[".config/"],
        )
        resolver = FileResolver(
            links_dir=mock_repo.links_dir,
            links_in_depth_dir=mock_repo.links_in_depth_dir,
            home_dir=mock_repo.home_dir,
        )

        # WHEN
        files = resolver.resolve_bundle(config)

        # THEN
        paths = [f.relative_path for f in files]
        assert ".config/nvim/init.lua" in paths
        assert ".config/starship.toml" in paths


# ============================================================================
# Integration Tests: OverrideManager
# ============================================================================


class TestOverrideManager:
    """Tests for the override system."""

    def test_override_manager_should_find_public_override(self, mock_repo: MockDotfilesRepo):
        # GIVEN
        mock_repo.create_override("server", ".gitconfig", "[user]\nemail = work@example.com")
        manager = OverrideManager(mock_repo.bundles_dir)

        # WHEN
        overrides = manager.find_overrides("server", ".gitconfig")

        # THEN
        assert len(overrides) == 1
        assert overrides[0].name == ".gitconfig"

    def test_override_manager_should_find_private_override(self, mock_repo: MockDotfilesRepo):
        # GIVEN
        mock_repo.create_override("server", ".gitconfig.private", "[user]\ntoken = secret")
        manager = OverrideManager(mock_repo.bundles_dir)

        # WHEN
        overrides = manager.find_overrides("server", ".gitconfig")

        # THEN
        assert len(overrides) == 1
        assert overrides[0].name == ".gitconfig.private"

    def test_override_manager_should_find_both_public_and_private(
        self, mock_repo: MockDotfilesRepo
    ):
        # GIVEN
        mock_repo.create_override("server", ".gitconfig", "[user]\nemail = work@example.com")
        mock_repo.create_override("server", ".gitconfig.private", "[user]\ntoken = secret")
        manager = OverrideManager(mock_repo.bundles_dir)

        # WHEN
        overrides = manager.find_overrides("server", ".gitconfig")

        # THEN
        assert len(overrides) == 2

    def test_override_manager_should_apply_replacement_for_non_structured_files(
        self, mock_repo: MockDotfilesRepo
    ):
        # GIVEN
        base_content = b"original content"
        override_path = mock_repo.create_override("server", ".zshrc", "override content")
        manager = OverrideManager(mock_repo.bundles_dir)

        # WHEN
        result = manager.apply_override(base_content, override_path, ".zshrc")

        # THEN
        assert result == b"override content"

    def test_override_manager_should_deep_merge_json_files(self, mock_repo: MockDotfilesRepo):
        # GIVEN
        base_content = json.dumps({"user": {"name": "John"}, "theme": "dark"}).encode()
        override_path = mock_repo.create_override(
            "server", "config.json", json.dumps({"user": {"email": "john@work.com"}})
        )
        manager = OverrideManager(mock_repo.bundles_dir)

        # WHEN
        result = manager.apply_override(base_content, override_path, "config.json")

        # THEN
        result_dict = json.loads(result)
        assert result_dict == {
            "user": {"name": "John", "email": "john@work.com"},
            "theme": "dark",
        }


# ============================================================================
# Integration Tests: PackageBuilder
# ============================================================================


class TestPackageBuilder:
    """Tests for package building."""

    def test_package_builder_should_create_tarball(self, mock_repo: MockDotfilesRepo):
        # GIVEN
        mock_repo.create_file(".zshrc", "# zshrc content")
        mock_repo.create_file(".gitconfig", "# gitconfig content")
        mock_repo.create_util()

        config = BundleConfig(name="test", description="Test bundle")
        files = [
            ResolvedFile(
                source_path=mock_repo.links_dir / ".zshrc",
                relative_path=".zshrc",
                source_type="links",
            ),
            ResolvedFile(
                source_path=mock_repo.links_dir / ".gitconfig",
                relative_path=".gitconfig",
                source_type="links",
            ),
        ]
        builder = PackageBuilder(
            "test",
            config,
            bundles_dir=mock_repo.bundles_dir,
            util_dir=mock_repo.util_dir,
        )
        output_path = mock_repo.root / "output.tar.gz"

        # WHEN
        result = builder.build(files, output_path)

        # THEN
        assert result.exists()
        with tarfile.open(result, "r:gz") as tar:
            names = tar.getnames()
            assert any(".zshrc" in n for n in names)
            assert any(".gitconfig" in n for n in names)

    def test_package_builder_should_apply_overrides(self, mock_repo: MockDotfilesRepo):
        # GIVEN
        mock_repo.create_file(".gitconfig", "[user]\nemail = personal@example.com")
        mock_repo.create_override("test", ".gitconfig", "[user]\nemail = work@example.com")
        mock_repo.create_util()

        config = BundleConfig(name="test", packages_install=[])
        files = [
            ResolvedFile(
                source_path=mock_repo.links_dir / ".gitconfig",
                relative_path=".gitconfig",
                source_type="links",
            ),
        ]
        builder = PackageBuilder(
            "test",
            config,
            bundles_dir=mock_repo.bundles_dir,
            util_dir=mock_repo.util_dir,
        )
        output_path = mock_repo.root / "output.tar.gz"

        # WHEN
        builder.build(files, output_path)

        # THEN
        with tarfile.open(output_path, "r:gz") as tar:
            for member in tar.getmembers():
                if member.name.endswith(".gitconfig"):
                    content = tar.extractfile(member).read().decode()
                    assert "work@example.com" in content
                    break
            else:
                pytest.fail(".gitconfig not found in tarball")

    def test_package_builder_should_include_install_script_when_packages_enabled(
        self, mock_repo: MockDotfilesRepo
    ):
        # GIVEN
        mock_repo.create_file(".zshrc", "# zshrc")
        mock_repo.create_util()

        config = BundleConfig(name="test", packages_install=["git", "vim"])
        files = [
            ResolvedFile(
                source_path=mock_repo.links_dir / ".zshrc",
                relative_path=".zshrc",
                source_type="links",
            ),
        ]
        builder = PackageBuilder(
            "test",
            config,
            bundles_dir=mock_repo.bundles_dir,
            util_dir=mock_repo.util_dir,
        )
        output_path = mock_repo.root / "output.tar.gz"

        # WHEN
        builder.build(files, output_path)

        # THEN
        with tarfile.open(output_path, "r:gz") as tar:
            names = tar.getnames()
            assert any("install-packages.sh" in n for n in names)
            assert any("README.md" in n for n in names)
            assert any("util" in n for n in names)


# ============================================================================
# End-to-End Tests
# ============================================================================


class TestEndToEnd:
    """End-to-end tests simulating real usage."""

    def test_e2e_should_build_bundle_with_inheritance_and_overrides(
        self, mock_repo: MockDotfilesRepo
    ):
        # GIVEN
        # Create base files
        mock_repo.create_file(".zshrc", "# base zshrc")
        mock_repo.create_file(".gitconfig", "[user]\nemail = personal@example.com")
        mock_repo.create_file(".vimrc", "# vimrc")
        mock_repo.create_file(".bin/script.sh", "# script")
        mock_repo.create_util()

        # Create base bundle
        mock_repo.create_bundle(
            "base",
            """
[bundle]
name = "base"
description = "Base configuration"
target = "any"

[files]
include = [
    ".gitconfig",
    ".zshrc",
]

[packages]
include = true
""",
        )

        # Create server bundle extending base
        mock_repo.create_bundle(
            "server",
            """
[bundle]
name = "server"
description = "Server configuration"
extends = "base"
target = "linux"

[files]
include = [
    ".vimrc",
]
exclude = []

[packages]
include = false
""",
        )

        # Create override for server
        mock_repo.create_override("server", ".gitconfig", "[user]\nemail = server@example.com")

        # WHEN
        resolver = BundleResolver(mock_repo.bundles_dir)
        config = resolver.resolve("server")

        file_resolver = FileResolver(
            links_dir=mock_repo.links_dir,
            links_in_depth_dir=mock_repo.links_in_depth_dir,
            home_dir=mock_repo.home_dir,
        )
        files = file_resolver.resolve_bundle(config)

        builder = PackageBuilder(
            "server",
            config,
            bundles_dir=mock_repo.bundles_dir,
            util_dir=mock_repo.util_dir,
        )
        output_path = mock_repo.root / "server.tar.gz"
        builder.build(files, output_path)

        # THEN
        # Verify bundle config
        assert config.name == "server"
        assert config.target == "linux"
        assert ".zshrc" in config.files_include
        assert ".gitconfig" in config.files_include
        assert ".vimrc" in config.files_include

        # Verify files resolved
        paths = [f.relative_path for f in files]
        assert ".zshrc" in paths
        assert ".gitconfig" in paths
        assert ".vimrc" in paths

        # Verify tarball contents
        assert output_path.exists()
        with tarfile.open(output_path, "r:gz") as tar:
            names = tar.getnames()
            assert any(".zshrc" in n for n in names)
            assert any(".gitconfig" in n for n in names)
            assert any(".vimrc" in n for n in names)

            # Verify override was applied
            for member in tar.getmembers():
                if member.name.endswith(".gitconfig"):
                    content = tar.extractfile(member).read().decode()
                    assert "server@example.com" in content
                    break

            # Verify no install script (packages_install=[])
            assert not any("install-packages.sh" in n for n in names)
