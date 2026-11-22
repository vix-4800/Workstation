import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None


ROOT = Path(__file__).resolve().parents[1]
ANSIBLE = shutil.which("ansible-playbook")
NODE = shutil.which("node")


@unittest.skipUnless(ANSIBLE and yaml, "requires ansible-playbook and PyYAML")
class DevelopmentConfigTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="debian-development-")
        self.addCleanup(temporary.cleanup)
        self.home = Path(temporary.name)
        self.repo = self.home / "repo"
        self.config = self.home / "config with spaces"
        for directory in ("roles/development/files/tools", "roles/debian/scripts"):
            shutil.copytree(ROOT / directory, self.repo / directory,
                            ignore=shutil.ignore_patterns("node_modules", "package-lock.json"))
        self.variables = yaml.safe_load((ROOT / "roles/debian/vars/development.yml").read_text())
        self.variables.update({
            "home": str(self.home), "dotfiles_dir": str(self.repo),
            "debian_config_home": str(self.config), "ansible_facts": {"env": {}},
        })

    def deploy(self, tasks, *, check=False, expected_success=True):
        # Keep real Ansible task bodies; resolve their role-relative includes in this isolated playbook.
        tasks = yaml.safe_load(yaml.safe_dump(tasks).replace(
            "file: user_links.yml", f"file: {ROOT / 'roles/debian/tasks/user_links.yml'}",
        ))
        playbook = self.home / "deploy.yml"
        playbook.write_text(yaml.safe_dump([{
            "hosts": "localhost", "gather_facts": False, "vars": self.variables, "tasks": tasks,
        }]))
        env = os.environ | {
            "ANSIBLE_CONFIG": str(ROOT / "ansible-debian.cfg"),
            "ANSIBLE_HOME": str(self.home / "ansible"), "ANSIBLE_NOCOLOR": "1",
            "ANSIBLE_LOCAL_TEMP": str(self.home / "ansible-local"),
            "ANSIBLE_REMOTE_TMP": str(self.home / "ansible-remote"),
        }
        result = subprocess.run(  # noqa: S603 - Isolated test-controlled playbook.
            [ANSIBLE, "-i", "localhost,", "-c", "local", str(playbook), *(["--check"] if check else [])],
            cwd=self.home, env=env, text=True, capture_output=True, timeout=90, check=False,
        )
        self.assertEqual(result.returncode == 0, expected_success, result.stdout + result.stderr)
        return result.stdout

    def test_global_php_below_84_is_rejected_before_configuring_tools(self):
        tasks = yaml.safe_load((ROOT / "roles/debian/tasks/development-php.yml").read_text())
        tasks = [task for task in tasks if task["name"] in {
            "Read the PHP version used by Composer", "Require global PHP 8.4 or newer",
        }]
        php = self.home / "php"
        self.variables["debian_development_php"] = str(php)
        for version, supported in (("8.2", False), ("8.3", False), ("8.4", True), ("8.5", True)):
            with self.subTest(version=version):
                php.write_text(f"#!/bin/sh\nprintf '%s' '{version}'\n")
                php.chmod(0o755)
                output = self.deploy(tasks, expected_success=supported)
                if not supported:
                    self.assertIn("PHP 8.4 or newer", output)

    def assert_backup(self, destination, content):
        backups = list(destination.parent.glob(f"{destination.name}.workstation-backup-*/{destination.name}"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), content)

    @unittest.skipUnless(NODE and Path("/usr/bin/fish").exists(), "requires Node.js and Fish")
    def test_node_bootstrap_is_repeatable_and_repairs_circular_runtime_links(self):
        runtime_root = self.home / "node versions"
        runtime = runtime_root / "v26.0.0/bin"
        runtime.mkdir(parents=True)
        (runtime / "node").symlink_to(Path(NODE).resolve())
        npm = runtime / "npm"
        npm.write_text(
            "#!/usr/bin/env node\n"
            "if (process.argv[2] === '--version') console.log('fixture-npm');\n"
            "else if (process.argv[2] !== 'list') process.exit(1);\n"
        )
        npm.chmod(0o755)
        (runtime / "npx").symlink_to(npm)
        user_bin = self.home / ".local/bin"
        user_bin.mkdir(parents=True)
        functions = self.config / "fish/functions"
        functions.mkdir(parents=True)
        # Installed nvm.fish does not reorder PATH when the requested version is already active.
        (functions / "nvm.fish").write_text(
            "function nvm\n"
            '    test "$argv[1]" = use; or return 1\n'
            '    if test "$nvm_current_version" != v26.0.0\n'
            "        set -gx nvm_current_version v26.0.0\n"
            '        set --prepend PATH "$nvm_data/$nvm_current_version/bin"\n'
            "    end\n"
            "end\n"
        )
        environment = {
            "HOME": str(self.home), "XDG_CONFIG_HOME": str(self.config),
            "PATH": f"{user_bin}:{runtime}:/usr/bin:/bin",
            "nvm_data": str(runtime_root), "nvm_current_version": "v26.0.0",
        }
        self.variables.update(debian_development_environment=environment, debian_npm_tools=["fixture-tool"])
        tasks = yaml.safe_load((ROOT / "roles/debian/tasks/development-node.yml").read_text())[:1]
        self.deploy(tasks)
        self.assertRegex(self.deploy(tasks), r"changed=0\b")
        runtime_link = self.home / ".local/lib/workstation/node-bin"
        self.assertEqual(runtime_link.resolve(), runtime)

        runtime_link.unlink()
        runtime_link.symlink_to(user_bin)
        self.deploy(tasks)
        self.assertRegex(self.deploy(tasks), r"changed=0\b")
        self.assertEqual(runtime_link.resolve(), runtime)
        for binary in ("node", "npm", "npx"):
            with self.subTest(binary=binary):
                result = subprocess.run(  # noqa: S603 - Fixture commands execute an installed Node runtime without installs.
                    [str(user_bin / binary), "--version"], env=os.environ | environment,
                    text=True, capture_output=True, timeout=10, check=False,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertTrue(result.stdout.strip())

    def test_node_config_directories_link_to_repo_and_preserve_local_configs(self):
        tasks = yaml.safe_load((ROOT / "roles/debian/tasks/development-node.yml").read_text())[1:-1]
        local = self.config / "eslint/eslint.config.js"
        local.parent.mkdir(parents=True)
        local.write_text("// local ESLint config\n")
        commitlint = self.config / "commitlint"
        commitlint.symlink_to(self.repo / "roles/development/files/tools/commitlint")

        self.deploy(tasks)
        self.assertRegex(self.deploy(tasks), r"changed=0\b")
        backup = list(self.config.glob("eslint.workstation-backup-*/eslint/eslint.config.js"))
        self.assertEqual([path.read_text() for path in backup], ["// local ESLint config\n"])
        self.assertFalse(list(self.config.glob("commitlint.workstation-backup-*")))
        for name, source in (("eslint", "javascript/eslint"), ("commitlint", "commitlint")):
            with self.subTest(name=name):
                destination = self.config / name
                self.assertTrue(destination.is_symlink())
                self.assertEqual(destination.resolve(), self.repo / "roles/development/files/tools" / source)
                config = destination / f"{name}.config.js"
                config.write_text(config.read_text() + "\n// local edit\n")
                self.assertTrue((destination.resolve() / config.name).read_text().endswith("// local edit\n"))
                self.assertTrue((destination / "package.json").is_file())

    def test_shared_php_configs_preserve_local_files_and_legacy_directory_links(self):
        tasks = yaml.safe_load((ROOT / "roles/debian/tasks/development-php.yml").read_text())
        tasks = [tasks[-1]]
        self.config = self.home / "php-config"
        self.variables.update(debian_config_home=str(self.config))
        sources = {
            "phpstan/phpstan.neon": "php/phpstan/phpstan.neon",
            "rector/rector.php": "php/rector/rector.php",
            "php-cs-fixer/php-cs-fixer.php": "php/php-cs-fixer/php-cs-fixer.php",
            "phpcs/phpcs.xml": "php/phpcs/phpcs.xml",
        }
        local = self.config / "rector/rector.php"
        local.parent.mkdir(parents=True)
        local.write_text("<?php // local config\n")
        shared = self.repo / "roles/development/files/tools/php/phpstan"
        self.config.mkdir(exist_ok=True)
        (self.config / "phpstan").symlink_to(shared)
        shared_content = (shared / "phpstan.neon").read_bytes()

        self.deploy(tasks)
        self.assertRegex(self.deploy(tasks), r"changed=0\b")
        self.assert_backup(local, "<?php // local config\n")
        self.assertEqual((shared / "phpstan.neon").read_bytes(), shared_content)
        for relative, source in sources.items():
            destination = self.config / relative
            expected = self.repo / f"roles/development/files/tools/{source}"
            self.assertEqual(destination.resolve(), expected)
            self.assertTrue(destination.is_symlink() or destination.parent.is_symlink())
            destination.write_text(destination.read_text() + "\n# local edit\n")
            self.assertTrue(expected.read_text().endswith("# local edit\n"))


    @unittest.skipUnless(NODE and Path("/usr/bin/fish").exists(), "requires Node.js and Fish")
    def test_node_configs_resolve_dependencies_from_their_real_repository_paths(self):
        functions = self.config / "fish/functions"
        functions.mkdir(parents=True)
        (functions / "nvm.fish").write_text("function nvm\n    return 0\nend\n")
        fixtures = self.home / "npm-fixtures"
        modules = {
            "@eslint/js": "module.exports = {configs: {recommended: {}}};\n",
            "typescript-eslint": (
                "module.exports = {configs: {recommended: [], strictTypeChecked: [], stylisticTypeChecked: []}};\n"
            ),
            "@commitlint/config-conventional": "module.exports = {rules: {}};\n",
        }
        for module, content in modules.items():
            directory = fixtures / module
            directory.mkdir(parents=True)
            (directory / "package.json").write_text(json.dumps({"name": module, "main": "index.js"}))
            (directory / "index.js").write_text(content)
        npm = self.home / ".local/bin/npm"
        npm.parent.mkdir(parents=True)
        # Replace only the external package manager: materialize local module fixtures without network access.
        npm.write_text(
            "#!/usr/bin/python3\n"
            "import json, pathlib, shutil, sys\n"
            "prefix = pathlib.Path(sys.argv[sys.argv.index('--prefix') + 1])\n"
            "dependencies = json.loads((prefix / 'package.json').read_text())['dependencies']\n"
            "if sys.argv[1] == 'list':\n"
            "    sys.exit(0 if all((prefix / 'node_modules' / name).is_dir() for name in dependencies) else 1)\n"
            "if sys.argv[1] != 'install':\n"
            "    sys.exit(2)\n"
            f"fixtures = pathlib.Path({str(fixtures)!r})\n"
            "for name in dependencies:\n"
            "    shutil.copytree(fixtures / name, prefix / 'node_modules' / name, dirs_exist_ok=True)\n"
        )
        npm.chmod(0o755)
        tasks = yaml.safe_load((ROOT / "roles/debian/tasks/development-node.yml").read_text())[1:]
        self.deploy(tasks)
        self.assertRegex(self.deploy(tasks), r"changed=0\b")
        script = (
            "const fs = require('node:fs'); const {createRequire} = require('node:module'); "
            "const config = fs.realpathSync(process.argv[1]); "
            "const configRequire = createRequire(config); "
            "if (process.argv[2] === 'eslint') { import(config).then(value => { "
            "if (!Array.isArray(value.default)) process.exit(1); }); } "
            "else { const value = configRequire(config); configRequire.resolve(value.extends[0]); }"
        )
        for name, source in (("eslint", "javascript/eslint"), ("commitlint", "commitlint")):
            with self.subTest(name=name):
                self.assertTrue((self.repo / "roles/development/files/tools" / source / "node_modules").is_dir())
                result = subprocess.run(  # noqa: S603 - Local Node.js evaluates copied tracked configs and fixture modules.
                    [NODE, "-e", script, str(self.config / name / f"{name}.config.js"), name],
                    text=True, capture_output=True, timeout=10, check=False,
                )
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
