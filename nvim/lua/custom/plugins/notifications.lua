-- Better notifications
return {
  'rcarriga/nvim-notify',
  event = 'VeryLazy',
  config = function()
    local notify = require('notify')
    notify.setup({
      background_colour = 'NotifyBackground',
      fps = 30,
      icons = {
        DEBUG = '',
        ERROR = '',
        INFO = '',
        TRACE = '✎',
        WARN = '',
      },
      level = 2,
      minimum_width = 50,
      render = 'compact',
      stages = 'fade_in_slide_out',
      timeout = 3000,
      top_down = true,
    })

    -- Use notify as default notification handler
    vim.notify = notify
  end,
}
