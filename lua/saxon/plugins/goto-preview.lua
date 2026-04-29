return {
  "rmagatti/goto-preview",
  event = "BufEnter",
  config = function()
    require("goto-preview").setup({
      width = 120,
      height = 25,
      border = "rounded",
      default_mappings = false,
      post_open_hook = function(buf, win)
        -- <Enter> inside preview jumps to the file and closes the window
        vim.keymap.set("n", "<CR>", function()
          local pos = vim.api.nvim_win_get_cursor(win)
          local bufname = vim.api.nvim_buf_get_name(buf)
          vim.api.nvim_win_close(win, true)
          vim.cmd("edit " .. vim.fn.fnameescape(bufname))
          vim.api.nvim_win_set_cursor(0, pos)
        end, { buffer = buf, desc = "Jump to file from preview" })
      end,
    })

    local gp = require("goto-preview")
    vim.keymap.set("n", "gpd", gp.goto_preview_definition, { desc = "Preview definition" })
    vim.keymap.set("n", "gpt", gp.goto_preview_type_definition, { desc = "Preview type definition" })
    vim.keymap.set("n", "gpi", gp.goto_preview_implementation, { desc = "Preview implementation" })
    vim.keymap.set("n", "gpr", gp.goto_preview_references, { desc = "Preview references" })
    vim.keymap.set("n", "gpc", require("goto-preview").close_all_win, { desc = "Close all previews" })
  end,
}
