-- boostrap
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/echasnovski/mini.nvim', mini_path })
  vim.cmd('packadd mini.nvim')
end

local Deps = require('mini.deps')
Deps.setup({ path = { package = path_package } })
local add, now, later = Deps.add, Deps.now, Deps.later

-- dependencies
now(function()
  add('folke/tokyonight.nvim')
  vim.cmd.colorscheme('tokyonight-night')
end)

later(function()
  add('nvim-lua/plenary.nvim')
  add('nvim-telescope/telescope.nvim')
  add('folke/which-key.nvim')
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
  })
end)

-- editor settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = 'a'
opt.showmode = false
opt.clipboard = 'unnamedplus'
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = 'yes'
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
opt.inccommand = 'split'
opt.cursorline = true
opt.scrolloff = 10

-- keymaps
local set = vim.keymap.set
set('n', '<Esc>', '<cmd>nohlsearch<CR>')
set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev Diagnostic' })
set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next Diagnostic' })
set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show Diagnostic Error' })
set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open Diagnostic List' })

-- [[ 5. Telescope ]]
later(function()
  pcall(require, 'telescope') -- Ensure telescope is safe
  local builtin = require('telescope.builtin')
  set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find buffers' })
end)

-- lsp configs
vim.lsp.config('terraformls', { cmd = { 'terraform-ls', 'serve' }, filetypes = { 'terraform', 'hcl' } })
vim.lsp.enable('terraformls')

vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod' },
  settings = { gopls = { completeUnimported = true, usePlaceholders = true } },
})
vim.lsp.enable('gopls')

-- lsp keybindings
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local bufnr = event.buf
    local map = function(keys, func, desc) set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc }) end

    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('K',  vim.lsp.buf.hover,      'Hover Documentation')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gr', function() require('telescope.builtin').lsp_references() end, '[G]oto [R]eferences')

    if client and client.supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = bufnr,
        callback = function() vim.lsp.buf.format({ bufnr = bufnr, id = client.id }) end,
      })
    end
  end,
})

-- [[ 8. Mini Modules & Treesitter ]]
later(function()
  local status, ts = pcall(require, 'nvim-treesitter.configs')
  if status then
    ts.setup({
      ensure_installed = { 'go', 'terraform', 'lua', 'vim', 'vimdoc', 'markdown' },
      highlight = { enable = true },
    })
  end

  require('mini.ai').setup({ n_lines = 500 })
  require('mini.surround').setup()
  require('mini.pairs').setup()
  require('which-key').setup()

  require('mini.statusline').setup({
    content = {
      active = function()
        local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
        local git           = MiniStatusline.section_git({ trunc_width = 75 })
        local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
        local location      = '%l│%v' 
        return MiniStatusline.combine_groups({
          { hl = mode_hl, strings = { mode } },
          { hl = 'MiniStatuslineDevinfo', strings = { git } },
          '%<',
          { hl = 'MiniStatuslineFilename', strings = { filename } },
          '%=',
          { hl = mode_hl, strings = { location } },
        })
      end
    }
  })
end)
