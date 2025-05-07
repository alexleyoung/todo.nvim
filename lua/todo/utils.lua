local M = {}

--- Get confirmation window base table (ex: Delete? y/n)
M.get_prompt_win_opts = function(extension)
  local conf_win_opts = {
    relative = "cursor",
    width = require("todo").options.window.width - 2,
    height = 1,
    row = 0,
    col = 0,
    border = "single",
    style = "minimal",
  }
  if extension then
    return vim.tbl_extend("force", conf_win_opts, extension)
  end
  return conf_win_opts
end

--- Creates scratch buffer and window with exit keymaps
--- comment
--- @param opts table: Window options (see :h nvim_open_win)
--- @return integer, integer: Buffer and window ints
M.open_scratch_window = function(opts, exit_function)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, opts)

  vim.keymap.set("n", "<C-c>", exit_function, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "<Esc>", exit_function, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("i", "<C-c>", exit_function, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("i", "<Esc>", exit_function, { buffer = buf, noremap = true, silent = true })

  return buf, win
end

--- Disables VIM navigation motions in a buffer
M.disable_navigation_keys = function(bufnr)
  -- disable non-vertical navigation
  vim.keymap.set("n", "l", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "h", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "L", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "H", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "w", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "b", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "W", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "B", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "i", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "o", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "I", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "A", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "O", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "c", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "C", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "y", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "Y", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "p", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "P", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "J", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "K", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "l", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "h", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "L", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "H", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "w", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "b", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "W", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "B", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "i", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "o", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "I", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "A", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "O", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "c", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "C", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "p", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "P", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "J", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("v", "K", "<Nop>", { buffer = bufnr, noremap = true, silent = true })
end

return M
