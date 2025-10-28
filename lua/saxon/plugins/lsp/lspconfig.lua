return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "nvim-lua/plenary.nvim",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    local mason_lspconfig = require("mason-lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local keymap = vim.keymap

    --------------------------------------------------------------------------
    --  Keymaps for when LSP attaches
    --------------------------------------------------------------------------
    local on_attach = function(_, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }

      keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Go to definition", buffer = bufnr })
      keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "Go to references", buffer = bufnr })
      keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<cr>", { desc = "Go to implementation", buffer = bufnr })
      keymap.set(
        "n",
        "gt",
        "<cmd>Telescope lsp_type_definitions<cr>",
        { desc = "Go to type definition", buffer = bufnr }
      )
      keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action", buffer = bufnr })
      keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol", buffer = bufnr })
      keymap.set(
        "n",
        "<leader>D",
        "<cmd>Telescope diagnostics bufnr=0<CR>",
        { desc = "Buffer diagnostics", buffer = bufnr }
      )
      keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics", buffer = bufnr })
      keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic", buffer = bufnr })
      keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic", buffer = bufnr })
      keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Docs", buffer = bufnr })
      keymap.set("n", "<leader>rs", ":LspRestart<CR>", { desc = "Restart LSP", buffer = bufnr })
    end

    --------------------------------------------------------------------------
    --  Capabilities
    --------------------------------------------------------------------------
    local capabilities = cmp_nvim_lsp.default_capabilities()

    --------------------------------------------------------------------------
    --  SourceKit (manual macOS setup)
    --------------------------------------------------------------------------
    vim.lsp.config("sourcekit", {
      capabilities = capabilities,
      on_attach = on_attach,
      cmd = { vim.trim(vim.fn.system("xcrun -f sourcekit-lsp")) },
    })
    vim.lsp.enable("sourcekit")

    --------------------------------------------------------------------------
    --  Diagnostic signs
    --------------------------------------------------------------------------
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.HINT] = "󰠠",
          [vim.diagnostic.severity.INFO] = "",
        },
      },
    })

    --------------------------------------------------------------------------
    --  Mason integration
    --------------------------------------------------------------------------
    mason_lspconfig.setup()

    -- Get all servers installed by Mason
    local servers = mason_lspconfig.get_installed_servers()

    --------------------------------------------------------------------------
    --  Define server-specific configs
    --------------------------------------------------------------------------
    local custom = {
      svelte = function()
        vim.lsp.config("svelte", {
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            on_attach(client, bufnr)
            vim.api.nvim_create_autocmd("BufWritePost", {
              pattern = { "*.js", "*.ts" },
              callback = function(ctx)
                client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
              end,
            })
          end,
        })
        vim.lsp.enable("svelte")
      end,

      graphql = function()
        vim.lsp.config("graphql", {
          capabilities = capabilities,
          on_attach = on_attach,
          filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
        })
        vim.lsp.enable("graphql")
      end,

      emmet_ls = function()
        vim.lsp.config("emmet_ls", {
          capabilities = capabilities,
          on_attach = on_attach,
          filetypes = {
            "html",
            "typescriptreact",
            "javascriptreact",
            "css",
            "sass",
            "scss",
            "less",
            "svelte",
          },
        })
        vim.lsp.enable("emmet_ls")
      end,

      lua_ls = function()
        vim.lsp.config("lua_ls", {
          capabilities = capabilities,
          on_attach = on_attach,
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              completion = { callSnippet = "Replace" },
            },
          },
        })
        vim.lsp.enable("lua_ls")
      end,
    }

    --------------------------------------------------------------------------
    --  Enable all servers (custom or default)
    --------------------------------------------------------------------------
    for _, server in ipairs(servers) do
      if custom[server] then
        custom[server]() -- use custom setup
      else
        vim.lsp.config(server, {
          capabilities = capabilities,
          on_attach = on_attach,
        })
        vim.lsp.enable(server)
      end
    end
  end,
}
