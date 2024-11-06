-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Set Gruvbox as the colorscheme
-- vim.o.background = "light"
vim.o.background = "dark"
vim.opt.clipboard = "unnamedplus"
-- vim.cmd([[colorscheme gruvbox]])
vim.api.nvim_set_keymap("n", "<leader>td", ':r! date "+\\%Y-\\%m-\\%d"<CR>', { noremap = true, silent = true })

vim.g.clipboard = {
  name = "xclip",
  copy = {
    ["+"] = "xclip -selection clipboard",
    ["*"] = "xclip -selection primary",
  },
  paste = {
    ["+"] = "xclip -selection clipboard -o",
    ["*"] = "xclip -selection primary -o",
  },
  cache_enabled = 0,
}

require("gruvbox").setup({
  contrast = "hard", -- Can be "soft", "medium", or "hard"
})
