-- Fast navigation with leap.nvim
return {
  "ggandor/leap.nvim",
  config = function()
    local leap = require("leap")

    -- Use 's' for forward leap, 'S' for backward leap
    vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)")
    vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")

    -- Use 'gs' for leap in other windows
    vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)")
  end,
}
