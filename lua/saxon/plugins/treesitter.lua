return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false, -- v1.0+ does not support lazy loading
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    -- v1.0+ API: setup() only accepts install_dir override
    require("nvim-treesitter").setup()

    -- Install parsers (async, no-op if already installed)
    require("nvim-treesitter").install({
      "json", "javascript", "typescript", "tsx", "yaml", "html", "css",
      "prisma", "markdown", "markdown_inline", "svelte", "graphql", "bash",
      "lua", "vim", "dockerfile", "gitignore", "query", "vimdoc",
      "c", "dart", "go", "cpp", "cmake",
    })

    -- Autotag for HTML/JSX/TSX
    require("nvim-ts-autotag").setup()

    -- Incremental selection (built into neovim, mapped manually)
    vim.keymap.set("n", "<C-space>", function()
      vim.treesitter.inspect_tree()
    end, { desc = "Inspect treesitter tree" })
  end,
}
