-- Neovim config for Python, Rust, and R development
-- Bootstrap lazy.nvim
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

-- General settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Colors matching kitty terminal
vim.opt.background = "light"
vim.cmd("highlight clear")
vim.cmd("syntax reset")

-- Base colors matching kitty
vim.g.terminal_color_0 = "#3a3a3a"
vim.g.terminal_color_1 = "#8a2f2f"
vim.g.terminal_color_2 = "#1f7a1f"
vim.g.terminal_color_3 = "#8a6a2f"
vim.g.terminal_color_4 = "#2f5aa5"
vim.g.terminal_color_5 = "#7a2f6e"
vim.g.terminal_color_6 = "#2f7a7a"
vim.g.terminal_color_7 = "#c9c9c9"
vim.g.terminal_color_8 = "#e2e2e2"
vim.g.terminal_color_9 = "#b34a4a"
vim.g.terminal_color_10 = "#2fbf2f"
vim.g.terminal_color_11 = "#b08b4a"
vim.g.terminal_color_12 = "#4a76e6"
vim.g.terminal_color_13 = "#b04aa2"
vim.g.terminal_color_14 = "#4aa3a3"
vim.g.terminal_color_15 = "#ffffff"

-- Editor highlights matching kitty theme
local highlight = function(group, fg, bg, attr)
  attr = attr or "none"
  vim.api.nvim_set_hl(0, group, { fg = fg, bg = bg, [attr] = true, default = true })
end

-- Normal text
vim.api.nvim_set_hl(0, "Normal", { fg = "#0f0f0f", bg = "#f8f4ec" })
vim.api.nvim_set_hl(0, "NormalNC", { fg = "#0f0f0f", bg = "#f8f4ec" })

-- Selection
vim.api.nvim_set_hl(0, "Visual", { fg = "#f8f4ec", bg = "#1f4f9a" })
vim.api.nvim_set_hl(0, "VisualNOS", { fg = "#f8f4ec", bg = "#1f4f9a" })

-- Cursor
vim.api.nvim_set_hl(0, "Cursor", { fg = "#f7f2e8", bg = "#1f1f1f" })
vim.api.nvim_set_hl(0, "lCursor", { fg = "#f7f2e8", bg = "#1f1f1f" })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#f0ebe3" })
vim.api.nvim_set_hl(0, "CursorColumn", { bg = "#f0ebe3" })

