return {
  "nvim-treesitter/nvim-treesitter",
  main = "nvim-treesitter.configs", -- Sets main module to use for opts
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  opts = {
    ensure_installed = {
      "bash",
      "diff",
      "html",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "vim",
      "vimdoc",
      "yaml",
      "json",
      "css",
      "typescript",
      "javascript",
      "php",
      "phpdoc",
      "python",
      "go",
      "dockerfile",
    },
    auto_install = true,
    sync_install = false,
    highlight = {
      enable = true,
    },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>",
        node_incremental = "<CR>",
        scope_incremental = "<TAB>",
        node_decremental = "<S-TAB>",
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = { query = "@function.outer", desc = "around function" },
          ["if"] = { query = "@function.inner", desc = "inner function" },
          ["ac"] = { query = "@class.outer", desc = "around class" },
          ["ic"] = { query = "@class.inner", desc = "inner class" },
          ["aa"] = { query = "@parameter.outer", desc = "around parameter" },
          ["ia"] = { query = "@parameter.inner", desc = "inner parameter" },
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]f"] = "@function.outer",
          ["]c"] = "@class.outer",
          ["]a"] = "@parameter.inner",
        },
        goto_next_end = {
          ["]F"] = "@function.outer",
          ["]C"] = "@class.outer",
          ["]A"] = "@parameter.inner",
        },
        goto_previous_start = {
          ["[f"] = "@function.outer",
          ["[c"] = "@class.outer",
          ["[a"] = "@parameter.inner",
        },
        goto_previous_end = {
          ["[F"] = "@function.outer",
          ["[C"] = "@class.outer",
          ["[A"] = "@parameter.inner",
        },
      },
    },
  },
}
