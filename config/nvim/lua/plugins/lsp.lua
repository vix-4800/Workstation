return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      { "saghen/blink.cmp" },
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
          map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
          map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
          map("<leader>cs", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[C]ode [S]ymbols")
          map("K", vim.lsp.buf.hover, "Hover Documentation")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })

            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
            end, "[T]oggle Inlay [H]ints")
          end

          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
              end,
            })
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities())

      -- PHP (Intelephense) - Primary LSP
      vim.lsp.config("intelephense", {
        capabilities = capabilities,
        settings = {
          intelephense = {
            stubs = {
              "apache",
              "bcmath",
              "bz2",
              "calendar",
              "com_dotnet",
              "Core",
              "ctype",
              "curl",
              "date",
              "dba",
              "dom",
              "enchant",
              "exif",
              "FFI",
              "fileinfo",
              "filter",
              "fpm",
              "ftp",
              "gd",
              "gettext",
              "gmp",
              "hash",
              "iconv",
              "imap",
              "intl",
              "json",
              "ldap",
              "libxml",
              "mbstring",
              "meta",
              "mysqli",
              "oci8",
              "odbc",
              "openssl",
              "pcntl",
              "pcre",
              "PDO",
              "pdo_ibm",
              "pdo_mysql",
              "pdo_pgsql",
              "pdo_sqlite",
              "pgsql",
              "Phar",
              "posix",
              "pspell",
              "readline",
              "Reflection",
              "session",
              "shmop",
              "SimpleXML",
              "snmp",
              "soap",
              "sockets",
              "sodium",
              "SPL",
              "sqlite3",
              "standard",
              "superglobals",
              "sysvmsg",
              "sysvsem",
              "sysvshm",
              "tidy",
              "tokenizer",
              "xml",
              "xmlreader",
              "xmlrpc",
              "xmlwriter",
              "xsl",
              "Zend OPcache",
              "zip",
              "zlib",
            },
            files = {
              maxSize = 10000000,
              exclude = {
                "**/mariadb/**",
                "**/meili_data/**",
                "**/logs/**",
                "**/tools/**",
                "**/src/www/**",
                "**/cache/**",
                "**/tests/**",
                "**/node_modules/**",
              },
            },
            environment = {
              shortOpenTag = false,
            },
            diagnostics = {
              enable = true,
              run = "onType", -- onSave or onType
              typeErrors = true,
              undefinedTypes = true,
              undefinedFunctions = true,
              undefinedMethods = true,
              undefinedProperties = true,
              undefinedVariables = true,
              undefinedConstants = true,
              undefinedClassConstants = true,
              duplicateSymbols = true,
              argumentCount = true,
              deprecated = true,
              languageConstraints = true,
              implementationErrors = true,
              unusedSymbols = true,
              relaxedTypeCheck = false,
            },
            completion = {
              insertUseDeclaration = true,
              fullyQualifyGlobalConstantsAndFunctions = false,
              suggestObjectOperatorStaticMethods = false,
              maxItems = 50,
              triggerParameterHints = true,
            },
            format = {
              enable = false, -- Use php-cs-fixer instead
            },
            phpdoc = {
              useFullyQualifiedNames = false,
            },
            rename = {
              exclude = {
                "**/vendor/**",
                "**/node_modules/**",
              },
            },
            trace = {
              server = "verbose",
            },
            telemetry = {
              enabled = false,
            },
            maxMemory = 4096,
            inlayHints = {
              returnTypes = true,
              parameterNames = true,
              parameterTypes = true,
            },
          },
        },
      })

      -- PHP (PHPActor) - Refactoring & Code Actions
      vim.lsp.config("phpactor", {
        capabilities = vim.tbl_deep_extend("force", capabilities, {
          textDocument = {
            completion = {
              completionItem = {
                snippetSupport = false,
              },
            },
            hover = { dynamicRegistration = false },
            signatureHelp = { dynamicRegistration = false },
            references = { dynamicRegistration = false },
            definition = { dynamicRegistration = false },
            documentSymbol = { dynamicRegistration = false },
            codeLens = { dynamicRegistration = false },
          },
        }),
        init_options = {
          ["language_server_phpstan.enabled"] = false,
          ["language_server_psalm.enabled"] = false,
          ["language_server.diagnostics_on_update"] = false,
          ["language_server.diagnostics_on_open"] = false,
          ["language_server.diagnostics_on_save"] = false,
          ["completion_worse.completor.class_member.enabled"] = false,
          ["completion_worse.completor.local_variable.enabled"] = false,
          ["completion_worse.completor.declared_function.enabled"] = false,
          ["completion_worse.completor.declared_constant.enabled"] = false,
          ["completion_worse.completor.declared_class.enabled"] = false,
        },
        handlers = {
          ["textDocument/publishDiagnostics"] = function() end,
          ["textDocument/hover"] = function() end,
          ["textDocument/signatureHelp"] = function() end,
          ["textDocument/completion"] = function() end,
        },
        on_attach = function(client, bufnr)
          client.server_capabilities.completionProvider = false
          client.server_capabilities.hoverProvider = false
          client.server_capabilities.signatureHelpProvider = false
          client.server_capabilities.definitionProvider = false
          client.server_capabilities.referencesProvider = false
          client.server_capabilities.documentSymbolProvider = false
          client.server_capabilities.codeLensProvider = false
          client.server_capabilities.documentHighlightProvider = false
        end,
      })

      -- Lua
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            hint = {
              enable = true,
              arrayIndex = "Auto",
              setType = true,
              paramName = "All",
              paramType = true,
            },
          },
        },
      })

      -- Python
      vim.lsp.config("pyright", {
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "strict",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
              autoImportCompletions = true,
              inlayHints = {
                variableTypes = true,
                functionReturnTypes = true,
                parameterTypes = true,
                callArgumentNames = true,
              },
            },
          },
        },
      })

      -- TypeScript/JavaScript
      local ts_ls_inlay_hints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      }

      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
        settings = {
          typescript = {
            inlayHints = ts_ls_inlay_hints,
          },
          javascript = {
            inlayHints = ts_ls_inlay_hints,
          },
        },
      })

      -- Go
      vim.lsp.config("gopls", {
        capabilities = capabilities,
        settings = {
          gopls = {
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })

      -- Bash
      vim.lsp.config("bashls", { capabilities = capabilities })

      -- JSON
      vim.lsp.config("jsonls", { capabilities = capabilities })

      -- YAML
      vim.lsp.config("yamlls", { capabilities = capabilities })

      -- HTML
      vim.lsp.config("html", { capabilities = capabilities })

      -- CSS
      vim.lsp.config("cssls", { capabilities = capabilities })

      -- XML
      vim.lsp.config("lemminx", {
        capabilities = capabilities,
        settings = {
          xml = {
            format = {
              enabled = true,
              splitAttributes = false,
              joinCDATALines = false,
              joinCommentLines = false,
              joinContentLines = false,
              spaceBeforeEmptyCloseTag = true,
              preservedNewlines = 2,
            },
            validation = {
              enabled = true,
              schema = {
                enabled = true,
              },
            },
            completion = {
              autoCloseTags = true,
            },
          },
        },
      })

      -- Docker
      vim.lsp.config("dockerls", { capabilities = capabilities })
      vim.lsp.config("docker_compose_language_service", { capabilities = capabilities })

      -- Markdown
      vim.lsp.config("marksman", { capabilities = capabilities })

      -- Enable LSP servers
      vim.lsp.enable("intelephense")
      vim.lsp.enable("phpactor")
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("pyright")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("gopls")
      vim.lsp.enable("bashls")
      vim.lsp.enable("jsonls")
      vim.lsp.enable("yamlls")
      vim.lsp.enable("html")
      vim.lsp.enable("cssls")
      vim.lsp.enable("lemminx")
      vim.lsp.enable("dockerls")
      vim.lsp.enable("docker_compose_language_service")
      vim.lsp.enable("marksman")
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {},
      automatic_installation = false,
    },
  },
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    dependencies = {
      { "neovim/nvim-lspconfig" },
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        dependencies = {
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
          end,
        },
      },
      { "giuxtaposition/blink-cmp-copilot",}
    },
    version = "1.*",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      snippets = {
        preset = "luasnip",
      },

      keymap = {
        preset = "default",

        -- Additional keymaps (optional)
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",

        kind_icons = {
          Text = " ",
          Method = " ",
          Function = " ",
          Constructor = " ",
          Field = " ",
          Variable = " ",
          Class = " ",
          Interface = " ",
          Module = " ",
          Property = " ",
          Unit = " ",
          Value = " ",
          Enum = " ",
          Keyword = " ",
          Snippet = " ",
          Color = " ",
          File = " ",
          Reference = " ",
          Folder = " ",
          EnumMember = " ",
          Constant = " ",
          Struct = " ",
          Event = " ",
          Operator = " ",
          TypeParameter = " ",
        },
      },

      completion = {
        ghost_text = {
          enabled = false,
        },
        documentation = {
          auto_show = true,
        },
        menu = {
          draw = {
            columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
            treesitter = { "lsp" },
          },
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "lazydev", "copilot" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          copilot = {
            name = "copilot",
            module = "blink-cmp-copilot",
            score_offset = 100,
            async = true,
          },
        },
      },

      fuzzy = { implementation = "lua" },

      signature = {
        enabled = true,
        window = {
          show_documentation = true,
        },
      },
    },
    opts_extend = { "sources.default" },
  },
  {
    "VidocqH/lsp-lens.nvim",
    event = "LspAttach",
    opts = {
      enable = true,
      include_declaration = false,
      sections = {
        definition = false,
        references = true,
        implements = true,
      },
    },
  },
}
