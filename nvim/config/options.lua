local global = vim.o

global.number = true
global.showmode = false

vim.g.mapleader = " "
vim.g.have_nerd_font = true

vim.schedule(function()
	global.clipboard = "unnamedplus"
end)
