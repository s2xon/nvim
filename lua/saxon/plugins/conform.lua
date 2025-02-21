return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        swift = { "swiftformat" },
        lua = { "stylua" },
      },
      format_on_save = function(bufnr)
        local ignore_filetypes = { "oil" }
        if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
          return
        end

        return { timeout_ms = 500, lsp_fallback = true }
      end,
      log_level = vim.log.levels.ERROR,
    })

    -- Create an autocmd group for formatting on save
    local format_augroup = vim.api.nvim_create_augroup("format_on_save", { clear = true })

    -- Format Lua files on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = format_augroup,
      pattern = "*.lua",
      callback = function()
        conform.format({ bufnr = vim.fn.bufnr("%") })
      end,
    })
  end,
}
