return {
  -- Add tpope's vim-dadbod plugin
  {
    "tpope/vim-dadbod",
    lazy = true, -- Load the plugin only when required
    cmd = { "DB", "DBUI", "DBUIToggle", "DBUIFindBuffer" }, -- Load when these commands are called
    dependencies = {
      "kristijanhusak/vim-dadbod-ui", -- Optional: UI for `vim-dadbod`
      "kristijanhusak/vim-dadbod-completion", -- Optional: Auto-completion for SQL commands
    },
    config = function()
      -- Setup vim-dadbod configurations here if needed
      vim.g.db_ui_auto_execute_table_helpers = 1 -- Enable some useful table functions in DBUI

      -- Define the SetupDBUILayout function
      function SetupDBUILayout()
        vim.cmd("Neotree toggle") -- Open Neo-tree
        vim.cmd("leftabove vsplit") -- Open a vertical split on the left
        vim.cmd("vertical resize 30") -- Adjust the Neo-tree width
        vim.cmd("wincmd l") -- Move to the right pane
        vim.cmd("belowright split") -- Open DBUI at the bottom
        vim.cmd("DBUI") -- Open the DBUI in this pane
      end

      -- Map the function to a keybinding
      vim.api.nvim_set_keymap("n", "<leader>od", ":lua SetupDBUILayout()<CR>", { noremap = true, silent = true })
    end,
  },
}
