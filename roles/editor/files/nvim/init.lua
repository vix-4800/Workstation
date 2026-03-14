vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.appearance")
require("config.autocmds")
require("config.ftdetect")

-- Language specific configs
require("config.php")
