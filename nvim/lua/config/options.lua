local global = vim.opt

-- Globals
global.number = true
global.relativenumber = true

global.showmode = false

global.termguicolors = true

-- Better indentation
global.breakindent = true
global.smartindent = true -- Smart indenting
global.autoindent = true -- Copy indent from current line when starting a new line

-- Save undo history
global.undofile = true

-- Better search experience
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
global.ignorecase = true
global.smartcase = true
global.hlsearch = true -- Highlight search results
global.incsearch = true -- Incremental search

-- Keep signcolumn on by default
global.signcolumn = "yes"

-- Decrease update time
global.updatetime = 250

-- Decrease mapped sequence wait time
global.timeoutlen = 300

-- Configure how new splits should be opened
global.splitright = true
global.splitbelow = true

-- Preview substitutions live, as you type!
global.inccommand = "split"

-- Show which line your cursor is on
global.cursorline = true

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
global.confirm = true

-- Additional useful options
global.fileencoding = "utf-8" -- File content encoding

-- Better completion experience
global.completeopt = "menuone,noselect" -- Better autocompletion
global.pumheight = 10 -- Pop up menu height

-- Better editing experience
global.wrap = false -- Display lines as one long line
global.scrolloff = 10 -- Minimal number of screen lines to keep above and below the cursor.
global.sidescrolloff = 8 -- Minimal number of columns to keep to the left and right of the cursor

global.backup = false -- Don't create backup files
global.writebackup = false -- Don't create backup files
global.swapfile = false -- Don't use swapfiles

global.spell = true -- Enable spell checking
global.spelllang = "en" -- Set spellcheck language to English

-- Other
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.schedule(function()
  global.clipboard = "unnamedplus"
end)

-- Sets how neovim will display certain whitespace characters in the editor.
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
