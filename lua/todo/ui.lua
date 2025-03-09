local M = {}

local config = require("todo.config")

M.open = function()
  local opts = config.window

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- todo buf keymaps
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "<C-c>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true, silent = true })

  vim.keymap.set("n", "a", function()
    M.create_list()
  end, { buffer = buf, noremap = true, silent = true })
end

-- Creates new Todo List
M.create_list = function()
  local opts = { relative = "cursor", width = 30, height = 1, row = 1, col = 0, border = "single" }

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_buf_set_lines(buf, 0, 1, false, { "Enter list name:" })
  vim.api.nvim_win_set_cursor(win, { 1, 0 })
  vim.cmd("startinsert")

  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function()
      local filename = vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1]
      vim.fn.writefile({}, filename)
      print("File created: " .. filename)
      vim.api.nvim_win_close(0, true)
    end,
  })
  -- vim.api.nvim_buf_attach(buf, false, {
  --   on_lines = function() end,
  -- })

  -- buf keymaps to close window
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "<C-c>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "<C-C>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true, silent = true })
end

return M
