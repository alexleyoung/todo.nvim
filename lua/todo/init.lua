-- Main entry point for the TODO plugin

local M = {}

-- Load default config
M.config = require("todo.config")

-- Setup function
function M.setup(user_config)
  -- Merge user config with defaults
  M.config = vim.tbl_extend("force", M.config, user_config or {})

  -- init open keymap
  vim.keymap.set("n", "<leader>td", function()
    require("todo.ui").open()
  end, { noremap = true, silent = true })
end

return M
