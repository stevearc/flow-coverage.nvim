# flow-coverage.nvim
Plugin for Neovim's built-in LSP to display flow type coverage as diagnostics

## Requirements
Neovim 0.5+

## Installation

flow-coverage supports all the usual plugin managers

<details>
  <summary>Packer</summary>

  ```lua
  require('packer').startup(function()
      use 'stevearc/flow-coverage.nvim'
  end)
  ```
</details>

<details>
  <summary>Paq</summary>

  ```lua
  require "paq" {
      'stevearc/flow-coverage.nvim';
  }
  ```
</details>

<details>
  <summary>vim-plug</summary>

  ```vim
  Plug 'stevearc/flow-coverage.nvim'
  ```
</details>

<details>
  <summary>dein</summary>

  ```vim
  call dein#add('stevearc/flow-coverage.nvim')
  ```
</details>

<details>
  <summary>Pathogen</summary>

  ```sh
  git clone --depth=1 https://github.com/stevearc/flow-coverage.nvim.git ~/.vim/bundle/
  ```
</details>

<details>
  <summary>Neovim native package</summary>

  ```sh
  git clone --depth=1 https://github.com/stevearc/flow-coverage.nvim.git \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/flow-coverage/start/flow-coverage.nvim
  ```
</details>

## Setup

Step one is to get Neovim LSP set up, which is beyond the scope of this guide.
See [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) for instructions.
You will need to use that plugin to set up the flow LSP, for example:

```lua
require('lspconfig').flow.setup{}
```

When the flow LSP client is configured and this plugin is installed, Neovim will
automatically start showing uncovered lines using standard diagnostics display.
Additionally, you can get the coverage percentage with:

```lua
require('flow').get_coverage_percent()
```

## Configuration

Variable                   | Type   | Default | Description
---                        | ---    | ---     | ---
`g:flow_coverage_interval` | number | `5000`  | How often (in ms) to refresh the type coverage of a file. Set to 0 to disable.
