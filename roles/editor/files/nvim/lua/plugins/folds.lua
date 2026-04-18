return {
  "kevinhwang91/nvim-ufo",
  dependencies = { "kevinhwang91/promise-async" },
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    provider_selector = function()
      return { "treesitter", "indent" }
    end,
  },
}
