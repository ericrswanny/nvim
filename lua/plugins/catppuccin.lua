return {
  "catppuccin/nvim",
  name = "catppuccin",
  flavour = "auto", -- latte, frappe, macchiato, mocha
  lazy = false,
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      -- Your configuration options here
    })
    vim.cmd("colorscheme catppuccin")
  end,
}
