return {
  "nvim-treesitter/nvim-treesitter",
  main = "nvim-treesitter.configs", -- Sets main module to use for opts
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  opts = {
    ensure_installed = { "bash", "diff", "html", "lua", "luadoc", "markdown", "markdown_inline", "vim", "vimdoc" },
    auto_install = true,
    highlight = {
      enable = true,
    },
    indent = { enable = true },
  },
}
