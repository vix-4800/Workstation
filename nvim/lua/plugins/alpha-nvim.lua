return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local icons = require("config.icons")
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
      dashboard.button("f", icons.dashboard.find_file .. " Find file", ":Telescope find_files <CR>"),
      dashboard.button("n", icons.dashboard.new_file .. "  New file", ":ene <BAR> startinsert <CR>"),
      dashboard.button("r", icons.dashboard.recent_files .. " Recent files", ":Telescope oldfiles <CR>"),
      dashboard.button("s", icons.dashboard.settings .. " Settings", ":e $MYVIMRC <CR>"),
      dashboard.button("l", icons.dashboard.lazy .. "  Lazy", ":Lazy<CR>"),
      dashboard.button("m", icons.dashboard.mason .. " Mason", ":Mason<CR>"),
      dashboard.button("q", icons.dashboard.quit .. " Quit", ":qa<CR>"),
    }

    dashboard.section.footer.val = ""

    dashboard.section.footer.opts.hl = "Type"
    dashboard.section.header.opts.hl = "Include"
    dashboard.section.buttons.opts.hl = "Keyword"

    dashboard.opts.opts.noautocmd = true

    require("alpha").setup(dashboard.opts)
  end,
}
