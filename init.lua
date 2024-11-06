-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Set Gruvbox as the colorscheme
vim.o.background = "dark"
-- vim.cmd([[colorscheme gruvbox]])

-- Set up date shortcut
vim.api.nvim_set_keymap("n", "<leader>td", ":r! date '+\\%Y-\\%m-\\%d'<CR>", { noremap = true, silent = true })

-- Detect the environment
local os_name = vim.loop.os_uname().sysname
local display_server = os.getenv("XDG_SESSION_TYPE") -- "x11", "wayland", or nil

-- Define clipboard settings
if os_name == "Linux" and display_server == "x11" then
  -- Linux with X11 (Desktop)
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
elseif os_name == "Linux" and display_server == "wayland" then
  -- Linux with Wayland (Sway/Laptop)
  -- Assuming wl-clipboard is installed; otherwise, adjust the commands accordingly.
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
      ["+"] = "wl-copy",
      ["*"] = "wl-copy",
    },
    paste = {
      ["+"] = "wl-paste",
      ["*"] = "wl-paste",
    },
    cache_enabled = 0,
  }
elseif os_name == "Darwin" then
  -- macOS
  vim.g.clipboard = {
    name = "pbcopy/pbpaste",
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
    cache_enabled = 0,
  }
else
  -- Fallback or unsupported environment
  vim.g.clipboard = nil
end

-- Gruvbox setup with contrast
require("gruvbox").setup({
  contrast = "hard", -- Can be "soft", "medium", or "hard"
})
