return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = function(plugin)
      if vim.g.workstation_upgrade then
        return
      end
      vim.opt.rtp:prepend(plugin.dir)
      local treesitter = require("nvim-treesitter")
      treesitter.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
      assert(treesitter.update():wait(300000), "Treesitter update failed")
    end,
    opts = {
      ensure_installed = {
        "bash",
        "fish",
        "diff",
        "html",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "vim",
        "vimdoc",
        "yaml",
        "json",
        "css",
        "typescript",
        "javascript",
        "php",
        "phpdoc",
        "python",
        "go",
        "dockerfile",
        "xml",
        "toml",
        "regex",
        "gitcommit",
        "gitignore",
        "sql",
      },
    },
    config = function(_, opts)
      local treesitter = require("nvim-treesitter")
      treesitter.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })

      local function attach(bufnr)
        if not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].buftype ~= "" then
          return false
        end
        if not pcall(vim.treesitter.start, bufnr) then
          return false
        end
        vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        vim.keymap.set({ "n", "x" }, "<CR>", function()
          vim.treesitter.select("parent")
        end, { buffer = bufnr, desc = "Expand syntax selection" })
        vim.keymap.set("x", "<Tab>", function()
          vim.treesitter.select("parent")
        end, { buffer = bufnr, desc = "Expand syntax selection" })
        vim.keymap.set("x", "<S-Tab>", function()
          vim.treesitter.select("child")
        end, { buffer = bufnr, desc = "Shrink syntax selection" })
        return true
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-attach", { clear = true }),
        callback = function(event)
          if not attach(event.buf) and vim.bo[event.buf].buftype == "" then
            local language = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
            if language and vim.list_contains(treesitter.get_available(), language) then
              treesitter.install({ language }):await(function(err, success)
                vim.schedule(function()
                  if not err and success then
                    attach(event.buf)
                  end
                end)
              end)
            end
          end
        end,
      })
      treesitter.install(opts.ensure_installed):await(function(err, success)
        vim.schedule(function()
          if err or not success then
            vim.notify(
              "Treesitter installation failed: " .. tostring(err or "parser build failed"),
              vim.log.levels.ERROR
            )
            return
          end
          for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            attach(bufnr)
          end
        end)
      end)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    opts = {
      select = { lookahead = true },
      move = { set_jumps = true },
    },
    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)
      local select = require("nvim-treesitter-textobjects.select")
      for key, query in pairs({
        af = "@function.outer",
        ["if"] = "@function.inner",
        ac = "@class.outer",
        ic = "@class.inner",
        aa = "@parameter.outer",
        ia = "@parameter.inner",
      }) do
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(query, "textobjects")
        end, { desc = "Select " .. query })
      end

      local move = require("nvim-treesitter-textobjects.move")
      for method, mappings in pairs({
        goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
        goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
        goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
        goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
      }) do
        for key, query in pairs(mappings) do
          vim.keymap.set({ "n", "x", "o" }, key, function()
            move[method](query, "textobjects")
          end, { desc = method .. " " .. query })
        end
      end
    end,
  },
}
