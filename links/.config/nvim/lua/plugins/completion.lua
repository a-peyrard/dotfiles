-- Autocompletion configuration
return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
  },
  config = function()
    local cmp = require("cmp")

    -- Subtle completion styling: transparent background, dim border
    vim.api.nvim_set_hl(0, "CmpNormal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#555555", bg = "NONE" })

    cmp.setup({
      sources = {
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" },
      },
      mapping = cmp.mapping.preset.insert({
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
      }),
      window = {
        completion = cmp.config.window.bordered({
          border = "rounded",
          col_offset = -1,
          side_padding = 1,
          winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:PmenuSel",
        }),
        documentation = cmp.config.window.bordered({
          border = "rounded",
          winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder",
          max_width = 60,
          max_height = 15,
        }),
      },
      experimental = {
        ghost_text = false,
      },
    })
  end,
}
