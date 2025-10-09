return {
  "vyfor/cord.nvim",
  build = ":Cord update",
  opts = function()
    local icons = require("config.icons")
    return {
      display = {
        theme = "catppuccin",
        flavor = "dark",
      },
      text = {
        editing = icons.notifications.editing .. " Editing files",
        viewing = icons.notifications.viewing .. " Viewing files",
        workspace = function()
          local hour = tonumber(os.date("%H"))
          local status = hour >= 23 and icons.notifications.midnight .. " Midnight debugging session"
            or hour >= 20 and icons.notifications.late_night .. " Late-night refactoring"
            or hour >= 17 and icons.notifications.evening .. " Evening commits incoming"
            or hour >= 13 and icons.notifications.afternoon .. " Afternoon feature grind"
            or hour >= 9 and icons.notifications.morning .. " Morning coding flow"
            or hour >= 6 and icons.notifications.early_bird .. " Early-bird programming"
            or icons.notifications.midnight .. " After-hours hacking spree"

          return string.format("%s", status)
        end,
      },
    }
  end,
  event = "VeryLazy",
  enabled = false,
  keys = {
    { "<leader>td", ":Cord toggle<CR>", desc = "[T]oggle [D]iscord Presence" },
  },
}
