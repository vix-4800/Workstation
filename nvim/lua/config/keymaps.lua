local telescope = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Telescope [F]ind [F]iles" })

vim.keymap.set("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Open [E]xplorer" })
