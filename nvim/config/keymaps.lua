local telescope = require("telescope.builtin")

vim.keymap.set('n', '<leader>ff', telescope.find_files, { desc = 'Telescope [F]ind [F]iles' })
