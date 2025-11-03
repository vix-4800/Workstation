# Commitlint Configuration

This directory contains the global commitlint configuration for enforcing conventional commit messages.

## Overview

Commitlint helps your team adhere to a commit convention by linting commit messages against a set of rules.

## Commit Message Format

The commit message should be structured as follows:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Examples

```bash
# Simple commit
feat: add user authentication

# With scope
feat(auth): add JWT token validation

# With body
fix(api): handle null response from external service

Previously the API would crash when receiving null responses.
Now it returns a proper error message to the client.

# With breaking change
feat(api)!: change API response structure

BREAKING CHANGE: The API now returns data in a different format.
Clients need to update their response parsing logic.

# Multiple issues
fix(ui): resolve button alignment issues

Fixes #123, #456
```

## Commit Types

| Type       | Description                                                      | Example                            |
| ---------- | ---------------------------------------------------------------- | ---------------------------------- |
| `feat`     | A new feature                                                    | `feat: add user profile page`      |
| `fix`      | A bug fix                                                        | `fix: resolve login timeout`       |
| `docs`     | Documentation only changes                                       | `docs: update installation guide`  |
| `style`    | Code style changes (formatting, missing semicolons, etc.)        | `style: format code with prettier` |
| `refactor` | Code refactoring without changing functionality                  | `refactor: simplify auth logic`    |
| `perf`     | Performance improvements                                         | `perf: optimize database queries`  |
| `test`     | Adding or updating tests                                         | `test: add unit tests for auth`    |
| `build`    | Changes to build system or dependencies                          | `build: update webpack config`     |
| `ci`       | CI configuration changes                                         | `ci: add GitHub Actions workflow`  |
| `chore`    | Other changes (maintenance, package updates, etc.)               | `chore: update dependencies`       |
| `revert`   | Revert a previous commit                                         | `revert: undo feature X`           |
| `wip`      | Work in progress (use sparingly, prefer rebasing before pushing) | `wip: initial implementation`      |

## Scopes

Scopes are optional but recommended. They provide context about which part of the codebase is affected:

- Component names: `auth`, `api`, `ui`, `database`
- Feature areas: `user-management`, `payments`, `notifications`
- File/module names: `config`, `routes`, `models`

## Rules

- **Type**: Required, must be lowercase
- **Scope**: Optional but recommended, must be lowercase
- **Subject**: Required, 3-72 characters, lowercase, no period at end
- **Header**: Max 100 characters total
- **Body**: Optional, blank line before body, max 100 chars per line
- **Footer**: Optional, blank line before footer

## Installation

Install commitlint globally:

```bash
# Install commitlint CLI and conventional config
npm install -g @commitlint/cli @commitlint/config-conventional
```

Or use the Ansible playbook which installs it automatically:

```bash
ansible-playbook ansible/development.yml
```

## Usage

### Manual Validation

Validate a commit message:

```bash
# Validate last commit
git log -1 --pretty=%B | commitlint

# Validate commit message from stdin
echo "feat: add new feature" | commitlint
```

### Git Hook Integration

To automatically validate commits, use with husky:

```bash
# Install husky in your project
npm install --save-dev husky @commitlint/cli @commitlint/config-conventional

# Create commitlint config symlink
ln -s ~/.config/commitlint/commitlint.config.js .

# Setup husky hook
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit $1'
```

### Pre-commit Hook

Alternatively, use with pre-commit framework:

```yaml
# Add to .pre-commit-config.yaml
repos:
  - repo: https://github.com/alessandrojcm/commitlint-pre-commit-hook
    rev: v9.5.0
    hooks:
      - id: commitlint
        stages: [commit-msg]
        additional_dependencies: ['@commitlint/config-conventional']
```

## Configuration Location

After running `workstation dotfiles link`, the configuration will be available at:

```
~/.config/commitlint/commitlint.config.js
```

## Benefits

- ✅ Consistent commit history
- ✅ Easier code reviews
- ✅ Automated changelog generation
- ✅ Better Git log readability
- ✅ Semantic versioning support
- ✅ CI/CD integration

## Related Tools

- **Commitizen**: Interactive commit message helper
- **Standard Version**: Automated versioning and changelog
- **Semantic Release**: Fully automated version management
- **Conventional Changelog**: Generate changelogs from commits

## Resources

- [Commitlint Documentation](https://commitlint.js.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Angular Commit Guidelines](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)
