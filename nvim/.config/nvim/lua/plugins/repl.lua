-- REPL integration with iron.nvim for interactive sessions
return {
  "hkupty/iron.nvim",
  keys = {
    -- Start REPL
    { "<leader>rp", function()
      local iron = require("iron")
      local ft = vim.bo.filetype

      if ft == "python" then
        iron.repl_for(ft)
      elseif ft == "r" then
        iron.repl_for(ft)
      else
        print("No REPL configured for: " .. ft)
      end
    end, desc = "[R]epl [P]start" },

    -- Send line to REPL
    { "<leader>rl", function()
      require("iron").send_line()
    end, desc = "[R]epl send [L]ine" },

    -- Send visual selection to REPL
    { "<leader>rs", function()
      require("iron").visual_send()
    end, desc = "[R]epl [S]end selection", mode = "v" },

    -- Send until cursor
    { "<leader>ru", function()
      require("iron").send_until_cursor()
    end, desc = "[R]epl send [U]ntil cursor" },

    -- Repeat last command
    { "<leader>rr", function()
      require("iron").repeat_cmd()
    end, desc = "[R]epl [R]epeat" },

    -- Clear REPL
    { "<leader>rc", function()
      require("iron").clear()
    end, desc = "[R]epl [C]lear" },

    -- Focus on editor
    { "<leader>ri", function()
      require("iron").focus_on_editor()
    end, desc = "[R]epl focu[I]s editor" },

    -- Focus on REPL
    { "<leader>rf", function()
      require("iron").focus_on_repl()
    end, desc = "[R]epl [F]ocus" },
  },
  opts = {
    config = {
      -- REPL definitions
      repl_definition = {
        sh = {
          command = { "bash" },
        },
        python = {
          command = { "python3" },
        },
        R = {
          command = { "R", "--no-save", "--no-restore" },
        },
      },
      -- How the REPL window will be opened
      repl_open_cmd = "botright 20 split",
    },
    -- Highlighting
    highlight = {
      italic = true,
    },
    ignore_blank_lines = true,
  },
}
