-- ====== Telescope ======
local telescope = require("telescope.builtin")

vim.keymap.set("n", "<leader>sf", telescope.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sw", telescope.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", telescope.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader><leader>", telescope.buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>sb", function()
  telescope.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
    winblend = 10,
    previewer = false,
  }))
end, { desc = "Fuzzily search in current [b]uffer" })

-- ====== Oil ======
vim.keymap.set("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Open [E]xplorer" })

-- ====== GitSigns ======
local gitsigns = require("gitsigns")

-- visual mode
vim.keymap.set("v", "<leader>gs", function()
  gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "git [s]tage hunk" })
vim.keymap.set("v", "<leader>gr", function()
  gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "git [r]eset hunk" })

-- normal mode
vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk, { desc = "git [s]tage hunk" })
vim.keymap.set("n", "<leader>gS", gitsigns.stage_buffer, { desc = "git [S]tage buffer" })
vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "git [r]eset hunk" })
vim.keymap.set("n", "<leader>gR", gitsigns.reset_buffer, { desc = "git [R]eset buffer" })
vim.keymap.set("n", "<leader>gu", gitsigns.stage_hunk, { desc = "git [u]ndo stage hunk" })
vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { desc = "git [p]review hunk" })
vim.keymap.set("n", "<leader>gd", function()
  gitsigns.diffthis("@")
end, { desc = "git [d]iff" })
