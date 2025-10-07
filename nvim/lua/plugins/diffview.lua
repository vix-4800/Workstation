return {
  "sindrets/diffview.nvim",
  event = "BufRead",
  config = function()
    local diffview = require("diffview")

    vim.keymap.set("n", "<leader>gd", diffview.open, { desc = "Open Diffview" })
    vim.keymap.set("n", "<leader>gq", diffview.close, { desc = "[Q]uit Diffview" })
    vim.keymap.set("n", "<leader>gh", ":DiffviewFileHistory %<CR>", { desc = "File [H]istory" })
    vim.keymap.set("n", "<leader>gH", ":DiffviewFileHistory<CR>", { desc = "Project [H]istory" })
  end,
}
