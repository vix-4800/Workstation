return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- dependencies = { 'echasnovski/mini.icons' },
  config = function()
    local dashboard = require("alpha.themes.dashboard")
    dashboard.section.header.val = {
      "██╗   ██╗██╗██╗  ██╗",
      "██║   ██║██║╚██╗██╔╝",
      "██║   ██║██║ ╚███╔╝ ",
      "╚██╗ ██╔╝██║ ██╔██╗ ",
      " ╚████╔╝ ██║██╔╝ ██╗",
      "  ╚═══╝  ╚═╝╚═╝  ╚═╝",
    }

    dashboard.section.buttons.val = {
      dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
      dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
      dashboard.button("p", "  Projects", ":Telescope projects <CR>"),
      dashboard.button("s", "勒 Settings", ":e $MYVIMRC <CR>"),
      dashboard.button("l", "鈴 Lazy", ":Lazy<CR>"),
      dashboard.button("q", "  Quit", ":qa<CR>"),
    }

    dashboard.section.footer.val = ""

    dashboard.section.footer.opts.hl = "Type"
    dashboard.section.header.opts.hl = "Include"
    dashboard.section.buttons.opts.hl = "Keyword"

    dashboard.opts.opts.noautocmd = true

    require("alpha").setup(dashboard.opts)
  end,
}
