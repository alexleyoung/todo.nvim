local M = {}

local config = require("todo.config")
local storage = require("todo.storage")
require("todo.utils")

local menu_buf
local menu_win
local curr_line = 1
local selected_list

local list_buf
local list_win
local curr_line_todo = 1
local selected_todo

--- Save in-memory todos to file and close window
local save_quit = function(win)
  storage.save_data(storage.lists)
  vim.api.nvim_win_close(win or 0, true)
end

--- Render lists
local render_lists = function()
  if #storage.lists == 0 then
    return
  end

  for i, list in ipairs(storage.lists) do
    vim.api.nvim_buf_set_lines(menu_buf, i - 1, -1, false, { "  - " .. list.name })
  end

  vim.api.nvim_win_set_cursor(menu_win, { curr_line, 0 })
end

--- Render todos
local render_todos = function()
  if #selected_list.todos == 0 then
    return
  end

  for i, todo in ipairs(selected_list.todos) do
    local indent = todo.completed and "   ■ " or "   □ "
    vim.api.nvim_buf_set_lines(list_buf, i - 1, -1, false, { indent .. todo.content })
  end

  vim.api.nvim_win_set_cursor(list_win, { curr_line_todo, 0 })
end

--- Open Todo UI
M.open = function()
  menu_buf, menu_win = Open_Scratch_Window(config.window)
  vim.wo[menu_win].cursorline = true
  selected_list = storage.lists[curr_line]

  render_lists()

  --- keymaps
  -- functions
  vim.keymap.set("n", "a", M.create_list, { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "d", M.delete_list, { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "r", M.rename_list, { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "<CR>", M.open_list, { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "j", function()
    if curr_line < #storage.lists then
      curr_line = curr_line + 1
      vim.api.nvim_win_set_cursor(menu_win, { curr_line, 0 })
      selected_list = storage.lists[curr_line]
    end
  end, { buffer = menu_buf })
  vim.keymap.set("n", "k", function()
    if curr_line > 1 then
      curr_line = curr_line - 1
      vim.api.nvim_win_set_cursor(menu_win, { curr_line, 0 })
      selected_list = storage.lists[curr_line]
    end
  end, { buffer = menu_buf })

  -- quit
  vim.keymap.set("n", "q", save_quit, { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "Q", function()
    save_quit()
    vim.fn.execute(":q!")
  end, { buffer = menu_buf, noremap = true, silent = true })

  -- disable non-vertical navigation
  Disable_Navigation_Keys(menu_buf)
end

-- Creates new Todo List
M.create_list = function()
  local opts = {
    relative = "cursor",
    width = config.window.width - 2,
    height = 1,
    row = 0,
    col = 0,
    border = "single",
    style = "minimal",
    title = "Enter list name:",
  }

  local name = ""

  local buf, win = Open_Scratch_Window(opts)
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
    vim.api.nvim_win_close(win, true)
    vim.cmd("stopinsert")

    -- move cursor to new list
    curr_line = #storage.lists
    selected_list = storage.lists[curr_line]

    -- force rerender
    render_lists()
  end, { buffer = buf, noremap = true, silent = true })
end

--- Deletes selected list
M.delete_list = function()
  if not selected_list then
    return
  end

  local opts = {
    relative = "cursor",
    width = config.window.width - 2,
    height = 1,
    row = 0,
    col = 0,
    border = "single",
    style = "minimal",
  }

  local buf, win = Open_Scratch_Window(opts)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Delete list '" .. selected_list.name .. "'? y/n" })

  vim.keymap.set("n", "y", function()
    if not storage.delete_list_idx(curr_line) then
      print("Failed to delete")
    else
      -- force rerender
      curr_line = curr_line - 1
      selected_list = storage.lists[curr_line]
      render_lists()
    end
    save_quit()
  end, { buffer = buf, noremap = true, silent = true })

  vim.keymap.set("n", "n", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true, silent = true })
end

--- Rename selected list
M.rename_list = function()
  if not selected_list then
    return
  end

  local opts = {
    relative = "cursor",
    width = config.window.width - 2,
    height = 1,
    row = 0,
    col = 0,
    border = "single",
    style = "minimal",
    title = "Enter new name for list '" .. selected_list.name .. "':",
  }

  local buf, win = Open_Scratch_Window(opts)
  vim.cmd("startinsert!")

  local name = selected_list.name
  vim.api.nvim_buf_set_lines(buf, 0, 1, false, { name })
  vim.api.nvim_win_set_cursor(win, { 1, string.len(name) })

  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function()
      name = vim.api.nvim_get_current_line()
    end,
  })

  vim.keymap.set("i", "<CR>", function()
    if not storage.rename_list_idx(curr_line, name) then
      print("Failed to create list...")
      return
    end

    -- force rerender
    render_lists()

    vim.api.nvim_win_close(win, true)
    vim.cmd("stopinsert")
  end, { buffer = buf, noremap = true, silent = true })
end

--- Open selected list
M.open_list = function()
  local opts = {}
  for k, v in pairs(config.window) do
    opts[k] = v
  end
  opts["title"] = " " .. selected_list.name .. " "

  list_buf, list_win = Open_Scratch_Window(opts)
  vim.wo[list_win].cursorline = true
  curr_line_todo = 1
  selected_todo = selected_list.todos[curr_line_todo]
  vim.api.nvim_win_set_cursor(list_win, { curr_line_todo, 0 })

  render_todos()

  --- Keymaps
  -- functions
  vim.keymap.set("n", "a", M.create_todo, { buffer = list_buf, noremap = true, silent = true })
  vim.keymap.set("n", "d", M.delete_todo, { buffer = list_buf, noremap = true, silent = true })
  vim.keymap.set("n", "r", M.edit_todo_content, { buffer = list_buf, noremap = true, silent = true })
  vim.keymap.set("n", "j", function()
    if curr_line_todo < #selected_list.todos then
      curr_line_todo = curr_line_todo + 1
      vim.api.nvim_win_set_cursor(list_win, { curr_line_todo, 0 })
      print(curr_line_todo)
      selected_todo = selected_list.todos[curr_line_todo]
    end
  end, { buffer = list_buf })
  vim.keymap.set("n", "k", function()
    if curr_line_todo > 1 then
      curr_line_todo = curr_line_todo - 1
      vim.api.nvim_win_set_cursor(list_win, { curr_line_todo, 0 })
      selected_todo = selected_list.todos[curr_line_todo]
    end
  end, { buffer = list_buf })
  vim.keymap.set("n", "<CR>", M.complete_todo, { buffer = list_buf, noremap = true, silent = true })

  -- quit
  vim.keymap.set("n", "q", function()
    save_quit()
    vim.api.nvim_win_set_cursor(menu_win, { curr_line, 0 })
  end, { buffer = list_buf, noremap = true, silent = true })
  vim.keymap.set("n", "Q", function()
    save_quit()
    vim.fn.execute(":q!")
  end, { buffer = list_buf, noremap = true, silent = true })

  -- disable non-vertical navigation
  Disable_Navigation_Keys(list_buf)
end

--- Create todo in selected list
M.create_todo = function()
  local opts = {
    relative = "cursor",
    width = config.window.width - 2,
    height = 1,
    row = 0,
    col = 0,
    border = "single",
    style = "minimal",
    title = "Type todo:",
  }

  local content = ""

  local buf, win = Open_Scratch_Window(opts)
  vim.cmd("startinsert")

  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function()
      content = vim.api.nvim_get_current_line()
    end,
  })

  vim.keymap.set("i", "<CR>", function()
    if not storage.create_todo(selected_list, content) then
      print("Failed to create todo...")
      return
    end

    save_quit(win)
    vim.cmd("stopinsert")

    curr_line_todo = #selected_list.todos
    selected_todo = selected_list.todos[curr_line_todo]

    -- force rerender
    render_todos()
  end, { buffer = buf, noremap = true, silent = true })
