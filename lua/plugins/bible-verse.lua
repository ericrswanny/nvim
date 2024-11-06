return {
  {
    "anthony-halim/bible-verse.nvim",
    config = function()
      require("bible-verse").setup({
        diatheke = {
          translation = "KJV",
        },
      })
    end,
    vmd = "BibleVerse",
  },
}
