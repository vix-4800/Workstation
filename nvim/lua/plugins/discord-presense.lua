return {
  'vyfor/cord.nvim',
  build = ':Cord update',
  opts = {
    display = {
      theme = 'catppuccin',
      flavor = 'dark',
    },
    text = {
      editing = '📝 Editing files',
      viewing = '👀 Viewing files',
      workspace = function()
        local hour = tonumber(os.date('%H'))
        local status =
          hour >= 23 and '🌙 Midnight debugging session' or
          hour >= 20 and '🌙 Late-night refactoring' or
          hour >= 17 and '🌆 Evening commits incoming' or
          hour >= 13 and '☀️ Afternoon feature grind' or
          hour >= 9  and '🌅 Morning coding flow' or
          hour >= 6  and '🌅 Early-bird programming' or
            '🌙 After-hours hacking spree'

        return string.format('%s', status)
      end
    }
  },
  event = 'VeryLazy',
  enabled = true,
  keys = {
    { '<leader>td', ':Cord toggle<CR>', desc = '[T]oggle [D]iscord Presence' },
  },
}
