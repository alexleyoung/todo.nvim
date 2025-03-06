-- Handles TODOs CRUD in JSON format

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
M.lists = {}

--- Loads Todo data from a JSON file into M.lists.
--- @param filepath string: Path to the JSON file.
function M.load_data(filepath)
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

  M.lists = data
end

--- Saves TODO data to a JSON file.
--- @param filepath string: Path to the JSON file.
--- @param data TodoList[]: Table containing todo lists.
--- @return boolean: `true` if saving is successful, `false` otherwise.
function M.save_data(filepath, data)
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
--- @return TodoList, number: List corresponding to the name, empty table if not found, and the index which it was found
function M.get_list(name)
  for i, list in ipairs(M.lists) do
    if list.name == name then
      return list, i
    end
  end
  return {}
end

--- Rename an existing todo list
--- @param name string: Name of the list
--- @param new_name string: New name to replace the initial name
--- @return boolean: `true` if rename is successful, `false` otherwise.
function M.rename_list(name, new_name)
  local list = M.get_list(name)

  if not next(list) then
    list.name = new_name
    return true
  end

  return false
end

--- Deletes todo list
--- @param name string: Name of the list
--- @return boolean: `true` if deletion is successful, `false` otherwise.
function M.delete_list(name)
  list, idx = M.get_list(name)

  if next(list) then
    table.remove(M.lists, idx)
  end

  return true
end

--- Creates a new todo item
--- @param content TodoItem: Name of the list
--- @return boolean: `true` if creation is successful, `false` otherwise.
function M.create_todo(content)
  return true
end

--- Read todos from a list

--- Edit an existing todo
--- @param id number: id of the todo
--- @param content PartialTodoItem: Potentially partial TodoItem
--- @return boolean: `true` if edit is successful, `false` otherwise.
function M.edit_todo(id, content)
  return true
end

--- Deletes todo item
--- @param id number: Name of the list
--- @return boolean: `true` if deletion is successful, `false` otherwise.
function M.delete_todo(id)
  return true
end

return M
