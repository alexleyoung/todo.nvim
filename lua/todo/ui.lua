local M = {}

local config = require("todo").options
local storage = require("todo.storage")
local utils = require("todo.utils")

local context = {
  menu_buf = nil,
  menu_win = nil,
  curr_line = 1,
  selected_list = nil,
  list_buf = nil,
  list_win = nil,
  curr_line_todo = 1,
  selected_todo = nil,
  last_opened = nil,
}

--- HELPER FUNCTIONS
--- Save in-memory todos to file and close window
local save_quit = function(win)
  storage.save_data(storage.lists)
  vim.api.nvim_win_close(win or 0, true)
end

--- Window closing logic
local close_menu = function()
  save_quit(context.menu_win)
  context.last_opened = nil
end

local close_prompt = function()
  vim.api.nvim_win_close(0, true)
  vim.cmd("stopinsert")
end

local close_list = function()
  save_quit(context.list_win)
  vim.api.nvim_set_current_win(context.menu_win)
  context.last_opened = nil
end

--- Render lists
local render_lists = function()
  if #storage.lists == 0 then
    vim.api.nvim_buf_set_lines(context.menu_buf, 0 - 1, -1, false, { "    " })
    return
  end

  for i, list in ipairs(storage.lists) do
    vim.api.nvim_buf_set_lines(context.menu_buf, i - 1, -1, false, { "  - " .. list.name })
  end

  vim.api.nvim_win_set_cursor(context.menu_win, { context.curr_line, 0 })
end

--- Render todos
local render_todos = function()
  if #context.selected_list.todos == 0 then
    vim.api.nvim_buf_set_lines(context.list_buf, 0 - 1, -1, false, { "    " })
    return
  end

  for i, todo in ipairs(context.selected_list.todos) do
    local indent = todo.completed and "   ■ " or "   □ "
    vim.api.nvim_buf_set_lines(context.list_buf, i - 1, -1, false, { indent .. todo.content })
  end

  vim.api.nvim_win_set_cursor(context.list_win, { context.curr_line_todo, 0 })
end

