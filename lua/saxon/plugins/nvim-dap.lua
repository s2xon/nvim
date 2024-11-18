return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "wojciech-kulik/xcodebuild.nvim",
  },
  config = function()
    local xcodebuild = require("xcodebuild.integrations.dap")
    -- SAMPLE PATH, change it to your local codelldb path
    local codelldbPath = os.getenv("HOME") .. "/tools/extension/adapter/codelldb"

    xcodebuild.setup(codelldbPath)

    vim.keymap.set("n", "<leader>zd", xcodebuild.build_and_debug, { desc = "Build & Debug" })
    vim.keymap.set("n", "<leader>zr", xcodebuild.debug_without_build, { desc = "Debug Without Building" })
    vim.keymap.set("n", "<leader>zt", xcodebuild.debug_tests, { desc = "Debug Tests" })
    vim.keymap.set("n", "<leader>zT", xcodebuild.debug_class_tests, { desc = "Debug Class Tests" })
    vim.keymap.set("n", "<leader>z", xcodebuild.toggle_breakpoint, { desc = "Toggle Breakpoint" })
    vim.keymap.set("n", "<leader>Z", xcodebuild.toggle_message_breakpoint, { desc = "Toggle Message Breakpoint" })
    vim.keymap.set("n", "<leader>zx", xcodebuild.terminate_session, { desc = "Terminate Debugger" })
  end,
}
