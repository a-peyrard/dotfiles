-- Database explorer (DataGrip-like experience)
return {
  {
    "kndndrj/nvim-dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
      require("dbee").install()
    end,
    keys = {
      { "<leader>Db", function() require("dbee").toggle() end, desc = "Toggle Dbee" },
    },
    config = function()
      require("dbee").setup()
    end,
  },
}
