local M = {}

local vh = 0.6 -- percentage screen height
local vw = 0.4 -- percentage screen width

-- Function to calculate window size dynamically
M.window = {
  height = math.floor(vim.o.lines * vh),
  width = math.floor(vim.o.columns * vw),
  row = math.floor(vim.o.lines * ((1 - vh) / 2)),
  col = math.floor(vim.o.columns * ((1 - vw) / 2)),
  relative = "editor",
  border = "rounded",
  style = "minimal",
}

M.save_location = vim.fn.stdpath("data") .. "/todo_data.json" -- Path to store TODOs
print(vim.fn.stdpath("data"))

return M
