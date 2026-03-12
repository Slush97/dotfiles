-- Quick code runner without creating files - sniprun
-- Great for testing snippets without saving
return {
  "michaelb/sniprun",
  build = "bash ./install.sh",
  keys = {
    -- Run current line
    { "<leader>rx", function() require("sniprun").run() end, desc = "[R]un line/snippet" },
    -- Run visual selection
    { "<leader>rx", function() require("sniprun").run("v") end, desc = "[R]un snippet", mode = "v" },
    -- Clear sniprun output
    { "<leader>rc", function() require("sniprun.display").close_all() end, desc = "[R]un [C]lear" },
  },
  opts = {
    selected_interpreters = {},  -- empty = auto-detect
    repl_enable = {},             -- interpreters with REPL support
    repl_disable = {},            -- interpreters without REPL
    interpreter_options = {
      R_original = {
        interpreter = "R_original",
        options = {
          send_to_repl = true,
        }
      }
    },
    display = {
      "Classic",                  -- use floating window
      "VirtualTextOk",            -- show OK as virtual text
      "VirtualTextErr",           -- show errors as virtual text
    },
    live_display = { "VirtualTextOk" },
  },
}
