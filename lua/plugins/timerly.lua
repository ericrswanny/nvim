return {
  "nvzone/timerly",
  dependencies = {
    "nvzone/volt",
    config = function()
      -- Map a key to toggle timerly
      vim.api.nvim_set_keymap("n", "<leader>T", ":TimerlyToggle<CR>", { noremap = true, silent = true })
    end,
  },
}
