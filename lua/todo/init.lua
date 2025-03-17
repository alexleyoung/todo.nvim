-- Main entry point for the TODO plugin

local config = require("todo.config")
local storage = require("todo.storage")

local M = {}

-- Load default config
M.options = config.get_defaults()

--- Sets up todo plugin with user-provided settings.
--- Merges user config with default settings.
---
--- @param user_opts table|nil User configuration table. Expected fields:
---   - window (table|nil): Floating window settings
---     - height (number|nil): Window height in lines (default: `math.floor(vim.o.lines * 0.6)`)
---     - width (number|nil): Window width in columns (default: `math.floor(vim.o.columns * 0.4)`)
---     - row (number|nil): Row position (default: centered)
---     - col (number|nil): Column position (default: centered)
---     - relative (string|nil): Window positioning mode (default: `"editor"`)
---     - border (string|nil): Border style (default: `"rounded"`)
---     - style (string|nil): Style mode (default: `"minimal"`)
---     - title (string|nil): Window title (default: `" Lists: "`)
---   - save_location (string|nil): Path to store TODO data (default: `vim.fn.stdpath("data") .. "/todo_data.json"`)
function M.setup(user_opts)
  user_opts = user_opts or {}
  -- Merge user config with defaults
  M.options = vim.tbl_deep_extend("force", M.options, user_opts or {})
  storage.load_data()

  -- init open keymap
  vim.keymap.set("n", "<leader>td", function()
    require("todo.ui").open()
  end, { noremap = true, silent = true })
end

return M
