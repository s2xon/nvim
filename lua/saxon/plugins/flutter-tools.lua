return {
  "nvim-flutter/flutter-tools.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim",
  },
  config = function()
    local keymap = vim.keymap

    local on_attach = function(_, bufnr)
      keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Go to definition", buffer = bufnr })
      keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "Go to references", buffer = bufnr })
      keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<cr>", { desc = "Go to implementation", buffer = bufnr })
      keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<cr>", { desc = "Go to type definition", buffer = bufnr })
      keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action", buffer = bufnr })
      keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol", buffer = bufnr })
      keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", { desc = "Buffer diagnostics", buffer = bufnr })
      keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics", buffer = bufnr })
      keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic", buffer = bufnr })
      keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic", buffer = bufnr })
      keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Docs", buffer = bufnr })
      keymap.set("n", "<leader>rs", ":LspRestart<CR>", { desc = "Restart LSP", buffer = bufnr })
    end

    require("flutter-tools").setup({
      lsp = {
        on_attach = on_attach,
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      },
    })
  end,
}
