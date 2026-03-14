local palette = require("catppuccin.palettes").get_palette("mocha")

local transparent = "NONE"
local inactiveBg = palette.mantle
local sectionBg = palette.base
local sectionFg = palette.text

return {
  normal = {
    a = { bg = palette.lavender, fg = palette.base, gui = "bold" },
    b = { bg = sectionBg, fg = sectionFg },
    c = { bg = transparent, fg = palette.subtext1 },
  },
  insert = {
    a = { bg = palette.green, fg = palette.base, gui = "bold" },
    b = { bg = sectionBg, fg = sectionFg },
    c = { bg = transparent, fg = palette.subtext1 },
  },
  visual = {
    a = { bg = palette.mauve, fg = palette.base, gui = "bold" },
    b = { bg = sectionBg, fg = sectionFg },
    c = { bg = transparent, fg = palette.subtext1 },
  },
  replace = {
    a = { bg = palette.red, fg = palette.base, gui = "bold" },
    b = { bg = sectionBg, fg = sectionFg },
    c = { bg = transparent, fg = palette.subtext1 },
  },
  command = {
    a = { bg = palette.peach, fg = palette.base, gui = "bold" },
    b = { bg = sectionBg, fg = sectionFg },
    c = { bg = transparent, fg = palette.subtext1 },
  },
  terminal = {
    a = { bg = palette.sapphire, fg = palette.base, gui = "bold" },
    b = { bg = sectionBg, fg = sectionFg },
    c = { bg = transparent, fg = palette.subtext1 },
  },
  inactive = {
    a = { bg = inactiveBg, fg = palette.overlay1, gui = "bold" },
    b = { bg = inactiveBg, fg = palette.overlay0 },
    c = { bg = transparent, fg = palette.overlay0 },
  },
}
