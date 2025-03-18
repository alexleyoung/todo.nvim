# todo.nvim

An incredibly unnecessary, probably poorly engineered, canonical pet-project, yet very fun and pragmatic to make, Todo-List App.

## What is Todo?

`todo.nvim` is a simple todo-list manager in `neovim`.

![demo](https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExMGpyaGN4MXAwcXVta2NuM2p5dzYwaGFsbmpqNDNkeXNxejVpZTBhdiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/wUjCsorVekwD2ooSgj/giphy.gif | width=250)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
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
