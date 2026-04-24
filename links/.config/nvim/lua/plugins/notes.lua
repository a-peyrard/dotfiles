-- Inline notes system using vim.diagnostic
-- Works standalone (cwd-based notes) or with review mode (diff-scoped via vim.g.review_diff_id)
-- Displays notes as HINT diagnostics → lsp_lines, trouble, signs, scrollbar all work for free
return {
  dir = vim.fn.stdpath("config") .. "/lua/plugins",
  name = "notes",
  lazy = false,
  config = function()
    local diag_ns = vim.api.nvim_create_namespace("review_notes")

    -- Configure diagnostics for the notes namespace with custom sign
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.HINT] = "💬",
        },
      },
    }, diag_ns)

    -- Get the notes file path — review mode uses diff ID, otherwise uses cwd
    local function notes_file()
      local id = vim.g.review_diff_id
      if id and id ~= "" then
        return "/tmp/nvc-review-" .. id .. ".md"
      end
      -- Outside review mode: use cwd-based notes file
      local cwd = vim.fn.getcwd()
      local cwd_key = cwd:gsub("/", "_"):gsub("^_", "")
      return "/tmp/nvc-notes-" .. cwd_key .. ".md"
    end

    -- In-memory notes store: key = "bufnr:line" → { comment, location, code_context }
    local notes_store = {}

    local function note_key(bufnr, line)
      return bufnr .. ":" .. line
    end

    -- Flush all notes to file (for Claude to read via `nvc notes`)
    local function flush_notes_to_file()
      local nf = notes_file()
      local f = io.open(nf, "w")
      if not f then return end
      for _, note in pairs(notes_store) do
        f:write("## " .. note.location .. "\n")
        f:write("```\n" .. note.code_context .. "\n```\n")
        f:write(note.comment .. "\n\n")
      end
      f:close()
    end

    -- Refresh diagnostics for a buffer from the notes store
    local function refresh_diagnostics(bufnr)
      local diagnostics = {}
      for key, note in pairs(notes_store) do
        local kb, kl = key:match("^(%d+):(%d+)$")
        if tonumber(kb) == bufnr then
          table.insert(diagnostics, {
            lnum = tonumber(kl) - 1, -- 0-indexed
            col = 0,
            message = note.comment,
            severity = vim.diagnostic.severity.HINT,
            source = "notes",
          })
        end
      end
      vim.diagnostic.set(diag_ns, bufnr, diagnostics)
    end

    -- Refresh diagnostics for all loaded buffers
    local function refresh_all_diagnostics()
      local seen = {}
      for key, _ in pairs(notes_store) do
        local kb = tonumber(key:match("^(%d+):"))
        if kb and not seen[kb] and vim.api.nvim_buf_is_loaded(kb) then
          seen[kb] = true
          refresh_diagnostics(kb)
        end
      end
    end

    -- ========================================================================
    -- Add / Edit / Delete notes
    -- ========================================================================

    local function add_note(visual, prefill)
      local file = vim.fn.expand("%:p")
      local repo_root = vim.fs.root(file, ".hg") or vim.fs.root(file, ".git") or ""
      local rel_path = file
      if repo_root ~= "" then
        rel_path = file:sub(#repo_root + 2)
      end

      local bufnr = vim.fn.bufnr()
      local start_line, end_line
      if visual then
        start_line = vim.fn.line("'<")
        end_line = vim.fn.line("'>")
      else
        start_line = vim.fn.line(".")
        end_line = start_line
      end

      local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      local code_context = table.concat(lines, "\n")

      local location
      if start_line == end_line then
        location = rel_path .. ":" .. start_line
      else
        location = rel_path .. ":" .. start_line .. "-" .. end_line
      end

      -- Floating input at cursor (multi-line capable)
      local input_buf = vim.api.nvim_create_buf(false, true)
      local win_width = math.min(80, vim.api.nvim_win_get_width(0) - 10)
      local input_win = vim.api.nvim_open_win(input_buf, true, {
        relative = "cursor",
        row = 1,
        col = 0,
        width = win_width,
        height = 5,
        style = "minimal",
        border = "rounded",
        title = " 📝 " .. location .. " (C-s save, q close) ",
        title_pos = "left",
      })
      vim.bo[input_buf].buftype = "nofile"
      vim.bo[input_buf].filetype = "markdown"
      vim.wo[input_win].wrap = true
      vim.wo[input_win].linebreak = true

      -- Pre-fill with existing comment if editing
      if prefill and prefill ~= "" then
        vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, vim.split(prefill, "\n"))
        vim.cmd("startinsert!")
      else
        vim.cmd("startinsert")
      end

      -- Save with Ctrl-S (works in both insert and normal mode)
      local function save_note()
        local input_lines = vim.api.nvim_buf_get_lines(input_buf, 0, -1, false)
        -- Trim trailing empty lines
        while #input_lines > 0 and input_lines[#input_lines] == "" do
          table.remove(input_lines)
        end
        local comment = table.concat(input_lines, "\n")
        vim.api.nvim_win_close(input_win, true)
        vim.cmd("stopinsert")
        if comment == "" then return end

        local key = note_key(bufnr, start_line)

        -- Store in memory
        notes_store[key] = {
          comment = comment,
          location = location,
          code_context = code_context,
        }

        -- Update diagnostics and file
        refresh_diagnostics(bufnr)
        flush_notes_to_file()

        vim.notify("Note saved: " .. location, vim.log.levels.INFO)
      end

      vim.keymap.set({ "i", "n" }, "<C-s>", save_note, { buffer = input_buf, desc = "Save note" })
      vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(input_win, true)
      end, { buffer = input_buf, desc = "Cancel note" })
    end

    local function edit_note_at_cursor()
      local key = note_key(vim.fn.bufnr(), vim.fn.line("."))
      local existing = notes_store[key]
      if not existing then
        vim.notify("No note at this line", vim.log.levels.WARN)
        return
      end
      add_note(false, existing.comment)
    end

    local function delete_note_at_cursor()
      local bufnr = vim.fn.bufnr()
      local cur_line = vim.fn.line(".")
      local key = note_key(bufnr, cur_line)

      if not notes_store[key] then
        vim.notify("No note at this line", vim.log.levels.WARN)
        return
      end

      notes_store[key] = nil
      refresh_diagnostics(bufnr)
      flush_notes_to_file()

      vim.notify("Note deleted at line " .. cur_line, vim.log.levels.INFO)
    end

    local function list_notes()
      if vim.tbl_isempty(notes_store) then
        vim.notify("No notes yet", vim.log.levels.INFO)
        return
      end

      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local conf = require("telescope.config").values
      local previewers = require("telescope.previewers")

      -- Build entries from notes store
      local entries = {}
      for key, note in pairs(notes_store) do
        local bufnr, line = key:match("^(%d+):(%d+)$")
        table.insert(entries, {
          bufnr = tonumber(bufnr),
          lnum = tonumber(line),
          location = note.location,
          comment = note.comment,
          code_context = note.code_context,
          display = note.location .. " │ " .. note.comment:gsub("\n", " "),
        })
      end

      table.sort(entries, function(a, b)
        if a.bufnr == b.bufnr then return a.lnum < b.lnum end
        return a.location < b.location
      end)

      local title = "Notes"
      if vim.g.review_diff_id and vim.g.review_diff_id ~= "" then
        title = "Review Notes (" .. vim.g.review_diff_id .. ")"
      end

      pickers.new({}, {
        prompt_title = title,
        finder = finders.new_table({
          results = entries,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.display,
              ordinal = entry.display,
              bufnr = entry.bufnr,
              lnum = entry.lnum,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = previewers.new_buffer_previewer({
          title = "Note",
          define_preview = function(self, entry)
            local note = entry.value
            local lines = {
              "## " .. note.location,
              "",
              "```",
            }
            for _, l in ipairs(vim.split(note.code_context, "\n")) do
              table.insert(lines, l)
            end
            table.insert(lines, "```")
            table.insert(lines, "")
            for _, l in ipairs(vim.split(note.comment, "\n")) do
              table.insert(lines, l)
            end
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            vim.bo[self.state.bufnr].filetype = "markdown"
          end,
        }),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              vim.api.nvim_set_current_buf(selection.bufnr)
              vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
              vim.cmd("normal! zz")
            end
          end)
          return true
        end,
      }):find()
    end

    local function clear_notes()
      local nf = notes_file()
      os.remove(nf)
      -- Clear diagnostics in all buffers
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          vim.diagnostic.reset(diag_ns, buf)
        end
      end
      notes_store = {}
      vim.notify("Notes cleared", vim.log.levels.INFO)
    end

    -- ========================================================================
    -- Keybindings
    -- ========================================================================

    vim.keymap.set("n", "<leader>nc", function() add_note(false) end, { desc = "Add note" })
    vim.keymap.set("v", "<leader>nc", function()
      vim.cmd("normal! ")
      add_note(true)
    end, { desc = "Add note (selection)" })
    vim.keymap.set("n", "<leader>nl", list_notes, { desc = "List notes" })
    vim.keymap.set("n", "<leader>nd", delete_note_at_cursor, { desc = "Delete note at cursor" })
    vim.keymap.set("n", "<leader>ne", edit_note_at_cursor, { desc = "Edit note at cursor" })
    vim.keymap.set("n", "<leader>nx", clear_notes, { desc = "Clear all notes" })
  end,
}
