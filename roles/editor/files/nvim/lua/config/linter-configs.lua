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

  -- Python
  ruff = vim.fn.expand("~/.config/ruff/pyproject.toml"),

  -- JavaScript/TypeScript/JSON/CSS/HTML/Markdown
  prettier = vim.fn.expand("~/.prettierrc"),
  prettier_ignore = vim.fn.expand("~/.prettierignore"),
  stylelint = vim.fn.expand("~/.stylelintrc.json"),
  htmlhint = vim.fn.expand("~/.htmlhintrc"),
  jsonlintrc = vim.fn.expand("~/.jsonlintrc"),

  -- Shell
  shellcheck = vim.fn.expand("~/.shellcheckrc"),

  -- YAML
  yamllint = vim.fn.expand("~/.config/yamllint/config"),

  -- Markdown
  markdownlint = vim.fn.expand("~/.config/markdownlint/.markdownlint.jsonc"),

  -- Docker
  hadolint = vim.fn.expand("~/.config/hadolint.yaml"),

  -- Lua
  stylua = vim.fn.expand("~/.config/stylua/stylua.toml"),

  -- SQL
  sqlfluff = vim.fn.expand("~/.sqlfluff"),

  -- Make
  checkmake = vim.fn.expand("~/.config/checkmake/checkmake.ini"),
}

function M.getConfig(tool)
  return M.configs[tool]
end

return M
