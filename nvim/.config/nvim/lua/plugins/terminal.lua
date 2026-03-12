-- Better terminal integration with toggleterm
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>tt", function() vim.cmd("ToggleTerm direction=horizontal") end, desc = "[T]oggle [T]erm (horizontal)" },
    { "<leader>tv", function() vim.cmd("ToggleTerm direction=vertical") end, desc = "[T]oggle [V]ertical term" },
    { "<leader>tf", function() vim.cmd("ToggleTerm direction=float") end, desc = "[T]oggle [F]loat term" },
  },
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    open_mapping = [[<c-\>]],
    direction = "horizontal",
    shade_terminals = true,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
      border = "rounded",
      winblend = 0,
    },
  },
}
