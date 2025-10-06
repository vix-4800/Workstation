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

-- Use system clipboard
vim.schedule(function()
  global.clipboard = "unnamedplus"
end)

-- Sets how neovim will display certain whitespace characters in the editor.
global.list = true
global.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Diagnostic configuration
vim.diagnostic.enable = true
vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = "✗",
      [vim.diagnostic.severity.WARN] = "⚠",
      [vim.diagnostic.severity.INFO] = "ℹ",
      [vim.diagnostic.severity.HINT] = "➤",
    },
    -- Highlight sign for selected severities
    -- linehl = {
    --   [vim.diagnostic.severity.ERROR] = "ErrorMsg",
    -- },
    -- Highlight number for selected severities
    numhl = {
      [vim.diagnostic.severity.WARN] = "WarningMsg",
    },
  } or {},
  virtual_text = {
    source = "if_many",
    spacing = 4,
    prefix = "●",
    format = function(diagnostic)
      return string.format("%s", diagnostic.message)

      -- To include error code or source, use this instead:
      -- return string.format("%s (%s)", diagnostic.message, diagnostic.code or diagnostic.source)
    end,

    -- Only show virtual text for selected severities
    -- Uncomment to enable
    -- severity = vim.diagnostic.severity.ERROR,
    -- severity = { min = vim.diagnostic.severity.WARN },
  },
})
