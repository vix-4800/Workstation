-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

vim.keymap.set('n', '<leader>e', '<cmd>Oil<CR>', { desc = 'Open [E]xplorer' })

-- Find and Replace keymaps
vim.keymap.set('n', '<leader>rw', ':%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>', { desc = '[R]eplace [W]ord under cursor' })
vim.keymap.set('v', '<leader>r', '"hy:%s/<C-r>h//g<left><left>', { desc = '[R]eplace selection' })
vim.keymap.set('n', '<leader>rl', ':s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>', { desc = '[R]eplace word in current [L]ine' })
vim.keymap.set('n', '<leader>rc', ':%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gcI<Left><Left><Left><Left>', { desc = '[R]eplace word with [C]onfirmation' })

-- Code Actions Menus
vim.keymap.set('n', '<leader>cp', function()
  local lines = {
    '╭─────────────────────────────────────────────────────────────────────╮',
    '│                       📝 PHP Code Actions Menu                      │',
    '╞═════════════════════════════════════════════════════════════════════╡',
    '│                                                                     │',
    '│  🐘 PHP Actions:                                                     │',
    '│     [R]efactor file (Rector)                                        │',
    '│     [s]tatic analysis file (PHPStan)                                │',
    '│     [c]heck coding standards (PHPCS)                                │',
    '│                                                                     │',
    '│  🌐 Project-wide PHP Actions:                                       │',
    '│     [S]tatic analysis entire project (PHPStan)                      │',
    '│     [C]heck coding standards entire project (PHPCS)                 │',
    '│                                                                     │',
    '╰─────────────────────────────────────────────────────────────────────╯',
  }
  vim.api.nvim_echo({ { table.concat(lines, '\n'), 'Normal' } }, false, {})
end, { desc = 'Show PHP Code Actions Menu' })
