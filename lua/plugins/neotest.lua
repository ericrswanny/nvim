return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sidlatau/neotest-dart",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-dart")({ -- Correctly require the dart module
            command = "flutter", -- Set the correct test command
          }),
        },
      })
    end,
  },
}
