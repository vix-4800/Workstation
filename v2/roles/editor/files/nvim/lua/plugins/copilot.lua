return {
  {
    "zbirenbaum/copilot.lua",
    requires = {
      "copilotlsp-nvim/copilot-lsp",
      init = function()
        vim.g.copilot_nes_debounce = 500
      end,
    },
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        nes = {
          enabled = false,
          keymap = {
            accept_and_goto = "<leader>p",
            accept = false,
            dismiss = "<Esc>",
          },
        },
        suggestion = { enabled = false },
        panel = { enabled = false },
        filetypes = {
          help = false,
          gitcommit = true,
          gitrebase = true,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
          ["env"] = false,
          ["dotenv"] = false,
        },
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      model = 'claude-sonnet-4.5',
      temperature = 0.1,
      context = "buffers",

      window = {
        layout = 'float', -- 'vertical', 'horizontal', 'float'
        width = 0.7,
        height = 0.4,
        zindex = 100,
        border = 'rounded',
      },

      auto_insert_mode = false,
      auto_fold = true,
    },
    keys = {
      { "<leader>aa", "<cmd>CopilotChatToggle<cr>",  desc = "[A]I Chat Toggle" },
      { "<leader>ae", "<cmd>CopilotChatExplain<cr>", desc = "[A]I [E]xplain",  mode = { "n", "v" } },
      { "<leader>ar", "<cmd>CopilotChatReview<cr>",  desc = "[A]I [R]eview",   mode = { "n", "v" } },
      { "<leader>af", "<cmd>CopilotChatFix<cr>",     desc = "[A]I [F]ix",      mode = { "n", "v" } },
      { "<leader>ao", "<cmd>CopilotChatOptimize<cr>", desc = "[A]I [O]ptimize", mode = { "n", "v" } },
      { "<leader>ad", "<cmd>CopilotChatDocs<cr>",    desc = "[A]I [D]ocs",     mode = { "n", "v" } },
      { "<leader>at", "<cmd>CopilotChatTests<cr>",   desc = "[A]I [T]ests",    mode = { "n", "v" } },
      {
        "<leader>ap",
        function()
          local input = vim.fn.input("Ask Copilot: ")
          if input ~= "" then
            vim.cmd("CopilotChat " .. input)
          end
        end,
        desc = "[A]I [P]rompt",
      },
    },
  },
}
