local M = {}

local config = require("todo.config")
local storage = require("todo.storage")

--- Save in-memory todos to file and close window
local save_quit = function()
  storage.save_data(storage.lists)
  vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
end

M.open = function()
  local opts = config.window

  local buf = vim.api.nvim_create_buf(false, true)
  local _ = vim.api.nvim_open_win(buf, true, opts)

  -- TODO: reset to normal mode after refocusing buffer
  vim.api.nvim_buf_attach(buf, false, {})

  -- todo buf keymaps
  -- quit
  vim.keymap.set("n", "q", save_quit, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "<C-c>", save_quit, { buffer = buf, noremap = true, silent = true })

  -- make changes
  vim.keymap.set("n", "a", M.create_list, { buffer = buf, noremap = true, silent = true })
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
