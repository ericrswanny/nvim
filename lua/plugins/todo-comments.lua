-- return {
--   {
--     "folke/todo-comments.nvim",
--     dependencies = { "nvim-lua/plenary.nvim" },
--     config = function()
--       require("todo-comments").setup({
--         keywords = {
--           TODO = { icon = " ", color = "info", alt = { "SDL", "ERIC" } },
--           FIX = { icon = " ", color = "error" },
--           HACK = { icon = " ", color = "warning" },
--           NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
--         },
--         search = {
--           pattern = [[\b(KEYWORDS)\b.*]], -- Regex pattern for TODO-like comments
--         },
--       })
--     end,
--   },
-- }

return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
}
