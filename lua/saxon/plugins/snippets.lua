return {
  vim.keymap.set("n", "<leader>ie", function()
    local lines = {
      "if err != nil {",
      "\tlog.Fatal(err)",
      "}",
    }
    vim.api.nvim_put(lines, "l", true, true)
    vim.api.nvim_feedkeys("k$", "n", true) -- move to line before closing }
  end, { desc = "Insert Go error check" }),
}
