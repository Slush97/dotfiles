-- Fuzzy finder and more
return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- Telescope fzf native for better performance
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
  keys = {
    -- File pickers
    { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "[F]ind [F]iles" },
    { "<leader>fg", function() require("telescope.builtin").git_files() end, desc = "[F]ind [G]it files" },
    { "<leader>fr", function() require("telescope.builtin").oldfiles() end, desc = "[F]ind [R]ecent" },

    -- Search
    { "<leader>sb", function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "[S]earch [B]uffer" },
    { "<leader>sg", function() require("telescope.builtin").live_grep() end, desc = "[S]earch [G]rep" },

    -- LSP
    { "<leader>sd", function() require("telescope.builtin").diagnostics() end, desc = "[S]earch [D]iagnostics" },
    { "gd", function() require("telescope.builtin").lsp_definitions() end, desc = "[G]oto [D]efinition" },
    { "gr", function() require("telescope.builtin").lsp_references() end, desc = "[G]oto [R]eferences" },
    { "gi", function() require("telescope.builtin").lsp_implementations() end, desc = "[G]oto [I]mplementation" },

    -- Buffers
    { "<leader>bb", function() require("telescope.builtin").buffers() end, desc = "[B]uffers list" },
    { "<leader>bn", function() vim.cmd("enew") end, desc = "[B]uffer [N]ew" },
    { "<leader>bd", function() require("telescope.builtin").buffers({ delete_buffer = true }) end, desc = "[B]uffer [D]elete" },
  },
  config = function()
    require("telescope").setup({
      defaults = {
        prompt_prefix = "> ",
        selection_caret = "> ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        file_ignore_patterns = {},
        generic_sorter = require("telescope.sorters").get_generic_fzy_sorter,
        path_display = { "truncate" },
        winblend = 0,
        border = {},
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        color_devicons = true,
        use_less = true,
        set_env = { ["COLORTERM"] = "truecolor" },
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<Esc>"] = "close",
          },
          n = {
            ["q"] = "close",
          },
        },
      },
    })
    require("telescope").load_extension("fzf")
  end,
}
