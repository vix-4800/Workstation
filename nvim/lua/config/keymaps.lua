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
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down (alt)" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Insert new line below and above and exit insert mode
vim.keymap.set("n", "o", "o<Esc>", { desc = "Insert new line below and exit insert mode" })
vim.keymap.set("n", "O", "O<Esc>", { desc = "Insert new line above and exit insert mode" })

-- Delete without copying into register
vim.keymap.set({ "n", "v" }, "x", '"_x', { desc = "Delete without yanking" })

-- Quick save and quit
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "[W]rite file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "[Q]uit" })

-- Buffer navigation
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "[D]elete buffer" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to down window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to up window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
