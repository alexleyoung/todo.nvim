local M = {}

local config = require("todo.config")
local storage = require("todo.storage")

--- Save in-memory todos to file and close window
local save_quit = function()
  storage.save_data(storage.lists)
  vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
end

M.open = function()
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, config.window)
  vim.wo[win].cursorline = true

  --- render lists
  local lists = storage.get_lists()
  for i, list in ipairs(lists) do
    vim.api.nvim_buf_set_lines(buf, i - 1, -1, false, { "    " .. list.name })
  end

  --- keymaps
  -- functions
  vim.keymap.set("n", "a", M.create_list, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "<CR>", "<Nop>", { buffer = buf, noremap = true, silent = true })

  -- quit
  vim.keymap.set("n", "q", save_quit, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "<C-c>", save_quit, { buffer = buf, noremap = true, silent = true })

  -- disable non-vertical navigation
  vim.keymap.set("n", "l", "<Nop>", { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "h", "<Nop>", { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "L", "<Nop>", { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "H", "<Nop>", { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "w", "<Nop>", { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "b", "<Nop>", { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "W", "<Nop>", { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "B", "<Nop>", { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "i", "<Nop>", { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "a", "<Nop>", { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "o", "<Nop>", { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "I", "<Nop>", { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "A", "<Nop>", { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "O", "<Nop>", { buffer = buf, noremap = true, silent = true })
end

-- Creates new Todo List
M.create_list = function()
  local opts = {
    relative = "cursor",
    width = 30,
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

    -- TODO: add exception handling here
    vim.api.nvim_win_close(win, true)
    vim.cmd("stopinsert")
  end, { buffer = buf, noremap = true, silent = true })
end

return M
