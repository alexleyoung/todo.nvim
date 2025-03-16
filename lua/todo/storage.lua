-- Handles TODOs CRUD in JSON format

local config = require("todo.config")

--- @class TodoItem
--- @field id number
--- @field text string The content of the todo item
--- @field completed boolean Whether the todo item is completed

--- @class TodoList
--- @field name string Name of the list
--- @field created_at number
--- @field todos TodoItem[] Todos

--- @class PartialTodoItem : TodoItem
--- @field id number
--- @field text? string The content of the todo item (optional)
--- @field completed? boolean Whether the todo item is completed (optional)

--- @class Storage
--- @field lists TodoList[] The in-memory table of todo lists

local M = {}

--- In-mem storage of user data
--- @type TodoList[]
M.lists = {}

-- filepath for save data
local filepath = config.save_location or vim.fn.stdpath("data") .. "/todo_data.json"

--- Loads Todo data from a JSON file into M.lists.
function M.load_data()
  local file = io.open(filepath, "r")
  if not file then
    return -- do nothing on no saved data
  end
  local content = file:read("*a")
  file:close()

  local success, data = pcall(vim.fn.json_decode, content)
  if not success or type(data) ~= "table" then
    return -- do nothing if decoding fails
  end

  M.lists = data
end

--- Saves TODO data to a JSON file.
--- @param data TodoList[]: Table containing todo lists.
--- @return boolean: `true` if saving is successful, `false` otherwise.
function M.save_data(data)
  local file = io.open(filepath, "w")
  if not file then
    return false -- Failed to open file
  end
  file:write(vim.fn.json_encode(data))
  file:close()
  return true
end

--- Creates a new todo list
--- @param name string: Name of the list
--- @return boolean: `true` if creation is successful, `false` otherwise.
function M.create_list(name)
  if not name:match("^%s*(.-)%s*$") then
    return false
  end

  local list = {
    name = name,
    created_at = os.time(),
    todos = {},
  }

  table.insert(M.lists, list)

  return true
end

--- Get todo list
--- @param name string: Name of the list
--- @return TodoList|nil, number|nil: List corresponding to the name, empty table if not found, and the index which it was found
function M.get_list(name)
  for i, list in ipairs(M.lists) do
    if list.name == name then
      return list, i
    end
  end
  return nil, nil
end

--- Get all todo lists
--- @return TodoList[]: All, if any, todo lists
function M.get_lists()
  return M.lists
end

--- Rename an existing todo list
--- @param name string: Name of the list
--- @param new_name string: New name to replace the initial name
--- @return boolean: `true` if rename is successful, `false` otherwise.
function M.rename_list(name, new_name)
  local list = M.get_list(name)

  if not list then
    return false
  end

  list.name = new_name
  return true
end

--- Rename an existing todo list
--- @param idx integer: Name of the list
--- @param new_name string: New name to replace the initial name
--- @return boolean: `true` if rename is successful, `false` otherwise.
function M.rename_list_idx(idx, new_name)
  if not idx or not new_name then
    return false
  end

  M.lists[idx].name = new_name
  return true
end

--- Deletes todo list
--- @param name string: Name of the list
--- @return boolean: `true` if deletion is successful, `false` otherwise.
function M.delete_list(name)
  local _, idx = M.get_list(name)

  if not idx then
    return false
  end

  table.remove(M.lists, idx)
  return true
end

--- Deletes todo list by index
--- @param idx number: Index of the list
--- @return boolean: `true` if deletion is successful, `false` otherwise.
function M.delete_list_idx(idx)
  if not idx then
    return false
  end

  table.remove(M.lists, idx)
  return true
end

return M
