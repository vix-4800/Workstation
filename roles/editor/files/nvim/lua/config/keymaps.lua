-- Remap up and down to center the cursor after moving
vim.keymap.set("", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })

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

-- Delete without copying into register
vim.keymap.set({ "n", "v" }, "x", '"_x', { desc = "Delete without yanking" })

-- Buffer navigation
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "[D]elete buffer" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to down window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to up window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window management
vim.keymap.set("n", "<leader>ws", "<cmd>w<CR>", { desc = "[W]indow [S]ave" })
vim.keymap.set("n", "<leader>wS", "<cmd>wa<CR>", { desc = "[W]indow Save all" })
vim.keymap.set("n", "<leader>wq", "<cmd>confirm q<CR>", { desc = "[W]indow [Q]uit (confirm)" })
vim.keymap.set("n", "<leader>wQ", "<cmd>qa!<CR>", { desc = "[W]indow [Q]uit without saving" })
vim.keymap.set("n", "<leader>wx", "<cmd>wq<CR>", { desc = "[W]indow Save & e[X]it" })
vim.keymap.set("n", "<leader>wX", "<cmd>xa<CR>", { desc = "[W]indow Save & e[X]it all" })
vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "[W]indow [V]ertical split" })
vim.keymap.set("n", "<leader>wh", "<cmd>split<cr>", { desc = "[W]indow [H]orizontal split" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "[W]indow [=] Equal size" })

-- Diagnostics navigation
vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "[D]iagnostic [F]loat" })
vim.keymap.set("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>", { desc = "[D]iagnostic [L]ist" })

-- Quick access to config
vim.keymap.set("n", "<leader>vc", "<cmd>e $MYVIMRC<cr>", { desc = "Edit [V]im [C]onfig" })
