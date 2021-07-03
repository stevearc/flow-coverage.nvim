# flow-coverage.nvim
Neovim plugin to display flow coverage information

## Requirements
Neovim 0.5

## Installation
flow-coverage.nvim works with [Pathogen](https://github.com/tpope/vim-pathogen)

```sh
cd ~/.vim/bundle/
git clone https://github.com/stevearc/flow-coverage.nvim
```

and [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'stevearc/flow-coverage.nvim'
```

## Configuration

Step one is to get a Neovim LSP set up, which is beyond the scope of this guide.
See [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) for instructions.

After you have a functioning LSP setup, you will need to customize the
`on_attach` callback.

```lua
require'lspconfig'.flow.setup{
  on_attach = require'flow'.on_attach,
}
```

It will automatically start showing uncovered lines using standard LSP
diagnostics display. Additionally, you can get the coverage with

```lua
require'flow'.get_coverage_percent()
```
