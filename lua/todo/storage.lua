-- Handles TODOs CRUD in JSON format

--- @class TodoItem
--- @field id number
--- @field content string The content of the todo item
--- @field completed boolean Whether the todo item is completed

--- @class TodoList
--- @field name string Name of the list
--- @field created_at number
--- @field todos TodoItem[] Todos

--- @class PartialTodoItem : TodoItem
--- @field id number
--- @field content? string The content of the todo item (optional)
--- @field completed? boolean Whether the todo item is completed (optional)

--- @class Storage
--- @field lists TodoList[] The in-memory table of todo lists

local M = {}

--- Sort todos by completion and creation
--- @param a TodoItem
--- @param b TodoItem
--- @return boolean: a < b
local sorter = function(a, b)
  -- return true if a is not completed and b is
  if not a.completed and b.completed then
    return true
  elseif a.completed and not b.completed then
    return false
  end
  return a.id < b.id
end

--- In-mem storage of user data
--- @type TodoList[]
M.lists = {}

--- Loads Todo data from a JSON file into M.lists.
function M.load_data()
  local file = io.open(require("todo").options.save_location, "r")
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
  local file = io.open(require("todo").options.save_location, "w")
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
  if not name:match("%S") then
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

--- Creates new todo in list
--- @param list TodoList
--- @param content string
--- @return boolean: `true` if creation is successful, `false` otherwise.
function M.create_todo(list, content)
  local todo = {
    id = #list.todos,
    content = content,
    completed = false,
  }

  table.insert(list.todos, todo)
  table.sort(list.todos, sorter)

  return true
end

--- Get todo by content
--- @param list TodoList: TodoList to search in
--- @param content string: Content to search for
--- @return TodoItem|nil
function M.get_todo_by_content(list, content)
  for _, todo in ipairs(list.todos) do
    print(content)
    if todo.content == content then
      return todo
    end
  end

  return nil
end

--- Edit todo content
--- @param todo TodoItem
--- @param new_content string
--- @return boolean
function M.edit_todo_content(todo, new_content)
  if not new_content or not new_content:match("%S") then
    return false
  end

  todo.content = new_content

  return true
end

--- Check/uncheck a todo
--- @param list TodoList
--- @param todo TodoItem
--- @return boolean: `true` if creation is successful, `false` otherwise.
function M.toggle_completed(list, todo)
  todo.completed = not todo.completed
  table.sort(list.todos, sorter)

  return true
end

--- Delete todo
--- @param list TodoList: List to delete from
--- @param idx number: Index of todo in list
--- @return boolean
function M.delete_todo(list, idx)
  table.remove(list, idx)

  return true
end

return M
