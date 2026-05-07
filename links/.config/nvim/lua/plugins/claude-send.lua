-- Send prompts to Claude Code in adjacent tmux pane
return {
  dir = vim.fn.stdpath("config") .. "/lua/local/claude-send",
  name = "claude-send",
  virtual = true,
  lazy = false,
  config = function()
    require("claude.send")
  end,
}
