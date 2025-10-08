return {
  "mistricky/codesnap.nvim",
  build = "make",
  cmd = { "CodeSnap", "CodeSnapSave" },
  opts = {
    has_breadcrumbs = true,
    watermark = "",
    bg_theme = "grape",
    min_width = 720,
    bg_x_padding = 20,
    bg_y_padding = 20,
  },
}
