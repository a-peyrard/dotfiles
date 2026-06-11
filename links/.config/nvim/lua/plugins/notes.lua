-- Inline notes system using vim.diagnostic
-- Works standalone (cwd-based notes) or with review mode (diff-scoped via vim.g.review_diff_id)
-- Displays notes as HINT diagnostics → lsp_lines, trouble, signs, scrollbar all work for free
-- Notes are identified by integer IDs (not line numbers) and tracked via extmarks for edit resilience
return {
  dir = vim.fn.stdpath("config") .. "/lua/local/notes",
  name = "notes",
  virtual = true,
  lazy = false,
  config = function()
    local diag_ns = vim.api.nvim_create_namespace("review_notes")
    local track_ns = vim.api.nvim_create_namespace("review_notes_track")

    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.HINT] = "💬",
        },
      },
    }, diag_ns)

    local function notes_file()
      local id = vim.g.review_diff_id
      if id and id ~= "" then
        return "/tmp/nvc-review-" .. id .. ".md"
      end
      local cwd = vim.fn.getcwd()
      local cwd_key = cwd:gsub("/", "_"):gsub("^_", "")
      return "/tmp/nvc-notes-" .. cwd_key .. ".md"
    end

    local notes_store = {} -- key = integer ID
    local next_id = 0

    local function get_note_line(note)
      if not vim.api.nvim_buf_is_loaded(note.bufnr) then return nil end
      local ok, mark = pcall(vim.api.nvim_buf_get_extmark_by_id, note.bufnr, track_ns, note.extmark_id, {})
      if ok and mark and #mark > 0 then
        return mark[1] + 1
      end
      return nil
    end

    local function flush_notes_to_file()
      local nf = notes_file()
      if vim.tbl_isempty(notes_store) then
        os.remove(nf)
        return
      end

      local f = io.open(nf, "w")
      if not f then return end

      local ids = vim.tbl_keys(notes_store)
      table.sort(ids)
      for _, id in ipairs(ids) do
        local note = notes_store[id]
        local line = get_note_line(note) or "?"
        f:write("## [" .. id .. "] " .. note.abs_path .. ":" .. line .. "\n")
        f:write("```\n" .. note.code_context .. "\n```\n")
        f:write(note.comment .. "\n\n")
      end
      f:close()
    end

    local function refresh_diagnostics(bufnr)
      local diagnostics = {}
      for _, note in pairs(notes_store) do
        if note.bufnr == bufnr then
          local line = get_note_line(note)
          if line then
            table.insert(diagnostics, {
              lnum = line - 1,
              col = 0,
              message = note.comment,
              severity = vim.diagnostic.severity.HINT,
              source = "notes",
            })
          end
        end
      end
      vim.diagnostic.set(diag_ns, bufnr, diagnostics)
    end

    local function refresh_all_diagnostics()
      local seen = {}
      for _, note in pairs(notes_store) do
        if not seen[note.bufnr] and vim.api.nvim_buf_is_loaded(note.bufnr) then
          seen[note.bufnr] = true
          refresh_diagnostics(note.bufnr)
        end
      end
    end

    -- ========================================================================
    -- Add / Edit / Delete notes
    -- ========================================================================

    local function add_note(visual, prefill, edit_id)
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

      vim.api.nvim_set_hl(0, "NotesBorder", { fg = "#e0af68", bg = "NONE", default = true })
      vim.api.nvim_set_hl(0, "NotesTitle", { fg = "#e0af68", bold = true, default = true })
      vim.api.nvim_set_hl(0, "NotesFloat", { bg = "#1a1b26", default = true })

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
        title = " 📝 Note ",
        title_pos = "left",
        footer = " " .. location .. "  C-s save  q close ",
        footer_pos = "left",
      })
      vim.bo[input_buf].buftype = "nofile"
      vim.bo[input_buf].filetype = "markdown"
      vim.wo[input_win].wrap = true
      vim.wo[input_win].linebreak = true
      vim.wo[input_win].winblend = 10
      vim.api.nvim_win_set_option(
        input_win,
        "winhighlight",
        "FloatBorder:NotesBorder,FloatTitle:NotesTitle,FloatFooter:NotesBorder,NormalFloat:NotesFloat"
      )

      if prefill and prefill ~= "" then
        vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, vim.split(prefill, "\n"))
        vim.cmd("startinsert!")
      else
        vim.cmd("startinsert")
      end

      local function save_note()
        local input_lines = vim.api.nvim_buf_get_lines(input_buf, 0, -1, false)
        while #input_lines > 0 and input_lines[#input_lines] == "" do
          table.remove(input_lines)
        end
        local comment = table.concat(input_lines, "\n")
        vim.api.nvim_win_close(input_win, true)
        vim.cmd("stopinsert")
        if comment == "" then return end

        if edit_id and notes_store[edit_id] then
          notes_store[edit_id].comment = comment
          notes_store[edit_id].code_context = code_context
        else
          next_id = next_id + 1
          local extmark_id = vim.api.nvim_buf_set_extmark(bufnr, track_ns, start_line - 1, 0, {})
          notes_store[next_id] = {
            bufnr = bufnr,
            extmark_id = extmark_id,
            abs_path = file,
            rel_path = rel_path,
            comment = comment,
            code_context = code_context,
          }
        end

        refresh_diagnostics(bufnr)
        flush_notes_to_file()
        vim.notify("Note saved: " .. location, vim.log.levels.INFO)
      end

      vim.keymap.set({ "i", "n" }, "<C-s>", save_note, { buffer = input_buf, desc = "Save note" })
      vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(input_win, true)
      end, { buffer = input_buf, desc = "Cancel note" })
    end

    local function find_note_at_cursor()
      local bufnr = vim.fn.bufnr()
      local cur_line = vim.fn.line(".")
      for id, note in pairs(notes_store) do
        if note.bufnr == bufnr then
          local line = get_note_line(note)
          if line == cur_line then
            return id, note
          end
        end
      end
      return nil, nil
    end

    local function edit_note_at_cursor()
      local id, note = find_note_at_cursor()
      if not id then
        vim.notify("No note at this line", vim.log.levels.WARN)
        return
      end
      add_note(false, note.comment, id)
    end

    local function delete_note_at_cursor()
      local id, note = find_note_at_cursor()
      if not id then
        vim.notify("No note at this line", vim.log.levels.WARN)
        return
      end

      vim.api.nvim_buf_del_extmark(note.bufnr, track_ns, note.extmark_id)
      notes_store[id] = nil
      refresh_diagnostics(note.bufnr)
      flush_notes_to_file()
      vim.notify("Note " .. id .. " deleted", vim.log.levels.INFO)
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

      local entries = {}
      for id, note in pairs(notes_store) do
        local line = get_note_line(note)
        if line then
          table.insert(entries, {
            id = id,
            bufnr = note.bufnr,
            lnum = line,
            rel_path = note.rel_path,
            comment = note.comment,
            code_context = note.code_context,
            display = "[" .. id .. "] " .. note.rel_path .. ":" .. line .. " │ " .. note.comment:gsub("\n", " "),
          })
        end
      end

      table.sort(entries, function(a, b)
        if a.bufnr == b.bufnr then return a.lnum < b.lnum end
        return a.rel_path < b.rel_path
      end)

      local title = "Notes"
      if vim.g.review_diff_id and vim.g.review_diff_id ~= "" then
        title = "Review Notes (" .. vim.g.review_diff_id .. ")"
      end

      pickers
        .new({}, {
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
              local preview_lines = {
                "## [" .. note.id .. "] " .. note.rel_path .. ":" .. note.lnum,
                "",
                "```",
              }
              for _, l in ipairs(vim.split(note.code_context, "\n")) do
                table.insert(preview_lines, l)
              end
              table.insert(preview_lines, "```")
              table.insert(preview_lines, "")
              for _, l in ipairs(vim.split(note.comment, "\n")) do
                table.insert(preview_lines, l)
              end
              vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
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
        })
        :find()
    end

    local function clear_notes()
      local nf = notes_file()
      os.remove(nf)
      for _, note in pairs(notes_store) do
        if vim.api.nvim_buf_is_loaded(note.bufnr) then
          pcall(vim.api.nvim_buf_del_extmark, note.bufnr, track_ns, note.extmark_id)
        end
      end
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          vim.diagnostic.reset(diag_ns, buf)
        end
      end
      notes_store = {}
      next_id = 0
      vim.notify("Notes cleared", vim.log.levels.INFO)
    end

    -- ========================================================================
    -- Remove note by ID (for nvc RPC)
    -- ========================================================================

    local function remove_note_by_id(id)
      local note = notes_store[id]
      if not note then
        vim.notify("No note with ID " .. id, vim.log.levels.WARN)
        return false
      end

      if vim.api.nvim_buf_is_loaded(note.bufnr) then
        pcall(vim.api.nvim_buf_del_extmark, note.bufnr, track_ns, note.extmark_id)
        notes_store[id] = nil
        refresh_diagnostics(note.bufnr)
      else
        notes_store[id] = nil
      end

      flush_notes_to_file()
      vim.notify("Note " .. id .. " removed", vim.log.levels.INFO)
      return true
    end

    _G.Notes = {
      clear = clear_notes,
      remove = remove_note_by_id,
    }

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
