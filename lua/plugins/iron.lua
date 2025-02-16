return {
  {
    "Vigemus/iron.nvim",
    config = function()
      local iron = require("iron.core")

      iron.setup({
        config = {
          scratch_repl = true, -- Opens REPL in a separate buffer
          repl_definition = {
            python = { command = { "python" } },
            lua = { command = { "lua" } },
            javascript = { command = { "node" } },
          },
          -- repl_open_cmd = "horizontal botright 15split",
          repl_open_cmd = "vertical botright 80vsplit",
        },
        keymaps = {
          send_motion = "<leader>rs", -- Send a motion to REPL
          visual_send = "<leader>rv", -- Send selection to REPL
          send_line = "<leader>rl", -- Send current line to REPL
          send_file = "<leader>rf", -- Send entire file to REPL
          cr = "<leader>re", -- Send input (Enter)
          interrupt = "<leader>rc", -- Interrupt REPL
          exit = "<leader>rq", -- Exit REPL
        },
        highlight = {
          italic = true,
        },
      })
    end,
  },
}
