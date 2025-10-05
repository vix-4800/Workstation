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

-- Remap up and down to center the cursor after moving
vim.api.nvim_set_keymap("", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("", "<C-d>", "<C-d>zz", { noremap = true, silent = true })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Find and Replace keymaps
vim.keymap.set(
  "n",
  "<leader>rw",
  ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
  { desc = "[R]eplace [W]ord under cursor" }
)
vim.keymap.set("v", "<leader>r", '"hy:%s/<C-r>h//g<left><left>', { desc = "[R]eplace selection" })
vim.keymap.set(
  "n",
  "<leader>rl",
  ":s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
  { desc = "[R]eplace word in current [L]ine" }
)

-- Better indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Move text up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Insert new line below and above and exit insert mode
vim.keymap.set("n", "o", "o<Esc>", { desc = "Insert new line below and exit insert mode" })
vim.keymap.set("n", "O", "O<Esc>", { desc = "Insert new line above and exit insert mode" })

-- Delete without copying into register
vim.keymap.set({ "n", "v" }, "x", '"_x', { desc = "Delete without yanking" })

-- Quick save and quit
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "[W]rite file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "[Q]uit" })
vim.keymap.set("n", "<leader>x", "<cmd>x<CR>", { desc = "Save and quit" })
