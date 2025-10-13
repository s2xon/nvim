return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        "ts_ls",
        "html",
        "cssls",
        "tailwindcss",
        "svelte",
        "lua_ls",
        "graphql",
        "emmet_ls",
        "prismals",
        "pyright",
        "gopls",
        "clangd",
        "asm_lsp",
      },
    })

    require("lspconfig").clangd.setup({
      settings = {
        clangd = {
          ["clangd.arguments"] = {
            "--clang-tidy", -- Enable clang-tidy if needed
            "--enable-config", -- Enable to use .clangd config
          },
          ["clangd.formatting"] = {
            SpacesInAngles = false, -- Disable spaces in angle brackets
          },
        },
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "isort", -- python formatter
        "black", -- python formatter
        "pylint",
        "eslint_d",
        "gofumpt",
        "clang-format",
        "rustfmt",
      },
    })
  end,
}
