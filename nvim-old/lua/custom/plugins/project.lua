return {
  'ahmedkhalf/project.nvim',
  config = function()
    require('project_nvim').setup {
      manual_mode = false,
      detection_methods = { 'lsp', 'pattern' },
      patterns = { '.git', 'composer.json', 'package.json', 'go.mod', 'pyproject.toml' },
    }

    require('telescope').load_extension 'projects'
  end,
}
