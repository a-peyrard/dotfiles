-- LSP Configuration for Rust, Python, and Lua
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Suppress nvim-lspconfig deprecation warnings for Neovim 0.11+
      -- We'll migrate to vim.lsp.config when the new API is more stable
      local notify = vim.notify
      vim.notify = function(msg, ...)
        if msg:match("lspconfig") or msg:match("deprecated") or msg:match("framework") then
          return
        end
        notify(msg, ...)
      end

      -- Global LSP border configuration - override the default open_floating_preview
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts)
        opts = opts or {}
        opts.border = opts.border or "rounded"
        opts.focusable = opts.focusable == nil and true or opts.focusable  -- Make focusable by default
        return orig_util_open_floating_preview(contents, syntax, opts)
      end

      -- Setup Mason
      require("mason").setup()

      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      -- Enhanced capabilities for autocompletion
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Common on_attach function for all LSP servers
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr }

        -- LSP keybindings
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>f', function()
          require("conform").format({ async = true, lsp_fallback = true })
        end, opts)

        -- Diagnostic navigation
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts)
      end

      -- Setup mason-lspconfig
      local mason_lspconfig = require("mason-lspconfig")

      mason_lspconfig.setup({
        ensure_installed = {
          "rust_analyzer", -- Rust
          "pyright",       -- Python
          "lua_ls",        -- Lua
        },
        -- IMPORTANT: Disable automatic_enable (Neovim 0.11+)
        -- We want to use lspconfig.setup() with our on_attach, not vim.lsp.enable()
        automatic_enable = false,
      })

      -- Manually setup each installed server with our on_attach callback
      local installed_servers = mason_lspconfig.get_installed_servers()

      for _, server_name in ipairs(installed_servers) do

        if server_name == "lua_ls" then
          -- Custom setup for lua_ls
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim" },
                },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                  checkThirdParty = false,
                },
                telemetry = {
                  enable = false,
                },
              },
            },
          })
        else
          -- Default setup for all other servers
          lspconfig[server_name].setup({
            capabilities = capabilities,
            on_attach = on_attach,
          })
        end
      end

      -- Restore original notify after all lspconfig setup is complete
      vim.notify = notify
    end,
  },
}
