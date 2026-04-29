return {
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<M-l>", -- Alt+l to avoid Tab conflict with cmp
        clear_suggestion = "<C-]>",
        accept_word = "<M-j>",
      },
    })
  end,
}
