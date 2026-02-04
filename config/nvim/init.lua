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
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10

-- diagnostic configuration
vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  virtual_text = true,
  jump = { float = true },
})

-- highlight when yanking text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- keymaps
local set = vim.keymap.set
set('n', '<Esc>', '<cmd>nohlsearch<CR>')
set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- window navigation
set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- telescope keymaps
later(function()
  pcall(require, 'telescope')
  local builtin = require('telescope.builtin')
  set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
  set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

  -- search in current buffer
  set('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  -- search in open files
  set('n', '<leader>s/', function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end, { desc = '[S]earch [/] in Open Files' })

  -- search neovim config files
  set('n', '<leader>sn', function()
    builtin.find_files { cwd = vim.fn.stdpath('config') }
  end, { desc = '[S]earch [N]eovim files' })
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
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
    end

    -- basic LSP keymaps
    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')

    -- telescope LSP keymaps (only if telescope is available)
    local ok, builtin = pcall(require, 'telescope.builtin')
    if ok then
      map('grr', builtin.lsp_references, '[G]oto [R]eferences')
      map('gri', builtin.lsp_implementations, '[G]oto [I]mplementation')
      map('grd', builtin.lsp_definitions, '[G]oto [D]efinition')
      map('grt', builtin.lsp_type_definitions, '[G]oto [T]ype Definition')
      map('gO', builtin.lsp_document_symbols, 'Open Document Symbols')
      map('gW', builtin.lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
    end

    -- toggle inlay hints if supported
    if client and client:supports_method('textDocument/inlayHint', bufnr) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
      end, '[T]oggle Inlay [H]ints')
    end

    -- auto format on save if supported
    if client and client.supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = bufnr,
        callback = function() vim.lsp.buf.format({ bufnr = bufnr, id = client.id }) end,
      })
    end

    -- document highlight on cursor hold
    if client and client:supports_method('textDocument/documentHighlight', bufnr) then
      local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = bufnr,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = bufnr,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = event2.buf })
        end,
      })
    end
  end,
})

-- configure treesitter and mini-submodules
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
  require('which-key').setup({
    delay = 0,
    spec = {
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>t', group = '[T]oggle' },
    },
  })

  require('mini.statusline').setup({
    content = {
      active = function()
        local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
        local git           = MiniStatusline.section_git({ trunc_width = 75 })
        local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
        local location      = '%l│%v' -- short format
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
