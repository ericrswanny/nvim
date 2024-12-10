return {
  -- Use a local development path instead of the GitHub repository
  "ericrswanny/chkn.nvim",
  -- dependencies = { "nvim-lua/plenary.nvim" }, -- plenary for tests
  -- dir = "~/code/nvim/chkn.nvim", -- Replace this with the path to your dev dir
  config = function()
    require("chkn").setup() -- Use the default configuration
  end,
  lazy = false,
  keys = {
    {
      "<leader>sp",
      function()
        vim.cmd("silent! ChknToggle")
      end,
      desc = "Toggle Scratchpad",
    },
},
}
