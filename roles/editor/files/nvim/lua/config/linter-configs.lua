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

local config_home = vim.env.XDG_CONFIG_HOME
if not config_home or config_home == "" then
  config_home = vim.fn.expand("~/.config")
end

function M.configPath(path)
  return vim.fs.joinpath(config_home, path)
end

function M.composerBin(name)
  local composer_home = vim.env.COMPOSER_HOME
  if not composer_home or composer_home == "" then
    composer_home = M.configPath("composer")
  end
  return vim.fs.joinpath(composer_home, "vendor", "bin", name)
end

M.configs = {
  -- PHP
  php_cs_fixer = M.configPath("php-cs-fixer/php-cs-fixer.php"),
  phpstan = M.configPath("phpstan/phpstan.neon"),
  phpcs = M.configPath("phpcs/phpcs.xml"),
  phpmd = M.configPath("phpmd/phpmd.yml"),
  rector = M.configPath("rector/rector.php"),
  pint = M.configPath("pint/pint.json"),
  blade_formatter = M.configPath("blade-formatter/.bladeformatterrc.json"),

  -- Python
  ruff = M.configPath("ruff/pyproject.toml"),

  -- JavaScript/TypeScript/JSON/CSS/HTML/Markdown
  prettier = vim.fn.expand("~/.prettierrc"),
  prettier_ignore = vim.fn.expand("~/.prettierignore"),
  eslint = M.configPath("eslint/eslint.config.js"),
  stylelint = vim.fn.expand("~/.stylelintrc.json"),
  linthtml = vim.fn.expand("~/.linthtmlrc"),
  jsonlintrc = vim.fn.expand("~/.jsonlintrc"),

  -- Shell
  shellcheck = vim.fn.expand("~/.shellcheckrc"),

  -- YAML
  yamllint = M.configPath("yamllint/config"),
  yamlfmt = M.configPath("yamlfmt/.yamlfmt"),

  -- TOML
  taplo = M.configPath("taplo/taplo.toml"),

  -- Markdown
  markdownlint = M.configPath("markdownlint/.markdownlint.jsonc"),

  -- Docker
  hadolint = M.configPath("hadolint.yaml"),

  -- Lua
  stylua = M.configPath("stylua/stylua.toml"),
  luacheck = M.configPath("luacheck/.luacheckrc"),

  -- SQL
  sqlfluff = vim.fn.expand("~/.sqlfluff"),

  -- NGINX
  nginx_lint = M.configPath("nginx-lint/.nginx-lint.toml"),

  -- Ansible
  ansible_lint = vim.fn.expand("~/.ansible-lint"),

  -- Make
  checkmake = M.configPath("checkmake/checkmake.ini"),

  -- EditorConfig
  editorconfig_checker = vim.fn.expand("~/.editorconfig-checker.json"),
}

function M.getConfig(tool)
  return M.configs[tool]
end

return M
