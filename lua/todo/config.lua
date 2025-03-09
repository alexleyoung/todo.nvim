local M = {}

local vh = 0.6 -- percentage screen height
local vw = 0.4 -- percentage screen width

-- Function to calculate window size dynamically
M.get_window_opts = function()
  local height = math.floor(vim.o.lines * vh)
  local width = math.floor(vim.o.columns * vw)
  return {
    height = height,
    width = width,
    row = math.floor(vim.o.lines * ((1 - vh) / 2)),
    col = math.floor(vim.o.columns * ((1 - vw) / 2)),
    relative = "editor",
    border = "rounded",
    style = "minimal",
  }
end

M.save_location = vim.fn.stdpath("data") .. "/todo.json" -- Path to store TODOs

return M
