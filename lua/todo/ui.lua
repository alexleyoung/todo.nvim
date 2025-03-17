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
local save_quit = function()
  storage.save_data(storage.lists)
  vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
end

--- Render lists
--- @param bufr integer
local render_lists = function(bufr)
  if #storage.lists == 0 then
    vim.api.nvim_buf_set_lines(bufr, 0, -1, false, { "    " })
    return
  end

  for i, list in ipairs(storage.lists) do
    vim.api.nvim_buf_set_lines(bufr, i - 1, -1, false, { "  - " .. list.name })
  end

  vim.api.nvim_win_set_cursor(menu_win, { curr_line, 0 })
end

--- Render todos
--- @param bufr integer
--- @param list TodoList
local render_todos = function(bufr, list)
  if #list.todos == 0 then
    vim.api.nvim_buf_set_lines(bufr, 0, -1, false, { "    " })
    return
  end

  for i, todo in ipairs(list.todos) do
    local indent = todo.completed and "   ■ " or "   □ "
    vim.api.nvim_buf_set_lines(list_buf, i - 1, -1, false, { indent .. todo.text })
  end

  vim.api.nvim_win_set_cursor(list_win, { curr_line_todo, 0 })
end

--- Open Todo UI
M.open = function()
  menu_buf, menu_win = Open_Scratch_Window(config.window)
  vim.wo[menu_win].cursorline = true
  selected_list = storage.lists[curr_line]

  render_lists(menu_buf)

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

    -- force rerender
    render_lists(menu_buf)

    -- close window
    vim.api.nvim_win_close(win, true)
    vim.cmd("stopinsert")

    -- move cursor to new list
    curr_line = #storage.lists
    selected_list = storage.lists[curr_line]
    vim.api.nvim_win_set_cursor(menu_win, { curr_line, 0 })
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
    title = "Delete list '" .. selected_list.name .. "'?",
  }

  local buf, win = Open_Scratch_Window(opts)
  local conf_string = "y/n: "
  vim.cmd("startinsert!")
  vim.api.nvim_buf_set_lines(buf, 0, 1, false, { conf_string })
  vim.api.nvim_win_set_cursor(win, { 1, string.len(conf_string) })

  local conf
  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function()
      conf = vim.api.nvim_get_current_line()
    end,
  })

  -- buf keymaps to close window
  vim.keymap.set("i", "<CR>", function()
    if conf == conf_string .. "y" then
      if not storage.delete_list_idx(curr_line) then
        print("Failed to delete")
      else
        -- force rerender
        render_lists(menu_buf)
      end
    end

    vim.api.nvim_win_close(win, true)
    vim.cmd("stopinsert")
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
    render_lists(menu_buf)

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

  for i, todo in ipairs(selected_list.todos) do
    local indent = todo.completed and "   ■ " or "   □ "
    vim.api.nvim_buf_set_lines(list_buf, i - 1, -1, false, { indent .. todo.text })
  end

  --- Keymaps
  -- functions
  vim.keymap.set("n", "a", M.create_todo, { buffer = list_buf, noremap = true, silent = true })
  vim.keymap.set("n", "d", M.delete_todo, { buffer = list_buf, noremap = true, silent = true })
  vim.keymap.set("n", "r", M.rename_todo, { buffer = list_buf, noremap = true, silent = true })
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

    -- force rerender
    render_todos(list_buf, selected_list)

    vim.api.nvim_win_close(win, true)
    vim.cmd("stopinsert")

    curr_line_todo = #selected_list.todos
    selected_todo = selected_list.todos[curr_line_todo]
    vim.api.nvim_win_set_cursor(list_win, { curr_line_todo, 0 })
  end, { buffer = buf, noremap = true, silent = true })
end

--- Delete selected todo
M.delete_todo = function() end
M.rename_todo = function() end

--- Check/uncheck selected todo
M.complete_todo = function()
  storage.toggle_completed(selected_todo)
  render_todos(list_buf, selected_list)
end

return M
