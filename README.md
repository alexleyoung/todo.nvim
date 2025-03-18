# todo.nvim

An incredibly unnecessary, probably poorly engineered, canonical pet-project, yet very fun and pragmatic to make, Todo-List.

## What is Todo?

`todo.nvim` is a simple todo-list manager in `neovim`.

![demo](https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExZ3o4bjJsNDA1aTF5MjY5Y3N6Y2U1Z2V5MzR6aDFuajA1dGFoMXcwZCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/ZE3ODXf1ot3jd1PpH8/giphy.gif)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```
return {
  'alexleyoung/todo.nvim',
  config = function()
    require('todo').setup()
  end,
}
```

## Usage

### Default Keymaps

See [here](#Customization) for keymap customization

| Mapping | Action |
| --- | --- |
| `<leader>td` | Open Todo-Lists |
| `j/k` | Up/down navigation |
| `a` | New list or todo |
| `r` | Rename list or todo |
| `d` | Delete list or todo |
| `q` | Quit/go back |

## Customization

**TBD**
