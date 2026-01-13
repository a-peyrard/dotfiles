-- Fuzzy completion for command-line mode
return {
  "gelguy/wilder.nvim",
  event = "CmdlineEnter",
  build = ":UpdateRemotePlugins",
  config = function()
    local wilder = require("wilder")
    wilder.setup({ modes = { ":", "/", "?" } })

    wilder.set_option(
      "renderer",
      wilder.popupmenu_renderer(wilder.popupmenu_border_theme({
        highlighter = wilder.basic_highlighter(),
        border = "rounded",
        highlights = {
          border = "Normal",
        },
        left = { " ", wilder.popupmenu_devicons() },
        right = { " ", wilder.popupmenu_scrollbar() },
      }))
    )

    wilder.set_option(
      "pipeline",
      {
        wilder.branch(
          wilder.cmdline_pipeline({
            fuzzy = 1,
          }),
          wilder.search_pipeline()
        ),
      }
    )
  end,
}
