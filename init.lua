vim.g.mapleader = ' '
vim.g.localleader = ' '
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)
vim.keymap.set('n', '<leader>wq', vim.cmd.wq)
vim.opt.relativenumber = true
vim.opt.nu = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.colorcolumn = '80'

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)   

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = '0.1.5',
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sf', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set('n', '<leader>t', ':NvimTreeToggle<CR>', { silent = true })
    end,
  },
  {
    dir = vim.fn.expand("~/.config/nvim/opencode.nvim"),
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("opencode").setup({
        preferred_picker = nil,
        preferred_completion = nil,
        default_global_keymaps = true,
        default_mode = 'build',
        legacy_commands = true,
        keymap_prefix = '<leader>o',
        opencode_executable = 'opencode',
        keymap = {
          editor = {
            ['<leader>og'] = { 'toggle', desc = 'Toggle Opencode window' },
            ['<leader>oi'] = { 'open_input', desc = 'Open input window' },
            ['<leader>oI'] = { 'open_input_new_session', desc = 'Open input (new session)' },
            ['<leader>oh'] = { 'select_history', desc = 'Select from history' },
            ['<leader>oo'] = { 'open_output', desc = 'Open output window' },
            ['<leader>ot'] = { 'toggle_focus', desc = 'Toggle focus' },
            ['<leader>oT'] = { 'timeline', desc = 'Session timeline' },
            ['<leader>oq'] = { 'close', desc = 'Close Opencode window' },
            ['<leader>os'] = { 'select_session', desc = 'Select session' },
            ['<leader>oR'] = { 'rename_session', desc = 'Rename session' },
            ['<leader>op'] = { 'configure_provider', desc = 'Configure provider' },
            ['<leader>oz'] = { 'toggle_zoom', desc = 'Toggle zoom' },
            ['<leader>ov'] = { 'paste_image', desc = 'Paste image from clipboard' },
          },
        },
        api_key = os.getenv("OPENCODE_API_KEY") or "your_api_key_here",
      })
      vim.keymap.set('n', '<leader>oc', ':Opencode<CR>', { desc = "Open OpenCode" })
      vim.keymap.set('v', '<leader>oc', ':Opencode<CR>', { desc = "Open OpenCode with selection" })
    end,
  },
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  {
    "preservim/nerdcommenter",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        configs.setup({
          ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
          highlight = { enable = true },
          indent = { enable = true },
        })
      end
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
        local cmp_capabilities = require('cmp_nvim_lsp').default_capabilities()
      local function on_attach(client, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "h", "hpp" },
        callback = function(args)
          local bufnr = args.buf
          vim.schedule(function()
            if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
              vim.lsp.start({
                name = "clangd",
                cmd = { "clangd", "--background-index" },
                root_dir = vim.fn.getcwd,
                on_attach = on_attach,
                capabilities = cmp_capabilities,
              })
            end
          end)
        end,
      })

      vim.api.nvim_create_user_command("LspStart", function()
        local bufnr = vim.api.nvim_get_current_buf()
        if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
          vim.lsp.start({
            name = "clangd",
            cmd = { "clangd", "--background-index" },
            root_dir = vim.fn.getcwd,
            on_attach = on_attach,
            capabilities = cmp_capabilities,
          })
          print("Clangd LSP started")
        else
          print("Clangd LSP already running")
        end
      end, {})
    end,
  },
})

vim.keymap.set('n', '<leader>lsp', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cmp_capabilities = require('cmp_nvim_lsp').default_capabilities()
  if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
    vim.lsp.start({
      name = "clangd",
      cmd = { "clangd", "--background-index", "--std=c11" },
      root_dir = vim.fn.getcwd,
      on_attach = function(client, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
      end,
    })
    print("LSP started")
  else
    print("LSP already running")
  end
end, { desc = "Start LSP manually" })


-- OpenCode info
vim.api.nvim_create_user_command("OpenCodeInfo", function()
  print("OpenCode Usage:")
  print("  <leader>oc - Open Opencode interface")
  print("  Then type: quick_chat (for chat with current context)")
  print("  Or type: help (to see all commands)")
  print("")
  print("Available Opencode commands:")
  print("  quick_chat - Chat with current buffer/selection")
  print("  new - Create new session")
  print("  sessions - Select existing session")
  print("  models - Switch provider/model")
  print("  help - Show full help")
  print("")
  print("42 Header:")
  print("  :Stdheader - Insert 42 school header")
  print("  <F1> - Insert 42 school header")
  print("  vim.g.user42 = 'your_username' (to set your name)")
  print("  vim.g.mail42 = 'your_email@student.42.fr' (to set your email)")
  print("")
  print("NERDCommenter:")
  print("  <leader>cc - Comment line")
  print("  <leader>cu - Uncomment line")
  print("  <leader>c<space> - Toggle comment")
  print("")
  print("Tmux Navigator:")
  print("  Ctrl+h/j/k/l - Navigate between tmux panes and nvim windows")
  print("")
  print("Telescope:")
  print("  <leader>ff - Find files")
  print("  <leader>fg - Live grep")
  print("  <leader>fb - Buffers")
  print("  <leader>fh - Help tags")
  print("")
  print("NvimTree:")
  print("  <leader>t - Toggle NvimTree")
end, { desc = "Show usage info" })
