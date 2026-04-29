return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim", -- for action picker
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            schema = {
              model = {
                default = "claude-sonnet-4-6",
              },
            },
          })
        end,
      },
      strategies = {
        chat = { adapter = "anthropic" },
        inline = { adapter = "anthropic" },
        agent = { adapter = "anthropic" },
      },
      display = {
        action_palette = {
          provider = "telescope",
        },
      },
    })

    local keymap = vim.keymap
    -- Pull-up action picker (the "search thing")
    keymap.set({ "n", "v" }, "<leader>ia", "<cmd>CodeCompanionActions<cr>", { desc = "AI action palette" })
    -- Inline ask (selected text or current line)
    keymap.set({ "n", "v" }, "<leader>ii", "<cmd>CodeCompanion<cr>", { desc = "AI inline ask" })
    -- Open chat buffer
    keymap.set({ "n", "v" }, "<leader>ic", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "AI chat toggle" })
    -- Add current buffer to chat context
    keymap.set("n", "<leader>ib", "<cmd>CodeCompanionChat Add<cr>", { desc = "AI add buffer to chat" })
  end,
}
