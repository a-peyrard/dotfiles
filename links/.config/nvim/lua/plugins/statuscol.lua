-- statuscol.nvim - Custom status column layout (JetBrains-style)
-- Layout: [diagnostics/breakpoints] [line numbers] [git indicator]
return {
  "luukvbaal/statuscol.nvim",
  config = function()
    local builtin = require("statuscol.builtin")
    require("statuscol").setup({
      relculright = true,  -- Right-align relative numbers
      segments = {
        -- 1. Diagnostics and DAP breakpoints (left side)
        {
          sign = {
            namespace = { "diagnostic" },
            name = { "Dap" },
            maxwidth = 1,
            auto = false,
          },
          click = "v:lua.ScSa",
        },
        -- 2. Line numbers
        { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
        -- 3. Small spacer before VCS indicator
        { text = { " " } },
        -- 4. VCS changes - single segment for both Git and Mercurial
        {
          sign = {
            name = { "GitSigns", "Signify" },
            maxwidth = 1,
            colwidth = 1,
            auto = false,
          },
          click = "v:lua.ScSa",
        },
      },
    })
  end,
}