-- Line numbers
vim.api.nvim_set_hl(0, "LineNr", { fg = "#8a7a6a", bg = "#f8f4ec" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#2f5aa5", bg = "#f0ebe3", bold = true })
vim.api.nvim_set_hl(0, "SignColumn", { fg = "#8a7a6a", bg = "#f8f4ec" })

-- Status line
vim.api.nvim_set_hl(0, "StatusLine", { fg = "#f8f4ec", bg = "#2f5aa5" })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#8a7a6a", bg = "#e8e4dc" })

-- Tab line
vim.api.nvim_set_hl(0, "TabLine", { fg = "#8a7a6a", bg = "#e8e4dc" })
vim.api.nvim_set_hl(0, "TabLineFill", { fg = "#f8f4ec", bg = "#e8e4dc" })
vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#f8f4ec", bg = "#2f5aa5" })

-- Search
vim.api.nvim_set_hl(0, "Search", { fg = "#f8f4ec", bg = "#1f4f9a" })
vim.api.nvim_set_hl(0, "IncSearch", { fg = "#f8f4ec", bg = "#8a6a2f" })

-- Folding
vim.api.nvim_set_hl(0, "Folded", { fg = "#8a7a6a", bg = "#e8e4dc" })
vim.api.nvim_set_hl(0, "FoldColumn", { fg = "#8a7a6a", bg = "#f8f4ec" })

-- Syntax highlights - warm theme
vim.api.nvim_set_hl(0, "Comment", { fg = "#7a6a5a", italic = true })
vim.api.nvim_set_hl(0, "Constant", { fg = "#7a2f6e" })
vim.api.nvim_set_hl(0, "String", { fg = "#1f7a1f" })
vim.api.nvim_set_hl(0, "Character", { fg = "#1f7a1f" })
vim.api.nvim_set_hl(0, "Number", { fg = "#7a2f6e" })
vim.api.nvim_set_hl(0, "Boolean", { fg = "#7a2f6e" })
vim.api.nvim_set_hl(0, "Float", { fg = "#7a2f6e" })

vim.api.nvim_set_hl(0, "Identifier", { fg = "#2f5aa5" })
vim.api.nvim_set_hl(0, "Function", { fg = "#2f5aa5" })

vim.api.nvim_set_hl(0, "Statement", { fg = "#8a2f2f" })
vim.api.nvim_set_hl(0, "Conditional", { fg = "#8a2f2f" })
vim.api.nvim_set_hl(0, "Repeat", { fg = "#8a2f2f" })
vim.api.nvim_set_hl(0, "Label", { fg = "#8a2f2f" })
vim.api.nvim_set_hl(0, "Operator", { fg = "#8a2f2f" })
vim.api.nvim_set_hl(0, "Keyword", { fg = "#8a2f2f" })
vim.api.nvim_set_hl(0, "Exception", { fg = "#8a2f2f" })

vim.api.nvim_set_hl(0, "PreProc", { fg = "#2f7a7a" })
vim.api.nvim_set_hl(0, "Include", { fg = "#2f7a7a" })
vim.api.nvim_set_hl(0, "Define", { fg = "#2f7a7a" })
vim.api.nvim_set_hl(0, "Macro", { fg = "#2f7a7a" })
vim.api.nvim_set_hl(0, "PreCondit", { fg = "#2f7a7a" })

vim.api.nvim_set_hl(0, "Type", { fg = "#8a6a2f" })
vim.api.nvim_set_hl(0, "StorageClass", { fg = "#8a6a2f" })
vim.api.nvim_set_hl(0, "Structure", { fg = "#8a6a2f" })
vim.api.nvim_set_hl(0, "Typedef", { fg = "#8a6a2f" })

vim.api.nvim_set_hl(0, "Special", { fg = "#7a2f6e" })
vim.api.nvim_set_hl(0, "SpecialChar", { fg = "#7a2f6e" })
vim.api.nvim_set_hl(0, "Tag", { fg = "#2f5aa5" })
vim.api.nvim_set_hl(0, "Delimiter", { fg = "#3a3a3a" })
vim.api.nvim_set_hl(0, "SpecialComment", { fg = "#7a6a5a" })
vim.api.nvim_set_hl(0, "Debug", { fg = "#8a2f2f" })

vim.api.nvim_set_hl(0, "Underlined", { fg = "#2f5aa5", underline = true })
vim.api.nvim_set_hl(0, "Ignore", { fg = "#7a6a5a" })
vim.api.nvim_set_hl(0, "Error", { fg = "#f8f4ec", bg = "#8a2f2f" })
vim.api.nvim_set_hl(0, "Todo", { fg = "#f8f4ec", bg = "#8a6a2f" })

-- LSP highlights
vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#8a2f2f" })
vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#8a6a2f" })
vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#2f5aa5" })
vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#2f7a7a" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { fg = "#8a2f2f", underline = true, sp = "#8a2f2f" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { fg = "#8a6a2f", underline = true, sp = "#8a6a2f" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { fg = "#2f5aa5", underline = true, sp = "#2f5aa5" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { fg = "#2f7a7a", underline = true, sp = "#2f7a7a" })

-- LSP signature help
vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#e8e4dc" })
vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#e8e4dc" })
vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#e8e4dc" })

-- Menu/Popup
vim.api.nvim_set_hl(0, "Pmenu", { fg = "#0f0f0f", bg = "#e8e4dc" })
vim.api.nvim_set_hl(0, "PmenuSel", { fg = "#f8f4ec", bg = "#2f5aa5" })
vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#d8d4cc" })
vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#8a7a6a" })
vim.api.nvim_set_hl(0, "PmenuKind", { fg = "#2f5aa5", bg = "#e8e4dc" })
vim.api.nvim_set_hl(0, "PmenuExtra", { fg = "#7a6a5a", bg = "#e8e4dc" })

-- Float window
vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#0f0f0f", bg = "#e8e4dc" })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#8a7a6a", bg = "#e8e4dc" })
vim.api.nvim_set_hl(0, "FloatTitle", { fg = "#f8f4ec", bg = "#2f5aa5" })

-- Spell checking
vim.api.nvim_set_hl(0, "SpellBad", { fg = "#8a2f2f", undercurl = true, sp = "#8a2f2f" })
vim.api.nvim_set_hl(0, "SpellCap", { fg = "#2f5aa5", undercurl = true, sp = "#2f5aa5" })
vim.api.nvim_set_hl(0, "SpellLocal", { fg = "#2f7a7a", undercurl = true, sp = "#2f7a7a" })
vim.api.nvim_set_hl(0, "SpellRare", { fg = "#7a2f6e", undercurl = true, sp = "#7a2f6e" })

-- Diff
vim.api.nvim_set_hl(0, "DiffAdd", { fg = "#1f7a1f", bg = "#d4ecd4" })
vim.api.nvim_set_hl(0, "DiffChange", { fg = "#8a6a2f", bg = "#ecdcc4" })
vim.api.nvim_set_hl(0, "DiffDelete", { fg = "#8a2f2f", bg = "#ecd4d4" })
vim.api.nvim_set_hl(0, "DiffText", { fg = "#2f5aa5", bg = "#d4dcec" })

-- MatchParen
vim.api.nvim_set_hl(0, "MatchParen", { fg = "#8a2f2f", bg = "#e8e4dc", bold = true })

-- Mode messages
vim.api.nvim_set_hl(0, "ModeMsg", { fg = "#1f7a1f" })
vim.api.nvim_set_hl(0, "MoreMsg", { fg = "#2f5aa5" })
vim.api.nvim_set_hl(0, "Question", { fg = "#2f5aa5" })
vim.api.nvim_set_hl(0, "WarningMsg", { fg = "#8a6a2f" })

-- === Quality of life keybindings ===

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focus left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focus down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focus up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus right" })

-- Buffer management
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })

