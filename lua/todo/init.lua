-- Main entry point for the TODO plugin

local M = {}

-- Load default config
M.config = require("todo.config")
storage = require("todo.storage")
ui = require("todo.ui")

-- Setup function
function M.setup(user_config)
  -- Merge user config with defaults
  M.config = vim.tbl_extend("force", M.config, user_config or {})
  storage.load_data()

  -- init open keymap
  vim.keymap.set("n", "<leader>td", function()
    ui.open()
  end, { noremap = true, silent = true })
end

return M
