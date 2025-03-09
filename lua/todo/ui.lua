local M = {}

local config = require("todo.config")

M.open = function()
  local opts = config.get_window_opts()

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- buf keymaps
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true, silent = true })
end

return M
