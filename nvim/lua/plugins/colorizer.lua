return {
  "norcalli/nvim-colorizer.lua",
  event = { "BufReadPost", "BufNewFile" },
  ft = { "css", "scss", "html", "javascript", "typescript", "vue", "lua" },
  config = function()
    require("colorizer").setup()
  end,
  -- keys = { "<leader>tc", ":ColorizerToggle<CR>", { desc = "[T]oggle [C]olorizer" } },
}
