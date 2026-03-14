return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name, _)
          return name == ".."
            or name == ".git"
            or name == ".DS_Store"
            or name == "thumbs.db"
            or name == ".venv"
            or name == "__pycache__"
            or name == "node_modules"
            or name == ".idea"
            or name == ".vscode"
            or name == ".pytest_cache"
            or name == ".mypy_cache"
        end,
      },
      win_options = {
        wrap = true,
        signcolumn = "yes:2",
      },
      watch_for_changes = true,
      columns = {
        "icon",
        -- "permissions",
        -- "size",
        "mtime",
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          require("oil").open()
        end,
        desc = "Open [E]xplorer",
      },
    },
  },
  {
    "refractalize/oil-git-status.nvim",
    dependencies = { "stevearc/oil.nvim" },
    config = true,
  },
}
