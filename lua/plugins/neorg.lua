return {
  {
    "nvim-neorg/neorg",
    ft = "norg",
    after = "nvim-treesitter",
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {}, -- Loads default behavior
          ["core.concealer"] = {
            config = {
              icons = {
                emphasis = {
                  strong = "**", -- Double asterisk for stronger emphasis
                  highlight = "*", -- Single asterisk for highlighting
                },
              },
              custom_highlights = {
                highlight = { fg = "#f28500", bg = "#2c2c2c" }, -- Custom color for highlights
              },
            },
          },
          ["core.dirman"] = {
            config = {
              workspaces = {
                work = "~/notes/work",
                personal = "~/notes/personal",
                projects = "~/notes/projects",
                templates = "~/notes/templates",
              },
              default_workspace = "personal", -- Set the default workspace
            },
          },
          ["core.esupports.metagen"] = {
            config = {
              type = "auto",
            },
          },
        },
      })

      -- Treesitter configuration specifically for Neorg
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "norg", "lua", "python" },
        highlight = {
          enable = true,
          disable = { "markdown" },
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        autotag = { enable = true },
      })

      -- Keybinding to quickly add single asterisk around visually selected text for highlighting
      -- vim.api.nvim_set_keymap("v", "<leader>h", ":'<,'>s/\\%V.*\\%V/*&*/g<CR>", { noremap = true, silent = true })
      -- vim.api.nvim_set_keymap("v", "<leader>h", "s/\\%V.*\\%V/\\=*&/", { noremap = true, silent = true })
      vim.api.nvim_set_keymap(
        "v",
        "<leader>h",
        [[<Esc>:%s/\%V\(.\{-}\)\%V/*\1*/g<CR>]],
        { noremap = true, silent = true }
      )
    end,
    requires = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
  },
}