end

--- Rename selected todo
M.edit_todo_content = function(new_content)
  if not selected_todo then
    return
  end

  local opts = {
    relative = "cursor",
    width = config.window.width - 2,
    height = 1,
    row = 0,
    col = 0,
    border = "single",
    style = "minimal",
    title = "Enter new todo content:",
  }

  local buf, win = Open_Scratch_Window(opts)

  local content = selected_todo.content
  vim.api.nvim_buf_set_lines(buf, 0, 1, false, { content })
  vim.api.nvim_win_set_cursor(win, { 1, string.len(content) })
  vim.cmd("startinsert!")

  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function()
      content = vim.api.nvim_get_current_line()
    end,
  })

  vim.keymap.set("i", "<CR>", function()
    if content == selected_todo.content then
      return
    end

    if not storage.edit_todo_content(selected_todo, new_content) then
      print("Failed to edit todo...")
      return
    end

    -- force rerender
    render_lists()

    vim.api.nvim_win_close(win, true)
    vim.cmd("stopinsert")
  end, { buffer = buf, noremap = true, silent = true })
end

--- Check/uncheck selected todo
M.complete_todo = function()
  if not selected_todo then
    return
  end

  storage.toggle_completed(selected_todo)
  render_todos()
end

--- Delete selected todo
M.delete_todo = function()
  if not selected_todo then
    return
  end

  local opts = {
    relative = "cursor",
    width = config.window.width - 2,
    height = 1,
    row = 0,
    col = 0,
    border = "single",
    style = "minimal",
  }

  local buf, win = Open_Scratch_Window(opts)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Delete todo? y/n" })

  vim.keymap.set("n", "y", function()
    if not storage.delete_todo(selected_list.todos, curr_line_todo) then
      print("Failed to delete")
      vim.api.nvim_win_close(win, true)
    else
      -- force rerender
      curr_line_todo = curr_line_todo - 1
      selected_todo = selected_list.todos[curr_line_todo]
      render_todos()
      save_quit(win)
    end
  end, { buffer = buf, noremap = true, silent = true })

  vim.keymap.set("n", "n", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true, silent = true })
end

return M
