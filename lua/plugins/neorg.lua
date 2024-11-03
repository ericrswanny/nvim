return {
  {
    "nvim-neorg/neorg",
    ft = "norg",
    after = "nvim-treesitter", -- Ensure Neorg loads after Treesitter
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {
            config = {
              icons = {
                todo = {
                  enabled = false, -- Disable all task icons
                },
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
          ["core.esupports.metagen"] = { -- Enable meta fields support
            config = {
              type = "auto", -- Automatically detect meta fields and format them
            },
          },
        },
      })

      -- Treesitter configuration specifically for Neorg
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "norg", "lua", "python" }, -- Automatically install the Neorg parser along with other languages if needed
        highlight = {
          enable = true,
          disable = { "markdown" }, -- Example: Disable Treesitter for markdown if desired
          additional_vim_regex_highlighting = false,
        },
        -- Include any other Treesitter-specific configurations here
        indent = { enable = true },
        autotag = { enable = true }, -- Autotagging support, if applicable for other filetypes
      })
    end,
    requires = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
  },
}