-- Quick save/quit
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "[W]rite" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "[Q]uit" })
vim.keymap.set("n", "<leader>x", "<cmd>x<CR>", { desc = "Write and quit" })

-- Clear search with <Esc>
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Keep selection when indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Move lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Directory
vim.api.nvim_set_hl(0, "Directory", { fg = "#2f5aa5" })

-- Non-text characters
vim.api.nvim_set_hl(0, "NonText", { fg = "#8a7a6a" })
vim.api.nvim_set_hl(0, "Whitespace", { fg = "#b8b4ac" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "#c0bcb4" })

-- WinSeparator
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#d8d4cc", bg = "#f8f4ec" })

-- Quickfix window
vim.api.nvim_set_hl(0, "QuickFixLine", { fg = "#0f0f0f", bg = "#e0dcd4" })

-- Wild menu
vim.api.nvim_set_hl(0, "WildMenu", { fg = "#f8f4ec", bg = "#2f5aa5" })

-- Leader key
vim.g.mapleader = " "

-- Add cargo to PATH for rust-analyzer
vim.env.PATH = vim.env.HOME .. "/.cargo/bin:" .. vim.env.PATH

-- LSP Configuration using Neovim 0.11+ native API
vim.lsp.config("pylsp", {
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = { enabled = false },
        mccabe = { enabled = false },
        pyflakes = { enabled = false },
        flake8 = { enabled = false },
        pylint = { enabled = false },
        ruff = { enabled = true },
      },
    },
  },
})

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
      },
    },
  },
})

-- R language server configuration
vim.lsp.config("r_language_server", {
  cmd = { "R", "--slave", "-e", "languageserver::run()" },
  filetypes = { "r", "rmd" },
  root_markers = { ".git", "DESCRIPTION", ".Rproj" },
})

vim.lsp.enable("pylsp", "rust_analyzer", "r_language_server")

-- LSP keybindings
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
    end

    map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
    map("gr", vim.lsp.buf.references, "[G]oto [R]eferences")
    map("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
    map("K", vim.lsp.buf.hover, "Hover Documentation")
    map("gK", vim.lsp.buf.signature_help, "Signature Help")
    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
    map("<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, "[F]ormat")
  end,
})

-- === REPL-heavy workflow keybindings ===

-- Send code to REPL (uses tmux or terminal)
local send_to_repl = function(text)
  -- Try using vim-slime style sending if available, otherwise just print
  -- For now, use a simple terminal approach
  vim.cmd("TermExec cmd='" .. text .. "'")
end

-- Run current file (kept from original)
vim.keymap.set("n", "<leader>rf", function()
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%:p")
  local cmd
  if ft == "python" then
    cmd = "python3 " .. file
  elseif ft == "rust" then
    cmd = "cargo run"
  elseif ft == "r" then
    cmd = "Rscript " .. file
  else
    print("No run command for filetype: " .. ft)
    return
  end
  vim.cmd("vsplit | terminal " .. cmd)
end, { desc = "[R]un [F]ile" })

-- Send current line to REPL
vim.keymap.set("n", "<leader>rl", function()
  local line = vim.api.nvim_get_current_line()
  local ft = vim.bo.filetype
  local cmd
  if ft == "python" then
    cmd = "python3 -c \"" .. line .. "\""
  elseif ft == "r" then
    cmd = "Rscript -e \"" .. line .. "\""
  else
    print("No REPL for filetype: " .. ft)
    return
  end
  vim.cmd("belowright split | terminal " .. cmd)
  vim.cmd("resize 10")
end, { desc = "[R]epl [L]ine" })

-- Send visual selection to REPL
vim.keymap.set("v", "<leader>rs", function()
  local ft = vim.bo.filetype
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local code = table.concat(lines, "\n")

  local tmpfile = vim.fn.tempname() .. (ft == "python" and ".py" or ".R")
  local f = io.open(tmpfile, "w")
  f:write(code)
  f:close()

  local cmd
  if ft == "python" then
    cmd = "python3 " .. tmpfile
  elseif ft == "r" then
    cmd = "Rscript " .. tmpfile
  else
    print("No REPL for filetype: " .. ft)
    return
  end

  vim.cmd("belowright split | terminal " .. cmd)
  vim.cmd("resize 10")
end, { desc = "[R]epl [S]election" })

-- Plugin setup
require("lazy").setup({
  spec = {
    -- Import all plugins from lua/plugins/
    { import = "plugins" },

    -- Autocompletion
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
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
          completion = { completeopt = "menu,menuone,noinsert" },
          mapping = cmp.mapping.preset.insert({
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping.select_next_item(),
            ["<S-Tab>"] = cmp.mapping.select_prev_item(),
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
          }),
          sources = cmp.config.sources({
            { name = "lsp" },
            { name = "luasnip" },
          }, {
            { name = "buffer" },
            { name = "path" },
          }),
        })
      end,
    },

    -- Snippets for Python and R
    {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
  },
  defaults = {
    lazy = true,
    version = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
