--- Creates scratch buffer and window with exit keymaps
--- comment
--- @param opts table: Window options (see :h nvim_open_win)
--- @return integer, integer: Buffer and window ints
Open_Scratch_Window = function(opts, exit_function)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, opts)

  vim.keymap.set("n", "<C-c>", exit_function, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "<Esc>", exit_function, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("i", "<C-c>", exit_function, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("i", "<Esc>", exit_function, { buffer = buf, noremap = true, silent = true })

  return buf, win
end

Disable_Navigation_Keys = function(bufnr)
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
end
