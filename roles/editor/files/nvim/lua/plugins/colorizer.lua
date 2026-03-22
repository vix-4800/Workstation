return {
  "NvChad/nvim-colorizer.lua",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    filetypes = { "css", "scss", "html", "javascript", "typescript", "vue", "lua" },
    user_default_options = {
      mode = "virtualtext",
      names = false,
      tailwind = false,
    },
  },
}
