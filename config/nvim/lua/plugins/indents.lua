return {
  {
    "NMAC427/guess-indent.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
  },
}
