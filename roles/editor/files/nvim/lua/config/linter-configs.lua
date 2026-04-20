-- ╭─────────────────────────────────────────────────────────╮
-- │ Global Linter & Formatter Configuration Paths           │
-- ╰─────────────────────────────────────────────────────────╯
--
-- This file contains paths to global configuration files for linters and formatters.
-- These configs are managed by the dotfiles repository and symlinked to appropriate locations.

local M = {}

-- ╭─────────────────────────────────────────────────────────╮
-- │ Configuration Paths                                     │
-- ╰─────────────────────────────────────────────────────────╯

M.configs = {
  -- PHP
  php_cs_fixer = vim.fn.expand("~/.config/php-cs-fixer/php-cs-fixer.php"),
  phpstan = vim.fn.expand("~/.config/phpstan/phpstan.neon"),
  phpcs = vim.fn.expand("~/.config/phpcs/phpcs.xml"),
  phpmd = vim.fn.expand("~/.config/phpmd/phpmd.xml"),
  rector = vim.fn.expand("~/.config/rector/rector.php"),
  pint = vim.fn.expand("~/.config/pint/pint.json"),
  blade_formatter = vim.fn.expand("~/.config/blade-formatter/.bladeformatterrc.json"),

  -- Python
  ruff = vim.fn.expand("~/.config/ruff/pyproject.toml"),

  -- JavaScript/TypeScript/JSON/CSS/HTML/Markdown
  prettier = vim.fn.expand("~/.prettierrc"),
  prettier_ignore = vim.fn.expand("~/.prettierignore"),
  eslint = vim.fn.expand("~/.config/eslint/eslint.config.js"),
  stylelint = vim.fn.expand("~/.stylelintrc.json"),
  linthtml = vim.fn.expand("~/.linthtmlrc"),
  jsonlintrc = vim.fn.expand("~/.jsonlintrc"),

  -- Shell
  shellcheck = vim.fn.expand("~/.shellcheckrc"),

  -- YAML
  yamllint = vim.fn.expand("~/.config/yamllint/config"),
  yamlfmt = vim.fn.expand("~/.config/yamlfmt/.yamlfmt"),

  -- TOML
  taplo = vim.fn.expand("~/.config/taplo/taplo.toml"),

  -- Markdown
  markdownlint = vim.fn.expand("~/.config/markdownlint/.markdownlint.jsonc"),

  -- Docker
  hadolint = vim.fn.expand("~/.config/hadolint.yaml"),

  -- Lua
  stylua = vim.fn.expand("~/.config/stylua/stylua.toml"),
  luacheck = vim.fn.expand("~/.config/luacheck/.luacheckrc"),

  -- SQL
  sqlfluff = vim.fn.expand("~/.sqlfluff"),

  -- NGINX
  nginx_lint = vim.fn.expand("~/.config/nginx-lint/.nginx-lint.toml"),

  -- Ansible
  ansible_lint = vim.fn.expand("~/.ansible-lint"),

  -- Make
  checkmake = vim.fn.expand("~/.config/checkmake/checkmake.ini"),

  -- EditorConfig
  editorconfig_checker = vim.fn.expand("~/.editorconfig-checker.json"),
}

function M.getConfig(tool)
  return M.configs[tool]
end

return M
