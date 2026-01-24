-- lsp_lines.nvim - Show diagnostics as virtual lines below code
return {
  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  event = "LspAttach",
  config = function()
    local lsp_lines = require("lsp_lines")
    lsp_lines.setup()

    -- Preserve signs config from options.lua
    local signs_config = vim.diagnostic.config().signs

    -- Start with virtual_text enabled, lsp_lines disabled
    vim.diagnostic.config({
      virtual_lines = false,
      signs = signs_config,
    })

    -- Toggle between virtual_text and lsp_lines
    vim.keymap.set("n", "<leader>ul", function()
      local virtual_lines = vim.diagnostic.config().virtual_lines
      if virtual_lines then
        -- Switch to virtual_text mode
        vim.diagnostic.config({
          virtual_lines = false,
          virtual_text = { prefix = "●", spacing = 2 },
          signs = signs_config,
        })
        vim.notify("Diagnostics: virtual_text", vim.log.levels.INFO)
      else
        -- Switch to lsp_lines mode
        vim.diagnostic.config({
          virtual_lines = { only_current_line = true },
          virtual_text = false,
          signs = signs_config,
        })
        vim.notify("Diagnostics: lsp_lines", vim.log.levels.INFO)
      end
    end, { desc = "Toggle diagnostic display (virtual_text/lsp_lines)" })
  end,
}
