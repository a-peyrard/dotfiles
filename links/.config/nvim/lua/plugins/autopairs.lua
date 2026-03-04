-- Auto-pairs for brackets, quotes, etc.
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    local autopairs = require("nvim-autopairs")
    
    autopairs.setup({
      check_ts = true, -- Use treesitter to check for pair
      ts_config = {
        lua = { "string" }, -- Don't add pairs in lua string treesitter nodes
        javascript = { "template_string" },
        java = false, -- Don't check treesitter on java
      },
      disable_filetype = { "TelescopePrompt", "vim" },
      fast_wrap = {
        map = "<M-e>", -- Alt+e to fast wrap
        chars = { "{", "[", "(", '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "Search",
        highlight_grey = "Comment",
      },
    })

    -- Integration with nvim-cmp (auto-completion)
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    local cmp = require("cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

    -- IntelliJ-style "Complete Statement" (Shift+Enter)
    local semicolon_langs = { "javascript", "typescript", "java", "c", "cpp", "css" }
    vim.keymap.set("i", "<S-CR>", function()
      local line = vim.api.nvim_get_current_line()
      -- Close unclosed brackets
      local suffix = ""
      for _, pair in ipairs({ { "%(", "%)", ")" }, { "%[", "%]", "]" }, { "%{", "%}", "}" } }) do
        local open, close = 0, 0
        for _ in line:gmatch(pair[1]) do open = open + 1 end
        for _ in line:gmatch(pair[2]) do close = close + 1 end
        suffix = suffix .. string.rep(pair[3], open - close)
      end
      -- Add semicolon if needed
      local ft = vim.bo.filetype
      if vim.tbl_contains(semicolon_langs, ft) then
        local trimmed = (line .. suffix):gsub("%s+$", "")
        if not trimmed:match("[;{]$") then
          suffix = suffix .. ";"
        end
      end
      vim.api.nvim_set_current_line(line .. suffix)
      local row = vim.api.nvim_win_get_cursor(0)[1]
      vim.api.nvim_win_set_cursor(0, { row, #(line .. suffix) })
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
    end, { desc = "Complete statement" })
  end,
}
