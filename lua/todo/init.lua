-- lua/todo/init.lua
-- Main entry point for the TODO plugin

local M = {}
local storage = require("todo.storage")

-- Default config
M.config = {
  todo_file = vim.fn.stdpath("data") .. "/todo.json", -- Path to store TODOs
}

-- In-memory data structure for lists and TODOs
M.todo_lists = {}

-- Setup function
function M.setup(user_config)
  -- Merge user config with defaults
  M.config = vim.tbl_extend("force", M.config, user_config or {})

  -- Load existing TODOs from storage
  M.todo_lists = storage.load_data(M.config.todo_file)

  -- Set up keymaps (temporary example)
  vim.api.nvim_set_keymap("n", "<leader>td", ":lua require('todo.ui').open()<CR>", { noremap = true, silent = true })
end

return M
