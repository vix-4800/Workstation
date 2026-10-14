return {
  "mistricky/codesnap.nvim",
  version = "2.*",
  cmd = { "CodeSnap", "CodeSnapSave" },
  opts = {
    snapshot_config = {
      code_config = {
        breadcrumbs = { enable = true },
      },
      watermark = { content = "" },
      window = {
        margin = { x = 20, y = 20 },
      },
      background = {
        stops = {
          { position = 0, color = "#7c3aed" },
          { position = 1, color = "#2e1065" },
        },
      },
    },
  },
}
