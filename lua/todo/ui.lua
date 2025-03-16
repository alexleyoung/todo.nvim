local M = {}

local config = require("todo.config")
local storage = require("todo.storage")

local menu_buf
local menu_win

--- Save in-memory todos to file and close window
local save_quit = function()
  storage.save_data(storage.lists)
  vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
end

--- Render lists
local render_lists = function(bufr)
  if #storage.lists == 0 then
    vim.api.nvim_buf_set_lines(bufr, 0, -1, false, { "    " })
    return
  end

  for i, list in ipairs(storage.lists) do
    vim.api.nvim_buf_set_lines(bufr, i - 1, -1, false, { "    " .. list.name })
  end
end

M.open = function()
  menu_buf = vim.api.nvim_create_buf(false, true)
  menu_win = vim.api.nvim_open_win(menu_buf, true, config.window)
  vim.wo[menu_win].cursorline = true

  render_lists(menu_buf)

  --- keymaps
  -- functions
  vim.keymap.set("n", "a", M.create_list, { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "d", M.delete_list, { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "<CR>", function()
    print("enter")
  end, { buffer = menu_buf, noremap = true, silent = true })

  -- quit
  vim.keymap.set("n", "q", save_quit, { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "<C-c>", save_quit, { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "<Esc>", save_quit, { buffer = menu_buf, noremap = true, silent = true })

  -- disable non-vertical navigation
  vim.keymap.set("n", "l", "<Nop>", { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "h", "<Nop>", { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "L", "<Nop>", { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "H", "<Nop>", { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "w", "<Nop>", { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "b", "<Nop>", { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "W", "<Nop>", { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "B", "<Nop>", { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "i", "<Nop>", { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "o", "<Nop>", { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "I", "<Nop>", { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "A", "<Nop>", { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "O", "<Nop>", { buffer = menu_buf, noremap = true, silent = true })
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

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.cmd("startinsert")

  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function()
      name = vim.api.nvim_get_current_line()
    end,
  })

  -- buf keymaps to close window
  vim.keymap.set("i", "<C-c>", function()
    vim.api.nvim_win_close(win, true)
    vim.cmd("stopinsert")
  end, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("i", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
    vim.cmd("stopinsert")
  end, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("i", "<CR>", function()
    if not storage.create_list(name) then
      print("Failed to create list...")
      return
    end

    -- force rerender
    render_lists(menu_buf)

    -- TODO: add exception handling here
    vim.api.nvim_win_close(win, true)
    vim.cmd("stopinsert")
  end, { buffer = buf, noremap = true, silent = true })
end

M.delete_list = function()
  local curr_line = vim.api.nvim_win_get_cursor(menu_win)[1]
  local list = storage.lists[curr_line]
  if not list then
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
    title = "Delete '" .. list.name or "" .. "'?",
  }

  local conf_buf = vim.api.nvim_create_buf(false, true)
  local conf_win = vim.api.nvim_open_win(conf_buf, true, opts)
  vim.api.nvim_buf_set_lines(conf_buf, 0, 1, false, { "y/n:  " })
  vim.api.nvim_win_set_cursor(conf_win, { 1, 5 })
  vim.cmd("startinsert")

  local conf
  vim.api.nvim_buf_attach(conf_buf, false, {
    on_lines = function()
      conf = vim.api.nvim_get_current_line()
    end,
  })

  -- buf keymaps to close window
  vim.keymap.set("i", "<C-c>", function()
    vim.api.nvim_win_close(conf_win, true)
    vim.cmd("stopinsert")
  end, { buffer = conf_buf, noremap = true, silent = true })
  vim.keymap.set("i", "<C-C>", function()
    vim.api.nvim_win_close(conf_win, true)
    vim.cmd("stopinsert")
  end, { buffer = conf_buf, noremap = true, silent = true })
  vim.keymap.set("i", "<Esc>", function()
    vim.api.nvim_win_close(conf_win, true)
    vim.cmd("stopinsert")
  end, { buffer = conf_buf, noremap = true, silent = true })
  vim.keymap.set("i", "<CR>", function()
    if conf == "y/n: y " then
      if not storage.delete_list_idx(curr_line) then
        print("Failed to delete")
      else
        -- force rerender
        render_lists(menu_buf)
      end
    end

    -- TODO: add exception handling here
    vim.api.nvim_win_close(conf_win, true)
    vim.cmd("stopinsert")
  end, { buffer = conf_buf, noremap = true, silent = true })
end

return M
