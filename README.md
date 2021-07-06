# flow-coverage.nvim
Plugin for Neovim's built-in LSP to display flow type coverage as diagnostics

## Requirements
Neovim 0.5

## Installation

It's a standard neovim plugin. Follow your plugin manager's instructions.

Need a plugin manager? Try [pathogen](https://github.com/tpope/vim-pathogen), [packer.nvim](https://github.com/wbthomason/packer.nvim), [vim-packager](https://github.com/kristijanhusak/vim-packager), [dein](https://github.com/Shougo/dein.vim), or [Vundle](https://github.com/VundleVim/Vundle.vim)

## Configuration

Step one is to get Neovim LSP set up, which is beyond the scope of this guide.
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
