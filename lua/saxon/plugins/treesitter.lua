return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- v1.0+ does not support lazy loading
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    -- v1.0+ API: setup() only accepts install_dir override
    require("nvim-treesitter").setup()

    -- Install parsers after lazy.nvim finishes loading (main branch exposes
    -- `install` asynchronously; calling it inline yields nil)
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      once = true,
      callback = function()
        local ok, ts = pcall(require, "nvim-treesitter")
        if ok and type(ts.install) == "function" then
          ts.install({
            "json", "javascript", "typescript", "tsx", "yaml", "html", "css",
            "prisma", "markdown", "markdown_inline", "svelte", "graphql", "bash",
            "lua", "vim", "dockerfile", "gitignore", "query", "vimdoc",
            "c", "dart", "go", "cpp", "cmake", "cuda",
          })
        end
      end,
    })

    -- Autotag for HTML/JSX/TSX
    require("nvim-ts-autotag").setup()

    -- Incremental selection (built into neovim, mapped manually)
    vim.keymap.set("n", "<C-space>", function()
      vim.treesitter.inspect_tree()
    end, { desc = "Inspect treesitter tree" })
  end,
}
