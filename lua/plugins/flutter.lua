return {
  -- Dart and Flutter plugins
  {
    "dart-lang/dart-vim-plugin",
    ft = "dart",
  },
  {
    "akinsho/flutter-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for better UI
      "lukas-reineke/lsp-format.nvim", -- Added lsp-format for auto formatting
    },
    ft = "dart", -- Only load for Dart files
    config = function()
      require("flutter-tools").setup({
        ui = {
          border = "rounded", -- Adds rounded borders to UI elements
        },
        decorations = {
          statusline = {
            app_version = true,
            device = true,
          },
        },
        widget_guides = {
          enabled = true, -- Highlights widget boundaries
        },
        closing_tags = {
          highlight = "ErrorMsg", -- Highlight matching closing tags
          prefix = ">", -- Prefix for closing tags
          enabled = true,
        },
        lsp = {
          on_attach = function(client, bufnr)
            -- Auto format setup
            require("lsp-format").on_attach(client)
          end,
        },
      })
    end,
  },
}
