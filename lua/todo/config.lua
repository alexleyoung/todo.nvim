local M = {}

local defaults = {
  window = {
    height = math.floor(vim.o.lines * 0.6),
    width = math.floor(vim.o.columns * 0.4),
    row = math.floor(vim.o.lines * 0.2),
    col = math.floor(vim.o.columns * 0.3),
    relative = "editor",
    border = "rounded",
    style = "minimal",
    title = " Lists: ",
  },
  save_location = vim.fn.stdpath("data") .. "/todo_data.json",
}

-- Function to calculate window size dynamically
M.get_defaults = function()
  return vim.deepcopy(defaults) -- Ensures fresh defaults every time
end

return M
