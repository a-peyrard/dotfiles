-- Conflict resolution UI (works with Git and Mercurial)
-- Detects conflict markers and provides keybindings to resolve them
return {
  "akinsho/git-conflict.nvim",
  version = "*",
  event = "BufReadPre",
  config = function()
    require("git-conflict").setup({
      default_mappings = true,  -- enable default mappings: co, ct, cb, c0, ]x, [x
      default_commands = true,
      disable_diagnostics = true,
      highlights = {
        incoming = "DiffAdd",
        current = "DiffText",
      },
    })
  end,
}
