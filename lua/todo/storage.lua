-- Handles TODOs CRUD in JSON format
--
-- JSON Shape:
--
-- {
--   "list1": [
--     {"text": "Buy groceries", "completed": false},
--     {"text": "Call Alice", "completed": true}
--   ],
--   "list2": [
--     {"text": "Finish project", "completed": false}
--   ]
-- }

local M = {}

-- Load TODO data from a JSON file
function M.load_data(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return {} -- Return an empty table if file doesn't exist
  end
  local content = file:read("*a")
  file:close()

  local success, data = pcall(vim.fn.json_decode, content)
  if not success or type(data) ~= "table" then
    return {} -- Return empty table if decoding fails
  end

  -- Ensure structure consistency
  for list, todos in pairs(data) do
    if type(todos) ~= "table" then
      data[list] = {}
    else
      for i, todo in ipairs(todos) do
        if type(todo) ~= "table" or not todo.text then
          todos[i] = { text = tostring(todo), completed = false }
        elseif todo.completed == nil then
          todo.completed = false
        end
      end
    end
  end

  return data
end

-- Save TODO data to a JSON file
function M.save_data(filepath, data)
  local file = io.open(filepath, "w")
  if not file then
    return false -- Failed to open file
  end
  file:write(vim.fn.json_encode(data))
  file:close()
  return true
end

return M
