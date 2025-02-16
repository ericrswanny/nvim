return {
  "vim-test/vim-test",
  vim.keymap.set("n", "<leader>Vt", ":TestNearest<CR>"),
  vim.keymap.set("n", "<leader>VT", ":TestFile<CR>"),
  vim.keymap.set("n", "<leader>Va", ":TestSuite<CR>"),
  vim.keymap.set("n", "<leader>Vl", ":TestLast<CR>"),
  vim.keymap.set("n", "<leader>Vg", ":TestVisit<CR>"),
}
