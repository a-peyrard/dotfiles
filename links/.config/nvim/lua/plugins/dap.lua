-- DAP (Debug Adapter Protocol) configuration
return {
  -- Core DAP plugin
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI for DAP
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio", -- Required by nvim-dap-ui
      -- Virtual text showing variable values
      "theHamsta/nvim-dap-virtual-text",
      -- Mason integration for auto-installing debug adapters
      "jay-babu/mason-nvim-dap.nvim",
      -- Go debugging integration (required by neotest-golang)
      "leoluz/nvim-dap-go",
      -- Persist breakpoints across sessions
      "ldelossa/nvim-dap-projects",
      -- Automatic breakpoint persistence
      "Weissle/persistent-breakpoints.nvim",
    },
    -- Load plugin when these keys are pressed AND map them
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
      { "<leader>db", function() require("persistent-breakpoints.api").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
      { "<leader>dB", function() require("persistent-breakpoints.api").set_conditional_breakpoint() end, desc = "Debug: Conditional Breakpoint" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "Debug: Open REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run Last" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Debug: Terminate" },
      { "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Debug: Hover Variables", mode = { "n", "v" } },
      { "<leader>dp", function() require("dap.ui.widgets").preview() end, desc = "Debug: Preview", mode = { "n", "v" } },
      { "<leader>dL", function() require("dap").list_breakpoints() end, desc = "Debug: List Breakpoints" },
      { "<leader>dC", function() require("persistent-breakpoints.api").clear_all_breakpoints() end, desc = "Debug: Clear All Breakpoints" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup mason-nvim-dap for automatic adapter installation
      require("mason-nvim-dap").setup({
        ensure_installed = { "python", "codelldb", "delve" },
        automatic_installation = true,
        handlers = {}, -- Uses default handlers for installed adapters
      })

      -- Setup nvim-dap-go (required by neotest-golang)
      require("dap-go").setup()

      -- Setup nvim-dap-projects for project-specific DAP configs
      require("nvim-dap-projects").search_project_config()

      -- Setup persistent-breakpoints for breakpoint persistence
      require("persistent-breakpoints").setup({
        save_dir = vim.fn.stdpath("data") .. "/breakpoints",
        load_breakpoints_event = { "BufReadPost" },
        perf_record = false,
      })

      -- Explicit codelldb adapter configuration
      local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
      if mason_registry_ok and mason_registry.is_installed("codelldb") then
        local mason_path = vim.fn.stdpath("data") .. "/mason"
        local codelldb_path = mason_path .. "/packages/codelldb/extension/adapter/codelldb"

        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = {
            command = codelldb_path,
            args = { "--port", "${port}" },
          },
        }
      end

      -- Explicit delve adapter configuration
      if mason_registry_ok and mason_registry.is_installed("delve") then
        dap.adapters.delve = {
          type = "server",
          port = "${port}",
          executable = {
            command = "dlv",
            args = { "dap", "-l", "127.0.0.1:${port}" },
          },
        }
      end

      -- Setup DAP UI
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
          },
        },
        floating = {
          border = "rounded",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
      })

      -- Setup virtual text
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        virt_text_pos = "eol",
      })

      -- Auto-open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Python configuration
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            -- Try to detect virtual environment
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then
              return venv .. "/bin/python"
            end
            return "/usr/bin/python3"
          end,
        },
        {
          type = "python",
          request = "launch",
          name = "Launch file with arguments",
          program = "${file}",
          args = function()
            local args_string = vim.fn.input("Arguments: ")
            return vim.split(args_string, " +")
          end,
          pythonPath = function()
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then
              return venv .. "/bin/python"
            end
            return "/usr/bin/python3"
          end,
        },
      }

      -- Rust configuration
      dap.configurations.rust = {
        {
          name = "Launch executable",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
        {
          name = "Debug test (auto-detect)",
          type = "codelldb",
          request = "launch",
          program = function()
            -- Get current file name without extension (e.g., "01" from "01.rs")
            local filename = vim.fn.expand("%:t:r")
            -- Find the most recent test binary matching this file
            local handle = io.popen("ls -t " .. vim.fn.getcwd() .. "/target/debug/deps/" .. filename .. "-* 2>/dev/null | head -1")
            local result = handle:read("*a")
            handle:close()
            result = result:gsub("%s+$", "") -- trim whitespace

            if result == "" then
              vim.notify("No test binary found. Run 'cargo build --tests' first.", vim.log.levels.ERROR)
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/deps/", "file")
            end

            return result
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
      }

      -- Go configuration
      dap.configurations.go = {
        {
          type = "delve",
          name = "Debug",
          request = "launch",
          program = "${file}",
        },
        {
          type = "delve",
          name = "Debug test",
          request = "launch",
          mode = "test",
          program = "${file}",
        },
        {
          type = "delve",
          name = "Debug package",
          request = "launch",
          program = "${fileDirname}",
        },
      }

      -- Register debug prefix with which-key
      local ok, which_key = pcall(require, "which-key")
      if ok then
        which_key.add({
          { "<leader>d", group = "Debug" },
        })
      end

      -- Custom breakpoint colors
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#8B0000" }) -- Dark red
      vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#DC143C" }) -- Crimson (brighter red for conditional)
      vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#FFA500" }) -- Orange
      vim.api.nvim_set_hl(0, "DapStopped", { fg = "#FFD700", bg = "#3E3E00" }) -- Gold with dark yellow background
      vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#808080" }) -- Gray

      -- Breakpoint signs
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "DapStopped", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })
    end,
  },
}
