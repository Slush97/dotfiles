-- File explorer with neo-tree
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "[E]xplorer toggle" },
    { "<leader>E", "<cmd>Neotree focus<CR>", desc = "[E]xplorer focus" },
    { "<leader>fe", "<cmd>Neotree reveal<CR>", desc = "[F]ind in [E]xplorer" },
  },
  opts = {
    close_if_last_window = true,
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    filesystem = {
      filtered_items = {
        visible = false,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      follow_current_file = {
        enabled = true,
      },
      use_libuv_file_watcher = true,
    },
    git_status = {
      symbols = {
        added = "+",
        changed = "~",
        deleted = "-",
        untracked = "?",
      },
    },
  },
}
