-- Better notifications
return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  config = function()
    local notify = require("notify")
    notify.setup({
      background_colour = "#000000",
      fps = 30,
      level = 2,
      minimum_width = 50,
      render = "simple",
      stages = "fade_in_slide_out",
      timeout = 3000,
      top_down = true,
    })

    -- Use notify as default notification handler
    vim.notify = notify
  end,
}
