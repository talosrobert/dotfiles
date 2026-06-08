-- settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ts = 4
vim.opt.sts = 4
vim.opt.sw = 4
vim.opt.et = true
vim.opt.clipboard = 'unnamedplus' -- system copy-paste

-- relative number toggle
local numbergroup = vim.api.nvim_create_augroup('numbertoggle', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter' }, {
  pattern = '*',
  group = numbergroup,
  callback = function()
    if vim.opt.number:get() then vim.opt.relativenumber = true end
  end,
})
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }, {
  pattern = '*',
  group = numbergroup,
  callback = function()
    if vim.opt.number:get() then vim.opt.relativenumber = false end
  end,
})

-- bootstrap lazy
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath }
end
vim.opt.rtp:prepend(lazypath)

-- plugins
require('lazy').setup({
  { 'folke/tokyonight.nvim', priority = 1000, config = function() vim.cmd.colorscheme 'tokyonight-night' end },
  { 'neovim/nvim-lspconfig' },
  { 'saghen/blink.cmp', version = '*', opts = { sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } } } },
  { 
    'stevearc/conform.nvim', 
    opts = { 
      formatters_by_ft = { terraform = { 'terraform_fmt' }, go = { 'gofmt' }, zig = { 'zigfmt' } },
      format_on_save = { timeout_ms = 500, lsp_fallback = true } 
    } 
  },
  { 
    'nvim-treesitter/nvim-treesitter', 
    build = ':TSUpdate', 
    config = function() 
      require('nvim-treesitter').setup { 
        highlight = { enable = true }, 
        ensure_installed = { 'terraform', 'go', 'yaml', 'lua', 'vim', 'vimdoc', 'zig' } 
      } 
    end 
  },
  { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' }, config = function()
      require('telescope').setup {
        defaults = { vimgrep_arguments = { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case' } }
      }
    end },
  { 'folke/which-key.nvim', opts = {} },
  { 'lewis6991/gitsigns.nvim', opts = {} },
})

-- telescope maps
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[s]earch [h]elp' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[s]earch [f]iles' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[s]earch current [w]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[s]earch by [g]rep (ripgrep)' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[s]earch [d]iagnostics' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] find existing buffers' })

-- lsp attach
local on_attach = function(client, bufnr)
  client.server_capabilities.semanticTokensProvider = nil -- kill jank
  local map = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'lsp: ' .. desc })
  end
  map('gd', builtin.lsp_definitions, '[g]oto [d]efinition')
  map('gr', builtin.lsp_references, '[g]oto [r]eferences')
  map('K', vim.lsp.buf.hover, 'hover docs')
  map('<leader>rn', vim.lsp.buf.rename, '[r]e[n]ame')
  map('<leader>ca', vim.lsp.buf.code_action, '[c]ode [a]ction')
end

-- terraform setup
vim.lsp.config('terraformls', {
  cmd = { '/usr/bin/terraform-ls', 'serve' },
  on_attach = on_attach,
  root_dir = vim.fs.root(0, { '.terraform', '.terraform.lock.hcl', 'main.tf' }),
})
vim.lsp.enable('terraformls')

-- go setup
vim.lsp.config('gopls', {
  cmd = { '/usr/bin/gopls' },
  on_attach = on_attach,
})
vim.lsp.enable('gopls')

-- zig setup
vim.lsp.config('zls', {
  cmd = { vim.fn.expand('~/.local/bin/zls') },
  on_attach = on_attach,
  root_dir = vim.fs.root(0, { 'build.zig', 'build.zig.zon' }),
})
vim.lsp.enable('zls')

-- diagnostic maps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'prev diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'next diagnostic' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'show diagnostic error' })
