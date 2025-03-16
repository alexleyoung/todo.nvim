local M = {}

local config = require("todo.config")
local storage = require("todo.storage")

--- Save in-memory todos to file and close window
local save_quit = function()
  storage.save_data(storage.lists)
  vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
end

--- Render lists
local render_lists = function(bufr)
  local lists = storage.get_lists()
  for i, list in ipairs(lists) do
    vim.api.nvim_buf_set_lines(bufr, i - 1, -1, false, { "    " .. list.name })
  end
end

local menu_buf
local menu_win

M.open = function()
  menu_buf = vim.api.nvim_create_buf(false, true)
  menu_win = vim.api.nvim_open_win(menu_buf, true, config.window)
  vim.wo[menu_win].cursorline = true

  render_lists(menu_buf)

  --- keymaps
  -- functions
  vim.keymap.set("n", "a", M.create_list, { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "<CR>", function()
    print("enter")
  end, { buffer = menu_buf, noremap = true, silent = true })

  -- quit
  vim.keymap.set("n", "q", save_quit, { buffer = menu_buf, noremap = true, silent = true })
  vim.keymap.set("n", "<C-c>", save_quit, { buffer = menu_buf, noremap = true, silent = true })

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
  vim.keymap.set("i", "<C-C>", function()
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

return M
