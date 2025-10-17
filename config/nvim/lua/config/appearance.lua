-- vim.cmd([[
--   highlight Normal guibg=none
--   highlight NonText guibg=none
--   highlight Normal ctermbg=none
--   highlight NonText ctermbg=none
-- ]])

vim.o.termguicolors = true

vim.api.nvim_set_hl(0, "LspInlayHint", {
  -- bg = "NONE",
  fg = "#6c7086",
  italic = true,
})
