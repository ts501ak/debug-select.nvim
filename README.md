# debug-select.nvim

This plugin aims to provide a simple way to configure the program to be debugged 
and its command line arguments in a [nvim-dap](https://github.com/mfussenegger/nvim-dap) configuartion.

## Usage
The plugin provides two Lua modules `debug-select.program` and `debug-select.args` 
with the functions `get_program` and `get_args`. These can be passed to a nvim-dap 
configuration. In addition, both modules also have a `toggle_menu` function to 
open/close a menu.  

`get_program` and `get_args` evaluate the contents of the first line of the 
corresponding menu:

* `get_program` returns the line replacing relative paths with absolute ones
* `get_args` returns an array containing the line splitted by whitespaces

In both menus you can press:

* `q` or `<ESC>` to close the menu and save the changes
* `<CR>` to select the current line, i.e. move it to the first line of the buffer, 
close the menu and save the changes

The data is stored for each working directory in the `debug-select.json` file 
inside the nvim data path (`:echo stdpath("data")`).

## Setup
### Requirments
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
* [Neovim](https://github.com/neovim/neovim) (v0.7.0+)

### Instalation
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```
use {
    'ts501ak/debug-select.nvim',
    requires = {'nvim-lua/plenary.nvim'}
}
```

Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'ts501ak/debug-select.nvim'
```

### Keymaps
Toggle the menus with `<F11>` and `<F12>`:

```lua
vim.keymap.set("n", "<F11>", function() require('debug-select.program'):toggle_menu() end, { noremap = true, silent = true})
vim.keymap.set("n", "<F12>", function() require('debug-select.args'):toggle_menu() end, { noremap = true, silent = true})
```

### Adapter configuartion
Example configuration for C++ via lldb-vscode:

```lua
local dap = require('dap')
dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',

    program = require('debug-select.program').get_program,
    args = require('debug-select.args').get_args,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}
```

## Plugin settings 
The plugin configuration is done via the setup function. Below are all 
the available settings with their default values:

```lua
require('debug-select').setup({
    -- menu appearance 
    width = 60,
    height = 10,
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },

    -- update the data file after closing the menu instead of leaving neovim
    save_on_change = true,

    -- launch a nvim-dap debug session after selecting a line 
    dap_continue_on_select = false,

    -- enable git-worktree integration
    git_worktree_integration = false
})
```

### Git Worktree
The plugin provides an integration for the [git-worktreee](https://github.com/ThePrimeagen/git-worktree.nvim) plugin from ThePrimeagen.
If you enable the integration, the data of the current working directory will be 
copied into a newly created worktree beofre switching to it.

## Note 
I created this plugin mainly for my personal use.
Nevertheless, I thought it could be usefull for others aswell.
As a result, the plugin is neither well tested nor does it contain many error checks.
Calling functions with bad arguments or changing the `debug-select.json` file 
manually can therefore easily break the plugin. If this is the case, you should 
reset the file by deleting it. 