--- UI FUNCTIONS
--- Open Todo UI
M.open = function()
  storage.load_data()

  if context.menu_win and vim.api.nvim_win_is_valid(context.menu_win) then
    vim.api.nvim_set_current_win(context.menu_win)
  else
    context.menu_buf, context.menu_win = utils.open_scratch_window(config.window, close_menu)
    vim.wo[context.menu_win].cursorline = true
  end

  context.selected_list = storage.lists[context.curr_line]

  render_lists()

  --- keymaps
  -- functions
  vim.keymap.set("n", "j", function()
    if context.curr_line < #storage.lists then
      context.curr_line = context.curr_line + 1
      vim.api.nvim_win_set_cursor(context.menu_win, { context.curr_line, 0 })
      context.selected_list = storage.lists[context.curr_line]
    end
  end, { buffer = context.menu_buf })
  vim.keymap.set("n", "k", function()
    if context.curr_line > 1 then
      context.curr_line = context.curr_line - 1
      vim.api.nvim_win_set_cursor(context.menu_win, { context.curr_line, 0 })
      context.selected_list = storage.lists[context.curr_line]
    end
  end, { buffer = context.menu_buf })
  vim.keymap.set("v", "j", function()
    if context.curr_line < #storage.lists then
      context.curr_line = context.curr_line + 1
      vim.api.nvim_win_set_cursor(context.menu_win, { context.curr_line, 0 })
      context.selected_list = storage.lists[context.curr_line]
    end
  end, { buffer = context.menu_buf })
  vim.keymap.set("v", "k", function()
    if context.curr_line > 1 then
      context.curr_line = context.curr_line - 1
      vim.api.nvim_win_set_cursor(context.menu_win, { context.curr_line, 0 })
      context.selected_list = storage.lists[context.curr_line]
    end
  end, { buffer = context.menu_buf })
  vim.keymap.set("n", "a", M.create_list, { buffer = context.menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "d", M.delete_list, { buffer = context.menu_buf, noremap = true, silent = true })
  vim.keymap.set("v", "d", M.delete_multiple_lists, { buffer = context.menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "r", M.rename_list, { buffer = context.menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "<CR>", M.open_list, { buffer = context.menu_buf, noremap = true, silent = true })

  -- quit
  vim.keymap.set("n", "q", close_menu, { buffer = context.menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "Q", close_menu, { buffer = context.menu_buf, noremap = true, silent = true })

  -- disable non-vertical navigation
  utils.disable_navigation_keys(context.menu_buf)

  if context.last_opened then
    context.selected_list = context.last_opened
    M.open_list()
  end
end

-- Creates new Todo List
M.create_list = function()
  local name = ""

  local buf, _ = utils.open_scratch_window(utils.get_prompt_win_opts({ title = "Enter list name:" }), close_prompt)
  vim.cmd("startinsert")

  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function()
      name = vim.api.nvim_get_current_line()
    end,
  })

  vim.keymap.set("i", "<CR>", function()
    if not storage.create_list(name) then
      print("Failed to create list...")
      return
    end

    -- close window
    close_prompt()

    -- move cursor to new list
    context.curr_line = #storage.lists
    context.selected_list = storage.lists[context.curr_line]

    -- force rerender
    render_lists()
  end, { buffer = buf, noremap = true, silent = true })
end

--- Deletes selected list
M.delete_list = function()
  if not context.selected_list then
    return
  end

  local buf, _ = utils.open_scratch_window(utils.get_prompt_win_opts(), close_prompt)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Delete list '" .. context.selected_list.name .. "'? y/n" })

  vim.keymap.set("n", "y", function()
    if not storage.delete_list_idx(context.curr_line) then
      print("Failed to delete")
    else
      -- force rerender
      context.curr_line = context.curr_line - 1
      if context.curr_line < 1 then
        context.curr_line = 1
      end
      context.selected_list = storage.lists[context.curr_line]
      render_lists()
      save_quit()
    end
  end, { buffer = buf, noremap = true, silent = true })

  vim.keymap.set("n", "n", close_prompt, { buffer = buf, noremap = true, silent = true })
end

--- Deletes multiple selected lists
M.delete_multiple_lists = function()
  if not context.selected_list then
    return
  end

  -- get lines
  local startl = vim.fn.line("v")
  local endl = vim.fn.line(".")
  if endl < startl then
    startl, endl = endl, startl
  end

  local buf, _ = utils.open_scratch_window(utils.get_prompt_win_opts(), close_prompt)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Delete selected lists?" })

  vim.keymap.set("n", "y", function()
    -- delete lists in range
    for i = endl, startl, -1 do
      if not storage.delete_list_idx(i) then
        print("Failed to delete")
        return
      end
    end
    -- force rerender
    context.curr_line = startl - 1
    if context.curr_line < 1 then
      context.curr_line = 1
    end
    context.selected_list = storage.lists[context.curr_line]
    render_lists()
    save_quit()
  end, { buffer = buf, noremap = true, silent = true })

  vim.keymap.set("n", "n", close_prompt, { buffer = buf, noremap = true, silent = true })
end

--- Rename selected list
M.rename_list = function()
  if not context.selected_list then
    return
  end

  local buf, win = utils.open_scratch_window(
    utils.get_prompt_win_opts({ title = "Enter new name for list '" .. context.selected_list.name .. "':" }),
    close_prompt
  )
  vim.cmd("startinsert!")

  local name = context.selected_list.name
  vim.api.nvim_buf_set_lines(buf, 0, 1, false, { name })
  vim.api.nvim_win_set_cursor(win, { 1, string.len(name) })

  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function()
      name = vim.api.nvim_get_current_line()
    end,
  })

  vim.keymap.set("i", "<CR>", function()
    if not storage.rename_list_idx(context.curr_line, name) then
      print("Failed to create list...")
      return
    end

    -- force rerender
    render_lists()

    close_prompt()
  end, { buffer = buf, noremap = true, silent = true })
end

--- Open selected list
M.open_list = function()
  local opts = {}
  for k, v in pairs(config.window) do
    opts[k] = v
  end
  opts["title"] = " " .. context.selected_list.name .. " "

  context.list_buf, context.list_win = utils.open_scratch_window(opts, close_list)
  vim.wo[context.list_win].cursorline = true
  context.curr_line_todo = 1
  context.selected_todo = context.selected_list.todos[context.curr_line_todo]
  context.last_opened = context.selected_list
  vim.api.nvim_win_set_cursor(context.list_win, { context.curr_line_todo, 0 })

  render_todos()

  --- Keymaps
  -- functions
  vim.keymap.set("n", "j", function()
    if context.curr_line_todo < #context.selected_list.todos then
      context.curr_line_todo = context.curr_line_todo + 1
      vim.api.nvim_win_set_cursor(context.list_win, { context.curr_line_todo, 0 })
      context.selected_todo = context.selected_list.todos[context.curr_line_todo]
    end
  end, { buffer = context.list_buf })
  vim.keymap.set("n", "k", function()
    if context.curr_line_todo > 1 then
      context.curr_line_todo = context.curr_line_todo - 1
      vim.api.nvim_win_set_cursor(context.list_win, { context.curr_line_todo, 0 })
      context.selected_todo = context.selected_list.todos[context.curr_line_todo]
    end
  end, { buffer = context.list_buf })
  vim.keymap.set("v", "j", function()
    if context.curr_line_todo < #context.selected_list.todos then
      context.curr_line_todo = context.curr_line_todo + 1
      vim.api.nvim_win_set_cursor(context.list_win, { context.curr_line_todo, 0 })
      context.selected_todo = context.selected_list.todos[context.curr_line_todo]
    end
  end, { buffer = context.list_buf })
  vim.keymap.set("v", "k", function()
    if context.curr_line_todo > 1 then
      context.curr_line_todo = context.curr_line_todo - 1
      vim.api.nvim_win_set_cursor(context.list_win, { context.curr_line_todo, 0 })
      context.selected_todo = context.selected_list.todos[context.curr_line_todo]
    end
  end, { buffer = context.list_buf })
  vim.keymap.set("n", "a", M.create_todo, { buffer = context.list_buf, noremap = true, silent = true })
  vim.keymap.set("n", "d", M.delete_todo, { buffer = context.list_buf, noremap = true, silent = true })
  vim.keymap.set("v", "d", M.delete_multiple_todos, { buffer = context.list_buf, noremap = true, silent = true })
  vim.keymap.set("n", "r", M.edit_todo_content, { buffer = context.list_buf, noremap = true, silent = true })
  vim.keymap.set("n", "<CR>", M.complete_todo, { buffer = context.list_buf, noremap = true, silent = true })

  -- quit
  vim.keymap.set("n", "q", close_list, { buffer = context.list_buf, noremap = true, silent = true })
  vim.keymap.set("n", "Q", function()
    vim.fn.execute(":q!")
    save_quit(context.menu_win)
  end, { buffer = context.list_buf, noremap = true, silent = true })

  -- disable non-vertical navigation
  utils.disable_navigation_keys(context.list_buf)
