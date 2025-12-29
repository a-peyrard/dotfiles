-- Treesitter configuration for syntax highlighting
-- NOTE: nvim-treesitter main branch has a new API that doesn't use .configs
-- Parsers are installed via :TSInstall command, highlighting is automatic
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  priority = 100,
  config = function()
    -- No setup needed with new API
    -- Parsers will be installed on demand or via :TSInstall rust python lua vim vimdoc toml json yaml markdown

    -- Enable highlighting automatically for all filetypes
    vim.api.nvim_create_autocmd('FileType', {
      pattern = '*',
      callback = function()
        pcall(vim.treesitter.start)  -- Use pcall in case parser not installed
      end,
    })
  end,
}
