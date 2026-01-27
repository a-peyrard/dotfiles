-- statuscol.nvim - Custom status column layout (JetBrains-style)
-- Layout: [diagnostics/breakpoints] [VCS] [line numbers] [spacer] | code
return {
  "luukvbaal/statuscol.nvim",
  config = function()
    local builtin = require("statuscol.builtin")
    require("statuscol").setup({
      relculright = true,  -- Right-align relative numbers
      segments = {
        -- 1. Diagnostics and DAP breakpoints (far left)
        {
          sign = {
            namespace = { "diagnostic" },
            name = { "Dap" },
            maxwidth = 1,
            auto = false,
          },
          click = "v:lua.ScSa",
        },
        -- 2. VCS changes - thin colored bar (left of numbers)
        {
          sign = {
            name = { "GitSigns", "Signify" },
            maxwidth = 1,
            colwidth = 1,
            auto = false,
          },
          click = "v:lua.ScSa",
        },
        -- 3. Line numbers
        { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
        -- 4. Small spacer before code
        { text = { " " } },
      },
    })
  end,
}