end

--- Create todo in selected list
M.create_todo = function()
  local content = ""

  local buf, _ = utils.open_scratch_window(utils.get_prompt_win_opts({ title = "Type todo:" }), close_prompt)
  vim.cmd("startinsert")

  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function()
      content = vim.api.nvim_get_current_line()
    end,
  })

  vim.keymap.set("i", "<CR>", function()
    if not storage.create_todo(context.selected_list, content) then
      print("Failed to create todo...")
      return
    end

    -- force rerender
    render_todos()

    close_prompt()
  end, { buffer = buf, noremap = true, silent = true })
end

--- Rename selected todo
M.edit_todo_content = function()
  if not context.selected_todo then
    return
  end

  local buf, win =
    utils.open_scratch_window(utils.get_prompt_win_opts({ title = "Enter new todo content:" }), close_prompt)

  local new_content = context.selected_todo.content
  vim.api.nvim_buf_set_lines(buf, 0, 1, false, { new_content })
  vim.api.nvim_win_set_cursor(win, { 1, string.len(new_content) })
  vim.cmd("startinsert!")

  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function()
      new_content = vim.api.nvim_get_current_line()
    end,
  })

  vim.keymap.set("i", "<CR>", function()
    if new_content == context.selected_todo.content then
      return
    end

    if not storage.edit_todo_content(context.selected_todo, new_content) then
      print("Failed to edit todo...")
      return
    end

    -- force rerender
    render_todos()

    close_prompt()
  end, { buffer = buf, noremap = true, silent = true })
end

--- Check/uncheck selected todo
M.complete_todo = function()
  if not context.selected_list or not context.selected_todo then
    return
  end

  storage.toggle_completed(context.selected_list, context.selected_todo)
  context.selected_todo = context.selected_list.todos[context.curr_line_todo]
  render_todos()
end

--- Delete selected todo
M.delete_todo = function()
  if not context.selected_todo then
    return
  end

  local buf, win = utils.open_scratch_window(utils.get_prompt_win_opts(), close_prompt)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Delete todo? y/n" })

  vim.keymap.set("n", "y", function()
    if not storage.delete_todo(context.selected_list.todos, context.curr_line_todo) then
      print("Failed to delete")
      vim.api.nvim_win_close(win, true)
    else
      context.curr_line_todo = context.curr_line_todo - 1
      if context.curr_line_todo < 1 then
        context.curr_line_todo = 1
      end
      context.selected_todo = context.selected_list.todos[context.curr_line_todo]
      -- force rerender
      render_todos()
      save_quit(win)
    end
  end, { buffer = buf, noremap = true, silent = true })

  vim.keymap.set("n", "n", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true, silent = true })
end

--- Deletes multiple selected lists
M.delete_multiple_todos = function()
  if not context.selected_list then
    return
  end

  -- get lines
  local startl = vim.fn.line("v")
  local endl = vim.fn.line(".")
  if endl < startl then
    startl, endl = endl, startl
  end

  local buf, _ = utils.open_scratch_window(utils.get_prompt_win_opts(), close_prompt)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Delete selected todos?" })

  vim.keymap.set("n", "y", function()
    -- delete lists in range
    for i = endl, startl, -1 do
      if not storage.delete_todo(context.selected_list.todos, i) then
        print("Failed to delete")
        return
      end
    end
    -- force rerender
    context.curr_line_todo = startl - 1
    if context.curr_line_todo < 1 then
      context.curr_line_todo = 1
    end
    context.selected_todo = context.selected_list.todos[context.curr_line_todo]
    render_todos()
    save_quit()
  end, { buffer = buf, noremap = true, silent = true })

  vim.keymap.set("n", "n", close_prompt, { buffer = buf, noremap = true, silent = true })
end

return M
